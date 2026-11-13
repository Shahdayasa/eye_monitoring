# Wave Plans - EOG Wearable Fatigue Detection System

This document breaks down the project into sequential waves. Each wave must be completed before starting the next.

---

## Wave 0: Project Setup & Foundation

### Duration: 3-5 days
### Status: ⏳ Not Started

#### Objectives
- Set up project structure and development environment
- Configure Firebase project and security rules
- Establish version control workflow
- Set up Python virtual environment for AI backend

#### Tasks
- [x] Create Flutter project structure
- [x] Add Firebase configuration files
- [ ] Create folder structure per DESIGN.md (core/, features/, services/, models/, shared/)
- [ ] Set up Firebase project in Firebase Console
- [ ] Enable Firebase Authentication (Email/Password)
- [ ] Create Firestore database in test mode
- [ ] Write initial Firebase security rules
- [ ] Create Python virtual environment for AI backend
- [ ] Set up Git branches and collaboration workflow

#### Deliverables
- Firebase project configured
- Flutter project structure organized
- Python environment ready
- Security rules document

#### Dependencies
- None (starting point)

---

## Wave 1: Firebase Authentication & User Management

### Duration: 5-7 days
### Status: ⏳ Not Started

#### Objectives
- Implement complete authentication flow
- Create user profile management
- Set up Firestore user data structure

#### Tasks
- [ ] Create authentication repository (`lib/features/authentication/data/auth_repository.dart`)
- [ ] Implement user registration with email/password
- [ ] Implement user login with email/password
- [ ] Implement logout functionality
- [ ] Add form validation for email and password
- [ ] Create authentication state management
- [ ] Build login/register UI screens
- [ ] Add error handling for authentication failures
- [ ] Create Firestore users collection structure
- [ ] Implement user profile creation on registration
- [ ] Add password reset functionality
- [ ] Write unit tests for authentication logic
- [ ] Write widget tests for auth UI

#### Deliverables
- Working authentication system
- User profile in Firestore
- Login/Register screens
- Authentication tests

#### Dependencies
- Wave 0 must be complete

#### Notes
- Firebase Auth is already partially configured
- Focus on clean architecture from the start

---

## Wave 2: Core UI Framework & Navigation

### Duration: 5-7 days
### Status: ⏳ Not Started

#### Objectives
- Build main app shell with navigation
- Create theme system
- Implement shared UI components
- Set up routing

#### Tasks
- [ ] Create app theme (`lib/core/theme/app_theme.dart`)
- [ ] Define color palette (`lib/core/theme/colors.dart`)
- [ ] Define typography system (`lib/core/theme/typography.dart`)
- [ ] Build main app shell with bottom navigation
- [ ] Create navigation router configuration
- [ ] Build shared loading indicator widget
- [ ] Build shared error message widget
- [ ] Build shared status badge widget
- [ ] Create responsive layout utilities
- [ ] Add app configuration management
- [ ] Implement navigation guards for authentication
- [ ] Test navigation flows

#### Deliverables
- App theme system
- Navigation framework
- Shared UI component library
- Main app shell

#### Dependencies
- Wave 1 must be complete (need authentication for navigation guards)

---

## Wave 3: BLE Device Connection

### Duration: 7-10 days
### Status: ⏳ Not Started

#### Objectives
- Implement BLE scanning and connection
- Connect to ESP32 device
- Handle connection states
- Add required Android permissions

#### Tasks
- [ ] Add flutter_blue_plus package to pubspec.yaml
- [ ] Configure Android BLE permissions in AndroidManifest.xml
- [ ] Create BLE service (`lib/services/ble/ble_service.dart`)
- [ ] Implement BLE scanner (`lib/services/ble/ble_scanner.dart`)
- [ ] Create device model (`lib/features/device/domain/device_model.dart`)
- [ ] Build device connection UI screen
- [ ] Implement device scanning UI
- [ ] Add connection state management
- [ ] Handle connection errors (timeout, device not found, permission denied)
- [ ] Add reconnection logic
- [ ] Test with actual ESP32 device
- [ ] Write unit tests for BLE logic

#### Deliverables
- BLE scanning and connection functionality
- Device connection UI
- Connection state management
- ESP32 connectivity verified

