import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';
import '../constants/app_styles.dart';

class AppTheme {
  static ThemeData get lightTheme {
    final ColorScheme colorScheme = AppColors.lightColorScheme;
    
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      
      // --- TYPOGRAPHY ENGINE ---
      textTheme: TextTheme(
        displayLarge: GoogleFonts.manrope(fontWeight: FontWeight.w800),
        headlineMedium: GoogleFonts.manrope(fontWeight: FontWeight.w700),
        bodyLarge: GoogleFonts.inter(),
        bodyMedium: GoogleFonts.inter(),
      ),

      // --- COMPONENT THEMES ---
      
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        titleTextStyle: GoogleFonts.manrope(
          fontSize: 20, 
          fontWeight: FontWeight.w700,
          color: colorScheme.onSurface,
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppStyles.radiusXL),
          ),
          textStyle: GoogleFonts.manrope(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceContainerLow,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        labelStyle: GoogleFonts.inter(color: colorScheme.onSurfaceVariant),
        hintStyle: GoogleFonts.inter(color: colorScheme.onSurfaceVariant.withOpacity(0.5)),
      ),

      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.surfaceContainerLowest,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppStyles.radiusXL),
        ),
      ),

      dividerTheme: DividerThemeData(
        thickness: 1,
        color: colorScheme.outlineVariant.withOpacity(0.1),
        space: 1,
      ),
    );
  }

  static ThemeData get darkTheme {
    final ColorScheme colorScheme = AppColors.darkColorScheme;
    
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      textTheme: TextTheme(
        displayLarge: GoogleFonts.manrope(fontWeight: FontWeight.w800, color: colorScheme.onSurface),
        headlineMedium: GoogleFonts.manrope(fontWeight: FontWeight.w700, color: colorScheme.onSurface),
        bodyLarge: GoogleFonts.inter(color: colorScheme.onSurface),
        bodyMedium: GoogleFonts.inter(color: colorScheme.onSurface),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppStyles.radiusXL),
          ),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppStyles.radiusXL),
        ),
      ),
    );
  }
}
