import '../../features/device/domain/ble_device.dart';
import 'ble_service.dart';

/// Thin scanner facade used by UI/tests; delegates to [BleService].
class BleScanner {
  final BleService _service;

  BleScanner(this._service);

  Stream<List<BleDevice>> get results => _service.scanResults;
  bool get isScanning => _service.isScanning;

  Future<void> startScan({Duration timeout = const Duration(seconds: 10)}) {
    return _service.startScan(timeout: timeout);
  }

  Future<void> stopScan() => _service.stopScan();
}
