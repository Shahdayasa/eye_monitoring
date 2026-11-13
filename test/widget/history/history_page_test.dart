import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:eye_monitoring/features/authentication/data/auth_repository.dart';
import 'package:eye_monitoring/features/authentication/domain/user_model.dart';
import 'package:eye_monitoring/features/authentication/presentation/auth_provider.dart';
import 'package:eye_monitoring/features/history/data/session_repository.dart';
import 'package:eye_monitoring/features/history/presentation/history_page.dart';
import 'package:eye_monitoring/models/session.dart';

class _FakeAuthRepository implements AuthRepository {
  @override
  Stream<User?> get authStateChanges => const Stream.empty();
  @override
  User? get currentUser => null;
  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _SignedInAuthProvider extends AuthProvider {
  _SignedInAuthProvider(super.repo);
  @override
  UserModel? get user => UserModel(
        uid: 'u1',
        email: 'a@b.com',
        displayName: 'Test',
        createdAt: DateTime.utc(2026, 1, 1),
        profileCompleted: true,
      );
}

class _SignedOutAuthProvider extends AuthProvider {
  _SignedOutAuthProvider(super.repo);
  @override
  UserModel? get user => null;
}

MonitoringSession _session(String id, DateTime startedAt) => MonitoringSession(
      id: id,
      deviceId: 'device-1',
      startedAt: startedAt,
      endedAt: startedAt.add(const Duration(minutes: 5)),
      durationSeconds: 300,
      status: SessionStatus.completed,
      predictionCount: 2,
    );

void main() {
  Widget wrap({
    required AuthProvider auth,
    required SessionRepositoryBase repo,
  }) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: auth),
        Provider<SessionRepositoryBase>.value(value: repo),
      ],
      child: const MaterialApp(home: HistoryPage()),
    );
  }

  testWidgets('shows sign-in message when unauthenticated', (tester) async {
    await tester.pumpWidget(wrap(
      auth: _SignedOutAuthProvider(_FakeAuthRepository()),
      repo: InMemorySessionRepository(),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Sign in to view history.'), findsOneWidget);
  });

  testWidgets('shows empty state when no sessions', (tester) async {
    await tester.pumpWidget(wrap(
      auth: _SignedInAuthProvider(_FakeAuthRepository()),
      repo: InMemorySessionRepository(),
    ));
    await tester.pumpAndSettle();
    expect(find.text('No sessions yet'), findsOneWidget);
  });

  testWidgets('renders session list', (tester) async {
    final repo = InMemorySessionRepository();
    await repo.saveSession(
      uid: 'u1',
      session: _session('s1', DateTime.now().subtract(const Duration(hours: 1))),
    );
    await tester.pumpWidget(wrap(
      auth: _SignedInAuthProvider(_FakeAuthRepository()),
      repo: repo,
    ));
    await tester.pumpAndSettle();
    expect(find.text('Session History'), findsOneWidget);
    expect(find.textContaining('predictions'), findsOneWidget);
    expect(find.text('Completed'), findsOneWidget);
  });
}
