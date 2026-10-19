import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/biometrics_provider.dart';
import '../../../core/providers/nutrition_provider.dart';
import '../models/food_item.dart';

class NutritionScreen extends ConsumerWidget {
  const NutritionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final biometrics = ref.watch(biometricsProvider);
    final foodItems = ref.watch(nutritionProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
      appBar: AppBar(
        title: const Text('Nutrition & Meal Engine'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Reset Day Log',
            onPressed: () {
              ref.read(nutritionProvider.notifier).resetDay();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Daily meal check-offs reset!')),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Recomposition Targets & Rest Day Toggle Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: isDark ? AppColors.darkCardGradient : null,
              color: isDark ? null : AppColors.lightCard,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
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
                        const Text(
                          'DAILY RECOMPOSITION TARGET',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.8,
                            color: AppColors.primaryVolt,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${targetCalories.toInt()} kcal / day',
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
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: biometrics.isRestDay
                              ? AppColors.primaryOrange.withValues(alpha: 0.2)
                              : AppColors.primaryVolt.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: biometrics.isRestDay ? AppColors.primaryOrange : AppColors.primaryVolt,
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              biometrics.isRestDay ? Icons.bedtime_outlined : Icons.fitness_center_rounded,
                              size: 14,
                              color: biometrics.isRestDay ? AppColors.primaryOrange : AppColors.primaryVolt,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              biometrics.isRestDay ? 'REST DAY' : 'WORKOUT DAY',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                color: biometrics.isRestDay ? AppColors.primaryOrange : AppColors.primaryVolt,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  biometrics.isRestDay
                      ? 'Rest Day Mode Active: Sweet Potato reduced to 100g (Meal 2) to maintain ~615 kcal deficit without training.'
                      : 'Training Day Mode: Full 200g Sweet Potato portion for glycogen replenishment & high performance.',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
                const Divider(height: 24),

                // Macro Progress Rings / Bars
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildMacroRing(
                      label: 'Calories',
                      current: loggedCalories.toInt(),
                      target: targetCalories.toInt(),
                      unit: 'kcal',
                      progress: calProgress,
                      color: AppColors.primaryVolt,
                    ),
                    _buildMacroRing(
                      label: 'Protein',
                      current: loggedProtein.toInt(),
                      target: targetProtein.toInt(),
                      unit: 'g',
                      progress: pProgress,
                      color: AppColors.primaryCyan,
                    ),
                    _buildMacroRing(
                      label: 'Carbs',
                      current: loggedCarbs.toInt(),
                      target: targetCarbs.toInt(),
                      unit: 'g',
                      progress: cProgress,
                      color: AppColors.primaryOrange,
                    ),
                    _buildMacroRing(
                      label: 'Fats',
                      current: loggedFats.toInt(),
                      target: targetFats.toInt(),
                      unit: 'g',
                      progress: fProgress,
                      color: AppColors.primaryIndigo,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Meals Inventory
          ...MealType.values.map((mealType) {
            final itemsForMeal = foodItems.where((item) => item.mealType == mealType).toList();
            if (itemsForMeal.isEmpty) return const SizedBox.shrink();

            final mealCalories = itemsForMeal.fold<double>(0, (sum, i) => sum + i.calories);
            final mealProtein = itemsForMeal.fold<double>(0, (sum, i) => sum + i.protein);

            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
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
                            color: _getMealColor(mealType).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _getMealColor(mealType).withValues(alpha: 0.3),
                            ),
                          ),
                          child: Icon(
                            _getMealIcon(mealType),
                            color: _getMealColor(mealType),
                            size: 22,
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
                                ),
                              ),
                              Text(
                                '${mealType.timeCue} • ${mealCalories.toInt()} kcal • ${mealProtein.toInt()}g Protein',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.primaryVolt.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${itemsForMeal.where((i) => i.isCompleted).length}/${itemsForMeal.length}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryVolt,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 20),

                    // Food items in this meal
                    ...itemsForMeal.map((item) {
                      return InkWell(
                        onTap: () => ref.read(nutritionProvider.notifier).toggleItem(item.id),
                        borderRadius: BorderRadius.circular(10),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Custom Checkbox
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
                                          color: isDark ? AppColors.primaryVolt : const Color(0xFF00C875),
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
                                                  ? (isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted)
                                                  : null,
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
                                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
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
                                            color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
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

  Widget _buildMacroRing({
    required String label,
    required int current,
    required int target,
    required String unit,
    required double progress,
    required Color color,
  }) {
    return Column(
      children: [
        SizedBox(
          width: 58,
          height: 58,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: progress,
                strokeWidth: 5,
                backgroundColor: color.withValues(alpha: 0.15),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$current',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    unit,
                    style: const TextStyle(fontSize: 8, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
        ),
        Text(
          '/ $target$unit',
          style: const TextStyle(fontSize: 10, color: Colors.grey),
        ),
      ],
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

  Color _getMealColor(MealType type) {
    switch (type) {
      case MealType.meal1:
        return AppColors.primaryOrange;
      case MealType.meal2:
        return AppColors.primaryVolt;
      case MealType.postWorkout:
        return AppColors.primaryCobalt;
      case MealType.meal3:
        return AppColors.primaryIndigo;
      case MealType.beverages:
        return AppColors.primaryIce;
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
