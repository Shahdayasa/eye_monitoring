# Wave Status Tracker

> Track progress through each wave of the project

---

## Current Wave: Wave 12 (Documentation & Deployment Preparation)

### Wave Status: ⏳ In Progress

---

## Wave Progress Overview

| Wave | Title | Status | Progress | Start Date | End Date |
|------|-------|--------|----------|------------|----------|
| 0 | Project Setup & Foundation | ⏳ In Progress | 40% | - | - |
| 1 | Firebase Authentication & User Management | ✅ Complete | 100% | - | - |
| 2 | Core UI Framework & Navigation | ✅ Complete | 100% | - | - |
| 3 | BLE Device Connection | ✅ Complete | 100% | - | - |
| 4 | Live Sensor Data & Signal Visualization | ✅ Complete | 100% | - | - |
| 5 | Session Management | ✅ Complete | 100% | - | - |
| 6 | Python AI Backend & API | ✅ Complete | 100% | - | - |
| 7 | AI Integration with Flutter | ⏸️ Not Started | 0% | - | - |
| 8 | History & Reports | ⏸️ Not Started | 0% | - | - |
| 9 | Settings & User Preferences | ✅ Complete | 100% | - | - |
| 10 | Error Handling & Edge Cases | ⏳ In Progress | 80% | 2026-11-13 | - |
| 11 | Testing & Quality Assurance | ⏳ In Progress | 45% | 2026-11-13 | - |
| 12 | Documentation & Deployment Preparation | ⏳ In Progress | 70% | 2026-11-13 | - |

---

## Detailed Wave Status

### Wave 0: Project Setup & Foundation

**Status**: ⏳ In Progress  
**Start Date**: -  
**Target End Date**: -  
**Actual End Date**: -

#### Tasks Progress

- [x] Create Flutter project structure
- [x] Add Firebase configuration files
- [ ] Create folder structure per DESIGN.md
- [ ] Set up Firebase project in Firebase Console
- [ ] Enable Firebase Authentication (Email/Password)
- [ ] Create Firestore database in test mode
- [ ] Write initial Firebase security rules
- [ ] Create Python virtual environment for AI backend
- [ ] Set up Git branches and collaboration workflow

#### Notes
- Basic Flutter project exists
- Firebase configuration partially done
- Need to complete folder structure

---

### Wave 1: Firebase Authentication & User Management

**Status**: ✅ Complete  
**Start Date**: -  
**Target End Date**: -  
**Actual End Date**: -

#### Tasks Progress

- [x] Create authentication repository
- [x] Implement user registration
- [x] Implement user login
- [x] Implement logout functionality
- [x] Add form validation
- [x] Create authentication state management
- [x] Build login/register UI screens
- [x] Add error handling
- [x] Create Firestore users collection
- [x] Implement user profile creation
- [x] Add password reset functionality
- [x] Write unit tests
- [x] Write widget tests

#### Dependencies
- Wave 0 must be complete

#### Notes
- Implemented in `lib/features/authentication/` with provider-based state, profile setup, splash/onboarding routing, and widget/unit tests. Some Firebase console steps remain tracked in Wave 0.

---

### Wave 2: Core UI Framework & Navigation

**Status**: ✅ Complete

#### Tasks Progress

- [x] Create app theme
- [x] Define color palette
- [x] Define typography system
- [x] Build main app shell
- [x] Create navigation router
- [x] Build shared loading indicator
- [x] Build shared error message
- [x] Build shared status badge
- [x] Create responsive layout utilities
- [x] Add app configuration management
- [x] Implement navigation guards
- [x] Test navigation flows

#### Notes
- Added `lib/core/theme/typography.dart`, expanded `lib/core/config/app_config.dart`, and implemented design-compliant floating pill bottom navigation in `lib/shared/widgets/app_bottom_nav_bar.dart`.
- Added shared UI foundation: `scroll_reveal.dart`, `skeleton.dart`, `paginated_list.dart`, `app_search_bar.dart`; aligned `error_message.dart` to design tokens and applied scroll-reveal to the dashboard.
- Added widget tests for navigation, search, scroll-reveal, and skeletons. `flutter test/analyze` could not be run in this environment because the Windows Flutter/Dart SDK under `/mnt/c/src/flutter` is missing Linux executables.

---

### Wave 3: BLE Device Connection

**Status**: ✅ Complete

#### Tasks Progress

