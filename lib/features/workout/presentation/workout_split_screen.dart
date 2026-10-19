import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/workout_provider.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                gradient: AppColors.voltCyanGradient,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(Icons.fitness_center_rounded, color: Colors.black, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'PHASE ${workout.currentPhase.phaseNumber}: ${workout.currentPhase.title}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: Colors.black,
                            letterSpacing: 0.4,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Week ${workout.currentWeek} • ${workout.currentPhase.repRangeGuide}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios_rounded, color: Colors.black54, size: 14),
                ],
              ),
            ),
          ),

          // Day Selection Tabs (Day 1 to 5)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                        color: isSelected
                            ? (isDark ? Colors.black : Colors.white)
                            : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                      ),
                    ),
                    backgroundColor: isDark ? AppColors.darkCard : AppColors.lightCard,
                    selectedColor: isDark ? AppColors.primaryVolt : const Color(0xFF00C875),
                    side: BorderSide(
                      color: isSelected
                          ? AppColors.primaryVolt
                          : (isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder),
                    ),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    onSelected: (selected) {
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: [
                // Day Overview Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.primaryIndigo.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'DAY ${activeDay.dayNumber}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.primaryIndigo,
                                ),
                              ),
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
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          ),
                        ),
                        const Divider(height: 18),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.shield_outlined, size: 16, color: AppColors.primaryVolt),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                activeDay.biomechanicalFocus,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Start Session CTA
                ElevatedButton.icon(
                  onPressed: () {
                    ref.read(workoutProvider.notifier).startWorkoutSession(selectedDayIndex);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ActiveWorkoutScreen()),
                    );
                  },
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: Text('Start Day ${activeDay.dayNumber} Session'),
                ),
                const SizedBox(height: 18),

                // Section Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'PRESCRIBED EXERCISES (${activeDay.exercises.length})',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                        color: AppColors.primaryCyan,
                      ),
                    ),
                    const Text(
                      'Tap to View / Swap',
                      style: TextStyle(fontSize: 11, color: AppColors.darkTextMuted),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Exercises Cards
                ...activeDay.exercises.asMap().entries.map((entry) {
                  final exIndex = entry.key;
                  final exercise = entry.value;

                  return _buildExerciseSplitCard(
                    context: context,
                    index: exIndex + 1,
                    exercise: exercise,
                    dayIndex: selectedDayIndex,
                    isDark: isDark,
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

  Widget _buildExerciseSplitCard({
    required BuildContext context,
    required int index,
    required Exercise exercise,
    required int dayIndex,
    required bool isDark,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(16),
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
                  backgroundColor: AppColors.primaryCyan.withValues(alpha: 0.15),
                  child: Text(
                    '$index',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryCyan,
                    ),
                  ),
                ),
                const SizedBox(width: 12),

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
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                // Swapped indicator badge
                if (exercise.isSwapped)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primaryOrange.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'SWAPPED',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primaryOrange,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Video & Illustration Preview
            InkWell(
              onTap: () => ExerciseDetailModal.show(context, exercise, dayIndex),
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  if (exercise.activeThumbnailPath.isNotEmpty)
                    Container(
                      height: 120,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF0F141F) : const Color(0xFFEDF2F7),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
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
                        border: Border.all(color: AppColors.primaryVolt.withValues(alpha: 0.8), width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.play_circle_fill_rounded, size: 13, color: AppColors.primaryVolt),
                          const SizedBox(width: 4),
                          Text(
                            exercise.hasDownloadedVideo ? 'ANIMATION & FULL VIDEO' : 'HD ANIMATION',
                            style: const TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w900,
                              color: AppColors.primaryVolt,
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
            const SizedBox(height: 12),

            // Parameters Badges Row
            Row(
              children: [
                _buildChipBadge('${exercise.defaultSets} Sets', Icons.format_list_numbered, isDark),
                const SizedBox(width: 6),
                _buildChipBadge('${exercise.defaultReps} Reps', Icons.repeat, isDark),
                const SizedBox(width: 6),
                _buildChipBadge(exercise.defaultRir, Icons.speed, isDark),
                const SizedBox(width: 6),
                _buildChipBadge('${exercise.defaultRestSeconds}s Rest', Icons.timer_outlined, isDark),
              ],
            ),
            const SizedBox(height: 10),

            // Biomechanical Cues snippet
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDark ? const Color(0x33000000) : const Color(0x0C000000),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.shield_outlined, size: 14, color: AppColors.primaryVolt),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      exercise.activeBiomechanicalCue,
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Actions Row
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: () => ExerciseSwapModal.show(context, dayIndex, exercise),
                  icon: const Icon(Icons.swap_horiz_rounded, size: 16),
                  label: const Text('Swap Exercise', style: TextStyle(fontSize: 12)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    visualDensity: VisualDensity.compact,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () => ExerciseDetailModal.show(context, exercise, dayIndex),
                  icon: const Icon(Icons.play_circle_outline_rounded, size: 16),
                  label: const Text('Form & Video', style: TextStyle(fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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

  Widget _buildChipBadge(String text, IconData icon, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCardElevated : AppColors.lightCardElevated,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.primaryCyan),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
