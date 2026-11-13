# Product and Technical Design --- EOG Wearable Fatigue Detection

> Project working title: **AI-Based Wearable Eye Fatigue Detection System**  
> This is an initial design specification for the student team and AI coding assistants.

## 1. Product Vision

Build a wearable glasses-based prototype that acquires EOG signals, uses an AI model to estimate fatigue-related patterns, and presents understandable results through an Android mobile application.

### Design Priorities

1. Reliable sensor acquisition
2. Clear feedback
3. Readable visualizations
4. Simple operation
5. Privacy
6. Testability

**Important**: This is an academic prototype, not a certified medical device.

## 2. Users and Primary Scenario

### Primary User

A person wearing the prototype glasses and using the companion Android application.

### Typical Session Flow

1. User opens the app and signs in (if accounts are enabled).
2. User checks the device/battery connection status.
3. User connects to the ESP32 over Bluetooth Low Energy.
4. App confirms that sensor data is arriving.
5. App displays live signal information and ambient-light context.
6. Signal windows are sent to the Python inference service, or processed locally if an offline model is later selected.
7. App displays the experimental fatigue estimate and its timestamp.
8. Results are saved to Firebase when connectivity and user consent allow.
9. User can review previous sessions and reports.

## 3. System Architecture

### 3.1 Hardware Layer

#### Known Components

- **ESP32-WROOM-32**: Microcontroller with BLE and WiFi
- **BioAmp EXG Pill**: One-channel analog biopotential front-end selected for EOG
- **VEML7700**: Ambient-light sensor
- **Power**: Rechargeable lithium battery, charging/power circuitry, switch, and wiring
- **Form factor**: Glasses-mounted electrodes and sensor arrangement

#### Hardware Verification Requirements

The hardware team must verify all electrical connections and supply requirements against the exact board/module revisions.

**Critical Safety Notes**:
- The BioAmp documentation states an input-voltage range of 4.5--40 V; verify the correct meaning of this specification and the final power design with the manufacturer's documentation.
- **Do not connect a signal or supply to an ESP32 pin unless its electrical limits are verified.**
- ESP32 ADC input limits, grounding, analog reference, noise, and safe battery charging require explicit testing.

### 3.2 Mobile Layer

Flutter (Dart) is the Android application frontend. It handles:

- Screens and navigation
- BLE scanning, connection, and incoming data
- Signal buffering and display
- Requests to the AI API
- Firebase Authentication and Firestore access
- Session history and user-facing alerts

**Note**: The application should not contain Python source code. If the team later chooses on-device inference, the trained model must be converted to a mobile-compatible runtime and integrated through a suitable Flutter/native plugin.

### 3.3 AI Service Layer

Python with FastAPI is the initial proposed inference service:

- Validates incoming signal windows
- Applies the exact training-time preprocessing
- Loads the versioned model
- Runs inference
- Returns a structured prediction response

The Python service is separate from Firebase. It can be deployed to Google Cloud Run or another suitable Python host. Firebase Authentication ID tokens should be verified by the service.

### 3.4 Firebase Layer

#### Proposed Firebase Services

- **Firebase Authentication**: Account creation and sign-in, if accounts are required
- **Cloud Firestore**: User profile metadata, session summaries, predictions, and report metadata
- **Firebase Cloud Messaging**: Optional push notifications, only if needed
- **Firebase Security Rules**: Access control for user-owned data

**Data Storage Note**: Do not store large continuous raw signal streams in Firestore by default. Decide whether raw signals are needed for research; if so, evaluate an appropriate file/object storage approach, data size, consent, retention, and cost. Firestore can store metadata and references.

## 4. Data Flow

### Live Acquisition

```
1. BioAmp EXG Pill conditions the biopotential signal
2. ESP32 samples the analog output using a verified ADC configuration
3. ESP32 transmits timestamped samples and device metadata over BLE
4. Flutter validates and buffers samples
5. Flutter shows connection and signal-quality status
```

