import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speedtalks/main.dart';

import '../models/user_model.dart';

class AuthController extends GetxController {
  RxBool isLoggedIn = false.obs;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void onInit() {
    super.onInit();
    checkLoginStatus();
  }

  Future<void> checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    isLoggedIn.value = prefs.getBool('isLoggedIn') ?? false;
  }

  Future<void> loginWithEmailAndPassword(String email, String password) async {
    try {
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _setLoginStatus(true, userCredential.user!.uid);

      Get.toNamed('/events');
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  Future<void> registerWithEmailAndPassword(
      String email, String password) async {
    try {
      final UserCredential userCredential =
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final String uid = userCredential.user!.uid;

      // Create a new UserModel instance
      final user = UserModel(
        uid: uid,
        fullName: "",
        email: email,
        createdAt: DateTime.now(),
      );

      // Save the user model to Firestore
      await _firestore.collection('users').doc(uid).set(user.toMap());

      await _setLoginStatus(true, user.uid);

      Get.toNamed('/updateUser');
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  Future<void> registerWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        final UserCredential userCredential =
        await _auth.signInWithCredential(credential);

        // Save user details to Firestore if it's the first login
        final user = userCredential.user;

        final String uid = userCredential.user!.uid;
        if (userCredential.additionalUserInfo?.isNewUser ?? false) {
          await addUserDetailsToFirestore(
            user!.uid,
            user.displayName ?? "Unknown",
            user.email ?? "No email",
          );
        }

        await _setLoginStatus(true, user!.uid);


        Get.toNamed('/updateUser');
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  Future<void> loginWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        final UserCredential userCredential =
        await _auth.signInWithCredential(credential);

        // Save user details to Firestore if it's the first login
        final user = userCredential.user;
        if (userCredential.additionalUserInfo?.isNewUser ?? false) {
          await addUserDetailsToFirestore(
            user!.uid,
            user.displayName ?? "Unknown",
            user.email ?? "No email",
          );
        }

        await _setLoginStatus(true, user!.uid);

        Get.toNamed('/events');

      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  Future<void> addUserDetailsToFirestore(
      String uid, String fullName, String email) async {
    try {
      await _firestore.collection('users').doc(uid).set({
        'uid': uid,
        'fullName': fullName,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      Get.snackbar("Error", "Failed to add user details: $e");
    }
  }

  Future<UserModel> getUserDetailsById(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();

      if (!doc.exists) {
        throw Exception("User not found");
      }

      // Parse Firestore document to UserModel
      return UserModel.fromFirestore(doc);
    } catch (e) {
      // Handle specific Firestore errors or rethrow for global error handling
      throw Exception("Failed to fetch user details: ${e.toString()}");
    }
  }

  Future<UserModel> getUserDetails() async {
    final userId = await getUserId();
    try {
      final doc = await _firestore.collection('users').doc(userId).get();

      if (!doc.exists) {
        throw Exception("User not found");
      }

      // Parse Firestore document to UserModel
      return UserModel.fromFirestore(doc);
    } catch (e) {
      // Handle specific Firestore errors or rethrow for global error handling
      throw Exception("Failed to fetch user details: ${e.toString()}");
    }
  }

  // Update user details in Firestore
  Future<void> updateUserDetail(String field, String value) async {
    final userId = await getUserId();
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .update({field: value});

    } catch (e) {
      print("Error updating $field: $e");

    }
  }

  Future<void> logout() async {
    try {
      await _setLoginStatus(false, "");
      await _auth.signOut();
      Get.offAllNamed('/signIn');
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }


  Future<String?> getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("uid");
  }

  Future<void> _setLoginStatus(bool status, String uid) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', status);
    await prefs.setString('uid', uid);
    isLoggedIn.value = status;
  }
}
