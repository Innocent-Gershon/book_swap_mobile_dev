// lib/presentation/widgets/common/custom_button.dart
import 'package:book_swap/presentation/theme/app_styles.dart';
import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
  });

  final String text;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity, // Make button take full width
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor, // Uses theme primary if null
          foregroundColor: foregroundColor, // Uses theme onPrimary if null
        ),
        child: Text(
          text,
          style: AppStyles.buttonText, // Use our button text style
        ),
      ),
    );
  }
}