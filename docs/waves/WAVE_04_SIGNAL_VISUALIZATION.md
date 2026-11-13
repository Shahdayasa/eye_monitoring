# Wave 4: Live Sensor Data & Signal Visualization

> **Status**: ✅ Complete  
> **Duration**: 7-10 days  
> **Dependencies**: Wave 3 must be complete

---

## Objectives

- Receive EOG data from ESP32 via BLE
- Display real-time waveform
- Show ambient light readings
- Implement signal buffering

---

## Tasks

- [x] Create signal buffer service (`lib/features/monitoring/data/signal_buffer.dart`)
- [x] Implement data parsing from BLE notifications
- [x] Create signal model (`lib/features/monitoring/domain/signal_model.dart`)
- [x] Build live monitoring UI screen (`lib/features/monitoring/presentation/monitoring_page.dart`)
- [x] Implement waveform painter (`lib/features/monitoring/presentation/waveform_painter.dart`)
- [x] Add real-time chart rendering with fl_chart package
- [x] Display ambient light readings (VEML7700 data)
- [x] Show connection status indicators
- [x] Add signal quality indicators
- [x] Handle missing data states
- [x] Implement data validation
- [ ] Test with actual sensor data
- [x] Write widget/unit tests for visualization

---

## Deliverables

- ✅ Live EOG waveform display
- ✅ Ambient light reading display
- ✅ Signal buffering system
- ✅ Data validation

---

## Dependencies

- Wave 3 must be complete (need BLE connection)

---

## Success Criteria

Wave is considered complete when:
- [x] All implementation tasks are checked off (hardware sensor test pending)
- [x] Live EOG waveform is displayed
- [x] Ambient light readings are shown
- [x] Signal buffering works correctly
- [x] Data validation catches invalid inputs
- [x] Missing data states are handled
- [x] Monitoring unit/widget tests pass (12/12)
- [x] Visualization is smooth and responsive (throttled updates, fl_chart)

---

## Notes

- Add fl_chart to pubspec.yaml
- Verify sampling rate with hardware team
- Use CustomPainter for better performance if needed


## Implementation Notes

- **Dependencies**: added `fl_chart`; BLE `sensorData` stream added to service abstraction.
- **Domain/Data**: `EogSample`, `LightReading`, `SensorPacket`, `SensorPacketParser` (CSV/key-value/binary + validation), `assessSignalQuality`, and `SignalBuffer` (window/display buffer, seq-drop tracking, invalid/missing-data detection, estimated sample rate).
- **Services**: `MockBleService` emits synthetic EOG/light/battery packets when connected; `FlutterBluePlusBleService` exposes `sensorData` (notify/UUID wiring pending hardware).
- **Presentation**: `MonitoringProvider` subscribes to BLE stream/state with throttled UI updates; `monitoring_page.dart` shows connection/data states, live waveform chart, ambient light & battery, quality/buffer/drop/invalid indicators, and missing-data handling; `waveform_painter.dart` custom painter included.
- **Tests**: `test/unit/monitoring/signal_parser_test.dart`, `test/unit/monitoring/signal_buffer_test.dart`, `test/widget/monitoring/monitoring_page_test.dart` (12 passed). Actual ESP32 sensor data validation pending.

---

**Previous**: [Wave 3: BLE Device Connection](./WAVE_03_BLE_CONNECTION.md)  
**Next**: [Wave 5: Session Management](./WAVE_05_SESSION_MANAGEMENT.md)
