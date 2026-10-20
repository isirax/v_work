import 'package:flutter/material.dart';

/// Raw brand + semantic colour values.
abstract final class AppColors {
  // Official logo palette
  static const Color logoNavy = Color(0xFF002D62); // Core inner V
  static const Color logoSilver = Color(0xFFCBD2D9); // Outer V border
  static const Color primaryCobalt = Color(0xFF0E5AD6); // Electric royal blue
  static const Color primaryIce = Color(0xFF00C2FF); // Cyan ice glow

  // Core semantic accents
  static const Color primaryVolt = Color(0xFF00D2FF); // High-voltage cyan-blue athletic accent
  static const Color primaryCyan = Color(0xFF00E5FF); // Electric cyber cyan
  static const Color primaryIndigo = Color(0xFF6366F1); // Athletic royal indigo
  static const Color primaryOrange = Color(0xFFFF6B4A); // High-burn metabolic flame
  static const Color primaryPurple = Color(0xFFA855F7); // Posture alignment violet
  static const Color primaryGreen = Color(0xFF10B981); // Athletic emerald for completed sets / safety
  static const Color success = Color(0xFF10B981);
  static const Color warningGold = Color(0xFFFFB800);
  static const Color warning = Color(0xFFFFB800);
  static const Color warningDeep = Color(0xFFB7791F); // readable on white
  static const Color errorRed = Color(0xFFFF3366);
  static const Color indigo = Color(0xFF6366F1);
  static const Color orange = Color(0xFFFF6B4A);
  static const Color orangeDeep = Color(0xFFE8590C); // readable on white
  static const Color teal = Color(0xFF22D3EE);
  static const Color tealDeep = Color(0xFF0891B2); // readable on white

  // Dark theme (Obsidian Navy from app_icon_dark.svg #0A1118)
  static const Color darkBg = Color(0xFF0A1118);
  static const Color darkCard = Color(0xFF111A24);
  static const Color darkCardElevated = Color(0xFF182332);
  static const Color darkCardBorder = Color(0xFF1F2E40);
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkTextMuted = Color(0xFF64748B);
  static const Color darkDivider = Color(0xFF1A2636);

  // Light theme (Clean white from app_icon_light.svg #FFFFFF)
  static const Color lightBg = Color(0xFFF6F8FB);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightCardElevated = Color(0xFFF1F5F9);
  static const Color lightCardBorder = Color(0xFFE2E8F0);
  static const Color lightTextPrimary = Color(0xFF0A1118);
  static const Color lightTextSecondary = Color(0xFF475569);
  static const Color lightTextMuted = Color(0xFF94A3B8);
  static const Color lightDivider = Color(0xFFE2E8F0);

  /// Background used behind videos / GIFs in both themes.
  static const Color media = Color(0xFF0A0D14);

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
