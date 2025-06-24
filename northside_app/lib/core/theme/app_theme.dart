// lib/core/theme/app_theme.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import '../utils/app_colors.dart';

class AppTheme {
  // This is the single source of truth for all our theme data
  static ThemeData get lightTheme {
    final ThemeData base = ThemeData.light();

    return base.copyWith(
      // --- COLOR SCHEME ---
      // This defines the app's primary color palette
      colorScheme: base.colorScheme.copyWith(
        primary: AppColors.primaryBlue,
        secondary: Colors.amber, // Example secondary color
        surface: const Color(0xFFF2F2F7), // Main background color
        onSurface: Colors.black, // Text on background
        background: const Color(0xFFF2F2F7),
      ),

      // --- TEXT THEME ---
      // This defines all the font styles for the app.
      // We use GoogleFonts to apply "Inter" and Sizer for responsive font sizes.
      textTheme: GoogleFonts.interTextTheme(
        base.textTheme.copyWith(
          // For large page titles (e.g., "Bulletin")
          displayLarge: TextStyle(
            fontSize: 28.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          // For section headers (e.g., "Pinned")
          headlineMedium: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade600,
          ),
          // For card titles (e.g., "Homecoming 2024")
          titleLarge: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
          // For subtitles and body text
          bodyMedium: TextStyle(
            fontSize: 12.sp,
            color: Colors.grey.shade700,
          ),
          // For button text
          labelLarge: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // --- OTHER WIDGET THEMES ---
      // You can define default styles for other widgets here too.
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.sp),
        ),
        color: Colors.white,
      ),
    );
  }

  static double get horizontalPadding => 6.w; // Responsive horizontal padding
  static double get cardRadius => 4.w; // Responsive card radius
}
