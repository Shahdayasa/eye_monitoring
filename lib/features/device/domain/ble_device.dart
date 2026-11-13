enum BleDeviceConnectionState {
  disconnected,
  scanning,
  connecting,
  connected,
  disconnecting,
  error,
}

class BleDevice {
  final String id;
  final String name;
  final int? rssi;

  const BleDevice({
    required this.id,
    required this.name,
    this.rssi,
  });

  BleDevice copyWith({
    String? id,
    String? name,
    int? rssi,
  }) {
    return BleDevice(
      id: id ?? this.id,
      name: name ?? this.name,
      rssi: rssi ?? this.rssi,
    );
  }

  String get displayName => name.trim().isEmpty ? 'Unknown device' : name;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BleDevice && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'BleDevice(id: $id, name: $name, rssi: $rssi)';
}
