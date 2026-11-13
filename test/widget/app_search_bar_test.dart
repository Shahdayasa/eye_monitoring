import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:eye_monitoring/shared/widgets/app_search_bar.dart';

void main() {
  group('AppSearchBar', () {
    testWidgets('renders hint and search icon', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppSearchBar(hintText: 'Find sessions'),
          ),
        ),
      );

      expect(find.text('Find sessions'), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('shows clear action and clears controller', (tester) async {
      final controller = TextEditingController(text: 'eog');
      var changed = '';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppSearchBar(
              controller: controller,
              onChanged: (value) => changed = value,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.close), findsOneWidget);

      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();

      expect(controller.text, isEmpty);
      expect(changed, isEmpty);

      controller.dispose();
    });
  });
}
