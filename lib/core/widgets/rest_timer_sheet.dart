import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_colors.dart';
import '../providers/workout_provider.dart';

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
    final workout = ref.watch(workoutProvider);
    final remaining = workout.activeRestSeconds;
    final total = workout.totalRestSeconds ?? 90;

    if (remaining == null || remaining <= 0) {
      return const SizedBox.shrink();
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progress = (total > 0) ? (remaining / total).clamp(0.0, 1.0) : 0.0;

    final minutes = remaining ~/ 60;
    final seconds = remaining % 60;
    final timeStr = '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCardElevated : AppColors.lightCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primaryVolt.withValues(alpha: 0.6),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryVolt.withValues(alpha: 0.2),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Circular Progress Indicator
          SizedBox(
            width: 44,
            height: 44,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 4,
                  backgroundColor: isDark ? Colors.white10 : Colors.black12,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryVolt),
                ),
                const Icon(
                  Icons.timer_outlined,
                  size: 20,
                  color: AppColors.primaryVolt,
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
                const Text(
                  'REST INTERVAL',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                    color: AppColors.primaryVolt,
                  ),
                ),
                Text(
                  timeStr,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
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
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          ),
          IconButton(
            onPressed: () => ref.read(workoutProvider.notifier).adjustRestTimer(30),
            icon: const Icon(Icons.add_circle_outline_rounded),
            tooltip: '+30s',
            visualDensity: VisualDensity.compact,
            color: AppColors.primaryVolt,
          ),
          IconButton(
            onPressed: () => ref.read(workoutProvider.notifier).cancelRestTimer(),
            icon: const Icon(Icons.close_rounded),
            tooltip: 'Skip Rest',
            visualDensity: VisualDensity.compact,
            color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
          ),
        ],
      ),
    );
  }
}
