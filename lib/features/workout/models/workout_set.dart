class WorkoutSet {
  final int setNumber;
  final double weightKg;
  final int reps;
  final int rir; // Reps In Reserve
  final bool isCompleted;

  const WorkoutSet({
    required this.setNumber,
    this.weightKg = 0.0,
    this.reps = 10,
    this.rir = 2,
    this.isCompleted = false,
  });

  WorkoutSet copyWith({
    int? setNumber,
    double? weightKg,
    int? reps,
    int? rir,
    bool? isCompleted,
  }) {
    return WorkoutSet(
      setNumber: setNumber ?? this.setNumber,
      weightKg: weightKg ?? this.weightKg,
      reps: reps ?? this.reps,
      rir: rir ?? this.rir,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
