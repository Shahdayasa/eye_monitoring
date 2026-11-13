# Demo Script - EOG Eye Monitoring Prototype

> **Duration target:** 5–8 minutes. Emphasize prototype/experimental status (not a medical device).

## Setup (before demo)
- [ ] Android device/emulator ready; app installed (debug or release).
- [ ] Firebase configured and test account available (or already signed in).
- [ ] Mode chosen:
  - **Mock BLE demo:** `USE_MOCK_BLE=true`, app can show simulated connection/data flow.
  - **Hardware demo:** ESP32 device powered, paired path known, `USE_MOCK_BLE=false`, correct `AI_API_BASE_URL`.
- [ ] AI backend reachable (`/health` OK) with expected artifacts/config **or** prepared to explain `insufficient_evidence` fallback.
- [ ] Network available if showing cloud history/predictions.

## Script

### 1. Intro (30s)
- "This is an academic prototype that explores EOG-based fatigue pattern estimation using a wearable glasses concept, Flutter app, BLE data path, and a Python inference API."
- State limitation: **not a medical device**.

### 2. Authentication & Navigation (45s)
- Launch app → show splash/login as applicable → sign in.
- Briefly show bottom navigation: Home, Device, Monitor, Results, History, Settings.

### 3. Device Connection (60–90s)
- Open **Device** → **Scan** → select/connect device (or show mock connected state).
- Point out connection/status indicators and reconnect/error handling if relevant.

### 4. Live Monitoring & Session (90s)
- Open **Monitor**: show live waveform, ambient light, signal quality/buffer indicators.
- Start a session, let data accumulate briefly, explain window/quality requirements.
- Stop session (mention interruption handling if disconnect occurs).

### 5. AI Prediction (60s)
- Open **Results/Predictions**: trigger/view prediction for available window.
- Explain fields: label/estimate, confidence/probabilities, quality/model info, disclaimer.
- If fallback: explain `insufficient_evidence` when model/data not ready (expected prototype behavior).

### 6. History & Details (45s)
- Open **History** → select a session → show metadata, summary, prediction trend/list (if present).
- Mention cloud sync dependency (Firestore/auth).

### 7. Settings, Privacy & Robustness (30–45s)
- Open **Settings**: account info, preferences, device help, data/privacy, delete-data option, app version/env.
- Mention offline banner/error/retry behavior if time permits.

### 8. Close (30s)
- Summarize pipeline: sensor → BLE → app → (optional cloud) API inference → storage/history.
- Reiterate known limitations and future work (hardware validation, model training, deployment hardening).

## Backup Plan
- If hardware/BLE fails: switch to mock BLE and explain real-device integration status.
- If API unavailable: show UI states/error handling and `/health` expectation; use cached/history views if possible.
- If Firebase unavailable: demonstrate local UI/flows that do not require network and explain sync limitations.
- Keep screenshots or a short recorded clip as contingency for unstable live conditions.
