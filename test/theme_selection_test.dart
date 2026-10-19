import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:v_work/core/providers/theme_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('ThemeNotifier defaults to Dark mode and toggles to White/Light mode', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    // Initial state is dark
    expect(container.read(themeProvider), ThemeMode.dark);

    // Toggle to Light / White
    await container.read(themeProvider.notifier).toggleTheme();
    expect(container.read(themeProvider), ThemeMode.light);

    // Toggle back to Dark
    await container.read(themeProvider.notifier).toggleTheme();
    expect(container.read(themeProvider), ThemeMode.dark);

    // Set explicitly to System
    await container.read(themeProvider.notifier).setTheme(ThemeMode.system);
    expect(container.read(themeProvider), ThemeMode.system);

    // Set explicitly to Light
    await container.read(themeProvider.notifier).setTheme(ThemeMode.light);
    expect(container.read(themeProvider), ThemeMode.light);
  });
}
