import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/workout_provider.dart';
import '../../../core/widgets/rest_timer_sheet.dart';
import '../models/exercise.dart';
import '../models/workout_set.dart';
import 'exercise_detail_modal.dart';
import 'exercise_swap_modal.dart';

class ActiveWorkoutScreen extends ConsumerStatefulWidget {
  const ActiveWorkoutScreen({super.key});

  @override
  ConsumerState<ActiveWorkoutScreen> createState() => _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends ConsumerState<ActiveWorkoutScreen> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final workout = ref.watch(workoutProvider);
    final day = workout.selectedDay;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Day ${day.dayNumber}: ${day.title}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              'Mesocycle Phase ${workout.currentPhase.phaseNumber} • Week ${workout.currentWeek}',
              style: const TextStyle(fontSize: 11, color: AppColors.primaryVolt, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: () => _showFinishDialog(context),
            icon: const Icon(Icons.check_circle_outline_rounded, color: AppColors.primaryVolt),
            label: const Text(
              'Finish',
              style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryVolt),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background content
          Column(
            children: [
              // Mandatory APT Alignment Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: AppColors.primaryVolt.withValues(alpha: isDark ? 0.12 : 0.08),
                child: Row(
                  children: [
                    const Icon(Icons.shield_outlined, size: 16, color: AppColors.primaryVolt),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Focus: ${day.biomechanicalFocus}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

              // Exercises List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 90),
                  itemCount: day.exercises.length,
                  itemBuilder: (context, exIndex) {
                    final exercise = day.exercises[exIndex];
                    final sets = workout.activeSessionSets[exercise.id] ?? [];
                    return _buildExerciseCard(
                      context: context,
                      exercise: exercise,
                      sets: sets,
                      isDark: isDark,
                      dayIndex: workout.selectedDayIndex,
                    );
                  },
                ),
              ),
            ],
          ),

          // Floating Rest Timer Bar at Bottom
          const Positioned(
            left: 0,
            right: 0,
            bottom: 12,
            child: RestTimerBar(),
          ),

          // Confetti celebratory burst
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                AppColors.primaryVolt,
                AppColors.primaryCyan,
                AppColors.primaryOrange,
                AppColors.primaryIndigo,
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseCard({
    required BuildContext context,
    required Exercise exercise,
    required List<WorkoutSet> sets,
    required bool isDark,
    required int dayIndex,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Exercise Header
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (exercise.activeThumbnailPath.isNotEmpty) ...[
                  GestureDetector(
                    onTap: () => ExerciseDetailModal.show(context, exercise, dayIndex),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        width: 44,
                        height: 44,
                        color: isDark ? AppColors.darkCardElevated : AppColors.lightCardElevated,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Image.asset(
                              exercise.activeThumbnailPath,
                              width: 44,
                              height: 44,
                              fit: BoxFit.cover,
                              errorBuilder: (ctx, err, st) => const Icon(
                                Icons.fitness_center_rounded,
                                size: 20,
                                color: AppColors.primaryVolt,
                              ),
                            ),
                            Container(
                              color: Colors.black26,
                              child: const Icon(
                                Icons.play_arrow_rounded,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exercise.activeName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Target: ${exercise.targetMuscle} • ${exercise.defaultRir}',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Watch Video & Cues',
                  icon: const Icon(Icons.play_circle_fill_rounded, color: AppColors.primaryVolt, size: 22),
                  onPressed: () => ExerciseDetailModal.show(context, exercise, dayIndex),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert_rounded),
                  onSelected: (value) {
                    if (value == 'swap') {
                      ExerciseSwapModal.show(context, dayIndex, exercise);
                    } else if (value == 'detail') {
                      ExerciseDetailModal.show(context, exercise, dayIndex);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'swap',
                      child: Row(
                        children: [
                          Icon(Icons.swap_horiz_rounded, size: 18),
                          SizedBox(width: 8),
                          Text('Swap Exercise'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'detail',
                      child: Row(
                        children: [
                          Icon(Icons.info_outline_rounded, size: 18),
                          SizedBox(width: 8),
                          Text('Form Cues & Video'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),

            // APT Biomechanical Note
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: isDark ? const Color(0x33000000) : const Color(0x0C000000),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.accessibility_new_rounded, size: 14, color: AppColors.primaryVolt),
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
            const SizedBox(height: 14),

            // Sets Table Header
            Row(
              children: [
                _buildTableHeader('SET', 36),
                _buildTableHeader('KG', 65),
                _buildTableHeader('REPS', 55),
                _buildTableHeader('RIR', 45),
                const Spacer(),
                _buildTableHeader('DONE', 48),
              ],
            ),
            const Divider(height: 14),

            // Sets Rows
            ...sets.asMap().entries.map((entry) {
              final setIndex = entry.key;
              final set = entry.value;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    // Set Number
                    SizedBox(
                      width: 36,
                      child: Text(
                        '#${set.setNumber}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),

                    // Weight Input
                    SizedBox(
                      width: 65,
                      child: _buildInlineNumberInput(
                        initialValue: set.weightKg > 0 ? set.weightKg.toStringAsFixed(1) : '',
                        hint: '0.0',
                        isDark: isDark,
                        onChanged: (val) {
                          final weight = double.tryParse(val) ?? 0.0;
                          ref.read(workoutProvider.notifier).updateSet(
                                exercise.id,
                                setIndex,
                                set.copyWith(weightKg: weight),
                              );
                        },
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Reps Input
                    SizedBox(
                      width: 55,
                      child: _buildInlineNumberInput(
                        initialValue: set.reps.toString(),
                        hint: '10',
                        isDark: isDark,
                        onChanged: (val) {
                          final reps = int.tryParse(val) ?? 10;
                          ref.read(workoutProvider.notifier).updateSet(
                                exercise.id,
                                setIndex,
                                set.copyWith(reps: reps),
                              );
                        },
                      ),
                    ),
                    const SizedBox(width: 8),

                    // RIR Input
                    SizedBox(
                      width: 45,
                      child: _buildInlineNumberInput(
                        initialValue: set.rir.toString(),
                        hint: '2',
                        isDark: isDark,
                        onChanged: (val) {
                          final rir = int.tryParse(val) ?? 2;
                          ref.read(workoutProvider.notifier).updateSet(
                                exercise.id,
                                setIndex,
                                set.copyWith(rir: rir),
                              );
                        },
                      ),
                    ),
                    const Spacer(),

                    // Done Checkbox
                    InkWell(
                      onTap: () {
                        ref.read(workoutProvider.notifier).toggleSetCompleted(
                              exercise.id,
                              setIndex,
                              exercise.defaultRestSeconds,
                            );
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 44,
                        height: 36,
                        decoration: BoxDecoration(
                          color: set.isCompleted
                              ? AppColors.primaryVolt
                              : (isDark ? Colors.white10 : Colors.black12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.check_rounded,
                          size: 20,
                          color: set.isCompleted ? Colors.black : Colors.transparent,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 8),
            // Add Set button
            Center(
              child: TextButton.icon(
                onPressed: () => ref.read(workoutProvider.notifier).addSet(exercise.id),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add Set', style: TextStyle(fontSize: 12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableHeader(String text, double width) {
    return SizedBox(
      width: width,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
          color: AppColors.primaryCyan,
        ),
      ),
    );
  }

  Widget _buildInlineNumberInput({
    required String initialValue,
    required String hint,
    required bool isDark,
    required ValueChanged<String> onChanged,
  }) {
    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCardElevated : AppColors.lightCardElevated,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
        ),
      ),
      child: TextFormField(
        initialValue: initialValue,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          isDense: true,
          hintText: hint,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
        ),
        onChanged: onChanged,
      ),
    );
  }

  void _showFinishDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Finish Workout Session?'),
        content: const Text(
          'Your completed sets and training volume will be logged to your periodization history.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(workoutProvider.notifier).finishWorkoutSession();
              _confettiController.play();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('🔥 Workout complete! Excellent pelvic alignment and volume!'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
              Navigator.pop(context);
            },
            child: const Text('Complete Session'),
          ),
        ],
      ),
    );
  }
}
