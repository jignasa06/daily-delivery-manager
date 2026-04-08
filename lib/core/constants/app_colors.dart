import 'package:flutter/material.dart';

class AppColors {
  // Core Brand Colors
  static const Color primary = Color(0xFF5C6BC0);      // Soft Indigo
  static const Color primaryLight = Color(0xFFB3E5FC); // Soft Light Blue
  
  // Backgrounds & Surfaces
  static const Color backgroundWhite = Colors.white;
  static const Color surfaceOffWhite = Color(0xFFFAFAFA); // Colors.grey[50]
  static const Color surfaceLightGrey = Color(0xFFEEEEEE); // Colors.grey[200]

  // Text Colors
  static const Color textMain = Colors.black87;
  static const Color textSecondary = Color(0xFF616161); // Colors.grey[700]
  static const Color textHint = Color(0xFFBDBDBD); // Colors.grey[400]
  static const Color textInverse = Colors.white;

  // Status & Feedback
  static const Color error = Colors.redAccent;
  static const Color success = Colors.green;

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
