import 'package:flutter/material.dart';

/// FaydaMX Central color palette (cream/yellow gradient, dark blue accents).
class AppColors {
  AppColors._();

  // Primary - dark blue (app bar, buttons, status)
  static const Color primary = Color(0xFF1A237E);
  static const Color primaryDark = Color(0xFF0D1542);

  /// FaydaBill category / subcategory chip selected (Figma).
  static const Color faydaBillChipSelected = Color(0xFF0040B8);

  // Background - cream / light yellow gradient
  static const Color backgroundLight = Color(0xFFFFFDE7);
  static const Color backgroundWarm = Color(0xFFFFF9C4);
  static const Color backgroundGradientEnd = Color(0xFFFFF8E1);

  // Surface
  static const Color surface = Colors.white;
  static const Color surfaceCard = Color(0xFFEEEEEE);

  // Accent - golden (coin / logo)
  static const Color accentGold = Color(0xFFFFC107);
  static const Color accentGoldDark = Color(0xFFFFA000);

  // Text
  static const Color textPrimary = Color(0xFF1A237E);
  static const Color textSecondary = Color(0xFF5C6BC0);
  static const Color textOnPrimary = Colors.white;
  static const Color textHint = Color(0xFF9E9E9E);

  // Illustration / decorative
  static const Color figurePink = Color(0xFFE91E8C);
  static const Color figureGrey = Color(0xFF9E9E9E);
}
