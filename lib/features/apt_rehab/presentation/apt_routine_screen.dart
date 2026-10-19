import 'dart:async';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/workout_video_player.dart';
import '../data/apt_database.dart';
import '../models/apt_exercise.dart';

class AptRoutineScreen extends StatefulWidget {
  const AptRoutineScreen({super.key});

  @override
  State<AptRoutineScreen> createState() => _AptRoutineScreenState();
}

class _AptRoutineScreenState extends State<AptRoutineScreen> {
  int _currentStepIndex = 0;
  int _currentSet = 1;
  int _timerSeconds = 0;
  bool _isTimerRunning = false;
  bool _showAptVideo = false;
  Timer? _timer;
  late ConfettiController _confettiController;
  final Set<String> _completedStepIds = {};

  final List<AptExercise> _routine = AptDatabase.routine;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _loadStepTimer(_currentStepIndex);
  }

  void _loadStepTimer(int index) {
    final step = _routine[index];
    setState(() {
      _timerSeconds = step.durationSeconds;
      _isTimerRunning = false;
    });
    _timer?.cancel();
  }

  void _toggleTimer() {
    if (_isTimerRunning) {
      _timer?.cancel();
      setState(() => _isTimerRunning = false);
    } else {
      setState(() => _isTimerRunning = true);
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_timerSeconds > 0) {
          setState(() => _timerSeconds--);
        } else {
          _timer?.cancel();
          setState(() => _isTimerRunning = false);
          _onSetFinished();
        }
      });
    }
  }

  void _onSetFinished() {
    if (!mounted) return;
    final step = _routine[_currentStepIndex];
    if (_currentSet < step.sets) {
      setState(() {
        _currentSet++;
        _timerSeconds = step.durationSeconds;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Set ${_currentSet - 1} finished! Starting Set $_currentSet'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } else {
      _completedStepIds.add(step.id);
      if (_currentStepIndex < _routine.length - 1) {
        setState(() {
          _currentStepIndex++;
          _currentSet = 1;
          _loadStepTimer(_currentStepIndex);
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${step.title} completed! Moving to next drill.'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else {
        _confettiController.play();
        if (mounted) {
          _showCompletedDialog();
        }
      }
    }
  }

  void _showCompletedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.verified_rounded, color: AppColors.primaryVolt),
            SizedBox(width: 8),
            Text('APT Routine Complete!'),
          ],
        ),
        content: const Text(
          'Your pelvis is neutral, lumbar erectors inhibited, and glutes activated. You are primed for safe, heavy resistance training!',
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Back to Training'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentExercise = _routine[_currentStepIndex];

    final minutes = _timerSeconds ~/ 60;
    final seconds = _timerSeconds % 60;
    final timeStr = '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    final timerProgress = currentExercise.durationSeconds > 0
        ? (_timerSeconds / currentExercise.durationSeconds).clamp(0.0, 1.0)
        : 1.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('APT Pre-Workout Protocol'),
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            margin: const EdgeInsets.only(right: 14),
            decoration: BoxDecoration(
              color: AppColors.primaryVolt.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.timer_outlined, size: 14, color: AppColors.primaryVolt),
                const SizedBox(width: 4),
                Text(
                  '${_completedStepIds.length}/4 DONE',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryVolt,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Clinical Goal Banner
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: AppColors.darkCardGradient,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primaryVolt.withValues(alpha: 0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.health_and_safety_rounded, color: AppColors.primaryVolt, size: 24),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'MANDATORY 10-MINUTE PRE-WORKOUT PROTOCOL',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: AppColors.primaryVolt,
                              letterSpacing: 0.5,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Inhibits psoas/erectors & activates internal obliques/glutes before loading.',
                            style: TextStyle(fontSize: 12, color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Step Progress Tracker
              Row(
                children: List.generate(_routine.length, (index) {
                  final isCurrent = index == _currentStepIndex;
                  final isDone = _completedStepIds.contains(_routine[index].id);

                  return Expanded(
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _currentStepIndex = index;
                          _currentSet = 1;
                          _loadStepTimer(index);
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        height: 8,
                        decoration: BoxDecoration(
                          color: isCurrent
                              ? AppColors.primaryVolt
                              : isDone
                                  ? AppColors.primaryCyan
                                  : (isDark ? Colors.white12 : Colors.black12),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 16),

              // Active Drill Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primaryCyan.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'DRILL ${_currentStepIndex + 1} OF 4',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                color: AppColors.primaryCyan,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.darkCardElevated : AppColors.lightCardElevated,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Set $_currentSet of ${currentExercise.sets}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      Text(
                        currentExercise.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        currentExercise.protocol,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryVolt,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Segmented Mode Selector for APT Drill (Quick Demo vs Tutorial Video)
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkCardElevated : AppColors.lightCardElevated,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () => setState(() => _showAptVideo = false),
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 6),
                                  decoration: BoxDecoration(
                                    color: !_showAptVideo
                                        ? (isDark ? AppColors.primaryVolt : const Color(0xFF00C875))
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.animation_rounded,
                                        size: 14,
                                        color: !_showAptVideo ? Colors.black : Colors.white70,
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        'Quick Demo',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: !_showAptVideo ? Colors.black : Colors.white70,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: InkWell(
                                onTap: () => setState(() => _showAptVideo = true),
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 6),
                                  decoration: BoxDecoration(
                                    color: _showAptVideo
                                        ? (isDark ? AppColors.primaryVolt : const Color(0xFF00C875))
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.play_circle_fill_rounded,
                                        size: 14,
                                        color: _showAptVideo ? Colors.black : Colors.white70,
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        'Tutorial Video',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: _showAptVideo ? Colors.black : Colors.white70,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Real Video / Animation Demonstration for APT Drill
                      WorkoutVideoPlayer(
                        key: ValueKey('apt_${currentExercise.id}_$_showAptVideo'),
                        assetVideoPath: _showAptVideo
                            ? currentExercise.assetVideoPath
                            : currentExercise.assetAnimationPath,
                        onlineVideoUrl: currentExercise.onlineHdVideoUrl ?? currentExercise.assetVideoPath,
                        exerciseTitle: currentExercise.title,
                        isOnline: false,
                        height: 200,
                      ),
                      const Divider(height: 24),

                      // Timer or Reps Display
                      Center(
                        child: Column(
                          children: [
                            SizedBox(
                              width: 140,
                              height: 140,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  CircularProgressIndicator(
                                    value: timerProgress,
                                    strokeWidth: 8,
                                    backgroundColor: isDark ? Colors.white10 : Colors.black12,
                                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryVolt),
                                  ),
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        timeStr,
                                        style: const TextStyle(
                                          fontSize: 32,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: -0.5,
                                        ),
                                      ),
                                      Text(
                                        currentExercise.isTimed ? 'Hold Interval' : 'Target Tempo',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Timer Controls
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                OutlinedButton.icon(
                                  onPressed: () => _loadStepTimer(_currentStepIndex),
                                  icon: const Icon(Icons.refresh_rounded, size: 18),
                                  label: const Text('Reset'),
                                ),
                                const SizedBox(width: 12),
                                ElevatedButton.icon(
                                  onPressed: _toggleTimer,
                                  icon: Icon(_isTimerRunning ? Icons.pause_rounded : Icons.play_arrow_rounded),
                                  label: Text(_isTimerRunning ? 'Pause' : 'Start Interval'),
                                ),
                                const SizedBox(width: 12),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primaryCyan,
                                    foregroundColor: Colors.black,
                                  ),
                                  onPressed: _onSetFinished,
                                  child: const Text('Done Set'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Biomechanical Mechanism Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.psychology_outlined, color: AppColors.primaryCyan, size: 18),
                          SizedBox(width: 8),
                          Text(
                            'BIOMECHANICAL PURPOSE',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primaryCyan,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        currentExercise.biomechanicalPurpose,
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.4,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Step-by-Step Execution Cues
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.checklist_rounded, color: AppColors.primaryVolt, size: 18),
                          SizedBox(width: 8),
                          Text(
                            'MANDATORY FORM CHECKPOINTS',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primaryVolt,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...currentExercise.executionCues.asMap().entries.map((entry) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${entry.key + 1}. ',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryVolt,
                                  fontSize: 13,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  entry.value,
                                  style: TextStyle(
                                    fontSize: 13,
                                    height: 1.4,
                                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.errorRed.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.errorRed.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.warning_amber_rounded, size: 16, color: AppColors.errorRed),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Common Flaw: ${currentExercise.commonMistake}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.errorRed,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),

          // Confetti for completion
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [AppColors.primaryVolt, AppColors.primaryCyan, Colors.white],
            ),
          ),
        ],
      ),
    );
  }
}
