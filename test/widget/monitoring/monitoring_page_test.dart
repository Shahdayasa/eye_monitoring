import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:eye_monitoring/features/authentication/data/auth_repository.dart';
import 'package:eye_monitoring/features/authentication/domain/user_model.dart';
import 'package:eye_monitoring/features/authentication/presentation/auth_provider.dart';
import 'package:eye_monitoring/features/device/domain/ble_device.dart';
import 'package:eye_monitoring/features/device/presentation/ble_provider.dart';
import 'package:eye_monitoring/features/history/data/session_repository.dart';
import 'package:eye_monitoring/features/history/presentation/session_provider.dart';
import 'package:eye_monitoring/features/monitoring/presentation/monitoring_page.dart';
import 'package:eye_monitoring/features/monitoring/presentation/monitoring_provider.dart';
import 'package:eye_monitoring/services/ble/ble_service.dart';

class _FakeBleService implements BleService {
  _FakeBleService({required this.stateController});

  final StreamController<BleDeviceConnectionState> stateController;
  final _scan = const Stream<List<BleDevice>>.empty();
  final _err = const Stream<String?>.empty();
  final _data = const Stream<Uint8List>.empty();

  @override
  Stream<List<BleDevice>> get scanResults => _scan;
  @override
  Stream<BleDeviceConnectionState> get connectionState => stateController.stream;
  @override
  Stream<String?> get errors => _err;
  @override
  Stream<Uint8List> get sensorData => _data;
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
  Future<void> dispose() async {}
}

class _FakeAuthRepository implements AuthRepository {
  @override
  Stream<User?> get authStateChanges => const Stream.empty();
  @override
  User? get currentUser => null;
  @override
  Future<UserModel> register({
    required String email,
    required String password,
    String? displayName,
  }) => throw UnimplementedError();
  @override
  Future<UserModel> login({required String email, required String password}) =>
      throw UnimplementedError();
  @override
  Future<void> logout() async {}
  @override
  Future<void> resetPassword({required String email}) async {}
  @override
  Future<UserModel?> getUserProfile(String uid) async => null;
  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets('shows not-connected state when disconnected', (tester) async {
    final stateCtrl = StreamController<BleDeviceConnectionState>.broadcast();
    final service = _FakeBleService(stateController: stateCtrl);
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<BleService>.value(value: service),
          Provider<AuthRepository>(create: (_) => _FakeAuthRepository()),
          ChangeNotifierProvider(
              create: (context) => AuthProvider(context.read<AuthRepository>())),
          ChangeNotifierProvider(create: (_) => BleProvider(service)),
          ChangeNotifierProvider(create: (_) => MonitoringProvider(service)),
          Provider<SessionRepositoryBase>(
            create: (_) => InMemorySessionRepository(),
          ),
          ChangeNotifierProvider(
            create: (context) => SessionProvider(
              repository: context.read<SessionRepositoryBase>(),
              bleService: service,
            ),
          ),
        ],
        child: const MaterialApp(home: MonitoringPage()),
      ),
    );
    stateCtrl.add(BleDeviceConnectionState.disconnected);
    await tester.pump();
    await tester.pump();

    expect(find.text('No device connected'), findsOneWidget);
    await stateCtrl.close();
  });
}
