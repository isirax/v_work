import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/biometrics_provider.dart';
import '../../../core/providers/nutrition_provider.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/widgets/common/v_badge.dart';
import '../../../core/widgets/common/v_callout.dart';
import '../../../core/widgets/common/v_checkbox.dart';
import '../../../core/widgets/common/v_progress_ring.dart';
import '../models/food_item.dart';

class NutritionScreen extends ConsumerWidget {
  const NutritionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final biometrics = ref.watch(biometricsProvider);
    final foodItems = ref.watch(nutritionProvider);
    final palette = context.palette;
    final isDark = context.isDark;

    // Calculate current logged totals
    double loggedCalories = 0;
    double loggedProtein = 0;
    double loggedCarbs = 0;
    double loggedFats = 0;

    for (final item in foodItems) {
      if (item.isCompleted) {
        loggedCalories += item.calories;
        loggedProtein += item.protein;
        loggedCarbs += item.carbs;
        loggedFats += item.fats;
      }
    }

    final targetCalories = biometrics.targetCalories;
    final targetProtein = biometrics.targetProtein;
    final targetCarbs = biometrics.targetCarbs;
    final targetFats = biometrics.targetFats;

    final calProgress = (targetCalories > 0) ? (loggedCalories / targetCalories).clamp(0.0, 1.0) : 0.0;
    final pProgress = (targetProtein > 0) ? (loggedProtein / targetProtein).clamp(0.0, 1.0) : 0.0;
    final cProgress = (targetCarbs > 0) ? (loggedCarbs / targetCarbs).clamp(0.0, 1.0) : 0.0;
    final fProgress = (targetFats > 0) ? (loggedFats / targetFats).clamp(0.0, 1.0) : 0.0;

    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        title: const Text('Nutrition & Meal Engine'),
        backgroundColor: palette.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Reset Day Log',
            onPressed: () {
              ref.read(nutritionProvider.notifier).resetDay();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Daily meal check-offs reset!'),
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
          // Recomposition Targets & Rest Day Toggle Card
          Container(
            padding: const EdgeInsets.all(Insets.lg),
            decoration: BoxDecoration(
              color: palette.surface,
              borderRadius: BorderRadius.circular(Radii.xl),
              border: Border.all(color: palette.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row with Rest Day Toggle
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'DAILY RECOMPOSITION TARGET',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.8,
                            color: palette.accent,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${targetCalories.toInt()} kcal',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                    // Rest Day Toggle
                    InkWell(
                      onTap: () => ref.read(biometricsProvider.notifier).toggleRestDay(),
                      borderRadius: BorderRadius.circular(Radii.md),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: biometrics.isRestDay
                              ? palette.orange.withValues(alpha: 0.15)
                              : palette.accent.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(Radii.md),
                          border: Border.all(
                            color: biometrics.isRestDay ? palette.orange : palette.accent,
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              biometrics.isRestDay ? Icons.bedtime_outlined : Icons.fitness_center_rounded,
                              size: 14,
                              color: biometrics.isRestDay ? palette.orange : palette.accent,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              biometrics.isRestDay ? 'REST DAY' : 'WORKOUT DAY',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                color: biometrics.isRestDay ? palette.orange : palette.accent,
                                letterSpacing: 0.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Insets.sm),
                VCallout(
                  variant: biometrics.isRestDay ? VCalloutVariant.warning : VCalloutVariant.accent,
                  icon: biometrics.isRestDay ? Icons.bedtime_outlined : Icons.bolt_rounded,
                  message: biometrics.isRestDay
                      ? 'Rest Day Mode Active: Sweet Potato reduced to 100g (Meal 2) to maintain ~615 kcal deficit.'
                      : 'Training Day Mode: Full 200g Sweet Potato portion for glycogen replenishment & high performance.',
                ),
                Divider(height: 28, color: palette.border),

                // Macro Progress Rings
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    VProgressRing(
                      label: 'Calories',
                      progress: calProgress,
                      valueText: '${loggedCalories.toInt()}',
                      targetText: '/ ${targetCalories.toInt()} kcal',
                      size: 56,
                      strokeWidth: 4.5,
                      color: palette.accent,
                    ),
                    VProgressRing(
                      label: 'Protein',
                      progress: pProgress,
                      valueText: '${loggedProtein.toInt()}g',
                      targetText: '/ ${targetProtein.toInt()}g',
                      size: 56,
                      strokeWidth: 4.5,
                      color: palette.teal,
                    ),
                    VProgressRing(
                      label: 'Carbs',
                      progress: cProgress,
                      valueText: '${loggedCarbs.toInt()}g',
                      targetText: '/ ${targetCarbs.toInt()}g',
                      size: 56,
                      strokeWidth: 4.5,
                      color: palette.orange,
                    ),
                    VProgressRing(
                      label: 'Fats',
                      progress: fProgress,
                      valueText: '${loggedFats.toInt()}g',
                      targetText: '/ ${targetFats.toInt()}g',
                      size: 56,
                      strokeWidth: 4.5,
                      color: palette.indigo,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: Insets.lg),

          // Meals Inventory
          ...MealType.values.map((mealType) {
            final itemsForMeal = foodItems.where((item) => item.mealType == mealType).toList();
            if (itemsForMeal.isEmpty) return const SizedBox.shrink();

            final mealCalories = itemsForMeal.fold<double>(0, (sum, i) => sum + i.calories);
            final mealProtein = itemsForMeal.fold<double>(0, (sum, i) => sum + i.protein);
            final completedCount = itemsForMeal.where((i) => i.isCompleted).length;
            final isAllDone = completedCount == itemsForMeal.length;

            return Container(
              margin: const EdgeInsets.only(bottom: Insets.md),
              decoration: BoxDecoration(
                color: palette.surface,
                borderRadius: BorderRadius.circular(Radii.lg),
                border: Border.all(
                  color: isAllDone ? palette.accent.withValues(alpha: 0.5) : palette.border,
                  width: isAllDone ? 1.5 : 1,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(Insets.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Meal Section Header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            color: _getMealColor(mealType, palette).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(Radii.md),
                            border: Border.all(
                              color: _getMealColor(mealType, palette).withValues(alpha: 0.3),
                            ),
                          ),
                          child: Icon(
                            _getMealIcon(mealType),
                            color: _getMealColor(mealType, palette),
                            size: 20,
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                mealType.displayName,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: -0.2,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${mealType.timeCue} • ${mealCalories.toInt()} kcal • ${mealProtein.toInt()}g Protein',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: palette.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        VBadge(
                          label: '$completedCount/${itemsForMeal.length}',
                          variant: isAllDone ? VBadgeVariant.success : VBadgeVariant.accent,
                        ),
                      ],
                    ),
                    Divider(height: 22, color: palette.border),

                    // Food items in this meal
                    ...itemsForMeal.map((item) {
                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => ref.read(nutritionProvider.notifier).toggleItem(item.id),
                          borderRadius: BorderRadius.circular(Radii.md),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                VCheckbox(
                                  isChecked: item.isCompleted,
                                  onChanged: (_) => ref.read(nutritionProvider.notifier).toggleItem(item.id),
                                  size: 22,
                                  activeColor: palette.accent,
                                ),
                                const SizedBox(width: 12),

                                // Food Details
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            _getFoodIcon(item.name),
                                            size: 14,
                                            color: palette.accent,
                                          ),
                                          const SizedBox(width: 6),
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
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${item.portion} • ${item.calories.toInt()} kcal (${item.protein.toStringAsFixed(1)}g P | ${item.carbs.toStringAsFixed(1)}g C | ${item.fats.toStringAsFixed(1)}g F)',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: palette.textSecondary,
                                        ),
                                      ),
                                      if (item.notes.isNotEmpty)
                                        Padding(
                                          padding: const EdgeInsets.only(top: 2),
                                          child: Text(
                                            item.notes,
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontStyle: FontStyle.italic,
                                              color: palette.textMuted,
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

  IconData _getMealIcon(MealType type) {
    switch (type) {
      case MealType.meal1:
        return Icons.wb_sunny_rounded;
      case MealType.meal2:
        return Icons.restaurant_rounded;
      case MealType.postWorkout:
        return Icons.bolt_rounded;
      case MealType.meal3:
        return Icons.nights_stay_rounded;
      case MealType.beverages:
        return Icons.water_drop_rounded;
    }
  }

  Color _getMealColor(MealType type, AppPalette palette) {
    switch (type) {
      case MealType.meal1:
        return palette.orange;
      case MealType.meal2:
        return palette.accent;
      case MealType.postWorkout:
        return AppColors.primaryCobalt;
      case MealType.meal3:
        return palette.indigo;
      case MealType.beverages:
        return palette.teal;
    }
  }

  IconData _getFoodIcon(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('chicken') || lower.contains('egg')) return Icons.restaurant_menu_rounded;
    if (lower.contains('oat') || lower.contains('rice') || lower.contains('potato')) return Icons.grain_rounded;
    if (lower.contains('oil') || lower.contains('fat')) return Icons.opacity_rounded;
    if (lower.contains('whey') || lower.contains('protein')) return Icons.sports_gymnastics_rounded;
    if (lower.contains('blueberr') || lower.contains('broccol')) return Icons.eco_rounded;
    return Icons.lunch_dining_rounded;
  }
}
