# Deployment Guide

## 1. Flutter App (Android)

### Prerequisites
- Flutter SDK (stable) and Android toolchain (`flutter doctor`)
- Firebase project configured (`android/app/google-services.json`, `lib/firebase_options.dart`)
- Correct `applicationId`/signing for release

### Configure
- Set API/base/env via dart-defines as needed:
  - `AI_API_BASE_URL` (default `http://10.0.2.2:8000`)
  - `APP_ENV` (`development|staging|production`)
  - `USE_MOCK_BLE` (`true` default in code; set `false` for real hardware)

### Build
```bash
cd eye_monitoring
flutter pub get
flutter build apk --release --dart-define=AI_API_BASE_URL=https://<api-host> --dart-define=USE_MOCK_BLE=false
# or App Bundle:
flutter build appbundle --release --dart-define=AI_API_BASE_URL=https://<api-host> --dart-define=USE_MOCK_BLE=false
```
Artifacts: `build/app/outputs/flutter-apk/app-release.apk`, `build/app/outputs/bundle/release/app-release.aab`.

### Release signing (production)
1. Create/upload keystore and configure `android/key.properties` + signing config in `android/app/build.gradle.kts`.
2. Replace debug signing used by default release config.
3. Update version in `pubspec.yaml` (`version: x.y.z+build`).

### Test release
- Install on physical device/emulator: `flutter install` or `adb install <apk>`.
- Verify auth, BLE (real device), monitoring, API calls, Firestore sync, and permissions.

## 2. Python AI Backend (FastAPI)

### Local
```bash
cd eye_monitoring/ai_backend
python -m venv .venv
source .venv/bin/activate  # Windows: .venv\Scripts\activate
pip install -r requirements.txt
export REQUIRE_AUTH=false
uvicorn app.main:app --host 0.0.0.0 --port 8000
```
Health: `GET /health`. Docs: `/docs`.

### Docker
```bash
cd eye_monitoring/ai_backend
docker build -t eog-ai-backend .
docker run --rm -p 8000:8000 \
  -e REQUIRE_AUTH=true \
  -e FIREBASE_CREDENTIALS=/secrets/service-account.json \
  -e CORS_ALLOW_ORIGINS=https://<app-or-web-origin> \
  -v /local/secrets:/secrets:ro \
  eog-ai-backend
```

### Environment variables
| Variable | Purpose | Default |
|---|---|---|
| `REQUIRE_AUTH` | Require Firebase bearer token | `true` (app logic) |
| `FIREBASE_CREDENTIALS` / `GOOGLE_APPLICATION_CREDENTIALS` | Service account for token verification | unset |
| `CORS_ALLOW_ORIGINS` | Comma-separated origins | `*` |
| (model paths/config) | As implemented in `app/inference.py`/artifacts | see code/artifacts |

### Hosting (example: Cloud Run/any container platform)
1. Build and push image to registry.
2. Deploy container exposing port 8000.
3. Set env vars and mount/provide Firebase credentials securely.
4. Configure HTTPS endpoint and update app `AI_API_BASE_URL`.
5. Validate `/health`, `/v1/model`, `/v1/predict` with valid auth.

## 3. Firebase

### Services used
- **Authentication:** Email/Password.
- **Cloud Firestore:** user profiles, sessions, predictions under `users/{uid}/...`.
- **(Storage rules present):** restrict `users/{uid}/**` to owner (if storage used).

### Deploy rules
```bash
# from eye_monitoring (with Firebase CLI configured)
firebase deploy --only firestore:rules
firebase deploy --only storage:rules   # if applicable
```
Rules files: `firestore.rules`, `storage.rules`. Verify project/aliases in `.firebaserc` or `firebase.json`.

### Indexes
- Create composite indexes in Firebase Console if queries require them (monitor Firestore error logs during testing).

### Production checks
- Confirm Auth providers and authorized domains.
- Review security rules against actual data paths (`users/{uid}/sessions/{sessionId}/predictions/{predictionId}`).
- Enable backups/exports and monitoring per academic/admin needs.

## 4. End-to-End Release Checklist
- [ ] Flutter release build signed and tested on target devices
- [ ] `AI_API_BASE_URL` points to deployed HTTPS API; `USE_MOCK_BLE=false` for hardware demos
- [ ] API deployed with auth configured and model artifacts (or documented fallback)
- [ ] Firebase rules deployed and access verified per-user
- [ ] Permissions (Bluetooth/Location) verified on Android versions used
- [ ] Known limitations communicated (prototype, not medical device)
