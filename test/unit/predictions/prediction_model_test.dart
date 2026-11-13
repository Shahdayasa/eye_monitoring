import 'package:flutter_test/flutter_test.dart';
import 'package:eye_monitoring/models/prediction.dart';

void main() {
  group('PredictionResult', () {
    test('parses API json and metadata', () {
      final res = PredictionResult.fromApiJson(
        {
          'prediction': 'fatigued',
          'probabilities': {'fatigued': 0.82, 'alert': 0.18},
          'model_version': 'v1.2.0',
          'message': 'ok',
          'quality_status': 'good',
          'features': {'rms': 0.12},
        },
        windowStart: DateTime.utc(2026, 11, 13, 12, 0, 0),
        windowDurationSeconds: 10.0,
      );

      expect(res.prediction, 'fatigued');
      expect(res.modelVersion, 'v1.2.0');
      expect(res.qualityStatus, 'good');
      expect(res.probabilities['fatigued'], closeTo(0.82, 1e-9));
      expect(res.features['rms'], 0.12);
      expect(res.windowDurationSeconds, 10.0);
      expect(res.isInsufficient, isFalse);
    });

    test('handles missing/partial fields safely', () {
      final res = PredictionResult.fromApiJson(
        const {},
        windowStart: DateTime.utc(2026, 1, 1),
        windowDurationSeconds: 5.0,
      );
      expect(res.prediction, 'unknown');
      expect(res.modelVersion, 'unknown');
      expect(res.message, '');
      expect(res.probabilities, isEmpty);
      expect(res.features, isEmpty);
    });

    test('detects insufficient evidence', () {
      final res = PredictionResult.fromApiJson(
        {'prediction': 'insufficient_evidence'},
        windowStart: DateTime.utc(2026, 1, 1),
        windowDurationSeconds: 10,
      );
      expect(res.isInsufficient, isTrue);
    });
  });

  group('PredictionApiException', () {
    test('classifies timeout/network/unauthorized', () {
      expect(const PredictionApiException('t', code: 'timeout').isTimeout, isTrue);
      expect(const PredictionApiException('n', code: 'network').isNetwork, isTrue);
      expect(const PredictionApiException('u', statusCode: 401).isUnauthorized, isTrue);
    });
  });
}
