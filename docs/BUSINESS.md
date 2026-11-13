# Business and Product Requirements --- EOG Wearable Fatigue Detection

> Project working title: **AI-Based Wearable Eye Fatigue Detection System**  
> Audience: senior-project team, supervisor, evaluators, and AI coding assistants.

## 1. Executive Summary

The project aims to develop an experimental wearable glasses-based system that uses electrooculography (EOG) signals to study eye-related patterns associated with fatigue. 

### System Components

- **ESP32** and **BioAmp EXG Pill** acquire the signal
- **VEML7700** measures ambient light as contextual information
- **Flutter Android application** presents device status, live readings, and AI-generated estimates
- **Firebase** is the proposed managed backend for user authentication and application data
- **Python AI service** for signal preprocessing and model inference

**Important**: This is an academic prototype and must not be marketed or described as a clinically validated medical device.

## 2. Problem Statement

Fatigue can affect attention and performance, but users may not recognize changes in their own state. The project explores whether wearable EOG measurements and a trained machine-learning model can identify patterns associated with fatigue and communicate experimental estimates to a user through a mobile application.

The project must demonstrate a complete engineering pipeline:
1. Sensing
2. Signal acquisition
3. Data processing
4. Model development
5. Mobile integration
6. Systematic testing

## 3. Project Objectives

1. Design and assemble a wearable glasses prototype.
2. Acquire EOG signals using the selected analog front-end and ESP32.
3. Measure ambient light using the VEML7700.
4. Collect, inspect, and prepare a suitable EOG dataset.
5. Develop and evaluate an AI model using defensible labels and validation.
6. Integrate the model with the mobile application.
7. Build an Android application using Flutter.
8. Use Firebase for agreed account and data-storage features.
9. Test individual hardware components and the integrated system.
10. Document results, limitations, and future improvements.

## 4. Target Users and Stakeholders

### Primary User

A person participating in a demonstration or evaluation of the wearable prototype.

### Project Team

The two student developers responsible for hardware, firmware, AI, mobile application, integration, documentation, and testing.

### Supervisor and Evaluators

Academic stakeholders who assess engineering methodology, evidence, safety, performance, and project outcomes.

**Note**: Do not assume a commercial customer, clinical user, hospital deployment, or regulatory approval.

## 5. Value Proposition

The prototype aims to demonstrate:

- Wearable EOG acquisition in a glasses form factor
- A complete hardware-to-mobile data path
- AI-based analysis of EOG windows
- Understandable visualization of signals and experimental results
- Historical session summaries where cloud storage is enabled
- Measurable component-level and system-level performance

**Project Value**: Engineering demonstration and evaluation, not a claim that fatigue can be diagnosed reliably in every person or situation.

## 6. Scope

### In Scope

- ESP32-based acquisition
- BioAmp EXG Pill integration for EOG
- VEML7700 ambient-light measurement
- BLE or another agreed communication method between ESP32 and phone
- Flutter Android application
- Python-based AI model development and inference
- Firebase Authentication and Firestore if required by the final feature set
- Signal visualization and prediction display
- Session summaries and history if implemented
- Testing, evaluation, and ABET-aligned reporting

### Out of Scope (Unless Explicitly Approved)

- Medical diagnosis or treatment recommendations
- Clinical certification or regulatory approval
- Claims of safe driving or safe operation of machinery
- Emergency medical monitoring
- Guaranteed fatigue detection across all users
- Continuous cloud storage of all raw sensor samples without a justified data plan
- iOS release unless the team adds it to scope
- Complex admin dashboards or commercial subscription features

## 7. Functional Requirements

### FR-01: Device Connection

**Requirement**: The app shall allow the user to connect to the ESP32 using the communication method selected by the team. It shall display connection status.

**Acceptance Criteria**:
- User can initiate device scan
- Available devices are listed
- Connection status is clearly displayed
- Connection/disconnection events are handled

### FR-02: Sensor Acquisition

**Requirement**: The ESP32 shall acquire EOG samples using the verified BioAmp/ADC configuration and read ambient-light measurements from the VEML7700.

**Acceptance Criteria**:
- EOG samples are acquired at documented sampling rate
- VEML7700 readings are obtained
- Data is transmitted to mobile app
- Sampling configuration is verified and documented

### FR-03: Live Monitoring

