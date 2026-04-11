import 'package:flutter/material.dart';

class AppColors {
  // --- CORE BRAND TOKENS (Atmospheric Precision) ---
  
  static const Color primary = Color(0xFF4352A5);          
  static const Color primaryContainer = Color(0xFF5C6BC0); 
  static const Color onPrimary = Colors.white;
  static const Color onPrimaryContainer = Colors.white;

  // --- SURFACE & LAYERING ENGINE ---
  
  static const Color surface = Color(0xFFF8F9FA);          
  static const Color surfaceContainerLow = Color(0xFFF3F4F5); 
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF); 
  static const Color surfaceContainerHigh = Color(0xFFE1E3E4); 
  
  static const Color onSurface = Color(0xFF191C1D);        
  static const Color onSurfaceVariant = Color(0xFF444748); 
  
  // --- FUNCTIONAL TOKENS ---
  
  static const Color error = Color(0xFFBA1A1A);
  static const Color onError = Colors.white;
  static const Color outline = Color(0xFF747778);
  static const Color outlineVariant = Color(0xFFC4C7C8); 

  // --- GRADIENTS & EFFECTS ---
  
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryContainer],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 1.0],
    transform: GradientRotation(0.785), 
  );

  static const Color ambientShadow = Color(0x0F191C1D); 

  // --- M3 COLOR SCHEME MAPPING ---
  
  static ColorScheme get lightColorScheme => const ColorScheme(
    brightness: Brightness.light,
    primary: primary,
    onPrimary: onPrimary,
    primaryContainer: primaryContainer,
    onPrimaryContainer: onPrimaryContainer,
    surface: surface,
    onSurface: onSurface,
    // Note: surfaceContainer variants are removed for backwards compatibility with older Flutter versions
    // They can be accessed via ThemeData.surfaceContainerLow etc. in newer versions
    secondary: primaryContainer,
    onSecondary: Colors.white,
    error: error,
    onError: onError,
    outline: outline,
    outlineVariant: outlineVariant,
  );

  static ColorScheme get darkColorScheme => const ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFFBEC2FF),
    onPrimary: Color(0xFF00174B),
    primaryContainer: Color(0xFF2E3D8C),
    onPrimaryContainer: Color(0xFFE0E0FF),
    surface: Color(0xFF111415),
    onSurface: Color(0xFFE1E3E4),
    secondary: Color(0xFFBEC2FF),
    onSecondary: Color(0xFF00174B),
    error: Color(0xFFFFB4AB),
    onError: Color(0xFF690005),
    outline: Color(0xFF8E9192),
    outlineVariant: Color(0xFF444748),
  );

  // --- LEGACY COMPATIBILITY ---
  static const Color indigoPrimary = primary;
  static const Color surfaceCloud = surface;
  static const Color cardShadow = ambientShadow;
  
  static const Color textMain = onSurface;
  static const Color textSecondary = onSurfaceVariant;
  static const Color textHint = outline;
  static const Color surfaceOffWhite = Color(0xFFF5F5F7);
  static const Color surfaceLightGrey = Color(0xFFF1F2F4);
  static const Color backgroundWhite = Colors.white;
  static const Color success = Color(0xFF2E7D32);
}
