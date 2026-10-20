import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/workout_provider.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/utils/youtube_launcher.dart';
import '../../../core/widgets/common/v_badge.dart';
import '../../../core/widgets/common/v_callout.dart';
import '../../../core/widgets/common/v_segment_control.dart';
import '../../../core/widgets/wger_anatomy_viewer.dart';
import '../../../core/widgets/workout_video_player.dart';
import '../models/exercise.dart';
import 'exercise_swap_modal.dart';

class ExerciseDetailModal extends ConsumerStatefulWidget {
  final Exercise exercise;
  final int dayIndex;

  const ExerciseDetailModal({
    super.key,
    required this.exercise,
    required this.dayIndex,
  });

  static Future<void> show(BuildContext context, Exercise exercise, int dayIndex) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ExerciseDetailModal(
        exercise: exercise,
        dayIndex: dayIndex,
      ),
    );
  }

  @override
  ConsumerState<ExerciseDetailModal> createState() => _ExerciseDetailModalState();
}

class _ExerciseDetailModalState extends ConsumerState<ExerciseDetailModal> {
  // 0: Offline 5s Loop / Vector Animation, 1: Full Video Guide / Online, 2: Anatomy
  int _mediaMode = 0;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final isDark = context.isDark;

    // Reactively watch workoutProvider so that swapping immediately updates this modal
    final workoutState = ref.watch(workoutProvider);
    Exercise exercise = widget.exercise;
    if (widget.dayIndex >= 0 && widget.dayIndex < workoutState.split.length) {
      final day = workoutState.split[widget.dayIndex];
      exercise = day.exercises.firstWhere(
        (e) => e.id == widget.exercise.id,
        orElse: () => widget.exercise,
      );
    }

