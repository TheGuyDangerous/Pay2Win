import 'package:flutter/material.dart';
import 'colors.dart';

class TextStyles {
  // Base Text Style
  static const TextStyle baseTextStyle = TextStyle(
    fontFamily: 'SpaceMono',
    color: AppColors.black,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.5,
  );
  
  // Headings
  static const TextStyle heading1 = TextStyle(
    fontFamily: 'SpaceMono',
    fontSize: 28,
    fontWeight: FontWeight.normal,
    letterSpacing: 1.0,
    height: 1.2,
    color: AppColors.black,
  );
  
  static const TextStyle heading2 = TextStyle(
    fontFamily: 'SpaceMono',
    fontSize: 24,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.8,
    height: 1.2,
    color: AppColors.black,
  );
  
  static const TextStyle heading3 = TextStyle(
    fontFamily: 'SpaceMono',
    fontSize: 20,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.6,
    height: 1.2,
    color: AppColors.black,
  );
  
  // Body Text
  static const TextStyle bodyText = TextStyle(
    fontFamily: 'SpaceMono',
    fontSize: 16,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.5,
    height: 1.5,
    color: AppColors.black,
  );
  
  static const TextStyle bodyTextBold = TextStyle(
    fontFamily: 'SpaceMono',
    fontSize: 16,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.5,
    height: 1.5,
    color: AppColors.black,
  );
  
  // Small Text
  static const TextStyle smallText = TextStyle(
    fontFamily: 'SpaceMono',
    fontSize: 12,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.4,
    height: 1.4,
    color: AppColors.black,
  );
  
  // Button Text
  static const TextStyle buttonText = TextStyle(
    fontFamily: 'SpaceMono',
    fontSize: 14,
    fontWeight: FontWeight.normal,
    letterSpacing: 1.0,
    height: 1.0,
    color: AppColors.black,
  );
  
  // Tab Label
  static const TextStyle tabLabel = TextStyle(
    fontFamily: 'SpaceMono',
    fontSize: 14,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.5,
    height: 1.0,
    color: AppColors.black,
  );
  
  // Hint Text
  static const TextStyle hintText = TextStyle(
    fontFamily: 'SpaceMono',
    fontSize: 16,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.5,
    height: 1.5,
    color: AppColors.darkGrey,
  );
  
  // Caption Text
  static const TextStyle captionText = TextStyle(
    fontFamily: 'SpaceMono',
    fontSize: 10,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.4,
    height: 1.2,
    color: AppColors.darkGrey,
  );
  
  // Amount Text
  static const TextStyle amountText = TextStyle(
    fontFamily: 'SpaceMono',
    fontSize: 32,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.5,
    height: 1.0,
    color: AppColors.black,
  );
  
  // Error Text
  static const TextStyle errorText = TextStyle(
    fontFamily: 'SpaceMono',
    fontSize: 12,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.4,
    height: 1.2,
    color: AppColors.red,
  );
} 