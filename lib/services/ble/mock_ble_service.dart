import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';

import '../../features/device/domain/ble_device.dart';
import 'ble_service.dart';

/// Mock BLE service for development and environments without hardware.
///
/// Simulates discovery of ESP32/EOG devices, connection lifecycle, and common
/// error cases so Wave 3 UI and state management can be exercised without a
/// physical device.
class MockBleService implements BleService {
  final _scanResultsController = StreamController<List<BleDevice>>.broadcast();
  final _connectionStateController =
      StreamController<BleDeviceConnectionState>.broadcast();
  final _errorsController = StreamController<String?>.broadcast();
  final _sensorDataController = StreamController<Uint8List>.broadcast();

  final Map<String, BleDevice> _discovered = {};
  BleDevice? _connectedDevice;
  BleDeviceConnectionState _state = BleDeviceConnectionState.disconnected;
  bool _isScanning = false;
  Timer? _scanTimer;
  Timer? _scanStopTimer;
  Timer? _dataTimer;
  bool _disposed = false;
  int _mockSeq = 0;
  final math.Random _rng = math.Random(42);

  static const List<BleDevice> _mockDevices = [
    BleDevice(id: 'ESP32-EOG-001', name: 'EOG Glasses A1', rssi: -48),
    BleDevice(id: 'ESP32-EOG-002', name: 'EOG Glasses B2', rssi: -63),
    BleDevice(id: 'ESP32-EOG-003', name: 'ESP32 Prototype', rssi: -71),
  ];

  @override
  Stream<List<BleDevice>> get scanResults => _scanResultsController.stream;

  @override
  Stream<BleDeviceConnectionState> get connectionState =>
      _connectionStateController.stream;

  @override
  Stream<String?> get errors => _errorsController.stream;

  @override
  Stream<Uint8List> get sensorData => _sensorDataController.stream;

  @override
  BleDevice? get connectedDevice => _connectedDevice;

  @override
  bool get isScanning => _isScanning;

  void _emitState(BleDeviceConnectionState state) {
    _state = state;
    if (!_connectionStateController.isClosed) {
      _connectionStateController.add(state);
    }
  }

  void _emitError(String? message) {
    if (!_errorsController.isClosed) {
      _errorsController.add(message);
    }
  }

  void _emitResults() {
    if (!_scanResultsController.isClosed) {
      _scanResultsController.add(_discovered.values.toList());
    }
  }

  @override
  Future<void> startScan({Duration timeout = const Duration(seconds: 10)}) async {
    if (_disposed) throw const BleServiceException('BLE service disposed');
    if (_isScanning) return;

    _discovered.clear();
    _emitResults();
    _isScanning = true;
    _emitState(BleDeviceConnectionState.scanning);
    _emitError(null);

    var index = 0;
    _scanTimer = Timer.periodic(const Duration(milliseconds: 700), (timer) {
      if (_disposed || !_isScanning) {
        timer.cancel();
        return;
      }
      if (index < _mockDevices.length) {
        final device = _mockDevices[index];
        _discovered[device.id] = device;
        _emitResults();
        index++;
      } else {
        timer.cancel();
      }
    });

    _scanStopTimer = Timer(timeout, () {
      if (_isScanning) {
        stopScan();
      }
    });
  }

  @override
  Future<void> stopScan() async {
    _scanTimer?.cancel();
    _scanTimer = null;
    _scanStopTimer?.cancel();
    _scanStopTimer = null;
    _isScanning = false;
    if (_state == BleDeviceConnectionState.scanning) {
      _emitState(
        _connectedDevice != null
            ? BleDeviceConnectionState.connected
            : BleDeviceConnectionState.disconnected,
      );
    }
  }

  @override
  Future<void> connect(String deviceId) async {
    if (_disposed) throw const BleServiceException('BLE service disposed');

    final device = _discovered[deviceId] ??
        _mockDevices.where((d) => d.id == deviceId).firstOrNull;
    if (device == null) {
      _emitState(BleDeviceConnectionState.error);
      _emitError('Device not found. Try scanning again.');
      throw const BleServiceException('Device not found', code: 'not_found');
    }

    await stopScan();
    _emitError(null);
    _emitState(BleDeviceConnectionState.connecting);

    await Future<void>.delayed(const Duration(milliseconds: 900));

    // Simulate a transient failure for a specific mock device id to exercise
    // error handling without affecting the primary demo device.
    if (deviceId.endsWith('003')) {
      _emitState(BleDeviceConnectionState.error);
      _emitError('Connection timed out. Make sure the device is on and nearby.');
      throw const BleServiceException('Connection timeout', code: 'timeout');
    }

    _connectedDevice = device;
    _emitState(BleDeviceConnectionState.connected);
    _startMockDataStream();
  }

  void _startMockDataStream() {
    _dataTimer?.cancel();
    _mockSeq = 0;
    const interval = Duration(milliseconds: 1000 ~/ 32); // ~32 Hz for mock
    _dataTimer = Timer.periodic(interval, (timer) {
      if (_disposed || _connectedDevice == null) {
        timer.cancel();
        return;
      }
      final t = DateTime.now().millisecondsSinceEpoch / 1000.0;
      // synthetic EOG-like waveform: baseline + blink-like pulses + noise
      final base = 2048 +
          (300 * math.sin(2 * math.pi * 0.8 * t)).round() +
          (_rng.nextInt(80) - 40);
      final blink = (math.sin(2 * math.pi * 0.25 * t) > 0.92) ? 500 : 0;
      final adc = (base + blink).clamp(0, 4095);
      final lux = 80 + 20 * math.sin(2 * math.pi * 0.05 * t) + _rng.nextDouble() * 5;
      final packet = '$_mockSeq,$adc,${_mockSeq % 65536},${lux.toStringAsFixed(1)},87';
      _mockSeq++;
      if (!_sensorDataController.isClosed) {
        _sensorDataController.add(Uint8List.fromList(packet.codeUnits));
      }
    });
  }

  void _stopMockDataStream() {
    _dataTimer?.cancel();
    _dataTimer = null;
  }

  @override
  Future<void> disconnect() async {
    if (_disposed) return;
    if (_connectedDevice == null &&
        _state != BleDeviceConnectionState.connected &&
        _state != BleDeviceConnectionState.connecting) {
      _emitState(BleDeviceConnectionState.disconnected);
      return;
    }

    _emitState(BleDeviceConnectionState.disconnecting);
    _stopMockDataStream();
    await Future<void>.delayed(const Duration(milliseconds: 400));
    _connectedDevice = null;
    _emitState(BleDeviceConnectionState.disconnected);
  }

  @override
  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    _stopMockDataStream();
    await stopScan();
    await _scanResultsController.close();
    await _connectionStateController.close();
    await _errorsController.close();
    await _sensorDataController.close();
  }
}
