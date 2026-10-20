import 'dart:async';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/workout_provider.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/utils/youtube_launcher.dart';
import '../../../core/widgets/common/v_badge.dart';
import '../../../core/widgets/common/v_callout.dart';
import '../../../core/widgets/common/v_checkbox.dart';
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
  late final Stopwatch _sessionStopwatch;
  Timer? _elapsedTimer;
  int _elapsedMinutes = 0;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _sessionStopwatch = Stopwatch()..start();
    _elapsedTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) {
        setState(() {
          _elapsedMinutes = _sessionStopwatch.elapsed.inMinutes;
        });
      }
    });
  }

  @override
  void dispose() {
    _elapsedTimer?.cancel();
    _sessionStopwatch.stop();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final day = ref.watch(workoutProvider.select((s) => s.selectedDay));
    final currentPhase = ref.watch(workoutProvider.select((s) => s.currentPhase));
    final currentWeek = ref.watch(workoutProvider.select((s) => s.currentWeek));
    final dayIndex = ref.watch(workoutProvider.select((s) => s.selectedDayIndex));
    final palette = context.palette;

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
              'Phase ${currentPhase.phaseNumber} • Week $currentWeek • ${_elapsedMinutes}m elapsed',
              style: TextStyle(
                fontSize: 11,
                color: palette.accent,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilledButton.tonalIcon(
              onPressed: () => _showFinishDialog(context),
              icon: const Icon(Icons.check_circle_rounded, size: 18),
              label: const Text('Finish', style: TextStyle(fontWeight: FontWeight.bold)),
              style: FilledButton.styleFrom(
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(horizontal: 12),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Mandatory APT Alignment Banner
              Padding(
                padding: const EdgeInsets.fromLTRB(Insets.lg, Insets.sm, Insets.lg, Insets.xs),
                child: VCallout(
                  title: 'BIOMECHANICAL FOCUS',
                  message: day.biomechanicalFocus,
                  icon: Icons.shield_outlined,
                  variant: VCalloutVariant.accent,
                ),
              ),

              // Exercises List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.only(
                    left: Insets.lg,
                    right: Insets.lg,
                    top: Insets.sm,
                    bottom: 100,
                  ),
                  itemCount: day.exercises.length,
                  itemBuilder: (context, exIndex) {
                    final exercise = day.exercises[exIndex];
                    return _ActiveExerciseCard(
                      key: ValueKey('active_ex_${exercise.id}_${exercise.activeAlternativeId}'),
                      exercise: exercise,
                      dayIndex: dayIndex,
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
              colors: [
                palette.accent,
                palette.teal,
                palette.orange,
                palette.indigo,
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showFinishDialog(BuildContext context) {
    final workout = ref.read(workoutProvider);
    int totalCompleted = 0;
    double volume = 0;
    for (final sets in workout.activeSessionSets.values) {
      for (final s in sets) {
        if (s.isCompleted) {
          totalCompleted++;
          volume += (s.weightKg * s.reps);
        }
      }
    }

    final palette = context.palette;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.sports_score_rounded, color: Colors.amber, size: 26),
            SizedBox(width: 10),
            Text('Complete Workout?'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Session Summary:',
              style: TextStyle(fontWeight: FontWeight.bold, color: palette.textPrimary),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(Insets.md),
              decoration: BoxDecoration(
                color: palette.surfaceSunken,
                borderRadius: BorderRadius.circular(Radii.md),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _SummaryStat(label: 'Sets Done', value: '$totalCompleted'),
                  _SummaryStat(label: 'Volume', value: '${volume.toInt()} kg'),
                  _SummaryStat(label: 'Duration', value: '${_elapsedMinutes}m'),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Your completed sets will be recorded in periodization history.',
              style: TextStyle(fontSize: 12, color: palette.textSecondary),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Keep Training'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(workoutProvider.notifier).finishWorkoutSession();
              _confettiController.play();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('🔥 Workout completed and logged to history!'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
              Navigator.pop(context);
            },
            child: const Text('Log & Finish'),
          ),
        ],
      ),
    );
  }
}

class _SummaryStat extends StatelessWidget {
  final String label;
  final String value;
  const _SummaryStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: palette.accent,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: palette.textMuted),
        ),
      ],
    );
  }
}

class _ActiveExerciseCard extends ConsumerWidget {
  final Exercise exercise;
  final int dayIndex;

