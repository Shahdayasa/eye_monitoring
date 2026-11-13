# AI Backend API Documentation

Base URL (default dev, Android emulator): `http://10.0.2.2:8000`  
Configured in app via `AI_API_BASE_URL` (`lib/core/config/app_config.dart`).  
Interactive docs when running: `GET /docs` (Swagger UI).

> Experimental prototype API. **Not a medical device.**

## Authentication
- **Default:** Firebase ID token required: `Authorization: Bearer <token>`.
- **Local dev bypass:** set `REQUIRE_AUTH=false` (server). When auth enabled, configure `FIREBASE_CREDENTIALS` or `GOOGLE_APPLICATION_CREDENTIALS`.
- `401` with error detail when token missing/invalid and auth required.

## Endpoints

### `GET /`
Service info.
```json
{ "message": "EOG Fatigue Detection API", "version": "1.0.0", "docs": "/docs", "note": "Experimental prototype; not a medical device." }
```

### `GET /health`
**Response 200**
```json
{ "status": "healthy", "version": "1.0.0", "model_loaded": false, "model_version": "none" }
```

### `GET /v1/model`
Model/artifact metadata.
```json
{
  "model_version": "none",
  "model_loaded": false,
  "expected_sample_rate_hz": 128,
  "expected_window_seconds": 10.0,
  "labels": ["alert", "fatigued"],
  "message": "..."
}
```
(`expected_*`/`labels` depend on loaded artifacts.)

### `POST /v1/predict`
Run preprocessing + feature extraction + inference for one EOG window.

**Request**
```json
{
  "sample_rate_hz": 128,
  "samples": [0.12, 0.15, 0.11],
  "channel": "vertical_eog",
  "unit": "adc_normalized",
  "window_start": "2026-11-11T15:30:00Z",
  "window_duration_seconds": 10,
  "device_id": "esp32-001",
  "ambient_light_lux": 120.5
}
```

**Validation rules (server)**
- `sample_rate_hz`: 16–2048
- `samples`: non-empty, no NaN/Inf
- `window_duration_seconds`: 1–120
- `samples` length must match `sample_rate_hz * window_duration_seconds` within ~5% (min 2 samples) tolerance
- `unit`: one of `adc_normalized`, `adc_raw`, `volts`, `millivolts`
- If model artifacts specify expected rate/window, request must match

**Response 200**
```json
{
  "prediction": "insufficient_evidence",
  "probabilities": { "alert": 0.5, "fatigued": 0.5 },
  "model_version": "none",
  "message": "Model artifact not loaded; returning insufficient evidence.",
  "quality_status": "unknown",
  "features": { }
}
```
Fields like `probabilities`/`features` may be null/omitted depending on model/quality.

**Errors**
- `401`: missing/invalid auth token (`{"detail":"..."}`)
- `422`: invalid signal/window/contract or preprocessing failure (`{"detail":"...","code":"invalid_signal"}` or HTTP detail)

## Example (curl)
```bash
curl -X POST http://localhost:8000/v1/predict \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <FIREBASE_ID_TOKEN>" \
  -d '{
    "sample_rate_hz": 128,
    "samples": [/* 1280 values */],
    "channel": "vertical_eog",
    "unit": "adc_normalized",
    "window_start": "2026-11-13T10:00:00Z",
    "window_duration_seconds": 10,
    "device_id": "esp32-001",
    "ambient_light_lux": 120.5
  }'
```

## App Integration Notes
- Flutter client: `lib/services/ai_api/api_client.dart`, repository/provider in `lib/features/predictions/`.
- Default app contract: 128 Hz, 10s windows (`AppConfig.sampleRateHz`, `AppConfig.windowDurationSeconds`).
- Ensure backend expected rate/window/artifacts align with app/config; mismatches return 422.
