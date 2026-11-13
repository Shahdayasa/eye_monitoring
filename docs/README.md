# Eye Monitoring Project Documentation

> **AI-Based Wearable Eye Fatigue Detection System**  
> Senior Project Documentation Index

## Project Overview

This is an experimental wearable glasses-based system that uses electrooculography (EOG) signals to study eye-related patterns associated with fatigue. The system consists of:

- **Hardware**: ESP32 microcontroller, BioAmp EXG Pill for EOG acquisition, VEML7700 ambient light sensor
- **Mobile App**: Flutter Android application for device control, data visualization, and result display
- **AI Service**: Python FastAPI backend for signal preprocessing and fatigue pattern inference
- **Backend**: Firebase for authentication and data storage

**Important**: This is an academic prototype and **not a medical device**.

## Documentation Files

### Core Documentation

| Document | Purpose | Audience |
|----------|---------|----------|
| [BUSINESS.md](./BUSINESS.md) | Business requirements, project objectives, success criteria | Team, supervisor, evaluators |
| [DESIGN.md](./DESIGN.md) | Technical architecture, system design, code organization | Developers, AI assistants |
| [AI.md](./AI.md) | AI/ML pipeline, model development, data contracts | AI developers, data scientists |
| [WAVE.md](./WAVE.md) | Signal processing, EOG characteristics, waveform visualization | Signal processing developers |
| [TECHNICAL.md](./TECHNICAL.md) | Complete technical documentation, setup guide, API reference | Developers, DevOps |
| [WAVE_STATUS.md](./WAVE_STATUS.md) | Wave progress tracker | Project management, team |
| [WAVE_PLANS.md](./waves/README.md) | Project wave breakdown, development phases, task tracking | Project management, team |

### Operational & User Documentation (Wave 12)

| Document | Purpose |
|----------|---------|
| [USER_MANUAL.md](./USER_MANUAL.md) | End-user guide for app flows and prototype usage |
| [API.md](./API.md) | AI backend endpoint contract (`/health`, `/v1/model`, `/v1/predict`) |
| [DEPLOYMENT.md](./DEPLOYMENT.md) | Flutter, FastAPI/Docker, and Firebase deployment steps |
| [FIREBASE_SECURITY.md](./FIREBASE_SECURITY.md) | Firestore/Storage rules, data paths, and verification |
| [TROUBLESHOOTING.md](./TROUBLESHOOTING.md) | Common build, BLE, API, and Firebase issues |
| [KNOWN_LIMITATIONS.md](./KNOWN_LIMITATIONS.md) | Prototype, hardware, model, testing, and deployment limitations |
| [DEMO_SCRIPT.md](./DEMO_SCRIPT.md) | Step-by-step demo flow and backup plan |
| [PRESENTATION.md](./PRESENTATION.md) | Presentation outline and asset checklist |

### Quick Start Guide

#### For Running the Flutter App

1. **Open project in VS Code**
   - File → Open Folder → Select project directory

2. **Check dependencies**
   ```bash
   flutter pub get
   ```

3. **Run on emulator or device**
   ```bash
   # List available devices
   flutter devices
   
   # Run on specific device
   flutter run -d <device_id>
   
   # Run on Chrome (web)
   flutter run -d chrome
   ```

4. **Press F5 in VS Code** to start debugging

#### For Development

1. **Read the documentation**
   - Start with [BUSINESS.md](./BUSINESS.md) for project context
   - Review [DESIGN.md](./DESIGN.md) for architecture
   - Check [AI.md](./AI.md) for ML pipeline
   - See [WAVE.md](./WAVE.md) for signal processing

2. **Follow the code structure**
   - `lib/` - Flutter application code
   - `test/` - Unit and widget tests
   - `ai_backend/` - Python AI service (to be created)

3. **Testing**
   ```bash
   # Run all tests
   flutter test
   
   # Run with coverage
   flutter test --coverage
   ```

## Project Structure

