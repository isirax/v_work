import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/workout_provider.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/utils/youtube_launcher.dart';
import '../../../core/widgets/common/v_badge.dart';
import '../../../core/widgets/common/v_callout.dart';
import '../../../core/widgets/exercise_illustration.dart';
import '../models/exercise.dart';
import 'active_workout_screen.dart';
import 'exercise_detail_modal.dart';
import 'exercise_swap_modal.dart';
import 'mesocycle_screen.dart';

class WorkoutSplitScreen extends ConsumerWidget {
  const WorkoutSplitScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workout = ref.watch(workoutProvider);
    final split = workout.split;
    final selectedDayIndex = workout.selectedDayIndex;
    final activeDay = workout.selectedDay;
    final palette = context.palette;

    return Scaffold(
      appBar: AppBar(
        title: const Text('5-Day Workout Split'),
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range_rounded),
            tooltip: 'Mesocycle Periodization',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MesocycleScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Periodization Phase Strip
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MesocycleScreen()),
              );
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: Insets.lg, vertical: Insets.xs),
              padding: const EdgeInsets.symmetric(horizontal: Insets.md, vertical: 10),
              decoration: BoxDecoration(
                gradient: palette.heroGradient,
                borderRadius: BorderRadius.circular(Radii.md),
                boxShadow: [
                  BoxShadow(
                    color: palette.accent.withValues(alpha: context.isDark ? 0.25 : 0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.fitness_center_rounded, color: Colors.white, size: 18),
                  ),
                  const SizedBox(width: Insets.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'PHASE ${workout.currentPhase.phaseNumber}: ${workout.currentPhase.title}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 0.4,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Week ${workout.currentWeek} • ${workout.currentPhase.repRangeGuide}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.white.withValues(alpha: 0.7),
                    size: 14,
                  ),
                ],
              ),
            ),
          ),

          // Day Selection Tabs (Day 1 to 5)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: Insets.lg, vertical: Insets.sm),
            child: Row(
              children: List.generate(split.length, (index) {
                final day = split[index];
                final isSelected = index == selectedDayIndex;

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    selected: isSelected,
                    showCheckmark: false,
                    label: Text(
                      'Day ${day.dayNumber}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: isSelected ? palette.onAccent : palette.textSecondary,
                      ),
                    ),
                    backgroundColor: palette.surface,
                    selectedColor: palette.accent,
                    side: BorderSide(
                      color: isSelected ? palette.accent : palette.border,
                      width: isSelected ? 1.5 : 1.0,
                    ),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.md)),
                    onSelected: (_) {
                      ref.read(workoutProvider.notifier).selectDay(index);
                    },
                  ),
                );
              }),
            ),
          ),

          // Active Day Details & Exercises List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: Insets.lg, vertical: Insets.xs),
              children: [
                // Day Overview Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(Insets.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            VBadge(
                              label: 'DAY ${activeDay.dayNumber}',
                              variant: VBadgeVariant.indigo,
                              fontSize: 10,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                activeDay.title,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          activeDay.subtitle,
                          style: TextStyle(
                            fontSize: 13,
                            color: palette.textSecondary,
                          ),
                        ),
                        const Divider(height: 20),
                        VCallout(
                          title: 'POSTURE & APT FOCUS',
                          message: activeDay.biomechanicalFocus,
                          icon: Icons.shield_outlined,
                          variant: VCalloutVariant.accent,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: Insets.md),

                // Start Session CTA
                FilledButton.icon(
                  onPressed: () {
                    ref.read(workoutProvider.notifier).startWorkoutSession(selectedDayIndex);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ActiveWorkoutScreen()),
                    );
                  },
                  icon: const Icon(Icons.play_arrow_rounded, size: 22),
                  label: Text(
                    'Start Day ${activeDay.dayNumber} Session',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: palette.accent,
                    foregroundColor: palette.onAccent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(Radii.md),
                    ),
                  ),
                ),
                const SizedBox(height: Insets.lg),

                // Section Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'PRESCRIBED EXERCISES (${activeDay.exercises.length})',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                        color: palette.accent,
                      ),
                    ),
                    Text(
                      'Tap to View / Swap',
                      style: TextStyle(fontSize: 11, color: palette.textMuted),
                    ),
                  ],
                ),
                const SizedBox(height: Insets.sm),

                // Exercises Cards
                ...activeDay.exercises.asMap().entries.map((entry) {
                  final exIndex = entry.key;
                  final exercise = entry.value;

                  return _ExerciseSplitCard(
                    index: exIndex + 1,
                    exercise: exercise,
                    dayIndex: selectedDayIndex,
                  );
                }),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ExerciseSplitCard extends StatelessWidget {
  final int index;
  final Exercise exercise;
  final int dayIndex;

  const _ExerciseSplitCard({
    required this.index,
    required this.exercise,
    required this.dayIndex,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final isDark = context.isDark;

    return Card(
      margin: const EdgeInsets.only(bottom: Insets.md),
      child: Padding(
        padding: const EdgeInsets.all(Insets.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Exercise Number Badge
                CircleAvatar(
                  radius: 14,
                  backgroundColor: palette.accent.withValues(alpha: 0.15),
                  child: Text(
                    '$index',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: palette.accent,
                    ),
                  ),
                ),
                const SizedBox(width: Insets.md),

                // Name & Target
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exercise.activeName,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        exercise.targetMuscle,
                        style: TextStyle(
                          fontSize: 12,
                          color: palette.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                // Swapped indicator badge
                if (exercise.isSwapped)
                  const VBadge(
                    label: 'SWAPPED',
                    variant: VBadgeVariant.orange,
                    fontSize: 9,
                  ),
              ],
            ),
            const SizedBox(height: Insets.md),

            // Video & Illustration Preview
            InkWell(
              onTap: () => ExerciseDetailModal.show(context, exercise, dayIndex),
              borderRadius: BorderRadius.circular(Radii.lg),
              child: Stack(
                children: [
                  if (exercise.activeThumbnailPath.isNotEmpty)
                    Container(
                      height: 120,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF0F141F) : const Color(0xFFEDF2F7),
                        borderRadius: BorderRadius.circular(Radii.lg),
                        border: Border.all(color: palette.border),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(Radii.lg),
                        child: Center(
                          child: Image.asset(
                            exercise.activeThumbnailPath,
                            fit: BoxFit.contain,
                            height: 120,
                            errorBuilder: (ctx, err, st) => ExerciseIllustration(
                              illustrationKey: exercise.illustrationKey,
                              height: 110,
                            ),
                          ),
                        ),
                      ),
                    )
                  else
                    ExerciseIllustration(
                      illustrationKey: exercise.illustrationKey,
                      height: 110,
                    ),
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: palette.accent.withValues(alpha: 0.8), width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.play_circle_fill_rounded, size: 13, color: palette.accent),
                          const SizedBox(width: 4),
                          Text(
                            exercise.hasDownloadedVideo ? 'ANIMATION & FULL VIDEO' : 'HD ANIMATION',
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w900,
                              color: palette.accent,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: Insets.md),

            // Parameters Badges Row
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                VBadge(
                  label: '${exercise.defaultSets} Sets',
                  icon: Icons.format_list_numbered,
                  variant: VBadgeVariant.cyan,
                  fontSize: 10,
                ),
                VBadge(
                  label: '${exercise.defaultReps} Reps',
                  icon: Icons.repeat,
                  variant: VBadgeVariant.cyan,
                  fontSize: 10,
                ),
                VBadge(
                  label: exercise.defaultRir,
                  icon: Icons.speed,
                  variant: VBadgeVariant.cyan,
                  fontSize: 10,
                ),
                VBadge(
                  label: '${exercise.defaultRestSeconds}s Rest',
                  icon: Icons.timer_outlined,
                  variant: VBadgeVariant.cyan,
                  fontSize: 10,
                ),
              ],
            ),
            const SizedBox(height: Insets.sm),

            // Biomechanical Cues snippet
            VCallout(
              message: exercise.activeBiomechanicalCue,
              icon: Icons.shield_outlined,
              variant: VCalloutVariant.accent,
              padding: const EdgeInsets.all(8),
            ),
            const SizedBox(height: Insets.sm),

            // Actions Row
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: () => YouTubeLauncher.launchExerciseTutorial(exercise.activeName),
                  icon: const Icon(Icons.smart_display_rounded, size: 15, color: Color(0xFFFF0000)),
                  label: const Text(
                    'YouTube',
                    style: TextStyle(fontSize: 11, color: Color(0xFFFF0000), fontWeight: FontWeight.bold),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFFF0000), width: 1),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    visualDensity: VisualDensity.compact,
                  ),
                ),
                const Spacer(),
                OutlinedButton.icon(
                  onPressed: () => ExerciseSwapModal.show(context, dayIndex, exercise),
                  icon: const Icon(Icons.swap_horiz_rounded, size: 16),
                  label: Text(
                    exercise.isSwapped ? 'Swapped' : 'Swap',
                    style: const TextStyle(fontSize: 12),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    visualDensity: VisualDensity.compact,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () => ExerciseDetailModal.show(context, exercise, dayIndex),
                  icon: const Icon(Icons.play_circle_outline_rounded, size: 16),
                  label: const Text('Form & Video', style: TextStyle(fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
