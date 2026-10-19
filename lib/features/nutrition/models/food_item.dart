enum MealType {
  meal1,
  meal2,
  postWorkout,
  meal3,
  beverages,
}

extension MealTypeExtension on MealType {
  String get displayName {
    switch (this) {
      case MealType.meal1:
        return 'Meal 1 (Breakfast & Fats)';
      case MealType.meal2:
        return 'Meal 2 (Lunch & Sustained Energy)';
      case MealType.postWorkout:
        return 'Post-Workout (Anabolic Window)';
      case MealType.meal3:
        return 'Meal 3 (Dinner & Recovery)';
      case MealType.beverages:
        return 'Zero-Calorie Hydration';
    }
  }

  String get timeCue {
    switch (this) {
      case MealType.meal1:
        return '08:00 AM';
      case MealType.meal2:
        return '01:00 PM';
      case MealType.postWorkout:
        return '05:30 PM';
      case MealType.meal3:
        return '08:00 PM';
      case MealType.beverages:
        return 'Throughout Day';
    }
  }
}

class FoodItem {
  final String id;
  final String name;
  final String portion;
  final double calories;
  final double protein;
  final double carbs;
  final double fats;
  final double fiber;
  final MealType mealType;
  final String notes;
  final bool isCompleted;

  const FoodItem({
    required this.id,
    required this.name,
    required this.portion,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
    this.fiber = 0.0,
    required this.mealType,
    this.notes = '',
    this.isCompleted = false,
  });

  FoodItem copyWith({
    String? id,
    String? name,
    String? portion,
    double? calories,
    double? protein,
    double? carbs,
    double? fats,
    double? fiber,
    MealType? mealType,
    String? notes,
    bool? isCompleted,
  }) {
    return FoodItem(
      id: id ?? this.id,
      name: name ?? this.name,
      portion: portion ?? this.portion,
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fats: fats ?? this.fats,
      fiber: fiber ?? this.fiber,
      mealType: mealType ?? this.mealType,
      notes: notes ?? this.notes,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