### AI Inference

```
1. Flutter forms a complete signal window using the agreed sample rate and duration
2. Flutter sends the window to the Python API over HTTPS
3. Python validates the request and runs preprocessing and inference
4. Python returns the prediction, model version, and status
5. Flutter displays the result and saves an appropriate summary to Firestore
```

### Historical Data

```
1. Flutter authenticates the user with Firebase
2. Flutter or a trusted backend writes user-authorized session summaries
3. Firestore Security Rules restrict access to the correct user
4. Flutter retrieves only the signed-in user's authorized history
```

**Security**: Do not allow the client to choose arbitrary user IDs and write data to another user's records. Use Firebase security rules and server-side token verification.

## 5. Suggested Flutter Screens

### 5.1 Onboarding / Authentication

**Components**:
- Welcome screen explaining the prototype
- Sign-in and registration if accounts are included
- Short consent and limitations notice
- No claims of medical diagnosis

**States**:
- Loading
- Not authenticated (show login/signup)
- Authenticated (redirect to home)

### 5.2 Home / Device Dashboard

**Components**:
- Device connection state
- Battery status (only if hardware reports reliable battery measurement)
- Sensor status
- Start/stop session control
- Current session duration
- Clear indication when data is missing or signal quality is poor

**States**:
- Disconnected
- Connecting
- Connected, no data
- Connected, receiving data
- Session active
- Error states

### 5.3 Live Monitoring

**Components**:
- Live EOG waveform with labeled axes and time scale
- Ambient-light reading from VEML7700, clearly labeled in lux if calibrated and verified
- Connection and sample-quality indicators

**Important Notes**:
- Do not show a fatigue prediction until a valid window has been processed
- Avoid smoothing or rescaling that could mislead the user about the underlying signal

**States**:
- Waiting for data
- Receiving data (show waveform)
- Poor signal quality
- Data interrupted
- Processing window

### 5.4 Fatigue Result

**Components**:
- Experimental model output
- Timestamp
- Optional confidence/probability (only if model supports meaningful and calibrated value)
- Short explanation that result is an estimate, not a diagnosis
- Clear unavailable/insufficient-data state

**States**:
- No prediction yet
- Prediction available
- Insufficient data
- Model unavailable
- Error

### 5.5 History / Reports

**Components**:
- Session list
- Session date and duration
- Summary of predictions
- Optional charts and export if approved by the team
- Empty state when no sessions exist
- Loading, offline, and error states

**States**:
- Loading
- Sessions available
- No sessions (empty state)
- Offline
- Error

### 5.6 Settings

**Components**:
- Account settings
- Device connection help
- Data/privacy information
- Sign out
- Data deletion option if supported by the final privacy design

## 6. UI and Interaction Principles

### Design Guidelines

- Mobile-first Android layout
- Clear hierarchy and readable typography
- High contrast for important values
- Use consistent spacing, colors, buttons, and status indicators
- Avoid decorative charts that imply unsupported precision
- Use plain language for technical and AI states
- Show connection/loading/error states explicitly

### Accessibility

- Do not use color alone to communicate fatigue or errors; include text labels
- Keep the live-monitoring screen focused on the signal and device status
- Make it clear when the app is disconnected, not sampling, or unable to reach the AI service

### Theme

**Note**: No final brand colors, logo, typography, or visual theme have been confirmed. Do not invent a fixed brand identity; propose a simple accessible design and ask the team to approve it.

## 7. Suggested Flutter Code Organization

