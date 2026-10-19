import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BiometricsState {
  final double weightKg;
  final double heightCm;
  final int age;
  final bool isMale;
  final double activityMultiplier;
  final bool isRestDay;
  final bool hasApt; // Anterior Pelvic Tilt

  const BiometricsState({
    this.weightKg = 95.0,
    this.heightCm = 170.0,
    this.age = 30,
    this.isMale = true,
    this.activityMultiplier = 1.48, // 5 Gym Days/Week
    this.isRestDay = false,
    this.hasApt = true,
  });

  BiometricsState copyWith({
    double? weightKg,
    double? heightCm,
    int? age,
    bool? isMale,
    double? activityMultiplier,
    bool? isRestDay,
    bool? hasApt,
  }) {
    return BiometricsState(
      weightKg: weightKg ?? this.weightKg,
      heightCm: heightCm ?? this.heightCm,
      age: age ?? this.age,
      isMale: isMale ?? this.isMale,
      activityMultiplier: activityMultiplier ?? this.activityMultiplier,
      isRestDay: isRestDay ?? this.isRestDay,
      hasApt: hasApt ?? this.hasApt,
    );
  }

  // BMR via Mifflin-St Jeor equation:
  // Men: (10 * W) + (6.25 * H) - (5 * A) + 5
  // Women: (10 * W) + (6.25 * H) - (5 * A) - 161
  double get bmr {
    final genderOffset = isMale ? 5.0 : -161.0;
    return (10.0 * weightKg) + (6.25 * heightCm) - (5.0 * age) + genderOffset;
  }

  // TDEE: BMR * Activity multiplier
  double get tdee => bmr * activityMultiplier;

  // Recomposition target calories (~615 kcal deficit from TDEE)
  // Adjusted on rest days for sweet potato reduction
  double get targetCalories {
    final base = tdee - 619;
    return isRestDay ? (base - 86) : base;
  }

  // Protein target: ~2.12g per kg bodyweight
  double get targetProtein => (weightKg * 2.126).roundToDouble();

  // Fats target: ~0.73g per kg bodyweight
  double get targetFats => (weightKg * 0.726).roundToDouble();

  // Carbs target: 129g baseline (scaled with weight), reduced by 20g on rest days (sweet potato reduction)
  double get targetCarbs {
    final base = (129.0 * weightRatio).roundToDouble();
    return isRestDay ? (base - 20.0) : base;
  }

  // Fiber target: 32g
  double get targetFiber => 32.0;

  // Dynamic food portions based on user weight scale relative to 95kg baseline
  double get weightRatio => weightKg / 95.0;

  // Chicken raw weight (baseline 350g: 200g Meal 2 + 150g Meal 3)
  double get chickenTotalGrams => (350.0 * weightRatio).roundToDouble();
  double get chickenMeal2Grams => (200.0 * weightRatio).roundToDouble();
  double get chickenMeal3Grams => (150.0 * weightRatio).roundToDouble();

  // Sweet Potato (baseline 200g on workout days, 100g on rest days)
  double get sweetPotatoGrams => isRestDay ? 100.0 : 200.0;

  // Oats (baseline 50g)
  double get oatsGrams => (50.0 * (targetCarbs / 129.0)).clamp(30.0, 90.0).roundToDouble();
}

final biometricsProvider = NotifierProvider<BiometricsNotifier, BiometricsState>(BiometricsNotifier.new);

class BiometricsNotifier extends Notifier<BiometricsState> {
  static const _weightKey = 'v_work_user_weight';
  static const _heightKey = 'v_work_user_height';
  static const _ageKey = 'v_work_user_age';
  static const _restDayKey = 'v_work_is_rest_day';

  @override
  BiometricsState build() {
    _loadFromPrefs();
    return const BiometricsState();
  }

  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final weight = prefs.getDouble(_weightKey);
      final height = prefs.getDouble(_heightKey);
      final age = prefs.getInt(_ageKey);
      final isRest = prefs.getBool(_restDayKey);

      state = state.copyWith(
        weightKg: weight ?? state.weightKg,
        heightCm: height ?? state.heightCm,
        age: age ?? state.age,
        isRestDay: isRest ?? state.isRestDay,
      );
    } catch (_) {}
  }

  Future<void> updateBiometrics({
    double? weight,
    double? height,
    int? age,
    bool? isRestDay,
    bool? hasApt,
  }) async {
    state = state.copyWith(
      weightKg: weight,
      heightCm: height,
      age: age,
      isRestDay: isRestDay,
      hasApt: hasApt,
    );

    try {
      final prefs = await SharedPreferences.getInstance();
      if (weight != null) await prefs.setDouble(_weightKey, weight);
      if (height != null) await prefs.setDouble(_heightKey, height);
      if (age != null) await prefs.setInt(_ageKey, age);
      if (isRestDay != null) await prefs.setBool(_restDayKey, isRestDay);
    } catch (_) {}
  }

  void toggleRestDay() {
    updateBiometrics(isRestDay: !state.isRestDay);
  }
}
