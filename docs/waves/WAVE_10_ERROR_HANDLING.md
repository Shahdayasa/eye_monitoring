# Wave 10: Error Handling & Edge Cases

> **Status**: ⏳ In Progress  
> **Duration**: 5-7 days  
> **Dependencies**: All previous waves should be complete

---

## Objectives

- Comprehensive error handling across all features
- Add offline detection
- Improve user feedback
- Add logging

---

## Tasks

- [x] Review all features for error handling
- [x] Add network connectivity detection
- [x] Implement offline states for all screens
- [x] Add retry mechanisms for failed operations
- [x] Improve error messages (clear, actionable)
- [x] Add loading indicators for all async operations
- [x] Handle edge cases (BLE disconnect during session, API timeout, etc.)
- [x] Add error logging for debugging
- [ ] Test error scenarios
- [x] Update UI for all error states

## Implementation Notes (2026-11-13)

- Added `core/connectivity/connectivity_service.dart` + global offline banner and `connectivity_plus` dependency.
- Added `core/logging/app_logger.dart` and instrumented BLE/session/prediction/monitoring/auth flows.
- Added retry/backoff and clearer network/timeouts in `AiApiClient` and `SessionRepository` (Firestore ops); improved user-facing messages and best-effort persistence handling.
- Added session data deletion support (`deleteAllSessions`) and settings compatibility wrapper.
- Remaining: run targeted/manual error-scenario tests in a Flutter-capable environment.

---

## Deliverables

- Robust error handling
- Offline support
- Improved user feedback
- Error logging

---

## Dependencies

- All previous waves should be complete

---

## Success Criteria

Wave is considered complete when:
- [ ] All tasks are checked off
- [ ] All error states are detected and handled
- [ ] Offline states are implemented
- [ ] Error messages are clear and actionable
- [ ] Loading indicators are consistent
- [ ] Edge cases are handled gracefully
- [ ] Error logging is in place
- [ ] All error scenarios are tested

---

## Notes

- Focus on user experience during errors
- Provide clear recovery paths
- Test with various failure scenarios
- Document error handling patterns

---

## Error Scenarios to Test

### BLE Errors
- Bluetooth permission denied
- ESP32 not found
- BLE connection lost
- BLE scan timeout

### Sensor Errors
- No sensor samples received
- Poor/noisy signal
- Incomplete signal window
- Unsupported sampling rate

### Network Errors
- Internet unavailable
- Python API unavailable or timeout
- API request failed

### Firebase Errors
- Firebase authentication expired
- Firebase write rejected
- Firebase read failed

### Model Errors
- Model not loaded
- Invalid prediction response
- Preprocessing failed

---

**Previous**: [Wave 9: Settings & User Preferences](./WAVE_09_SETTINGS.md)  
**Next**: [Wave 11: Testing & Quality Assurance](./WAVE_11_TESTING.md)
