import 'package:flutter/foundation.dart';

import '../../../core/logging/app_logger.dart';
import '../../../models/prediction.dart';
import '../../authentication/presentation/auth_provider.dart';
import '../../device/presentation/ble_provider.dart';
import '../../history/data/session_repository.dart';
import '../../history/presentation/session_provider.dart';
import '../../monitoring/presentation/monitoring_provider.dart';
import '../data/prediction_repository.dart';

class PredictionProvider extends ChangeNotifier {
  PredictionProvider({
    required PredictionRepository repository,
    required MonitoringProvider monitoringProvider,
    required BleProvider bleProvider,
    AuthProvider? authProvider,
    SessionProvider? sessionProvider,
    SessionRepositoryBase? sessionRepository,
  })  : _repository = repository,
        _monitoringProvider = monitoringProvider,
        _bleProvider = bleProvider,
        _authProvider = authProvider,
        _sessionProvider = sessionProvider,
        _sessionRepository = sessionRepository;

  final PredictionRepository _repository;
  final MonitoringProvider _monitoringProvider;
  final BleProvider _bleProvider;
  final AuthProvider? _authProvider;
  final SessionProvider? _sessionProvider;
  final SessionRepositoryBase? _sessionRepository;

  PredictionResult? _latestResult;
  String? _errorMessage;
  bool _isLoading = false;

  PredictionResult? get latestResult => _latestResult;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;

  int get requiredSamples =>
      (_monitoringProvider.buffer.sampleRateHz *
              _monitoringProvider.buffer.windowSeconds)
          .round();

  int get availableSamples => _monitoringProvider.buffer.samples.length;

  bool get canAnalyze =>
      !_isLoading && availableSamples >= requiredSamples && requiredSamples > 0;

  String? get analyzeBlockReason {
    if (_isLoading) return 'Analysis in progress';
    if (_monitoringProvider.buffer.samples.isEmpty) {
      return 'No signal data available. Connect a device and start monitoring first.';
    }
    if (availableSamples < requiredSamples) {
      final secs = _monitoringProvider.buffer.windowSeconds;
      return 'Need $requiredSamples samples (${secs}s window). Currently have $availableSamples.';
    }
    return null;
  }

  Future<bool> analyzeCurrentWindow() async {
    if (_isLoading) return false;
    final window = _repository.buildWindowFromBuffer(_monitoringProvider.buffer);
    if (window == null) {
      _errorMessage = analyzeBlockReason ?? 'Insufficient signal data for analysis.';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      String? token;
      try {
        token = await _tryGetIdToken();
      } catch (_) {
        token = null;
      }
      final result = await _repository.predictWindow(
        window,
        authToken: token,
        deviceId: _bleProvider.connectedDevice?.id,
      );
      _latestResult = result;
      await _persistIfPossible(result);
      _isLoading = false;
      notifyListeners();
      return true;
    } on PredictionApiException catch (e) {
      AppLogger.error('Prediction API error', tag: 'PREDICT', error: e);
      _errorMessage = _friendlyApiError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      AppLogger.error('Unexpected prediction error', tag: 'PREDICT', error: e);
      _errorMessage = 'Unexpected error during analysis. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> _persistIfPossible(PredictionResult result) async {
    try {
      final uid = _authProvider?.user?.uid;
      final session = _sessionProvider?.currentSession;
      final repo = _sessionRepository;
      if (uid == null || session == null || repo == null) return;
      await repo.savePrediction(
        uid: uid,
        sessionId: session.id,
        prediction: result,
      );
    } catch (e) {
      AppLogger.warning('Failed to persist prediction (best-effort)', tag: 'PREDICT', data: e);
      // Prediction is still shown to user; persistence is best-effort.
    }
  }

  Future<String?> _tryGetIdToken() async {
    try {
      final user = _authProvider?.user;
      // If user model exposes Firebase token in future, prefer it; avoid hard dependency.
      return null;
    } catch (_) {
      return null;
    }
  }

  String _friendlyApiError(PredictionApiException e) {
    if (e.isTimeout) return 'Request timed out. Check your connection or AI service and try again.';
    if (e.isNetwork) return 'No connection to AI service. Verify network/API settings and try again.';
    if (e.isUnauthorized) return 'Authentication failed for AI service. Please sign in again.';
    if (e.statusCode == 422) return 'Invalid signal window: ${e.message}';
    if (e.statusCode != null && e.statusCode! >= 500) {
      return 'AI service is unavailable right now (${e.statusCode}). Please try again later.';
    }
    return e.message;
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearResult() {
    _latestResult = null;
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _repository.dispose();
    super.dispose();
  }
}
