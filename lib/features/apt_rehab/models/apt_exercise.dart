enum AptType {
  breathing,
  stretch,
  coreActivation,
  gluteActivation,
}

class AptExercise {
  final String id;
  final String title;
  final String targetMuscles;
  final String protocol;
  final int sets;
  final String repsOrDuration;
  final int durationSeconds; // for timer
  final bool isTimed;
  final String biomechanicalPurpose;
  final List<String> executionCues;
  final String commonMistake;
  final String visualIllustration;
  final String assetAnimationPath;
  final String assetVideoPath;
  final String? onlineHdVideoUrl;

  const AptExercise({
    required this.id,
    required this.title,
    required this.targetMuscles,
    required this.protocol,
    required this.sets,
    required this.repsOrDuration,
    required this.durationSeconds,
    required this.isTimed,
    required this.biomechanicalPurpose,
    required this.executionCues,
    required this.commonMistake,
    required this.visualIllustration,
    required this.assetAnimationPath,
    required this.assetVideoPath,
    this.onlineHdVideoUrl,
  });
}
