import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speedtalks/models/args.dart';
import 'package:speedtalks/models/chat_args.dart';
import 'package:speedtalks/services/auth_controller.dart';
import 'package:speedtalks/services/event_controller.dart';
import '../models/user_model.dart';

class MatchingPage extends StatefulWidget {

  @override
  _MatchingPageState createState() => _MatchingPageState();
}

class _MatchingPageState extends State<MatchingPage> {
  late Future<List<UserModel>> usersFuture; // To store the future list of users
  final EventController eventController = Get.find();
  final AuthController authController = Get.find();
  final args = Get.arguments as Args1;
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Call the function to get users for the event when the page is initialized
    usersFuture = eventController.getUsersForEvent(args.eventType, args.eventDate);
  }

  void handleAccept(String name, List users, String receiverId) async {
    final userId = await authController.getUserId();
    // Perform an action when the user accepts the profile
    Get.snackbar("Accepted", "You accepted $name");
    Get.toNamed('/messages',arguments: ChatArgs(userId!, receiverId));
  }

  void handlePass(String name, List users) {
    // Perform an action when the user passes the profile
    Get.snackbar("Passed", "You passed on $name");
    _showNextProfile(users);
  }

  void _showNextProfile(List users) {
    setState(() {
      // Check if there are more users to display
      if (currentIndex < users.length - 1) {
        currentIndex++;
      } else {
        currentIndex = 0; // Reset to first profile if all are swiped
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Pre-Matching',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<List<UserModel>>(
        future: usersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final users = snapshot.data ?? [];

          if (users.isEmpty) {
            return Center(child: Text('No users registered for this event.'));
          }

          final profile = users[currentIndex];

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Profile Card
                Container(
                  padding: EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                    color: Colors.white,
                  ),
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16.0),
                        child: Image.network(
                          profile.profilePictureUrl == '' ? "http://placebeard.it/250/250" : profile.profilePictureUrl,
                          height: 150,
                          width: 150,
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(height: 16.0),
                      Text(
                        profile.fullName,
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8.0),
                      Text(
                        profile.bio,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 32.0),

                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Pass Button
                    ElevatedButton(
                      onPressed: (){
                        handlePass(profile.fullName, users);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.close, color: Colors.white),
                          SizedBox(width: 8.0),
                          Text(
                            'Pass',
                            style: GoogleFonts.poppins(fontSize: 16, color: Colors.white),
                          ),
                        ],
                      ),
                    ),

                    // Accept Button
                    ElevatedButton(
                      onPressed: (){
                        handleAccept(profile.fullName, users, profile.uid);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.favorite, color: Colors.white),
                          SizedBox(width: 8.0),
                          Text(
                            'Accept',
                            style: GoogleFonts.poppins(fontSize: 16, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 40,
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
