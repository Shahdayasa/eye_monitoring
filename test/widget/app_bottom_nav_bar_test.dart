import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:eye_monitoring/shared/widgets/app_bottom_nav_bar.dart';

void main() {
  const destinations = [
    AppNavDestination(
      icon: Icons.home_outlined,
      selectedIcon: Icons.home,
      label: 'Home',
    ),
    AppNavDestination(
      icon: Icons.settings_outlined,
      selectedIcon: Icons.settings,
      label: 'Settings',
    ),
  ];

  group('AppBottomNavBar', () {
    testWidgets('shows active label and notifies on tap', (tester) async {
      var selected = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: StatefulBuilder(
              builder: (context, setState) {
                return AppBottomNavBar(
                  selectedIndex: selected,
                  onDestinationSelected: (index) => setState(() => selected = index),
                  destinations: destinations,
                );
              },
            ),
          ),
        ),
      );

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Settings'), findsNothing);
      expect(find.byIcon(Icons.home), findsOneWidget);

      await tester.tap(find.byIcon(Icons.settings_outlined));
      await tester.pumpAndSettle();

      expect(selected, 1);
      expect(find.text('Settings'), findsOneWidget);
    });
  });
}
