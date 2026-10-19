import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:v_work/core/providers/biometrics_provider.dart';
import 'package:v_work/core/providers/supplement_provider.dart';
import 'package:v_work/features/workout/data/workout_database.dart';
import 'package:v_work/features/apt_rehab/data/apt_database.dart';

void main() {
  group('Section 1.1: Biometrics & Macronutrient Engine', () {
    test('Calculates exact BMR, TDEE, Deficit and Macros for 30yo 95kg 170cm Male', () {
      const bio = BiometricsState(
        weightKg: 95.0,
        heightCm: 170.0,
        age: 30,
        isMale: true,
        activityMultiplier: 1.48,
        isRestDay: false,
      );

      // BMR: (10 * 95) + (6.25 * 170) - (5 * 30) + 5 = 1,867.5 kcal
      expect(bio.bmr, equals(1867.5));

      // TDEE: 1867.5 * 1.48 = 2,763.9 kcal
      expect(bio.tdee.round(), equals(2764));

      // Recomposition Target: ~2145 kcal (range 2,140 - 2,150)
      expect(bio.targetCalories.round(), inInclusiveRange(2140, 2150));

      // Macros: 202g Protein, 129g Carbs, 69g Fats, 32g Fiber
      expect(bio.targetProtein.round(), equals(202));
      expect(bio.targetCarbs.round(), equals(129));
      expect(bio.targetFats.round(), equals(69));
      expect(bio.targetFiber.round(), equals(32));

      // Food portions on training day
      expect(bio.sweetPotatoGrams, equals(200.0));
      expect(bio.chickenTotalGrams, equals(350.0));
    });

    test('Rest Day correctly reduces sweet potato to 100g and adjusts carbs/deficit', () {
      const bio = BiometricsState(
        weightKg: 95.0,
        heightCm: 170.0,
        age: 30,
        isMale: true,
        activityMultiplier: 1.48,
        isRestDay: true, // Rest day active
      );

      expect(bio.sweetPotatoGrams, equals(100.0));
      expect(bio.targetCalories.round(), equals(2059));
      expect(bio.targetCarbs.round(), equals(109));
    });

    test('Dynamic biometrics scaling updates chicken and oats with weight change', () {
      const lighterBio = BiometricsState(weightKg: 85.0);
      expect(lighterBio.chickenTotalGrams, lessThan(350.0));
      expect(lighterBio.targetProtein, lessThan(202.0));
    });
  });

  group('Section 1.3: Clinical Supplement Timing & Mutual Exclusion Safety Rule', () {
    test('Enforces mutual exclusion between Limitless Man Max and Vit4ever A-Z', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final initial = container.read(supplementProvider);
      expect(initial.activeMultivitamin, equals(MultivitaminChoice.limitlessManMax));

      // When Limitless Man Max is active, it is in the list, Vit4ever A-Z is NOT in the list
      final itemIdsInitial = initial.items.map((i) => i.id).toList();
      expect(itemIdsInitial.contains('supp_multi_limitless'), isTrue);
      expect(itemIdsInitial.contains('supp_multi_vit4ever'), isFalse);

      // Switch to Vit4ever A-Z
      container.read(supplementProvider.notifier).selectMultivitamin(MultivitaminChoice.vit4everAZ);
      final switched = container.read(supplementProvider);
      expect(switched.activeMultivitamin, equals(MultivitaminChoice.vit4everAZ));

      final itemIdsSwitched = switched.items.map((i) => i.id).toList();
      expect(itemIdsSwitched.contains('supp_multi_vit4ever'), isTrue);
      expect(itemIdsSwitched.contains('supp_multi_limitless'), isFalse);
    });
  });

  group('Section 2: APT Biomechanical Protocol', () {
    test('Contains all 4 mandatory pre-workout drills', () {
      expect(AptDatabase.routine.length, equals(4));
      expect(AptDatabase.routine[0].title, contains('90/90 Diaphragmatic Breathing'));
      expect(AptDatabase.routine[1].title, contains('Couch Stretch'));
      expect(AptDatabase.routine[2].title, contains('Deadbug'));
      expect(AptDatabase.routine[3].title, contains('Pause Glute Bridge'));
    });
  });

  group('Section 3: 5-Day Workout Database & Alternatives', () {
    test('Database contains 5 complete days with prescribed exercises and alternatives', () {
      final split = WorkoutDatabase.getDefaultSplit();
      expect(split.length, equals(5));

      // Day 1: 6 exercises, each with 2 alternatives
      expect(split[0].exercises.length, equals(6));
      for (final ex in split[0].exercises) {
        expect(ex.alternatives.length, equals(2));
      }

      // Day 2: 6 exercises, each with 2 alternatives
      expect(split[1].exercises.length, equals(6));
      for (final ex in split[1].exercises) {
        expect(ex.alternatives.length, equals(2));
      }

      // Day 3: 5 exercises, each with 2 alternatives
      expect(split[2].exercises.length, equals(5));
      for (final ex in split[2].exercises) {
        expect(ex.alternatives.length, equals(2));
      }

      // Day 4: 6 exercises, each with 2 alternatives
      expect(split[3].exercises.length, equals(6));
      for (final ex in split[3].exercises) {
        expect(ex.alternatives.length, equals(2));
      }

      // Day 5: 5 exercises, each with 2 alternatives
      expect(split[4].exercises.length, equals(5));
      for (final ex in split[4].exercises) {
        expect(ex.alternatives.length, equals(2));
      }
    });
  });
}
