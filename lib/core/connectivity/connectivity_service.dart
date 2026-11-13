import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

import '../logging/app_logger.dart';

class ConnectivityService extends ChangeNotifier {
  ConnectivityService({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;
  StreamSubscription<List<ConnectivityResult>>? _sub;
  bool _isOnline = true;
  bool _initialized = false;

  bool get isOnline => _isOnline;
  bool get isOffline => !_isOnline;
  bool get initialized => _initialized;

  Future<void> initialize() async {
    if (_initialized) return;
    try {
      final results = await _connectivity.checkConnectivity();
      _updateFromResults(results, emitLog: false);
    } catch (e) {
      AppLogger.warning('Connectivity check failed, assuming online', tag: 'NET', data: e);
      _isOnline = true;
    }
    _sub = _connectivity.onConnectivityChanged.listen(
      (results) => _updateFromResults(results),
      onError: (e) {
        AppLogger.error('Connectivity stream error', tag: 'NET', error: e);
      },
    );
    _initialized = true;
    notifyListeners();
  }

  void _updateFromResults(List<ConnectivityResult> results, {bool emitLog = true}) {
    final online = results.any((r) => r != ConnectivityResult.none);
    if (online == _isOnline) return;
    _isOnline = online;
    if (emitLog) {
      AppLogger.info(online ? 'Back online' : 'Offline', tag: 'NET', data: results.map((r) => r.name).join(','));
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
