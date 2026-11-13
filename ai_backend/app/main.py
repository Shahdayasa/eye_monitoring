"""FastAPI application for EOG fatigue inference."""

from __future__ import annotations

import os

from fastapi import Depends, FastAPI, Header, HTTPException, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse

from .auth import auth_required, verify_bearer_token
from .features import extract_features
from .inference import model_manager
from .preprocessing import PreprocessingError, assess_quality, preprocess_signal
from .schemas import (
    ErrorResponse,
    HealthResponse,
    ModelInfoResponse,
    PredictionRequest,
    PredictionResponse,
)

API_VERSION = "1.0.0"

app = FastAPI(
    title="EOG Fatigue Detection API",
    version=API_VERSION,
    description=(
        "Experimental inference service for EOG-based fatigue estimation. "
        "Not a medical device."
    ),
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=os.getenv("CORS_ALLOW_ORIGINS", "*").split(","),
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.exception_handler(PreprocessingError)
async def preprocessing_error_handler(_: Request, exc: PreprocessingError):
    return JSONResponse(
        status_code=422,
        content=ErrorResponse(detail=str(exc), code="invalid_signal").model_dump(),
    )


def require_auth(authorization: str | None = Header(default=None)) -> str | None:
    if not auth_required():
        return None
    try:
        return verify_bearer_token(authorization)
    except ValueError as e:
        raise HTTPException(status_code=401, detail=str(e))


@app.get("/health", response_model=HealthResponse)
async def health_check() -> HealthResponse:
    info = model_manager.info()
    return HealthResponse(
        status="healthy",
        version=API_VERSION,
        model_loaded=bool(info["model_loaded"]),
        model_version=str(info["model_version"]),
    )


@app.get("/v1/model", response_model=ModelInfoResponse)
async def model_info() -> ModelInfoResponse:
    info = model_manager.info()
    return ModelInfoResponse(**info)


@app.post(
    "/v1/predict",
    response_model=PredictionResponse,
    responses={
        401: {"model": ErrorResponse},
        422: {"model": ErrorResponse},
    },
)
async def predict(
    request: PredictionRequest,
    _: str | None = Depends(require_auth),
) -> PredictionResponse:
    # Basic contract enforcement beyond schema-level validation.
    if request.unit not in {"adc_normalized", "adc_raw", "volts", "millivolts"}:
        raise HTTPException(
            status_code=422,
            detail="Unsupported unit; expected one of adc_normalized, adc_raw, volts, millivolts",
        )

    expected_meta = model_manager.info()
    exp_rate = expected_meta.get("expected_sample_rate_hz")
    exp_win = expected_meta.get("expected_window_seconds")
    if exp_rate and int(exp_rate) != request.sample_rate_hz:
        raise HTTPException(
            status_code=422,
            detail=f"sample_rate_hz {request.sample_rate_hz} does not match model expectation {exp_rate}",
        )
    if exp_win and abs(float(exp_win) - float(request.window_duration_seconds)) > 1e-6:
        raise HTTPException(
            status_code=422,
            detail=(
                f"window_duration_seconds {request.window_duration_seconds} does not "
                f"match model expectation {exp_win}"
            ),
        )

    try:
        processed = preprocess_signal(request.samples, request.sample_rate_hz)
    except PreprocessingError as e:
        raise HTTPException(status_code=422, detail=str(e))

    quality = assess_quality(processed)
    features = extract_features(processed, request.sample_rate_hz)
    result = model_manager.predict(features, quality_status=quality)
    result["features"] = features
    return PredictionResponse(**result)


@app.get("/")
async def root():
    return {
        "message": "EOG Fatigue Detection API",
        "version": API_VERSION,
        "docs": "/docs",
        "note": "Experimental prototype; not a medical device.",
    }
