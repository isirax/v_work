import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/biometrics_provider.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/widgets/common/v_badge.dart';
import '../../../core/widgets/common/v_callout.dart';
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
    final palette = context.palette;
    final isDark = context.isDark;

    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        title: const Text('Biometrics & Profile'),
        backgroundColor: palette.surface,
        elevation: 0,
      ),
      body: ListView(
        padding: Insets.page,
        children: [
          // App & Profile Header with High Quality V Logo
          Center(
            child: Column(
              children: [
                const VLogo(size: 72, showGlow: true, showBadge: true),
                const SizedBox(height: Insets.md),
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
                    color: palette.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: Insets.xl),

          // Theme Selector (Dark, White, System)
          Container(
            padding: const EdgeInsets.all(Insets.lg),
            decoration: BoxDecoration(
              color: palette.surface,
              borderRadius: BorderRadius.circular(Radii.lg),
              border: Border.all(color: palette.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(Insets.sm),
                      decoration: BoxDecoration(
                        color: palette.accent.withValues(alpha: isDark ? 0.2 : 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        themeMode == ThemeMode.dark
                            ? Icons.dark_mode_rounded
                            : (themeMode == ThemeMode.light
                                ? Icons.light_mode_rounded
                                : Icons.brightness_auto_rounded),
                        color: palette.accent,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: Insets.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'App Appearance',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Select Dark, White, or System adaptive mode',
                            style: TextStyle(fontSize: 12, color: palette.textMuted),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Insets.md),
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
                            palette: palette,
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
                            palette: palette,
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
                            palette: palette,
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
          const SizedBox(height: Insets.md),

          // Editable Biometrics Card
          Container(
            padding: const EdgeInsets.all(Insets.lg),
            decoration: BoxDecoration(
              color: palette.surface,
              borderRadius: BorderRadius.circular(Radii.lg),
              border: Border.all(color: palette.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'BIOMETRICS & ANTHROPOMETRY',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                        color: palette.accent,
                      ),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        foregroundColor: palette.accent,
                      ),
                      onPressed: () {
                        ref.read(biometricsProvider.notifier).updateBiometrics(
                              weight: 95.0,
                              height: 170.0,
                              age: 30,
                            );
                        _syncControllers(const BiometricsState());
                      },
                      child: const Text('Reset Baseline', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: Insets.md),

                // Weight Slider & Input
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Body Weight (kg)', style: TextStyle(fontWeight: FontWeight.bold)),
                    VBadge(
                      label: '${bio.weightKg.toStringAsFixed(1)} kg',
                      variant: VBadgeVariant.accent,
                    ),
                  ],
                ),
                Slider(
                  value: bio.weightKg.clamp(60.0, 150.0),
                  min: 60.0,
                  max: 150.0,
                  divisions: 180,
                  activeColor: palette.accent,
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
                    VBadge(
                      label: '${bio.heightCm.toStringAsFixed(1)} cm',
                      variant: VBadgeVariant.cyan,
                    ),
                  ],
                ),
                Slider(
                  value: bio.heightCm.clamp(140.0, 210.0),
                  min: 140.0,
                  max: 210.0,
                  divisions: 140,
                  activeColor: palette.teal,
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
                    VBadge(
                      label: '${bio.age} years',
                      variant: VBadgeVariant.orange,
                    ),
                  ],
                ),
                Slider(
                  value: bio.age.toDouble().clamp(18.0, 70.0),
                  min: 18.0,
                  max: 70.0,
                  divisions: 52,
                  activeColor: palette.orange,
                  onChanged: (val) {
                    ref.read(biometricsProvider.notifier).updateBiometrics(age: val.toInt());
                    _ageController.text = val.toInt().toString();
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: Insets.md),

          // Dynamically Recalculated Targets Card
          Container(
            padding: const EdgeInsets.all(Insets.lg),
            decoration: BoxDecoration(
              color: palette.surface,
              borderRadius: BorderRadius.circular(Radii.lg),
              border: Border.all(
                color: palette.accent.withValues(alpha: 0.5),
                width: 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.auto_graph_rounded, color: palette.accent, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'DYNAMICALLY RECALCULATED TARGETS',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                        color: palette.accent,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Insets.md),

                _buildStatRow('BMR (Mifflin-St Jeor)', '${bio.bmr.toStringAsFixed(1)} kcal', palette),
                _buildStatRow('TDEE (x1.48 Gym Days)', '${bio.tdee.toStringAsFixed(1)} kcal', palette),
                _buildStatRow(
                  'Recomposition Target (~615 kcal deficit)',
                  '${bio.targetCalories.toInt()} kcal',
                  palette,
                  highlight: true,
                ),
                Divider(height: 24, color: palette.border),

                // Macro breakdown
                _buildStatRow('Target Protein (2.12g/kg)', '${bio.targetProtein.toInt()}g', palette),
                _buildStatRow('Target Carbs (Adaptive)', '${bio.targetCarbs.toInt()}g', palette),
                _buildStatRow('Target Fats (0.73g/kg)', '${bio.targetFats.toInt()}g', palette),
                _buildStatRow('Target Fiber', '${bio.targetFiber.toInt()}g', palette),
                Divider(height: 24, color: palette.border),

                // Dynamic food portion weights
                Text(
                  'AUTOMATICALLY SCALED FOOD PORTIONS',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: palette.accent,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 8),
                _buildStatRow('Chicken Breast (Raw Weight Total)', '${bio.chickenTotalGrams.toInt()}g', palette),
                _buildStatRow('  ↳ Meal 2 Chicken Portion', '${bio.chickenMeal2Grams.toInt()}g', palette),
                _buildStatRow('  ↳ Meal 3 Chicken Portion', '${bio.chickenMeal3Grams.toInt()}g', palette),
                _buildStatRow('Sweet Potato Portion', '${bio.sweetPotatoGrams.toInt()}g (${bio.isRestDay ? "Rest" : "Training"})', palette),
                _buildStatRow('Oats Portion (Meal 2)', '${bio.oatsGrams.toInt()}g', palette),
              ],
            ),
          ),
          const SizedBox(height: Insets.md),

          // Anterior Pelvic Tilt (APT) Bio Details
          const VCallout(
            variant: VCalloutVariant.accent,
            icon: Icons.accessibility_new_rounded,
            title: 'ANTERIOR PELVIC TILT (APT) STATUS',
            message: 'Anterior Pelvic Tilt is characterized by hypertonic hip flexors (psoas, rectus femoris) and tight lumbar erectors, coupled with inhibited glutes and anterior abdominals. All 5 workout days in V Workout enforce posterior tuck at lockout and ribcage-to-pelvis cylinder stacking.',
          ),
          const SizedBox(height: Insets.xxl),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, AppPalette palette, {bool highlight = false}) {
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
              color: highlight ? palette.textPrimary : palette.textSecondary,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: highlight ? palette.accent : palette.textPrimary,
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
  final AppPalette palette;
  final bool isDarkContext;
  final VoidCallback onTap;

  const _ThemeOptionTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.previewBg,
    required this.previewAccent,
    required this.palette,
    required this.isDarkContext,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Radii.md),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? palette.accent.withValues(alpha: isDarkContext ? 0.16 : 0.08)
              : palette.surfaceSunken,
          borderRadius: BorderRadius.circular(Radii.md),
          border: Border.all(
            color: isSelected ? palette.accent : palette.border,
            width: isSelected ? 2.0 : 1.0,
          ),
        ),
        child: Column(
          children: [
            // Preview Circle Badge
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: previewBg,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? previewAccent : palette.border,
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
                size: 16,
              ),
            ),
            const SizedBox(height: Insets.sm),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected ? palette.accent : palette.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                color: palette.textMuted,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: palette.accent,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check,
                  size: 10,
                  color: palette.onAccent,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
