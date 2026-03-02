import 'package:flutter/material.dart';

/// Social Sage Design System Colors
/// Dark theme with neon accents — coder vibe, minimalist UI
class AppColors {
  AppColors._();

  // ── Backgrounds ──
  static const Color background = Color(0xFF181A20);
  static const Color cardBackground = Color(0xFF23272F);
  static const Color surfaceDark = Color(0xFF1E2028);
  static const Color bottomNavBg = Color(0xFF1C1E26);

  // ── Primary Accents ──
  static const Color neonCyan = Color(0xFF00FFD0);
  static const Color neonCyanDark = Color(0xFF00CCA0);
  static const Color neonCyanGlow = Color(0x3300FFD0);
  static const Color neonCyanSubtle = Color(0x1A00FFD0);

  // ── Secondary Accents ──
  static const Color gold = Color(0xFFFFD700);
  static const Color neonGreen = Color(0xFF00FF88);
  static const Color neonPurple = Color(0xFFBB86FC);
  static const Color neonBlue = Color(0xFF448AFF);
  static const Color neonPink = Color(0xFFFF4081);

  // ── Text ──
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B3B8);
  static const Color textTertiary = Color(0xFF6B6E75);
  static const Color textDisabled = Color(0xFF4A4D54);

  // ── Status ──
  static const Color error = Color(0xFFFF4444);
  static const Color success = Color(0xFF00FF88);
  static const Color warning = Color(0xFFFFAA00);
  static const Color info = Color(0xFF448AFF);

  // ── Borders ──
  static const Color border = Color(0xFF2E3139);
  static const Color borderLight = Color(0xFF3A3D45);
  static const Color borderActive = neonCyan;

  // ── Platform Colors ──
  static const Color facebook = Color(0xFF1877F2);
  static const Color instagram = Color(0xFFE4405F);
  static const Color twitter = Color(0xFF1DA1F2);
  static const Color tiktok = Color(0xFF000000);
  static const Color youtube = Color(0xFFFF0000);
  static const Color linkedin = Color(0xFF0A66C2);
  static const Color pinterest = Color(0xFFBD081C);
  static const Color telegram = Color(0xFF0088CC);
  static const Color whatsapp = Color(0xFF25D366);
  static const Color snapchat = Color(0xFFFFFC00);
  static const Color reddit = Color(0xFFFF4500);
  static const Color discord = Color(0xFF5865F2);
  static const Color wechat = Color(0xFF07C160);

  // ── Gradients ──
  static const LinearGradient neonGradient = LinearGradient(
    colors: [neonCyan, neonGreen],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF23272F), Color(0xFF1C1E26)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient shimmerGradient = LinearGradient(
    colors: [
      Color(0xFF23272F),
      Color(0xFF2E3139),
      Color(0xFF23272F),
    ],
    stops: [0.0, 0.5, 1.0],
    begin: Alignment(-1.0, -0.3),
    end: Alignment(1.0, 0.3),
  );
}
