import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/nutrition/models/food_item.dart';
import 'biometrics_provider.dart';

final nutritionProvider = NotifierProvider<NutritionNotifier, List<FoodItem>>(NutritionNotifier.new);

class NutritionNotifier extends Notifier<List<FoodItem>> {
  final Set<String> _completedIds = {};

  @override
  List<FoodItem> build() {
    final biometrics = ref.watch(biometricsProvider);
    return _buildInventory(biometrics);
  }

  List<FoodItem> _buildInventory(BiometricsState biometrics) {
    final chickenMeal2 = biometrics.chickenMeal2Grams.toInt();
    final chickenMeal3 = biometrics.chickenMeal3Grams.toInt();
    final sweetPotato = biometrics.sweetPotatoGrams.toInt();
    final oats = biometrics.oatsGrams.toInt();

    final items = [
      // MEAL 1
      const FoodItem(
        id: 'm1_eggs',
        name: 'Whole Eggs',
        portion: '3 large (150g)',
        calories: 215,
        protein: 19,
        carbs: 1.1,
        fats: 15,
        fiber: 0,
        mealType: MealType.meal1,
        notes: 'Choline for cognitive focus + healthy lipid vehicle for vitamins',
      ),
      const FoodItem(
        id: 'm1_cottage_cheese',
        name: 'Cottage Cheese',
        portion: '150g',
        calories: 147,
        protein: 18,
        carbs: 5,
        fats: 6,
        fiber: 0,
        mealType: MealType.meal1,
        notes: 'Slow-release micellar casein protein',
      ),
      const FoodItem(
        id: 'm1_olive_oil',
        name: 'Extra Virgin Olive Oil',
        portion: '10ml (2 tsp)',
        calories: 80,
        protein: 0,
        carbs: 0,
        fats: 9.3,
        fiber: 0,
        mealType: MealType.meal1,
        notes: 'Monounsaturated fatty acids for hormone synthesis & supplement absorption',
      ),
      const FoodItem(
        id: 'm1_cucumber',
        name: 'Fresh Cucumbers',
        portion: '150g (1.5 medium)',
        calories: 22,
        protein: 0.9,
        carbs: 5.2,
        fats: 0.2,
        fiber: 1.5,
        mealType: MealType.meal1,
        notes: 'Electrolyte hydration & digestive volume',
      ),

      // MEAL 2
      FoodItem(
        id: 'm2_chicken',
        name: 'Chicken Breast (Raw Weight)',
        portion: '${chickenMeal2}g raw weight',
        calories: (chickenMeal2 * 1.20).roundToDouble(),
        protein: (chickenMeal2 * 0.224).roundToDouble(),
        carbs: 0,
        fats: (chickenMeal2 * 0.026).roundToDouble(),
        fiber: 0,
        mealType: MealType.meal2,
        notes: 'Lean complete amino acid profile for muscle protein synthesis',
      ),
      FoodItem(
        id: 'm2_oats',
        name: 'Rolled Oats',
        portion: '${oats}g',
        calories: (oats * 3.88).roundToDouble(),
        protein: (oats * 0.13).roundToDouble(),
        carbs: (oats * 0.66).roundToDouble(),
        fats: (oats * 0.07).roundToDouble(),
        fiber: (oats * 0.10).roundToDouble(),
        mealType: MealType.meal2,
        notes: 'Beta-glucan complex low-glycemic fuel',
      ),
      FoodItem(
        id: 'm2_sweet_potato',
        name: biometrics.isRestDay ? 'Sweet Potato (Rest Day Portioned)' : 'Sweet Potato (Workout Day)',
        portion: '${sweetPotato}g baked/steamed',
        calories: (sweetPotato * 0.86).roundToDouble(),
        protein: (sweetPotato * 0.016).roundToDouble(),
        carbs: (sweetPotato * 0.20).roundToDouble(),
        fats: 0.2,
        fiber: (sweetPotato * 0.03).roundToDouble(),
        mealType: MealType.meal2,
        notes: biometrics.isRestDay
            ? 'Reduced from 200g to 100g on Rest Days to balance non-training deficit'
            : 'Glycogen loading for 5-day resistance training performance',
      ),
      const FoodItem(
        id: 'm2_milk',
        name: 'Skimmed Milk',
        portion: '200ml',
        calories: 70,
        protein: 7,
        carbs: 10,
        fats: 0.2,
        fiber: 0,
        mealType: MealType.meal2,
        notes: 'Liquid calcium and whey/casein blend',
      ),
      const FoodItem(
        id: 'm2_chia',
        name: 'Chia Seeds',
        portion: '10g',
        calories: 49,
        protein: 1.7,
        carbs: 4.2,
        fats: 3.1,
        fiber: 3.4,
        mealType: MealType.meal2,
        notes: 'Soluble fiber & ALA plant Omega-3s',
      ),
      const FoodItem(
        id: 'm2_cocoa',
        name: 'Raw Cocoa Powder',
        portion: '10g',
        calories: 23,
        protein: 2.0,
        carbs: 5.8,
        fats: 1.4,
        fiber: 3.3,
        mealType: MealType.meal2,
        notes: 'Rich polyphenols and nitric oxide vasodilation',
      ),
      const FoodItem(
        id: 'm2_cucumber',
        name: 'Fresh Cucumbers',
        portion: '125g (1 medium)',
        calories: 19,
        protein: 0.8,
        carbs: 4.4,
        fats: 0.1,
        fiber: 1.2,
        mealType: MealType.meal2,
        notes: 'Satiety and micronutrient hydration',
      ),

      // POST-WORKOUT
      const FoodItem(
        id: 'pw_isolate',
        name: 'Whey Protein Isolate',
        portion: '1 scoop (35g powder)',
        calories: 130,
        protein: 30,
        carbs: 1.5,
        fats: 0.5,
        fiber: 0,
        mealType: MealType.postWorkout,
        notes: 'Rapid leucine spike triggering mTOR muscle recovery',
      ),
      const FoodItem(
        id: 'pw_jelly',
        name: 'High-Protein Jelly',
        portion: '1 pack',
        calories: 72,
        protein: 14,
        carbs: 3,
        fats: 0,
        fiber: 0,
        mealType: MealType.postWorkout,
        notes: 'Collagen-rich glycine for tendon/joint tensile strength',
      ),

      // MEAL 3
      FoodItem(
        id: 'm3_chicken',
        name: 'Chicken Breast (Raw Weight)',
        portion: '${chickenMeal3}g raw weight',
        calories: (chickenMeal3 * 1.20).roundToDouble(),
        protein: (chickenMeal3 * 0.224).roundToDouble(),
        carbs: 0,
        fats: (chickenMeal3 * 0.026).roundToDouble(),
        fiber: 0,
        mealType: MealType.meal3,
        notes: 'Evening muscle repair and nighttime amino acid availability',
      ),
      const FoodItem(
        id: 'm3_yogurt',
        name: 'Authentic Greek Yogurt',
        portion: '200g',
        calories: 190,
        protein: 18,
        carbs: 8,
        fats: 9,
        fiber: 0,
        mealType: MealType.meal3,
        notes: 'Probiotic gut microbiome flora + sustained overnight casein',
      ),
      const FoodItem(
        id: 'm3_flax',
        name: 'Ground Flax Seeds',
        portion: '10g',
        calories: 53,
        protein: 1.8,
        carbs: 2.9,
        fats: 4.2,
        fiber: 2.7,
        mealType: MealType.meal3,
        notes: 'Lignans and anti-inflammatory cellular fatty acids',
      ),
      const FoodItem(
        id: 'm3_olive_oil',
        name: 'Extra Virgin Olive Oil',
        portion: '5ml (1 tsp)',
        calories: 40,
        protein: 0,
        carbs: 0,
        fats: 4.7,
        fiber: 0,
        mealType: MealType.meal3,
        notes: 'Aids lipid carrier for Ashwagandha & Magnesium uptake',
      ),
      const FoodItem(
        id: 'm3_cucumber',
        name: 'Fresh Cucumbers',
        portion: '125g (1 medium)',
        calories: 19,
        protein: 0.8,
        carbs: 4.4,
        fats: 0.1,
        fiber: 1.2,
        mealType: MealType.meal3,
        notes: 'Crucial evening hydration and gastric fullness',
      ),

      // BEVERAGES
      const FoodItem(
        id: 'bev_coffee',
        name: 'Black Coffee (Pre-Training)',
        portion: '1-2 cups (250-500ml)',
        calories: 4,
        protein: 0.3,
        carbs: 0,
        fats: 0,
        fiber: 0,
        mealType: MealType.beverages,
        notes: 'Adenosine antagonism, CNS drive & fat oxidation',
      ),
      const FoodItem(
        id: 'bev_green_tea',
        name: 'Japanese Green Tea',
        portion: '1-2 mugs',
        calories: 2,
        protein: 0,
        carbs: 0,
        fats: 0,
        fiber: 0,
        mealType: MealType.beverages,
        notes: 'EGCG catechins for mitochondrial energy expenditure',
      ),
      const FoodItem(
        id: 'bev_parsley',
        name: 'Brewed Parsley Tea',
        portion: '1 mug',
        calories: 2,
        protein: 0,
        carbs: 0,
        fats: 0,
        fiber: 0,
        mealType: MealType.beverages,
        notes: 'Natural diuretic apigenin; prevents lumbar fluid retention',
      ),
      const FoodItem(
        id: 'bev_cola_zero',
        name: 'Cola Zero / Carbonated Water',
        portion: 'As desired',
        calories: 0,
        protein: 0,
        carbs: 0,
        fats: 0,
        fiber: 0,
        mealType: MealType.beverages,
        notes: 'Zero caloric impact craving control',
      ),
    ];

    return items.map((item) {
      return item.copyWith(isCompleted: _completedIds.contains(item.id));
    }).toList();
  }

  void toggleItem(String id) {
    if (_completedIds.contains(id)) {
      _completedIds.remove(id);
    } else {
      _completedIds.add(id);
    }
    state = state.map((item) {
      if (item.id == id) {
        return item.copyWith(isCompleted: _completedIds.contains(id));
      }
      return item;
    }).toList();
  }

  void resetDay() {
    _completedIds.clear();
    state = state.map((item) => item.copyWith(isCompleted: false)).toList();
  }
}
