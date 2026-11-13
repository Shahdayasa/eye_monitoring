import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/logging/app_logger.dart';
import '../../../services/ble/ble_service.dart';
import '../domain/ble_device.dart';

class BleProvider extends ChangeNotifier {
  final BleService _service;

  BleProvider(this._service) {
    _init();
  }

  List<BleDevice> _devices = [];
  BleDeviceConnectionState _connectionState =
      BleDeviceConnectionState.disconnected;
  String? _errorMessage;
  BleDevice? _connectedDevice;
  bool _isScanning = false;

  StreamSubscription<List<BleDevice>>? _devicesSub;
  StreamSubscription<BleDeviceConnectionState>? _stateSub;
  StreamSubscription<String?>? _errorSub;

  List<BleDevice> get devices => _devices;
  BleDeviceConnectionState get connectionState => _connectionState;
  String? get errorMessage => _errorMessage;
  BleDevice? get connectedDevice => _connectedDevice ?? _service.connectedDevice;
  bool get isScanning => _isScanning || _service.isScanning;

  bool get isConnected => _connectionState == BleDeviceConnectionState.connected;
  bool get isConnecting => _connectionState == BleDeviceConnectionState.connecting;
  bool get isBusy =>
      isScanning ||
      _connectionState == BleDeviceConnectionState.connecting ||
      _connectionState == BleDeviceConnectionState.disconnecting;

  void _init() {
    _devicesSub = _service.scanResults.listen((devices) {
      _devices = devices;
      notifyListeners();
    });
    _stateSub = _service.connectionState.listen((state) {
      _connectionState = state;
      _connectedDevice = _service.connectedDevice;
      if (state == BleDeviceConnectionState.scanning) {
        _isScanning = true;
      } else {
        _isScanning = _service.isScanning;
      }
      notifyListeners();
    });
    _errorSub = _service.errors.listen((error) {
      _errorMessage = error;
      notifyListeners();
    });
  }

  Future<void> startScan() async {
    _errorMessage = null;
    _isScanning = true;
    notifyListeners();
    try {
      await _service.startScan();
    } on BleServiceException catch (e) {
      _errorMessage = e.message;
      _isScanning = false;
      _connectionState = BleDeviceConnectionState.error;
      AppLogger.warning('BLE scan failed', tag: 'BLE', data: e.message);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to start scan. Check Bluetooth permissions and try again.';
      _isScanning = false;
      AppLogger.error('BLE scan unexpected error', tag: 'BLE', error: e);
      notifyListeners();
    }
  }

  Future<void> stopScan() async {
    await _service.stopScan();
    _isScanning = false;
    notifyListeners();
  }

  Future<bool> connect(BleDevice device) async {
    _errorMessage = null;
    notifyListeners();
    try {
      await _service.connect(device.id);
      _connectedDevice = _service.connectedDevice ?? device;
      notifyListeners();
      return _connectionState == BleDeviceConnectionState.connected;
    } on BleServiceException catch (e) {
      _errorMessage = e.message;
      AppLogger.warning('BLE connect failed', tag: 'BLE', data: {'device': device.id, 'error': e.message});
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Failed to connect to device. Ensure it is powered on and in range.';
      AppLogger.error('BLE connect unexpected error', tag: 'BLE', error: e);
      notifyListeners();
      return false;
    }
  }

  Future<void> disconnect() async {
    _errorMessage = null;
    notifyListeners();
    try {
      await _service.disconnect();
      _connectedDevice = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to disconnect cleanly. You can try again.';
      AppLogger.error('BLE disconnect error', tag: 'BLE', error: e);
      notifyListeners();
    }
  }

  Future<void> reconnect() async {
    final device = _connectedDevice;
    if (device == null) {
      _errorMessage = 'No device to reconnect to. Please scan and select a device.';
      notifyListeners();
      return;
    }
    AppLogger.info('Reconnecting to BLE device', tag: 'BLE', data: device.id);
    await connect(device);
  }

  void clearError() {
    _errorMessage = null;
    if (_connectionState == BleDeviceConnectionState.error && !isConnected) {
      _connectionState = BleDeviceConnectionState.disconnected;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _devicesSub?.cancel();
    _stateSub?.cancel();
    _errorSub?.cancel();
    _service.dispose();
    super.dispose();
  }
}
