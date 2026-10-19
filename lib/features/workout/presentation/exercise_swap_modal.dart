import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/workout_provider.dart';
import '../models/exercise.dart';

class ExerciseSwapModal extends ConsumerWidget {
  final int dayIndex;
  final Exercise exercise;

  const ExerciseSwapModal({
    super.key,
    required this.dayIndex,
    required this.exercise,
  });

  static Future<void> show(BuildContext context, int dayIndex, Exercise exercise) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ExerciseSwapModal(
        dayIndex: dayIndex,
        exercise: exercise,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeAltId = exercise.activeAlternativeId;

    return Container(
      padding: const EdgeInsets.only(top: 12, left: 20, right: 20, bottom: 32),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(
          color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
          const SizedBox(height: 18),

          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primaryVolt.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.swap_horiz_rounded,
                  color: AppColors.primaryVolt,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Swap Exercise Alternative',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Original: ${exercise.name}',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
          const SizedBox(height: 20),

          // Revert to Baseline option if currently swapped
          if (exercise.isSwapped) ...[
            _buildOptionCard(
              context: context,
              title: 'Revert to Primary Baseline',
              subtitle: exercise.name,
              equipment: exercise.equipment,
              biomechanicalCue: exercise.biomechanicalCues,
              thumbnailPath: exercise.thumbnailPath,
              isSelected: activeAltId == null,
              isDark: isDark,
              onTap: () {
                ref.read(workoutProvider.notifier).swapExercise(
                      dayIndex: dayIndex,
                      exerciseId: exercise.id,
                      alternativeId: null,
                    );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Reverted to ${exercise.name}'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
          ],

          // List of Alternatives
          ...exercise.alternatives.asMap().entries.map((entry) {
            final index = entry.key;
            final alt = entry.value;
            final isSelected = alt.id == activeAltId;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildOptionCard(
                context: context,
                badge: 'ALTERNATIVE ${index + 1}',
                title: alt.name,
                subtitle: alt.description,
                equipment: alt.equipment,
                biomechanicalCue: alt.biomechanicalCue,
                thumbnailPath: alt.thumbnailPath,
                isSelected: isSelected,
                isDark: isDark,
                onTap: () {
                  ref.read(workoutProvider.notifier).swapExercise(
                        dayIndex: dayIndex,
                        exerciseId: exercise.id,
                        alternativeId: alt.id,
                      );
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Swapped to ${alt.name}'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildOptionCard({
    required BuildContext context,
    String? badge,
    required String title,
    required String subtitle,
    required String equipment,
    required String biomechanicalCue,
    String? thumbnailPath,
    required bool isSelected,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryVolt.withValues(alpha: isDark ? 0.15 : 0.12)
              : (isDark ? AppColors.darkCardElevated : AppColors.lightCardElevated),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryVolt
                : (isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (thumbnailPath != null && thumbnailPath.isNotEmpty) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 44,
                      height: 44,
                      color: isDark ? Colors.black45 : Colors.white60,
                      child: Image.asset(
                        thumbnailPath,
                        width: 44,
                        height: 44,
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, err, st) => const Icon(
                          Icons.fitness_center_rounded,
                          size: 20,
                          color: AppColors.primaryVolt,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (badge != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          margin: const EdgeInsets.only(bottom: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primaryCyan.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            badge,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryCyan,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  const Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.primaryVolt,
                    size: 20,
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.fitness_center_outlined, size: 13, color: AppColors.primaryIndigo),
                const SizedBox(width: 5),
                Text(
                  equipment,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryIndigo,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark ? const Color(0x33000000) : const Color(0x0A000000),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.accessibility_new_rounded, size: 14, color: AppColors.primaryVolt),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Cue: $biomechanicalCue',
                      style: TextStyle(
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
