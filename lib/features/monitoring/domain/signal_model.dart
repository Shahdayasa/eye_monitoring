import 'dart:typed_data';

enum SignalQualityStatus { excellent, good, poor, unusable }

class EogSample {
  final DateTime timestamp;
  final double normalizedValue;
  final int rawAdc;
  final int sequenceNumber;

  const EogSample({
    required this.timestamp,
    required this.normalizedValue,
    required this.rawAdc,
    required this.sequenceNumber,
  });
}

class LightReading {
  final DateTime timestamp;
  final double lux;

  const LightReading({required this.timestamp, required this.lux});
}

class SensorPacket {
  final EogSample eogSample;
  final LightReading? lightReading;
  final int? batteryPercent;
  final bool isValid;

  const SensorPacket({
    required this.eogSample,
    this.lightReading,
    this.batteryPercent,
    this.isValid = true,
  });
}

class ParsedPacketResult {
  final SensorPacket? packet;
  final bool isValid;
  final String? error;

  const ParsedPacketResult._({this.packet, required this.isValid, this.error});

  const ParsedPacketResult.valid(SensorPacket packet)
      : this._(packet: packet, isValid: true);

  const ParsedPacketResult.invalid(String error)
      : this._(isValid: false, error: error);
}

/// Parses incoming BLE payloads from ESP32.
///
/// Supported formats (coordinated/flexible):
/// 1) Binary EOG packet (9+ bytes, little-endian):
///    [u32 timestamp_ms][i16 adc][u16 seq][u8 battery?][f32 lux?]
/// 2) CSV/text: "timestampMs,adc[,seq][,lux][,battery]"
/// 3) Key-value: "ts=1,adc=2048,seq=2,lux=120.5,bat=90"
class SensorPacketParser {
  static const int adcMax = 4095;

  static ParsedPacketResult parse(Uint8List data, {DateTime? receivedAt}) {
    if (data.isEmpty) {
      return const ParsedPacketResult.invalid('Empty packet');
    }

    // Heuristic: binary packet if contains non-printables and length >= 8.
    final isLikelyText = data.every((b) => b == 9 || b == 10 || b == 13 || (b >= 32 && b <= 126));
    if (isLikelyText) {
      final text = String.fromCharCodes(data).trim();
      return _parseText(text, receivedAt: receivedAt);
    }
    if (data.length >= 8) {
      return _parseBinary(data, receivedAt: receivedAt);
    }
    return const ParsedPacketResult.invalid('Unsupported packet format');
  }

  static ParsedPacketResult parseString(String text, {DateTime? receivedAt}) {
    if (text.trim().isEmpty) {
      return const ParsedPacketResult.invalid('Empty packet');
    }
    return _parseText(text.trim(), receivedAt: receivedAt);
  }

  static ParsedPacketResult _parseBinary(Uint8List data, {DateTime? receivedAt}) {
    try {
      final bd = ByteData.sublistView(data);
      final tsMs = bd.getUint32(0, Endian.little);
      final adc = bd.getInt16(4, Endian.little);
      final seq = bd.getUint16(6, Endian.little);

      int? battery;
      double? lux;
      var offset = 8;
      if (data.length >= offset + 1) {
        battery = bd.getUint8(offset);
        offset += 1;
      }
      if (data.length >= offset + 4) {
        lux = bd.getFloat32(offset, Endian.little);
      }

      return _buildResult(
        timestampMs: tsMs,
        adc: adc,
        seq: seq,
        lux: lux,
        battery: battery,
        receivedAt: receivedAt,
      );
    } catch (_) {
      return const ParsedPacketResult.invalid('Malformed binary packet');
    }
  }

