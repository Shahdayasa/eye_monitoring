# AI Engineering Guide --- EOG Wearable Fatigue Detection

> Project working title: **AI-Based Wearable Eye Fatigue Detection System**  
> Status: Initial project specification. Confirm unresolved items with the student team before implementing them.

## 1. Purpose

This document guides AI coding assistants and developers working on the AI/ML part of the senior project. The system is an experimental wearable EOG-based fatigue-monitoring prototype. It collects eye-related biopotential signals, processes them, and estimates a fatigue-related state for presentation in a Flutter mobile application.

The system is an academic prototype, **not a medical device**. It must not claim to diagnose a disease, determine a person's medical fitness, or provide clinically validated conclusions.

## 2. AI Component Responsibilities

The AI component is responsible for:

1. Accepting a correctly structured EOG signal window.
2. Validating that the input is complete and has the expected sampling rate, units, channel arrangement, and duration.
3. Applying the exact preprocessing used during model training.
4. Extracting the required features, if the selected model uses engineered features.
5. Running the trained model.
6. Returning a prediction with relevant metadata, such as model version and confidence/probability when meaningful.
7. Recording enough information to reproduce and evaluate a prediction.

The AI component must not be responsible for Bluetooth communication, Flutter UI rendering, Firebase login screens, or hardware power management.

## 3. Current Hardware and Signal Context

Known project components:

- **ESP32-WROOM-32** microcontroller.
- **BioAmp EXG Pill** biopotential front-end, selected for EOG acquisition.
- **VEML7700** ambient-light sensor.
- Wearable glasses form factor.
- Rechargeable lithium battery and power circuitry.

### Signal Specifications

The BioAmp EXG Pill is a one-channel analog biopotential front-end. The project has discussed vertical EOG electrode placement, with electrodes above and below the eye and a reference electrode near the mastoid/behind the ear.

**Important**: Confirm the final electrode arrangement against the module documentation, supervisor guidance, and safe-use instructions before testing.

The intended EOG analysis band discussed by the team is approximately **0.5--15 Hz**. Do not assume this is the final hardware filter response or sampling configuration. Verify the actual acquisition chain and record:
- Final sampling rate
- ADC resolution
- Gain settings
- Filter characteristics
- Voltage range
- Units

The VEML7700 measures ambient light. Treat light level as contextual information, not as a direct fatigue label or a substitute for EOG evidence.

## 4. Data Contract

Before training or integrating the model, define and document a stable input contract. At minimum, each signal window should specify:

| Field | Description | Required |
|-------|-------------|----------|
| `sample_rate_hz` | Actual sampling rate | Yes |
| `samples` | Ordered numeric EOG samples | Yes |
| `channel` | Channel identity and electrode configuration | Yes |
| `unit` | Voltage unit or calibrated representation | Yes |
| `window_start` | Timestamp, preferably ISO 8601 UTC | Yes |
| `window_duration_seconds` | Duration of the signal window | Yes |
| `device_id` | Pseudonymous device identifier | Optional |
| `ambient_light_lux` | VEML7700 reading | Optional |

### Validation Rules

Do not silently accept:
- Missing samples
- NaN/Infinity values
- Unexpected sample rates
- Wrong units
- Incorrectly sized windows

Return a clear validation error for any invalid input.

### Example Request Schema

```json
{
  "sample_rate_hz": 128,
  "unit": "adc_normalized",
  "window_duration_seconds": 10,
  "samples": [0.12, 0.15, 0.11, 0.08, "..."],
  "window_start": "2026-11-11T15:30:00Z",
  "device_id": "esp32-001",
  "channel": "vertical_eog"
}
```

**Note**: Sample values are illustrative only. Do not treat them as actual sensor calibration or a complete model input.

## 5. Dataset and Labeling Rules

### Dataset Management

- Keep the original dataset unchanged and read-only.
- Record the dataset source, license/usage conditions, collection protocol, participant count, and available labels.
- Determine what each label actually means.

### Label Integrity

**Critical**: Do not rename or interchange these concepts:
- Alertness
- Sleepiness
- Cognitive workload
- Fatigue

