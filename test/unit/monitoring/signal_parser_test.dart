import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:eye_monitoring/features/monitoring/domain/signal_model.dart';

void main() {
  group('SensorPacketParser', () {
    test('parses valid csv packet', () {
      final result = SensorPacketParser.parseString('1000,2048,5,120.5,90');
      expect(result.isValid, isTrue);
      expect(result.packet, isNotNull);
      expect(result.packet!.eogSample.rawAdc, 2048);
      expect(result.packet!.eogSample.sequenceNumber, 5);
      expect(result.packet!.lightReading!.lux, closeTo(120.5, 0.001));
      expect(result.packet!.batteryPercent, 90);
      expect(result.packet!.eogSample.normalizedValue, closeTo(0.5, 0.01));
    });

    test('parses key-value packet', () {
      final result = SensorPacketParser.parseString('ts=100,adc=4095,seq=2,lux=55,bat=80');
      expect(result.isValid, isTrue);
      expect(result.packet!.eogSample.normalizedValue, closeTo(1.0, 0.001));
      expect(result.packet!.lightReading!.lux, 55);
    });

    test('rejects empty packet', () {
      final result = SensorPacketParser.parse(Uint8List(0));
      expect(result.isValid, isFalse);
      expect(result.error, isNotNull);
    });

    test('rejects invalid adc', () {
      final result = SensorPacketParser.parseString('1000,abc,1');
      expect(result.isValid, isFalse);
    });

    test('parses binary packet', () {
      final bd = ByteData(13);
      bd.setUint32(0, 1000, Endian.little);
      bd.setInt16(4, 1024, Endian.little);
      bd.setUint16(6, 7, Endian.little);
      bd.setUint8(8, 88);
      bd.setFloat32(9, 42.0, Endian.little);
      final result = SensorPacketParser.parse(bd.buffer.asUint8List());
      expect(result.isValid, isTrue);
      expect(result.packet!.eogSample.rawAdc, 1024);
      expect(result.packet!.eogSample.sequenceNumber, 7);
      expect(result.packet!.batteryPercent, 88);
      expect(result.packet!.lightReading!.lux, closeTo(42.0, 0.01));
    });
  });
}
