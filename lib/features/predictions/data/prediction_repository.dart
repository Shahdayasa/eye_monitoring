import '../../../core/config/app_config.dart';
import '../../../features/monitoring/data/signal_buffer.dart';
import '../../../models/prediction.dart';
import '../../../services/ai_api/api_client.dart';

class SignalWindow {
  final List<double> samples;
  final int sampleRateHz;
  final DateTime windowStart;
  final double windowDurationSeconds;
  final double? ambientLightLux;

  const SignalWindow({
    required this.samples,
    required this.sampleRateHz,
    required this.windowStart,
    required this.windowDurationSeconds,
    this.ambientLightLux,
  });
}

class PredictionRepository {
  PredictionRepository({AiApiClient? apiClient})
      : _apiClient = apiClient ?? AiApiClient();

  final AiApiClient _apiClient;

  /// Builds a contiguous window from the end of the signal buffer using the
  /// app/model contract (sample rate + duration). Returns null if insufficient.
  SignalWindow? buildWindowFromBuffer(SignalBuffer buffer) {
    if (buffer.samples.isEmpty) return null;

    final expectedSamples = (AppConfig.sampleRateHz * AppConfig.windowDurationSeconds)
        .round();
    if (expectedSamples <= 0) return null;
    if (buffer.samples.length < expectedSamples) return null;

    final windowSamples = buffer.samples.sublist(buffer.samples.length - expectedSamples);
    final values = windowSamples.map((s) => s.normalizedValue).toList(growable: false);
    final start = windowSamples.first.timestamp;
    final duration = windowSamples.length / AppConfig.sampleRateHz;
    final lux = buffer.latestLight?.lux;

    return SignalWindow(
      samples: values,
      sampleRateHz: AppConfig.sampleRateHz,
      windowStart: start,
      windowDurationSeconds: duration,
      ambientLightLux: lux,
    );
  }

  Future<PredictionResult> predictWindow(
    SignalWindow window, {
    String? authToken,
    String? deviceId,
  }) async {
    return _apiClient.predictFromWindow(
      samples: window.samples,
      sampleRateHz: window.sampleRateHz,
      windowStart: window.windowStart,
      windowDurationSeconds: window.windowDurationSeconds,
      deviceId: deviceId,
      ambientLightLux: window.ambientLightLux,
      authToken: authToken,
    );
  }

  void dispose() => _apiClient.dispose();
}
