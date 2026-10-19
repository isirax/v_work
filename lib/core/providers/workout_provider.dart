import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/workout/data/workout_database.dart';
import '../../features/workout/models/periodization.dart';
import '../../features/workout/models/workout_day.dart';
import '../../features/workout/models/workout_set.dart';

class CompletedWorkout {
  final DateTime timestamp;
  final int dayNumber;
  final String dayTitle;
  final int totalSets;
  final double totalVolumeKg;
  final int durationMinutes;

  const CompletedWorkout({
    required this.timestamp,
    required this.dayNumber,
    required this.dayTitle,
    required this.totalSets,
    required this.totalVolumeKg,
    required this.durationMinutes,
  });
}

class WorkoutState {
  final List<WorkoutDay> split;
  final int selectedDayIndex;
  final int currentWeek; // 1 - 24
  final Map<String, List<WorkoutSet>> activeSessionSets; // exerciseId -> sets
  final bool isSessionActive;
  final int? activeRestSeconds;
  final int? totalRestSeconds;
  final bool isRestRunning;
  final List<CompletedWorkout> history;

  const WorkoutState({
    required this.split,
    this.selectedDayIndex = 0,
    this.currentWeek = 1,
    this.activeSessionSets = const {},
    this.isSessionActive = false,
    this.activeRestSeconds,
    this.totalRestSeconds,
    this.isRestRunning = false,
    this.history = const [],
  });

  PeriodizationPhase get currentPhase {
    if (currentWeek <= 8) return PeriodizationPhase.allPhases[0];
    if (currentWeek <= 16) return PeriodizationPhase.allPhases[1];
    return PeriodizationPhase.allPhases[2];
  }

  WorkoutDay get selectedDay => split[selectedDayIndex];

  WorkoutState copyWith({
    List<WorkoutDay>? split,
    int? selectedDayIndex,
    int? currentWeek,
    Map<String, List<WorkoutSet>>? activeSessionSets,
    bool? isSessionActive,
    int? activeRestSeconds,
    int? totalRestSeconds,
    bool? isRestRunning,
    List<CompletedWorkout>? history,
    bool clearRest = false,
  }) {
    return WorkoutState(
      split: split ?? this.split,
      selectedDayIndex: selectedDayIndex ?? this.selectedDayIndex,
      currentWeek: currentWeek ?? this.currentWeek,
      activeSessionSets: activeSessionSets ?? this.activeSessionSets,
      isSessionActive: isSessionActive ?? this.isSessionActive,
      activeRestSeconds: clearRest ? null : (activeRestSeconds ?? this.activeRestSeconds),
      totalRestSeconds: clearRest ? null : (totalRestSeconds ?? this.totalRestSeconds),
      isRestRunning: clearRest ? false : (isRestRunning ?? this.isRestRunning),
      history: history ?? this.history,
    );
  }
}

final workoutProvider = NotifierProvider<WorkoutNotifier, WorkoutState>(WorkoutNotifier.new);

class WorkoutNotifier extends Notifier<WorkoutState> {
  @override
  WorkoutState build() {
    final defaultSplit = WorkoutDatabase.getDefaultSplit();
    return WorkoutState(
      split: defaultSplit,
      history: [
        CompletedWorkout(
          timestamp: DateTime.now().subtract(const Duration(days: 2)),
          dayNumber: 1,
          dayTitle: 'Upper Body Hypertrophy',
          totalSets: 19,
          totalVolumeKg: 8450,
          durationMinutes: 58,
        ),
        CompletedWorkout(
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
          dayNumber: 2,
          dayTitle: 'Lower Body A: Posterior Chain',
          totalSets: 19,
          totalVolumeKg: 11200,
          durationMinutes: 65,
        ),
      ],
    );
  }

  void selectDay(int index) {
    state = state.copyWith(selectedDayIndex: index);
  }

  void setWeek(int week) {
    state = state.copyWith(currentWeek: week.clamp(1, 24));
  }

  void swapExercise({
    required int dayIndex,
    required String exerciseId,
    required String? alternativeId,
  }) {
    final updatedSplit = List<WorkoutDay>.from(state.split);
    final day = updatedSplit[dayIndex];

    final updatedExercises = day.exercises.map((ex) {
      if (ex.id == exerciseId) {
        return ex.copyWith(
          activeAlternativeId: alternativeId,
          clearActiveAlternative: alternativeId == null,
        );
      }
      return ex;
    }).toList();

    updatedSplit[dayIndex] = day.copyWith(exercises: updatedExercises);
    state = state.copyWith(split: updatedSplit);
  }

