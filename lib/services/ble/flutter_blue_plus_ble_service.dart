import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../features/device/domain/ble_device.dart';
import 'ble_service.dart';

/// Real BLE implementation backed by flutter_blue_plus.
///
/// Note: ESP32 service/characteristic UUIDs are TBD with the hardware team.
/// This service handles scanning, connection lifecycle, permissions, and error
/// states; characteristic discovery/subscription will be wired in Wave 4 once
/// UUIDs and data format are finalized.
class FlutterBluePlusBleService implements BleService {
  final _scanResultsController = StreamController<List<BleDevice>>.broadcast();
  final _connectionStateController =
      StreamController<BleDeviceConnectionState>.broadcast();
  final _errorsController = StreamController<String?>.broadcast();
  final _sensorDataController = StreamController<Uint8List>.broadcast();

  final Map<String, BleDevice> _discovered = {};
  BleDevice? _connectedDevice;
  BleDeviceConnectionState _state = BleDeviceConnectionState.disconnected;
  bool _isScanning = false;
  bool _disposed = false;

  // TODO(Wave 4+HW): set actual ESP32 service/characteristic UUIDs and enable
  // notify subscriptions to forward data into _sensorDataController.

  StreamSubscription<List<ScanResult>>? _scanSub;
  StreamSubscription<bool>? _isScanningSub;
  StreamSubscription<BluetoothConnectionState>? _deviceConnSub;
  BluetoothDevice? _nativeDevice;

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

  Future<bool> _ensurePermissions() async {
    if (Platform.isAndroid) {
      final statuses = await [
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
        Permission.locationWhenInUse,
      ].request();

      final granted = statuses.values.every((s) => s.isGranted || s.isLimited);
      if (!granted) {
        final permanentlyDenied =
            statuses.values.any((s) => s.isPermanentlyDenied);
        _emitState(BleDeviceConnectionState.error);
        _emitError(
          permanentlyDenied
              ? 'Bluetooth permissions permanently denied. Enable them in system settings.'
              : 'Bluetooth permissions are required to scan for devices.',
        );
        return false;
      }
    } else if (Platform.isIOS) {
      final status = await Permission.bluetooth.request();
      if (!status.isGranted && !status.isLimited) {
        _emitState(BleDeviceConnectionState.error);
        _emitError('Bluetooth permission is required to scan for devices.');
        return false;
      }
    }
    return true;
  }

  @override
  Future<void> startScan({Duration timeout = const Duration(seconds: 10)}) async {
    if (_disposed) throw const BleServiceException('BLE service disposed');
    if (_isScanning) return;

    final adapterState = await FlutterBluePlus.adapterState.first;
    if (adapterState != BluetoothAdapterState.on) {
      _emitState(BleDeviceConnectionState.error);
      _emitError('Bluetooth is turned off. Please enable Bluetooth and try again.');
      throw const BleServiceException('Bluetooth off', code: 'bluetooth_off');
    }

    final ok = await _ensurePermissions();
    if (!ok) {
      throw const BleServiceException(
        'Permissions denied',
        code: 'permission_denied',
      );
    }

    _discovered.clear();
    _emitResults();
    _isScanning = true;
    _emitState(BleDeviceConnectionState.scanning);
    _emitError(null);

    await _scanSub?.cancel();
    _scanSub = FlutterBluePlus.scanResults.listen((results) {
      for (final result in results) {
        final device = result.device;
        final name = device.platformName.isNotEmpty
            ? device.platformName
            : (result.advertisementData.advName.isNotEmpty
                ? result.advertisementData.advName
                : 'Unknown device');
        _discovered[device.remoteId.str] = BleDevice(
          id: device.remoteId.str,
          name: name,
          rssi: result.rssi,
        );
      }
      _emitResults();
    });

    await _isScanningSub?.cancel();
    _isScanningSub = FlutterBluePlus.isScanning.listen((scanning) {
      _isScanning = scanning;
      if (!scanning && _state == BleDeviceConnectionState.scanning) {
        _emitState(
          _connectedDevice != null
              ? BleDeviceConnectionState.connected
              : BleDeviceConnectionState.disconnected,
        );
      }
    });

    try {
      await FlutterBluePlus.startScan(timeout: timeout);
    } catch (e) {
      _isScanning = false;
      _emitState(BleDeviceConnectionState.error);
      _emitError('Failed to start scan: $e');
      rethrow;
    }
  }

  @override
  Future<void> stopScan() async {
    try {
      await FlutterBluePlus.stopScan();
    } catch (_) {
      // ignore if not scanning
    }
    _isScanning = false;
    await _scanSub?.cancel();
    _scanSub = null;
    await _isScanningSub?.cancel();
    _isScanningSub = null;
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

    await stopScan();
    _emitError(null);
    _emitState(BleDeviceConnectionState.connecting);

    try {
      final device = BluetoothDevice.fromId(deviceId);
      _nativeDevice = device;

      await _deviceConnSub?.cancel();
      _deviceConnSub = device.connectionState.listen((state) {
        switch (state) {
          case BluetoothConnectionState.connected:
            _connectedDevice = _discovered[deviceId] ??
                BleDevice(id: deviceId, name: device.platformName);
            _emitState(BleDeviceConnectionState.connected);
            break;
          case BluetoothConnectionState.disconnected:
            if (_state == BleDeviceConnectionState.connecting) {
              _emitState(BleDeviceConnectionState.error);
              _emitError('Failed to connect to device.');
            } else if (_state == BleDeviceConnectionState.connected ||
                _state == BleDeviceConnectionState.disconnecting) {
              _connectedDevice = null;
              _nativeDevice = null;
              _emitState(BleDeviceConnectionState.disconnected);
            }
            break;
          default:
            break;
        }
      });

      await device.connect(
        timeout: const Duration(seconds: 30),
      );
    } on FlutterBluePlusException catch (e) {
      _emitState(BleDeviceConnectionState.error);
      _emitError(_mapFbpError(e));
      throw BleServiceException(_mapFbpError(e), code: e.code.toString());
    } catch (e) {
      _emitState(BleDeviceConnectionState.error);
      _emitError('Connection failed: $e');
      rethrow;
    }
  }

  String _mapFbpError(FlutterBluePlusException e) {
    final desc = e.description ?? e.toString();
    if (desc.toLowerCase().contains('timeout')) {
      return 'Connection timed out. Ensure the device is powered on and in range.';
    }
    if (desc.toLowerCase().contains('not found')) {
      return 'Device not found. Try scanning again.';
    }
    return 'Bluetooth error: $desc';
  }

  @override
  Future<void> disconnect() async {
    if (_disposed) return;
    final device = _nativeDevice;
    if (device == null) {
      _connectedDevice = null;
      _emitState(BleDeviceConnectionState.disconnected);
      return;
    }
    _emitState(BleDeviceConnectionState.disconnecting);
    try {
      await device.disconnect();
    } catch (_) {
      // best effort
    }
    _connectedDevice = null;
    _nativeDevice = null;
    await _deviceConnSub?.cancel();
    _deviceConnSub = null;
    _emitState(BleDeviceConnectionState.disconnected);
  }

  @override
  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    await stopScan();
    await _deviceConnSub?.cancel();
    await _scanResultsController.close();
    await _connectionStateController.close();
    await _errorsController.close();
    await _sensorDataController.close();
  }
}
