import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:v_work/features/apt_rehab/data/apt_database.dart';
import 'package:v_work/features/apt_rehab/presentation/apt_routine_screen.dart';
import 'package:v_work/features/apt_rehab/presentation/apt_exercise_detail_modal.dart';
import 'package:v_work/features/apt_rehab/presentation/apt_guided_session_sheet.dart';

void main() {
  group('APT Rehab Screen and Modals Verification', () {
    testWidgets('AptRoutineScreen displays all 4 corrective drills cleanly like Workouts', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AptRoutineScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Screen Header & Protocol Card
      expect(find.text('APT Rehab Protocol'), findsOneWidget);
      expect(find.text('Anterior Pelvic Tilt Correction'), findsOneWidget);
      expect(find.text('PRESCRIBED DRILLS (4)'), findsOneWidget);
      expect(find.text('Start Guided Routine (Timer)'), findsOneWidget);

      // Verify all 4 drills can be found by scrolling
      final routine = AptDatabase.routine;
      expect(routine.length, 4);

      for (final drill in routine) {
        await tester.scrollUntilVisible(
          find.text(drill.title),
          150,
          scrollable: find.byType(Scrollable),
        );
        expect(find.text(drill.title), findsOneWidget);
        expect(find.text(drill.targetMuscles), findsOneWidget);
      }
    });

    testWidgets('AptExerciseDetailModal displays correct segmented modes and YouTube action', (tester) async {
      final firstDrill = AptDatabase.routine.first;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => AptExerciseDetailModal.show(context, firstDrill),
                child: const Text('Open Modal'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Modal'));
      await tester.pumpAndSettle();

      // Modal is visible with exercise title
      expect(find.text(firstDrill.title), findsOneWidget);
      expect(find.text('Quick Demo'), findsOneWidget);
      expect(find.text('Video Guide'), findsOneWidget);
      expect(find.text('Technique Cues'), findsOneWidget);
      expect(find.text('Search YouTube'), findsOneWidget);
      expect(find.text('BIOMECHANICAL PURPOSE'), findsOneWidget);
    });

    testWidgets('AptGuidedSessionSheet can be opened and shows countdown ring', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => AptGuidedSessionSheet.show(context, initialIndex: 0),
                child: const Text('Open Guided'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Guided'));
      await tester.pumpAndSettle();

      expect(find.text('Guided APT Routine'), findsOneWidget);
      expect(find.text('Start'), findsOneWidget);
      expect(find.text('Done Set'), findsOneWidget);
      expect(find.text('Reset'), findsOneWidget);
    });
  });
}
