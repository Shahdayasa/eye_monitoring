import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';

import '../../../core/logging/app_logger.dart';
import '../../../services/ble/ble_service.dart';
import '../../device/domain/ble_device.dart';
import '../data/signal_buffer.dart';
import '../domain/signal_model.dart';

class MonitoringProvider extends ChangeNotifier {
  final BleService _bleService;
  final SignalBuffer buffer;

  MonitoringProvider(this._bleService, {SignalBuffer? buffer})
      : buffer = buffer ?? SignalBuffer() {
    _init();
  }

  StreamSubscription<Uint8List>? _dataSub;
  StreamSubscription<BleDeviceConnectionState>? _stateSub;
  StreamSubscription<String?>? _errorSub;
  Timer? _tickTimer;

  BleDeviceConnectionState _connectionState =
      BleDeviceConnectionState.disconnected;
  String? _errorMessage;
  bool _streamActive = false;
  DateTime? _lastUiUpdate;

  BleDeviceConnectionState get connectionState => _connectionState;
  String? get errorMessage => _errorMessage;
  bool get isConnected => _connectionState == BleDeviceConnectionState.connected;
  bool get streamActive => _streamActive && isConnected;

  LightReading? get latestLight => buffer.latestLight;
  int? get latestBattery => buffer.latestBattery;
  SignalQualityStatus get quality => buffer.qualityStatus();
  bool get hasData => buffer.hasData;
  bool get isMissingData => isConnected && buffer.isMissingData;
  bool get isReceiving => isConnected && buffer.isReceiving;
  int get droppedPackets => buffer.droppedPackets;
  int get invalidPackets => buffer.invalidPackets;
  double get sampleRateHz => buffer.estimatedSampleRateHz;

  List<double> get waveformValues => buffer.displayValues;

  void _init() {
    _stateSub = _bleService.connectionState.listen((state) {
      final wasConnected = _connectionState == BleDeviceConnectionState.connected;
      _connectionState = state;
      if (state == BleDeviceConnectionState.connected && !wasConnected) {
        _startListening();
      } else if (state != BleDeviceConnectionState.connected && wasConnected) {
        _stopListening(clearData: false);
      }
      notifyListeners();
    });

    _errorSub = _bleService.errors.listen((err) {
      _errorMessage = err;
      notifyListeners();
    });

    // periodic tick to refresh "missing data"/quality indicators
    _tickTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (_connectionState == BleDeviceConnectionState.connected) {
        notifyListeners();
      }
    });
  }

  void _startListening() {
    _dataSub?.cancel();
    buffer.clear();
    _streamActive = true;
    _dataSub = _bleService.sensorData.listen(
      _handlePacket,
      onError: (e) {
        AppLogger.error('Sensor stream error', tag: 'MONITOR', error: e);
        _errorMessage = 'Sensor stream interrupted. Data may be incomplete.';
        notifyListeners();
      },
      onDone: () {
        if (_connectionState == BleDeviceConnectionState.connected) {
          AppLogger.warning('Sensor stream ended while connected', tag: 'MONITOR');
          _errorMessage = 'Sensor stream ended unexpectedly. Try reconnecting the device.';
          notifyListeners();
        }
      },
    );
  }

  void _stopListening({bool clearData = true}) {
    _streamActive = false;
    _dataSub?.cancel();
    _dataSub = null;
    if (clearData) buffer.clear();
  }

  void _handlePacket(Uint8List data) {
    final result = SensorPacketParser.parse(data);
    if (!result.isValid || result.packet == null) {
      buffer.recordInvalid();
    } else {
      buffer.addPacket(result.packet!);
    }

    // throttle UI updates to ~15 Hz
    final now = DateTime.now();
    if (_lastUiUpdate == null ||
        now.difference(_lastUiUpdate!) >= const Duration(milliseconds: 66)) {
      _lastUiUpdate = now;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearData() {
    buffer.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    _tickTimer?.cancel();
    _stopListening(clearData: false);
    _stateSub?.cancel();
    _errorSub?.cancel();
    super.dispose();
  }
}
