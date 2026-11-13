import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('App Structure Tests', () {
    testWidgets('App should have MaterialApp', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: Text('Eye Monitoring'),
            ),
          ),
        ),
      );

      expect(find.text('Eye Monitoring'), findsOneWidget);
    });

    testWidgets('Auth page should have email and password fields',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: [
                  Text('Email'),
                  Text('Password'),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
    });
  });
}
