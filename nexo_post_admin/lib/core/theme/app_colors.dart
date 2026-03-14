import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Palette
  static const Color background = Color(0xFF071B1A);
  static const Color surface = Color(0xFF0F2A28);
  static const Color primaryAccent = Color(0xFF00FFB3);
  static const Color secondaryAccent = Color(0xFF00D9FF);
  static const Color highlight = Color(0xFF008CFF);

  // Text Colors
  static const Color textPrimary = Color(0xFFE6FFF9);
  static const Color textSecondary = Color(0xFF9CCAC3);
  static const Color textDisabled = Color(0xFF6B8F8A);

  // Border Colors
  static const Color borderCard = Color(0x2600FFB4); // rgba(0,255,180,0.15)
  static const Color divider = Color(0x14FFFFFF); // rgba(255,255,255,0.08)

  // Status Colors
  static const Color success = Color(0xFF00FF9C);
  static const Color warning = Color(0xFFFFB800);
  static const Color error = Color(0xFFFF4D6D);
  static const Color info = Color(0xFF00D9FF);

  // Gradients
  static const LinearGradient neonGlow = LinearGradient(
    colors: [
      Color(0x6600FFB4), // rgba(0,255,180,0.4)
      Color(0x0000FFB4),
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
