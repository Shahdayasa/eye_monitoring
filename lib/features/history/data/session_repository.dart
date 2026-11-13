import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/config/app_config.dart';
import '../../../core/logging/app_logger.dart';
import '../../../models/prediction.dart';
import '../../../models/session.dart';

abstract class SessionRepositoryBase {
  Future<MonitoringSession> createSession({
    required String uid,
    required String deviceId,
  });

  Future<void> saveSession({
    required String uid,
    required MonitoringSession session,
  });

  Future<void> endSession({
    required String uid,
    required String sessionId,
    required DateTime endedAt,
    required int durationSeconds,
    required SessionStatus status,
  });

  Future<List<MonitoringSession>> getUserSessions(String uid);
  Future<MonitoringSession?> getSession(String uid, String sessionId);
  Future<void> savePrediction({
    required String uid,
    required String sessionId,
    required PredictionResult prediction,
  });
  Future<List<PredictionResult>> getPredictionsForSession(
    String uid,
    String sessionId,
  );

  Future<void> deleteAllSessions(String uid);
}

class SessionRepository implements SessionRepositoryBase {
  SessionRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _sessions(String uid) {
    return _firestore
        .collection(AppConfig.usersCollection)
        .doc(uid)
        .collection(AppConfig.sessionsCollection);
  }

  CollectionReference<Map<String, dynamic>> _predictions(
    String uid,
    String sessionId,
  ) {
    return _sessions(uid)
        .doc(sessionId)
        .collection(AppConfig.predictionsCollection);
  }

  Future<T> _withRetry<T>(Future<T> Function() op, {String tag = 'FIRESTORE'}) async {
    const attempts = 3;
    var delay = const Duration(milliseconds: 400);
    Object? lastError;
    for (var i = 0; i < attempts; i++) {
      try {
        return await op();
      } catch (e) {
        lastError = e;
        final retryable = e is SocketException ||
            e is TimeoutException ||
            e is FirebaseException && (e.code == 'unavailable' || e.code == 'network-request-failed' || e.code == 'deadline-exceeded');
        AppLogger.error('Firestore op failed (attempt ${i + 1}/$attempts)', tag: tag, error: e);
        if (!retryable || i == attempts - 1) rethrow;
        await Future<void>.delayed(delay);
        delay *= 2;
      }
    }
    // ignore: only_throw_errors
    throw lastError!;
  }

  @override
  Future<MonitoringSession> createSession({
    required String uid,
    required String deviceId,
  }) async {
    final doc = _sessions(uid).doc();
    final session = MonitoringSession(
      id: doc.id,
      deviceId: deviceId,
      startedAt: DateTime.now(),
      durationSeconds: 0,
      status: SessionStatus.active,
    );
    await _withRetry(() => doc.set(session.toFirestore()), tag: 'SESSION');
    return session;
  }

  @override
  Future<void> saveSession({
    required String uid,
    required MonitoringSession session,
  }) async {
    await _withRetry(() => _sessions(uid).doc(session.id).set(session.toFirestore()), tag: 'SESSION');
  }

  @override
  Future<void> endSession({
    required String uid,
    required String sessionId,
    required DateTime endedAt,
    required int durationSeconds,
    required SessionStatus status,
  }) async {
    await _withRetry(
      () => _sessions(uid).doc(sessionId).set({
        'endedAt': Timestamp.fromDate(endedAt),
        'duration': durationSeconds,
        'status': status.value,
      }, SetOptions(merge: true)),
      tag: 'SESSION',
    );
  }

  @override
  Future<List<MonitoringSession>> getUserSessions(String uid) async {
    final snapshot = await _withRetry(
      () => _sessions(uid).orderBy('startedAt', descending: true).get(),
      tag: 'SESSION',
    );
    return snapshot.docs.map((d) => MonitoringSession.fromFirestore(d)).toList();
  }

  @override
  Future<MonitoringSession?> getSession(String uid, String sessionId) async {
    final doc = await _withRetry(() => _sessions(uid).doc(sessionId).get(), tag: 'SESSION');
    if (!doc.exists) return null;
    return MonitoringSession.fromFirestore(doc);
  }

  @override
  Future<void> savePrediction({
    required String uid,
    required String sessionId,
    required PredictionResult prediction,
  }) async {
    await _withRetry(() async {
      final predRef = _predictions(uid, sessionId).doc();
      final batch = _firestore.batch();
      batch.set(predRef, prediction.toFirestore());
      batch.set(
        _sessions(uid).doc(sessionId),
        {
          'predictionCount': FieldValue.increment(1),
          'lastPredictionAt': Timestamp.fromDate(prediction.createdAt),
          'lastPrediction': prediction.prediction,
        },
        SetOptions(merge: true),
      );
      await batch.commit();
    }, tag: 'PREDICTION');
  }

  @override
  Future<List<PredictionResult>> getPredictionsForSession(
    String uid,
    String sessionId,
  ) async {
    final snapshot = await _withRetry(
      () => _predictions(uid, sessionId).orderBy('createdAt', descending: false).get(),
      tag: 'PREDICTION',
    );
    return snapshot.docs.map((d) => PredictionResult.fromFirestore(d)).toList();
  }

