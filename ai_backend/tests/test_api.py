import os

import pytest
from fastapi.testclient import TestClient

# Ensure auth is disabled for API tests.
os.environ["REQUIRE_AUTH"] = "false"

from app.main import app  # noqa: E402


client = TestClient(app)


def _valid_payload(n=1280, sample_rate=128, duration=10.0):
    # Simple synthetic signal; values illustrative only.
    samples = [0.2 + 0.05 * ((i % 20) - 10) / 10.0 for i in range(n)]
    return {
        "sample_rate_hz": sample_rate,
        "samples": samples,
        "channel": "vertical_eog",
        "unit": "adc_normalized",
        "window_start": "2026-11-11T15:30:00Z",
        "window_duration_seconds": duration,
        "device_id": "esp32-001",
    }


def test_health_check():
    response = client.get("/health")
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "healthy"
    assert "model_loaded" in data
    assert "model_version" in data


def test_root():
    response = client.get("/")
    assert response.status_code == 200
    assert response.json()["docs"] == "/docs"


def test_model_info():
    response = client.get("/v1/model")
    assert response.status_code == 200
    data = response.json()
    assert "model_loaded" in data
    assert "model_version" in data


def test_predict_valid_window():
    response = client.post("/v1/predict", json=_valid_payload())
    assert response.status_code == 200
    data = response.json()
    assert data["prediction"] == "insufficient_evidence"
    assert data["model_version"] == "not-yet-trained"
    assert data["quality_status"] in ("ok", "good", "excellent", "poor", "unusable", "unknown")
    assert "features" in data and isinstance(data["features"], dict)


def test_predict_rejects_nan_samples():
    payload = _valid_payload(n=128)
    payload["window_duration_seconds"] = 1.0
    payload["samples"][10] = float("nan")
    response = client.post("/v1/predict", json=payload)
    assert response.status_code == 422


def test_predict_rejects_wrong_window_size():
    payload = _valid_payload(n=100)  # should be ~1280
    response = client.post("/v1/predict", json=payload)
    assert response.status_code == 422


def test_predict_rejects_invalid_sample_rate():
    payload = _valid_payload(n=10, sample_rate=0, duration=10.0)
    response = client.post("/v1/predict", json=payload)
    assert response.status_code == 422


def test_predict_rejects_unsupported_unit():
    payload = _valid_payload(n=128, sample_rate=128, duration=1.0)
    payload["unit"] = "unknown_unit"
    response = client.post("/v1/predict", json=payload)
    assert response.status_code == 422


def test_predict_rejects_missing_samples():
    payload = _valid_payload()
    del payload["samples"]
    response = client.post("/v1/predict", json=payload)
    assert response.status_code == 422


def test_auth_required_when_enabled(monkeypatch):
    monkeypatch.setenv("REQUIRE_AUTH", "true")
    # Re-import style not needed; dependency reads env per-request.
    response = client.post("/v1/predict", json=_valid_payload())
    assert response.status_code == 401
    # restore for any subsequent tests in same process
    monkeypatch.setenv("REQUIRE_AUTH", "false")
