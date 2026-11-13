import 'package:flutter_test/flutter_test.dart';
import 'package:eye_monitoring/models/session.dart';

void main() {
  group('MonitoringSession', () {
    test('creates with required fields and defaults', () {
      final started = DateTime(2026, 1, 1, 12);
      final session = MonitoringSession(
        id: 's1',
        deviceId: 'dev-1',
        startedAt: started,
        durationSeconds: 0,
        status: SessionStatus.active,
      );

      expect(session.id, 's1');
      expect(session.deviceId, 'dev-1');
      expect(session.isActive, isTrue);
      expect(session.predictionCount, 0);
      expect(session.endedAt, isNull);
    });

    test('copyWith updates fields and status', () {
      final started = DateTime(2026, 1, 1, 12);
      final session = MonitoringSession(
        id: 's1',
        deviceId: 'dev-1',
        startedAt: started,
        durationSeconds: 0,
        status: SessionStatus.active,
      );

      final ended = started.add(const Duration(minutes: 5));
      final updated = session.copyWith(
        endedAt: ended,
        durationSeconds: 300,
        status: SessionStatus.completed,
      );

      expect(updated.isActive, isFalse);
      expect(updated.status, SessionStatus.completed);
      expect(updated.durationSeconds, 300);
      expect(updated.endedAt, ended);
      expect(updated.deviceId, 'dev-1');
    });

    test('toFirestore/fromMap round-trip basics', () {
      final started = DateTime(2026, 1, 1, 12);
      final session = MonitoringSession(
        id: 's1',
        deviceId: 'esp32',
        startedAt: started,
        endedAt: started.add(const Duration(seconds: 42)),
        durationSeconds: 42,
        status: SessionStatus.interrupted,
        predictionCount: 3,
      );

      final map = session.toFirestore();
      final restored = MonitoringSession.fromMap('s1', {
        ...map,
        'startedAt': started,
        'endedAt': started.add(const Duration(seconds: 42)),
      });

      expect(restored.id, 's1');
      expect(restored.deviceId, 'esp32');
      expect(restored.durationSeconds, 42);
      expect(restored.status, SessionStatus.interrupted);
      expect(restored.predictionCount, 3);
    });

    test('status parsing', () {
      expect(SessionStatusX.fromValue('completed'), SessionStatus.completed);
      expect(SessionStatusX.fromValue('interrupted'), SessionStatus.interrupted);
      expect(SessionStatusX.fromValue('active'), SessionStatus.active);
      expect(SessionStatusX.fromValue(null), SessionStatus.active);
      expect(SessionStatusX.fromValue('unknown'), SessionStatus.active);
    });
  });
}
