import 'package:flutter/material.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/utils/youtube_launcher.dart';
import '../../../core/widgets/common/v_badge.dart';
import '../../../core/widgets/common/v_callout.dart';
import '../data/apt_database.dart';
import '../models/apt_exercise.dart';
import 'apt_exercise_detail_modal.dart';
import 'apt_guided_session_sheet.dart';

class AptRoutineScreen extends StatelessWidget {
  const AptRoutineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final routine = AptDatabase.routine;

    return Scaffold(
      appBar: AppBar(
        title: const Text('APT Rehab Protocol'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: Insets.sm),
            child: TextButton.icon(
              style: TextButton.styleFrom(
                foregroundColor: palette.accent,
                visualDensity: VisualDensity.compact,
              ),
              onPressed: () => AptGuidedSessionSheet.show(context),
              icon: const Icon(Icons.timer_rounded, size: 18),
              label: const Text('Guided Routine', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: Insets.lg, vertical: Insets.xs),
        children: [
          // Clinical Protocol Overview Card
          Card(
            margin: const EdgeInsets.only(bottom: Insets.md),
            child: Padding(
              padding: const EdgeInsets.all(Insets.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(Insets.xs),
                        decoration: BoxDecoration(
                          color: palette.accent.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.shield_rounded, color: palette.accent, size: 20),
                      ),
                      const SizedBox(width: Insets.sm),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Anterior Pelvic Tilt Correction',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '10-Minute Pre-Workout Clinical Protocol',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const VBadge(
                        label: '4 DRILLS',
                        variant: VBadgeVariant.accent,
                        fontSize: 10,
                      ),
                    ],
                  ),
                  const Divider(height: 22),
                  const VCallout(
                    title: 'BIOMECHANICAL PURPOSE',
                    message:
                        'Inhibits hyperactive hip flexors (psoas) & tight lumbar erectors while activating dormant glutes & transverse abdominis before loaded training.',
                    icon: Icons.health_and_safety_rounded,
                    variant: VCalloutVariant.accent,
                  ),
                  const SizedBox(height: Insets.md),

                  // Start Guided Routine CTA
                  FilledButton.icon(
                    onPressed: () => AptGuidedSessionSheet.show(context),
                    icon: const Icon(Icons.play_arrow_rounded, size: 22),
                    label: const Text(
                      'Start Guided Routine (Timer)',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: palette.accent,
                      foregroundColor: palette.onAccent,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      minimumSize: const Size.fromHeight(46),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(Radii.md),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Prescribed Drills Section Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'PRESCRIBED DRILLS (${routine.length})',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.8,
                  color: palette.accent,
                ),
              ),
              Text(
                'Tap for Video & Details',
                style: TextStyle(fontSize: 11, color: palette.textMuted),
              ),
            ],
          ),
          const SizedBox(height: Insets.sm),

          // Exercise Cards List (Just like Workouts Split)
          ...routine.asMap().entries.map((entry) {
            final index = entry.key;
            final exercise = entry.value;

            return _AptExerciseCard(
              index: index + 1,
              exercise: exercise,
              onStartDrill: () => AptGuidedSessionSheet.show(context, initialIndex: index),
            );
          }),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}

class _AptExerciseCard extends StatelessWidget {
  final int index;
  final AptExercise exercise;
  final VoidCallback onStartDrill;