#### Dependencies
- Wave 2 must be complete (need UI framework)
- ESP32 hardware must be available for testing

#### Notes
- Coordinate with hardware team for ESP32 availability
- Test with mock device if hardware not ready

---

## Wave 4: Live Sensor Data & Signal Visualization

### Duration: 7-10 days
### Status: ⏳ Not Started

#### Objectives
- Receive EOG data from ESP32 via BLE
- Display real-time waveform
- Show ambient light readings
- Implement signal buffering

#### Tasks
- [ ] Create signal buffer service (`lib/features/monitoring/data/signal_buffer.dart`)
- [ ] Implement data parsing from BLE notifications
- [ ] Create signal model (`lib/features/monitoring/domain/signal_model.dart`)
- [ ] Build live monitoring UI screen (`lib/features/monitoring/presentation/monitoring_page.dart`)
- [ ] Implement waveform painter (`lib/features/monitoring/presentation/waveform_painter.dart`)
- [ ] Add real-time chart rendering with fl_chart package
- [ ] Display ambient light readings (VEML7700 data)
- [ ] Show connection status indicators
- [ ] Add signal quality indicators
- [ ] Handle missing data states
- [ ] Implement data validation
- [ ] Test with actual sensor data
- [ ] Write widget tests for visualization

#### Deliverables
- Live EOG waveform display
- Ambient light reading display
- Signal buffering system
- Data validation

#### Dependencies
- Wave 3 must be complete (need BLE connection)

#### Notes
- Add fl_chart to pubspec.yaml
- Verify sampling rate with hardware team

---

## Wave 5: Session Management

### Duration: 5-7 days
### Status: ⏳ Not Started

#### Objectives
- Implement session start/stop functionality
- Track session duration and metadata
- Save session data to Firestore
- Create session model

#### Tasks
- [ ] Create session model (`lib/models/session.dart`)
- [ ] Build session repository (`lib/features/history/data/session_repository.dart`)
- [ ] Implement session state management
- [ ] Add start/stop session buttons to monitoring screen
- [ ] Track session duration
- [ ] Store session metadata (device ID, start time, end time, duration)
- [ ] Save session to Firestore on completion
- [ ] Handle session interruptions (BLE disconnect, app background)
- [ ] Add session status indicators
- [ ] Write unit tests for session logic
- [ ] Test session persistence

#### Deliverables
- Session control functionality
- Session data persistence
- Session metadata tracking

#### Dependencies
- Wave 4 must be complete (need live data flowing)

---

## Wave 6: Python AI Backend & API

### Duration: 10-14 days
### Status: ⏳ Not Started

#### Objectives
- Build FastAPI backend for AI inference
- Implement signal preprocessing
- Create prediction endpoint
- Set up model serving infrastructure

#### Tasks
- [ ] Create Python project structure (ai_backend/)
- [ ] Set up FastAPI application (`ai_backend/app/main.py`)
- [ ] Define request/response schemas (`ai_backend/app/schemas.py`)
- [ ] Implement signal preprocessing pipeline (`ai_backend/app/preprocessing.py`)
- [ ] Implement feature extraction (`ai_backend/app/features.py`)
- [ ] Create model inference module (`ai_backend/app/inference.py`)
- [ ] Add Firebase token verification (`ai_backend/app/auth.py`)
- [ ] Build health check endpoint
- [ ] Build prediction endpoint (`/v1/predict`)
- [ ] Add comprehensive error handling
- [ ] Add request validation
- [ ] Write unit tests for preprocessing
- [ ] Write unit tests for inference
- [ ] Write API integration tests
- [ ] Create Dockerfile
- [ ] Test API with Postman/curl

#### Deliverables
- Working FastAPI backend
- Signal preprocessing pipeline
- Prediction API endpoint
- API tests
- Docker configuration

#### Dependencies
- Wave 0 must be complete (Python environment)
- Dataset must be available for preprocessing design
- Model must be trained (coordinate with AI work)

#### Notes
- Coordinate with AI model development
- Document exact preprocessing requirements

---

## Wave 7: AI Integration with Flutter

