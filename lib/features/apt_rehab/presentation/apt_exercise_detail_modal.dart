import 'package:flutter/material.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/utils/youtube_launcher.dart';
import '../../../core/widgets/common/v_badge.dart';
import '../../../core/widgets/common/v_callout.dart';
import '../../../core/widgets/common/v_segment_control.dart';
import '../../../core/widgets/workout_video_player.dart';
import '../models/apt_exercise.dart';

class AptExerciseDetailModal extends StatefulWidget {
  final AptExercise exercise;
  final VoidCallback? onStartDrill;

  const AptExerciseDetailModal({
    super.key,
    required this.exercise,
    this.onStartDrill,
  });

  static Future<void> show(
    BuildContext context,
    AptExercise exercise, {
    VoidCallback? onStartDrill,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AptExerciseDetailModal(
        exercise: exercise,
        onStartDrill: onStartDrill,
      ),
    );
  }

  @override
  State<AptExerciseDetailModal> createState() => _AptExerciseDetailModalState();
}

class _AptExerciseDetailModalState extends State<AptExerciseDetailModal> {
  // 0: Quick Demo (GIF loop), 1: Video Guide (Detailed MP4), 2: Form Checkpoints
  int _mediaMode = 0;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final isDark = context.isDark;
    final exercise = widget.exercise;
    final hasLocalVideo = exercise.hasDownloadedVideo;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.92,
      ),
      padding: const EdgeInsets.only(
        top: Insets.sm,
        left: Insets.lg,
        right: Insets.lg,
        bottom: Insets.xl,
      ),
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

            // Header: Title & Target Muscles & Close
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exercise.title,
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
                          const VBadge(
                            label: 'APT CORRECTIVE',
                            variant: VBadgeVariant.accent,
                          ),
                          VBadge(
                            label: exercise.isTimed ? 'TIMED INTERVAL' : 'REP TEMPO',
                            icon: exercise.isTimed ? Icons.timer_outlined : Icons.repeat_rounded,
                            variant: VBadgeVariant.indigo,
                          ),
                          VBadge(
                            label: hasLocalVideo ? 'OFFLINE HD VIDEO' : 'HD ANIMATION',
                            icon: hasLocalVideo ? Icons.check_circle_outline_rounded : Icons.animation_rounded,
                            variant: hasLocalVideo ? VBadgeVariant.success : VBadgeVariant.cyan,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
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

            // Segmented Media Control
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
                  label: 'Technique Cues',
                  icon: Icons.checklist_rounded,
                ),
              ],
            ),
            const SizedBox(height: Insets.md),

            // Media Container
            if (_mediaMode == 0) ...[
              WorkoutVideoPlayer(
                key: ValueKey('apt_anim_${exercise.id}'),
                assetVideoPath: exercise.assetAnimationPath,
                onlineVideoUrl: exercise.onlineHdVideoUrl ?? exercise.assetAnimationPath,
                exerciseTitle: exercise.title,
                isOnline: false,
                height: 220,
              ),
              const SizedBox(height: Insets.sm),
              VCallout(
                message: 'Continuous movement loop. Switch to "Video Guide" for detailed voice breakdown.',
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
                key: ValueKey('apt_vid_${exercise.id}_$hasLocalVideo'),
                assetVideoPath: exercise.assetVideoPath,
                onlineVideoUrl: exercise.onlineHdVideoUrl ?? exercise.assetVideoPath,
                exerciseTitle: exercise.title,
                isOnline: !hasLocalVideo,
                height: 220,
              ),
              const SizedBox(height: Insets.sm),
              _buildYouTubeBar(context, palette, exercise),
            ] else ...[
              // Technique checkpoints view
              Container(
                padding: const EdgeInsets.all(Insets.md),
                decoration: BoxDecoration(
                  color: palette.surfaceElevated,
                  borderRadius: BorderRadius.circular(Radii.lg),
                  border: Border.all(color: palette.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.checklist_rounded, color: palette.accent, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'MANDATORY FORM CHECKPOINTS',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                            color: palette.accent,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: Insets.sm),
                    ...exercise.executionCues.asMap().entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${entry.key + 1}. ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: palette.accent,
                                fontSize: 13,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                entry.value,
                                style: TextStyle(
                                  fontSize: 13,
                                  height: 1.4,
                                  color: palette.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: Insets.md),
                    VCallout(
                      variant: VCalloutVariant.danger,
                      icon: Icons.warning_amber_rounded,
                      message: 'Common Flaw: ${exercise.commonMistake}',
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: Insets.md),

            // Target Parameters Row
            Row(
              children: [
                _buildParameterBox(
                  palette: palette,
                  label: 'SETS',
                  value: '${exercise.sets} Sets',
                  icon: Icons.format_list_numbered_rounded,
                ),
                const SizedBox(width: Insets.xs),
                _buildParameterBox(
                  palette: palette,
                  label: exercise.isTimed ? 'INTERVAL' : 'REPS',
                  value: exercise.repsOrDuration,
                  icon: exercise.isTimed ? Icons.timer_outlined : Icons.repeat_rounded,
                ),
                const SizedBox(width: Insets.xs),
                _buildParameterBox(
                  palette: palette,
                  label: 'DURATION',
                  value: '${exercise.durationSeconds}s',
                  icon: Icons.hourglass_top_rounded,
                ),
              ],
            ),
            const SizedBox(height: Insets.md),

            // Target Muscles Banner
            Container(
              padding: const EdgeInsets.all(Insets.md),
              decoration: BoxDecoration(
                color: palette.surfaceElevated,
                borderRadius: BorderRadius.circular(Radii.md),
                border: Border.all(color: palette.border),
              ),
              child: Row(
                children: [
                  Icon(Icons.accessibility_new_rounded, size: 20, color: palette.accent),
                  const SizedBox(width: Insets.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'TARGET MUSCLES & STABILIZERS',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: palette.accent,
                            letterSpacing: 0.4,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          exercise.targetMuscles,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: palette.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: Insets.md),

            // Clinical Purpose Callout
            VCallout(
              title: 'BIOMECHANICAL PURPOSE',
              message: exercise.biomechanicalPurpose,
              icon: Icons.shield_outlined,
              variant: VCalloutVariant.accent,
            ),
            const SizedBox(height: Insets.lg),

            // Action Buttons: YouTube & Start Timer
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: const BorderSide(color: Color(0xFFFF0000)),
                      foregroundColor: const Color(0xFFFF0000),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(Radii.md),
                      ),
                    ),
                    onPressed: () => YouTubeLauncher.launchExerciseTutorial(exercise.title),
                    icon: const Icon(Icons.smart_display_rounded, size: 18),
                    label: const Text(
                      'Search YouTube',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                ),
                if (widget.onStartDrill != null) ...[
                  const SizedBox(width: Insets.md),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: palette.accent,
                        foregroundColor: palette.onAccent,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(Radii.md),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        widget.onStartDrill!();
                      },
                      icon: const Icon(Icons.play_arrow_rounded, size: 20),
                      label: const Text(
                        'Start Drill Timer',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildYouTubeBar(BuildContext context, AppPalette palette, AptExercise exercise) {
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
                  'Watch Form Breakdown Online',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: palette.textPrimary,
                  ),
                ),
                Text(
                  'Search tutorials & clinical cues on YouTube',
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
            onPressed: () => YouTubeLauncher.launchExerciseTutorial(exercise.title),
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
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.2,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
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
