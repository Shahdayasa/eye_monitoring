# Known Limitations

## Prototype & Safety
- **Not a medical device.** Outputs are experimental and not clinically validated; do not use for diagnosis, treatment, or safety-critical decisions (e.g., driving/operating machinery).
- Model performance, calibration, and generalization are unproven on broad populations and conditions.
- Fatigue labels/ground truth (if any) and dataset representativeness may be limited in an academic setting.

## Hardware & Signal
- Real-world validation with the target ESP32 + BioAmp EXG Pill + VEML7700 hardware/firmware may be incomplete; BLE UUIDs, packet format, and sampling characteristics must match the final device.
- EOG signal quality is sensitive to electrode placement, skin contact, motion artifacts, and electrical noise.
- Battery reporting/long-session endurance and comfort/wearability are hardware-dependent and may not be fully characterized.

## AI & Inference
- Backend may run without trained artifacts and return `insufficient_evidence` (by design fallback).
- Predictions depend on window configuration (default 128 Hz, 10 s) and preprocessing/feature pipeline alignment between training and inference.
- Network latency/availability affect cloud inference; no guaranteed real-time or offline on-device model unless separately implemented.

## Mobile App & Data
- Some flows require Firebase project configuration, deployed rules, and internet connectivity (auth sync, history, cloud-backed operations).
- Firestore/index/rule configuration must match queries and deployment environment; emulator vs production behavior may differ.
- Android-focused; iOS/web not validated as release targets unless explicitly tested.
- BLE behavior varies by Android version/device permissions and OEM power management.

## Testing & Deployment
- Automated suite: Flutter unit/widget tests pass in the current dev environment, but **coverage metrics, integration/E2E tests, multi-device/emulator matrix, performance/memory profiling, and live Firebase/API/hardware tests** may be pending.
- Release signing, store distribution, backend production hardening/monitoring, and scalability are outside prototype scope unless completed separately.
- Security hardening is prototype-level; do not treat as production-compliant without further review.

## Documentation & Operations
- API/model contracts and hardware specifics may evolve; keep docs synchronized with firmware and model artifacts.
- Demo results depend on environment (mock BLE vs real device, backend/model availability).
