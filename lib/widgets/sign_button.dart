import 'package:easy_loading_button/easy_loading_button.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const CustomButton({Key? key, required this.label, required this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: EasyButton(
        onPressed: onPressed,
        useWidthAnimation: true,
        useEqualLoadingStateWidgetDimension: true,
        width: double.maxFinite,
        height: 55.0,
        contentGap: 6.0,
        borderRadius: 5.0,
        loadingStateWidget: const CircularProgressIndicator(
          strokeWidth: 3.0,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
        idleStateWidget: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5.0),
          child: Text(
            label,
            style: GoogleFonts.poppins(fontSize: 16, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
