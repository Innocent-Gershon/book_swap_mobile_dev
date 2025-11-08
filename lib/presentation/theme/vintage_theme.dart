import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class VintageTheme {
  // Vintage Color Palette
  static const Color parchment = Color(0xFFF4F1E8);
  static const Color antiqueBrown = Color(0xFF8B4513);
  static const Color darkBrown = Color(0xFF654321);
  static const Color goldAccent = Color(0xFFD4AF37);
  static const Color burgundy = Color(0xFF800020);
  static const Color cream = Color(0xFFFFFDD0);
  static const Color sepia = Color(0xFF704214);
  static const Color oldPaper = Color(0xFFF7F3E9);
  static const Color inkBlue = Color(0xFF2F4F4F);

  static ThemeData get theme => ThemeData(
    primarySwatch: MaterialColor(0xFF8B4513, {
      50: antiqueBrown.withOpacity(0.1),
      100: antiqueBrown.withOpacity(0.2),
      200: antiqueBrown.withOpacity(0.3),
      300: antiqueBrown.withOpacity(0.4),
      400: antiqueBrown.withOpacity(0.5),
      500: antiqueBrown,
      600: antiqueBrown.withOpacity(0.7),
      700: antiqueBrown.withOpacity(0.8),
      800: antiqueBrown.withOpacity(0.9),
      900: darkBrown,
    }),
    scaffoldBackgroundColor: parchment,
    fontFamily: GoogleFonts.crimsonText().fontFamily,
    textTheme: TextTheme(
      displayLarge: GoogleFonts.playfairDisplay(
        fontSize: 36,
        fontWeight: FontWeight.bold,
        color: darkBrown,
      ),
      displayMedium: GoogleFonts.playfairDisplay(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        color: darkBrown,
      ),
      headlineLarge: GoogleFonts.playfairDisplay(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: antiqueBrown,
      ),
      headlineMedium: GoogleFonts.crimsonText(
        fontSize: 24,
        fontWeight: FontWeight.w500,
        color: darkBrown,
      ),
      titleLarge: GoogleFonts.playfairDisplay(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: darkBrown,
      ),
      titleMedium: GoogleFonts.crimsonText(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        color: darkBrown,
      ),
      titleSmall: GoogleFonts.crimsonText(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: sepia,
      ),
      bodyLarge: GoogleFonts.crimsonText(
        fontSize: 18,
        color: sepia,
      ),
      bodyMedium: GoogleFonts.crimsonText(
        fontSize: 16,
        color: sepia,
      ),
      bodySmall: GoogleFonts.crimsonText(
        fontSize: 14,
        color: sepia,
      ),
      labelLarge: GoogleFonts.crimsonText(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: darkBrown,
      ),
      labelMedium: GoogleFonts.crimsonText(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: sepia,
      ),
      labelSmall: GoogleFonts.crimsonText(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: sepia,
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: antiqueBrown,
      foregroundColor: cream,
      elevation: 0,
      titleTextStyle: GoogleFonts.playfairDisplay(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: cream,
      ),
    ),
    cardTheme: CardThemeData(
      color: oldPaper,
      elevation: 8,
      shadowColor: antiqueBrown.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: antiqueBrown.withValues(alpha: 0.2), width: 1),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: antiqueBrown,
        foregroundColor: cream,
        elevation: 4,
        shadowColor: darkBrown.withOpacity(0.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: GoogleFonts.crimsonText(
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
  );

  static BoxDecoration get vintageCardDecoration => BoxDecoration(
    color: oldPaper,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: antiqueBrown.withOpacity(0.3), width: 1),
    boxShadow: [
      BoxShadow(
        color: antiqueBrown.withOpacity(0.2),
        blurRadius: 8,
        offset: const Offset(2, 4),
      ),
    ],
  );

  static BoxDecoration get ornateDecoration => BoxDecoration(
    color: cream,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: goldAccent, width: 2),
    boxShadow: [
      BoxShadow(
        color: antiqueBrown.withOpacity(0.3),
        blurRadius: 12,
        offset: const Offset(0, 6),
      ),
    ],
  );
}
