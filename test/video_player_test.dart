import 'package:flutter_test/flutter_test.dart';
import 'package:v_work/features/workout/data/workout_database.dart';
import 'package:v_work/features/apt_rehab/data/apt_database.dart';

void main() {
  group('Workout Detailed Video & Animation Path Verification', () {
    test('Every primary exercise has distinct animation GIF and detailed MP4 video', () {
      final days = WorkoutDatabase.getDefaultSplit();

      for (final day in days) {
        for (final exercise in day.exercises) {
          // Animation GIF
          expect(exercise.activeAssetAnimationPath.endsWith('.gif'), isTrue,
              reason: '${exercise.name} activeAssetAnimationPath must be a .gif');
          expect(exercise.activeAssetAnimationPath.startsWith('assets/exercises/'), isTrue);

          // Detailed MP4 video from YouTube
          expect(exercise.activeAssetVideoPath.endsWith('.mp4'), isTrue,
              reason: '${exercise.name} activeAssetVideoPath must be an .mp4');
          expect(exercise.activeAssetVideoPath.startsWith('assets/videos/'), isTrue);
          expect(exercise.hasDownloadedVideo, isTrue);
        }
      }
    });

    test('APT Rehab exercises have both animation GIF and tutorial MP4 video', () {
      final routine = AptDatabase.routine;

      for (final drill in routine) {
        expect(drill.assetAnimationPath.endsWith('.gif'), isTrue);
        expect(drill.assetVideoPath.endsWith('.mp4'), isTrue);
      }
    });
  });
}