- [x] Add flutter_blue_plus package
- [x] Configure Android BLE permissions
- [x] Create BLE service
- [x] Implement BLE scanner
- [x] Create device model
- [x] Build device connection UI
- [x] Implement device scanning UI
- [x] Add connection state management
- [x] Handle connection errors
- [x] Add reconnection logic
- [ ] Test with actual ESP32 device
- [x] Write unit tests

#### Notes
- Added `flutter_blue_plus` and `permission_handler`; configured Android BLE permissions in `android/app/src/main/AndroidManifest.xml`.
- Implemented BLE domain/service layer: `lib/features/device/domain/ble_device.dart`, `lib/services/ble/ble_service.dart`, `lib/services/ble/ble_scanner.dart`, `lib/services/ble/mock_ble_service.dart`, `lib/services/ble/flutter_blue_plus_ble_service.dart`.
- Added `BleProvider` state management, wired providers in `lib/main.dart` (`AppConfig.useMockBle` selects mock by default), and built device connection UI in `lib/features/device/presentation/device_page.dart` (scan/connect/disconnect/reconnect, states, errors).
- Unit tests added: `test/unit/ble/ble_device_test.dart`, `test/unit/ble/mock_ble_service_test.dart`. Actual ESP32 hardware validation remains pending.

---

### Wave 4: Live Sensor Data & Signal Visualization

**Status**: ✅ Complete

#### Tasks Progress

- [x] Create signal buffer service
- [x] Implement data parsing
- [x] Create signal model
- [x] Build live monitoring UI
- [x] Implement waveform painter
- [x] Add real-time chart rendering
- [x] Display ambient light readings
- [x] Show connection status
- [x] Add signal quality indicators
- [x] Handle missing data states
- [x] Implement data validation
- [ ] Test with actual sensor data
- [x] Write widget/unit tests

#### Notes
- Added signal domain/data layer: `lib/features/monitoring/domain/signal_model.dart` (EOG/light models, packet parser for CSV/key-value/binary, quality assessment) and `lib/features/monitoring/data/signal_buffer.dart` (windowed buffering, display window, validation, drop/invalid/missing-data tracking).
- Extended BLE for sensor streaming: `BleService.sensorData` plus mock stream in `MockBleService` and stream hook placeholder in `FlutterBluePlusBleService` (UUIDs/subscriptions TBD with hardware).
- Added `MonitoringProvider` and monitoring UI: `lib/features/monitoring/presentation/monitoring_page.dart` with connection/not-connected states, real-time fl_chart waveform, ambient light/battery metrics, signal quality + buffer/drop/invalid indicators, and missing-data handling; `waveform_painter.dart` custom painter included.
- Wired `MonitoringProvider` in `lib/main.dart`. Tests: `test/unit/monitoring/signal_parser_test.dart`, `test/unit/monitoring/signal_buffer_test.dart`, `test/widget/monitoring/monitoring_page_test.dart` (12/12 passed). Actual sensor/hardware validation pending.

---

### Wave 5: Session Management

**Status**: ✅ Complete

#### Tasks Progress

- [x] Create session model
- [x] Build session repository
- [x] Implement session state management
- [x] Add start/stop session buttons
- [x] Track session duration
- [x] Store session metadata
- [x] Save session to Firestore
- [x] Handle session interruptions
- [x] Add session status indicators
- [x] Write unit tests
- [x] Test session persistence

#### Notes
- Added `lib/models/session.dart` (status, duration/device/timestamps/prediction metadata, Firestore serialization) and `lib/features/history/data/session_repository.dart` (Firestore `users/{uid}/sessions` create/save/end + in-memory implementation for tests).
- Added `SessionProvider` for start/stop, 1s duration ticker, BLE disconnect and app-lifecycle interruption handling, and save/error states; wired in `lib/main.dart`.
- Updated `MonitoringPage` with session control/status card (start/stop, duration, device, status badges, interruption/error feedback). Tests: `test/unit/session_model_test.dart`, `test/unit/session_provider_test.dart`, updated `test/widget/monitoring/monitoring_page_test.dart` (all passed). End-to-end Firestore persistence on real backend still requires configured Firebase environment.

---

### Wave 6: Python AI Backend & API

**Status**: ✅ Complete

#### Tasks Progress

