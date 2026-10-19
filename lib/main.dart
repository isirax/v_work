import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/constants/app_colors.dart';
import 'core/constants/app_theme.dart';
import 'core/providers/theme_provider.dart';
import 'features/home/presentation/home_screen.dart';

void main() {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    // 1. Flutter framework error handler (layout, rendering, widget tree)
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      debugPrint('[FlutterError] Caught framework exception: ${details.exceptionAsString()}');
    };

    // 2. Uncaught asynchronous error handler for all Dart isolates/futures
    PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
      debugPrint('[PlatformDispatcherError] Caught uncaught async error: $error\n$stack');
      return true; // Mark as handled to prevent termination
    };

    // 3. Global custom ErrorWidget fallback (prevents red screen of death on any platform)
    ErrorWidget.builder = (FlutterErrorDetails details) {
      return Material(
        color: const Color(0xFF0A0D14),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: AppColors.errorRed,
                    size: 44,
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Temporary Display Glitch',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    kDebugMode
                        ? details.exceptionAsString()
                        : 'The interface safely recovered from an unexpected rendering error.',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    };

    runApp(
      const ProviderScope(
        child: VWorkoutApp(),
      ),
    );
  }, (error, stack) {
    debugPrint('[ZonedGuardedError] Uncaught root zone error: $error\n$stack');
  });
}

class VWorkoutApp extends ConsumerWidget {
  const VWorkoutApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return MaterialApp(
      title: 'V Workout',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: const HomeScreen(),
    );
  }
}