  const _ActiveExerciseCard({
    super.key,
    required this.exercise,
    required this.dayIndex,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Only listen to this specific exercise's sets!
    final sets = ref.watch(
      workoutProvider.select((s) => s.activeSessionSets[exercise.id] ?? const <WorkoutSet>[]),
    );
    final palette = context.palette;

    final completedCount = sets.where((s) => s.isCompleted).length;

    return Card(
      margin: const EdgeInsets.only(bottom: Insets.md),
      child: Padding(
        padding: const EdgeInsets.all(Insets.lg),
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
                      borderRadius: BorderRadius.circular(Radii.md),
                      child: Container(
                        width: 48,
                        height: 48,
                        color: palette.surfaceSunken,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Image.asset(
                              exercise.activeThumbnailPath,
                              width: 48,
                              height: 48,
                              fit: BoxFit.cover,
                              errorBuilder: (ctx, err, st) => Icon(
                                Icons.fitness_center_rounded,
                                size: 22,
                                color: palette.accent,
                              ),
                            ),
                            Container(
                              color: Colors.black26,
                              child: const Icon(
                                Icons.play_arrow_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: Insets.md),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              exercise.activeName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (exercise.isSwapped) ...[
                            const SizedBox(width: 6),
                            const VBadge(
                              label: 'SWAPPED',
                              variant: VBadgeVariant.orange,
                              fontSize: 9,
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${exercise.targetMuscle} • ${exercise.defaultRir} • $completedCount/${sets.length} done',
                        style: TextStyle(
                          fontSize: 12,
                          color: palette.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Tutorial & Form Cues',
                  icon: Icon(Icons.play_circle_fill_rounded, color: palette.accent, size: 24),
                  onPressed: () => ExerciseDetailModal.show(context, exercise, dayIndex),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert_rounded),
                  onSelected: (value) {
                    if (value == 'swap') {
                      ExerciseSwapModal.show(context, dayIndex, exercise);
                    } else if (value == 'detail') {
                      ExerciseDetailModal.show(context, exercise, dayIndex);
                    } else if (value == 'youtube') {
                      YouTubeLauncher.launchExerciseTutorial(exercise.activeName);
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                      value: 'swap',
                      child: Row(
                        children: [
                          Icon(Icons.swap_horiz_rounded, size: 18),
                          SizedBox(width: 8),
                          Text('Swap Alternative'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'detail',
                      child: Row(
                        children: [
                          Icon(Icons.info_outline_rounded, size: 18),
                          SizedBox(width: 8),
                          Text('Form Cues & Anatomy'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'youtube',
                      child: Row(
                        children: [
                          Icon(Icons.smart_display_rounded, size: 18, color: Color(0xFFFF0000)),
                          SizedBox(width: 8),
                          Text('Search on YouTube'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: Insets.sm),

            // APT Biomechanical Note
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: palette.surfaceSunken,
                borderRadius: BorderRadius.circular(Radii.sm),
              ),
              child: Row(
                children: [
                  Icon(Icons.shield_outlined, size: 14, color: palette.accent),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      exercise.activeBiomechanicalCue,
                      style: TextStyle(
                        fontSize: 11,
                        color: palette.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: Insets.md),

            // Sets Table Header
            Row(
              children: [
                _buildHeader('SET', 36, palette),
                _buildHeader('KG', 72, palette),
                const SizedBox(width: 8),
                _buildHeader('REPS', 60, palette),
                const SizedBox(width: 8),
                _buildHeader('RIR', 48, palette),
                const Spacer(),
                _buildHeader('DONE', 48, palette),
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
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                          color: set.isCompleted ? palette.accent : palette.textPrimary,
                        ),
                      ),
                    ),

                    // Weight Input
                    SizedBox(
                      width: 72,
                      child: _InlineNumberInput(
                        key: ValueKey('weight_${exercise.id}_$setIndex'),
                        initialValue: set.weightKg > 0 ? set.weightKg.toStringAsFixed(1) : '',
                        hint: '0.0',
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
                      width: 60,
                      child: _InlineNumberInput(
                        key: ValueKey('reps_${exercise.id}_$setIndex'),
                        initialValue: set.reps.toString(),
                        hint: '10',
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
                      width: 48,
                      child: _InlineNumberInput(
                        key: ValueKey('rir_${exercise.id}_$setIndex'),
                        initialValue: set.rir.toString(),
                        hint: '2',
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
                    VCheckbox(
                      isChecked: set.isCompleted,
                      size: 36,
                      activeColor: palette.accent,
                      checkColor: palette.onAccent,
                      onChanged: (_) {
                        ref.read(workoutProvider.notifier).toggleSetCompleted(
                              exercise.id,
                              setIndex,
                              exercise.defaultRestSeconds,
                            );
                      },
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: Insets.xs),
            // Add Set button
            Center(
              child: TextButton.icon(
                onPressed: () => ref.read(workoutProvider.notifier).addSet(exercise.id),
                icon: const Icon(Icons.add_rounded, size: 16),
                label: const Text('Add Set', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(String text, double width, AppPalette palette) {
    return SizedBox(
      width: width,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
          color: palette.teal,
        ),
      ),
    );
  }
}

class _InlineNumberInput extends StatelessWidget {
  final String initialValue;
  final String hint;
  final ValueChanged<String> onChanged;

  const _InlineNumberInput({
    super.key,
    required this.initialValue,
    required this.hint,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: palette.surfaceSunken,
        borderRadius: BorderRadius.circular(Radii.sm),
        border: Border.all(color: palette.border),
      ),
      child: TextFormField(
        initialValue: initialValue,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w800,
          color: palette.textPrimary,
        ),
        decoration: InputDecoration(
          isDense: true,
          hintText: hint,
          hintStyle: TextStyle(color: palette.textMuted, fontSize: 12),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
        ),
        onChanged: onChanged,
      ),
    );
  }
}
