import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/workout_provider.dart';
import '../theme/app_palette.dart';

class RestTimerBar extends ConsumerStatefulWidget {
  const RestTimerBar({super.key});

  @override
  ConsumerState<RestTimerBar> createState() => _RestTimerBarState();
}

class _RestTimerBarState extends ConsumerState<RestTimerBar> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimerTicker();
  }

  void _startTimerTicker() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      ref.read(workoutProvider.notifier).tickRestTimer();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Only rebuild when the timer numbers change, not other workout state
    final remaining = ref.watch(workoutProvider.select((s) => s.activeRestSeconds));
    final total = ref.watch(workoutProvider.select((s) => s.totalRestSeconds)) ?? 90;

    if (remaining == null || remaining <= 0) {
      return const SizedBox.shrink();
    }

    final palette = context.palette;
    final progress = (total > 0) ? (remaining / total).clamp(0.0, 1.0) : 0.0;

    final minutes = remaining ~/ 60;
    final seconds = remaining % 60;
    final timeStr = '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: Insets.lg, vertical: Insets.sm),
      padding: const EdgeInsets.symmetric(horizontal: Insets.lg, vertical: Insets.md),
      decoration: BoxDecoration(
        color: palette.surfaceElevated,
        borderRadius: BorderRadius.circular(Radii.xl),
        border: Border.all(
          color: palette.accent.withValues(alpha: 0.6),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: palette.accent.withValues(alpha: context.isDark ? 0.25 : 0.15),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Circular Progress Indicator
          SizedBox(
            width: 46,
            height: 46,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 4.5,
                  strokeCap: StrokeCap.round,
                  backgroundColor: palette.accent.withValues(alpha: context.isDark ? 0.15 : 0.10),
                  valueColor: AlwaysStoppedAnimation<Color>(palette.accent),
                ),
                Icon(
                  Icons.timer_outlined,
                  size: 20,
                  color: palette.accent,
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),

          // Time text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'REST INTERVAL',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                    color: palette.accent,
                  ),
                ),
                Text(
                  timeStr,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                    color: palette.textPrimary,
                  ),
                ),
              ],
            ),
          ),

          // Adjust buttons
          IconButton(
            onPressed: () => ref.read(workoutProvider.notifier).adjustRestTimer(-15),
            icon: const Icon(Icons.remove_circle_outline_rounded),
            tooltip: '-15s',
            visualDensity: VisualDensity.compact,
            color: palette.textSecondary,
          ),
          IconButton(
            onPressed: () => ref.read(workoutProvider.notifier).adjustRestTimer(30),
            icon: const Icon(Icons.add_circle_outline_rounded),
            tooltip: '+30s',
            visualDensity: VisualDensity.compact,
            color: palette.accent,
          ),
          IconButton(
            onPressed: () => ref.read(workoutProvider.notifier).cancelRestTimer(),
            icon: const Icon(Icons.close_rounded),
            tooltip: 'Skip Rest',
            visualDensity: VisualDensity.compact,
            color: palette.textMuted,
          ),
        ],
      ),
    );
  }
}
