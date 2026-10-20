/// Known local MP4 video keys available in assets/videos/
const Set<String> _kAvailableLocalVideoKeys = {
  'ab_wheel',
  'assisted_dips',
  'assisted_nordic_curl',
  'assisted_pull_ups',
  'back_extension_45',
  'ball_hamstring_curl',
  'ball_rollout',
  'barbell_bench_press',
  'barbell_rdl',
  'barbell_seal_row',
  'bayesian_cable_curl',
  'breathing_9090',
  'bulgarian_split_squat',
  'cable_fly',
  'cable_lateral_raise',
  'cable_pull_through',
  'chest_supported_db_row',
  'chest_supported_row',
  'close_grip_pulldown',
  'couch_stretch',
  'cross_body_hammer_curl',
  'db_lateral_raise',
  'db_rdl',
  'db_shoulder_press',
  'deadbug',
  'dual_rope_pushdown',
  'dumbbell_pullover',
  'face_pulls',
  'flat_db_press',
  'glute_back_extension',
  'glute_bridge',
  'glute_drive_machine',
  'goblet_squat',
  'hack_squat',
  'hammer_curl',
  'hanging_knee_tuck',
  'hip_thrust',
  'incline_curl',
  'incline_db_press',
  'incline_machine_press',
  'incline_smith_press',
  'iso_lateral_row',
  'kettlebell_swing',
  'kneeling_lat_pulldown',
  'landmine_press',
  'lat_prayer',
  'lat_pulldown',
  'leg_press_45',
  'leg_press_toe_press',
  'lying_leg_curl',
  'machine_lateral_raise',
  'machine_shoulder_press',
  'nautilus_pullover',
  'overhead_triceps',
  'pallof_press',
  'pec_deck_machine',
  'plank_pull_through',
  'preacher_curl',
  'prone_incline_rear_delt_fly',
  'rear_delt_db_fly',
  'reverse_crunch',
  'reverse_pec_deck',
  'rkc_plank',
  'rope_cable_hammer_curl',
  'rope_triceps_pushdown',
  'seated_cable_row',
  'seated_calf_raise',
  'seated_leg_curl',
  'seated_machine_press',
  'side_plank',
  'single_arm_cable_pushdown',
  'single_arm_lat_pulldown',
  'single_arm_machine_row',
  'single_leg_press',
  'skullcrushers',
  'smith_hip_thrust',
  'spider_curl',
  'standing_calf_raise',
  'straight_bar_pushdown',
  'walking_lunges',
};

class ExerciseAlternative {
  final String id;
  final String name;
  final String targetMuscle;
  final String description;
  final String equipment;
  final String biomechanicalCue;
  final String? assetAnimationPath; // Quick loop GIF from exercises-dataset
  final String? assetVideoPath;     // Detailed breakdown video from YouTube (MP4)
  final String? onlineHdVideoUrl;
  final String? thumbnailPath;
  final String? onlineThumbnailUrl;

  const ExerciseAlternative({
    required this.id,
    required this.name,
    required this.targetMuscle,
    required this.description,
    required this.equipment,
    required this.biomechanicalCue,
    this.assetAnimationPath,
    this.assetVideoPath,
    this.onlineHdVideoUrl,
    this.thumbnailPath,
    this.onlineThumbnailUrl,
  });

  /// Resolves the dedicated MP4 video path if one exists locally.
  String? get resolvedVideoPath {
    if (assetVideoPath != null && assetVideoPath!.isNotEmpty) {
      return assetVideoPath;
    }
    if (assetAnimationPath != null && assetAnimationPath!.isNotEmpty) {
      final fileName = assetAnimationPath!.split('/').last;
      final key = fileName.replaceAll('.gif', '');
      if (_kAvailableLocalVideoKeys.contains(key)) {
        return 'assets/videos/$key.mp4';
      }
    }
    return null;
  }

  bool get hasDetailedLocalVideo => resolvedVideoPath != null;
}

class Exercise {
  final String id;
  final String name;
  final String targetMuscle;
  final int defaultSets;
  final String defaultReps;
  final String defaultRir;
  final int defaultRestSeconds;
  final String biomechanicalCues;
  final String equipment;
  final String assetAnimationPath; // Quick concept loop GIF (from exercises-dataset)
  final String assetVideoPath;     // In-depth tutorial video (from YouTube MP4)
  final String onlineHdVideoUrl;
  final List<ExerciseAlternative> alternatives;
  final String? activeAlternativeId; // null if original exercise is active
  final String illustrationKey;
  final String? thumbnailPath;
  final String? onlineThumbnailUrl;

