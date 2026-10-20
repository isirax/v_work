import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/supplement_provider.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/widgets/common/v_badge.dart';
import '../../../core/widgets/common/v_callout.dart';
import '../../../core/widgets/common/v_checkbox.dart';
import '../../../core/widgets/common/v_progress_ring.dart';
import '../../../core/widgets/common/v_segment_control.dart';
import '../models/supplement_item.dart';

class SupplementScreen extends ConsumerWidget {
  const SupplementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final supplementState = ref.watch(supplementProvider);
    final palette = context.palette;
    final activeMulti = supplementState.activeMultivitamin;

    final completedCount = supplementState.items.where((i) => i.isCompleted).length;
    final totalCount = supplementState.items.length;
    final adherenceProgress = totalCount > 0 ? (completedCount / totalCount).clamp(0.0, 1.0) : 0.0;

    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        title: const Text('Clinical Supplement Schedule'),
        backgroundColor: palette.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Reset Schedule',
            onPressed: () {
              ref.read(supplementProvider.notifier).resetDay();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Supplements check-offs reset!'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: Insets.page,
        children: [
          // Clinical Mutual Exclusion Safety Card
          Container(
            padding: const EdgeInsets.all(Insets.lg),
            decoration: BoxDecoration(
              color: palette.surface,
              borderRadius: BorderRadius.circular(Radii.xl),
              border: Border.all(
                color: palette.warning.withValues(alpha: 0.5),
                width: 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                VCallout(
                  variant: VCalloutVariant.warning,
                  icon: Icons.shield_outlined,
                  title: 'CRITICAL MUTUAL EXCLUSION SAFETY RULE',
                  message: 'User owns Limitless Man Max AND Vit4ever Multivitamin A-Z. Mutual exclusion is enforced to prevent hypervitaminosis A and Zinc/Selenium toxicity.',
                ),
                const SizedBox(height: Insets.md),

                Text(
                  'ACTIVE FORMULA (MUTUALLY EXCLUSIVE):',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: palette.warning,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: Insets.xs),

                // Choice Switcher using VSegmentControl
                VSegmentControl<MultivitaminChoice>(
                  selectedValue: activeMulti,
                  activeColor: palette.warning,
                  onSelected: (choice) {
                    ref.read(supplementProvider.notifier).selectMultivitamin(choice);
                    final name = choice == MultivitaminChoice.limitlessManMax
                        ? 'Limitless Man Max active. Vit4ever A-Z locked out.'
                        : 'Vit4ever A-Z active. Limitless Man Max locked out.';
                    _showSafetyNotice(context, name);
                  },
                  items: const [
                    VSegmentItem(
                      value: MultivitaminChoice.limitlessManMax,
                      label: 'Limitless Man Max',
                      icon: Icons.medication_rounded,
                    ),
                    VSegmentItem(
                      value: MultivitaminChoice.vit4everAZ,
                      label: 'Vit4ever A-Z',
                      icon: Icons.health_and_safety_rounded,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: Insets.md),

          // Progress Overview Card
          Container(
            padding: const EdgeInsets.all(Insets.md),
            decoration: BoxDecoration(
              color: palette.surface,
              borderRadius: BorderRadius.circular(Radii.lg),
              border: Border.all(color: palette.border),
            ),
            child: Row(
              children: [
                VProgressRing(
                  progress: adherenceProgress,
                  size: 52,
                  strokeWidth: 4.5,
                  color: palette.accent,
                  valueText: '$completedCount/$totalCount',
                ),
                const SizedBox(width: Insets.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Daily Adherence Status',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        completedCount == totalCount
                            ? 'All supplements completed for the day! Perfect adherence.'
                            : '$completedCount of $totalCount doses checked off today.',
                        style: TextStyle(
                          fontSize: 12,
                          color: palette.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: Insets.lg),

          // Timing Sections (08:00 AM, 05:30 PM, 08:00 PM, 10:30 PM)
          ...SupplementTiming.values.map((timing) {
            final itemsForTiming = supplementState.items.where((i) => i.timing == timing).toList();
            if (itemsForTiming.isEmpty) return const SizedBox.shrink();

            final timingCompleted = itemsForTiming.where((i) => i.isCompleted).length;
            final isTimingDone = timingCompleted == itemsForTiming.length;

            return Container(
              margin: const EdgeInsets.only(bottom: Insets.md),
              decoration: BoxDecoration(
                color: palette.surface,
                borderRadius: BorderRadius.circular(Radii.lg),
                border: Border.all(
                  color: isTimingDone ? palette.accent.withValues(alpha: 0.5) : palette.border,
                  width: isTimingDone ? 1.5 : 1,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(Insets.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section Title
                    Row(
                      children: [
                        VBadge(
                          label: timing.timeLabel,
                          variant: VBadgeVariant.accent,
                        ),
                        const SizedBox(width: Insets.sm),
                        Expanded(
                          child: Text(
                            timing.timingTitle,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.1,
                            ),
                          ),
                        ),
                        VBadge(
                          label: '$timingCompleted/${itemsForTiming.length}',
                          variant: isTimingDone ? VBadgeVariant.success : VBadgeVariant.neutral,
                        ),
                      ],
                    ),
                    Divider(height: 22, color: palette.border),

                    // Items
                    ...itemsForTiming.map((item) {
                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => ref.read(supplementProvider.notifier).toggleSupplement(item.id),
                          borderRadius: BorderRadius.circular(Radii.md),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                VCheckbox(
                                  isChecked: item.isCompleted,
                                  onChanged: (_) => ref.read(supplementProvider.notifier).toggleSupplement(item.id),
                                  size: 22,
                                  activeColor: palette.accent,
                                ),
                                const SizedBox(width: 12),

                                // Item Details
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              item.name,
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                decoration: item.isCompleted ? TextDecoration.lineThrough : null,
                                                color: item.isCompleted
                                                    ? palette.textMuted
                                                    : palette.textPrimary,
                                              ),
                                            ),
                                          ),
                                          if (item.isMutuallyExclusive)
                                            const VBadge(
                                              label: 'MUTUAL LOCK',
                                              variant: VBadgeVariant.warning,
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        item.dosage,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: palette.accent,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        item.mechanism,
                                        style: TextStyle(
                                          fontSize: 11.5,
                                          color: palette.textSecondary,
                                          height: 1.3,
                                        ),
                                      ),
                                      if (item.warning.isNotEmpty)
                                        Padding(
                                          padding: const EdgeInsets.only(top: 4),
                                          child: Text(
                                            '⚠️ ${item.warning}',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: palette.warning,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  void _showSafetyNotice(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
