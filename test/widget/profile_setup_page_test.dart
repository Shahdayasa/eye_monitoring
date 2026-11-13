import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:eye_monitoring/features/authentication/data/auth_repository.dart';
import 'package:eye_monitoring/features/authentication/domain/user_model.dart';
import 'package:eye_monitoring/features/authentication/presentation/auth_provider.dart';
import 'package:eye_monitoring/features/authentication/presentation/profile_setup_page.dart';

class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository(this.user);

  final UserModel user;

  @override
  Stream<User?> get authStateChanges => const Stream.empty();

  @override
  User? get currentUser => null;

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async =>
      user;

  @override
  Future<UserModel> completeProfile({
    required UserModel user,
    required String displayName,
    required int age,
    required String country,
    String? medicalConditions,
  }) async =>
      user.copyWith(
        displayName: displayName,
        age: age,
        country: country,
        medicalConditions: medicalConditions,
        profileCompleted: true,
      );

  @override
  Future<UserModel?> getUserProfile(String uid) async => user;

  @override
  Future<UserModel> register({
    required String email,
    required String password,
    String? displayName,
  }) async =>
      user;

  @override
  Future<void> logout() async {}

  @override
  Future<void> resetPassword({required String email}) async {}

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Next & Save navigates to the dashboard', (tester) async {
    final provider = AuthProvider(
      FakeAuthRepository(
        UserModel(
          uid: 'test-uid',
          email: 'test@example.com',
          displayName: 'Test User',
          createdAt: DateTime(2024),
        ),
      ),
    );

    await provider.login(email: 'test@example.com', password: 'password123');

    final router = GoRouter(
      initialLocation: '/onboarding',
      routes: [
        GoRoute(
          path: '/onboarding',
          builder: (context, state) => const ProfileSetupPage(),
        ),
        GoRoute(
          path: '/dashboard',
          builder: (context, state) =>
              const Scaffold(body: Text('Dashboard Page')),
        ),
      ],
    );

    await tester.pumpWidget(
      ChangeNotifierProvider<AuthProvider>.value(
        value: provider,
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Age'),
      '25',
    );

    final countryField = find.byType(DropdownButtonFormField<String>);
    await tester.ensureVisible(countryField);
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.arrow_drop_down));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Albania').last);
    await tester.pumpAndSettle();

    final saveButton = find.text('Next & Save');
    await tester.ensureVisible(saveButton);
    await tester.pumpAndSettle();
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    expect(find.text('Dashboard Page'), findsOneWidget);
  });
}