  const Exercise({
    required this.id,
    required this.name,
    required this.targetMuscle,
    required this.defaultSets,
    required this.defaultReps,
    required this.defaultRir,
    required this.defaultRestSeconds,
    required this.biomechanicalCues,
    required this.equipment,
    required this.assetAnimationPath,
    required this.assetVideoPath,
    required this.onlineHdVideoUrl,
    required this.alternatives,
    this.activeAlternativeId,
    required this.illustrationKey,
    this.thumbnailPath,
    this.onlineThumbnailUrl,
  });

  bool get isSwapped => activeAlternativeId != null;

  ExerciseAlternative? get activeAlternative {
    if (activeAlternativeId == null) return null;
    try {
      return alternatives.firstWhere((a) => a.id == activeAlternativeId);
    } catch (_) {
      return null;
    }
  }

  String get activeName {
    final alt = activeAlternative;
    return alt != null ? alt.name : name;
  }

  String get activeTargetMuscle {
    final alt = activeAlternative;
    return alt != null ? alt.targetMuscle : targetMuscle;
  }

  String get activeEquipment {
    final alt = activeAlternative;
    return alt != null ? alt.equipment : equipment;
  }

  String get activeBiomechanicalCue {
    final alt = activeAlternative;
    return alt != null ? alt.biomechanicalCue : biomechanicalCues;
  }

  String get activeAssetAnimationPath {
    final alt = activeAlternative;
    if (alt != null && alt.assetAnimationPath != null && alt.assetAnimationPath!.isNotEmpty) {
      return alt.assetAnimationPath!;
    }
    return assetAnimationPath;
  }

  /// Returns the video asset path for the active exercise.
  /// If swapped, it uses the swapped alternative's dedicated MP4 or GIF animation.
  /// NEVER falls back to the primary baseline exercise's video when swapped!
  String get activeAssetVideoPath {
    final alt = activeAlternative;
    if (alt == null) return assetVideoPath;

    // Check if the alternative has a local MP4
    final altVideo = alt.resolvedVideoPath;
    if (altVideo != null && altVideo.isNotEmpty) {
      return altVideo;
    }

    // Fall back to the swapped alternative's animation path (GIF)
    if (alt.assetAnimationPath != null && alt.assetAnimationPath!.isNotEmpty) {
      return alt.assetAnimationPath!;
    }
    return '';
  }

  bool get hasDownloadedVideo => hasDetailedLocalVideo;

  bool get hasDetailedLocalVideo {
    final path = activeAssetVideoPath;
    return path.isNotEmpty && path.toLowerCase().endsWith('.mp4');
  }

  String get activeOnlineHdVideoUrl {
    final alt = activeAlternative;
    if (alt != null && alt.onlineHdVideoUrl != null && alt.onlineHdVideoUrl!.isNotEmpty) {
      return alt.onlineHdVideoUrl!;
    }
    return onlineHdVideoUrl;
  }

  String get activeThumbnailPath {
    final alt = activeAlternative;
    if (alt != null && alt.thumbnailPath != null && alt.thumbnailPath!.isNotEmpty) {
      return alt.thumbnailPath!;
    }
    return thumbnailPath ?? '';
  }

  Exercise copyWith({
    String? id,
    String? name,
    String? targetMuscle,
    int? defaultSets,
    String? defaultReps,
    String? defaultRir,
    int? defaultRestSeconds,
    String? biomechanicalCues,
    String? equipment,
    String? assetAnimationPath,
    String? assetVideoPath,
    String? onlineHdVideoUrl,
    List<ExerciseAlternative>? alternatives,
    String? activeAlternativeId,
    bool clearActiveAlternative = false,
    String? illustrationKey,
    String? thumbnailPath,
    String? onlineThumbnailUrl,
  }) {
    return Exercise(
      id: id ?? this.id,
      name: name ?? this.name,
      targetMuscle: targetMuscle ?? this.targetMuscle,
      defaultSets: defaultSets ?? this.defaultSets,
      defaultReps: defaultReps ?? this.defaultReps,
      defaultRir: defaultRir ?? this.defaultRir,
      defaultRestSeconds: defaultRestSeconds ?? this.defaultRestSeconds,
      biomechanicalCues: biomechanicalCues ?? this.biomechanicalCues,
      equipment: equipment ?? this.equipment,
      assetAnimationPath: assetAnimationPath ?? this.assetAnimationPath,
      assetVideoPath: assetVideoPath ?? this.assetVideoPath,
      onlineHdVideoUrl: onlineHdVideoUrl ?? this.onlineHdVideoUrl,
      alternatives: alternatives ?? this.alternatives,
      activeAlternativeId: clearActiveAlternative ? null : (activeAlternativeId ?? this.activeAlternativeId),
      illustrationKey: illustrationKey ?? this.illustrationKey,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      onlineThumbnailUrl: onlineThumbnailUrl ?? this.onlineThumbnailUrl,
    );
  }
}