### Duration: 5-7 days
### Status: ⏳ Not Started

#### Objectives
- Connect Flutter app to AI API
- Send signal windows for inference
- Display prediction results
- Handle API errors

#### Tasks
- [ ] Add http package to pubspec.yaml
- [ ] Create API client service (`lib/services/ai_api/api_client.dart`)
- [ ] Define API endpoints (`lib/services/ai_api/api_endpoints.dart`)
- [ ] Create prediction model (`lib/models/prediction.dart`)
- [ ] Build prediction repository (`lib/features/predictions/data/prediction_repository.dart`)
- [ ] Implement signal window formation (correct duration and sample rate)
- [ ] Add API request logic
- [ ] Build prediction result UI screen
- [ ] Display prediction with timestamp
- [ ] Show model version information
- [ ] Add experimental-use disclaimer
- [ ] Handle API errors (network failure, timeout, invalid response)
- [ ] Add loading states
- [ ] Write integration tests
- [ ] Test with actual API

#### Deliverables
- Flutter-API integration
- Prediction result display
- Error handling
- Integration tests

#### Dependencies
- Wave 4 must be complete (need signal data)
- Wave 6 must be complete (need API available)

#### Notes
- Ensure signal window matches model training specifications
- Verify sampling rate consistency

---

## Wave 8: History & Reports

### Duration: 7-10 days
### Status: ⏳ Not Started

#### Objectives
- Display session history
- Show prediction history per session
- Add data visualization for trends
- Implement export functionality (optional)

#### Tasks
- [ ] Create session detail model
- [ ] Build history repository
- [ ] Implement Firestore queries for user sessions
- [ ] Build history list UI screen (`lib/features/history/presentation/history_page.dart`)
- [ ] Build session detail UI screen (`lib/features/history/presentation/session_detail_page.dart`)
- [ ] Display session metadata (date, duration, device)
- [ ] Show prediction summary per session
- [ ] Add charts for prediction trends (using fl_chart)
- [ ] Implement empty state (no sessions)
- [ ] Add loading states
- [ ] Add error handling
- [ ] Implement pull-to-refresh
- [ ] Add optional PDF export (if approved)
- [ ] Write widget tests
- [ ] Test with real Firestore data

#### Deliverables
- Session history display
- Session detail view
- Prediction trend visualization
- History tests

#### Dependencies
- Wave 5 must be complete (need sessions saved)
- Wave 7 must be complete (need predictions saved)

---

## Wave 9: Settings & User Preferences

### Duration: 3-5 days
### Status: ⏳ Not Started

#### Objectives
- Build settings screen
- Implement user preferences
- Add account management
- Include privacy information

#### Tasks
- [ ] Build settings UI screen (`lib/features/settings/presentation/settings_page.dart`)
- [ ] Add account information display
- [ ] Implement sign out functionality
- [ ] Add device connection help/instructions
- [ ] Create data/privacy information page
- [ ] Add user preferences (if applicable)
- [ ] Implement data deletion option (if required)
- [ ] Add app version display
- [ ] Test settings persistence
- [ ] Write widget tests

#### Deliverables
- Settings screen
- Account management
- Privacy information
- Settings tests

#### Dependencies
- Wave 1 must be complete (need authentication)

---

## Wave 10: Error Handling & Edge Cases

### Duration: 5-7 days
### Status: ⏳ Not Started

#### Objectives
- Comprehensive error handling across all features
- Add offline detection
- Improve user feedback
- Add logging

#### Tasks
- [ ] Review all features for error handling
- [ ] Add network connectivity detection
- [ ] Implement offline states for all screens
- [ ] Add retry mechanisms for failed operations
- [ ] Improve error messages (clear, actionable)
- [ ] Add loading indicators for all async operations
- [ ] Handle edge cases (BLE disconnect during session, API timeout, etc.)
- [ ] Add error logging for debugging
- [ ] Test error scenarios
- [ ] Update UI for all error states

#### Deliverables
- Robust error handling
- Offline support
- Improved user feedback
- Error logging

#### Dependencies
- All previous waves should be complete

---

## Wave 11: Testing & Quality Assurance

### Duration: 7-10 days
### Status: ⏳ Not Started

