import 'dart:async';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/utils/youtube_launcher.dart';
import '../../../core/widgets/common/v_progress_ring.dart';
import '../../../core/widgets/workout_video_player.dart';
import '../data/apt_database.dart';
import '../models/apt_exercise.dart';

class AptGuidedSessionSheet extends StatefulWidget {
  final int initialIndex;

  const AptGuidedSessionSheet({
    super.key,
    this.initialIndex = 0,
  });

  static Future<void> show(BuildContext context, {int initialIndex = 0}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AptGuidedSessionSheet(initialIndex: initialIndex),
    );
  }

  @override
  State<AptGuidedSessionSheet> createState() => _AptGuidedSessionSheetState();
}

class _AptGuidedSessionSheetState extends State<AptGuidedSessionSheet> {
  late int _currentStepIndex;
  int _currentSet = 1;
  int _timerSeconds = 0;
  bool _isTimerRunning = false;
  bool _showVideo = false;
  Timer? _timer;
  late ConfettiController _confettiController;
  final Set<String> _completedStepIds = {};

  final List<AptExercise> _routine = AptDatabase.routine;

  @override
  void initState() {
    super.initState();
    _currentStepIndex = widget.initialIndex.clamp(0, _routine.length - 1);
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Set ${_currentSet - 1} finished! Starting Set $_currentSet of ${step.sets}'),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      _completedStepIds.add(step.id);
      if (_currentStepIndex < _routine.length - 1) {
        setState(() {
          _currentStepIndex++;
          _currentSet = 1;
          _loadStepTimer(_currentStepIndex);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${step.title} completed! Moving to next drill.'),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        _confettiController.play();
        _showCompletedDialog();
      }
    }
  }

  void _showCompletedDialog() {
    final palette = context.palette;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: palette.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.xl)),
        title: Row(
          children: [
            Icon(Icons.verified_rounded, color: palette.accent),
            const SizedBox(width: 8),
            const Text('APT Protocol Complete!'),
          ],
        ),
        content: const Text(
          'Your pelvis is neutrally positioned, lumbar erectors inhibited, and glutes activated. You are primed for heavy resistance training!',
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: palette.accent,
              foregroundColor: palette.onAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.md)),
            ),
            onPressed: () {
              Navigator.pop(context); // Dialog
              Navigator.pop(context); // Sheet
            },
            child: const Text('Done', style: TextStyle(fontWeight: FontWeight.bold)),
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
    final palette = context.palette;
    final currentExercise = _routine[_currentStepIndex];

    final minutes = _timerSeconds ~/ 60;
    final seconds = _timerSeconds % 60;
    final timeStr = '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    final timerProgress = currentExercise.durationSeconds > 0
        ? (_timerSeconds / currentExercise.durationSeconds).clamp(0.0, 1.0)
        : 1.0;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.94,
      ),
      padding: const EdgeInsets.only(top: Insets.sm, left: Insets.lg, right: Insets.lg, bottom: Insets.xl),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(Radii.xl)),
        border: Border.all(color: palette.border),
      ),
      child: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Drag handle
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: palette.textMuted.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: Insets.md),

                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(Insets.sm),
                      decoration: BoxDecoration(
                        color: palette.accent.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.timer_rounded, color: palette.accent, size: 22),
                    ),
                    const SizedBox(width: Insets.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Guided APT Routine',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.2,
                            ),
                          ),
                          Text(
                            'Drill ${_currentStepIndex + 1} of ${_routine.length} • Set $_currentSet of ${currentExercise.sets}',
                            style: TextStyle(
                              fontSize: 12,
                              color: palette.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close_rounded, color: palette.textSecondary, size: 20),
                      style: IconButton.styleFrom(
                        backgroundColor: palette.surfaceElevated,
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(Insets.xs),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Insets.md),

                // Step Progress Indicators
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
                        borderRadius: BorderRadius.circular(4),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          height: 7,
                          decoration: BoxDecoration(
                            color: isCurrent
                                ? palette.accent
                                : isDone
                                    ? palette.teal
                                    : palette.surfaceSunken,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: Insets.md),

                // Drill Title & Protocol
                Text(
                  currentExercise.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  currentExercise.protocol,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: palette.accent,
                  ),
                ),
                const SizedBox(height: Insets.md),

                // Toggle Video/Animation Preview
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        foregroundColor: palette.accent,
                      ),
                      onPressed: () => setState(() => _showVideo = !_showVideo),
                      icon: Icon(_showVideo ? Icons.visibility_off_rounded : Icons.videocam_rounded, size: 16),
                      label: Text(
                        _showVideo ? 'Hide Demonstration' : 'Show Demonstration',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        foregroundColor: const Color(0xFFFF0000),
                      ),
                      onPressed: () => YouTubeLauncher.launchExerciseTutorial(currentExercise.title),
                      icon: const Icon(Icons.smart_display_rounded, size: 16),
                      label: const Text('YouTube Guide', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),

                if (_showVideo) ...[
                  const SizedBox(height: Insets.xs),
                  WorkoutVideoPlayer(
                    key: ValueKey('guided_${currentExercise.id}'),
                    assetVideoPath: currentExercise.assetVideoPath,
                    onlineVideoUrl: currentExercise.onlineHdVideoUrl ?? currentExercise.assetVideoPath,
                    exerciseTitle: currentExercise.title,
                    isOnline: false,
                    height: 190,
                  ),
                  const SizedBox(height: Insets.md),
                ],

                // Circular Timer Display
                Center(
                  child: Column(
                    children: [
                      VProgressRing(
                        progress: timerProgress,
                        size: 140,
                        strokeWidth: 8,
                        color: palette.accent,
                        centerChild: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              timeStr,
                              style: const TextStyle(
                                fontSize: 34,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.5,
                              ),
                            ),
                            Text(
                              currentExercise.isTimed ? 'Hold Interval' : 'Target Tempo',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: palette.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: Insets.lg),

                      // Controls
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: palette.textPrimary,
                              side: BorderSide(color: palette.border),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.md)),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            ),
                            onPressed: () => _loadStepTimer(_currentStepIndex),
                            icon: const Icon(Icons.refresh_rounded, size: 18),
                            label: const Text('Reset'),
                          ),
                          const SizedBox(width: Insets.sm),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: palette.accent,
                              foregroundColor: palette.onAccent,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.md)),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            ),
                            onPressed: _toggleTimer,
                            icon: Icon(_isTimerRunning ? Icons.pause_rounded : Icons.play_arrow_rounded),
                            label: Text(
                              _isTimerRunning ? 'Pause' : 'Start',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: Insets.sm),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: palette.surfaceElevated,
                              foregroundColor: palette.textPrimary,
                              side: BorderSide(color: palette.border),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.md)),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            ),
                            onPressed: _onSetFinished,
                            child: const Text('Done Set', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: Insets.lg),

                // Cues snippet
                Container(
                  padding: const EdgeInsets.all(Insets.md),
                  decoration: BoxDecoration(
                    color: palette.surfaceElevated,
                    borderRadius: BorderRadius.circular(Radii.md),
                    border: Border.all(color: palette.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'KEY FORM CHECKPOINTS:',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                          color: palette.accent,
                        ),
                      ),
                      const SizedBox(height: 6),
                      ...currentExercise.executionCues.take(3).map((cue) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('• ', style: TextStyle(color: palette.accent, fontWeight: FontWeight.bold)),
                              Expanded(
                                child: Text(
                                  cue,
                                  style: TextStyle(fontSize: 12, color: palette.textSecondary),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Confetti for completion
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: [palette.accent, palette.teal, palette.orange, Colors.white],
            ),
          ),
        ],
      ),
    );
  }
}
