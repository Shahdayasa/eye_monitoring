"""Model loading and inference.

No trained/validated model artifact is shipped with this repository. This module
provides a safe runtime that can load a future artifact when available and
otherwise returns an explicit 'insufficient_evidence' result.
"""

from __future__ import annotations

import json
import os
import pickle
from dataclasses import dataclass, field
from typing import Any, Dict, List, Optional


@dataclass
class ModelMetadata:
    model_version: str = "not-yet-trained"
    model_loaded: bool = False
    expected_sample_rate_hz: Optional[int] = None
    expected_window_seconds: Optional[float] = None
    labels: Optional[List[str]] = None
    artifact_path: Optional[str] = None
    message: str = "No trained model artifact loaded"


class ModelManager:
    def __init__(self, artifacts_dir: Optional[str] = None):
        base = os.path.dirname(os.path.dirname(__file__))
        self.artifacts_dir = artifacts_dir or os.path.join(base, "artifacts")
        self.model: Any = None
        self.metadata = ModelMetadata()
        self.config: Dict[str, Any] = {}
        self.load_artifacts()

    def load_artifacts(self) -> None:
        cfg_path = os.path.join(self.artifacts_dir, "preprocessing-config.json")
        if os.path.exists(cfg_path):
            try:
                with open(cfg_path, "r", encoding="utf-8") as f:
                    self.config = json.load(f)
            except Exception:
                self.config = {}

        model_path = self.config.get("model_path") or os.path.join(
            self.artifacts_dir, "model.pkl"
        )
        if os.path.exists(model_path):
            try:
                with open(model_path, "rb") as f:
                    self.model = pickle.load(f)
                self.metadata = ModelMetadata(
                    model_version=str(self.config.get("model_version", "unknown")),
                    model_loaded=True,
                    expected_sample_rate_hz=self.config.get("sample_rate_hz"),
                    expected_window_seconds=self.config.get("window_duration_seconds"),
                    labels=self.config.get("labels"),
                    artifact_path=model_path,
                    message="Model artifact loaded",
                )
                return
            except Exception as e:
                self.model = None
                self.metadata = ModelMetadata(
                    model_version=str(self.config.get("model_version", "unavailable")),
                    model_loaded=False,
                    artifact_path=model_path,
                    message=f"Failed to load model artifact: {e}",
                )
                return

        self.model = None
        self.metadata = ModelMetadata(
            model_version=str(self.config.get("model_version", "not-yet-trained")),
            model_loaded=False,
            expected_sample_rate_hz=self.config.get("sample_rate_hz"),
            expected_window_seconds=self.config.get("window_duration_seconds"),
            labels=self.config.get("labels"),
            artifact_path=None,
            message="Model not yet trained; returning insufficient_evidence",
        )

    def info(self) -> Dict[str, Any]:
        return {
            "model_version": self.metadata.model_version,
            "model_loaded": self.metadata.model_loaded,
            "expected_sample_rate_hz": self.metadata.expected_sample_rate_hz,
            "expected_window_seconds": self.metadata.expected_window_seconds,
            "labels": self.metadata.labels,
            "message": self.metadata.message,
        }

    def predict(self, features: Dict[str, float], quality_status: str = "ok") -> Dict[str, Any]:
        # Never fabricate fatigue labels without a validated model + labels.
        if quality_status not in ("ok", "good", "excellent"):
            return {
                "prediction": "insufficient_evidence",
                "probabilities": None,
                "model_version": self.metadata.model_version,
                "message": f"Signal quality '{quality_status}' is insufficient for inference",
                "quality_status": quality_status,
            }

        if not self.metadata.model_loaded or self.model is None:
            return {
                "prediction": "insufficient_evidence",
                "probabilities": None,
                "model_version": self.metadata.model_version,
                "message": self.metadata.message,
                "quality_status": quality_status,
            }

        # Generic best-effort inference path for a future sklearn-like model.
        try:
            feature_names = self.config.get("feature_order")
            if feature_names:
                vector = [[features.get(name, 0.0) for name in feature_names]]
            else:
                vector = [[features[k] for k in sorted(features.keys())]]

            if hasattr(self.model, "predict_proba"):
                probs_arr = self.model.predict_proba(vector)[0]
                classes = getattr(self.model, "classes_", None)
                if classes is None:
                    classes = self.metadata.labels or [str(i) for i in range(len(probs_arr))]
                probabilities = {str(c): float(p) for c, p in zip(classes, probs_arr)}
                prediction = max(probabilities, key=probabilities.get)
                return {
                    "prediction": prediction,
                    "probabilities": probabilities,
                    "model_version": self.metadata.model_version,
                    "message": "Inference completed",
                    "quality_status": quality_status,
                }

            pred = self.model.predict(vector)[0]
            return {
                "prediction": str(pred),
                "probabilities": None,
                "model_version": self.metadata.model_version,
                "message": "Inference completed",
                "quality_status": quality_status,
            }
        except Exception as e:
            return {
                "prediction": "insufficient_evidence",
                "probabilities": None,
                "model_version": self.metadata.model_version,
                "message": f"Inference failed: {e}",
                "quality_status": quality_status,
            }


model_manager = ModelManager()
