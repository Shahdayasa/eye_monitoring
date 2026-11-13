import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:eye_monitoring/features/authentication/data/auth_repository.dart';
import 'package:eye_monitoring/features/authentication/domain/user_model.dart';
import 'package:eye_monitoring/features/authentication/presentation/auth_provider.dart';
import 'package:eye_monitoring/features/history/data/session_repository.dart';
import 'package:eye_monitoring/features/history/presentation/session_detail_page.dart';
import 'package:eye_monitoring/models/prediction.dart';
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

void main() {
  testWidgets('shows session details and empty prediction summary', (tester) async {
    final repo = InMemorySessionRepository();
    final session = MonitoringSession(
      id: 's1',
      deviceId: 'glasses-01',
      startedAt: DateTime.utc(2026, 11, 13, 10, 0),
      endedAt: DateTime.utc(2026, 11, 13, 10, 5),
      durationSeconds: 300,
      status: SessionStatus.completed,
      predictionCount: 0,
    );
    await repo.saveSession(uid: 'u1', session: session);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>.value(
              value: _SignedInAuthProvider(_FakeAuthRepository())),
          Provider<SessionRepositoryBase>.value(value: repo),
        ],
        child: const MaterialApp(home: SessionDetailPage(sessionId: 's1')),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Session Details'), findsOneWidget);
    expect(find.text('Session metadata'), findsOneWidget);
    expect(find.text('glasses-01'), findsOneWidget);
    expect(find.textContaining('No predictions recorded'), findsOneWidget);
  });

  testWidgets('shows prediction summary and trend/list with data', (tester) async {
    final repo = InMemorySessionRepository();
    final session = MonitoringSession(
      id: 's2',
      deviceId: 'glasses-02',
      startedAt: DateTime.utc(2026, 11, 13, 11, 0),
      endedAt: DateTime.utc(2026, 11, 13, 11, 10),
      durationSeconds: 600,
      status: SessionStatus.completed,
      predictionCount: 0,
    );
    await repo.saveSession(uid: 'u1', session: session);
    await repo.savePrediction(
      uid: 'u1',
      sessionId: 's2',
      prediction: PredictionResult(
        prediction: 'alert',
        probabilities: const {'alert': 0.9, 'fatigued': 0.1},
        modelVersion: 'v1',
        message: 'ok',
        qualityStatus: 'good',
        features: const {},
        windowStart: DateTime.utc(2026, 11, 13, 11, 1),
        windowDurationSeconds: 10,
        createdAt: DateTime.utc(2026, 11, 13, 11, 1, 10),
      ),
    );
    await repo.savePrediction(
      uid: 'u1',
      sessionId: 's2',
      prediction: PredictionResult(
        prediction: 'fatigued',
        probabilities: const {'fatigued': 0.8, 'alert': 0.2},
        modelVersion: 'v1',
        message: 'check rest',
        qualityStatus: 'good',
        features: const {},
        windowStart: DateTime.utc(2026, 11, 13, 11, 2),
        windowDurationSeconds: 10,
        createdAt: DateTime.utc(2026, 11, 13, 11, 2, 10),
      ),
    );

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>.value(
              value: _SignedInAuthProvider(_FakeAuthRepository())),
          Provider<SessionRepositoryBase>.value(value: repo),
        ],
        child: const MaterialApp(home: SessionDetailPage(sessionId: 's2')),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Prediction summary'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Confidence trend'), 200);
    expect(find.text('Confidence trend'), findsOneWidget);
    expect(find.textContaining('Total predictions'), findsOneWidget);
    final scrollable = find.byType(Scrollable).first;
    await tester.scrollUntilVisible(find.text('Predictions'), 300, scrollable: scrollable);
    expect(find.text('Predictions'), findsOneWidget);
  });
}
