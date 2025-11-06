import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:book_swap/presentation/pages/widgets/theme/app_colors.dart';
import 'package:book_swap/services/auth_service.dart';

class AuthDialogs {
  static void showNoAccountDialog(BuildContext context) {
    _showBlurDialog(
      context,
      title: 'No Account Found',
      message: 'We couldn\'t find an account with this email. Would you like to create one?',
      icon: Icons.person_add_outlined,
      iconColor: AppColors.primary,
      primaryText: 'Create Account',
      secondaryText: 'Cancel',
      onPrimary: () {
        Navigator.pop(context);
        context.go('/signup');
      },
      onSecondary: () => Navigator.pop(context),
    );
  }

  static void showWrongPasswordDialog(BuildContext context) {
    _showBlurDialog(
      context,
      title: 'Incorrect Password',
      message: 'The password is incorrect. Try again or reset your password.',
      icon: Icons.lock_outline,
      iconColor: AppColors.error,
      primaryText: 'Try Again',
      secondaryText: 'Reset Password',
      onPrimary: () => Navigator.pop(context),
      onSecondary: () {
        Navigator.pop(context);
        _showForgotPasswordDialog(context);
      },
    );
  }

  static void showEmailNotVerifiedDialog(BuildContext context) {
    _showBlurDialog(
      context,
      title: 'Email Not Verified',
      message: 'Please verify your email before signing in. Check your inbox for the verification link.',
      icon: Icons.email_outlined,
      iconColor: AppColors.warning,
      primaryText: 'Resend Email',
      secondaryText: 'Cancel',
      onPrimary: () async {
        Navigator.pop(context);
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await user.sendEmailVerification();
          if (context.mounted) {
            _showSnackBar(context, 'Verification email sent!', true);
          }
        }
      },
      onSecondary: () => Navigator.pop(context),
    );
  }

  static void showSuccessDialog(BuildContext context, String message, {VoidCallback? onOk}) {
    _showBlurDialog(
      context,
      title: 'Success!',
      message: message,
      icon: Icons.check_circle_outline,
      iconColor: AppColors.success,
      primaryText: 'OK',
      onPrimary: () {
        Navigator.pop(context);
        onOk?.call();
      },
    );
  }

  static void showErrorDialog(BuildContext context, String message) {
    _showBlurDialog(
      context,
      title: 'Error',
      message: message,
      icon: Icons.error_outline,
      iconColor: AppColors.error,
      primaryText: 'OK',
      onPrimary: () => Navigator.pop(context),
    );
  }

  static void _showForgotPasswordDialog(BuildContext context) {
    final emailController = TextEditingController();
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Stack(
        children: [
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(color: Colors.black.withValues(alpha: 0.3)),
          ),
          Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.lock_reset, size: 40, color: AppColors.primary),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Reset Password',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Enter your email to receive a password reset link.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: 'Email address',
                      prefixIcon: const Icon(Icons.email_outlined),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            if (emailController.text.isNotEmpty) {
                              Navigator.pop(context);
                              final result = await AuthService.resetPassword(emailController.text);
                              if (context.mounted) {
                                _showSnackBar(context, result.message, result.isSuccess);
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                          child: const Text('Send Link', style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static void _showBlurDialog(
    BuildContext context, {
    required String title,
    required String message,
    required IconData icon,
    required Color iconColor,
    required String primaryText,
    String? secondaryText,
    required VoidCallback onPrimary,
    VoidCallback? onSecondary,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Stack(
        children: [
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(color: Colors.black.withValues(alpha: 0.3)),
          ),
          Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: iconColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, size: 40, color: iconColor),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    title,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    message,
                    style: const TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      if (secondaryText != null) ...[
                        Expanded(
                          child: OutlinedButton(
                            onPressed: onSecondary,
                            child: Text(secondaryText),
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      Expanded(
                        child: ElevatedButton(
                          onPressed: onPrimary,
                          style: ElevatedButton.styleFrom(backgroundColor: iconColor),
                          child: Text(primaryText, style: const TextStyle(color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static void _showSnackBar(BuildContext context, String message, bool isSuccess) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? AppColors.success : AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
