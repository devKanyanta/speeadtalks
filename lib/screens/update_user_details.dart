import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_loading_button/easy_loading_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:speedtalks/services/auth_controller.dart';
import '../models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UpdateUserDetailsPage extends StatefulWidget {
  @override
  _UpdateUserDetailsPageState createState() => _UpdateUserDetailsPageState();
}

class _UpdateUserDetailsPageState extends State<UpdateUserDetailsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthController authController = Get.find();

  UserModel? _user;
  bool _isLoading = true;
  bool _isUpdateComplete = false;

  // Controllers for user input
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  // Track which cards have been updated
  bool _isNameUpdated = false;
  bool _isBioUpdated = false;
  bool _isPhoneUpdated = false;
  bool _isProfilePictureUpdated = false;

  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _loadUserDetails();
  }

  Future<void> _loadUserDetails() async {
    final userId = await authController.getUserId();
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        setState(() {
          _user = UserModel.fromFirestore(doc);
          _nameController.text = _user?.fullName ?? '';
          _bioController.text = _user?.bio ?? '';
          _phoneController.text = _user?.phone ?? '';
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error loading user details: $e");
    }
  }

  Future<void> _updateDetail(String field, String value) async {
    await authController.updateUserDetail(field, value);

    setState(() {
      switch (field) {
        case 'fullName':
          _isNameUpdated = true;
          break;
        case 'bio':
          _isBioUpdated = true;
          break;
        case 'phone':
          _isPhoneUpdated = true;
          break;
      }
    });

    // Check if all updates are complete
    if (_isNameUpdated && _isBioUpdated && _isPhoneUpdated && _isProfilePictureUpdated) {
      Future.delayed(Duration(seconds: 1), () {
        setState(() {
          _isUpdateComplete = true;
        });
      });
    }
  }


  Future<void> _pickAndUploadImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final file = File(image.path);

      try {
        // Await the user ID resolution
        final userId = await authController.getUserId();
        if (userId == null) {
          throw Exception("User ID not found");
        }

        // Reference to the user's document in Firestore
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();

        if (!userDoc.exists) {
          throw Exception("User not found in Firestore");
        }

        // Check if a profile picture already exists
        String? existingProfilePictureUrl = userDoc.data()?['profilePictureUrl'];

        if (existingProfilePictureUrl != null) {
          print('Existing Profile Picture URL: $existingProfilePictureUrl');
          final existingFileName = existingProfilePictureUrl.split('/').last;

          // Attempt to delete the old profile picture
          try {
            final response = await Supabase.instance.client.storage
                .from('profilePictures')
                .remove(['public/$existingFileName']);

            if (response.isEmpty) {
              print("No files matched the specified name, skipping deletion.");
            } else {
              print("Old profile picture deleted successfully.");
            }
          } catch (e) {
            print("Error deleting old profile picture: $e");
          }
        }

        // Generate a unique file name for the new upload
        final fileName = '$userId-${DateTime.now().millisecondsSinceEpoch}.jpg';

        // Upload the new profile picture
        final storageResponse = await Supabase.instance.client.storage
            .from('profilePictures')
            .upload('public/$fileName', file);

        // Get the public URL for the uploaded file
        final publicUrl = Supabase.instance.client.storage
            .from('profilePictures')
            .getPublicUrl('public/$fileName');

        print('Public URL: $publicUrl');

        // Save the new profile picture URL to Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .update({'profilePictureUrl': publicUrl});

        // Update state
        setState(() {
          _isProfilePictureUpdated = true;
          _isUpdateComplete = true;
        });

        Get.snackbar("Success", "Profile picture uploaded successfully.");
      } catch (e) {
        print("Error uploading file: $e");
        Get.snackbar("Error", "Failed to upload profile picture.");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Update Details',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Center(
        child: Padding(
          padding: EdgeInsets.all(15.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Name card only shows if not updated
              if (!_isNameUpdated) ...[
                _buildUpdateCard(
                  title: 'UPDATE NAME',
                  controller: _nameController,
                  field: 'fullName',
                  hintText: 'Enter your full name',
                ),
              ],

              // Bio card only shows when name is updated
              if (_isNameUpdated && !_isBioUpdated) ...[
                _buildUpdateCard(
                  title: 'UPDATE BIO',
                  controller: _bioController,
                  field: 'bio',
                  hintText: 'Enter your bio',
                ),
              ],

              // Phone card only shows when bio is updated
              if (_isNameUpdated && _isBioUpdated && !_isPhoneUpdated) ...[
                _buildUpdateCard(
                  title: 'UPDATE PHONE',
                  controller: _phoneController,
                  field: 'phone',
                  hintText: 'Enter your phone number',
                ),
              ],

              // Profile Picture card shows when phone is updated
              if (_isNameUpdated && _isBioUpdated && _isPhoneUpdated && !_isProfilePictureUpdated) ...[
                _buildProfilePictureCard(),
              ],

              // Update complete card shows only when all updates are done
              if (_isUpdateComplete) ...[
                _buildUpdateCompleteCard(),
              ]
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfilePictureCard() {
    return AnimatedSwitcher(
      duration: Duration(milliseconds: 500),
      child: Card(
        key: ValueKey<String>('profilePicture'),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: EdgeInsets.all(26),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'UPDATE PROFILE PICTURE',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              if (_selectedImage != null)
                Image.file(
                  _selectedImage!,
                  height: 100,
                  width: 100,
                  fit: BoxFit.cover,
                ),
              SizedBox(height: 8),
              EasyButton(
                onPressed: _pickAndUploadImage,
                idleStateWidget: Text(
                  'Upload',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 16
                  ),
                ),
                useWidthAnimation: true,
                useEqualLoadingStateWidgetDimension: true,
                width: double.maxFinite,
                height: 40.0,
                contentGap: 6.0,
                borderRadius: 5.0,
                loadingStateWidget: const CircularProgressIndicator(
                  strokeWidth: 3.0,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUpdateCard({
    required String title,
    required TextEditingController controller,
    required String field,
    required String hintText,
  }) {
    return AnimatedSwitcher(
      duration: Duration(milliseconds: 500),
      child: Card(
        key: ValueKey<String>(field),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: EdgeInsets.all(26),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: controller,
                style: GoogleFonts.poppins(
                  fontSize: 16
                ),
                decoration: InputDecoration(
                  hintText: hintText,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 16),
              Align(
                alignment: Alignment.center,
                child: EasyButton(
                  onPressed: () async {
                    if (controller.text.isNotEmpty) {
                      await _updateDetail(field, controller.text);
                    } else {
                      Get.snackbar("Error", "Input cannot be empty");
                    }
                  },
                  idleStateWidget: Text(
                    'Update',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 16
                    ),
                  ),
                  useWidthAnimation: true,
                  useEqualLoadingStateWidgetDimension: true,
                  width: double.maxFinite,
                  height: 40.0,
                  contentGap: 6.0,
                  borderRadius: 5.0,
                  loadingStateWidget: const CircularProgressIndicator(
                    strokeWidth: 3.0,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUpdateCompleteCard() {
    return Card(
      key: ValueKey<int>(-1),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'UPDATE COMPLETE',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            EasyButton(
              onPressed: () {
                Get.toNamed('/events');
              },
              idleStateWidget: Text(
                'Proceed',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 16
                ),
              ),
              useWidthAnimation: true,
              useEqualLoadingStateWidgetDimension: true,
              width: double.maxFinite,
              height: 40.0,
              contentGap: 6.0,
              borderRadius: 5.0,
              loadingStateWidget: const CircularProgressIndicator(
                strokeWidth: 3.0,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}