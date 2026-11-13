# Wave 5: Session Management

> **Status**: ✅ Complete  
> **Duration**: 5-7 days  
> **Dependencies**: Wave 4 must be complete

---

## Objectives

- Implement session start/stop functionality
- Track session duration and metadata
- Save session data to Firestore
- Create session model

---

## Tasks

- [x] Create session model (`lib/models/session.dart`)
- [x] Build session repository (`lib/features/history/data/session_repository.dart`)
- [x] Implement session state management
- [x] Add start/stop session buttons to monitoring screen
- [x] Track session duration
- [x] Store session metadata (device ID, start time, end time, duration)
- [x] Save session to Firestore on completion
- [x] Handle session interruptions (BLE disconnect, app background)
- [x] Add session status indicators
- [x] Write unit tests for session logic
- [x] Test session persistence

---

## Deliverables

- Session control functionality
- Session data persistence
- Session metadata tracking

---

## Dependencies

- Wave 4 must be complete (need live data flowing)

---

## Success Criteria

Wave is considered complete when:
- [x] All tasks are checked off
- [x] User can start and stop sessions
- [x] Session duration is accurately tracked
- [x] Session data is saved to Firestore
- [x] Session interruptions are handled gracefully
- [x] All relevant tests pass
- [x] Data persistence is verified (repository/in-memory + unit tests; live Firestore pending env)

---

## Notes

- Coordinate session metadata with Wave 8 (History & Reports)
- Consider session recovery for interruptions
- Document session data structure for AI integration


## Implementation Notes

- **Model/Repository:** `MonitoringSession` with status/duration/device/metadata and Firestore mapping; `SessionRepository` (Firestore, `users/{uid}/sessions`) and `InMemorySessionRepository` for testing.
- **State/UI:** `SessionProvider` manages active session lifecycle, duration ticker, start/stop, BLE-disconnect and app-background interruption handling, and persistence/errors. `MonitoringPage` includes session card with start/stop controls, duration, status, and metadata indicators.
- **Tests:** `test/unit/session_model_test.dart`, `test/unit/session_provider_test.dart`, and updated `test/widget/monitoring/monitoring_page_test.dart` pass. Real Firestore write verification depends on configured Firebase project/runtime.

---

**Previous**: [Wave 4: Live Sensor Data & Signal Visualization](./WAVE_04_SIGNAL_VISUALIZATION.md)  
**Next**: [Wave 6: Python AI Backend & API](./WAVE_06_PYTHON_BACKEND.md)
