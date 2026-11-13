"""Signal preprocessing for EOG inference.

Pipeline is deterministic and must match the configuration used for training
when a trained model/artifacts are available. Current implementation provides a
safe baseline (validation, detrend/DC removal, optional bandpass, normalization)
without inventing dataset-specific calibration.
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import Iterable, List

import numpy as np

try:
    from scipy.signal import butter, filtfilt
except Exception:  # pragma: no cover - optional dependency fallback
    butter = None
    filtfilt = None


@dataclass
class PreprocessConfig:
    bandpass_low_hz: float = 0.5
    bandpass_high_hz: float = 15.0
    filter_order: int = 4
    normalize: bool = True


class PreprocessingError(ValueError):
    """Raised when signal preprocessing/validation fails."""


def validate_signal(samples: Iterable[float], sample_rate_hz: int) -> np.ndarray:
    if sample_rate_hz <= 0:
        raise PreprocessingError("sample_rate_hz must be > 0")

    signal = np.asarray(list(samples), dtype=np.float64)
    if signal.size == 0:
        raise PreprocessingError("samples must not be empty")
    if not np.all(np.isfinite(signal)):
        raise PreprocessingError("samples contain NaN or infinite values")
    return signal


def remove_dc_offset(signal: np.ndarray) -> np.ndarray:
    return signal - float(np.mean(signal))


def bandpass_filter(
    signal: np.ndarray,
    sample_rate_hz: int,
    low_hz: float,
    high_hz: float,
    order: int,
) -> np.ndarray:
    nyq = 0.5 * sample_rate_hz
    if high_hz >= nyq:
        high_hz = max(low_hz + 0.1, nyq * 0.99)
    if low_hz <= 0 or high_hz <= low_hz:
        raise PreprocessingError("Invalid bandpass cutoff frequencies")

    if butter is None or filtfilt is None:
        # Fallback: detrended signal only if scipy is unavailable.
        return signal

    b, a = butter(order, [low_hz / nyq, high_hz / nyq], btype="band")
    padlen = 3 * max(len(a), len(b))
    if signal.size <= padlen:
        return signal
    return filtfilt(b, a, signal)


def normalize_signal(signal: np.ndarray) -> np.ndarray:
    std = float(np.std(signal))
    if std < 1e-12:
        return np.zeros_like(signal)
    return (signal - float(np.mean(signal))) / std


def assess_quality(signal: np.ndarray) -> str:
    if signal.size == 0:
        return "unusable"
    std = float(np.std(signal))
    ptp = float(np.ptp(signal))
    if not np.all(np.isfinite(signal)):
        return "unusable"
    if std < 1e-9:
        return "poor"
    if ptp > 1e6:
        return "unusable"
    if ptp > 1e4:
        return "poor"
    return "ok"


def preprocess_signal(
    samples: List[float],
    sample_rate_hz: int,
    config: PreprocessConfig | None = None,
) -> np.ndarray:
    cfg = config or PreprocessConfig()
    signal = validate_signal(samples, sample_rate_hz)
    signal = remove_dc_offset(signal)
    signal = bandpass_filter(
        signal,
        sample_rate_hz,
        cfg.bandpass_low_hz,
        cfg.bandpass_high_hz,
        cfg.filter_order,
    )
    if cfg.normalize:
        signal = normalize_signal(signal)
    return signal.astype(np.float64)