If the dataset is unlabeled, do not invent ground-truth fatigue labels. Discuss a defensible labeling or exploratory-analysis plan with the supervisor.

### Data Structure Verification

- Check whether each row is a sample, feature, window, or participant-level record.
- Identify participant IDs and session IDs before splitting data.

### Data Splitting

- Prefer **subject-independent evaluation** (e.g., leave-subjects-out or GroupKFold) when multiple windows come from the same participants.
- Avoid placing windows from the same person/session in both train and test sets to prevent data leakage.

### Preprocessing

- Fit normalization, scaling, feature selection, and other learned preprocessing **only on the training data**.
- Apply the fitted transformation to validation/test data.
- Keep a final untouched test set where the dataset size allows.

### Reporting

- Report class balance and per-class performance.
- **Accuracy alone is insufficient** for imbalanced data.
- Report: precision, recall, F1-score, confusion matrix.

## 6. Model Development Workflow

1. **Inspect and document the dataset**
   - Verify data types, ranges, and structure
   - Identify missing values or anomalies

2. **Define the prediction target and labels**
   - Clarify what the model should predict
   - Document label definitions

3. **Establish a simple baseline**
   - Use a basic model (e.g., logistic regression, random classifier)
   - Establish minimum performance threshold

4. **Build a reproducible preprocessing pipeline**
   - Document all transformations
   - Use version control for preprocessing code

5. **Compare suitable models**
   - Consider data size and signal characteristics
   - Evaluate: classical classifiers (SVM, Random Forest, Gradient Boosting) and neural networks (only when justified)

6. **Tune using training/validation data only**
   - Use cross-validation
   - Avoid information leakage

7. **Evaluate once on held-out test data**
   - Final performance assessment
   - Document all metrics

8. **Save the model and preprocessing artifacts together**
   - Model file
   - Preprocessing configuration
   - Feature list
   - Metadata

9. **Record model metadata**
   - Model version
   - Training date
   - Dataset version
   - Feature list
   - Sampling rate
   - Evaluation metrics

10. **Test inference on real signals**
    - Use signals from the actual ESP32/BioAmp acquisition chain
    - Verify preprocessing consistency

### Potential Methods to Evaluate

- Signal filtering (bandpass, notch)
- Blink/event detection
- Time-domain features (mean, variance, RMS, zero-crossings)
- Frequency-domain features (PSD, band power)
- Classical classifiers: logistic regression, SVM, random forest, gradient boosting
- Neural networks (only when justified by dataset size and evidence)

## 7. Training vs. Inference

**Training is an offline development activity. It should not happen whenever the mobile app opens.**

### Separation of Concerns

- Training scripts and experiments belong in `ai_backend/training/`
- Selected trained model and preprocessing artifacts belong in `ai_backend/artifacts/`
- Inference code loads saved artifacts and predicts on new signal windows

### Rules

- Never retrain automatically using unverified user data.
- Do not overwrite a known-good model without evaluation and versioning.

### Suggested Layout

```
ai_backend/
  app/
    main.py              # FastAPI application
    schemas.py           # Request/response schemas
    preprocessing.py     # Signal preprocessing
    features.py          # Feature extraction
    inference.py         # Model loading and prediction
  training/
    inspect_dataset.py   # Dataset exploration
    train.py             # Training scripts
    evaluate.py          # Model evaluation
  artifacts/
    README.md            # Model documentation
    model.pkl            # Trained model (actual extension varies)
    preprocessing-config.json
  tests/
    test_preprocessing.py
    test_inference.py
  requirements.txt
  README.md
```

Use the real model file extension appropriate to the chosen library (e.g., `.pkl`, `.h5`, `.onnx`). Do not create placeholder model files that look production-ready.

## 8. Prediction API

### Deployment Recommendation

The initial recommended deployment approach is a **Python API (FastAPI)** deployed separately from Firebase, such as on **Google Cloud Run**.

**Rationale**:
- Firebase handles authentication and application data
- Python service handles model inference
- Clear separation of concerns
- Independent scaling

### API Specification

#### Health Check
```
GET /health
```
Returns service status without exposing secrets.

#### Prediction Endpoint
```
POST /v1/predict
```

