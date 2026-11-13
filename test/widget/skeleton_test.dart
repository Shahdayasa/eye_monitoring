import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:eye_monitoring/shared/widgets/skeleton.dart';

void main() {
  group('Skeleton widgets', () {
    testWidgets('SkeletonBox renders with reduced motion', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(disableAnimations: true),
            child: Scaffold(
              body: Center(
                child: SkeletonBox(width: 120, height: 16),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(SkeletonBox), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(SkeletonBox),
          matching: find.byType(AnimatedBuilder),
        ),
        findsNothing,
      );
    });

    testWidgets('SkeletonList renders requested card count', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(disableAnimations: true),
            child: Scaffold(
              body: SingleChildScrollView(
                child: SkeletonList(itemCount: 4),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(SkeletonCard), findsNWidgets(4));
    });
  });
}