**Requirement**: The app shall display incoming EOG data in a time-based graph and indicate when data is missing or invalid.

**Acceptance Criteria**:
- Real-time EOG waveform is displayed
- Graph has labeled axes and time scale
- Missing data is clearly indicated
- Invalid data states are shown

### FR-04: AI Inference

**Requirement**: The system shall submit valid signal windows to the selected inference runtime and receive a structured result.

**Acceptance Criteria**:
- Signal windows are formed correctly
- Requests are sent to AI service
- Responses are received and parsed
- Errors are handled gracefully

### FR-05: Result Presentation

**Requirement**: The app shall display the model's output with a timestamp and a clear experimental-use limitation.

**Acceptance Criteria**:
- Prediction result is displayed
- Timestamp is shown
- Experimental-use notice is visible
- Unavailable states are handled

### FR-06: Authentication

**Requirement**: If accounts are included, users shall be able to register, sign in, and sign out through Firebase Authentication.

**Acceptance Criteria**:
- User registration works
- User login works
- User logout works
- Authentication state is maintained
- Errors are handled

### FR-07: History

**Requirement**: Authenticated users shall be able to view their own saved session summaries and predictions.

**Acceptance Criteria**:
- Session list is displayed
- Session details are accessible
- Only user's own data is shown
- Empty state is handled
- Loading and error states are shown

### FR-08: Data Protection

**Requirement**: The system shall prevent one user from accessing another user's private records.

**Acceptance Criteria**:
- Firebase Security Rules enforce access control
- User A cannot access User B's data
- Server-side token verification is implemented

### FR-09: Error Handling

**Requirement**: The app shall clearly report device disconnection, invalid data, network failure, unavailable inference service, and storage errors.

**Acceptance Criteria**:
- All error states are detected
- Clear error messages are displayed
- User can take corrective action
- Errors are logged appropriately

### FR-10: Session Control

**Requirement**: The user shall be able to start and stop a monitoring session, subject to the final hardware and software design.

**Acceptance Criteria**:
- Start session button works
- Stop session button works
- Session state is tracked
- Session data is saved

## 8. Non-Functional Requirements

### Reliability
- Invalid or incomplete sensor data must not produce a normal prediction.
- System should handle edge cases gracefully.

### Performance
- Measure and report acquisition rate
- Measure and report inference latency
- Measure and report UI responsiveness
- Set numeric targets after team and supervisor agreement

### Security
- Use HTTPS for remote API calls
- Protect Firebase credentials
- Apply security rules
- Never embed service account credentials in client

### Privacy
- Collect only necessary data
- Define retention/deletion behavior
- Use pseudonymous identifiers
- Document data handling procedures

### Maintainability
- Separate Flutter, firmware, AI, and Firebase responsibilities
- Use clear code organization
- Document decisions and architecture

### Reproducibility
- Record model version
- Record preprocessing configuration
- Record dataset version
- Record test conditions

### Usability
- Show clear connection states
- Show clear sampling states
- Show clear prediction states
- Use readable typography and contrast

### Portability
- Document supported Android version requirements
- Document device requirements

### Safety
- Verify power, wiring, electrode use, and electrical limits before human testing
- Follow manufacturer guidelines
- Document safety procedures

## 9. Data and AI Requirements

### Dataset Requirements
- Use a dataset with documented source and usage permission
- Establish what the labels represent before defining fatigue classes
- Do not invent labels for an unlabeled dataset

### Model Development
- Avoid data leakage between training and test sets, especially across participant sessions
- Report suitable metrics: per-class precision, recall, F1-score, confusion matrix, and class balance where applicable
- Test the model on signals from the actual prototype
- Record limitations and any mismatch between public dataset signals and the team's hardware

## 10. Technology Decisions (Proposed)

| Area | Proposed Technology | Reason |
|------|---------------------|--------|
| Mobile app | Flutter / Dart | Android application |
| IDE | VS Code and/or Android Studio | Both support the same Flutter project |
| Microcontroller | ESP32-WROOM-32 | Hardware controller |
| EOG front-end | BioAmp EXG Pill | Selected biopotential acquisition module |
| Light sensor | VEML7700 | Ambient-light context |
| AI development | Python | Dataset processing and model training |
| AI API | FastAPI | Expose Python inference to Flutter |
| Managed backend | Firebase | Authentication and application data |
| Database | Cloud Firestore | User/session metadata and predictions |
| AI hosting | Cloud Run or another Python host | Run the inference service |
| Version control | Git/GitHub | Team collaboration |
| Containers | Docker (optional) | Reproducible Python service environment |

