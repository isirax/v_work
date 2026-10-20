import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

/// Semantic, theme-aware colour tokens.
///
/// Access with `context.palette`. Every surface/text colour in the UI should
/// come from here instead of `isDark ? AppColors.x : AppColors.y` ternaries.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.background,
    required this.surface,
    required this.surfaceElevated,
    required this.surfaceSunken,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.accent,
    required this.onAccent,
    required this.success,
    required this.warning,
    required this.danger,
    required this.indigo,
    required this.orange,
    required this.teal,
    required this.heroGradient,
  });

  final Color background;
  final Color surface;
  final Color surfaceElevated;

  /// Slightly recessed fill for inline callouts and inputs.
  final Color surfaceSunken;
  final Color border;

  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;

  /// Primary interactive accent (cyan in dark mode, cobalt in light mode).
  final Color accent;
  final Color onAccent;

  final Color success;
  final Color warning;
  final Color danger;
  final Color indigo;
  final Color orange;
  final Color teal;

  final LinearGradient heroGradient;

  static const dark = AppPalette(
    background: AppColors.darkBg,
    surface: AppColors.darkCard,
    surfaceElevated: AppColors.darkCardElevated,
    surfaceSunken: Color(0xFF0D151F),
    border: AppColors.darkCardBorder,
    textPrimary: AppColors.darkTextPrimary,
    textSecondary: AppColors.darkTextSecondary,
    textMuted: AppColors.darkTextMuted,
    accent: AppColors.primaryIce,
    onAccent: AppColors.darkBg,
    success: AppColors.success,
    warning: AppColors.warning,
    danger: AppColors.errorRed,
    indigo: Color(0xFF818CF8),
    orange: AppColors.orange,
    teal: AppColors.teal,
    heroGradient: LinearGradient(
      colors: [Color(0xFF0E3A7A), Color(0xFF0B2347)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  );

  static const light = AppPalette(
    background: AppColors.lightBg,
    surface: AppColors.lightCard,
    surfaceElevated: AppColors.lightCardElevated,
    surfaceSunken: Color(0xFFF1F4F8),
    border: AppColors.lightCardBorder,
    textPrimary: AppColors.lightTextPrimary,
    textSecondary: AppColors.lightTextSecondary,
    textMuted: AppColors.lightTextMuted,
    accent: AppColors.primaryCobalt,
    onAccent: Colors.white,
    success: Color(0xFF059669),
    warning: AppColors.warningDeep,
    danger: Color(0xFFE11D48),
    indigo: AppColors.indigo,
    orange: AppColors.orangeDeep,
    teal: AppColors.tealDeep,
    heroGradient: LinearGradient(
      colors: [AppColors.primaryCobalt, AppColors.logoNavy],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  );

  @override
  AppPalette copyWith({
    Color? background,
    Color? surface,
    Color? surfaceElevated,
    Color? surfaceSunken,
    Color? border,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? accent,
    Color? onAccent,
    Color? success,
    Color? warning,
    Color? danger,
    Color? indigo,
    Color? orange,
    Color? teal,
    LinearGradient? heroGradient,
  }) {
    return AppPalette(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceElevated: surfaceElevated ?? this.surfaceElevated,
      surfaceSunken: surfaceSunken ?? this.surfaceSunken,
      border: border ?? this.border,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      accent: accent ?? this.accent,
      onAccent: onAccent ?? this.onAccent,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      danger: danger ?? this.danger,
      indigo: indigo ?? this.indigo,
      orange: orange ?? this.orange,
      teal: teal ?? this.teal,
      heroGradient: heroGradient ?? this.heroGradient,
    );
  }

  @override
  AppPalette lerp(AppPalette? other, double t) {
    if (other == null) return this;
    Color c(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppPalette(
      background: c(background, other.background),
      surface: c(surface, other.surface),
      surfaceElevated: c(surfaceElevated, other.surfaceElevated),
      surfaceSunken: c(surfaceSunken, other.surfaceSunken),
      border: c(border, other.border),
      textPrimary: c(textPrimary, other.textPrimary),
      textSecondary: c(textSecondary, other.textSecondary),
      textMuted: c(textMuted, other.textMuted),
      accent: c(accent, other.accent),
      onAccent: c(onAccent, other.onAccent),
      success: c(success, other.success),
      warning: c(warning, other.warning),
      danger: c(danger, other.danger),
      indigo: c(indigo, other.indigo),
      orange: c(orange, other.orange),
      teal: c(teal, other.teal),
      heroGradient: LinearGradient.lerp(heroGradient, other.heroGradient, t)!,
    );
  }
}

/// Spacing & radius scale so paddings stay consistent across screens.
abstract final class Insets {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;

  /// Standard horizontal page padding.
  static const page = EdgeInsets.fromLTRB(lg, sm, lg, xl);
}

abstract final class Radii {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 22;
}

extension ThemeContext on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get text => Theme.of(this).textTheme;
  AppPalette get palette =>
      Theme.of(this).extension<AppPalette>() ??
      (Theme.of(this).brightness == Brightness.dark
          ? AppPalette.dark
          : AppPalette.light);
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
}
