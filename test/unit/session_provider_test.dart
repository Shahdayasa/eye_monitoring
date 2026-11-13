import 'package:flutter_test/flutter_test.dart';
import 'package:eye_monitoring/features/history/data/session_repository.dart';
import 'package:eye_monitoring/features/history/presentation/session_provider.dart';
import 'package:eye_monitoring/models/session.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SessionProvider', () {
    late InMemorySessionRepository repository;
    late SessionProvider provider;

    setUp(() {
      repository = InMemorySessionRepository();
      provider = SessionProvider(repository: repository);
    });

    tearDown(() {
      provider.dispose();
    });

    test('starts a session and tracks active state', () async {
      final ok = await provider.startSession(uid: 'u1', deviceId: 'dev-1');

      expect(ok, isTrue);
      expect(provider.hasActiveSession, isTrue);
      expect(provider.currentSession, isNotNull);
      expect(provider.currentSession!.deviceId, 'dev-1');
      expect(provider.currentSession!.status, SessionStatus.active);

      final stored = repository.getSessionSync('u1', provider.currentSession!.id);
      expect(stored, isNotNull);
      expect(stored!.isActive, isTrue);
    });

    test('fails to start when already active', () async {
      await provider.startSession(uid: 'u1', deviceId: 'dev-1');
      final ok = await provider.startSession(uid: 'u1', deviceId: 'dev-2');

      expect(ok, isFalse);
      expect(provider.errorMessage, isNotNull);
    });

    test('stops session and persists completion', () async {
      await provider.startSession(uid: 'u1', deviceId: 'dev-1');
      final id = provider.currentSession!.id;

      await Future<void>.delayed(const Duration(milliseconds: 1100));
      final ok = await provider.stopSession(status: SessionStatus.completed);

      expect(ok, isTrue);
      expect(provider.hasActiveSession, isFalse);
      expect(provider.currentSession!.status, SessionStatus.completed);
      expect(provider.currentSession!.endedAt, isNotNull);
      expect(provider.currentSession!.durationSeconds, greaterThanOrEqualTo(1));

      final stored = repository.getSessionSync('u1', id)!;
      expect(stored.status, SessionStatus.completed);
      expect(stored.durationSeconds, greaterThanOrEqualTo(1));
    });

    test('interrupts active session', () async {
      await provider.startSession(uid: 'u1', deviceId: 'dev-1');
      final id = provider.currentSession!.id;

      await provider.handleInterruption(reason: 'test interruption');

      expect(provider.hasActiveSession, isFalse);
      expect(provider.currentSession!.status, SessionStatus.interrupted);
      final stored = repository.getSessionSync('u1', id)!;
      expect(stored.status, SessionStatus.interrupted);
    });

    test('requires uid and deviceId', () async {
      expect(await provider.startSession(uid: '', deviceId: 'dev'), isFalse);
      expect(await provider.startSession(uid: 'u1', deviceId: ''), isFalse);
    });
  });
}