**Request**: Validated EOG window with required metadata.

**Response**: 
- Predicted class
- Optional calibrated probabilities
- Model version
- Processing status

**Error Responses**:
- Invalid input
- Unsupported sampling rate
- Insufficient samples
- Unavailable model
- Internal processing error

### Example Response

```json
{
  "prediction": "insufficient_evidence",
  "probabilities": null,
  "model_version": "not-yet-trained",
  "message": "Illustrative response only; replace after model validation."
}
```

**Important**: Do not hard-code `High`, `Medium`, or `Low` fatigue categories until the dataset labels and model design support those categories. A model confidence score is not automatically a clinically meaningful probability.

### Authentication

The service must verify Firebase Authentication ID tokens before accepting private user requests. **Never embed Firebase Admin service-account credentials in the Flutter application.**

## 9. Safety, Privacy, and User Messaging

### Safety Messaging

- Describe outputs as **experimental estimates**, not diagnoses.
- Do not tell users they are safe to drive, operate machinery, or perform safety-critical tasks based on this prototype.
- Avoid alarming language.
- Provide appropriate limitation notices.

### Privacy

- Collect only data needed for the project.
- Use pseudonymous identifiers where possible.
- Protect transport with HTTPS.
- Apply Firebase Security Rules and server-side authorization.
- Do not log raw EOG samples or personal information unnecessarily.
- Define retention and deletion behavior with the team and supervisor.

### Compliance

- Obtain appropriate consent and institutional approval before collecting human-subject data.
- Document all data handling procedures.

## 10. Testing Requirements

Test independently:

- Dataset parsing and label mapping
- Signal validation
- Filtering and preprocessing
- Feature extraction
- Model loading
- Prediction output schema
- Invalid and incomplete windows
- API authentication and authorization
- Inference latency under realistic window sizes
- Predictions using signals captured from the actual hardware

### Critical Verification

For the full system, verify that the sampling rate and preprocessing in deployment match training. **A model tested only on a public dataset is not automatically validated for the team's hardware.**

## 11. Instructions for AI Coding Assistants

When modifying this project:

1. **Read this file and the other project documents before coding.**
2. Do not invent dataset labels, sensor specifications, model accuracy, hardware calibration, or completed features.
3. Preserve a clear separation between Flutter, ESP32 firmware, Python inference, and Firebase.
4. Ask before changing the agreed architecture or adding paid services.
5. Explain the purpose of new packages and avoid unnecessary dependencies.
6. Keep training code separate from inference code.
7. Add tests for preprocessing and prediction behavior.
8. Never claim the model is accurate or clinically validated without measured evidence.
9. Do not place secrets, private keys, service-account files, or API credentials in Git.
10. Update documentation when the data contract, model, API, or deployment changes.

## 12. Open Decisions

The team must still confirm:

- [ ] Dataset and exact fatigue/alertness labels
- [ ] Sampling rate and ADC calibration
- [ ] Final EOG electrode configuration
- [ ] Window duration and overlap
- [ ] Model type and feature pipeline
- [ ] Whether VEML7700 readings are used by the model or only displayed/stored as context
- [ ] Whether inference must work offline
- [ ] Final prediction categories and evaluation thresholds
- [ ] Hosting provider and deployment cost

## 13. Implementation Checklist

Before deployment:

- [ ] Dataset inspected and documented
- [ ] Labels verified and understood
- [ ] Baseline model established
- [ ] Preprocessing pipeline reproducible
- [ ] Model evaluated on held-out test set
- [ ] Model artifacts saved with metadata
- [ ] Inference tested on real hardware signals
- [ ] API endpoints implemented and tested
- [ ] Authentication integrated
- [ ] Error handling implemented
- [ ] Documentation complete

## 14. Key Principles

1. **Reproducibility**: Every prediction should be reproducible given the same input and model version.
2. **Transparency**: Document all assumptions, preprocessing steps, and limitations.
3. **Safety**: Never present experimental results as medical diagnoses.
4. **Validation**: Test on real data from the actual hardware, not just public datasets.
5. **Separation**: Keep training, inference, and application layers separate.
