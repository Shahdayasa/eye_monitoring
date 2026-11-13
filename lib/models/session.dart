import 'package:cloud_firestore/cloud_firestore.dart';

enum SessionStatus { active, completed, interrupted }

extension SessionStatusX on SessionStatus {
  String get value => name;

  static SessionStatus fromValue(String? value) {
    switch (value) {
      case 'completed':
        return SessionStatus.completed;
      case 'interrupted':
        return SessionStatus.interrupted;
      case 'active':
      default:
        return SessionStatus.active;
    }
  }
}

class MonitoringSession {
  final String id;
  final String deviceId;
  final DateTime startedAt;
  final DateTime? endedAt;
  final int durationSeconds;
  final SessionStatus status;
  final int predictionCount;

  const MonitoringSession({
    required this.id,
    required this.deviceId,
    required this.startedAt,
    this.endedAt,
    required this.durationSeconds,
    required this.status,
    this.predictionCount = 0,
  });

  bool get isActive => status == SessionStatus.active;

  MonitoringSession copyWith({
    String? id,
    String? deviceId,
    DateTime? startedAt,
    DateTime? endedAt,
    int? durationSeconds,
    SessionStatus? status,
    int? predictionCount,
  }) {
    return MonitoringSession(
      id: id ?? this.id,
      deviceId: deviceId ?? this.deviceId,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      status: status ?? this.status,
      predictionCount: predictionCount ?? this.predictionCount,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'deviceId': deviceId,
      'startedAt': Timestamp.fromDate(startedAt),
      'endedAt': endedAt != null ? Timestamp.fromDate(endedAt!) : null,
      'duration': durationSeconds,
      'status': status.value,
      'predictionCount': predictionCount,
    };
  }

  factory MonitoringSession.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? const <String, dynamic>{};
    final started = data['startedAt'];
    final ended = data['endedAt'];
    return MonitoringSession(
      id: doc.id,
      deviceId: data['deviceId'] as String? ?? 'unknown',
      startedAt: started is Timestamp ? started.toDate() : DateTime.now(),
      endedAt: ended is Timestamp ? ended.toDate() : null,
      durationSeconds: (data['duration'] as num?)?.toInt() ?? 0,
      status: SessionStatusX.fromValue(data['status'] as String?),
      predictionCount: (data['predictionCount'] as num?)?.toInt() ?? 0,
    );
  }

  factory MonitoringSession.fromMap(String id, Map<String, dynamic> data) {
    final started = data['startedAt'];
    final ended = data['endedAt'];
    DateTime parseDate(dynamic v) {
      if (v is Timestamp) return v.toDate();
      if (v is DateTime) return v;
      if (v is String) return DateTime.tryParse(v) ?? DateTime.now();
      return DateTime.now();
    }

    return MonitoringSession(
      id: id,
      deviceId: data['deviceId'] as String? ?? 'unknown',
      startedAt: parseDate(started),
      endedAt: ended == null ? null : parseDate(ended),
      durationSeconds: (data['duration'] as num?)?.toInt() ?? 0,
      status: SessionStatusX.fromValue(data['status'] as String?),
      predictionCount: (data['predictionCount'] as num?)?.toInt() ?? 0,
    );
  }
}
