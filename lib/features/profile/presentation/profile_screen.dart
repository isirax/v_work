import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/biometrics_provider.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/widgets/v_logo.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  late TextEditingController _weightController;
  late TextEditingController _heightController;
  late TextEditingController _ageController;

  @override
  void initState() {
    super.initState();
    final bio = ref.read(biometricsProvider);
    _weightController = TextEditingController(text: bio.weightKg.toStringAsFixed(1));
    _heightController = TextEditingController(text: bio.heightCm.toStringAsFixed(1));
    _ageController = TextEditingController(text: bio.age.toString());
  }

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  void _syncControllers(BiometricsState bio) {
    if (_weightController.text != bio.weightKg.toStringAsFixed(1)) {
      _weightController.text = bio.weightKg.toStringAsFixed(1);
    }
    if (_heightController.text != bio.heightCm.toStringAsFixed(1)) {
      _heightController.text = bio.heightCm.toStringAsFixed(1);
    }
    if (_ageController.text != bio.age.toString()) {
      _ageController.text = bio.age.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bio = ref.watch(biometricsProvider);
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Biometrics & Profile'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // App & Profile Header with High Quality V Logo
          Center(
            child: Column(
              children: [
                const VLogo(size: 72, showGlow: true, showBadge: true),
                const SizedBox(height: 14),
                const Text(
                  'V Workout',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Hypertrophy & Anterior Pelvic Tilt Engine',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Theme Selector (Dark, White, System)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primaryCobalt.withValues(alpha: isDark ? 0.2 : 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          themeMode == ThemeMode.dark
                              ? Icons.dark_mode_rounded
                              : (themeMode == ThemeMode.light
                                  ? Icons.light_mode_rounded
                                  : Icons.brightness_auto_rounded),
                          color: isDark ? AppColors.primaryIce : AppColors.logoNavy,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'App Appearance',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Choose between Dark, White, or System theme',
                              style: TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isNarrow = constraints.maxWidth < 360;
                      return Flex(
                        direction: isNarrow ? Axis.vertical : Axis.horizontal,
                        children: [
                          Expanded(
                            flex: isNarrow ? 0 : 1,
                            child: _ThemeOptionTile(
                              title: 'Dark Mode',
                              subtitle: 'Obsidian Navy',
                              icon: Icons.dark_mode_rounded,
                              isSelected: themeMode == ThemeMode.dark,
                              previewBg: const Color(0xFF0A1118),
                              previewAccent: AppColors.primaryIce,
                              isDarkContext: isDark,
                              onTap: () => ref.read(themeProvider.notifier).setTheme(ThemeMode.dark),
                            ),
                          ),
                          SizedBox(width: isNarrow ? 0 : 8, height: isNarrow ? 8 : 0),
                          Expanded(
                            flex: isNarrow ? 0 : 1,
                            child: _ThemeOptionTile(
                              title: 'White Mode',
                              subtitle: 'Clean Crisp',
                              icon: Icons.light_mode_rounded,
                              isSelected: themeMode == ThemeMode.light,
                              previewBg: Colors.white,
                              previewAccent: AppColors.logoNavy,
                              isDarkContext: isDark,
                              onTap: () => ref.read(themeProvider.notifier).setTheme(ThemeMode.light),
                            ),
                          ),
                          SizedBox(width: isNarrow ? 0 : 8, height: isNarrow ? 8 : 0),
                          Expanded(
                            flex: isNarrow ? 0 : 1,
                            child: _ThemeOptionTile(
                              title: 'System',
                              subtitle: 'Auto Match',
                              icon: Icons.brightness_auto_rounded,
                              isSelected: themeMode == ThemeMode.system,
                              previewBg: isDark ? const Color(0xFF182332) : const Color(0xFFE2E8F0),
                              previewAccent: AppColors.primaryCobalt,
                              isDarkContext: isDark,
                              onTap: () => ref.read(themeProvider.notifier).setTheme(ThemeMode.system),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Editable Biometrics Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'BIOMETRICS & ANTHROPOMETRY',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                          color: AppColors.primaryCyan,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          ref.read(biometricsProvider.notifier).updateBiometrics(
                                weight: 95.0,
                                height: 170.0,
                                age: 30,
                              );
                          _syncControllers(const BiometricsState());
                        },
                        child: const Text('Reset Baseline', style: TextStyle(fontSize: 11)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Weight Slider & Input
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Body Weight (kg)', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(
                        '${bio.weightKg.toStringAsFixed(1)} kg',
                        style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.primaryVolt),
                      ),
                    ],
                  ),
                  Slider(
                    value: bio.weightKg.clamp(60.0, 150.0),
                    min: 60.0,
                    max: 150.0,
                    divisions: 180,
                    activeColor: AppColors.primaryVolt,
                    onChanged: (val) {
                      ref.read(biometricsProvider.notifier).updateBiometrics(weight: val);
                      _weightController.text = val.toStringAsFixed(1);
                    },
                  ),

                  // Height Slider & Input
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Height (cm)', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(
                        '${bio.heightCm.toStringAsFixed(1)} cm',
                        style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.primaryCyan),
                      ),
                    ],
                  ),
                  Slider(
                    value: bio.heightCm.clamp(140.0, 210.0),
                    min: 140.0,
                    max: 210.0,
                    divisions: 140,
                    activeColor: AppColors.primaryCyan,
                    onChanged: (val) {
                      ref.read(biometricsProvider.notifier).updateBiometrics(height: val);
                      _heightController.text = val.toStringAsFixed(1);
                    },
                  ),

                  // Age Slider & Input
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Age (years)', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(
                        '${bio.age} years',
                        style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.primaryOrange),
                      ),
                    ],
                  ),
                  Slider(
                    value: bio.age.toDouble().clamp(18.0, 70.0),
                    min: 18.0,
                    max: 70.0,
                    divisions: 52,
                    activeColor: AppColors.primaryOrange,
                    onChanged: (val) {
                      ref.read(biometricsProvider.notifier).updateBiometrics(age: val.toInt());
                      _ageController.text = val.toInt().toString();
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Dynamically Recalculated Targets Card
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
              side: const BorderSide(color: AppColors.primaryVolt, width: 1.5),
            ),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.auto_graph_rounded, color: AppColors.primaryVolt, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'DYNAMICALLY RECALCULATED TARGETS',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                          color: AppColors.primaryVolt,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  _buildStatRow('BMR (Mifflin-St Jeor)', '${bio.bmr.toStringAsFixed(1)} kcal', isDark),
                  _buildStatRow('TDEE (x1.48 Gym Days)', '${bio.tdee.toStringAsFixed(1)} kcal', isDark),
                  _buildStatRow(
                    'Recomposition Target (~615 kcal deficit)',
                    '${bio.targetCalories.toInt()} kcal',
                    isDark,
                    highlight: true,
                  ),
                  const Divider(height: 20),

                  // Macro breakdown
                  _buildStatRow('Target Protein (2.12g/kg)', '${bio.targetProtein.toInt()}g', isDark),
                  _buildStatRow('Target Carbs (Adaptive)', '${bio.targetCarbs.toInt()}g', isDark),
                  _buildStatRow('Target Fats (0.73g/kg)', '${bio.targetFats.toInt()}g', isDark),
                  _buildStatRow('Target Fiber', '${bio.targetFiber.toInt()}g', isDark),
                  const Divider(height: 20),

                  // Dynamic food portion weights
                  const Text(
                    'AUTOMATICALLY SCALED FOOD PORTIONS',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryCyan,
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildStatRow('Chicken Breast (Raw Weight Total)', '${bio.chickenTotalGrams.toInt()}g', isDark),
                  _buildStatRow('  ↳ Meal 2 Chicken Portion', '${bio.chickenMeal2Grams.toInt()}g', isDark),
                  _buildStatRow('  ↳ Meal 3 Chicken Portion', '${bio.chickenMeal3Grams.toInt()}g', isDark),
                  _buildStatRow('Sweet Potato Portion', '${bio.sweetPotatoGrams.toInt()}g (${bio.isRestDay ? "Rest" : "Training"})', isDark),
                  _buildStatRow('Oats Portion (Meal 2)', '${bio.oatsGrams.toInt()}g', isDark),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Anterior Pelvic Tilt (APT) Bio Details
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.accessibility_new_rounded, color: AppColors.primaryVolt, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'ANTERIOR PELVIC TILT (APT) STATUS',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                          color: AppColors.primaryVolt,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Anterior Pelvic Tilt is characterized by hypertonic hip flexors (psoas, rectus femoris) and tight lumbar erectors, coupled with inhibited glutes and anterior abdominals.\n\nAll 5 workout days in V Workout enforce posterior tuck at lockout and ribcage-to-pelvis cylinder stacking.',
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.5,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, bool isDark, {bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: highlight ? FontWeight.bold : FontWeight.w500,
              color: highlight
                  ? (isDark ? Colors.white : Colors.black)
                  : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: highlight ? AppColors.primaryVolt : (isDark ? Colors.white : Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemeOptionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final Color previewBg;
  final Color previewAccent;
  final bool isDarkContext;
  final VoidCallback onTap;

  const _ThemeOptionTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.previewBg,
    required this.previewAccent,
    required this.isDarkContext,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDarkContext
                  ? AppColors.primaryCobalt.withValues(alpha: 0.18)
                  : AppColors.logoNavy.withValues(alpha: 0.08))
              : (isDarkContext ? const Color(0xFF141C27) : const Color(0xFFF1F5F9)),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? (isDarkContext ? AppColors.primaryIce : AppColors.logoNavy)
                : (isDarkContext ? AppColors.darkCardBorder : AppColors.lightCardBorder),
            width: isSelected ? 2.0 : 1.0,
          ),
        ),
        child: Column(
          children: [
            // Preview Circle Badge
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: previewBg,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? previewAccent : Colors.grey.withValues(alpha: 0.3),
                  width: 1.5,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: previewAccent.withValues(alpha: 0.3),
                          blurRadius: 8,
                        ),
                      ]
                    : null,
              ),
              child: Icon(
                icon,
                color: previewAccent,
                size: 18,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected
                    ? (isDarkContext ? AppColors.primaryIce : AppColors.logoNavy)
                    : (isDarkContext ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                color: isDarkContext ? AppColors.darkTextMuted : AppColors.lightTextMuted,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: isDarkContext ? AppColors.primaryIce : AppColors.logoNavy,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check,
                  size: 10,
                  color: isDarkContext ? Colors.black : Colors.white,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
