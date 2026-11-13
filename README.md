# Eye Monitoring - AI-Based Wearable Eye Fatigue Detection System

An experimental wearable glasses-based prototype that uses electrooculography (EOG) signals to study eye-related patterns associated with fatigue.

> **Important**: This is an academic prototype and **not a medical device**. It must not be used for medical diagnosis or safety-critical decisions.

## System Components
- **Wearable hardware (target):** ESP32-WROOM-32, BioAmp EXG Pill (EOG), VEML7700 (ambient light), BLE
- **Mobile app:** Flutter (Android-focused) for auth, device connection, live monitoring, sessions, predictions, history, settings
- **AI backend:** Python FastAPI service for preprocessing/feature extraction/inference (`ai_backend/`)
- **Cloud:** Firebase Authentication and Cloud Firestore (per-user sessions/predictions)

## Documentation
- [Docs index](./docs/README.md)
- [User Manual](./docs/USER_MANUAL.md)
- [API Documentation](./docs/API.md)
- [Deployment Guide](./docs/DEPLOYMENT.md)
- [Firebase Security](./docs/FIREBASE_SECURITY.md)
- [Troubleshooting](./docs/TROUBLESHOOTING.md)
- [Known Limitations](./docs/KNOWN_LIMITATIONS.md)
- [Demo Script](./docs/DEMO_SCRIPT.md)
- [Presentation Outline](./docs/PRESENTATION.md)
- [Technical Design](./docs/DESIGN.md) · [Technical Reference](./docs/TECHNICAL.md) · [AI Guide](./docs/AI.md)
- [Wave Status](./docs/WAVE_STATUS.md) · [Wave Plans](./docs/waves/README.md)

## Repository Structure
```
eye_monitoring/
  lib/                 # Flutter app (features, core, services, shared, models)
  test/                # Flutter unit/widget tests
  ai_backend/          # FastAPI inference service, artifacts, tests, Dockerfile
  android/ ios/ web/   # Platform targets
  docs/                # Project and operational documentation
  firebase.json        # Firebase config
  firestore.rules      # Firestore security rules
  storage.rules        # Storage security rules
  pubspec.yaml         # Flutter dependencies
```

## Prerequisites
- Flutter SDK (stable, Dart `^3.13.7`) and Android toolchain (`flutter doctor`)
- Android device/emulator (recommended for BLE features)
- Firebase project (Auth + Firestore) configured for this app
- Python 3.10+ for AI backend (optional for UI-only/mock flows)

## Flutter App Setup & Run
```bash
git clone <repository-url>
cd eye_monitoring
flutter pub get
flutter devices
flutter run
```

### Configuration (dart-defines)
Defaults in `lib/core/config/app_config.dart`:
- `AI_API_BASE_URL` = `http://10.0.2.2:8000` (Android emulator → host)
- `APP_ENV` = `development`
- `USE_MOCK_BLE` = `true` (mock device/data for development)

Examples:
```bash
# Real hardware + deployed API
flutter run \
  --dart-define=USE_MOCK_BLE=false \
  --dart-define=AI_API_BASE_URL=https://<api-host> \
  --dart-define=APP_ENV=production
```

### Build (release)
```bash
flutter build apk --release --dart-define=AI_API_BASE_URL=https://<api-host> --dart-define=USE_MOCK_BLE=false
flutter build appbundle --release --dart-define=AI_API_BASE_URL=https://<api-host> --dart-define=USE_MOCK_BLE=false
```
> Release signing is required for production distribution (default Gradle config may use debug signing). See [Deployment Guide](./docs/DEPLOYMENT.md).

## AI Backend Setup & Run
```bash
cd ai_backend
python -m venv .venv
source .venv/bin/activate   # Windows: .venv\Scripts\activate
pip install -r requirements.txt
REQUIRE_AUTH=false uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```
- Health: `GET /health`, docs: `GET /docs`, model: `GET /v1/model`, predict: `POST /v1/predict`
- Docker: `docker build -t eog-ai-backend .` (see `ai_backend/README.md`, [API docs](./docs/API.md), [Deployment](./docs/DEPLOYMENT.md))

## Firebase
- Configure `android/app/google-services.json` and `lib/firebase_options.dart` for your project.
- Enable Email/Password Authentication and create Firestore database.
- Deploy/verify rules: `firestore.rules`, `storage.rules` (see [Firebase Security](./docs/FIREBASE_SECURITY.md)).

## Testing & Quality
```bash
flutter test
flutter test --coverage
flutter analyze
dart format .
```
Latest recorded run (2026-11-13, Wave 11): **111 Flutter tests passed** in dev environment. Integration/E2E, hardware, performance, and coverage targets may still be pending—see [Known Limitations](./docs/KNOWN_LIMITATIONS.md).

## Implemented (prototype scope)
- Firebase email/password auth, profile/setup flow, routed app shell/navigation
- BLE service abstraction with mock + FlutterBluePlus implementations, device UI/state
- Live EOG/light monitoring, buffering/parsing, signal quality indicators, session lifecycle & persistence
- AI API client/contracts, prediction UI/persistence integration points, history/settings/help/privacy flows
- Error/offline handling and logging foundations; expanded documentation and QA fixes

## Safety, Privacy & Limitations
- Research prototype only; outputs are not diagnostic.
- Collect minimal necessary data; protect credentials/tokens; use HTTPS and Firebase rules.
- Known gaps: real hardware/firmware validation, trained/calibrated model artifacts, live end-to-end deployment validation, multi-device/perf/coverage testing. Details: [Known Limitations](./docs/KNOWN_LIMITATIONS.md).

## License
Developed for academic purposes.
