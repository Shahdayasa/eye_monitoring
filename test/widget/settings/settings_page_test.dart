import 'package:eye_monitoring/core/config/app_config.dart';
import 'package:eye_monitoring/features/authentication/domain/user_model.dart';
import 'package:eye_monitoring/features/authentication/presentation/auth_provider.dart';
import 'package:eye_monitoring/features/settings/presentation/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeAuthProvider extends ChangeNotifier implements AuthProvider {
  final UserModel? _user;
  _FakeAuthProvider(this._user);

  @override
  UserModel? get user => _user;

  @override
  bool get isAuthenticated => _user != null;

  @override
  bool get isLoading => false;

  @override
  String? get errorMessage => null;

  @override
  bool get isProfileComplete => _user?.profileCompleted ?? false;

  @override
  AuthStatus get status => _user != null ? AuthStatus.authenticated : AuthStatus.unauthenticated;

  @override
  Future<bool> logout() async => true;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({
      'pref_notifications_enabled': false,
      'pref_high_contrast_charts': true,
    });
  });

  Widget wrap(Widget child) {
    final user = UserModel(
      uid: 'u1',
      email: 'user@example.com',
      displayName: 'Test User',
      createdAt: DateTime(2024, 1, 1),
      age: 30,
      country: 'US',
      profileCompleted: true,
    );
    return ChangeNotifierProvider<AuthProvider>.value(
      value: _FakeAuthProvider(user),
      child: MaterialApp(home: child),
    );
  }

  testWidgets('Settings page shows account, sections and app version', (tester) async {
    await tester.pumpWidget(wrap(const SettingsPage()));
    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Test User'), findsOneWidget);
    expect(find.text('user@example.com'), findsOneWidget);
    expect(find.text('Account information'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('Device connection help'), 200);
    expect(find.text('Device connection help'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('Data & privacy'), 200);
    expect(find.text('Data & privacy'), findsOneWidget);
    expect(find.text('Delete my data'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('App version'), 200);
    expect(find.text('App version'), findsOneWidget);
    expect(find.textContaining(AppConstants.appVersion), findsWidgets);
  });

  testWidgets('Preferences toggles persist', (tester) async {
    await tester.pumpWidget(wrap(const SettingsPage()));
    await tester.pumpAndSettle();

    final notifications = find.byType(SwitchListTile).at(0);
    final highContrast = find.byType(SwitchListTile).at(1);

    SwitchListTile nTile = tester.widget(notifications);
    SwitchListTile hTile = tester.widget(highContrast);
    expect(nTile.value, false);
    expect(hTile.value, true);

    await tester.tap(notifications);
    await tester.pumpAndSettle();

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('pref_notifications_enabled'), true);
  });
}
