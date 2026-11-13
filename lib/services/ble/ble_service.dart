import 'dart:async';
import 'dart:typed_data';

import '../../features/device/domain/ble_device.dart';

abstract class BleService {
  Stream<List<BleDevice>> get scanResults;
  Stream<BleDeviceConnectionState> get connectionState;
  Stream<String?> get errors;

  /// Raw sensor payload stream (EOG/light packets) from connected device.
  /// Empty stream if the implementation does not support data streaming.
  Stream<Uint8List> get sensorData;

  BleDevice? get connectedDevice;
  bool get isScanning;

  Future<void> startScan({Duration timeout = const Duration(seconds: 10)});
  Future<void> stopScan();
  Future<void> connect(String deviceId);
  Future<void> disconnect();
  Future<void> dispose();
}

class BleServiceException implements Exception {
  final String message;
  final String? code;

  const BleServiceException(this.message, {this.code});

  @override
  String toString() => 'BleServiceException($code): $message';
}
