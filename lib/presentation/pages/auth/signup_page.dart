// presentation/pages/sign_up_page.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:book_swap/services/auth_service.dart';
import 'package:book_swap/widgets/auth_dialogs.dart';
import 'package:book_swap/presentation/pages/widgets/theme/app_colors.dart';
import 'package:book_swap/presentation/pages/widgets/theme/app_styles.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

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
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    // Additional check for password mismatch before calling AuthService
    if (_passwordController.text != _confirmPasswordController.text) {
      if (mounted) {
        AuthDialogs.showErrorDialog(context, 'Passwords do not match. Please ensure both password fields are identical.');
      }
      return;
    }

    setState(() => _isLoading = true);

    final result = await AuthService.signUp(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (result.isSuccess) {
      // Show success dialog and then navigate to sign-in page, prompting email verification
      AuthDialogs.showSuccessDialog(
        context,
        result.message, // This message comes from AuthService: "Account created! Please verify your email to log in."
        onOk: () => context.go('/signin'),
      );
    } else {
      // Handle specific error types from AuthService for better user feedback
      switch (result.type) {
        case AuthResultType.weakPassword:
          AuthDialogs.showErrorDialog(context, 'Your password is too weak. Please choose a stronger one with at least 6 characters.');
          break;
        case AuthResultType.emailAlreadyInUse:
          AuthDialogs.showErrorDialog(context, 'This email is already registered. Try signing in or use a different email address.');
          break;
        case AuthResultType.invalidEmail:
          AuthDialogs.showErrorDialog(context, 'The email address is not valid. Please check its format and try again.');
          break;
        case AuthResultType.error: // Generic error, show the message from AuthService
        default:
          AuthDialogs.showErrorDialog(context, result.message);
      }
    }
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
                  'Join BookSwap',
                  style: AppStyles.headline1.copyWith(fontSize: 28, color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  'Create your account to start swapping books',
                  style: TextStyle(color: Colors.grey[300], fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Full Name',
                          hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.1),
                          prefixIcon: const Icon(Icons.person_outline, color: Colors.white),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Please enter your name';
                          if (value.length < 2) return 'Name must be at least 2 characters';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
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
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                            return 'Enter a valid email address';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Password',
                          hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.1),
                          prefixIcon: const Icon(Icons.lock_outline, color: Colors.white),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Please enter a password';
                          if (value.length < 6) return 'Password must be at least 6 characters';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: true,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Confirm Password',
                          hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.1),
                          prefixIcon: const Icon(Icons.lock_outline, color: Colors.white),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Please confirm your password';
                          if (value != _passwordController.text) return 'Passwords do not match';
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: AnimatedBuilder(
                          animation: _glowController,
                          builder: (context, child) => ElevatedButton(
                            onPressed: _isLoading ? null : _signUp,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _glowAnimation.value,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: _isLoading
                                ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                                : const Text(
                                    'Create Account',
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
                        onTap: () => context.go('/signin'),
                        child: const Text(
                          "Already have an account? Sign in!",
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