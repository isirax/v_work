import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/supplement_provider.dart';
import '../models/supplement_item.dart';

class SupplementScreen extends ConsumerWidget {
  const SupplementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final supplementState = ref.watch(supplementProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeMulti = supplementState.activeMultivitamin;

    final completedCount = supplementState.items.where((i) => i.isCompleted).length;
    final totalCount = supplementState.items.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Clinical Supplement Schedule'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Reset Schedule',
            onPressed: () {
              ref.read(supplementProvider.notifier).resetDay();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Supplements check-offs reset!')),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Clinical Mutual Exclusion Safety Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.warningGold.withValues(alpha: isDark ? 0.15 : 0.10),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.warningGold.withValues(alpha: 0.6),
                width: 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.shield_outlined, color: AppColors.warningGold, size: 22),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'CRITICAL MUTUAL EXCLUSION SAFETY RULE',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                          color: AppColors.warningGold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'User owns Limitless Man Max AND Vit4ever Multivitamin A-Z. Mutual exclusion is enforced to prevent hypervitaminosis A and Zinc/Selenium toxicity.',
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.4,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                ),
                const SizedBox(height: 14),

                // Choice Switcher
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCard : AppColors.lightCard,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildMultiToggle(
                          title: 'Limitless Man Max',
                          isSelected: activeMulti == MultivitaminChoice.limitlessManMax,
                          isDark: isDark,
                          onTap: () {
                            ref.read(supplementProvider.notifier).selectMultivitamin(MultivitaminChoice.limitlessManMax);
                            _showSafetyNotice(context, 'Limitless Man Max active. Vit4ever A-Z is locked out.');
                          },
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: _buildMultiToggle(
                          title: 'Vit4ever A-Z',
                          isSelected: activeMulti == MultivitaminChoice.vit4everAZ,
                          isDark: isDark,
                          onTap: () {
                            ref.read(supplementProvider.notifier).selectMultivitamin(MultivitaminChoice.vit4everAZ);
                            _showSafetyNotice(context, 'Vit4ever A-Z active. Limitless Man Max is locked out.');
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Progress Overview
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  SizedBox(
                    width: 48,
                    height: 48,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircularProgressIndicator(
                          value: totalCount > 0 ? completedCount / totalCount : 0,
                          strokeWidth: 4,
                          backgroundColor: AppColors.primaryVolt.withValues(alpha: 0.15),
                          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryVolt),
                        ),
                        Text(
                          '$completedCount/$totalCount',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Daily Adherence Status',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          completedCount == totalCount
                              ? 'All supplements completed for the day! Perfect adherence.'
                              : '$completedCount of $totalCount doses checked off today.',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Timing Sections (08:00 AM, 05:30 PM, 08:00 PM, 10:30 PM)
          ...SupplementTiming.values.map((timing) {
            final itemsForTiming = supplementState.items.where((i) => i.timing == timing).toList();
            if (itemsForTiming.isEmpty) return const SizedBox.shrink();

            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section Title
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primaryVolt.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            timing.timeLabel,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              color: AppColors.primaryVolt,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            timing.timingTitle,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 20),

                    // Items
                    ...itemsForTiming.map((item) {
                      return InkWell(
                        onTap: () => ref.read(supplementProvider.notifier).toggleSupplement(item.id),
                        borderRadius: BorderRadius.circular(10),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Checkbox
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 22,
                                height: 22,
                                margin: const EdgeInsets.only(top: 2, right: 12),
                                decoration: BoxDecoration(
                                  color: item.isCompleted
                                      ? AppColors.primaryVolt
                                      : (isDark ? Colors.white12 : Colors.black12),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: item.isCompleted ? AppColors.primaryVolt : Colors.transparent,
                                  ),
                                ),
                                child: item.isCompleted
                                    ? const Icon(Icons.check, size: 16, color: Colors.black)
                                    : null,
                              ),

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
                                            ),
                                          ),
                                        ),
                                        if (item.isMutuallyExclusive)
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: AppColors.warningGold.withValues(alpha: 0.15),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: const Text(
                                              'MUTUAL LOCK',
                                              style: TextStyle(
                                                fontSize: 9,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.warningGold,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      item.dosage,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.primaryCyan,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      item.mechanism,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                      ),
                                    ),
                                    if (item.warning.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: Text(
                                          '⚠️ ${item.warning}',
                                          style: const TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.warningGold,
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

  Widget _buildMultiToggle({
    required String title,
    required bool isSelected,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(9),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.warningGold : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.black : (isDark ? Colors.white70 : Colors.black87),
            ),
          ),
        ),
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