  @override
  Future<void> deleteAllSessions(String uid) async {
    await _withRetry(() async {
      final sessions = await _sessions(uid).get();
      for (final doc in sessions.docs) {
        final preds = await _predictions(uid, doc.id).get();
        for (final p in preds.docs) {
          await p.reference.delete();
        }
        await doc.reference.delete();
      }
    }, tag: 'SESSION');
  }
}

/// In-memory repository for tests and offline/local fallback.
class InMemorySessionRepository implements SessionRepositoryBase {
  final Map<String, Map<String, MonitoringSession>> _store = {};
  final Map<String, Map<String, List<PredictionResult>>> _predictions = {};
  int _counter = 0;
  int _predCounter = 0;

  Map<String, MonitoringSession> _userStore(String uid) =>
      _store.putIfAbsent(uid, () => <String, MonitoringSession>{});

  Map<String, List<PredictionResult>> _userPreds(String uid) =>
      _predictions.putIfAbsent(uid, () => <String, List<PredictionResult>>{});

  @override
  Future<MonitoringSession> createSession({
    required String uid,
    required String deviceId,
  }) async {
    final id = 'session_${++_counter}';
    final session = MonitoringSession(
      id: id,
      deviceId: deviceId,
      startedAt: DateTime.now(),
      durationSeconds: 0,
      status: SessionStatus.active,
    );
    _userStore(uid)[id] = session;
    return session;
  }

  @override
  Future<void> saveSession({
    required String uid,
    required MonitoringSession session,
  }) async {
    _userStore(uid)[session.id] = session;
  }

  @override
  Future<void> endSession({
    required String uid,
    required String sessionId,
    required DateTime endedAt,
    required int durationSeconds,
    required SessionStatus status,
  }) async {
    final existing = _userStore(uid)[sessionId];
    if (existing == null) return;
    _userStore(uid)[sessionId] = existing.copyWith(
      endedAt: endedAt,
      durationSeconds: durationSeconds,
      status: status,
    );
  }

  @override
  Future<List<MonitoringSession>> getUserSessions(String uid) async {
    final list = _userStore(uid).values.toList();
    list.sort((a, b) => b.startedAt.compareTo(a.startedAt));
    return list;
  }

  @override
  Future<MonitoringSession?> getSession(String uid, String sessionId) async {
    return _userStore(uid)[sessionId];
  }

  @override
  Future<void> savePrediction({
    required String uid,
    required String sessionId,
    required PredictionResult prediction,
  }) async {
    final preds = _userPreds(uid).putIfAbsent(sessionId, () => []);
    final withId = prediction.copyWith(id: 'pred_${++_predCounter}');
    preds.add(withId);
    final session = _userStore(uid)[sessionId];
    if (session != null) {
      _userStore(uid)[sessionId] = session.copyWith(
        predictionCount: session.predictionCount + 1,
      );
    }
  }

  @override
  Future<List<PredictionResult>> getPredictionsForSession(
    String uid,
    String sessionId,
  ) async {
    final list = List<PredictionResult>.from(_userPreds(uid)[sessionId] ?? const []);
    list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return list;
  }

  @override
  Future<void> deleteAllSessions(String uid) async {
    _store.remove(uid);
    _predictions.remove(uid);
  }

  MonitoringSession? getSessionSync(String uid, String sessionId) =>
      _userStore(uid)[sessionId];

  List<MonitoringSession> sessionsFor(String uid) =>
      _userStore(uid).values.toList();
}

/// Compatibility wrapper for older settings code expecting a per-user repository.
class FirestoreSessionRepository implements SessionRepositoryBase {
  FirestoreSessionRepository({required String userId, FirebaseFirestore? firestore})
      : _userId = userId,
        _delegate = SessionRepository(firestore: firestore);

  final String _userId;
  final SessionRepository _delegate;

  @override
  Future<MonitoringSession> createSession({required String uid, required String deviceId}) =>
      _delegate.createSession(uid: uid, deviceId: deviceId);

  @override
  Future<void> saveSession({required String uid, required MonitoringSession session}) =>
      _delegate.saveSession(uid: uid, session: session);

  @override
  Future<void> endSession({required String uid, required String sessionId, required DateTime endedAt, required int durationSeconds, required SessionStatus status}) =>
      _delegate.endSession(uid: uid, sessionId: sessionId, endedAt: endedAt, durationSeconds: durationSeconds, status: status);

  @override
  Future<List<MonitoringSession>> getUserSessions(String uid) => _delegate.getUserSessions(uid);

  @override
  Future<MonitoringSession?> getSession(String uid, String sessionId) => _delegate.getSession(uid, sessionId);

  @override
  Future<void> savePrediction({required String uid, required String sessionId, required PredictionResult prediction}) =>
      _delegate.savePrediction(uid: uid, sessionId: sessionId, prediction: prediction);

  @override
  Future<List<PredictionResult>> getPredictionsForSession(String uid, String sessionId) =>
      _delegate.getPredictionsForSession(uid, sessionId);

  @override
  Future<void> deleteAllSessions(String uid) => _delegate.deleteAllSessions(uid);

  Future<void> deleteAllSessionsForCurrentUser() => _delegate.deleteAllSessions(_userId);
}

