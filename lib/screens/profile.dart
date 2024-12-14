import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speedtalks/services/auth_controller.dart';
import 'package:speedtalks/widgets/drawer.dart';

import '../models/user_model.dart';

class UserProfilePage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    AuthController authController = Get.find();
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profile',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
      ),
      drawer: MyDrawer(),
      body: FutureBuilder(
        future: authController.getUserDetails(),
        builder: (BuildContext context, AsyncSnapshot<UserModel> snapshot) {
          if(snapshot.data == null){
            return const Center(child: CircularProgressIndicator());
          }

          final user = snapshot.data;
          String profileUrl = user!.profilePictureUrl;

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Profile Picture
                  CircleAvatar(
                    radius: 60.0,
                    backgroundImage: NetworkImage(
                      profileUrl == '' ? "http://placebeard.it/250/250" : profileUrl,
                    ),
                  ),
                  SizedBox(height: 16.0),

                  // Full Name
                  Text(
                    user!.fullName,
                    style: GoogleFonts.poppins(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 8.0),

                  // Bio
                  Text(
                    user.bio,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 16.0,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 24.0),
                  // Profile Information Section
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          blurRadius: 6.0,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Email
                        ListTile(
                          leading: Icon(Icons.email, color: Colors.blueAccent),
                          title: Text(
                            'Email',
                            style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                          ),
                          subtitle: Text(
                            user.email,
                            style: GoogleFonts.poppins(),
                          ),
                        ),
                        Divider(),

                        // Phone
                        ListTile(
                          leading: Icon(Icons.phone, color: Colors.green),
                          title: Text(
                            'Phone',
                            style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                          ),
                          subtitle: Text(
                            user.phone,
                            style: GoogleFonts.poppins(),
                          ),
                        ),
                        Divider(),

                        // Address
                        // ListTile(
                        //   leading: Icon(Icons.star, color: Colors.redAccent),
                        //   title: Text(
                        //     'Interests',
                        //     style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                        //   ),
                        //   subtitle: ListView.builder(
                        //     itemCount: user.interests.length,
                        //     itemBuilder: (BuildContext context, int index) {
                        //       return Text(
                        //         user.interests[index],
                        //         style: GoogleFonts.poppins(),
                        //       );
                        //     },
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24.0),

                  // Action Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          Get.toNamed('/updateUser');
                        },
                        icon: Icon(
                            Icons.edit,
                          color: Colors.white,
                        ),
                        label: Text(
                          'Edit Profile',
                          style: GoogleFonts.poppins(
                            color: Colors.white
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          authController.logout();
                        },
                        icon: Icon(
                            Icons.logout,
                          color: Colors.white,
                        ),
                        label: Text(
                          'Log Out',
                          style: GoogleFonts.poppins(
                            color: Colors.white
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      )
    );
  }
}