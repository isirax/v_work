import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/workout_provider.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/widgets/common/v_badge.dart';
import '../models/periodization.dart';

class MesocycleScreen extends ConsumerStatefulWidget {
  const MesocycleScreen({super.key});

  @override
  ConsumerState<MesocycleScreen> createState() => _MesocycleScreenState();
}

class _MesocycleScreenState extends ConsumerState<MesocycleScreen> {
  late final ScrollController _weekScrollController;

  @override
  void initState() {
    super.initState();
    _weekScrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToActiveWeek();
    });
  }

  void _scrollToActiveWeek() {
    if (!_weekScrollController.hasClients) return;
    final currentWeek = ref.read(workoutProvider).currentWeek;
    // Each chip is ~56px wide including margin
    final targetOffset = ((currentWeek - 1) * 58.0) - 80.0;
    _weekScrollController.animateTo(
      targetOffset.clamp(0.0, _weekScrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _weekScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final workout = ref.watch(workoutProvider);
    final activeWeek = workout.currentWeek;
    final activePhase = workout.currentPhase;
    final palette = context.palette;
    final isDark = context.isDark;
    final progress = activeWeek / 24.0;

    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        title: const Text('Mesocycle Periodization'),
        backgroundColor: palette.surface,
        elevation: 0,
      ),
      body: ListView(
        padding: Insets.page,
        children: [
          // Active Mesocycle Header Card
          Container(
            padding: const EdgeInsets.all(Insets.lg),
            decoration: BoxDecoration(
              gradient: palette.heroGradient,
              borderRadius: BorderRadius.circular(Radii.xl),
              boxShadow: [
                BoxShadow(
                  color: palette.accent.withValues(alpha: isDark ? 0.2 : 0.15),
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
                        color: Colors.black.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(Radii.sm),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Text(
                        'ACTIVE PHASE ${activePhase.phaseNumber}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    Text(
                      'Week $activeWeek of 24',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Insets.md),
                Text(
                  activePhase.title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: Insets.xs),
                Text(
                  activePhase.durationRange,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
                const SizedBox(height: Insets.md),
                // Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isDark ? const Color(0xFF00E5FF) : Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '${(progress * 100).toInt()}% completed',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.75),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: Insets.lg),

          // Week Selector Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TRAINING WEEK SELECTOR',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.8,
                  color: palette.accent,
                ),
              ),
              Text(
                'Tap to switch week',
                style: TextStyle(
                  fontSize: 11,
                  color: palette.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: Insets.sm),

          SizedBox(
            height: 48,
            child: ListView.builder(
              controller: _weekScrollController,
              scrollDirection: Axis.horizontal,
              itemCount: 24,
              itemBuilder: (context, index) {
                final weekNum = index + 1;
                final isSelected = weekNum == activeWeek;
                // Determine phase for chip styling
                final phaseOfChip = (weekNum <= 8) ? 1 : ((weekNum <= 16) ? 2 : 3);

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: InkWell(
                    onTap: () {
                      ref.read(workoutProvider.notifier).setWeek(weekNum);
                    },
                    borderRadius: BorderRadius.circular(Radii.md),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? palette.accent
                            : palette.surfaceElevated,
                        borderRadius: BorderRadius.circular(Radii.md),
                        border: Border.all(
                          color: isSelected ? palette.accent : palette.border,
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'W$weekNum',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? palette.onAccent
                                  : palette.textPrimary,
                            ),
                          ),
                          Text(
                            'P$phaseOfChip',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? palette.onAccent.withValues(alpha: 0.8)
                                  : palette.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: Insets.lg),

          // Periodization Target Parameters
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
                    Icon(Icons.tune_rounded, size: 16, color: palette.accent),
                    const SizedBox(width: 8),
                    Text(
                      'PHASE TARGET PARAMETERS',
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
                _buildParamRow(
                  palette: palette,
                  icon: Icons.repeat_rounded,
                  title: 'Prescribed Rep Ranges',
                  value: activePhase.repRangeGuide,
                ),
                Divider(height: 24, color: palette.border),
                _buildParamRow(
                  palette: palette,
                  icon: Icons.speed_rounded,
                  title: 'Target RIR (Reps in Reserve)',
                  value: activePhase.rirGuide,
                ),
                Divider(height: 24, color: palette.border),
                _buildParamRow(
                  palette: palette,
                  icon: Icons.accessibility_new_rounded,
                  title: 'Pelvic & APT Biomechanical Strategy',
                  value: activePhase.pelvicStrategy,
                ),
              ],
            ),
          ),
          const SizedBox(height: Insets.md),

          // Progressive Overload Key Rules
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
                    Icon(Icons.bolt_rounded, size: 16, color: palette.warning),
                    const SizedBox(width: 8),
                    Text(
                      'PROGRESSIVE OVERLOAD PROTOCOL',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                        color: palette.warning,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Insets.md),
                ...activePhase.keyRules.map((rule) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: Insets.sm),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.check_circle_rounded,
                          size: 16,
                          color: palette.accent,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            rule,
                            style: TextStyle(
                              fontSize: 13,
                              height: 1.4,
                              color: palette.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: Insets.lg),

          // All 3 Phases Overview
          Text(
            'ALL 24-WEEK MESOCYCLE PHASES',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.8,
              color: palette.accent,
            ),
          ),
          const SizedBox(height: Insets.sm),

          ...PeriodizationPhase.allPhases.map((phase) {
            final isCurrent = phase.phaseNumber == activePhase.phaseNumber;
            final isPast = phase.phaseNumber < activePhase.phaseNumber;

            return Padding(
              padding: const EdgeInsets.only(bottom: Insets.sm),
              child: InkWell(
                onTap: () {
                  // Jump to week 1 of this phase
                  final startWeek = (phase.phaseNumber == 1)
                      ? 1
                      : (phase.phaseNumber == 2 ? 9 : 17);
                  ref.read(workoutProvider.notifier).setWeek(startWeek);
                  _scrollToActiveWeek();
                },
                borderRadius: BorderRadius.circular(Radii.lg),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(Insets.md),
                  decoration: BoxDecoration(
                    color: isCurrent
                        ? palette.accent.withValues(alpha: isDark ? 0.12 : 0.08)
                        : palette.surface,
                    borderRadius: BorderRadius.circular(Radii.lg),
                    border: Border.all(
                      color: isCurrent ? palette.accent : palette.border,
                      width: isCurrent ? 1.5 : 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'PHASE ${phase.phaseNumber} • ${phase.durationRange}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: isCurrent
                                  ? palette.accent
                                  : palette.textMuted,
                              letterSpacing: 0.4,
                            ),
                          ),
                          if (isCurrent)
                            const VBadge(
                              label: 'ACTIVE',
                              variant: VBadgeVariant.accent,
                            )
                          else if (isPast)
                            const VBadge(
                              label: 'COMPLETED',
                              variant: VBadgeVariant.success,
                            )
                          else
                            const VBadge(
                              label: 'UPCOMING',
                              variant: VBadgeVariant.neutral,
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        phase.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        phase.focusDescription,
                        style: TextStyle(
                          fontSize: 12.5,
                          height: 1.35,
                          color: palette.textSecondary,
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
    );
  }

  Widget _buildParamRow({
    required AppPalette palette,
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: palette.accent),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: palette.textMuted,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: palette.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
