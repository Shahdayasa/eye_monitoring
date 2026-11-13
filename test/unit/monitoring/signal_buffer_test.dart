import 'package:flutter_test/flutter_test.dart';
import 'package:eye_monitoring/features/monitoring/data/signal_buffer.dart';
import 'package:eye_monitoring/features/monitoring/domain/signal_model.dart';

SensorPacket _packet({
  required int seq,
  double normalized = 0.5,
  double? lux,
  int? battery,
  DateTime? ts,
}) {
  return SensorPacket(
    eogSample: EogSample(
      timestamp: ts ?? DateTime.now(),
      normalizedValue: normalized,
      rawAdc: (normalized * 4095).round(),
      sequenceNumber: seq,
    ),
    lightReading: lux == null
        ? null
        : LightReading(timestamp: ts ?? DateTime.now(), lux: lux),
    batteryPercent: battery,
  );
}

void main() {
  group('SignalBuffer', () {
    test('adds valid packets and tracks latest readings', () {
      final buffer = SignalBuffer(sampleRateHz: 128, windowSeconds: 10, displaySamples: 5);
      expect(buffer.hasData, isFalse);

      buffer.addPacket(_packet(seq: 0, normalized: 0.4, lux: 100, battery: 90));
      buffer.addPacket(_packet(seq: 1, normalized: 0.6));

      expect(buffer.hasData, isTrue);
      expect(buffer.samples.length, 2);
      expect(buffer.latestLight!.lux, 100);
      expect(buffer.latestBattery, 90);
      expect(buffer.displayValues.length, 2);
    });

    test('validates out-of-range samples', () {
      final buffer = SignalBuffer();
      final bad = _packet(seq: 0, normalized: 1.5);
      final result = buffer.validate(bad);
      expect(result.isValid, isFalse);
      expect(buffer.addPacket(bad), isFalse);
      expect(buffer.invalidPackets, 1);
    });

    test('tracks dropped packets from sequence gaps', () {
      final buffer = SignalBuffer();
      buffer.addPacket(_packet(seq: 1));
      buffer.addPacket(_packet(seq: 5));
      expect(buffer.droppedPackets, 3);
    });

    test('maintains display window size', () {
      final buffer = SignalBuffer(displaySamples: 3);
      for (var i = 0; i < 10; i++) {
        buffer.addPacket(_packet(seq: i, normalized: i / 10));
      }
      expect(buffer.displayValues.length, 3);
    });

    test('clear resets state', () {
      final buffer = SignalBuffer();
      buffer.addPacket(_packet(seq: 0, lux: 50));
      buffer.clear();
      expect(buffer.hasData, isFalse);
      expect(buffer.latestLight, isNull);
      expect(buffer.droppedPackets, 0);
      expect(buffer.invalidPackets, 0);
    });

    test('reports missing data when stale', () {
      final buffer = SignalBuffer();
      buffer.addPacket(_packet(seq: 0, ts: DateTime.now().subtract(const Duration(seconds: 5))));
      expect(buffer.isMissingData, isTrue);
      expect(buffer.isReceiving, isFalse);
    });
  });
}
