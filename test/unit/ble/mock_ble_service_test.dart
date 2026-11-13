import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:eye_monitoring/features/device/domain/ble_device.dart';
import 'package:eye_monitoring/services/ble/mock_ble_service.dart';

void main() {
  group('MockBleService', () {
    late MockBleService service;

    setUp(() {
      service = MockBleService();
    });

    tearDown(() async {
      await service.dispose();
    });

    test('startScan emits discovered devices', () async {
      final completer = Completer<List<BleDevice>>();
      service.scanResults.listen((devices) {
        if (devices.isNotEmpty && !completer.isCompleted) {
          completer.complete(devices);
        }
      });

      await service.startScan(timeout: const Duration(seconds: 2));
      final devices = await completer.future.timeout(const Duration(seconds: 3));
      expect(devices, isNotEmpty);
      expect(devices.first.id, isNotEmpty);
    });

    test('connect sets connected state for a known mock device', () async {
      final connected = Completer<void>();
      final states = <BleDeviceConnectionState>[];
      service.connectionState.listen((state) {
        states.add(state);
        if (state == BleDeviceConnectionState.connected &&
            !connected.isCompleted) {
          connected.complete();
        }
      });

      await service.connect('ESP32-EOG-001');
      await connected.future.timeout(const Duration(seconds: 3));

      expect(service.connectedDevice, isNotNull);
      expect(service.connectedDevice!.id, 'ESP32-EOG-001');
      expect(states, contains(BleDeviceConnectionState.connecting));
      expect(states.last, BleDeviceConnectionState.connected);
    });

    test('disconnect clears connected device', () async {
      final connected = Completer<void>();
      service.connectionState.listen((state) {
        if (state == BleDeviceConnectionState.connected &&
            !connected.isCompleted) {
          connected.complete();
        }
      });

      await service.connect('ESP32-EOG-001');
      await connected.future.timeout(const Duration(seconds: 3));
      await service.disconnect();

      expect(service.connectedDevice, isNull);
    });
  });
}