    final hasLocalVideo = exercise.hasDownloadedVideo;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.92,
      ),
      padding: const EdgeInsets.only(top: Insets.sm, left: Insets.lg, right: Insets.lg, bottom: Insets.xl),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(Radii.xl)),
        border: Border.all(
          color: palette.border,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.1),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: palette.textMuted.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: Insets.md),

            // Exercise Title & Muscle Target & Actions
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exercise.activeName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: Insets.xs),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          VBadge(
                            label: exercise.activeTargetMuscle.toUpperCase(),
                            variant: VBadgeVariant.accent,
                          ),
                          if (exercise.isSwapped)
                            const VBadge(
                              label: 'SWAPPED ALT',
                              variant: VBadgeVariant.orange,
                            ),
                          VBadge(
                            label: exercise.activeEquipment,
                            icon: Icons.fitness_center_rounded,
                            variant: VBadgeVariant.indigo,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // Swap Button directly in modal
                OutlinedButton.icon(
                  onPressed: () => ExerciseSwapModal.show(context, widget.dayIndex, exercise),
                  icon: const Icon(Icons.swap_horiz_rounded, size: 16),
                  label: Text(
                    exercise.isSwapped ? 'Alt Swapped' : 'Swap',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                  style: OutlinedButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    foregroundColor: exercise.isSwapped ? palette.orange : palette.textPrimary,
                    side: BorderSide(
                      color: exercise.isSwapped ? palette.orange : palette.border,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.md)),
                  ),
                ),
                const SizedBox(width: 4),

                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close_rounded, color: palette.textSecondary, size: 20),
                  style: IconButton.styleFrom(
                    backgroundColor: palette.surfaceElevated,
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(Insets.xs),
                  ),
                ),
              ],
            ),
            const SizedBox(height: Insets.md),

            // Segmented Media Player Controller (Quick Demo vs Detailed Video vs Muscle Anatomy)
            VSegmentControl<int>(
              selectedValue: _mediaMode,
              onSelected: (mode) => setState(() => _mediaMode = mode),
              items: [
                const VSegmentItem(
                  value: 0,
                  label: 'Quick Demo',
                  icon: Icons.animation_rounded,
                ),
                VSegmentItem(
                  value: 1,
                  label: hasLocalVideo ? 'Video Guide' : 'Full Video',
                  icon: Icons.play_circle_fill_rounded,
                ),
                const VSegmentItem(
                  value: 2,
                  label: 'Anatomy',
                  icon: Icons.accessibility_new_rounded,
                ),
              ],
            ),
            const SizedBox(height: Insets.md),

            // Media Display Container
            if (_mediaMode == 0) ...[
              WorkoutVideoPlayer(
                key: ValueKey('anim_${exercise.id}_${exercise.activeAlternativeId}'),
                assetVideoPath: exercise.activeAssetAnimationPath,
                onlineVideoUrl: exercise.activeOnlineHdVideoUrl,
                exerciseTitle: exercise.activeName,
                isOnline: false,
                height: 220,
              ),
              const SizedBox(height: Insets.sm),
              VCallout(
                message: 'Continuous visual loop for quick reference. Switch to "Video Guide" for breakdown.',
                icon: Icons.info_outline_rounded,
                variant: VCalloutVariant.accent,
                trailing: TextButton.icon(
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: Insets.xs, vertical: 2),
                    foregroundColor: palette.accent,
                  ),
                  onPressed: () => setState(() => _mediaMode = 1),
                  icon: const Icon(Icons.play_circle_filled_rounded, size: 14),
                  label: const Text('Play Video', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ),
            ] else if (_mediaMode == 1) ...[
              WorkoutVideoPlayer(
                key: ValueKey('video_${exercise.id}_${exercise.activeAlternativeId}_$hasLocalVideo'),
                assetVideoPath: exercise.activeAssetVideoPath,
                onlineVideoUrl: exercise.activeOnlineHdVideoUrl,
                exerciseTitle: exercise.activeName,
                isOnline: !hasLocalVideo,
                height: 220,
              ),
              const SizedBox(height: Insets.sm),
              _buildYouTubeBar(context, palette, exercise),
            ] else
              WgerAnatomyViewer(
                exerciseKey: exercise.illustrationKey,
                exerciseName: exercise.activeName,
                animationPath: exercise.activeAssetAnimationPath,
                targetMuscle: exercise.activeTargetMuscle,
                height: 260,
              ),
            const SizedBox(height: Insets.md),

            // Prescribed Parameters (Sets x Reps, RIR, Rest)
            Row(
              children: [
                _buildParameterBox(
                  palette: palette,
                  label: 'TARGET SETS',
                  value: '${exercise.defaultSets} Sets',
                  icon: Icons.format_list_numbered_rounded,
                ),
                const SizedBox(width: Insets.xs),
                _buildParameterBox(
                  palette: palette,
                  label: 'REPS',
                  value: exercise.defaultReps,
                  icon: Icons.repeat_rounded,
                ),
                const SizedBox(width: Insets.xs),
                _buildParameterBox(
                  palette: palette,
                  label: 'RIR',
                  value: exercise.defaultRir,
                  icon: Icons.speed_rounded,
                ),
                const SizedBox(width: Insets.xs),
                _buildParameterBox(
                  palette: palette,
                  label: 'REST',
                  value: '${exercise.defaultRestSeconds}s',
                  icon: Icons.timer_outlined,
                ),
              ],
            ),
            const SizedBox(height: Insets.md),

            // APT Biomechanical Cues Card
            VCallout(
              title: 'APT BIOMECHANICAL & POSTURE CUES',
              message: exercise.activeBiomechanicalCue,
              icon: Icons.shield_outlined,
              variant: VCalloutVariant.accent,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildYouTubeBar(BuildContext context, AppPalette palette, Exercise exercise) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Insets.md, vertical: 8),
      decoration: BoxDecoration(
        color: palette.surfaceElevated,
        borderRadius: BorderRadius.circular(Radii.md),
        border: Border.all(color: palette.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFFFF0000).withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.smart_display_rounded, color: Color(0xFFFF0000), size: 18),
          ),
          const SizedBox(width: Insets.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Watch Full Tutorial Online',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: palette.textPrimary,
                  ),
                ),
                Text(
                  'Search video on YouTube for ${exercise.activeName}',
                  style: TextStyle(
                    fontSize: 11,
                    color: palette.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF0000),
              foregroundColor: Colors.white,
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.sm)),
            ),
            onPressed: () => YouTubeLauncher.launchExerciseTutorial(exercise.activeName),
            icon: const Icon(Icons.open_in_new_rounded, size: 13),
            label: const Text('YouTube', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildParameterBox({
    required AppPalette palette,
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: Insets.sm, horizontal: Insets.xs),
        decoration: BoxDecoration(
          color: palette.surfaceElevated,
          borderRadius: BorderRadius.circular(Radii.md),
          border: Border.all(
            color: palette.border,
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 16, color: palette.accent),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: palette.textMuted,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
