import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final themeProvider = NotifierProvider<ThemeNotifier, ThemeMode>(ThemeNotifier.new);

class ThemeNotifier extends Notifier<ThemeMode> {
  static const _prefKey = 'v_workout_theme_mode_str';
  static const _legacyKey = 'v_workout_theme_mode';

  @override
  ThemeMode build() {
    _loadTheme();
    return ThemeMode.dark;
  }

  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final modeStr = prefs.getString(_prefKey);
      if (modeStr != null) {
        if (modeStr == 'light') {
          state = ThemeMode.light;
        } else if (modeStr == 'system') {
          state = ThemeMode.system;
        } else {
          state = ThemeMode.dark;
        }
      } else {
        final isLight = prefs.getBool(_legacyKey);
        if (isLight != null) {
          state = isLight ? ThemeMode.light : ThemeMode.dark;
        }
      }
    } catch (_) {}
  }

  Future<void> setTheme(ThemeMode mode) async {
    state = mode;
    try {
      final prefs = await SharedPreferences.getInstance();
      final modeStr = switch (mode) {
        ThemeMode.light => 'light',
        ThemeMode.dark => 'dark',
        ThemeMode.system => 'system',
      };
      await prefs.setString(_prefKey, modeStr);
      await prefs.setBool(_legacyKey, mode == ThemeMode.light);
    } catch (_) {}
  }

  Future<void> toggleTheme() async {
    final next = (state == ThemeMode.dark) ? ThemeMode.light : ThemeMode.dark;
    await setTheme(next);
  }
}
