"""Feature extraction for EOG windows."""

from __future__ import annotations

from typing import Dict

import numpy as np


def _safe_std(signal: np.ndarray) -> float:
    return float(np.std(signal)) if signal.size else 0.0


def _zero_crossings(signal: np.ndarray) -> int:
    if signal.size < 2:
        return 0
    centered = signal - float(np.mean(signal))
    signs = np.sign(centered)
    return int(np.sum(np.diff(signs) != 0))


def _band_power(freqs: np.ndarray, psd: np.ndarray, low: float, high: float) -> float:
    mask = (freqs >= low) & (freqs < high)
    if not np.any(mask):
        return 0.0
    trapz = getattr(np, "trapezoid", None) or np.trapz
    return float(trapz(psd[mask], freqs[mask]))


def extract_features(signal: np.ndarray, sample_rate_hz: int) -> Dict[str, float]:
    if signal.size == 0:
        raise ValueError("signal must not be empty")
    if sample_rate_hz <= 0:
        raise ValueError("sample_rate_hz must be > 0")

    sig = np.asarray(signal, dtype=np.float64)
    mean = float(np.mean(sig))
    std = _safe_std(sig)
    rms = float(np.sqrt(np.mean(sig ** 2)))
    abs_mean = float(np.mean(np.abs(sig)))

    features: Dict[str, float] = {
        "mean": mean,
        "std": std,
        "variance": float(np.var(sig)),
        "min": float(np.min(sig)),
        "max": float(np.max(sig)),
        "range": float(np.max(sig) - np.min(sig)),
        "median": float(np.median(sig)),
        "rms": rms,
        "abs_mean": abs_mean,
        "zero_crossings": float(_zero_crossings(sig)),
        "sample_count": float(sig.size),
    }

    # Frequency-domain features (best-effort, informative only).
    if sig.size >= 8:
        window = np.hanning(sig.size)
        windowed = sig * window
        fft = np.fft.rfft(windowed)
        psd = (np.abs(fft) ** 2) / max(sig.size, 1)
        freqs = np.fft.rfftfreq(sig.size, d=1.0 / sample_rate_hz)
        trapz = getattr(np, "trapezoid", None) or np.trapz
        total_power = float(trapz(psd, freqs)) if freqs.size > 1 else 0.0
        peak_idx = int(np.argmax(psd)) if psd.size else 0
        features.update(
            {
                "total_power": total_power,
                "peak_frequency_hz": float(freqs[peak_idx]) if freqs.size else 0.0,
                "band_0_5_4hz_power": _band_power(freqs, psd, 0.5, 4.0),
                "band_4_8hz_power": _band_power(freqs, psd, 4.0, 8.0),
                "band_8_15hz_power": _band_power(freqs, psd, 8.0, 15.0),
            }
        )
        if total_power > 0:
            features["band_0_5_4hz_ratio"] = features["band_0_5_4hz_power"] / total_power
            features["band_4_8hz_ratio"] = features["band_4_8hz_power"] / total_power
            features["band_8_15hz_ratio"] = features["band_8_15hz_power"] / total_power
    return features
