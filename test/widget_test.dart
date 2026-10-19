import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:v_work/main.dart';

void main() {
  testWidgets('V Workout App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: VWorkoutApp(),
      ),
    );

    // Verify app renders with V Workout title
    expect(find.text('V Workout'), findsWidgets);
  });
}
