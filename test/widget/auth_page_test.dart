import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:eye_monitoring/features/authentication/data/auth_repository.dart';
import 'package:eye_monitoring/features/authentication/domain/user_model.dart';
import 'package:eye_monitoring/features/authentication/presentation/auth_provider.dart';
import 'package:eye_monitoring/features/authentication/presentation/auth_page.dart';

class FakeAuthRepository implements AuthRepository {
  @override
  Stream<User?> get authStateChanges => const Stream.empty();

  @override
  User? get currentUser => null;

  @override
  Future<UserModel> register({
    required String email,
    required String password,
    String? displayName,
  }) =>
      throw UnimplementedError();

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) =>
      throw UnimplementedError();

  @override
  Future<void> logout() async {}

  @override
  Future<void> resetPassword({required String email}) async {}

  @override
  Future<UserModel?> getUserProfile(String uid) async => null;

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late FakeAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = FakeAuthRepository();
  });

  Widget createTestWidget() {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider(mockAuthRepository),
      child: const MaterialApp(
        home: AuthPage(),
      ),
    );
  }

  group('AuthPage Widget', () {
    testWidgets('should display login form by default', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Eye Monitoring'), findsOneWidget);
      expect(find.text('Welcome back! Please log in.'), findsOneWidget);
      expect(find.text('Login'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
    });

    testWidgets('should toggle to register form when sign up button is pressed',
        (tester) async {
      await tester.pumpWidget(createTestWidget());

      await tester.tap(find.text("Don't have an account? Sign Up"));
      await tester.pump();

      expect(find.text('Create your account.'), findsOneWidget);
      expect(find.text('Create Account'), findsOneWidget);
      expect(find.text('Full Name'), findsOneWidget);
    });

    testWidgets('should show validation error for empty email', (tester) async {
      await tester.pumpWidget(createTestWidget());

      await tester.tap(find.text('Login'));
      await tester.pump();

      expect(find.text('Please enter your email.'), findsOneWidget);
    });

    testWidgets('should show validation error for invalid email',
        (tester) async {
      await tester.pumpWidget(createTestWidget());

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'invalid-email',
      );

      await tester.tap(find.text('Login'));
      await tester.pump();

      expect(find.text('Please enter a valid email.'), findsOneWidget);
    });

    testWidgets('should show validation error for empty password',
        (tester) async {
      await tester.pumpWidget(createTestWidget());

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'test@example.com',
      );

      await tester.tap(find.text('Login'));
      await tester.pump();

      expect(find.text('Please enter your password.'), findsOneWidget);
    });

    testWidgets('should show validation error for short password',
        (tester) async {
      await tester.pumpWidget(createTestWidget());

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'test@example.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        '123',
      );

      await tester.tap(find.text('Login'));
      await tester.pump();

      expect(find.text('Password must be at least 6 characters.'), findsOneWidget);
    });

    testWidgets('should show forgot password button in login mode',
        (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Forgot Password?'), findsOneWidget);
    });

    testWidgets('should hide forgot password button in register mode',
        (tester) async {
      await tester.pumpWidget(createTestWidget());

      await tester.tap(find.text("Don't have an account? Sign Up"));
      await tester.pump();

      expect(find.text('Forgot Password?'), findsNothing);
    });

    testWidgets('should show password reset form when forgot password is tapped',
        (tester) async {
      await tester.pumpWidget(createTestWidget());

      await tester.tap(find.text('Forgot Password?'));
      await tester.pump();

      expect(find.text('Reset your password'), findsOneWidget);
      expect(find.text('Send Reset Link'), findsOneWidget);
      expect(find.text('Back to Login'), findsOneWidget);
    });

    testWidgets('should mask the password field', (tester) async {
      await tester.pumpWidget(createTestWidget());

      final passwordField = find.widgetWithText(TextFormField, 'Password');
      final editableText = find.descendant(
        of: passwordField,
        matching: find.byType(EditableText),
      );

      expect(tester.widget<EditableText>(editableText).obscureText, isTrue);
      expect(find.byIcon(Icons.visibility), findsNothing);
    });

    testWidgets('should show confirm password field in register mode',
        (tester) async {
      await tester.pumpWidget(createTestWidget());

      await tester.tap(find.text("Don't have an account? Sign Up"));
      await tester.pump();

      final confirmField =
          find.widgetWithText(TextFormField, 'Confirm Password');
      expect(confirmField, findsOneWidget);

      final editableText = find.descendant(
        of: confirmField,
        matching: find.byType(EditableText),
      );
      expect(tester.widget<EditableText>(editableText).obscureText, isTrue);
    });

    testWidgets('should show validation error when passwords do not match',
        (tester) async {
      await tester.pumpWidget(createTestWidget());

      await tester.tap(find.text("Don't have an account? Sign Up"));
      await tester.pump();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Full Name'),
        'Test User',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'test@example.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        'password123',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Confirm Password'),
        'password456',
      );

      await tester.tap(find.text('Create Account'));
      await tester.pump();

      expect(find.text('Passwords do not match.'), findsOneWidget);
    });

    testWidgets('should require name field in register mode', (tester) async {
      await tester.pumpWidget(createTestWidget());

      await tester.tap(find.text("Don't have an account? Sign Up"));
      await tester.pump();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'test@example.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        'password123',
      );

      await tester.tap(find.text('Create Account'));
      await tester.pump();

      expect(find.text('Please enter your name.'), findsOneWidget);
    });

    testWidgets('should clear error when switching modes', (tester) async {
      await tester.pumpWidget(createTestWidget());

      await tester.tap(find.text("Don't have an account? Sign Up"));
      await tester.pump();

      final loginToggle = find.text('Already have an account? Login');
      await tester.ensureVisible(loginToggle);
      await tester.pumpAndSettle();
      await tester.tap(loginToggle);
      await tester.pump();

      expect(find.text('Welcome back! Please log in.'), findsOneWidget);
    });

    testWidgets('should show app icon and title', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.byIcon(Icons.remove_red_eye), findsOneWidget);
      expect(find.text('Eye Monitoring'), findsOneWidget);
    });
  });
}