#### Objectives
- Comprehensive testing across all features
- Integration testing
- Performance testing
- Bug fixes

#### Tasks
- [ ] Complete unit test coverage for all repositories
- [ ] Complete widget test coverage for all screens
- [ ] Write integration tests for critical flows
- [ ] Test BLE communication thoroughly
- [ ] Test API integration thoroughly
- [ ] Test Firestore operations
- [ ] Performance testing (large datasets, long sessions)
- [ ] Memory leak testing
- [ ] Test on multiple Android devices/emulators
- [ ] Fix discovered bugs
- [ ] Code review and refactoring
- [ ] Update documentation

#### Deliverables
- Comprehensive test suite
- Bug fixes
- Performance validation
- Code quality improvements

#### Dependencies
- All previous waves must be complete

---

## Wave 12: Documentation & Deployment Preparation

### Duration: 5-7 days
### Status: ⏳ Not Started

#### Objectives
- Complete all documentation
- Prepare for deployment
- Create user manual
- Final testing

#### Tasks
- [ ] Complete README.md with setup instructions
- [ ] Write user manual
- [ ] Document API endpoints
- [ ] Create deployment guide for Python service
- [ ] Document Firebase security rules
- [ ] Create troubleshooting guide
- [ ] Build release APK/AAB
- [ ] Test release build
- [ ] Create presentation materials
- [ ] Final system testing
- [ ] Document known limitations
- [ ] Prepare demo script

#### Deliverables
- Complete documentation
- Release build
- User manual
- Deployment guide
- Presentation materials

#### Dependencies
- All previous waves must be complete

---

## Wave Summary

| Wave | Title | Duration | Dependencies |
|------|-------|----------|--------------|
| 0 | Project Setup & Foundation | 3-5 days | None |
| 1 | Firebase Authentication & User Management | 5-7 days | Wave 0 |
| 2 | Core UI Framework & Navigation | 5-7 days | Wave 1 |
| 3 | BLE Device Connection | 7-10 days | Wave 2 |
| 4 | Live Sensor Data & Signal Visualization | 7-10 days | Wave 3 |
| 5 | Session Management | 5-7 days | Wave 4 |
| 6 | Python AI Backend & API | 10-14 days | Wave 0 |
| 7 | AI Integration with Flutter | 5-7 days | Wave 4, Wave 6 |
| 8 | History & Reports | 7-10 days | Wave 5, Wave 7 |
| 9 | Settings & User Preferences | 3-5 days | Wave 1 |
| 10 | Error Handling & Edge Cases | 5-7 days | All previous |
| 11 | Testing & Quality Assurance | 7-10 days | All previous |
| 12 | Documentation & Deployment Preparation | 5-7 days | All previous |

**Total Estimated Duration**: 74-104 days (working sequentially)

**Note**: Wave 6 (Python AI Backend) can be developed in parallel with Waves 1-5 if you have a dedicated Python developer or if you're working on both simultaneously.

---

## Critical Path

The critical path through the project is:

```
Wave 0 → Wave 1 → Wave 2 → Wave 3 → Wave 4 → Wave 5 → Wave 8
                                                            ↓
Wave 0 → Wave 6 → Wave 7 → Wave 8 ----------------------→ Wave 11 → Wave 12
```

The project is hardware-dependent (Waves 3-5 require ESP32) and AI-dependent (Waves 6-7 require trained model).

---

## Risk Mitigation

1. **Hardware delays**: If ESP32 is not ready, create mock BLE service for testing
2. **AI model delays**: Use mock API with sample responses during development
3. **Firebase costs**: Use Firebase emulators during development
4. **Integration issues**: Test each component thoroughly before integration
5. **Performance issues**: Profile and optimize incrementally

---

## Success Criteria for Each Wave

Each wave is considered complete when:
- All tasks are checked off
- Deliverables are produced
- Tests pass (where applicable)
- Documentation is updated
- No blocking issues remain

---

## Notes

- **Do not start the next wave until the current wave is complete**
- Each wave builds on the previous waves
- Coordinate hardware dependencies early
- Document decisions and changes
- Regular code reviews during each wave
- Update this document as progress is made
