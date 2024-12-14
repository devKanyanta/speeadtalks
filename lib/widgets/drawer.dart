import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speedtalks/models/user_model.dart';
import 'package:speedtalks/services/auth_controller.dart';

class MyDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find(); // Access AuthController here

    return Drawer(
      child: FutureBuilder<UserModel>(
        future: authController.getUserDetails(), // Ensure the user details are fetched
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading user details'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text('No user data available'));
          }

          final UserModel userModel = snapshot.data!;
          return Container(
            width: double.maxFinite,
            padding: EdgeInsets.zero,
            height: double.maxFinite,
            child: Column(
              children: [
                SizedBox(
                  width: double.maxFinite,
                  child: DrawerHeader(
                    decoration: const BoxDecoration(color: Colors.blue),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SpeedTalks',
                          style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20),
                        ),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  userModel.fullName,
                                style: GoogleFonts.poppins(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                ListTile(
                  title: Text(
                    'Events',
                    style: GoogleFonts.poppins(color: Colors.black),
                  ),
                  onTap: () {
                    Get.toNamed('/events');
                  },
                ),
                ListTile(
                  title: Text('Registered Events'),
                  onTap: () {
                    Get.toNamed('/registeredEvents');
                  },
                ),
                ListTile(
                  title: Text('Messages'),
                  onTap: () {
                    Get.toNamed('/chatRoom', arguments: userModel.uid);
                  },
                ),
                ListTile(
                  title: Text('Profile'),
                  onTap: () {
                    Get.toNamed('/profile');
                  },
                ),
                ListTile(
                  title: Text('Add Event'),
                  onTap: () {
                    Get.toNamed('/addEvent');
                  },
                ),
                const Spacer(),
                ListTile(
                  title: Text('Logout'),
                  onTap: () async {
                    if (authController != null) {
                      await authController.logout();
                    } else {
                      print('Null controller');
                    }
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
