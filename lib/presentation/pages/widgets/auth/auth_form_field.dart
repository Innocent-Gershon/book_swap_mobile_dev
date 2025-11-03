// lib/presentation/widgets/auth/auth_form_field.dart
import 'package:book_swap/presentation/theme/app_styles.dart';
import 'package:flutter/material.dart';

class AuthFormField extends StatelessWidget {
  const AuthFormField({
    super.key,
    required this.controller,
    required this.labelText,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.suffixIcon,
  });

  final TextEditingController controller;
  final String labelText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      style: AppStyles.bodyText1, // Apply our body text style
      decoration: InputDecoration(
        labelText: labelText,
        suffixIcon: suffixIcon,
        // The rest of the InputDecoration styling is handled by AppTheme
      ),
    );
  }
}