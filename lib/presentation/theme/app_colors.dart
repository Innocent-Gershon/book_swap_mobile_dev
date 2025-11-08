import 'package:flutter/material.dart';

class AppColors {
  // Light theme colors - Matching Welcome Screen
  static const Color primary = Color(0xFF1976D2); // Blue
  static const Color primaryDark = Color(0xFF1565C0);
  static const Color primaryLight = Color(0xFF42A5F5);
  static const Color accent = Color(0xFFFFA726); // Orange
  static const Color accentDark = Color(0xFFF57C00);
  static const Color accentLight = Color(0xFFFFB74D);

  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Colors.white;
  static const Color error = Color(0xFFD32F2F);
  static const Color success = Color(0xFF388E3C);
  static const Color warning = Color(0xFFF59E0B);

  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFF9E9E9E);
  static const Color divider = Color(0xFFBDBDBD);

  static const Color cardBackground = Colors.white;
  static const Color shadowColor = Colors.black12;
  static const Color overlayLight = Colors.white70;
  static const Color overlayDark = Colors.black54;

  // Dark theme colors
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkPrimary = Color(0xFF90CAF9);
  static const Color darkAccent = Color(0xFFFFCC02);
  static const Color darkTextPrimary = Color(0xFFE0E0E0);
  static const Color darkTextSecondary = Color(0xFFB0B0B0);
  static const Color darkDivider = Color(0xFF424242);
  static const Color darkShadow = Colors.black26;

  // Aliases for compatibility
  static const Color textDark = textPrimary;
  static const Color textLight = Colors.white;
  static const Color card = cardBackground;
  static const Color border = divider;
}
