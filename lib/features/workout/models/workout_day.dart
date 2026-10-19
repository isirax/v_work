import 'exercise.dart';

class WorkoutDay {
  final int dayNumber;
  final String title;
  final String subtitle;
  final String targetEmphasis;
  final String biomechanicalFocus;
  final List<Exercise> exercises;

  const WorkoutDay({
    required this.dayNumber,
    required this.title,
    required this.subtitle,
    required this.targetEmphasis,
    required this.biomechanicalFocus,
    required this.exercises,
  });

  WorkoutDay copyWith({
    int? dayNumber,
    String? title,
    String? subtitle,
    String? targetEmphasis,
    String? biomechanicalFocus,
    List<Exercise>? exercises,
  }) {
    return WorkoutDay(
      dayNumber: dayNumber ?? this.dayNumber,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      targetEmphasis: targetEmphasis ?? this.targetEmphasis,
      biomechanicalFocus: biomechanicalFocus ?? this.biomechanicalFocus,
      exercises: exercises ?? this.exercises,
    );
  }
}
