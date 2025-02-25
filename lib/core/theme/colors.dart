import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color black = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);
  
  // Secondary Colors
  static const Color lightGrey = Color(0xFFE0E0E0);
  static const Color darkGrey = Color(0xFF333333);
  
  // Accent Color (used sparingly)
  static const Color red = Color(0xFFFF0000);
  
  // Transparent Colors
  static Color blackTransparent(double opacity) => black.withAlpha((opacity * 255).round());
  static Color whiteTransparent(double opacity) => white.withAlpha((opacity * 255).round());
  
  // Dot Matrix Pattern Color
  static const Color dotMatrix = Color(0xFFCCCCCC);
  
  // Status Colors
  static const Color success = Color(0xFF00FF00);
  static const Color warning = Color(0xFFFFFF00);
  static const Color info = Color(0xFF0000FF);
} 