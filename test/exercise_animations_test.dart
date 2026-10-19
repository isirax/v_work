import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:v_work/features/workout/data/workout_database.dart';
import 'package:v_work/features/apt_rehab/data/apt_database.dart';

void main() {
  group('Exercise Media & Animation Dataset Verification', () {
    test('All 28 workout exercises have valid local animation GIFs and downloaded MP4 videos', () {
      final days = WorkoutDatabase.getDefaultSplit();
      expect(days.length, 5);

      int totalExercises = 0;
      int totalAlternatives = 0;

      for (final day in days) {
        for (final ex in day.exercises) {
          totalExercises++;
          // 1. Check animation GIF paths (from exercises-dataset)
          expect(ex.assetAnimationPath.endsWith('.gif'), isTrue,
              reason: 'Exercise ${ex.id} (${ex.name}) must have a .gif animation path');
          expect(ex.onlineHdVideoUrl.startsWith('https://cdn.jsdelivr.net/gh/hasaneyldrm/exercises-dataset@main/videos/'), isTrue,
              reason: 'Exercise ${ex.id} must point to hasaneyldrm/exercises-dataset CDN URL');
          expect(ex.thumbnailPath != null && ex.thumbnailPath!.endsWith('.jpg'), isTrue,
              reason: 'Exercise ${ex.id} must have a thumbnail');

          // Verify the local GIF file actually exists
          final animFile = File(ex.assetAnimationPath);
          expect(animFile.existsSync(), isTrue,
              reason: 'GIF file ${ex.assetAnimationPath} must exist on disk');
          expect(animFile.lengthSync(), greaterThan(1000),
              reason: 'GIF file ${ex.assetAnimationPath} must not be empty');

          // 2. Check detailed video MP4 paths (downloaded YouTube tutorials)
          expect(ex.assetVideoPath.endsWith('.mp4'), isTrue,
              reason: 'Exercise ${ex.id} (${ex.name}) must have an .mp4 detailed video path');
          final videoFile = File(ex.assetVideoPath);
          expect(videoFile.existsSync(), isTrue,
              reason: 'Video file ${ex.assetVideoPath} must exist on disk');
          expect(videoFile.lengthSync(), greaterThan(10000),
              reason: 'Video file ${ex.assetVideoPath} must not be empty');

          // 3. Check alternatives
          for (final alt in ex.alternatives) {
            totalAlternatives++;
            expect(alt.assetAnimationPath != null && alt.assetAnimationPath!.endsWith('.gif'), isTrue,
                reason: 'Alternative ${alt.id} (${alt.name}) must have a .gif animation path');
            expect(alt.onlineHdVideoUrl != null && alt.onlineHdVideoUrl!.startsWith('https://cdn.jsdelivr.net/gh/hasaneyldrm/exercises-dataset@main/videos/'), isTrue,
                reason: 'Alternative ${alt.id} must point to exercises-dataset CDN URL');
            expect(alt.thumbnailPath != null && alt.thumbnailPath!.endsWith('.jpg'), isTrue,
                reason: 'Alternative ${alt.id} must have a thumbnail');

            final altFile = File(alt.assetAnimationPath!);
            expect(altFile.existsSync(), isTrue,
                reason: 'Animation file ${alt.assetAnimationPath} must exist on disk');
          }
        }
      }

      expect(totalExercises, 28);
      expect(totalAlternatives, 56);
    });

    test('All APT Rehab exercises have valid animation GIFs and downloaded MP4 tutorials', () {
      final aptExercises = AptDatabase.routine;
      expect(aptExercises.length, 4);

      for (final ex in aptExercises) {
        expect(ex.assetAnimationPath.endsWith('.gif'), isTrue);
        expect(ex.assetVideoPath.endsWith('.mp4'), isTrue);
        expect(ex.onlineHdVideoUrl != null && ex.onlineHdVideoUrl!.contains('exercises-dataset'), isTrue);

        final animFile = File(ex.assetAnimationPath);
        expect(animFile.existsSync(), isTrue,
            reason: 'APT Exercise animation ${ex.assetAnimationPath} must exist');

        final videoFile = File(ex.assetVideoPath);
        expect(videoFile.existsSync(), isTrue,
            reason: 'APT Exercise video ${ex.assetVideoPath} must exist');
      }
    });

    test('Exercise swapping switches activeAssetAnimationPath and activeThumbnailPath', () {
      final days = WorkoutDatabase.getDefaultSplit();
      final original = days[0].exercises[0]; // d1_ex1
      final alt = original.alternatives[0];

      expect(original.isSwapped, isFalse);
      expect(original.activeAssetAnimationPath, original.assetAnimationPath);
      expect(original.activeAssetVideoPath, original.assetVideoPath);

      final swapped = original.copyWith(activeAlternativeId: alt.id);
      expect(swapped.isSwapped, isTrue);
      expect(swapped.activeName, alt.name);
      expect(swapped.activeAssetAnimationPath, alt.assetAnimationPath);
      expect(swapped.activeOnlineHdVideoUrl, alt.onlineHdVideoUrl);
      expect(swapped.activeThumbnailPath, alt.thumbnailPath);
    });
  });
}
