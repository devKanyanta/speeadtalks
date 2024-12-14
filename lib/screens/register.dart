import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speedtalks/screens/update_user_details.dart';
import 'package:speedtalks/widgets/drawer.dart';
import '../services/auth_controller.dart';
import '../widgets/button_social.dart';
import '../widgets/email.dart';
import '../widgets/password.dart';
import '../widgets/sign_button.dart';

class Registration extends StatefulWidget {
  const Registration({super.key});

  @override
  State<Registration> createState() => _RegistrationState();
}

class _RegistrationState extends State<Registration> {
  final AuthController authController = Get.put(AuthController());
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? userId;

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
                const SizedBox(height: 20),
                PasswordField(controller: confirmPasswordController),
                const SizedBox(height: 20),
                CustomButton(
                  label: 'Sign Up',
                  onPressed: () async{
                    // Handle sign-in logic here
                    final email = emailController.text;
                    final password = passwordController.text;
                    final confirmPassword = confirmPasswordController.text;
                    if(_formKey.currentState!.validate()){
                      if(password != confirmPassword){
                        Get.snackbar("Passwords do not match", 'Make sure the passwords match.');
                      }else{
                        await authController.registerWithEmailAndPassword(
                            email,
                            password
                        );
                      }
                    }
                  },
                ),
                const SizedBox(height: 20),
                Center(
                  child: Text(
                    'Or sign up with',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      ButtonSocial(
                        icon: Icons.g_mobiledata,
                        label: 'Continue with Google',
                        onPressed: () async {
                          await authController.registerWithGoogle();
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
