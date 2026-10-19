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

  String get activeName {
    if (activeAlternativeId == null) return name;
    final alt = alternatives.firstWhere(
      (a) => a.id == activeAlternativeId,
      orElse: () => alternatives.first,
    );
    return alt.name;
  }

  String get activeBiomechanicalCue {
    if (activeAlternativeId == null) return biomechanicalCues;
    final alt = alternatives.firstWhere(
      (a) => a.id == activeAlternativeId,
      orElse: () => alternatives.first,
    );
    return alt.biomechanicalCue;
  }

  String get activeAssetAnimationPath {
    if (activeAlternativeId == null) return assetAnimationPath;
    final alt = alternatives.firstWhere(
      (a) => a.id == activeAlternativeId,
      orElse: () => alternatives.first,
    );
    return alt.assetAnimationPath ?? assetAnimationPath;
  }

  String get activeAssetVideoPath {
    if (activeAlternativeId == null) return assetVideoPath;
    final alt = alternatives.firstWhere(
      (a) => a.id == activeAlternativeId,
      orElse: () => alternatives.first,
    );
    return alt.assetVideoPath ?? assetVideoPath;
  }

  bool get hasDownloadedVideo => hasDetailedLocalVideo;

  bool get hasDetailedLocalVideo {
    final path = activeAssetVideoPath;
    return path.isNotEmpty && path.toLowerCase().endsWith('.mp4');
  }

  String get activeOnlineHdVideoUrl {
    if (activeAlternativeId == null) return onlineHdVideoUrl;
    final alt = alternatives.firstWhere(
      (a) => a.id == activeAlternativeId,
      orElse: () => alternatives.first,
    );
    return alt.onlineHdVideoUrl ?? onlineHdVideoUrl;
  }

  String get activeThumbnailPath {
    if (activeAlternativeId == null) return thumbnailPath ?? '';
    final alt = alternatives.firstWhere(
      (a) => a.id == activeAlternativeId,
      orElse: () => alternatives.first,
    );
    return alt.thumbnailPath ?? thumbnailPath ?? '';
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
