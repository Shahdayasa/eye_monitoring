import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:eye_monitoring/shared/widgets/status_badge.dart';

void main() {
  group('StatusBadge', () {
    testWidgets('should display label text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatusBadge(
              label: 'Connected',
            ),
          ),
        ),
      );

      expect(find.text('Connected'), findsOneWidget);
    });

    testWidgets('should display dot by default', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatusBadge(
              label: 'Status',
            ),
          ),
        ),
      );

      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('should not display dot when showDot is false', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatusBadge(
              label: 'Status',
              showDot: false,
            ),
          ),
        ),
      );

      expect(find.byType(StatusBadge), findsOneWidget);
    });

    testWidgets('should display custom icon when provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatusBadge(
              label: 'Bluetooth',
              icon: Icons.bluetooth,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.bluetooth), findsOneWidget);
    });

    testWidgets('should apply success colors', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatusBadge(
              label: 'Success',
              type: StatusType.success,
            ),
          ),
        ),
      );

      expect(find.byType(StatusBadge), findsOneWidget);
    });

    testWidgets('should apply warning colors', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatusBadge(
              label: 'Warning',
              type: StatusType.warning,
            ),
          ),
        ),
      );

      expect(find.byType(StatusBadge), findsOneWidget);
    });

    testWidgets('should apply error colors', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatusBadge(
              label: 'Error',
              type: StatusType.error,
            ),
          ),
        ),
      );

      expect(find.byType(StatusBadge), findsOneWidget);
    });

    testWidgets('should apply info colors', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatusBadge(
              label: 'Info',
              type: StatusType.info,
            ),
          ),
        ),
      );

      expect(find.byType(StatusBadge), findsOneWidget);
    });

    testWidgets('should apply connected colors', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatusBadge(
              label: 'Connected',
              type: StatusType.connected,
            ),
          ),
        ),
      );

      expect(find.byType(StatusBadge), findsOneWidget);
    });

    testWidgets('should apply disconnected colors', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatusBadge(
              label: 'Disconnected',
              type: StatusType.disconnected,
            ),
          ),
        ),
      );

      expect(find.byType(StatusBadge), findsOneWidget);
    });
  });
}
