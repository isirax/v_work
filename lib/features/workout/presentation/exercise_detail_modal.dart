import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/wger_anatomy_viewer.dart';
import '../../../core/widgets/workout_video_player.dart';
import '../models/exercise.dart';

class ExerciseDetailModal extends StatefulWidget {
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
  State<ExerciseDetailModal> createState() => _ExerciseDetailModalState();
}

class _ExerciseDetailModalState extends State<ExerciseDetailModal> {
  // 0: Offline 5s Loop / Vector Animation, 1: Online Full HD Video Stream/Cache
  int _mediaMode = 0;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final exercise = widget.exercise;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      padding: const EdgeInsets.only(top: 12, left: 20, right: 20, bottom: 32),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(
          color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Exercise Title & Muscle Target
            Row(
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
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.primaryVolt.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              exercise.targetMuscle,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryVolt,
                              ),
                            ),
                          ),
                          if (exercise.isSwapped) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.primaryOrange.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'SWAPPED ALT',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryOrange,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Segmented Media Player Controller (Quick Animation vs Detailed Video vs Muscle Anatomy)
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCardElevated : AppColors.lightCardElevated,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildSegmentButton(
                      label: 'Quick Demo',
                      icon: Icons.animation_rounded,
                      isSelected: _mediaMode == 0,
                      isDark: isDark,
                      onTap: () => setState(() => _mediaMode = 0),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: _buildSegmentButton(
                      label: 'Detailed Video',
                      icon: Icons.play_circle_fill_rounded,
                      isSelected: _mediaMode == 1,
                      isDark: isDark,
                      onTap: () => setState(() => _mediaMode = 1),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: _buildSegmentButton(
                      label: 'Anatomy',
                      icon: Icons.accessibility_new_rounded,
                      isSelected: _mediaMode == 2,
                      isDark: isDark,
                      onTap: () => setState(() => _mediaMode = 2),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

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
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCardElevated : AppColors.lightCardElevated,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.primaryVolt.withValues(alpha: 0.25),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded, size: 16, color: AppColors.primaryVolt),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Continuous animation concept loop. Watch full tutorial video for detailed coaching.',
                        style: TextStyle(fontSize: 11, color: Colors.white70),
                      ),
                    ),
                    const SizedBox(width: 6),
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        foregroundColor: AppColors.primaryVolt,
                      ),
                      onPressed: () => setState(() => _mediaMode = 1),
                      icon: const Icon(Icons.play_circle_filled_rounded, size: 14),
                      label: const Text('Play Video', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ] else if (_mediaMode == 1) ...[
              WorkoutVideoPlayer(
                key: ValueKey('video_${exercise.id}_${exercise.activeAlternativeId}'),
                assetVideoPath: exercise.activeAssetVideoPath,
                onlineVideoUrl: exercise.activeOnlineHdVideoUrl,
                exerciseTitle: exercise.activeName,
                isOnline: false,
                height: 220,
              ),
            ] else
              WgerAnatomyViewer(
                exerciseKey: exercise.illustrationKey,
                exerciseName: exercise.activeName,
                animationPath: exercise.activeAssetAnimationPath,
                targetMuscle: exercise.targetMuscle,
                height: 260,
              ),
            const SizedBox(height: 18),

            // Prescribed Parameters (Sets x Reps, RIR, Rest)
            Row(
              children: [
                _buildParameterBox(
                  label: 'TARGET SETS',
                  value: '${exercise.defaultSets} Sets',
                  icon: Icons.format_list_numbered_rounded,
                  isDark: isDark,
                ),
                const SizedBox(width: 10),
                _buildParameterBox(
                  label: 'REPS',
                  value: exercise.defaultReps,
                  icon: Icons.repeat_rounded,
                  isDark: isDark,
                ),
                const SizedBox(width: 10),
                _buildParameterBox(
                  label: 'RIR',
                  value: exercise.defaultRir,
                  icon: Icons.speed_rounded,
                  isDark: isDark,
                ),
                const SizedBox(width: 10),
                _buildParameterBox(
                  label: 'REST',
                  value: '${exercise.defaultRestSeconds}s',
                  icon: Icons.timer_outlined,
                  isDark: isDark,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // APT Biomechanical Cues Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCardElevated : AppColors.lightCardElevated,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.primaryVolt.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.shield_outlined, color: AppColors.primaryVolt, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'APT BIOMECHANICAL & POSTURE CUES',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryVolt,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    exercise.activeBiomechanicalCue,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Equipment Info
            Row(
              children: [
                const Icon(Icons.fitness_center_rounded, size: 16, color: AppColors.primaryIndigo),
                const SizedBox(width: 8),
                Text(
                  'Equipment: ${exercise.equipment}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSegmentButton({
    required String label,
    required IconData icon,
    required bool isSelected,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(9),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AppColors.primaryVolt : const Color(0xFF00C875))
              : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 15,
              color: isSelected
                  ? (isDark ? Colors.black : Colors.white)
                  : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isSelected
                    ? (isDark ? Colors.black : Colors.white)
                    : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParameterBox({
    required String label,
    required String value,
    required IconData icon,
    required bool isDark,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCardElevated : AppColors.lightCardElevated,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 16, color: AppColors.primaryCyan),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
