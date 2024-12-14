import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speedtalks/widgets/button_social.dart';
import '../services/auth_controller.dart';
import '../widgets/email.dart';
import '../widgets/password.dart';
import '../widgets/sign_button.dart';

class LogIn extends StatefulWidget {
  const LogIn({super.key});

  @override
  State<LogIn> createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  final AuthController authController = Get.put(AuthController());
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Let’s get started by filling out the form below.",
                  style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 30),
                EmailField(controller: emailController),
                const SizedBox(height: 20),
                PasswordField(controller: passwordController),
                const SizedBox(height: 40),
                CustomButton(
                  label: 'Sign In',
                  onPressed: () {
                    // Handle sign-in logic here
                    final email = emailController.text;
                    final password = passwordController.text;
                    print('Email: $email, Password: $password');
                    if(_formKey.currentState!.validate()){
                      authController.loginWithEmailAndPassword(
                        email,
                        password,
                      );
                    }
                  },
                ),
                const SizedBox(height: 25),
                Center(
                  child: Text(
                    'Forgot Password',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.blueAccent,
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                Center(
                  child: Text(
                    'Or sign in with',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                Align(
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      ButtonSocial(
                        icon: Icons.g_mobiledata,
                        label: 'Continue with Google',
                        onPressed: () async {
                          await authController.loginWithGoogle();
                        },
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      ButtonSocial(
                        icon: Icons.apple,
                        label: 'Continue with Apple',
                        onPressed: () {

                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
