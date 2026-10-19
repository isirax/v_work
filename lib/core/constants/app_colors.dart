import 'package:flutter/material.dart';

class AppColors {
  // Official Logo Palette
  static const Color logoNavy = Color(0xFF002D62); // Official Core Inner V
  static const Color logoSilver = Color(0xFFCBD2D9); // Official Outer V Border
  static const Color primaryCobalt = Color(0xFF0E5AD6); // Electric Royal Blue
  static const Color primaryIce = Color(0xFF00C2FF); // Cyan Ice Glow
  static const Color primaryVolt = Color(0xFF00D2FF); // High-voltage cyan-blue athletic accent
  static const Color primaryGreen = Color(0xFF10B981); // Athletic emerald for completed sets / safety
  static const Color primaryCyan = Color(0xFF00E5FF); // Electric cyber cyan
  static const Color primaryIndigo = Color(0xFF6366F1); // Athletic royal indigo
  static const Color primaryOrange = Color(0xFFFF6B4A); // High-burn metabolic flame
  static const Color primaryPurple = Color(0xFFA855F7); // Posture alignment violet
  static const Color warningGold = Color(0xFFFFB800);
  static const Color errorRed = Color(0xFFFF3366);

  // Dark Theme Palette (Obsidian Navy from app_icon_dark.svg #0A1118)
  static const Color darkBg = Color(0xFF0A1118);
  static const Color darkCard = Color(0xFF111A24);
  static const Color darkCardElevated = Color(0xFF182332);
  static const Color darkCardBorder = Color(0xFF1F2E40);
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkTextMuted = Color(0xFF64748B);
  static const Color darkDivider = Color(0xFF1A2636);

  // White / Light Theme Palette (Clean White from app_icon_light.svg #FFFFFF)
  static const Color lightBg = Color(0xFFF8FAFC);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightCardElevated = Color(0xFFF1F5F9);
  static const Color lightCardBorder = Color(0xFFE2E8F0);
  static const Color lightTextPrimary = Color(0xFF0A1118); // Logo obsidian navy text
  static const Color lightTextSecondary = Color(0xFF475569);
  static const Color lightTextMuted = Color(0xFF94A3B8);
  static const Color lightDivider = Color(0xFFE2E8F0);

  // Gradients
  static const LinearGradient logoGradient = LinearGradient(
    colors: [logoNavy, primaryCobalt],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient voltCyanGradient = LinearGradient(
    colors: [primaryCobalt, primaryIce],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient indigoPurpleGradient = LinearGradient(
    colors: [primaryIndigo, primaryPurple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient silverGradient = LinearGradient(
    colors: [Color(0xFFE2E8F0), logoSilver],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient flameGradient = LinearGradient(
    colors: [Color(0xFFFF8A00), primaryOrange],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkCardGradient = LinearGradient(
    colors: [Color(0xFF15202D), Color(0xFF0F1722)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
