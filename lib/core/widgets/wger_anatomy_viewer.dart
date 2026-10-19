import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../constants/app_colors.dart';

class MuscleTargetMapping {
  final List<int> primaryMuscleIds;
  final List<int> secondaryMuscleIds;
  final bool defaultIsFront;
  final String primaryLabel;
  final String secondaryLabel;
  final String biomechanicalAction;

  const MuscleTargetMapping({
    required this.primaryMuscleIds,
    this.secondaryMuscleIds = const [],
    required this.defaultIsFront,
    required this.primaryLabel,
    this.secondaryLabel = '',
    this.biomechanicalAction = '',
  });
}

class WgerAnatomyViewer extends StatefulWidget {
  final String exerciseKey;
  final String? exerciseName;
  final String? animationPath;
  final String? targetMuscle;
  final double height;

  const WgerAnatomyViewer({
    super.key,
    required this.exerciseKey,
    this.exerciseName,
    this.animationPath,
    this.targetMuscle,
    this.height = 260,
  });

  static MuscleTargetMapping getMapping(String key, [String? name]) {
    final lower = '${key.toLowerCase()} ${name?.toLowerCase() ?? ''}';

    // 1. CHEST / PECS
    if (lower.contains('incline') && (lower.contains('press') || lower.contains('bench'))) {
      return const MuscleTargetMapping(
        primaryMuscleIds: [4], // Pectoralis Major
        secondaryMuscleIds: [2], // Anterior Deltoid
        defaultIsFront: true,
        primaryLabel: 'Pectoralis Major (Clavicular Upper Head)',
        secondaryLabel: 'Anterior Deltoids & Triceps Brachii',
        biomechanicalAction: 'Shoulder Flexion & Horizontal Adduction',
      );
    }
    if (lower.contains('reverse pec') || lower.contains('rear delt')) {
      return const MuscleTargetMapping(
        primaryMuscleIds: [2, 9], // Rear deltoid & Trapezius
        secondaryMuscleIds: [12], // Lats / Rhomboids
        defaultIsFront: false,
        primaryLabel: 'Posterior Deltoids & Rhomboids',
        secondaryLabel: 'Middle & Lower Trapezius, Infraspinatus',
        biomechanicalAction: 'Horizontal Abduction & Scapular Retraction',
      );
    }
    if (lower.contains('fly') || lower.contains('pec') || lower.contains('flat db press') || (lower.contains('press') && !lower.contains('shoulder') && !lower.contains('overhead') && !lower.contains('leg') && !lower.contains('pallof'))) {
      return const MuscleTargetMapping(
        primaryMuscleIds: [4], // Pectoralis Major
        secondaryMuscleIds: [2, 5], // Delts & Triceps
        defaultIsFront: true,
        primaryLabel: 'Pectoralis Major (Sternal & Costal Fibers)',
        secondaryLabel: 'Anterior Deltoids & Triceps Brachii',
        biomechanicalAction: 'Horizontal Adduction with Scapular Retraction',
      );
    }

    // 2. BACK / LATS / ROWS
    if (lower.contains('lat prayer') || lower.contains('straight arm')) {
      return const MuscleTargetMapping(
        primaryMuscleIds: [12], // Lats
        secondaryMuscleIds: [5, 3], // Triceps long head, Serratus
        defaultIsFront: false,
        primaryLabel: 'Latissimus Dorsi (Sagittal Arc Isolation)',
        secondaryLabel: 'Triceps Long Head, Teres Major & Serratus',
        biomechanicalAction: 'Pure Shoulder Extension without Elbow Flexion',
      );
    }
    if (lower.contains('row') || lower.contains('pulldown') || lower.contains('lat')) {
      final isRow = lower.contains('row');
      return MuscleTargetMapping(
        primaryMuscleIds: const [12, 9], // Lats & Mid-Traps
        secondaryMuscleIds: const [1, 2], // Biceps, Rear Delts
        defaultIsFront: false,
        primaryLabel: isRow ? 'Mid-Trapezius, Rhomboids & Latissimus Dorsi' : 'Latissimus Dorsi (Iliac & Costal fibers)',
        secondaryLabel: 'Biceps Brachii, Posterior Deltoid & Brachialis',
        biomechanicalAction: isRow ? 'Scapular Retraction & Glenohumeral Extension' : 'Scapular Depression & Glenohumeral Adduction',
      );
    }

    // 3. SHOULDERS
    if (lower.contains('lateral raise')) {
      return const MuscleTargetMapping(
        primaryMuscleIds: [2], // Lateral Deltoid
        secondaryMuscleIds: [9], // Traps
        defaultIsFront: true,
        primaryLabel: 'Lateral Deltoids (Acromial Head)',
        secondaryLabel: 'Supraspinatus & Upper Trapezius',
        biomechanicalAction: 'Shoulder Abduction in Scaption Plane (30° forward)',
      );
    }
    if (lower.contains('face pull')) {
      return const MuscleTargetMapping(
        primaryMuscleIds: [2, 9], // Rear delt & Trapezius
        secondaryMuscleIds: [],
        defaultIsFront: false,
        primaryLabel: 'Posterior Deltoids & External Rotators (Infraspinatus)',
        secondaryLabel: 'Middle & Lower Trapezius',
        biomechanicalAction: 'External Rotation with Scapular Retraction',
      );
    }
    if (lower.contains('shoulder') || lower.contains('overhead press')) {
      return const MuscleTargetMapping(
        primaryMuscleIds: [2], // Deltoid
        secondaryMuscleIds: [5, 9], // Triceps, Traps
        defaultIsFront: true,
        primaryLabel: 'Deltoids (Anterior & Medial Heads)',
        secondaryLabel: 'Triceps Brachii & Upper Trapezius',
        biomechanicalAction: 'Vertical Shoulder Pressing & Scapular Elevation',
      );
    }

    // 4. ARMS (BICEPS / TRICEPS)
    if (lower.contains('curl') || lower.contains('bicep')) {
      final isPreacher = lower.contains('preacher');
      final isHammer = lower.contains('hammer');
      return MuscleTargetMapping(
        primaryMuscleIds: const [1, 13], // Biceps & Brachialis
        secondaryMuscleIds: const [],
        defaultIsFront: true,
        primaryLabel: isHammer
            ? 'Brachialis & Brachioradialis (Forearm)'
            : (isPreacher ? 'Biceps Brachii (Short Inner Head)' : 'Biceps Brachii (Long Outer Head & Peak)'),
        secondaryLabel: 'Brachialis & Wrist Flexors',
        biomechanicalAction: 'Elbow Flexion with Supination / Neutral Grip',
      );
    }
    if (lower.contains('tricep') || lower.contains('pushdown') || lower.contains('overhead triceps')) {
      final isOverhead = lower.contains('overhead');
      return MuscleTargetMapping(
        primaryMuscleIds: const [5], // Triceps
        secondaryMuscleIds: const [],
        defaultIsFront: false,
        primaryLabel: isOverhead ? 'Triceps Brachii (Long Head Full Stretch)' : 'Triceps Brachii (Lateral & Medial Heads)',
        secondaryLabel: 'Anconeus & Core Stabilizers',
        biomechanicalAction: 'Elbow Extension with Fixed Shoulder Angle',
      );
    }

    // 5. LEGS (QUADS / HAMSTRINGS / GLUTES / CALVES)
    if (lower.contains('squat') || lower.contains('split squat') || lower.contains('lunge')) {
      final isBulgarian = lower.contains('split squat') || lower.contains('bulgarian');
      return MuscleTargetMapping(
        primaryMuscleIds: isBulgarian ? const [8, 10] : const [10, 8],
        secondaryMuscleIds: const [11], // Hamstrings
        defaultIsFront: !isBulgarian,
        primaryLabel: isBulgarian ? 'Gluteus Maximus (Lengthened Arc) & Quads' : 'Quadriceps Femoris (Vastus Lateralis/Medialis)',
        secondaryLabel: 'Gluteus Medius, Adductor Magnus & Hamstrings',
        biomechanicalAction: 'Knee Extension coupled with Hip Extension',
      );
    }
    if (lower.contains('hip thrust') || lower.contains('glute bridge') || lower.contains('pull through') || lower.contains('pull-through')) {
      return const MuscleTargetMapping(
        primaryMuscleIds: [8], // Gluteus maximus
        secondaryMuscleIds: [11], // Hamstrings
        defaultIsFront: false,
        primaryLabel: 'Gluteus Maximus (Peak Shortened Contraction)',
        secondaryLabel: 'Biceps Femoris & Adductor Magnus',
        biomechanicalAction: 'Terminal Hip Extension with Posterior Pelvic Tilt',
      );
    }
    if (lower.contains('rdl') || lower.contains('deadlift') || lower.contains('leg curl') || lower.contains('hamstring')) {
      final isCurl = lower.contains('curl');
      return MuscleTargetMapping(
        primaryMuscleIds: const [11], // Hamstrings
        secondaryMuscleIds: isCurl ? const [7] : const [8], // Glutes or Calves
        defaultIsFront: false,
        primaryLabel: isCurl ? 'Biceps Femoris, Semitendinosus & Semimembranosus' : 'Hamstrings (Lengthened Hinge) & Gluteus Maximus',
        secondaryLabel: isCurl ? 'Gastrocnemius' : 'Erector Spinae & Gluteal Complex',
        biomechanicalAction: isCurl ? 'Knee Flexion' : 'Hip Hinge with Posterior Pelvic Control',
      );
    }
    if (lower.contains('calf') || lower.contains('calves')) {
      return const MuscleTargetMapping(
        primaryMuscleIds: [7, 15], // Gastrocnemius & Soleus
        secondaryMuscleIds: [],
        defaultIsFront: false,
        primaryLabel: 'Gastrocnemius (Lateral & Medial Heads) & Soleus',
        secondaryLabel: 'Tibialis Posterior & Plantaris',
        biomechanicalAction: 'Plantar Flexion with Full Ankle Dorsiflexion',
      );
    }

    // 6. CORE & APT REHAB
    if (lower.contains('ab wheel') || lower.contains('crunch') || lower.contains('deadbug') || lower.contains('breathing') || lower.contains('pallof') || lower.contains('abs')) {
      final isPallof = lower.contains('pallof');
      return MuscleTargetMapping(
        primaryMuscleIds: const [6, 14], // Rectus Abdominis & Obliques
        secondaryMuscleIds: const [3], // Serratus
        defaultIsFront: true,
        primaryLabel: isPallof ? 'Internal & External Obliques (Anti-Rotation)' : 'Rectus Abdominis & Transverse Abdominis (Anti-Extension)',
        secondaryLabel: 'Serratus Anterior & Gluteal Stabilizers',
        biomechanicalAction: isPallof ? 'Isometric Anti-Rotation Resistance' : 'Posterior Pelvic Tilt & Ribcage Lock-Down',
      );
    }

    if (lower.contains('couch stretch') || lower.contains('psoas') || lower.contains('stretch')) {
      return const MuscleTargetMapping(
        primaryMuscleIds: [10], // Quads / Rectus Femoris
        secondaryMuscleIds: [8], // Glutes
        defaultIsFront: true,
        primaryLabel: 'Iliopsoas, Psoas Major & Rectus Femoris',
        secondaryLabel: 'Gluteus Maximus (Reciprocal Inhibition)',
        biomechanicalAction: 'Passive Hip Flexor Lengthening with Glute Squeeze',
      );
    }

    // Fallback default
    return const MuscleTargetMapping(
      primaryMuscleIds: [4, 6],
      secondaryMuscleIds: [2],
      defaultIsFront: true,
      primaryLabel: 'Compound Torso & Muscular Complex',
      secondaryLabel: 'Shoulder & Core Stabilizers',
      biomechanicalAction: 'Dynamic Multi-Joint Resistance',
    );
  }

