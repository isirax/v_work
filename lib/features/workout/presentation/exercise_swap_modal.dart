import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/workout_provider.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/widgets/common/v_badge.dart';
import '../../../core/widgets/common/v_callout.dart';
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
    final palette = context.palette;
    final isDark = context.isDark;
    final activeAltId = exercise.activeAlternativeId;

    return Container(
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
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

          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(Insets.sm),
                decoration: BoxDecoration(
                  color: palette.accent.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.swap_horiz_rounded,
                  color: palette.accent,
                  size: 22,
                ),
              ),
              const SizedBox(width: Insets.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Swap Exercise Alternative',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Original: ${exercise.name}',
                      style: TextStyle(
                        fontSize: 12,
                        color: palette.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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

          // Revert to Baseline option if currently swapped
          if (exercise.isSwapped) ...[
            _buildOptionCard(
              context: context,
              palette: palette,
              isDark: isDark,
              badge: const VBadge(label: 'PRIMARY BASELINE', variant: VBadgeVariant.accent),
              title: 'Revert to Primary Baseline',
              subtitle: exercise.name,
              equipment: exercise.equipment,
              biomechanicalCue: exercise.biomechanicalCues,
              thumbnailPath: exercise.thumbnailPath,
              isSelected: activeAltId == null,
              onTap: () {
                ref.read(workoutProvider.notifier).swapExercise(
                      dayIndex: dayIndex,
                      exerciseId: exercise.id,
                      alternativeId: null,
                    );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Reverted to primary baseline: ${exercise.name}'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
            const SizedBox(height: Insets.sm),
          ],

          // List of Alternatives
          ...exercise.alternatives.asMap().entries.map((entry) {
            final index = entry.key;
            final alt = entry.value;
            final isSelected = alt.id == activeAltId;

            return Padding(
              padding: const EdgeInsets.only(bottom: Insets.sm),
              child: _buildOptionCard(
                context: context,
                palette: palette,
                isDark: isDark,
                badge: VBadge(
                  label: 'ALT ${index + 1}',
                  variant: isSelected ? VBadgeVariant.accent : VBadgeVariant.cyan,
                ),
                title: alt.name,
                subtitle: alt.description,
                equipment: alt.equipment,
                biomechanicalCue: alt.biomechanicalCue,
                thumbnailPath: alt.thumbnailPath,
                isSelected: isSelected,
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
    required AppPalette palette,
    required bool isDark,
    Widget? badge,
    required String title,
    required String subtitle,
    required String equipment,
    required String biomechanicalCue,
    String? thumbnailPath,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Radii.lg),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(Insets.md),
          decoration: BoxDecoration(
            color: isSelected
                ? palette.accent.withValues(alpha: isDark ? 0.12 : 0.08)
                : palette.surfaceElevated,
            borderRadius: BorderRadius.circular(Radii.lg),
            border: Border.all(
              color: isSelected ? palette.accent : palette.border,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (thumbnailPath != null && thumbnailPath.isNotEmpty) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(Radii.md),
                      child: Container(
                        width: 46,
                        height: 46,
                        color: isDark ? Colors.black38 : Colors.grey.shade200,
                        child: Image.asset(
                          thumbnailPath,
                          width: 46,
                          height: 46,
                          fit: BoxFit.cover,
                          errorBuilder: (ctx, err, st) => Icon(
                            Icons.fitness_center_rounded,
                            size: 20,
                            color: palette.accent,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: Insets.sm),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (badge != null) ...[
                          badge,
                          const SizedBox(height: 4),
                        ],
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: Insets.xs),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected ? palette.accent : Colors.transparent,
                      border: Border.all(
                        color: isSelected ? palette.accent : palette.textMuted.withValues(alpha: 0.4),
                        width: 1.5,
                      ),
                    ),
                    child: isSelected
                        ? Icon(
                            Icons.check_rounded,
                            size: 15,
                            color: palette.onAccent,
                          )
                        : null,
                  ),
                ],
              ),
              const SizedBox(height: Insets.xs),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12.5,
                  color: palette.textSecondary,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: Insets.xs),
              Wrap(
                spacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  VBadge(
                    label: equipment,
                    icon: Icons.fitness_center_outlined,
                    variant: VBadgeVariant.indigo,
                  ),
                ],
              ),
              const SizedBox(height: Insets.xs),
              VCallout(
                message: biomechanicalCue,
                icon: Icons.accessibility_new_rounded,
                variant: VCalloutVariant.info,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
