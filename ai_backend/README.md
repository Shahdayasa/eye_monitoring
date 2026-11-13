# EOG Fatigue Detection AI Backend

FastAPI inference service for the experimental EOG wearable fatigue detection prototype.
This is **not a medical device** and must not be presented as clinically validated.

## Endpoints

- `GET /health` — service status and model load state
- `GET /v1/model` — model/artifact metadata
- `POST /v1/predict` — run preprocessing + feature extraction + inference on an EOG window

## Request contract (`POST /v1/predict`)

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

## Auth

- Firebase ID token required by default: `Authorization: Bearer <token>`.
- Set `REQUIRE_AUTH=false` for local development only.
- Configure credentials via `FIREBASE_CREDENTIALS` or `GOOGLE_APPLICATION_CREDENTIALS` when auth is enabled.

## Run locally

```bash
python -m venv .venv
source .venv/bin/activate  # Windows: .venv\\Scripts\\activate
pip install -r requirements.txt
REQUIRE_AUTH=false uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

## Tests

```bash
REQUIRE_AUTH=false pytest
```

## Docker

```bash
docker build -t eog-ai-backend .
docker run --rm -p 8000:8000 -e REQUIRE_AUTH=false eog-ai-backend
```

## Model artifacts

Place optional artifacts in `artifacts/` (see `artifacts/README.md`). Without a trained
model the API returns `prediction="insufficient_evidence"` with explanatory metadata.