- [x] Create Python project structure
- [x] Set up FastAPI application
- [x] Define request/response schemas
- [x] Implement signal preprocessing
- [x] Implement feature extraction
- [x] Create model inference module
- [x] Add Firebase token verification
- [x] Build health check endpoint
- [x] Build prediction endpoint
- [x] Add error handling
- [x] Add request validation
- [x] Write unit tests
- [x] Write API integration tests
- [x] Create Dockerfile
- [ ] Test API with Postman/curl in a fully provisioned runtime

#### Notes
- Implemented `ai_backend/` service: `app/main.py` (FastAPI, CORS, `/health`, `/v1/model`, `/v1/predict`, auth dependency, error handling), `app/schemas.py` (validated request/response/models), `app/preprocessing.py` (deterministic validation/DC removal/bandpass/normalization/quality), `app/features.py` (time/frequency features), `app/inference.py` (artifact-aware loader, safe `insufficient_evidence` when no validated model), `app/auth.py` (Firebase bearer verification, `REQUIRE_AUTH` toggle).
- Added/updated `requirements.txt`, `Dockerfile`, `.dockerignore`, `README.md`, `artifacts/README.md`, and package markers. Wrote tests: `tests/test_preprocessing.py`, `tests/test_inference.py`, `tests/test_api.py`.
- Verification: `python3 -m py_compile` passed for all app/test modules. Runtime test execution (`pytest`) and live API/curl checks could not be run in this environment because Python dependencies (fastapi/pydantic/numpy/scipy/pytest/httpx/firebase-admin) are not installed; run after `pip install -r requirements.txt`. No trained/clinically validated model included by design.

---

### Wave 7: AI Integration with Flutter

**Status**: ⏸️ Not Started

#### Tasks Progress

- [ ] Add http package
- [ ] Create API client service
- [ ] Define API endpoints
- [ ] Create prediction model
- [ ] Build prediction repository
- [ ] Implement signal window formation
- [ ] Add API request logic
- [ ] Build prediction result UI
- [ ] Display prediction with timestamp
- [ ] Show model version
- [ ] Add experimental-use disclaimer
- [ ] Handle API errors
- [ ] Add loading states
- [ ] Write integration tests
- [ ] Test with API

---

### Wave 8: History & Reports

**Status**: ⏸️ Not Started

#### Tasks Progress

- [ ] Create session detail model
- [ ] Build history repository
- [ ] Implement Firestore queries
- [ ] Build history list UI
- [ ] Build session detail UI
- [ ] Display session metadata
- [ ] Show prediction summary
- [ ] Add trend charts
- [ ] Implement empty state
- [ ] Add loading states
- [ ] Add error handling
- [ ] Implement pull-to-refresh
- [ ] Add optional export
- [ ] Write widget tests
- [ ] Test with Firestore

---


### Wave 9: Settings & User Preferences

**Status**: ✅ Complete

#### Tasks Progress

- [x] Build settings UI screen (`lib/features/settings/presentation/settings_page.dart`)
- [x] Add account information display
- [x] Implement sign out functionality
- [x] Add device connection help/instructions
- [x] Create data/privacy information page
- [x] Add user preferences (if applicable)
- [x] Implement data deletion option (if required)
- [x] Add app version display
- [x] Test settings persistence
- [x] Write widget tests

#### Notes
- Implemented settings with account details, sign-out, device connection help, and data/privacy pages.
- Added persisted preferences via `SharedPreferences` (`UserPreferences`) and app/environment version display.
- Added "Delete my data" to remove saved session history for the user (with repository support).
- Tests added: `test/unit/settings/user_preferences_test.dart`, `test/widget/settings/settings_page_test.dart`.



### Wave 10: Error Handling & Edge Cases

**Status**: ⏳ In Progress

#### Tasks Progress

- [x] Review all features for error handling
- [x] Add network connectivity detection
- [x] Implement offline states
- [x] Add retry mechanisms
- [x] Improve error messages
- [x] Add loading indicators
- [x] Handle edge cases
- [x] Add error logging
- [ ] Test error scenarios
- [x] Update UI for error states

#### Notes
- Added `ConnectivityService` (`connectivity_plus`) and global `OfflineBanner`; improved user-facing network/offline/error messaging across history, session, prediction, and BLE flows.
- Added centralized `AppLogger`, retry/backoff for AI API and Firestore session/prediction operations, and safer stream/error handling for monitoring and BLE.
- Implemented session repository data deletion support (`deleteAllSessions`) and compatibility wrapper for settings; improved local-save fallback messaging on interruption/save failures.
- Flutter/Dart CLI unavailable in this Linux/WSL environment for automated test runs; manual/error-scenario validation still pending.

