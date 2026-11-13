import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:eye_monitoring/shared/widgets/error_message.dart';

void main() {
  group('ErrorMessage', () {
    testWidgets('should display error message', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ErrorMessage(
              message: 'An error occurred',
            ),
          ),
        ),
      );

      expect(find.text('An error occurred'), findsOneWidget);
    });

    testWidgets('should display retry button when onRetry is provided', (tester) async {
      bool retryCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorMessage(
              message: 'An error occurred',
              onRetry: () => retryCalled = true,
            ),
          ),
        ),
      );

      expect(find.text('Retry'), findsOneWidget);

      await tester.tap(find.text('Retry'));
      await tester.pump();

      expect(retryCalled, isTrue);
    });

    testWidgets('should not display retry button when onRetry is null', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ErrorMessage(
              message: 'An error occurred',
            ),
          ),
        ),
      );

      expect(find.text('Retry'), findsNothing);
    });

    testWidgets('should display custom retry label', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ErrorMessage(
              message: 'An error occurred',
              onRetry: null,
              retryLabel: 'Try Again',
            ),
          ),
        ),
      );

      expect(find.text('Try Again'), findsNothing);
    });

    testWidgets('should display warning style for warning type', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ErrorMessage(
              message: 'Warning message',
              type: ErrorType.warning,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.warning_amber_outlined), findsOneWidget);
    });

    testWidgets('should display info style for info type', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ErrorMessage(
              message: 'Info message',
              type: ErrorType.info,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.info_outline), findsOneWidget);
    });

    testWidgets('should display custom icon when provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ErrorMessage(
              message: 'Custom icon',
              icon: Icons.bluetooth_disabled,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.bluetooth_disabled), findsOneWidget);
    });
  });

  group('FullScreenError', () {
    testWidgets('should display in scaffold', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: FullScreenError(
            message: 'Error message',
          ),
        ),
      );

      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(ErrorMessage), findsOneWidget);
    });

    testWidgets('should pass retry callback', (tester) async {
      bool retryCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: FullScreenError(
            message: 'Error message',
            onRetry: () => retryCalled = true,
          ),
        ),
      );

      await tester.tap(find.text('Retry'));
      await tester.pump();

      expect(retryCalled, isTrue);
    });
  });
}
