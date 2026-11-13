import 'package:cloud_firestore/cloud_firestore.dart';

class PredictionResult {
  final String? id;
  final String prediction;
  final Map<String, double> probabilities;
  final String modelVersion;
  final String message;
  final String qualityStatus;
  final Map<String, dynamic> features;
  final DateTime windowStart;
  final double windowDurationSeconds;
  final DateTime createdAt;

  const PredictionResult({
    this.id,
    required this.prediction,
    required this.probabilities,
    required this.modelVersion,
    required this.message,
    required this.qualityStatus,
    required this.features,
    required this.windowStart,
    required this.windowDurationSeconds,
    required this.createdAt,
  });

  factory PredictionResult.fromApiJson(
    Map<String, dynamic> json, {
    required DateTime windowStart,
    required double windowDurationSeconds,
  }) {
    final rawProbs = json['probabilities'];
    final probs = <String, double>{};
    if (rawProbs is Map) {
      for (final entry in rawProbs.entries) {
        final v = entry.value;
        if (v is num) probs[entry.key.toString()] = v.toDouble();
      }
    }
    final rawFeatures = json['features'];
    return PredictionResult(
      prediction: (json['prediction'] as String?) ?? 'unknown',
      probabilities: probs,
      modelVersion: (json['model_version'] as String?) ?? 'unknown',
      message: (json['message'] as String?) ?? '',
      qualityStatus: (json['quality_status'] as String?) ?? 'unknown',
      features: rawFeatures is Map<String, dynamic>
          ? rawFeatures
          : rawFeatures is Map
              ? rawFeatures.map((k, v) => MapEntry(k.toString(), v))
              : const <String, dynamic>{},
      windowStart: windowStart,
      windowDurationSeconds: windowDurationSeconds,
      createdAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'prediction': prediction,
      'probabilities': probabilities,
      'modelVersion': modelVersion,
      'message': message,
      'qualityStatus': qualityStatus,
      'features': features,
      'windowStart': Timestamp.fromDate(windowStart),
      'windowDurationSeconds': windowDurationSeconds,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory PredictionResult.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    return PredictionResult.fromMap(doc.id, doc.data() ?? const <String, dynamic>{});
  }

  factory PredictionResult.fromMap(String id, Map<String, dynamic> data) {
    DateTime parseDate(dynamic v) {
      if (v is Timestamp) return v.toDate();
      if (v is DateTime) return v;
      if (v is String) return DateTime.tryParse(v) ?? DateTime.now();
      return DateTime.now();
    }

    final rawProbs = data['probabilities'];
    final probs = <String, double>{};
    if (rawProbs is Map) {
      for (final entry in rawProbs.entries) {
        final v = entry.value;
        if (v is num) probs[entry.key.toString()] = v.toDouble();
      }
    }
    final rawFeatures = data['features'];
    return PredictionResult(
      id: id,
      prediction: (data['prediction'] as String?) ?? 'unknown',
      probabilities: probs,
      modelVersion: (data['modelVersion'] as String?) ?? 'unknown',
      message: (data['message'] as String?) ?? '',
      qualityStatus: (data['qualityStatus'] as String?) ?? 'unknown',
      features: rawFeatures is Map<String, dynamic>
          ? rawFeatures
          : rawFeatures is Map
              ? rawFeatures.map((k, v) => MapEntry(k.toString(), v))
              : const <String, dynamic>{},
      windowStart: parseDate(data['windowStart']),
      windowDurationSeconds:
          (data['windowDurationSeconds'] as num?)?.toDouble() ?? 0.0,
      createdAt: parseDate(data['createdAt']),
    );
  }

  PredictionResult copyWith({String? id}) {
    return PredictionResult(
      id: id ?? this.id,
      prediction: prediction,
      probabilities: probabilities,
      modelVersion: modelVersion,
      message: message,
      qualityStatus: qualityStatus,
      features: features,
      windowStart: windowStart,
      windowDurationSeconds: windowDurationSeconds,
      createdAt: createdAt,
    );
  }

  bool get isInsufficient => prediction == 'insufficient_evidence';

  double get confidence {
    if (probabilities.isEmpty) return 0.0;
    return probabilities.values.reduce((a, b) => a > b ? a : b);
  }
}

class PredictionApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? code;

  const PredictionApiException(this.message, {this.statusCode, this.code});

  bool get isNetwork => statusCode == null && code == 'network';
  bool get isTimeout => code == 'timeout';
  bool get isUnauthorized => statusCode == 401;

  @override
  String toString() => 'PredictionApiException($statusCode, $code): $message';
}
