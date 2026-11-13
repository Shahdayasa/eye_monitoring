import 'dart:async';

import 'package:flutter/widgets.dart';

import '../../../core/logging/app_logger.dart';
import '../../../models/session.dart';
import '../../../services/ble/ble_service.dart';
import '../../device/domain/ble_device.dart';
import '../data/session_repository.dart';

class SessionProvider extends ChangeNotifier with WidgetsBindingObserver {
  SessionProvider({
    required SessionRepositoryBase repository,
    BleService? bleService,
  })  : _repository = repository,
        _bleService = bleService {
    WidgetsBinding.instance.addObserver(this);
    _bleStateSub = _bleService?.connectionState.listen(_onBleStateChanged);
  }

  final SessionRepositoryBase _repository;
  final BleService? _bleService;

  StreamSubscription<BleDeviceConnectionState>? _bleStateSub;
  Timer? _ticker;

  MonitoringSession? _currentSession;
  String? _activeUid;
  String? _errorMessage;
  bool _isSaving = false;

  MonitoringSession? get currentSession => _currentSession;
  bool get hasActiveSession => _currentSession?.isActive == true;
  String? get errorMessage => _errorMessage;
  bool get isSaving => _isSaving;

  int get elapsedSeconds {
    final session = _currentSession;
    if (session == null) return 0;
    if (!session.isActive) return session.durationSeconds;
    final diff = DateTime.now().difference(session.startedAt).inSeconds;
    return diff < 0 ? 0 : diff;
  }

  String get formattedDuration {
    final total = elapsedSeconds;
    final hours = total ~/ 3600;
    final minutes = (total % 3600) ~/ 60;
    final seconds = total % 60;
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:'
          '${minutes.toString().padLeft(2, '0')}:'
          '${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  Future<bool> startSession({
    required String uid,
    required String deviceId,
  }) async {
    if (hasActiveSession) {
      _errorMessage = 'A session is already active.';
      notifyListeners();
      return false;
    }
    if (uid.isEmpty) {
      _errorMessage = 'You must be signed in to start a session.';
      notifyListeners();
      return false;
    }
    if (deviceId.isEmpty) {
      _errorMessage = 'Connect a device before starting a session.';
      notifyListeners();
      return false;
    }

    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final session = await _repository.createSession(
        uid: uid,
        deviceId: deviceId,
      );
      _activeUid = uid;
      _currentSession = session;
      _startTicker();
      _isSaving = false;
      notifyListeners();
      return true;
    } catch (e) {
      AppLogger.error('Failed to start session', tag: 'SESSION', error: e);
      _errorMessage = 'Failed to start session. Check your connection and try again.';
      _isSaving = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> stopSession({
    SessionStatus status = SessionStatus.completed,
  }) async {
    final session = _currentSession;
    final uid = _activeUid;
    if (session == null || uid == null || !session.isActive) {
      return false;
    }

    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    final endedAt = DateTime.now();
    final duration = elapsedSeconds;

    try {
      await _repository.endSession(
        uid: uid,
        sessionId: session.id,
        endedAt: endedAt,
        durationSeconds: duration,
        status: status,
      );
      _stopTicker();
      _currentSession = session.copyWith(
        endedAt: endedAt,
        durationSeconds: duration,
        status: status,
      );
      _isSaving = false;
      notifyListeners();
      return true;
    } catch (e) {
      AppLogger.error('Failed to save ended session', tag: 'SESSION', error: e);
      // Keep session marked locally so data isn't lost from UI perspective.
      _stopTicker();
      _currentSession = session.copyWith(
        endedAt: endedAt,
        durationSeconds: duration,
        status: status,
      );
      _errorMessage = 'Session ended locally but could not be saved to cloud. It will be retried when possible.';
      _isSaving = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> handleInterruption({String? reason}) async {
    if (!hasActiveSession) return;
    if (reason != null) {
      _errorMessage = reason;
    }
    await stopSession(status: SessionStatus.interrupted);
  }

  void clearSession() {
    _stopTicker();
    _currentSession = null;
    _activeUid = null;
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (hasActiveSession) notifyListeners();
    });
  }

  void _stopTicker() {
    _ticker?.cancel();
    _ticker = null;
  }

  void _onBleStateChanged(BleDeviceConnectionState state) {
    if (!hasActiveSession) return;
    if (state == BleDeviceConnectionState.disconnected ||
        state == BleDeviceConnectionState.error) {
      // Defer to avoid re-entrant notify issues from nested listeners.
      Future<void>.microtask(() => handleInterruption(
            reason: 'Session interrupted: device disconnected.',
          ));
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!hasActiveSession) return;
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached ||
        state == AppLifecycleState.hidden) {
      Future<void>.microtask(() => handleInterruption(
            reason: 'Session interrupted: app moved to background.',
          ));
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _bleStateSub?.cancel();
    _stopTicker();
    // Best-effort: if active, mark interrupted in memory; async persist cannot
    // be awaited in dispose.
    final session = _currentSession;
    final uid = _activeUid;
    if (session != null && uid != null && session.isActive) {
      final endedAt = DateTime.now();
      final duration = elapsedSeconds;
      _currentSession = session.copyWith(
        endedAt: endedAt,
        durationSeconds: duration,
        status: SessionStatus.interrupted,
      );
      unawaited(_repository.endSession(
        uid: uid,
        sessionId: session.id,
        endedAt: endedAt,
        durationSeconds: duration,
        status: SessionStatus.interrupted,
      ));
    }
    super.dispose();
  }
}
