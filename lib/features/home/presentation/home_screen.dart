import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/biometrics_provider.dart';
import '../../../core/providers/nutrition_provider.dart';
import '../../../core/providers/supplement_provider.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/providers/workout_provider.dart';
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
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;

    return Scaffold(
      body: IndexedStack(
        index: _selectedTabIndex,
        children: _tabs,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedTabIndex,
        backgroundColor: isDark ? AppColors.darkCard : AppColors.lightCard,
        indicatorColor: AppColors.primaryVolt.withValues(alpha: isDark ? 0.25 : 0.20),
        onDestinationSelected: (index) {
          setState(() => _selectedTabIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard_rounded, color: AppColors.primaryVolt),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.fitness_center_outlined),
            selectedIcon: Icon(Icons.fitness_center_rounded, color: AppColors.primaryVolt),
            label: 'Workouts',
          ),
          NavigationDestination(
            icon: Icon(Icons.shield_outlined),
            selectedIcon: Icon(Icons.shield_rounded, color: AppColors.primaryVolt),
            label: 'APT Rehab',
          ),
          NavigationDestination(
            icon: Icon(Icons.restaurant_outlined),
            selectedIcon: Icon(Icons.restaurant_rounded, color: AppColors.primaryVolt),
            label: 'Nutrition',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded, color: AppColors.primaryVolt),
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
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;

    final todayWorkout = workout.selectedDay;
    final loggedCals = foodItems.where((i) => i.isCompleted).fold<double>(0, (sum, i) => sum + i.calories);
    final targetCals = biometrics.targetCalories;
    final completedSupps = supplementState.items.where((i) => i.isCompleted).length;
    final totalSupps = supplementState.items.length;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: Row(
          children: [
            const VLogo(size: 34, showGlow: true),
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
                  size: 22,
                ),
              ),
              tooltip: isDark ? 'Switch to White Theme' : 'Switch to Dark Theme',
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          // Greeting & Periodization Phase Chip
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Welcome back, Athlete',
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  Text(
                    'Week ${workout.currentWeek} • ${workout.currentPhase.title.split('&').first.trim()}',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
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
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.primaryVolt.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Phase ${workout.currentPhase.phaseNumber}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primaryVolt,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // TODAY'S WORKOUT HERO CARD
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: isDark ? AppColors.darkCardGradient : null,
              color: isDark ? null : AppColors.lightCard,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
              ),
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
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryVolt.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'DAY ${todayWorkout.dayNumber} OF 5',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primaryVolt,
                        ),
                      ),
                    ),
                    Text(
                      '${todayWorkout.exercises.length} Exercises',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
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
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0x33000000) : const Color(0x0C000000),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.shield_outlined, size: 14, color: AppColors.primaryVolt),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          todayWorkout.biomechanicalFocus,
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          ref.read(workoutProvider.notifier).startWorkoutSession(workout.selectedDayIndex);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const ActiveWorkoutScreen()),
                          );
                        },
                        icon: const Icon(Icons.play_arrow_rounded),
                        label: const Text('Start Workout'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // MANDATORY APT 10-MIN ROUTINE QUICK CARD
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AptRoutineScreen()),
              );
            },
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryIndigo.withValues(alpha: isDark ? 0.15 : 0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.primaryIndigo.withValues(alpha: 0.4),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primaryIndigo.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.accessibility_new_rounded,
                      color: AppColors.primaryIndigo,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'MANDATORY PRE-WORKOUT APT ROUTINE',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primaryIndigo,
                            letterSpacing: 0.6,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          '10-Min Pelvic Alignment',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '90/90 Breathing • Couch Stretch • Deadbug • Glute Bridge',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.primaryIndigo),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // TWO-COLUMN QUICK STATS (NUTRITION & SUPPLEMENTS)
          Row(
            children: [
              // Nutrition Card
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCard : AppColors.lightCard,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Icon(Icons.restaurant_rounded, size: 18, color: AppColors.primaryOrange),
                          Text(
                            biometrics.isRestDay ? 'REST DAY' : 'TRAINING',
                            style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.primaryOrange),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '${loggedCals.toInt()} / ${targetCals.toInt()}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const Text(
                        'Calories Logged',
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: (targetCals > 0) ? (loggedCals / targetCals).clamp(0.0, 1.0) : 0,
                        backgroundColor: isDark ? Colors.white10 : Colors.black12,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryOrange),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Supplements Card
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCard : AppColors.lightCard,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Icon(Icons.medication_rounded, size: 18, color: AppColors.primaryCyan),
                          Text(
                            'MUTUAL LOCK',
                            style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.warningGold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '$completedSupps of $totalSupps Doses',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const Text(
                        'Clinical Timing Active',
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: (totalSupps > 0) ? (completedSupps / totalSupps).clamp(0.0, 1.0) : 0,
                        backgroundColor: isDark ? Colors.white10 : Colors.black12,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryCyan),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Recent Completed Workouts History
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'RECENT TRAINING LOGS',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.8,
                  color: AppColors.primaryVolt,
                ),
              ),
              Text(
                '${workout.history.length} Sessions Logged',
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 8),

          ...workout.history.take(3).map((hist) {
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.primaryVolt.withValues(alpha: 0.15),
                  child: const Icon(Icons.check_rounded, color: AppColors.primaryVolt, size: 20),
                ),
                title: Text(
                  hist.dayTitle,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  '${hist.totalSets} Sets • ${hist.totalVolumeKg.toInt()} kg Total Volume',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
                trailing: Text(
                  '${hist.durationMinutes}m',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryCyan),
                ),
              ),
            );
          }),
          const SizedBox(height: 24),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nutrition & Supplements'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primaryVolt,
          labelColor: AppColors.primaryVolt,
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