```
flutter_app/
  lib/
    main.dart
    app.dart
    core/
      config/
        app_config.dart
        firebase_config.dart
      errors/
        exceptions.dart
        failures.dart
      theme/
        app_theme.dart
        colors.dart
        typography.dart
    features/
      authentication/
        data/
          auth_repository.dart
        domain/
          user_model.dart
        presentation/
          auth_page.dart
          auth_provider.dart
      device/
        data/
          ble_service.dart
        domain/
          device_model.dart
        presentation/
          device_page.dart
          device_provider.dart
      monitoring/
        data/
          signal_buffer.dart
        domain/
          signal_model.dart
        presentation/
          monitoring_page.dart
          monitoring_provider.dart
          waveform_painter.dart
      predictions/
        data/
          prediction_repository.dart
          ai_api_service.dart
        domain/
          prediction_model.dart
        presentation/
          prediction_page.dart
          prediction_provider.dart
      history/
        data/
          session_repository.dart
        domain/
          session_model.dart
        presentation/
          history_page.dart
          history_provider.dart
          session_detail_page.dart
      settings/
        presentation/
          settings_page.dart
    services/
      ble/
        ble_manager.dart
        ble_scanner.dart
      firebase/
        firebase_auth_service.dart
        firebase_firestore_service.dart
      ai_api/
        api_client.dart
        api_endpoints.dart
    models/
      prediction.dart
      session.dart
      signal_window.dart
      device.dart
    shared/
      widgets/
        loading_indicator.dart
        error_message.dart
        status_badge.dart
      utils/
        validators.dart
        formatters.dart
  test/
  pubspec.yaml
```

### Architecture Principles

- Use a maintainable architecture with clear separation between UI, application state, data models, and service integrations
- Select a state-management package only after the team agrees on one
- Do not add several competing state-management solutions

## 8. Suggested Python Service Organization

```
ai_backend/
  app/
    main.py              # FastAPI application entry point
    schemas.py           # Pydantic models for request/response
    auth.py              # Firebase token verification
    preprocessing.py     # Signal preprocessing pipeline
    features.py          # Feature extraction
    inference.py         # Model loading and prediction
  artifacts/
    model.pkl            # Trained model
    preprocessing-config.json
    README.md
  training/
    inspect_dataset.py
    train.py
    evaluate.py
  tests/
    test_preprocessing.py
    test_inference.py
    test_api.py
  requirements.txt
  Dockerfile
```

**Note**: Training experiments and dataset preparation should be kept separate from the deployed inference service.

## 9. API Design (Initial Proposal)

### Endpoints

#### Health Check
```http
GET /health
```
Returns service health status. Must not expose secrets.

**Response**:
```json
{
  "status": "healthy",
  "version": "1.0.0"
}
```

#### Prediction
```http
POST /v1/predict
```
Validates a signal window and returns an inference result.

**Request Headers**:
```
Authorization: Bearer <firebase_id_token>
Content-Type: application/json
```

**Request Body**:
```json
{
  "sample_rate_hz": 128,
  "unit": "adc_normalized",
  "window_duration_seconds": 10,
  "samples": [0.12, 0.15, 0.11, "..."],
  "window_start": "2026-11-11T15:30:00Z"
}
```

**Response**:
```json
{
  "prediction": "insufficient_evidence",
  "probabilities": null,
  "model_version": "not-yet-trained",
  "message": "Illustrative response only; replace after model validation."
}
```

#### Model Info (Optional)
```http
GET /v1/model
```
Returns model metadata if useful.

### API Constraints

- The API contract must specify sample rate, window length, channel, units, timestamps, and model version
- Avoid sending arbitrary unbounded arrays
- Add request-size and rate limits appropriate to the hosting platform

## 10. Data Design (Initial Proposal)

### Potential Firestore Collections

#### Users Collection
```
users/{uid}
  displayName: string
  createdAt: timestamp
  preferences: map
```

#### Sessions Collection
```
users/{uid}/sessions/{sessionId}
  startedAt: timestamp
  endedAt: timestamp
  deviceId: string
  status: string
  duration: number
  predictionCount: number
```

#### Predictions Collection
```
users/{uid}/sessions/{sessionId}/predictions/{predictionId}
  createdAt: timestamp
  label: string
  confidence: number (only if model provides calibrated value)
  modelVersion: string
  qualityStatus: string
  windowDuration: number
  sampleRate: number
```