  void startWorkoutSession(int dayIndex) {
    final day = state.split[dayIndex];
    final Map<String, List<WorkoutSet>> sessionSets = {};

    for (final ex in day.exercises) {
      sessionSets[ex.id] = List.generate(ex.defaultSets, (index) {
        return WorkoutSet(
          setNumber: index + 1,
          weightKg: 0,
          reps: int.tryParse(ex.defaultReps.split('-').first) ?? 10,
          rir: 2,
          isCompleted: false,
        );
      });
    }

    state = state.copyWith(
      selectedDayIndex: dayIndex,
      isSessionActive: true,
      activeSessionSets: sessionSets,
    );
  }

  void updateSet(String exerciseId, int setIndex, WorkoutSet newSet) {
    final currentSets = List<WorkoutSet>.from(state.activeSessionSets[exerciseId] ?? []);
    if (setIndex >= 0 && setIndex < currentSets.length) {
      currentSets[setIndex] = newSet;
      final newMap = Map<String, List<WorkoutSet>>.from(state.activeSessionSets);
      newMap[exerciseId] = currentSets;
      state = state.copyWith(activeSessionSets: newMap);
    }
  }

  void addSet(String exerciseId) {
    final currentSets = List<WorkoutSet>.from(state.activeSessionSets[exerciseId] ?? []);
    final nextNumber = currentSets.length + 1;
    final lastSet = currentSets.isNotEmpty ? currentSets.last : null;
    currentSets.add(WorkoutSet(
      setNumber: nextNumber,
      weightKg: lastSet?.weightKg ?? 0,
      reps: lastSet?.reps ?? 10,
      rir: lastSet?.rir ?? 2,
      isCompleted: false,
    ));

    final newMap = Map<String, List<WorkoutSet>>.from(state.activeSessionSets);
    newMap[exerciseId] = currentSets;
    state = state.copyWith(activeSessionSets: newMap);
  }

  void toggleSetCompleted(String exerciseId, int setIndex, int restSeconds) {
    final currentSets = List<WorkoutSet>.from(state.activeSessionSets[exerciseId] ?? []);
    if (setIndex >= 0 && setIndex < currentSets.length) {
      final wasCompleted = currentSets[setIndex].isCompleted;
      currentSets[setIndex] = currentSets[setIndex].copyWith(isCompleted: !wasCompleted);
      final newMap = Map<String, List<WorkoutSet>>.from(state.activeSessionSets);
      newMap[exerciseId] = currentSets;

      // If set just marked completed, trigger rest timer
      if (!wasCompleted) {
        state = state.copyWith(
          activeSessionSets: newMap,
          activeRestSeconds: restSeconds,
          totalRestSeconds: restSeconds,
          isRestRunning: true,
        );
      } else {
        state = state.copyWith(activeSessionSets: newMap);
      }
    }
  }

  void tickRestTimer() {
    if (state.activeRestSeconds != null && state.activeRestSeconds! > 0) {
      state = state.copyWith(activeRestSeconds: state.activeRestSeconds! - 1);
    } else if (state.activeRestSeconds == 0) {
      state = state.copyWith(clearRest: true);
    }
  }

  void adjustRestTimer(int deltaSeconds) {
    if (state.activeRestSeconds != null) {
      final newTime = (state.activeRestSeconds! + deltaSeconds).clamp(5, 600);
      state = state.copyWith(
        activeRestSeconds: newTime,
        totalRestSeconds: (state.totalRestSeconds ?? newTime) + (deltaSeconds > 0 ? deltaSeconds : 0),
      );
    }
  }

  void cancelRestTimer() {
    state = state.copyWith(clearRest: true);
  }

  void finishWorkoutSession() {
    double totalVol = 0;
    int completedCount = 0;

    for (final entry in state.activeSessionSets.entries) {
      for (final s in entry.value) {
        if (s.isCompleted) {
          completedCount++;
          totalVol += (s.weightKg * s.reps);
        }
      }
    }

    final newHistoryItem = CompletedWorkout(
      timestamp: DateTime.now(),
      dayNumber: state.selectedDay.dayNumber,
      dayTitle: state.selectedDay.title,
      totalSets: completedCount,
      totalVolumeKg: totalVol,
      durationMinutes: 48,
    );

    state = state.copyWith(
      isSessionActive: false,
      clearRest: true,
      history: [newHistoryItem, ...state.history],
    );
  }
}
