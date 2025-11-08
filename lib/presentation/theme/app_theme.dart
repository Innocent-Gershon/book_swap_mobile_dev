import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme => ThemeData(
    brightness: Brightness.light,
    primarySwatch: MaterialColor(0xFF1976D2, {
      50: AppColors.primary.withOpacity(0.1),
      100: AppColors.primary.withOpacity(0.2),
      200: AppColors.primary.withOpacity(0.3),
      300: AppColors.primary.withOpacity(0.4),
      400: AppColors.primary.withOpacity(0.5),
      500: AppColors.primary,
      600: AppColors.primary.withOpacity(0.7),
      700: AppColors.primary.withOpacity(0.8),
      800: AppColors.primary.withOpacity(0.9),
      900: AppColors.primaryDark,
    }),
    scaffoldBackgroundColor: AppColors.background,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.textLight,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      color: AppColors.surface,
      elevation: 2,
      shadowColor: AppColors.shadowColor,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textLight,
      ),
    ),
  );

  static ThemeData get darkTheme => ThemeData(
    brightness: Brightness.dark,
    primarySwatch: MaterialColor(0xFF90CAF9, {
      50: AppColors.darkPrimary.withOpacity(0.1),
      100: AppColors.darkPrimary.withOpacity(0.2),
      200: AppColors.darkPrimary.withOpacity(0.3),
      300: AppColors.darkPrimary.withOpacity(0.4),
      400: AppColors.darkPrimary.withOpacity(0.5),
      500: AppColors.darkPrimary,
      600: AppColors.darkPrimary.withOpacity(0.7),
      700: AppColors.darkPrimary.withOpacity(0.8),
      800: AppColors.darkPrimary.withOpacity(0.9),
      900: AppColors.primary,
    }),
    scaffoldBackgroundColor: AppColors.darkBackground,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.darkSurface,
      foregroundColor: AppColors.darkTextPrimary,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      color: AppColors.darkSurface,
      elevation: 2,
      shadowColor: AppColors.darkShadow,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.darkPrimary,
        foregroundColor: AppColors.darkBackground,
      ),
    ),
  );
}
