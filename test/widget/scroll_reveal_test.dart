import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:eye_monitoring/shared/widgets/scroll_reveal.dart';

void main() {
  group('RevealOnScroll', () {
    testWidgets('renders child without animation when reduced motion is on',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(disableAnimations: true),
            child: Scaffold(
              body: RevealOnScroll(
                index: 0,
                child: Text('Visible'),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Visible'), findsOneWidget);
      expect(find.byType(TweenAnimationBuilder<double>), findsNothing);
    });

    testWidgets('reveals visible child with animation', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RevealOnScroll(
              index: 0,
              child: Text('Animated'),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('Animated'), findsOneWidget);
      expect(find.byType(TweenAnimationBuilder<double>), findsOneWidget);
    });
  });
}
