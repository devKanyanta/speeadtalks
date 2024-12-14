import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speedtalks/screens/log_in.dart';
import 'package:speedtalks/screens/register.dart';

class SignInSignUpPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0, // Removes shadow under the AppBar
          title: Text(
            'SpeedTalks',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          bottom: TabBar(
            labelColor: Colors.blueAccent, // Color for the active tab
            unselectedLabelColor: Colors.grey, // Color for inactive tabs
            labelStyle: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            unselectedLabelStyle: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.normal,
            ),
            indicatorColor: Colors.blueAccent, // Underline color for active tab
            indicatorWeight: 3.0, // Thickness of the underline
            tabs: [
              Tab(
                text: 'Sign In',
              ),
              Tab(
                text: 'Sign Up',
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            LogIn(), // Independent Sign In Page
            Registration(), // Independent Sign Up Page
          ],
        ),
      ),
    );
  }
}
