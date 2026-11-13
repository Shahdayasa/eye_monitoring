import 'package:flutter_test/flutter_test.dart';
import 'package:eye_monitoring/features/monitoring/data/signal_buffer.dart';
import 'package:eye_monitoring/features/monitoring/domain/signal_model.dart';
import 'package:eye_monitoring/features/predictions/data/prediction_repository.dart';

void main() {
  group('PredictionRepository.buildWindowFromBuffer', () {
    late PredictionRepository repo;

    setUp(() {
      repo = PredictionRepository();
    });

    tearDown(() {
      repo.dispose();
    });

    SensorPacket packet(int seq, DateTime t, {double lux = 100}) {
      return SensorPacket(
        eogSample: EogSample(
          timestamp: t,
          normalizedValue: 0.5,
          rawAdc: 2048,
          sequenceNumber: seq,
        ),
        lightReading: LightReading(timestamp: t, lux: lux),
      );
    }

    test('returns null when buffer has insufficient samples', () {
      final buffer = SignalBuffer(sampleRateHz: 128, windowSeconds: 10);
      final now = DateTime.now();
      for (var i = 0; i < 100; i++) {
        buffer.addPacket(packet(i, now.add(Duration(milliseconds: i * 8))));
      }
      expect(repo.buildWindowFromBuffer(buffer), isNull);
    });

    test('builds correctly sized window from tail of buffer', () {
      final buffer = SignalBuffer(sampleRateHz: 128, windowSeconds: 10);
      final start = DateTime.utc(2026, 11, 13, 10, 0, 0);
      final expected = 128 * 10;
      for (var i = 0; i < expected + 50; i++) {
        buffer.addPacket(packet(i, start.add(Duration(milliseconds: i * 8)), lux: 250));
      }

      final window = repo.buildWindowFromBuffer(buffer);
      expect(window, isNotNull);
      expect(window!.samples.length, expected);
      expect(window.sampleRateHz, 128);
      expect(window.windowDurationSeconds, closeTo(10.0, 1e-6));
      expect(window.windowStart, buffer.samples[buffer.samples.length - expected].timestamp);
      expect(window.ambientLightLux, 250);
    });
  });
}
