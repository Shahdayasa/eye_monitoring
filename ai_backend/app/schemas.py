"""Request/response schemas for the EOG fatigue inference API."""

from __future__ import annotations

from datetime import datetime
from typing import List, Optional

from pydantic import BaseModel, Field, field_validator, model_validator


class PredictionRequest(BaseModel):
    sample_rate_hz: int = Field(..., gt=0, description="Actual sampling rate in Hz")
    samples: List[float] = Field(..., min_length=1, description="Ordered EOG samples")
    channel: str = Field(default="vertical_eog", min_length=1)
    unit: str = Field(default="adc_normalized", min_length=1)
    window_start: datetime
    window_duration_seconds: float = Field(..., gt=0)
    device_id: Optional[str] = Field(default=None)
    ambient_light_lux: Optional[float] = Field(default=None, ge=0)

    @field_validator("samples")
    @classmethod
    def validate_samples(cls, values: List[float]) -> List[float]:
        for i, v in enumerate(values):
            if v != v:  # NaN
                raise ValueError(f"samples[{i}] is NaN")
            if v in (float("inf"), float("-inf")):
                raise ValueError(f"samples[{i}] is infinite")
        return values

    @field_validator("sample_rate_hz")
    @classmethod
    def validate_sample_rate(cls, value: int) -> int:
        if value < 16 or value > 2048:
            raise ValueError("sample_rate_hz must be between 16 and 2048")
        return value

    @field_validator("window_duration_seconds")
    @classmethod
    def validate_window_duration(cls, value: float) -> float:
        if value < 1 or value > 120:
            raise ValueError("window_duration_seconds must be between 1 and 120")
        return value

    @model_validator(mode="after")
    def validate_window_size(self) -> "PredictionRequest":
        expected = int(round(self.sample_rate_hz * self.window_duration_seconds))
        if expected <= 0:
            raise ValueError("Invalid window configuration")
        # Allow small tolerance for device timing jitter.
        tolerance = max(2, int(expected * 0.05))
        if abs(len(self.samples) - expected) > tolerance:
            raise ValueError(
                f"samples length {len(self.samples)} does not match expected "
                f"{expected} for {self.sample_rate_hz}Hz over "
                f"{self.window_duration_seconds}s (±{tolerance})"
            )
        return self


class PredictionResponse(BaseModel):
    prediction: str
    probabilities: Optional[dict] = None
    model_version: str
    message: str
    quality_status: str = "unknown"
    features: Optional[dict] = None


class HealthResponse(BaseModel):
    status: str
    version: str
    model_loaded: bool
    model_version: str


class ModelInfoResponse(BaseModel):
    model_version: str
    model_loaded: bool
    expected_sample_rate_hz: Optional[int] = None
    expected_window_seconds: Optional[float] = None
    labels: Optional[List[str]] = None
    message: str


class ErrorResponse(BaseModel):
    detail: str
    code: str