**Note**: These are proposed choices based on current discussion, not proof that every component is already configured or deployed.

## 11. Success Criteria

The project can be considered successfully demonstrated when the team can show evidence that:

1. The EOG acquisition circuit produces measurable signals under the documented test setup.
2. The ESP32 reliably samples and transmits data at the documented configuration.
3. The VEML7700 returns plausible light readings under controlled conditions.
4. Flutter connects to the device and displays incoming data.
5. The AI pipeline runs reproducibly on valid input.
6. Model evaluation uses a defensible test methodology.
7. The mobile app receives and displays an inference response.
8. Firebase features, if included, store and retrieve only authorized data.
9. Component tests and end-to-end tests are documented.
10. Limitations and failures are reported honestly.

**Important**: Do not define success as achieving a particular accuracy until the dataset, labels, and evaluation protocol are known and approved.

## 12. Risks and Mitigations

| Risk | Mitigation |
|------|------------|
| Dataset does not contain fatigue labels | Inspect labels early; agree on a valid labeling strategy |
| Public dataset differs from hardware signal | Test with real prototype recordings |
| Electrical noise or unstable electrodes | Test acquisition, grounding, electrode placement, and filtering |
| Sampling rate mismatch | Record and validate sample rate end to end |
| BLE packet loss | Use sequence numbers/timestamps and detect missing samples |
| AI API needs internet | Decide offline requirements and communicate unavailable states |
| Cloud cost or service limits | Estimate usage and use quotas/budgets |
| Sensitive signal data exposure | Minimize collection, use access controls, and define retention |
| Model overfitting | Use subject-aware splitting and held-out evaluation |

## 13. Team Collaboration

### Repository

Both students should work from one shared Git repository. They may use different IDEs.

### Agreements Needed

- Flutter/Dart versions
- Package versions
- Folder conventions
- API contracts
- Branch/merge practices

### Suggested Responsibility Split

**Student A**: 
- Flutter screens
- App state
- Firebase integration

**Student B**: 
- ESP32 firmware
- Sensor acquisition
- BLE integration

**Shared**: 
- AI model
- Data analysis
- API integration
- System testing
- Documentation

**Note**: The split is a starting suggestion, not a fixed assignment.

## 14. Academic Reporting

For the ABET-oriented testing/results chapter, include:

### Component-Level Testing
- Test objective
- Setup
- Procedure
- Measured results
- Pass/fail criteria

### AI Testing
- Dataset description
- Evaluation methodology
- Results and metrics

### Hardware Testing
- Acquisition measurements
- Communication measurements

### Integration Testing
- Mobile/API/Firebase integration tests
- Full-system scenarios

### Documentation
- Limitations
- Unexpected results
- Corrective actions

**Critical**: Never fabricate measurements or report a test as passed without recorded evidence.

## 15. Deliverables

### Documentation
- Business requirements document (this file)
- Technical design document
- AI engineering guide
- Wave/signal processing documentation
- User manual
- Testing report

### Software
- Flutter mobile application
- ESP32 firmware
- Python AI service
- Database schema

### Hardware
- Assembled wearable prototype
- Circuit diagrams
- Bill of materials

### Testing
- Component test results
- Integration test results
- System test results
- Performance metrics

## 16. Timeline Considerations

### Phase 1: Foundation
- Hardware assembly and verification
- Dataset acquisition and inspection
- Basic Flutter app structure
- Firebase setup

### Phase 2: Integration
- BLE communication
- Live data display
- Basic AI model training
- API development

### Phase 3: Completion
- Full system integration
- Comprehensive testing
- Documentation
- Presentation preparation

## 17. Key Principles

1. **Safety First**: Never present the prototype as a medical device or safety system.
2. **Evidence-Based**: Document all claims with measurable evidence.
3. **Transparency**: Report limitations and failures honestly.
4. **Separation of Concerns**: Keep hardware, firmware, AI, and mobile layers distinct.
5. **Reproducibility**: Ensure all results can be reproduced.
6. **User-Centered**: Design for clarity and usability.
