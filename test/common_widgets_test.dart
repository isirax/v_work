import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:v_work/core/constants/app_theme.dart';
import 'package:v_work/core/widgets/common/v_badge.dart';
import 'package:v_work/core/widgets/common/v_callout.dart';
import 'package:v_work/core/widgets/common/v_checkbox.dart';
import 'package:v_work/core/widgets/common/v_progress_ring.dart';
import 'package:v_work/core/widgets/common/v_segment_control.dart';

void main() {
  Widget buildTestApp(Widget child) {
    return MaterialApp(
      theme: AppTheme.darkTheme,
      home: Scaffold(body: Center(child: child)),
    );
  }

  group('VBadge Tests', () {
    testWidgets('renders text and optional icon correctly', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          const VBadge(
            label: 'HYPERTROPHY',
            icon: Icons.flash_on,
            variant: VBadgeVariant.accent,
          ),
        ),
      );

      expect(find.text('HYPERTROPHY'), findsOneWidget);
      expect(find.byIcon(Icons.flash_on), findsOneWidget);
    });
  });

  group('VCheckbox Tests', () {
    testWidgets('handles tap and toggles value', (tester) async {
      bool checked = false;

      await tester.pumpWidget(
        buildTestApp(
          StatefulBuilder(
            builder: (context, setState) {
              return VCheckbox(
                isChecked: checked,
                onChanged: (val) {
                  setState(() => checked = val);
                },
              );
            },
          ),
        ),
      );

      expect(checked, isFalse);
      await tester.tap(find.byType(VCheckbox));
      await tester.pumpAndSettle();

      expect(checked, isTrue);
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
    });
  });

  group('VSegmentControl Tests', () {
    testWidgets('changes active selection when tapped', (tester) async {
      String selected = 'day1';

      await tester.pumpWidget(
        buildTestApp(
          StatefulBuilder(
            builder: (context, setState) {
              return VSegmentControl<String>(
                selectedValue: selected,
                onSelected: (val) {
                  setState(() => selected = val);
                },
                items: const [
                  VSegmentItem(value: 'day1', label: 'Day 1'),
                  VSegmentItem(value: 'day2', label: 'Day 2'),
                ],
              );
            },
          ),
        ),
      );

      expect(find.text('Day 1'), findsOneWidget);
      expect(find.text('Day 2'), findsOneWidget);

      await tester.tap(find.text('Day 2'));
      await tester.pumpAndSettle();

      expect(selected, 'day2');
    });
  });

  group('VCallout Tests', () {
    testWidgets('renders title and message correctly', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          const VCallout(
            title: 'SAFETY NOTICE',
            message: 'Never combine iron with calcium.',
            variant: VCalloutVariant.warning,
          ),
        ),
      );

      expect(find.text('SAFETY NOTICE'), findsOneWidget);
      expect(find.text('Never combine iron with calcium.'), findsOneWidget);
    });
  });

  group('VProgressRing Tests', () {
    testWidgets('calculates ratio and renders value', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          const VProgressRing(
            progress: 0.75,
            valueText: '150',
            targetText: '200g',
            label: 'PROTEIN',
          ),
        ),
      );

      expect(find.text('150'), findsOneWidget);
      expect(find.text('200g'), findsOneWidget);
      expect(find.text('PROTEIN'), findsOneWidget);
    });
  });
}
