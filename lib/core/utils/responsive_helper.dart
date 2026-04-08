import 'package:flutter/material.dart';
import 'dart:math' as math;

extension ResponsiveHelper on BuildContext {
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;

  // Proportional Width
  double pw(double p) => screenWidth * (p / 100);

  // Proportional Height
  double ph(double p) => screenHeight * (p / 100);

  // Scaled Pixels (using width as base for standard scaling)
  // 375 is a standard mobile width (iPhone X/12)
  double sp(double size) {
    double scale = screenWidth / 375;
    // Cap scaling for large tablets to avoid massive fonts
    return size * math.min(scale, 1.2);
  }

  // Responsive Spacing
  double get hSpacing => pw(6); // 6% of width
  double get vSpacing => ph(2); // 2% of height
}

class Responsive {
  static late MediaQueryData _mediaQueryData;
  static late double screenWidth;
  static late double screenHeight;
  static late double _scale;

  static void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;
    _scale = screenWidth / 375;
  }

  static double sp(double size) => size * math.min(_scale, 1.2);
  static double width(double p) => screenWidth * (p / 100);
  static double height(double p) => screenHeight * (p / 100);
}