  @override
  State<WgerAnatomyViewer> createState() => _WgerAnatomyViewerState();
}

class _WgerAnatomyViewerState extends State<WgerAnatomyViewer> {
  // 0: Active Muscle Highlight Animation (from exercises-dataset), 1: Anatomical Body Map (Front/Back)
  int _viewMode = 0;
  late bool _isFront;
  late MuscleTargetMapping _mapping;

  @override
  void initState() {
    super.initState();
    _mapping = WgerAnatomyViewer.getMapping(widget.exerciseKey, widget.exerciseName);
    _isFront = _mapping.defaultIsFront;
    // If no animation path is available, default to Body Map
    if (widget.animationPath == null || widget.animationPath!.isEmpty) {
      _viewMode = 1;
    }
  }

  @override
  void didUpdateWidget(covariant WgerAnatomyViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.exerciseKey != widget.exerciseKey ||
        oldWidget.exerciseName != widget.exerciseName ||
        oldWidget.animationPath != widget.animationPath) {
      _mapping = WgerAnatomyViewer.getMapping(widget.exerciseKey, widget.exerciseName);
      _isFront = _mapping.defaultIsFront;
      if (widget.animationPath == null || widget.animationPath!.isEmpty) {
        _viewMode = 1;
      }
    }
  }

  bool _isMuscleOnView(int muscleId, bool isFront) {
    const frontMuscles = {1, 2, 3, 4, 6, 10, 13, 14};
    return isFront ? frontMuscles.contains(muscleId) : !frontMuscles.contains(muscleId);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasAnimation = widget.animationPath != null && widget.animationPath!.isNotEmpty;

    final baseSvgPath = _isFront
        ? 'assets/muscles/muscular_system_front.svg'
        : 'assets/muscles/muscular_system_back.svg';

    final activePrimary = _mapping.primaryMuscleIds.where((id) => _isMuscleOnView(id, _isFront)).toList();
    final activeSecondary = _mapping.secondaryMuscleIds.where((id) => _isMuscleOnView(id, _isFront)).toList();

    return Container(
      constraints: BoxConstraints(minHeight: widget.height),
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0A0E17) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. Top Mode Selector Bar
          Padding(
            padding: const EdgeInsets.only(top: 10, left: 10, right: 10, bottom: 6),
            child: Row(
              children: [
                // View Mode Switcher
                if (hasAnimation) ...[
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: (isDark ? Colors.black : Colors.white).withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildToggleBtn(
                          label: 'Active Muscles (Red)',
                          icon: Icons.flash_on_rounded,
                          isSelected: _viewMode == 0,
                          onTap: () => setState(() => _viewMode = 0),
                          isDark: isDark,
                        ),
                        const SizedBox(width: 4),
                        _buildToggleBtn(
                          label: 'Body Map',
                          icon: Icons.accessibility_new_rounded,
                          isSelected: _viewMode == 1,
                          onTap: () => setState(() => _viewMode = 1),
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ),
                ],

                const Spacer(),

                // Anterior / Posterior Switcher (Only active when in Body Map mode)
                if (_viewMode == 1)
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: (isDark ? Colors.black : Colors.white).withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildToggleBtn(
                          label: 'Front',
                          icon: Icons.flip_to_front_rounded,
                          isSelected: _isFront,
                          onTap: () => setState(() => _isFront = true),
                          isDark: isDark,
                        ),
                        const SizedBox(width: 3),
                        _buildToggleBtn(
                          label: 'Back',
                          icon: Icons.flip_to_back_rounded,
                          isSelected: !_isFront,
                          onTap: () => setState(() => _isFront = false),
                          isDark: isDark,
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.75),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFFF3B30).withValues(alpha: 0.7)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.fiber_manual_record_rounded, size: 9, color: Color(0xFFFF3B30)),
                        SizedBox(width: 5),
                        Text(
                          'RED = WORKING MUSCLE',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFFFF3B30),
                            letterSpacing: 0.4,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // 2. Middle Visual Display (Active Muscle Animation or Anatomical Body Map)
          SizedBox(
            height: widget.height * 0.72,
            child: _viewMode == 0 && hasAnimation
                ? Center(
                    child: Image.asset(
                      widget.animationPath!,
                      fit: BoxFit.contain,
                      errorBuilder: (ctx, err, st) => const Icon(
                        Icons.fitness_center_rounded,
                        size: 40,
                        color: AppColors.primaryVolt,
                      ),
                    ),
                  )
                : Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: AspectRatio(
                        aspectRatio: 200 / 369,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            // Base silhouette
                            SvgPicture.asset(
                              baseSvgPath,
                              colorFilter: ColorFilter.mode(
                                isDark ? const Color(0xFF2A3342) : const Color(0xFF94A3B8),
                                BlendMode.srcIn,
                              ),
                              placeholderBuilder: (_) => const SizedBox(),
                              errorBuilder: (_, _, _) => const SizedBox(),
                            ),

                            // Primary Target Muscle Highlights (Volt Neon Green)
                            for (final id in activePrimary)
                              SvgPicture.asset(
                                'assets/muscles/main/muscle-$id.svg',
                                colorFilter: const ColorFilter.mode(
                                  AppColors.primaryVolt,
                                  BlendMode.srcIn,
                                ),
                                placeholderBuilder: (_) => const SizedBox(),
                                errorBuilder: (_, _, _) => const SizedBox(),
                              ),

                            // Secondary Target Muscle Highlights (Cyan Blue)
                            for (final id in activeSecondary)
                              SvgPicture.asset(
                                'assets/muscles/secondary/muscle-$id.svg',
                                colorFilter: const ColorFilter.mode(
                                  AppColors.primaryCyan,
                                  BlendMode.srcIn,
                                ),
                                placeholderBuilder: (_) => const SizedBox(),
                                errorBuilder: (_, _, _) => const SizedBox(),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
          ),

          // 3. Bottom Anatomical Details Box
          Padding(
            padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10, top: 4),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isDark ? Colors.black87 : Colors.white.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Primary muscle
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 3),
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.primaryVolt,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'PRIMARY: ',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primaryVolt,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          _mapping.primaryLabel,
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Secondary muscle
                  if (_mapping.secondaryLabel.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 3),
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.primaryCyan,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'SYNERGISTS: ',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primaryCyan,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            _mapping.secondaryLabel,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],

                  // Biomechanical action
                  if (_mapping.biomechanicalAction.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 3),
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.primaryOrange,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'ACTION: ',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primaryOrange,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            _mapping.biomechanicalAction,
                            style: TextStyle(
                              fontSize: 9.5,
                              fontStyle: FontStyle.italic,
                              color: isDark ? Colors.white70 : Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleBtn({
    required String label,
    IconData? icon,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AppColors.primaryVolt : const Color(0xFF00C875))
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 11,
                color: isSelected
                    ? Colors.black
                    : (isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted),
              ),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.bold,
                color: isSelected
                    ? Colors.black
                    : (isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
