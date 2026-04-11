import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import '../utils/responsive_helper.dart';

class AppStyles {
  // --- BASE DESIGN SCALES ---
  
  static const double gutter = 24.0; // 1.5rem Standard Gutter
  static const double radiusXL = 24.0; // 1.5rem Large Container Radius

  // --- TYPOGRAPHY (MANROPE: Headlines, INTER: Body) ---

  // Display Lg (Editorial North Star)
  static TextStyle displayLg(BuildContext context) => GoogleFonts.manrope(
    fontSize: context.sp(48), // 3.5rem approach
    fontWeight: FontWeight.w800,
    color: AppColors.onSurface,
    letterSpacing: -1.5,
  );

  static TextStyle headlineMd(BuildContext context) => GoogleFonts.manrope(
    fontSize: context.sp(24),
    fontWeight: FontWeight.w700,
    color: AppColors.onSurface,
    letterSpacing: -0.5,
  );

  static TextStyle headlineSm(BuildContext context) => GoogleFonts.manrope(
    fontSize: context.sp(20),
    fontWeight: FontWeight.w600,
    color: AppColors.onSurface,
  );

  // Body & Functional Text (Inter)
  static TextStyle bodyLg(BuildContext context) => GoogleFonts.inter(
    fontSize: context.sp(16),
    color: AppColors.onSurface,
    height: 1.5,
  );

  static TextStyle bodyMd(BuildContext context) => GoogleFonts.inter(
    fontSize: context.sp(14),
    color: AppColors.onSurfaceVariant,
    height: 1.4,
  );

  static TextStyle bodySm(BuildContext context) => GoogleFonts.inter(
    fontSize: context.sp(12),
    color: AppColors.onSurfaceVariant,
    height: 1.3,
  );

  static TextStyle labelMedium(BuildContext context) => GoogleFonts.inter(
    fontSize: context.sp(14),
    fontWeight: FontWeight.w600,
    color: AppColors.onSurface,
  );

  // --- COMPONENT SPECIFIC STYLES ---

  static TextStyle primaryButton(BuildContext context) => GoogleFonts.manrope(
    fontSize: context.sp(16),
    fontWeight: FontWeight.w700,
    color: Colors.white,
    letterSpacing: 0.5,
  );

  static TextStyle inputHint(BuildContext context) => GoogleFonts.inter(
    fontSize: context.sp(bodySize),
    color: AppColors.onSurfaceVariant.withOpacity(0.6),
  );

  // --- AMBIENT DEPTH SYSTEM ---

  static List<BoxShadow> ambientShadow = [
    const BoxShadow(
      color: AppColors.ambientShadow,
      blurRadius: 24,
      spreadRadius: -4,
      offset: Offset(0, 8),
    ),
  ];

  // --- LEGACY COMPATIBILITY WRAPPERS (To maintain current build) ---
  
  static const double h1Size = 32;
  static const double bodySize = 14;

  static TextStyle headerDisplay(BuildContext context) => headlineMd(context);
  static TextStyle subheader(BuildContext context) => bodyMd(context).copyWith(color: AppColors.onSurfaceVariant);
  static TextStyle dashboardHeading(BuildContext context) => headlineSm(context);
  static TextStyle premiumCardTitle(BuildContext context) => labelMedium(context);
  static TextStyle premiumCardBody(BuildContext context) => bodySm(context);
  static TextStyle premiumButton(BuildContext context) => primaryButton(context);
  static TextStyle inputLabel(BuildContext context) => labelMedium(context);
  static TextStyle inputText(BuildContext context) => bodyMd(context);
  static TextStyle textLink(BuildContext context) => labelMedium(context).copyWith(color: AppColors.primary);
  static TextStyle textLinkPlain(BuildContext context) => bodyMd(context);
  static TextStyle baseHeadline(BuildContext context) => headlineSm(context);
  static TextStyle dashboardSubheading(BuildContext context) => bodyMd(context).copyWith(color: AppColors.onSurfaceVariant);
  static TextStyle labelSmall(BuildContext context) => bodySm(context).copyWith(fontWeight: FontWeight.w500);
}
