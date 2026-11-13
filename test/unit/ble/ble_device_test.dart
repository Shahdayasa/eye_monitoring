import 'package:flutter_test/flutter_test.dart';
import 'package:eye_monitoring/features/device/domain/ble_device.dart';

void main() {
  group('BleDevice', () {
    test('displayName falls back for empty name', () {
      const device = BleDevice(id: 'id1', name: '');
      expect(device.displayName, 'Unknown device');
    });

    test('displayName returns trimmed name', () {
      const device = BleDevice(id: 'id1', name: 'EOG Glasses');
      expect(device.displayName, 'EOG Glasses');
    });

    test('equality is based on id', () {
      const a = BleDevice(id: 'same', name: 'A', rssi: -40);
      const b = BleDevice(id: 'same', name: 'B', rssi: -50);
      const c = BleDevice(id: 'other', name: 'A', rssi: -40);
      expect(a, equals(b));
      expect(a == c, isFalse);
    });

    test('copyWith overrides fields', () {
      const device = BleDevice(id: 'id1', name: 'A', rssi: -40);
      final updated = device.copyWith(name: 'B', rssi: -55);
      expect(updated.id, 'id1');
      expect(updated.name, 'B');
      expect(updated.rssi, -55);
    });
  });
}
