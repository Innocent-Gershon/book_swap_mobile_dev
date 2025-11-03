// lib/presentation/theme/app_styles.dart
import 'package:book_swap/presentation/pages/widgets/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppStyles {
  // Headings
  static TextStyle get headline1 => GoogleFonts.poppins(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.textDark,
  );
  
  static TextStyle get headline2 => GoogleFonts.poppins(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textDark,
  );
  
  static TextStyle get headline3 => GoogleFonts.poppins(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.textDark,
  );

  // Body text
  static TextStyle get bodyText1 => GoogleFonts.poppins(
    fontSize: 16,
    color: AppColors.textDark,
  );
  
  static TextStyle get bodyText2 => GoogleFonts.poppins(
    fontSize: 14,
    color: AppColors.textDark,
  );
  
  static TextStyle get bodyTextSmall => GoogleFonts.poppins(
    fontSize: 12,
    color: AppColors.textDark,
  );

  // Button text
  static TextStyle get buttonText => GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textLight,
  );

  // Hint text
  static TextStyle get hintText => GoogleFonts.poppins(
    fontSize: 14,
    color: AppColors.textDark.withValues(alpha: 0.6),
  );

  // Card titles
  static TextStyle get cardTitle => GoogleFonts.poppins(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textDark,
  );

  // Card subtitles
  static TextStyle get cardSubtitle => GoogleFonts.poppins(
    fontSize: 14,
    color: AppColors.textDark.withValues(alpha: 0.8),
  );

  // Condition tags
  static TextStyle get conditionTag => GoogleFonts.poppins(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textLight,
  );
}