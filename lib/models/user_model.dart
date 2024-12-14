import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String fullName;
  final String email;
  final DateTime? createdAt;
  final String bio;
  final String phone;
  final String profilePictureUrl;
  final List<String> interests;

  UserModel({
    required this.uid,
    required this.fullName,
    required this.email,
    this.createdAt,
    this.bio = '',
    this.phone = '',
    this.profilePictureUrl = '',
    this.interests = const [],
  });

  // Factory method to create a UserModel from Firestore document data
  factory UserModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc,
      ) {
    final data = doc.data()!;
    return UserModel(
      uid: doc.id,
      fullName: data['fullName'] ?? '',
      email: data['email'] ?? '',
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
      bio: data['bio'] ?? '',
      phone: data['phone'] ?? '',
      profilePictureUrl: data['profilePictureUrl'] ?? '',
      interests: data['interests'] != null
          ? List<String>.from(data['interests'])
          : [],
    );
  }

  // Converts the UserModel to a map for Firestore storage
  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'email': email,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'bio': bio,
      'phone': phone,
      'profilePictureUrl': profilePictureUrl,
      'interests': interests,
    };
  }
}
