# Model Artifacts

This directory holds runtime artifacts for inference (kept separate from training code/data).

Expected optional files (when a validated model exists):
- `model.pkl` — serialized model compatible with the inference loader
- `preprocessing-config.json` — preprocessing/metadata config, e.g.:
  - `model_version`, `model_path`, `sample_rate_hz`, `window_duration_seconds`
  - `labels`, `feature_order`, filter/normalization parameters used in training

No trained or clinically validated model is included. The API must report
`insufficient_evidence` until artifacts are produced and evaluated per `docs/AI.md`.