### Design Notes

- These are conceptual fields, not a finalized schema
- Store only fields needed by the project
- Do not store confidence if the model does not provide a valid calibrated confidence measure
- Do not store raw signal arrays in Firestore without a documented reason and storage design

## 11. Error and Edge States

### Design and Test For

#### Bluetooth Errors
- Bluetooth permission denied
- ESP32 not found
- BLE connection lost
- BLE scan timeout

#### Sensor Errors
- No sensor samples received
- Poor/noisy signal
- Incomplete signal window
- Unsupported sampling rate

#### Network Errors
- Internet unavailable
- Python API unavailable or timeout
- API request failed

#### Firebase Errors
- Firebase authentication expired
- Firebase write rejected
- Firebase read failed

#### Model Errors
- Model not loaded
- Invalid prediction response
- Preprocessing failed

#### Data States
- No historical sessions
- Session in progress
- Session completed

### Error Handling Principles

- The app must not turn missing data or an API failure into a fatigue prediction
- All errors should be clearly communicated to the user
- Provide actionable guidance when possible
- Log errors appropriately for debugging

## 12. Accessibility, Privacy, and Safety

### Accessibility

- Use readable text and accessible contrast
- Provide labels in addition to colors
- Support system font size settings

### Privacy

- Request only necessary Android permissions
- Explain what sensor data is collected and why
- Protect account and session data
- Avoid unnecessary raw-signal retention
- Implement data deletion capability

### Safety

- Do not describe the prototype as a diagnostic or safety-certification system
- Include appropriate disclaimers
- Do not make claims about detecting medical conditions

## 13. Design Acceptance Criteria

The design is acceptable when:

1. A user can understand whether the ESP32 is connected
2. The app can show incoming signal data with clear units/time information
3. The app distinguishes live data from stored history
4. Prediction results show timestamp and model version where available
5. Missing data and service failures are clearly represented
6. A user can access only their own protected account data
7. All screens work on the target Android version

## 14. Technical Debt and Future Considerations

### Current Limitations

- No offline inference capability (requires internet for AI predictions)
- No raw signal storage design
- No model versioning strategy finalized
- No comprehensive error recovery mechanisms

### Future Enhancements (Out of Scope)

- On-device inference
- Raw signal storage and export
- Multiple EOG channels
- Advanced signal quality metrics
- Real-time feedback mechanisms
- Cross-platform support (iOS)

## 15. Implementation Priorities

### Priority 1: Core Functionality
1. Firebase authentication (already implemented)
2. BLE device connection
3. Live signal display
4. Basic session management

### Priority 2: AI Integration
1. Python API development
2. Signal preprocessing
3. Model inference integration
4. Prediction display

### Priority 3: Data Management
1. Session history
2. Firestore integration
3. Data export

### Priority 4: Polish
1. Error handling
2. UI refinement
3. Documentation
4. Testing

## 16. Testing Strategy

### Unit Tests
- Data models
- Utility functions
- Repository logic

### Widget Tests
- UI components
- Screen layouts
- User interactions

### Integration Tests
- BLE communication
- API calls
- Firebase operations

### End-to-End Tests
- Complete user flows
- System integration

### Hardware Tests
- Signal acquisition
- Power consumption
- Connection stability

## 17. Deployment Considerations

### Mobile App
- Android APK/AAB build
- Version numbering
- Release notes

### Python Service
- Docker containerization
- Cloud Run deployment
- Environment configuration
- Monitoring and logging

### Firebase
- Security rules
- Database indexes
- Backup strategy

## 18. Maintenance and Support

### Documentation Requirements
- Code comments for complex logic
- API documentation
- Setup instructions
- Troubleshooting guide

### Monitoring
- Error logging
- Performance metrics
- User feedback mechanism

### Updates
- Version control strategy
- Migration planning
- Backward compatibility
