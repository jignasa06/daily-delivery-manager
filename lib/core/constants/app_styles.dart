import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import '../utils/responsive_helper.dart';

class AppStyles {
  // Base font sizes
  static const double h1Size = 32;
  static const double h2Size = 24;
  static const double subSize = 16;
  static const double labelSize = 14;
  static const double bodySize = 15;

  // General Headers (Scaled versions via BuildContext)
  static TextStyle headerDisplay(BuildContext context) => GoogleFonts.poppins(
    fontSize: context.sp(h1Size),
    fontWeight: FontWeight.bold,
    color: AppColors.textInverse,
    letterSpacing: 1.2,
  );

  static TextStyle subheader(BuildContext context) => GoogleFonts.inter(
    fontSize: context.sp(subSize),
    color: AppColors.textInverse.withValues(alpha: 0.8),
  );

  // Labels & Form Elements
  static TextStyle inputLabel(BuildContext context) => GoogleFonts.inter(
    fontSize: context.sp(labelSize),
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
  );

  static TextStyle inputText(BuildContext context) => GoogleFonts.inter(
    fontSize: context.sp(bodySize),
    color: AppColors.textMain,
  );

  static TextStyle inputHint(BuildContext context) => GoogleFonts.inter(
    fontSize: context.sp(bodySize),
    color: AppColors.textHint,
  );

  // Buttons & Links
  static TextStyle primaryButton(BuildContext context) => GoogleFonts.poppins(
    fontSize: context.sp(subSize),
    fontWeight: FontWeight.w600,
    color: AppColors.textInverse,
    letterSpacing: 1,
  );

  static TextStyle textLink(BuildContext context) => GoogleFonts.inter(
    fontSize: context.sp(bodySize),
    fontWeight: FontWeight.bold,
    color: AppColors.textInverse,
  );

  static TextStyle textLinkPlain(BuildContext context) => GoogleFonts.inter(
    fontSize: context.sp(bodySize),
    color: AppColors.textInverse.withValues(alpha: 0.8),
  );

  // Generic Base Widget Styling
  static TextStyle baseHeadline(BuildContext context) => GoogleFonts.inter(
    fontSize: context.sp(subSize),
    fontWeight: FontWeight.w600,
    color: AppColors.textMain,
  );

  // Static Fallbacks (Legacy support)
  static TextStyle get staticHeaderDisplay => GoogleFonts.poppins(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.textInverse,
  );
}
