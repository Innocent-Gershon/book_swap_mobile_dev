// presentation/pages/sign_in_page.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:book_swap/services/auth_service.dart';
import 'package:book_swap/widgets/auth_dialogs.dart';
import 'package:book_swap/presentation/pages/widgets/theme/app_colors.dart';
import 'package:book_swap/presentation/pages/widgets/theme/app_styles.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  late AnimationController _glowController;
  late Animation<Color?> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);
    _glowAnimation = ColorTween(
      begin: AppColors.accent.withValues(alpha: 0.6),
      end: AppColors.primary.withValues(alpha: 0.9),
    ).animate(_glowController);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final result = await AuthService.signIn(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (result.isSuccess) {
      context.go('/browse'); // Navigate to the main app screen after successful sign-in
    } else {
      // Use the new AuthResultType for better error handling and specific dialogs
      switch (result.type) {
        case AuthResultType.emailNotVerified:
          AuthDialogs.showEmailNotVerifiedDialog(context);
          break;
        case AuthResultType.userNotFound:
          // Creative dialog prompting user to sign up if account not found
          AuthDialogs.showNoAccountDialog(context);
          break;
        case AuthResultType.wrongPassword:
          // Creative dialog for incorrect password
          AuthDialogs.showWrongPasswordDialog(context);
          break;
        case AuthResultType.invalidEmail:
          AuthDialogs.showErrorDialog(context, 'The email address is not valid. Please check and try again.');
          break;
        case AuthResultType.error: // Generic error, show the message from AuthService
        default:
          AuthDialogs.showErrorDialog(context, result.message);
      }
    }
  }

  void _showForgotPasswordDialog(BuildContext context) {
    final emailController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Reset Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter your email address and we\'ll send you a link to reset your password.'),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                hintText: 'Email address',
                prefixIcon: Icon(Icons.email_outlined),
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (emailController.text.isNotEmpty) {
                Navigator.pop(context); // Dismiss the input dialog
                final result = await AuthService.resetPassword(emailController.text);
                if (context.mounted) {
                  // Show a SnackBar to indicate if the reset link was sent
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(result.message),
                      backgroundColor: result.isSuccess ? AppColors.success : AppColors.error,
                    ),
                  );
                }
              }
            },
            child: const Text('Send Reset Link'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E2038),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.go('/welcome'),
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              children: [
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.menu_book_rounded, color: Color(0xFF1E2038), size: 60),
                ),
                const SizedBox(height: 16),
                Text(
                  'Welcome Back',
                  style: AppStyles.headline1.copyWith(fontSize: 28, color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  'Sign in to continue your book journey',
                  style: TextStyle(color: Colors.grey[300], fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Email',
                          hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.1),
                          prefixIcon: const Icon(Icons.email_outlined, color: Colors.white),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Please enter your email';
                          if (!value.contains('@') || !value.contains('.')) return 'Enter a valid email';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Password',
                          hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.1),
                          prefixIcon: const Icon(Icons.lock_outline, color: Colors.white),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off : Icons.visibility,
                              color: Colors.white.withValues(alpha: 0.7),
                            ),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Please enter your password';
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => _showForgotPasswordDialog(context),
                          child: const Text(
                            'Forgot Password?',
                            style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: AnimatedBuilder(
                          animation: _glowController,
                          builder: (context, child) => ElevatedButton(
                            onPressed: _isLoading ? null : _signIn,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _glowAnimation.value,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: _isLoading
                                ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                                : const Text(
                                    'Sign In',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: () => context.go('/signup'),
                        child: const Text(
                          "Don't have an account? Sign up!",
                          style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}