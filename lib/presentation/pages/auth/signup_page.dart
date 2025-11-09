// presentation/pages/sign_up_page.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

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

    if (result.isSuccess && result.user != null) {
      // Show email verification dialog immediately - it will handle navigation
      if (mounted) {
        _showEmailVerificationDialog(result.user!);
      }
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

  Future<void> _showEmailVerificationDialog(User user) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      useRootNavigator: false,
      builder: (dialogContext) => _EmailVerificationDialog(user: user),
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
                          if (value == null || value.isEmpty) return 'Please enter a password';
                          if (value.length < 6) return 'Password must be at least 6 characters';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirmPassword,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Confirm Password',
                          hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.1),
                          prefixIcon: const Icon(Icons.lock_outline, color: Colors.white),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                              color: Colors.white.withValues(alpha: 0.7),
                            ),
                            onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                          ),
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


class _EmailVerificationDialog extends StatefulWidget {
  final User user;
  const _EmailVerificationDialog({required this.user});

  @override
  State<_EmailVerificationDialog> createState() => _EmailVerificationDialogState();
}

class _EmailVerificationDialogState extends State<_EmailVerificationDialog> {
  bool _isChecking = false;

  @override
  void initState() {
    super.initState();
    _startVerificationCheck();
  }

  void _startVerificationCheck() async {
    while (mounted) {
      await Future.delayed(const Duration(seconds: 3));
      try {
        await FirebaseAuth.instance.currentUser?.reload();
        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser != null && currentUser.emailVerified && mounted) {
          Navigator.of(context).pop();
          if (mounted) {
            context.go('/browse');
          }
          return;
        }
      } catch (e) {
        // Continue checking even if reload fails
      }
    }
  }

  Future<void> _resendEmail() async {
    setState(() => _isChecking = true);
    try {
      await widget.user.sendEmailVerification();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Verification email sent!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send email: $e')),
        );
      }
    }
    setState(() => _isChecking = false);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [AppColors.accent, AppColors.accent.withValues(alpha: 0.8)]),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.email_outlined, size: 48, color: Color(0xFF1E2038)),
            ),
            const SizedBox(height: 20),
            const Text(
              'Verify Your Email',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Color(0xFF1A1B3A)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'We sent a verification link to\n${widget.user.email}',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Please check your inbox and click the link to continue.',
              style: TextStyle(fontSize: 13, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(color: AppColors.primary, strokeWidth: 3),
            const SizedBox(height: 12),
            Text(
              'Waiting for verification...',
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
            const SizedBox(height: 24),
            TextButton.icon(
              onPressed: _isChecking ? null : _resendEmail,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Resend Email'),
              style: TextButton.styleFrom(foregroundColor: AppColors.primary),
            ),
          ],
        ),
      ),
      ),
    );
  }
}