  static ParsedPacketResult _parseText(String text, {DateTime? receivedAt}) {
    // key=value form
    if (text.contains('=')) {
      final map = <String, String>{};
      for (final part in text.split(RegExp(r'[;,\\s]+'))) {
        if (part.trim().isEmpty) continue;
        final kv = part.split('=');
        if (kv.length != 2) continue;
        map[kv[0].trim().toLowerCase()] = kv[1].trim();
      }
      final ts = _toInt(map['ts'] ?? map['timestamp'] ?? map['time_ms'] ?? map['t']);
      final adc = _toInt(map['adc'] ?? map['eog'] ?? map['value']);
      final seq = _toInt(map['seq'] ?? map['sequence'] ?? map['n']) ?? 0;
      final lux = _toDouble(map['lux'] ?? map['light']);
      final battery = _toInt(map['bat'] ?? map['battery']);
      if (adc == null) {
        return const ParsedPacketResult.invalid('Missing ADC/EOG value');
      }
      return _buildResult(
        timestampMs: ts,
        adc: adc,
        seq: seq,
        lux: lux,
        battery: battery,
        receivedAt: receivedAt,
      );
    }

    // CSV form
    final parts = text.split(RegExp(r'[;,\\s]+')).where((p) => p.isNotEmpty).toList();
    if (parts.length < 2) {
      return const ParsedPacketResult.invalid('Incomplete packet');
    }
    final ts = _toInt(parts[0]);
    final adc = _toInt(parts[1]);
    final seq = parts.length > 2 ? (_toInt(parts[2]) ?? 0) : 0;
    final lux = parts.length > 3 ? _toDouble(parts[3]) : null;
    final battery = parts.length > 4 ? _toInt(parts[4]) : null;
    if (adc == null) {
      return const ParsedPacketResult.invalid('Invalid ADC/EOG value');
    }
    return _buildResult(
      timestampMs: ts,
      adc: adc,
      seq: seq,
      lux: lux,
      battery: battery,
      receivedAt: receivedAt,
    );
  }

  static ParsedPacketResult _buildResult({
    int? timestampMs,
    required int adc,
    required int seq,
    double? lux,
    int? battery,
    DateTime? receivedAt,
  }) {
    if (adc.isNaN) {
      return const ParsedPacketResult.invalid('Invalid sample value');
    }
    // Accept 12-bit range; clamp defensively but flag extreme outliers.
    if (adc < -2048 || adc > 8191) {
      return ParsedPacketResult.invalid('ADC out of range ($adc)');
    }
    if (battery != null && (battery < 0 || battery > 100)) {
      battery = battery.clamp(0, 100);
    }
    if (lux != null && (lux.isNaN || lux.isInfinite || lux < 0)) {
      lux = null;
    }

    final now = receivedAt ?? DateTime.now();
    final timestamp = timestampMs != null && timestampMs > 0
        ? DateTime.fromMillisecondsSinceEpoch(timestampMs, isUtc: true).toLocal()
        : now;

    final clampedAdc = adc.clamp(0, adcMax);
    final normalized = clampedAdc / adcMax;

    final sample = EogSample(
      timestamp: timestamp,
      normalizedValue: normalized.toDouble(),
      rawAdc: clampedAdc,
      sequenceNumber: seq < 0 ? 0 : seq,
    );
    final light = lux != null ? LightReading(timestamp: timestamp, lux: lux) : null;

    return ParsedPacketResult.valid(
      SensorPacket(
        eogSample: sample,
        lightReading: light,
        batteryPercent: battery,
      ),
    );
  }

  static int? _toInt(String? s) => s == null ? null : int.tryParse(s.trim());
  static double? _toDouble(String? s) => s == null ? null : double.tryParse(s.trim());
}

SignalQualityStatus assessSignalQuality(List<EogSample> samples, {int droppedPackets = 0}) {
  if (samples.length < 10) return SignalQualityStatus.unusable;
  final values = samples.map((s) => s.normalizedValue).toList();
  final mean = values.reduce((a, b) => a + b) / values.length;
  var variance = 0.0;
  for (final v in values) {
    final d = v - mean;
    variance += d * d;
  }
  variance /= values.length;
  final std = variance <= 0 ? 0.0 : _sqrt(variance);

  // crude noise/artifact heuristics on normalized 0..1 signal
  if (std < 0.002 || std > 0.35) return SignalQualityStatus.unusable;
  if (droppedPackets > 10 || std > 0.20) return SignalQualityStatus.poor;
  if (droppedPackets > 2 || std > 0.12) return SignalQualityStatus.good;
  return SignalQualityStatus.excellent;
}

double _sqrt(double x) {
  // dart:math avoided to keep model simple in test env? use num sqrt via dart:math in callers not needed; implement quick newton
  if (x <= 0) return 0;
  double r = x;
  for (var i = 0; i < 10; i++) {
    r = 0.5 * (r + x / r);
  }
  return r;
}
