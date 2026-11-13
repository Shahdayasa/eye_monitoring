import 'dart:collection';
import 'dart:math' as math;

import '../domain/signal_model.dart';

class SignalValidationResult {
  final bool isValid;
  final String? reason;

  const SignalValidationResult._(this.isValid, this.reason);
  const SignalValidationResult.valid() : this._(true, null);
  const SignalValidationResult.invalid(String reason) : this._(false, reason);
}

class SignalBuffer {
  final int sampleRateHz;
  final int windowSeconds;
  final int displaySamples;

  final List<EogSample> _samples = <EogSample>[];
  final Queue<double> _displayWindow = Queue<double>();
  LightReading? _latestLight;
  int? _latestBattery;
  DateTime? _lastSampleAt;
  int _droppedPackets = 0;
  int _invalidPackets = 0;
  int? _lastSequence;

  SignalBuffer({
    this.sampleRateHz = 128,
    this.windowSeconds = 10,
    this.displaySamples = 256,
  });

  UnmodifiableListView<EogSample> get samples => UnmodifiableListView(_samples);
  List<double> get displayValues => _displayWindow.toList(growable: false);
  LightReading? get latestLight => _latestLight;
  int? get latestBattery => _latestBattery;
  DateTime? get lastSampleAt => _lastSampleAt;
  int get droppedPackets => _droppedPackets;
  int get invalidPackets => _invalidPackets;
  bool get hasData => _samples.isNotEmpty;

  int get maxSamples => sampleRateHz * windowSeconds;

  SignalValidationResult validate(SensorPacket packet) {
    final s = packet.eogSample;
    if (s.normalizedValue.isNaN || s.normalizedValue.isInfinite) {
      return const SignalValidationResult.invalid('Non-finite sample');
    }
    if (s.normalizedValue < 0 || s.normalizedValue > 1) {
      return const SignalValidationResult.invalid('Sample out of normalized range');
    }
    if (packet.batteryPercent != null &&
        (packet.batteryPercent! < 0 || packet.batteryPercent! > 100)) {
      return const SignalValidationResult.invalid('Invalid battery level');
    }
    return const SignalValidationResult.valid();
  }

  bool addPacket(SensorPacket packet) {
    final validation = validate(packet);
    if (!validation.isValid) {
      _invalidPackets++;
      return false;
    }

    final seq = packet.eogSample.sequenceNumber;
    if (_lastSequence != null && seq > _lastSequence!) {
      final diff = seq - _lastSequence! - 1;
      if (diff > 0 && diff < 1000) {
        _droppedPackets += diff;
      }
    }
    _lastSequence = seq;

    _samples.add(packet.eogSample);
    if (_samples.length > maxSamples) {
      _samples.removeRange(0, _samples.length - maxSamples);
    }

    _displayWindow.add(packet.eogSample.normalizedValue);
    while (_displayWindow.length > displaySamples) {
      _displayWindow.removeFirst();
    }

    if (packet.lightReading != null) {
      _latestLight = packet.lightReading;
    }
    if (packet.batteryPercent != null) {
      _latestBattery = packet.batteryPercent;
    }
    _lastSampleAt = packet.eogSample.timestamp;
    return true;
  }

  void recordInvalid() {
    _invalidPackets++;
  }

  SignalQualityStatus qualityStatus() {
    if (_samples.isEmpty) return SignalQualityStatus.unusable;
    final recent = _samples.length > 128
        ? _samples.sublist(_samples.length - 128)
        : _samples;
    return assessSignalQuality(recent, droppedPackets: _droppedPackets);
  }

  bool get isReceiving {
    final last = _lastSampleAt;
    if (last == null) return false;
    return DateTime.now().difference(last) <= const Duration(seconds: 2);
  }

  bool get isMissingData {
    final last = _lastSampleAt;
    if (last == null) return false;
    return DateTime.now().difference(last) > const Duration(seconds: 2);
  }

  double get estimatedSampleRateHz {
    if (_samples.length < 2) return 0;
    final a = _samples[_samples.length - 1].timestamp;
    final b = _samples[math.max(0, _samples.length - 33)].timestamp;
    final n = _samples.length - math.max(0, _samples.length - 33) - 1;
    final dt = a.difference(b).inMicroseconds / 1e6;
    if (dt <= 0 || n <= 0) return 0;
    return n / dt;
  }

  void clear() {
    _samples.clear();
    _displayWindow.clear();
    _latestLight = null;
    _latestBattery = null;
    _lastSampleAt = null;
    _droppedPackets = 0;
    _invalidPackets = 0;
    _lastSequence = null;
  }
}