```
eye_monitoring/
├── lib/                          # Flutter application
│   ├── main.dart                 # App entry point
│   ├── firebase_options.dart     # Firebase configuration
│   └── (features to be added)
├── test/                         # Flutter tests
│   └── widget_test.dart
├── docs/                         # Documentation
│   ├── README.md                 # This file
│   ├── BUSINESS.md               # Business requirements
│   ├── DESIGN.md                 # Technical design
│   ├── AI.md                     # AI/ML guide
│   ├── WAVE.md                   # Signal processing guide
│   ├── TECHNICAL.md              # Technical documentation
│   ├── WAVE_STATUS.md            # Wave progress tracker
│   └── waves/                    # Wave plan files
│       ├── README.md             # Wave plans index
│       ├── WAVE_00_SETUP.md
│       ├── WAVE_01_AUTHENTICATION.md
│       ├── WAVE_02_UI_FRAMEWORK.md
│       ├── WAVE_03_BLE_CONNECTION.md
│       ├── WAVE_04_SIGNAL_VISUALIZATION.md
│       ├── WAVE_05_SESSION_MANAGEMENT.md
│       ├── WAVE_06_PYTHON_BACKEND.md
│       ├── WAVE_07_AI_INTEGRATION.md
│       ├── WAVE_08_HISTORY_REPORTS.md
│       ├── WAVE_09_SETTINGS.md
│       ├── WAVE_10_ERROR_HANDLING.md
│       ├── WAVE_11_TESTING.md
│       └── WAVE_12_DOCUMENTATION.md
├── android/                      # Android-specific code
├── ios/                          # iOS-specific code (not in scope)
├── web/                          # Web-specific code
├── ai_backend/                   # Python AI service (to be created)
│   ├── app/                      # FastAPI application
│   ├── training/                 # Model training scripts
│   ├── artifacts/                # Trained models
│   └── tests/                    # Python tests
├── pubspec.yaml                  # Flutter dependencies
└── README.md                     # Project README
```

## Current Status

### Implemented
- ✅ Basic Flutter app structure
- ✅ Firebase Authentication integration
- ✅ Login/Signup screens
- ✅ Basic home screen

### To Be Implemented
- ⏳ BLE device connection
- ⏳ Live EOG signal display
- ⏳ Signal processing pipeline
- ⏳ AI model integration
- ⏳ Session management
- ⏳ History/reports screens
- ⏳ Python AI service
- ⏳ Hardware integration

## Team Roles

### Suggested Split (Adjust as needed)

**Student A - Mobile & Backend**
- Flutter screens and UI
- App state management
- Firebase integration
- API client implementation

**Student B - Hardware & AI**
- ESP32 firmware
- Sensor acquisition
- BLE communication
- AI model development

**Shared Responsibilities**
- System integration
- Testing
- Documentation
- API contract definition

## Key Technologies

| Layer | Technology | Purpose |
|-------|-----------|---------|
| Mobile | Flutter/Dart | Android application |
| Backend | Firebase | Authentication & data storage |
| AI Service | Python/FastAPI | Model inference |
| Hardware | ESP32 | Microcontroller |
| Sensors | BioAmp EXG Pill | EOG acquisition |
| Sensors | VEML7700 | Ambient light |
| Communication | BLE | Device to phone |

## Important Notes

### Safety & Compliance
- This is an **academic prototype**, not a medical device
- Do not claim fatigue diagnosis capability
- Do not use for safety-critical decisions
- Obtain proper approvals for human testing

### Data Privacy
- Collect only necessary data
- Protect user credentials
- Use Firebase Security Rules
- Implement proper access controls

### Testing
- Test all components individually
- Verify signal quality before analysis
- Document all test results
- Report failures honestly

## Getting Help

### Documentation
- Read the relevant documentation file for your task
- Check code comments for implementation details
- Review test files for usage examples

### Development
- Ask your teammate first
- Consult your supervisor for academic questions
- Check manufacturer documentation for hardware
- Review framework documentation (Flutter, Firebase, etc.)

### Common Issues

**Flutter won't run**
- Run `flutter doctor` to check setup
- Ensure all dependencies are installed
- Check emulator/device is available

**Firebase errors**
- Verify `firebase_options.dart` configuration
- Check Firebase console for project setup
- Ensure authentication is enabled

**BLE connection issues**
- Verify permissions in AndroidManifest.xml
- Check device is discoverable
- Ensure proper BLE service/characteristic UUIDs

**Signal quality problems**
- Check electrode connections
- Verify BioAmp power supply
- Review grounding and shielding
- Test with known signal source

## Version History

- **v1.0.0** (2026-11-11): Initial documentation created
- Basic Flutter app with Firebase authentication

## Contact

For project-related questions, contact your project partner or supervisor.

For technical issues, consult the relevant documentation or framework guides.

---

**Last Updated**: November 11, 2026