  const _AptExerciseCard({
    required this.index,
    required this.exercise,
    required this.onStartDrill,
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
            // Top Row: Number, Name, Target
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exercise.title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        exercise.targetMuscles,
                        style: TextStyle(
                          fontSize: 12,
                          color: palette.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                VBadge(
                  label: exercise.isTimed ? 'TIMED' : 'REPS',
                  variant: exercise.isTimed ? VBadgeVariant.indigo : VBadgeVariant.cyan,
                  fontSize: 9,
                ),
              ],
            ),
            const SizedBox(height: Insets.md),

            // Video & Animation Preview Surface
            InkWell(
              onTap: () => AptExerciseDetailModal.show(
                context,
                exercise,
                onStartDrill: onStartDrill,
              ),
              borderRadius: BorderRadius.circular(Radii.lg),
              child: Stack(
                children: [
                  Container(
                    height: 125,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0F141F) : const Color(0xFFEDF2F7),
                      borderRadius: BorderRadius.circular(Radii.lg),
                      border: Border.all(color: palette.border),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(Radii.lg),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Image.asset(
                            exercise.resolvedThumbnailPath,
                            fit: BoxFit.contain,
                            height: 125,
                            width: double.infinity,
                            errorBuilder: (ctx, err, st) => Image.asset(
                              exercise.assetAnimationPath,
                              fit: BoxFit.contain,
                              height: 125,
                              width: double.infinity,
                              errorBuilder: (c, e, s) => Center(
                                child: Icon(Icons.shield_outlined, size: 40, color: palette.accent),
                              ),
                            ),
                          ),
                          // Subtle dark overlay with play icon
                          Container(
                            color: Colors.black.withValues(alpha: 0.18),
                            child: Center(
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.65),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: palette.accent, width: 1.5),
                                ),
                                child: Icon(
                                  Icons.play_arrow_rounded,
                                  color: palette.accent,
                                  size: 26,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Media Badge
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
                  label: '${exercise.sets} Sets',
                  icon: Icons.format_list_numbered,
                  variant: VBadgeVariant.cyan,
                  fontSize: 10,
                ),
                VBadge(
                  label: exercise.repsOrDuration,
                  icon: exercise.isTimed ? Icons.timer_outlined : Icons.repeat,
                  variant: VBadgeVariant.cyan,
                  fontSize: 10,
                ),
                VBadge(
                  label: '${exercise.durationSeconds}s Hold',
                  icon: Icons.hourglass_top_rounded,
                  variant: VBadgeVariant.cyan,
                  fontSize: 10,
                ),
              ],
            ),
            const SizedBox(height: Insets.sm),

            // Biomechanical Purpose Callout
            VCallout(
              message: exercise.biomechanicalPurpose,
              icon: Icons.shield_outlined,
              variant: VCalloutVariant.accent,
              padding: const EdgeInsets.all(8),
            ),
            const SizedBox(height: Insets.sm),

            // Actions Row: YouTube, Form & Video, Start Drill
            Row(
              children: [
                // Option to check on YouTube online
                OutlinedButton.icon(
                  onPressed: () => YouTubeLauncher.launchExerciseTutorial(exercise.title),
                  icon: const Icon(Icons.smart_display_rounded, size: 16, color: Color(0xFFFF0000)),
                  label: const Text(
                    'YouTube',
                    style: TextStyle(fontSize: 12, color: Color(0xFFFF0000), fontWeight: FontWeight.bold),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFFF0000), width: 1),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    visualDensity: VisualDensity.compact,
                  ),
                ),
                const Spacer(),

                // Form & Video Detail
                ElevatedButton.icon(
                  onPressed: () => AptExerciseDetailModal.show(
                    context,
                    exercise,
                    onStartDrill: onStartDrill,
                  ),
                  icon: const Icon(Icons.play_circle_outline_rounded, size: 16),
                  label: const Text('Form & Video', style: TextStyle(fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: palette.surfaceElevated,
                    foregroundColor: palette.textPrimary,
                    side: BorderSide(color: palette.border),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    visualDensity: VisualDensity.compact,
                  ),
                ),
                const SizedBox(width: 8),

                // Start Single Drill
                FilledButton.icon(
                  onPressed: onStartDrill,
                  icon: const Icon(Icons.timer_outlined, size: 16),
                  label: const Text('Timer', style: TextStyle(fontSize: 12)),
                  style: FilledButton.styleFrom(
                    backgroundColor: palette.accent,
                    foregroundColor: palette.onAccent,
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
