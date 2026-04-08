import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppStyles {
  // General Headers
  static TextStyle headerDisplay = GoogleFonts.poppins(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.textInverse,
    letterSpacing: 1.2,
  );

  static TextStyle subheader = GoogleFonts.inter(
    fontSize: 16,
    color: AppColors.textInverse.withValues(alpha: 0.8),
  );

  // Labels & Form Elements
  static TextStyle inputLabel = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
  );

  static TextStyle inputText = GoogleFonts.inter(
    fontSize: 15,
    color: AppColors.textMain,
  );

  static TextStyle inputHint = GoogleFonts.inter(
    fontSize: 15,
    color: AppColors.textHint,
  );

  // Buttons & Links
  static TextStyle primaryButton = GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textInverse,
    letterSpacing: 1,
  );

  static TextStyle textLink = GoogleFonts.inter(
    fontSize: 15,
    fontWeight: FontWeight.bold,
    color: AppColors.textInverse,
  );

  static TextStyle textLinkPlain = GoogleFonts.inter(
    fontSize: 15,
    color: AppColors.textInverse.withValues(alpha: 0.8),
  );

  // Generic Base Widget Styling (Used for replacing old PvjTextWidget styles)
  static TextStyle baseHeadline = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textMain,
  );
}