---

### Wave 11: Testing & Quality Assurance

**Status**: ⏸️ Not Started

#### Tasks Progress

- [ ] Complete unit test coverage
- [ ] Complete widget test coverage
- [ ] Write integration tests
- [ ] Test BLE communication
- [ ] Test API integration
- [ ] Test Firestore operations
- [ ] Performance testing
- [ ] Memory leak testing
- [ ] Test on multiple devices
- [ ] Fix bugs
- [ ] Code review
- [ ] Update documentation

---

### Wave 12: Documentation & Deployment Preparation

**Status**: ⏸️ Not Started

#### Tasks Progress

- [ ] Complete README.md
- [ ] Write user manual
- [ ] Document API endpoints
- [ ] Create deployment guide
- [ ] Document security rules
- [ ] Create troubleshooting guide
- [ ] Build release APK/AAB
- [ ] Test release build
- [ ] Create presentation materials
- [ ] Final system testing
- [ ] Document limitations
- [ ] Prepare demo script

---

## Status Legend

- ⏸️ **Not Started**: Wave has not begun
- ⏳ **In Progress**: Wave is currently being worked on
- ✅ **Complete**: Wave is finished and verified
- ⚠️ **Blocked**: Wave is blocked by an issue
- ⏸️ **On Hold**: Wave is temporarily paused

---

## How to Update

1. When starting a new wave:
   - Change status from "Not Started" to "In Progress"
   - Update "Current Wave" section at top
   - Add start date

2. When completing tasks:
   - Check off completed tasks
   - Update progress percentage

3. When completing a wave:
   - Change status to "Complete"
   - Add end date
   - Update "Current Wave" section
   - Verify all deliverables are produced

4. When blocked:
   - Change status to "Blocked"
   - Add note about blocker in Notes section
   - Create issue if needed

---

## Notes

Use this space to track important decisions, blockers, or changes:

### Wave 0 Notes
- Initial project setup in progress
- Firebase project needs to be created
- Folder structure needs to be implemented

### Wave 11: Testing & Quality Assurance

**Status**: ⏳ In Progress  
**Start Date**: 2026-11-13

#### Tasks Progress

- [x] Execute existing unit/widget test suite and fix discovered failures
- [x] Code review/refactor in touched areas
- [x] Update wave/testing documentation
- [ ] Add/expand integration tests for critical flows
- [ ] BLE hardware, multi-device/emulator, Firestore/API live, performance, memory, and coverage validation

#### Notes
- Full Flutter suite passed in available environment (2026-11-13): `cmd.exe /c "flutter test"` in `eye_monitoring` → **111 passed**.
- Fixes: missing theme tokens (`AppRadius.input`, `AppTypography.label`, `AppColors.warningBorder`), settings tile materialization, skeleton reduced-motion behavior, and stabilized prediction/session-detail/settings tests.
- Blocked: real ESP32/device matrix, live Firebase/Python runtime, performance/memory profiling, formal coverage.

---

### Wave 12: Documentation & Deployment Preparation

**Status**: ⏳ In Progress  
**Start Date**: 2026-11-13

#### Tasks Progress

- [x] Complete README.md with setup/run/build/test/config instructions
- [x] Write user manual (`docs/USER_MANUAL.md`)
- [x] Document API endpoints (`docs/API.md`, aligned with `ai_backend/app`)
- [x] Create deployment guide for app/API/Firebase (`docs/DEPLOYMENT.md`)
- [x] Document Firebase security rules (`docs/FIREBASE_SECURITY.md`, `firestore.rules`, `storage.rules`)
- [x] Create troubleshooting guide (`docs/TROUBLESHOOTING.md`)
- [x] Create presentation materials outline (`docs/PRESENTATION.md`)
- [x] Prepare demo script (`docs/DEMO_SCRIPT.md`)
- [x] Document known limitations (`docs/KNOWN_LIMITATIONS.md`)
- [ ] Build release APK/AAB and test on target devices
- [ ] Final end-to-end system testing (real hardware, deployed API, Firebase prod config)

#### Notes
- Docs index updated (`docs/README.md`) and wave docs/status refreshed (`docs/waves/WAVE_12_DOCUMENTATION.md`, `docs/waves/README.md`).
- Pending: release signing/build verification, Docker/hosting execution, Firebase rule/index deployment validation in target project, and full live system testing.

---

**Last Updated**: 2026-11-13
