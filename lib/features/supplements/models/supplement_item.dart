enum SupplementTiming {
  morning, // 08:00 AM
  postWorkout, // 05:30 PM
  evening, // 08:00 PM
  preBed, // 10:30 PM
}

extension SupplementTimingExtension on SupplementTiming {
  String get timeLabel {
    switch (this) {
      case SupplementTiming.morning:
        return '08:00 AM';
      case SupplementTiming.postWorkout:
        return '05:30 PM';
      case SupplementTiming.evening:
        return '08:00 PM';
      case SupplementTiming.preBed:
        return '10:30 PM';
    }
  }

  String get timingTitle {
    switch (this) {
      case SupplementTiming.morning:
        return 'Morning Protocol (With Meal 1 Fats)';
      case SupplementTiming.postWorkout:
        return 'Post-Workout Anabolic Surge';
      case SupplementTiming.evening:
        return 'Evening Cortisol Blunting (With Meal 3)';
      case SupplementTiming.preBed:
        return 'Pre-Bed Neuro-Muscular Relaxation';
    }
  }
}

class SupplementItem {
  final String id;
  final String name;
  final String dosage;
  final SupplementTiming timing;
  final String mechanism;
  final String warning;
  final bool isCompleted;
  final bool isMutuallyExclusive; // Multi-vitamin conflict check

  const SupplementItem({
    required this.id,
    required this.name,
    required this.dosage,
    required this.timing,
    required this.mechanism,
    this.warning = '',
    this.isCompleted = false,
    this.isMutuallyExclusive = false,
  });

  SupplementItem copyWith({
    String? id,
    String? name,
    String? dosage,
    SupplementTiming? timing,
    String? mechanism,
    String? warning,
    bool? isCompleted,
    bool? isMutuallyExclusive,
  }) {
    return SupplementItem(
      id: id ?? this.id,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      timing: timing ?? this.timing,
      mechanism: mechanism ?? this.mechanism,
      warning: warning ?? this.warning,
      isCompleted: isCompleted ?? this.isCompleted,
      isMutuallyExclusive: isMutuallyExclusive ?? this.isMutuallyExclusive,
    );
  }
}
