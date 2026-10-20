import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/biometrics_provider.dart';
import '../../../core/providers/nutrition_provider.dart';
import '../../../core/providers/supplement_provider.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/providers/workout_provider.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/widgets/common/v_badge.dart';
import '../../../core/widgets/common/v_callout.dart';
import '../../../core/widgets/common/v_progress_ring.dart';
import '../../../core/widgets/v_logo.dart';
import '../../apt_rehab/presentation/apt_routine_screen.dart';
import '../../nutrition/presentation/nutrition_screen.dart';
import '../../profile/presentation/profile_screen.dart';
import '../../supplements/presentation/supplement_screen.dart';
import '../../workout/presentation/active_workout_screen.dart';
import '../../workout/presentation/mesocycle_screen.dart';
import '../../workout/presentation/workout_split_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedTabIndex = 0;

  final List<Widget> _tabs = const [
    _DashboardTab(),
    WorkoutSplitScreen(),
    AptRoutineScreen(),
    _NutritionAndSupplementsTab(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final isDark = context.isDark;

    return Scaffold(
      backgroundColor: palette.background,
      body: IndexedStack(
        index: _selectedTabIndex,
        children: _tabs,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedTabIndex,
        backgroundColor: palette.surface,
        indicatorColor: palette.accent.withValues(alpha: isDark ? 0.22 : 0.16),
        onDestinationSelected: (index) {
          setState(() => _selectedTabIndex = index);
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard_rounded, color: palette.accent),
            label: 'Home',
          ),
          NavigationDestination(
            icon: const Icon(Icons.fitness_center_outlined),
            selectedIcon: Icon(Icons.fitness_center_rounded, color: palette.accent),
            label: 'Workouts',
          ),
          NavigationDestination(
            icon: const Icon(Icons.shield_outlined),
            selectedIcon: Icon(Icons.shield_rounded, color: palette.accent),
            label: 'APT Rehab',
          ),
          NavigationDestination(
            icon: const Icon(Icons.restaurant_outlined),
            selectedIcon: Icon(Icons.restaurant_rounded, color: palette.accent),
            label: 'Nutrition',
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded, color: palette.accent),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class _DashboardTab extends ConsumerWidget {
  const _DashboardTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workout = ref.watch(workoutProvider);
    final biometrics = ref.watch(biometricsProvider);
    final foodItems = ref.watch(nutritionProvider);
    final supplementState = ref.watch(supplementProvider);
    final palette = context.palette;
    final isDark = context.isDark;

    final todayWorkout = workout.selectedDay;
    final loggedCals = foodItems.where((i) => i.isCompleted).fold<double>(0, (sum, i) => sum + i.calories);
    final targetCals = biometrics.targetCalories;
    final calProgress = (targetCals > 0) ? (loggedCals / targetCals).clamp(0.0, 1.0) : 0.0;

    final completedSupps = supplementState.items.where((i) => i.isCompleted).length;
    final totalSupps = supplementState.items.length;
    final suppProgress = (totalSupps > 0) ? (completedSupps / totalSupps).clamp(0.0, 1.0) : 0.0;

    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        backgroundColor: palette.surface,
        elevation: 0,
        titleSpacing: Insets.lg,
        title: Row(
          children: [
            const VLogo(size: 32, showGlow: true),
            const SizedBox(width: 10),
            const Text(
              'V Workout',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
            const Spacer(),
            IconButton(
              onPressed: () => ref.read(themeProvider.notifier).toggleTheme(),
              icon: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: Icon(
                  isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                  key: ValueKey<bool>(isDark),
                  color: isDark ? const Color(0xFFFFC107) : AppColors.logoNavy,
                  size: 20,
                ),
              ),
              tooltip: isDark ? 'Switch to White Theme' : 'Switch to Dark Theme',
            ),
          ],
        ),
      ),
      body: ListView(
        padding: Insets.page,
        children: [
          // Greeting & Periodization Phase Chip
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back, Athlete',
                    style: TextStyle(fontSize: 12, color: palette.textMuted),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Week ${workout.currentWeek} • ${workout.currentPhase.title.split('&').first.trim()}',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MesocycleScreen()),
                  );
                },
                borderRadius: BorderRadius.circular(Radii.md),
                child: VBadge(
                  label: 'Phase ${workout.currentPhase.phaseNumber}',
                  variant: VBadgeVariant.accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: Insets.md),

          // TODAY'S WORKOUT HERO CARD
          Container(
            padding: const EdgeInsets.all(Insets.lg),
            decoration: BoxDecoration(
              color: palette.surface,
              borderRadius: BorderRadius.circular(Radii.xl),
              border: Border.all(color: palette.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.05),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    VBadge(
                      label: 'DAY ${todayWorkout.dayNumber} OF 5',
                      variant: VBadgeVariant.accent,
                    ),
                    Text(
                      '${todayWorkout.exercises.length} Exercises',
                      style: TextStyle(
                        fontSize: 12,
                        color: palette.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Insets.md),
                Text(
                  todayWorkout.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  todayWorkout.subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: palette.textSecondary,
                  ),
                ),
                const SizedBox(height: Insets.md),
                VCallout(
                  message: todayWorkout.biomechanicalFocus,
                  icon: Icons.shield_outlined,
                  variant: VCalloutVariant.accent,
                ),
                const SizedBox(height: Insets.lg),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: palette.accent,
                      foregroundColor: palette.onAccent,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.md)),
                    ),
                    onPressed: () {
                      ref.read(workoutProvider.notifier).startWorkoutSession(workout.selectedDayIndex);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ActiveWorkoutScreen()),
                      );
                    },
                    icon: const Icon(Icons.play_arrow_rounded, size: 20),
                    label: const Text(
                      'Start Workout Session',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: Insets.md),

          // MANDATORY APT 10-MIN ROUTINE QUICK CARD
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AptRoutineScreen()),
              );
            },
            borderRadius: BorderRadius.circular(Radii.lg),
            child: Container(
              padding: const EdgeInsets.all(Insets.md),
              decoration: BoxDecoration(
                color: palette.surface,
                borderRadius: BorderRadius.circular(Radii.lg),
                border: Border.all(
                  color: palette.indigo.withValues(alpha: 0.4),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: palette.indigo.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.accessibility_new_rounded,
                      color: palette.indigo,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: Insets.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const VBadge(
                          label: 'PRE-WORKOUT APT ROUTINE',
                          variant: VBadgeVariant.indigo,
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          '10-Min Pelvic Alignment',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '90/90 Breathing • Couch Stretch • Deadbug • Glute Bridge',
                          style: TextStyle(
                            fontSize: 11,
                            color: palette.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios_rounded, size: 14, color: palette.indigo),
                ],
              ),
            ),
          ),
          const SizedBox(height: Insets.md),

          // TWO-COLUMN QUICK STATS (NUTRITION & SUPPLEMENTS)
          Row(
            children: [
              // Nutrition Card
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(Insets.md),
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
                          Icon(Icons.restaurant_rounded, size: 16, color: palette.orange),
                          VBadge(
                            label: biometrics.isRestDay ? 'REST' : 'TRAINING',
                            variant: VBadgeVariant.orange,
                          ),
                        ],
                      ),
                      const SizedBox(height: Insets.sm),
                      Center(
                        child: VProgressRing(
                          progress: calProgress,
                          size: 58,
                          strokeWidth: 4.5,
                          color: palette.orange,
                          valueText: '${loggedCals.toInt()}',
                          label: 'Calories',
                          targetText: '/ ${targetCals.toInt()} kcal',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: Insets.md),

              // Supplements Card
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(Insets.md),
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
                          Icon(Icons.medication_rounded, size: 16, color: palette.accent),
                          const VBadge(
                            label: 'LOCKED',
                            variant: VBadgeVariant.warning,
                          ),
                        ],
                      ),
                      const SizedBox(height: Insets.sm),
                      Center(
                        child: VProgressRing(
                          progress: suppProgress,
                          size: 58,
                          strokeWidth: 4.5,
                          color: palette.accent,
                          valueText: '$completedSupps',
                          label: 'Supplements',
                          targetText: '/ $totalSupps Doses',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: Insets.lg),

          // Recent Completed Workouts History
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'RECENT TRAINING LOGS',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.8,
                  color: palette.accent,
                ),
              ),
              Text(
                '${workout.history.length} Sessions Logged',
                style: TextStyle(fontSize: 11, color: palette.textMuted),
              ),
            ],
          ),
          const SizedBox(height: Insets.sm),

          if (workout.history.isEmpty)
            Container(
              padding: const EdgeInsets.all(Insets.lg),
              decoration: BoxDecoration(
                color: palette.surface,
                borderRadius: BorderRadius.circular(Radii.lg),
                border: Border.all(color: palette.border),
              ),
              child: Center(
                child: Text(
                  'No workouts completed yet. Start your first session above!',
                  style: TextStyle(fontSize: 12, color: palette.textMuted),
                ),
              ),
            )
          else
            ...workout.history.take(3).map((hist) {
              return Container(
                margin: const EdgeInsets.only(bottom: Insets.sm),
                padding: const EdgeInsets.all(Insets.md),
                decoration: BoxDecoration(
                  color: palette.surface,
                  borderRadius: BorderRadius.circular(Radii.md),
                  border: Border.all(color: palette.border),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(Insets.sm),
                      decoration: BoxDecoration(
                        color: palette.accent.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.check_rounded, color: palette.accent, size: 18),
                    ),
                    const SizedBox(width: Insets.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            hist.dayTitle,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${hist.totalSets} Sets • ${hist.totalVolumeKg.toInt()} kg Total Volume',
                            style: TextStyle(
                              fontSize: 12,
                              color: palette.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    VBadge(
                      label: '${hist.durationMinutes}m',
                      variant: VBadgeVariant.accent,
                    ),
                  ],
                ),
              );
            }),
          const SizedBox(height: Insets.xl),
        ],
      ),
    );
  }
}

class _NutritionAndSupplementsTab extends StatefulWidget {
  const _NutritionAndSupplementsTab();

  @override
  State<_NutritionAndSupplementsTab> createState() => _NutritionAndSupplementsTabState();
}

class _NutritionAndSupplementsTabState extends State<_NutritionAndSupplementsTab> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        title: const Text('Nutrition & Supplements'),
        backgroundColor: palette.surface,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: palette.accent,
          labelColor: palette.accent,
          unselectedLabelColor: palette.textSecondary,
          indicatorWeight: 3,
          tabs: const [
            Tab(text: 'Food Inventory & Macros'),
            Tab(text: 'Clinical Supplements'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          NutritionScreen(),
          SupplementScreen(),
        ],
      ),
    );
  }
}
