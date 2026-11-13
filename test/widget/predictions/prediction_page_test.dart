import 'dart:async';
import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:eye_monitoring/features/authentication/data/auth_repository.dart';
import 'package:eye_monitoring/features/authentication/presentation/auth_provider.dart';
import 'package:eye_monitoring/features/device/domain/ble_device.dart';
import 'package:eye_monitoring/features/device/presentation/ble_provider.dart';
import 'package:eye_monitoring/features/monitoring/presentation/monitoring_provider.dart';
import 'package:eye_monitoring/features/history/data/session_repository.dart';
import 'package:eye_monitoring/features/history/presentation/session_provider.dart';
import 'package:eye_monitoring/features/predictions/data/prediction_repository.dart';
import 'package:eye_monitoring/features/predictions/presentation/prediction_page.dart';
import 'package:eye_monitoring/features/predictions/presentation/prediction_provider.dart';
import 'package:eye_monitoring/services/ble/ble_service.dart';

class _FakeBleService implements BleService {
  final _state = StreamController<BleDeviceConnectionState>.broadcast();
  @override
  Stream<List<BleDevice>> get scanResults => const Stream.empty();
  @override
  Stream<BleDeviceConnectionState> get connectionState => _state.stream;
  @override
  Stream<String?> get errors => const Stream.empty();
  @override
  Stream<Uint8List> get sensorData => const Stream.empty();
  @override
  BleDevice? get connectedDevice => null;
  @override
  bool get isScanning => false;
  @override
  Future<void> startScan({Duration timeout = const Duration(seconds: 10)}) async {}
  @override
  Future<void> stopScan() async {}
  @override
  Future<void> connect(String deviceId) async {}
  @override
  Future<void> disconnect() async {}
  @override
  Future<void> dispose() async => _state.close();
}

class _FakeAuthRepository implements AuthRepository {
  @override
  Stream<User?> get authStateChanges => const Stream.empty();
  @override
  User? get currentUser => null;
  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets('PredictionPage shows disclaimer and empty state', (tester) async {
    final service = _FakeBleService();
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<BleService>.value(value: service),
          Provider<AuthRepository>(create: (_) => _FakeAuthRepository()),
          ChangeNotifierProvider(
              create: (context) => AuthProvider(context.read<AuthRepository>())),
          ChangeNotifierProvider(create: (_) => BleProvider(service)),
          ChangeNotifierProvider(create: (_) => MonitoringProvider(service)),
          Provider<PredictionRepository>(create: (_) => PredictionRepository()),
          Provider<SessionRepositoryBase>(create: (_) => InMemorySessionRepository()),
          ChangeNotifierProvider(
            create: (context) => SessionProvider(
              repository: context.read<SessionRepositoryBase>(),
            ),
          ),
          ChangeNotifierProvider(
            create: (context) => PredictionProvider(
              repository: context.read<PredictionRepository>(),
              monitoringProvider: context.read<MonitoringProvider>(),
              bleProvider: context.read<BleProvider>(),
              authProvider: context.read<AuthProvider>(),
              sessionProvider: context.read<SessionProvider>(),
              sessionRepository: context.read<SessionRepositoryBase>(),
            ),
          ),
        ],
        child: const MaterialApp(home: PredictionPage()),
      ),
    );
    await tester.pump();

    expect(find.text('Fatigue Results'), findsOneWidget);
    expect(find.textContaining('Experimental prototype'), findsOneWidget);
    expect(find.text('No prediction yet'), findsOneWidget);
    expect(find.text('Run analysis'), findsOneWidget);
  });
}
