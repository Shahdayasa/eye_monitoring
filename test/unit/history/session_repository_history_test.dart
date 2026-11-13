import 'package:flutter_test/flutter_test.dart';
import 'package:eye_monitoring/features/history/data/session_repository.dart';
import 'package:eye_monitoring/models/prediction.dart';
import 'package:eye_monitoring/models/session.dart';

void main() {
  group('InMemorySessionRepository history/report queries', () {
    late InMemorySessionRepository repo;

    setUp(() => repo = InMemorySessionRepository());

    test('returns sessions sorted by start time desc', () async {
      final s1 = await repo.createSession(uid: 'u1', deviceId: 'd1');
      await repo.saveSession(
        uid: 'u1',
        session: s1.copyWith(startedAt: DateTime.utc(2026, 1, 1, 10)),
      );
      final s2 = await repo.createSession(uid: 'u1', deviceId: 'd2');
      await repo.saveSession(
        uid: 'u1',
        session: s2.copyWith(startedAt: DateTime.utc(2026, 1, 2, 10)),
      );

      final sessions = await repo.getUserSessions('u1');
      expect(sessions, hasLength(2));
      expect(sessions.first.id, s2.id);
      expect(sessions.last.id, s1.id);
    });

    test('getSession returns session or null', () async {
      final s = await repo.createSession(uid: 'u1', deviceId: 'd1');
      expect((await repo.getSession('u1', s.id))?.id, s.id);
      expect(await repo.getSession('u1', 'missing'), isNull);
    });

    test('saves predictions and increments predictionCount', () async {
      final s = await repo.createSession(uid: 'u1', deviceId: 'd1');
      final pred = PredictionResult(
        prediction: 'fatigued',
        probabilities: const {'fatigued': 0.8, 'alert': 0.2},
        modelVersion: 'v1',
        message: '',
        qualityStatus: 'good',
        features: const {},
        windowStart: DateTime.utc(2026, 1, 1, 12),
        windowDurationSeconds: 10,
        createdAt: DateTime.utc(2026, 1, 1, 12, 0, 10),
      );

      await repo.savePrediction(uid: 'u1', sessionId: s.id, prediction: pred);
      await repo.savePrediction(
        uid: 'u1',
        sessionId: s.id,
        prediction: pred.copyWith(),
      );

      final preds = await repo.getPredictionsForSession('u1', s.id);
      expect(preds, hasLength(2));
      expect(preds.first.id, isNotNull);
      final updated = await repo.getSession('u1', s.id);
      expect(updated?.predictionCount, 2);
    });

    test('getPredictionsForSession returns chronological list', () async {
      final s = await repo.createSession(uid: 'u1', deviceId: 'd1');
      await repo.savePrediction(
        uid: 'u1',
        sessionId: s.id,
        prediction: PredictionResult(
          prediction: 'alert',
          probabilities: const {'alert': 0.9},
          modelVersion: 'v1',
          message: '',
          qualityStatus: 'good',
          features: const {},
          windowStart: DateTime.utc(2026, 1, 1, 12),
          windowDurationSeconds: 10,
          createdAt: DateTime.utc(2026, 1, 1, 12, 0, 20),
        ),
      );
      await repo.savePrediction(
        uid: 'u1',
        sessionId: s.id,
        prediction: PredictionResult(
          prediction: 'fatigued',
          probabilities: const {'fatigued': 0.7},
          modelVersion: 'v1',
          message: '',
          qualityStatus: 'good',
          features: const {},
          windowStart: DateTime.utc(2026, 1, 1, 12),
          windowDurationSeconds: 10,
          createdAt: DateTime.utc(2026, 1, 1, 12, 0, 10),
        ),
      );
      final preds = await repo.getPredictionsForSession('u1', s.id);
      expect(preds.first.createdAt.isBefore(preds.last.createdAt), isTrue);
      expect(preds.first.prediction, 'fatigued');
    });
  });
}
