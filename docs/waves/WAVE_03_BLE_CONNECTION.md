# Wave 3: BLE Device Connection

> **Status**: ✅ Complete  
> **Duration**: 7-10 days  
> **Dependencies**: Wave 2 must be complete

---

## Objectives

- Implement BLE scanning and connection
- Connect to ESP32 device
- Handle connection states
- Add required Android permissions

---

## Tasks

- [x] Add flutter_blue_plus package to pubspec.yaml
- [x] Configure Android BLE permissions in AndroidManifest.xml
- [x] Create BLE service (`lib/services/ble/ble_service.dart`)
- [x] Implement BLE scanner (`lib/services/ble/ble_scanner.dart`)
- [x] Create device model (`lib/features/device/domain/ble_device.dart`)
- [x] Build device connection UI screen
- [x] Implement device scanning UI
- [x] Add connection state management
- [x] Handle connection errors (timeout, device not found, permission denied)
- [x] Add reconnection logic
- [ ] Test with actual ESP32 device
- [x] Write unit tests for BLE logic

---

## Deliverables

- ✅ BLE scanning and connection functionality
- ✅ Device connection UI
- ✅ Connection state management
- ⏳ ESP32 connectivity verified (pending hardware)

---

## Dependencies

- Wave 2 must be complete (need UI framework)
- ESP32 hardware must be available for testing

---

## Success Criteria

Wave is considered complete when:
- [x] All implementation tasks are checked off (hardware test pending)
- [x] App can scan for BLE devices (mock + real service)
- [x] App can connect to ESP32 (service/UI implemented; hardware pending)
- [x] Connection states are properly handled
- [x] Errors are gracefully managed
- [x] BLE unit tests pass
- ⏳ Connection stability pending hardware validation

---

## Notes

- Coordinate with hardware team for ESP32 availability
- Test with mock device if hardware not ready
- Verify BLE service and characteristic UUIDs with hardware team


## Implementation Notes

- **Dependencies**: `flutter_blue_plus`, `permission_handler` added; `AppConfig.useMockBle` defaults to `true` for development.
- **Domain/Services**: `BleDevice` + `BleDeviceConnectionState` (`lib/features/device/domain/ble_device.dart`), `BleService`/`BleScanner` abstractions, `MockBleService` (simulated discovery/lifecycle/errors), and `FlutterBluePlusBleService` (permissions, scan/connect/disconnect; UUIDs TBD for Wave 4).
- **State/UI**: `BleProvider` (`ChangeNotifier`) wired in `main.dart`; `DevicePage` provides scan controls, device list, status badge/card, connect/disconnect/reconnect, and error handling.
- **Tests**: `test/unit/ble/ble_device_test.dart`, `test/unit/ble/mock_ble_service_test.dart`.
- **Pending**: Validation on physical ESP32 hardware and final service/characteristic UUIDs.

---

**Previous**: [Wave 2: Core UI Framework & Navigation](./WAVE_02_UI_FRAMEWORK.md)  
**Next**: [Wave 4: Live Sensor Data & Signal Visualization](./WAVE_04_SIGNAL_VISUALIZATION.md)
