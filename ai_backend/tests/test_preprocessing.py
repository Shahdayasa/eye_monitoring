import numpy as np
import pytest

from app.preprocessing import (
    PreprocessConfig,
    PreprocessingError,
    assess_quality,
    preprocess_signal,
    remove_dc_offset,
    validate_signal,
)


def test_remove_dc_offset_centers_signal():
    signal = np.array([1.0, 2.0, 3.0, 4.0])
    centered = remove_dc_offset(signal)
    assert abs(float(np.mean(centered))) < 1e-9


def test_validate_signal_rejects_empty_and_nan():
    with pytest.raises(PreprocessingError):
        validate_signal([], 128)
    with pytest.raises(PreprocessingError):
        validate_signal([0.1, float("nan")], 128)
    with pytest.raises(PreprocessingError):
        validate_signal([0.1, 0.2], 0)


def test_preprocess_signal_returns_finite_normalized_output():
    samples = [float(i % 10) for i in range(1280)]
    out = preprocess_signal(samples, 128, PreprocessConfig(normalize=True))
    assert out.shape == (1280,)
    assert np.all(np.isfinite(out))
    assert abs(float(np.mean(out))) < 1e-6
    assert abs(float(np.std(out)) - 1.0) < 1e-3


def test_preprocess_without_normalization_preserves_scale_centered():
    samples = [1.0, 2.0, 3.0, 4.0] * 40
    out = preprocess_signal(samples, 128, PreprocessConfig(normalize=False))
    assert out.shape == (160,)
    assert np.all(np.isfinite(out))


def test_assess_quality_basic():
    assert assess_quality(np.array([])) == "unusable"
    assert assess_quality(np.zeros(100)) == "poor"
    assert assess_quality(np.linspace(-1, 1, 256)) == "ok"
