from app.features import extract_features
from app.inference import ModelManager
from app.preprocessing import preprocess_signal


def test_feature_extraction_returns_expected_keys():
    samples = [0.1 * (i % 7) for i in range(256)]
    processed = preprocess_signal(samples, 128)
    features = extract_features(processed, 128)
    for key in ["mean", "std", "variance", "min", "max", "rms", "zero_crossings", "sample_count"]:
        assert key in features
    assert features["sample_count"] == 256.0


def test_feature_extraction_rejects_invalid_input():
    try:
        extract_features([], 128)
        assert False, "expected ValueError"
    except ValueError:
        pass
    try:
        extract_features([0.1, 0.2], 0)
        assert False, "expected ValueError"
    except ValueError:
        pass


def test_model_manager_without_artifact_returns_insufficient_evidence():
    manager = ModelManager(artifacts_dir="/nonexistent-artifacts-dir")
    info = manager.info()
    assert info["model_loaded"] is False
    assert info["model_version"] == "not-yet-trained"

    features = {"mean": 0.0, "std": 1.0, "rms": 1.0}
    result = manager.predict(features, quality_status="ok")
    assert result["prediction"] == "insufficient_evidence"
    assert result["probabilities"] is None
    assert "model_version" in result


def test_model_manager_rejects_poor_quality():
    manager = ModelManager(artifacts_dir="/nonexistent-artifacts-dir")
    result = manager.predict({"mean": 0.0}, quality_status="poor")
    assert result["prediction"] == "insufficient_evidence"
    assert "quality" in result["message"].lower()
