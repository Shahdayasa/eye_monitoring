# Presentation Materials (Outline)

## Suggested Slide Deck (10–12 slides)

1. **Title**
   - Project: AI-Based Wearable Eye Fatigue Detection System (EOG)
   - Team, supervisor/course, date
   - Disclaimer: academic prototype, **not a medical device**

2. **Problem & Motivation**
   - Fatigue awareness challenges; why EOG/wearable exploration matters
   - Scope: engineering prototype and evaluation, not clinical diagnosis

3. **Objectives & Requirements**
   - Hardware acquisition, mobile visualization, AI inference, cloud/session storage
   - Key functional goals and constraints

4. **System Architecture**
   - ESP32 + BioAmp EXG Pill + VEML7700 → BLE → Flutter app
   - Firebase (Auth/Firestore) and Python FastAPI inference service
   - High-level data flow diagram

5. **Hardware & Signal Acquisition**
   - Components, electrode placement concept, sampling/windowing assumptions
   - Ambient light context (VEML7700)
   - Verification/safety considerations (high level)

6. **Mobile Application (Flutter)**
   - Core screens: Device, Monitor, Results, History, Settings
   - Live visualization, session management, error/offline handling
   - Tech: Provider, go_router, flutter_blue_plus, fl_chart, Firebase

7. **AI Backend & Pipeline**
   - FastAPI endpoints (`/health`, `/v1/model`, `/v1/predict`)
   - Preprocessing → features → inference; request/response contract
   - Auth, validation, fallback behavior (`insufficient_evidence`)

8. **Data, Security & Privacy**
   - Firestore structure (`users/{uid}/sessions/.../predictions`)
   - Security rules (owner-only access), token verification concept
   - Prototype privacy considerations and data deletion option

9. **Testing & Quality**
   - Unit/widget testing results (current suite pass count/date)
   - Bug fixes/refactoring highlights; known gaps (integration, hardware, performance, coverage)

10. **Demo / Results**
   - Screenshots or live demo flow (connect → monitor → predict → history)
   - Example outputs and interpretation cautions

11. **Limitations & Challenges**
   - Hardware/firmware maturity, signal quality, model validation, environment dependencies
   - Deployment/testing constraints (devices, live services)

12. **Conclusion & Future Work**
   - What was achieved end-to-end
   - Next steps: hardware validation, model training/calibration, integration/perf testing, deployment hardening
   - Q&A

## Assets to Prepare
- Architecture and data-flow diagrams (export from design docs if available)
- App screenshots (Device, Monitor, Results, History, Settings)
- Sample API request/response and `/health` output
- Short demo video backup
- Test summary evidence (`flutter test` result)
- References/citations as required by course
