# Technical Documentation - EOG Wearable Fatigue Detection System

> **Project**: AI-Based Wearable Eye Fatigue Detection System  
> **Version**: 1.0.0  
> **Last Updated**: 2026-11-11  
> **Status**: Academic Prototype - Not a Medical Device

---

## Table of Contents

1. [System Overview](#1-system-overview)
2. [Architecture](#2-architecture)
3. [Technology Stack](#3-technology-stack)
4. [Flutter Application Structure](#4-flutter-application-structure)
5. [Firebase Configuration](#5-firebase-configuration)
6. [BLE Communication Protocol](#6-ble-communication-protocol)
7. [AI Service Integration](#7-ai-service-integration)
8. [Data Models](#8-data-models)
9. [Security Considerations](#9-security-considerations)
10. [Setup Instructions](#10-setup-instructions)
11. [Testing Guide](#11-testing-guide)
12. [Deployment Guide](#12-deployment-guide)
13. [Troubleshooting](#13-troubleshooting)

---

## 1. System Overview

The system consists of four main components:

1. **Wearable Hardware**: ESP32 + BioAmp EXG Pill + VEML7700
2. **Mobile Application**: Flutter Android app
3. **AI Backend**: Python FastAPI service
4. **Cloud Services**: Firebase (Auth, Firestore)

### Data Flow

```
[ESP32 + Sensors]
      ↓ (BLE)
[Flutter App] ←→ [Firebase Auth]
      ↓               ↓
[Firestore]    [Python AI API]
                      ↓
              [Model Inference]
```

---

## 2. Architecture

### 2.1 Layered Architecture

The Flutter application follows a clean architecture pattern:

```
┌─────────────────────────────────────┐
│         Presentation Layer          │
│    (Screens, Widgets, Providers)    │
├─────────────────────────────────────┤
│         Domain Layer                │
│    (Models, Business Logic)         │
├─────────────────────────────────────┤
│         Data Layer                  │
│  (Repositories, Services, APIs)     │
├─────────────────────────────────────┤
│         Infrastructure Layer        │
│    (Firebase, BLE, HTTP Client)     │
└─────────────────────────────────────┘
```

### 2.2 Key Principles

- **Separation of Concerns**: Each layer has distinct responsibilities
- **Dependency Rule**: Outer layers depend on inner layers, not vice versa
- **Testability**: Business logic is independent of UI and external services
- **Maintainability**: Clear boundaries make code easier to modify

---

## 3. Technology Stack

### 3.1 Mobile Application

| Component | Technology | Version | Purpose |
|-----------|-----------|---------|---------|
| Framework | Flutter | Latest stable | Cross-platform UI |
| Language | Dart | ^3.13.7 | Application logic |
| State Management | Provider/Riverpod | TBD | State management |
| BLE | flutter_blue_plus | Latest | Bluetooth communication |
| Charts | fl_chart | Latest | Data visualization |
| Firebase Core | firebase_core | ^5.1.0 | Firebase integration |
| Firebase Auth | firebase_auth | ^7.0.1 | Authentication |
| Cloud Firestore | cloud_firestore | Latest | Data storage |

### 3.2 Backend Services

| Component | Technology | Purpose |
|-----------|-----------|---------|
| AI API | FastAPI (Python) | Model inference |
| Authentication | Firebase Auth | User management |
| Database | Cloud Firestore | Session/prediction storage |
| Hosting | Google Cloud Run | AI service deployment |

### 3.3 Hardware

| Component | Model | Purpose |
|-----------|-------|---------|
| Microcontroller | ESP32-WROOM-32 | BLE controller |
| EOG Sensor | BioAmp EXG Pill | Biopotential acquisition |
| Light Sensor | VEML7700 | Ambient light measurement |
| Power | LiPo battery + charging circuit | Portable power |

---

## 4. Flutter Application Structure

### 4.1 Directory Structure

```
lib/
├── main.dart                           # App entry point
├── app.dart                            # App configuration
├── firebase_options.dart               # Firebase config
│
├── core/                               # Core utilities
│   ├── config/
│   │   ├── app_config.dart            # App configuration
│   │   └── firebase_config.dart       # Firebase initialization
│   ├── errors/
│   │   ├── exceptions.dart            # Custom exceptions
│   │   └── failures.dart              # Failure classes
│   └── theme/
│       ├── app_theme.dart             # Theme definition
│       ├── colors.dart                # Color palette
│       └── typography.dart            # Text styles
│
├── features/                           # Feature modules
│   ├── authentication/
│   │   ├── data/
│   │   │   └── auth_repository.dart   # Auth data layer
│   │   ├── domain/
│   │   │   └── user_model.dart        # User model
│   │   └── presentation/
│   │       ├── auth_page.dart         # Login/Register UI
│   │       └── auth_provider.dart     # Auth state
│   │
│   ├── device/
│   │   ├── data/
│   │   │   └── ble_service.dart       # BLE implementation
│   │   ├── domain/
│   │   │   └── device_model.dart      # Device model
│   │   └── presentation/
│   │       ├── device_page.dart       # Device connection UI
│   │       └── device_provider.dart   # Device state
│   │
│   ├── monitoring/
│   │   ├── data/
│   │   │   └── signal_buffer.dart     # Signal buffering
│   │   ├── domain/
│   │   │   └── signal_model.dart      # Signal data model
│   │   └── presentation/
│   │       ├── monitoring_page.dart   # Live monitoring UI
│   │       ├── monitoring_provider.dart
│   │       └── waveform_painter.dart  # Waveform visualization
│   │
│   ├── predictions/
│   │   ├── data/
│   │   │   ├── prediction_repository.dart
│   │   │   └── ai_api_service.dart    # AI API client
│   │   ├── domain/
│   │   │   └── prediction_model.dart  # Prediction model
│   │   └── presentation/
│   │       ├── prediction_page.dart   # Prediction results UI
│   │       └── prediction_provider.dart
│   │
│   ├── history/
│   │   ├── data/
│   │   │   └── session_repository.dart
│   │   ├── domain/
│   │   │   └── session_model.dart     # Session model
│   │   └── presentation/
│   │       ├── history_page.dart      # History list UI
│   │       ├── history_provider.dart
│   │       └── session_detail_page.dart
│   │
│   └── settings/
│       └── presentation/
│           └── settings_page.dart     # Settings UI
│
├── services/                           # Shared services
│   ├── ble/
│   │   ├── ble_manager.dart           # BLE connection management
│   │   └── ble_scanner.dart           # BLE device scanning
│   ├── firebase/
│   │   ├── firebase_auth_service.dart # Auth service wrapper
│   │   └── firebase_firestore_service.dart
│   └── ai_api/
│       ├── api_client.dart            # HTTP client
│       └── api_endpoints.dart         # API endpoints
│
├── models/                             # Shared models
│   ├── prediction.dart
│   ├── session.dart
│   ├── signal_window.dart
│   └── device.dart
│
└── shared/                             # Shared utilities
    ├── widgets/
    │   ├── loading_indicator.dart
    │   ├── error_message.dart
    │   └── status_badge.dart
    └── utils/
        ├── validators.dart            # Input validation
        └── formatters.dart            # Data formatting
```

### 4.2 State Management

**Recommended**: Use Provider or Riverpod for state management.

**Rationale**:
- Official Flutter recommendation
- Good documentation and community support
- Testable and maintainable
- Suitable for this project's complexity

### 4.3 Key Dependencies

Add to `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # Firebase
  firebase_core: ^5.1.0
  firebase_auth: ^7.0.1
  cloud_firestore: ^5.0.0
  
  # BLE
  flutter_blue_plus: ^1.31.15
  
  # Charts
  fl_chart: ^0.69.0
  
  # State Management
  provider: ^6.1.2
  
  # HTTP Client
  http: ^1.2.0
  
  # Utilities
  intl: ^0.19.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0
  mockito: ^5.4.4
  build_runner: ^2.4.8
```

---

## 5. Firebase Configuration

### 5.1 Project Setup

1. Create Firebase project at https://console.firebase.google.com
2. Register Android app with package name
3. Download `google-services.json` and place in `android/app/`
4. Enable required services

### 5.2 Firebase Authentication

**Enabled Methods**:
- Email/Password

**Configuration**:
```dart
// lib/core/config/firebase_config.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> initializeFirebase() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

FirebaseAuth get auth => FirebaseAuth.instance;
```

### 5.3 Cloud Firestore

**Collections Structure**:

```
users/
  {uid}/
    displayName: string
    createdAt: timestamp
    email: string
    
users/{uid}/sessions/
  {sessionId}/
    startedAt: timestamp
    endedAt: timestamp
    deviceId: string
    status: string (active, completed, interrupted)
    duration: number (seconds)
    predictionCount: number
    
users/{uid}/sessions/{sessionId}/predictions/
  {predictionId}/
    createdAt: timestamp
    label: string
    confidence: number (optional)
    modelVersion: string
    qualityStatus: string
    windowDuration: number
    sampleRate: number
```

**Security Rules**:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only access their own data
    match /users/{userId}/{document=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

### 5.4 Firebase Initialization

```dart
// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}
```

---

## 6. BLE Communication Protocol

### 6.1 BLE Service Configuration

**Expected ESP32 BLE Service**:
- Service UUID: `TBD` (coordinate with hardware team)
- Characteristic UUID (EOG Data): `TBD`
- Characteristic UUID (Light Data): `TBD`
- Characteristic Properties: Notify

### 6.2 BLE Connection Flow

```dart
// lib/services/ble/ble_service.dart
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BLEService {
  // Scan for devices
  Future<List<ScanResult>> scanDevices() async {
    List<ScanResult> scanResults = [];
    
    await FlutterBluePlus.startScan(timeout: Duration(seconds: 10));
    
    FlutterBluePlus.scanResults.listen((results) {
      scanResults = results;
    });
    
    await Future.delayed(Duration(seconds: 10));
    await FlutterBluePlus.stopScan();
    
    return scanResults;
  }
  
  // Connect to device
  Future<BluetoothDevice> connectToDevice(String deviceId) async {
    final device = BluetoothDevice.fromId(deviceId);
    await device.connect(timeout: Duration(seconds: 30));
    return device;
  }
  
  // Discover services and characteristics
  Future<List<BluetoothService>> discoverServices(BluetoothDevice device) async {
    return await device.discoverServices();
  }
  
  // Subscribe to notifications
  Stream<List<int>> subscribeToCharacteristic(BluetoothCharacteristic characteristic) {
    characteristic.setNotifyValue(true);
    return characteristic.onValueReceived;
  }
}
```

### 6.3 Data Packet Format

**Expected Format** (coordinate with hardware team):

```
EOG Data Packet:
- Timestamp: 4 bytes (uint32, milliseconds)
- EOG Sample: 2 bytes (int16, ADC value)
- Sequence Number: 2 bytes (uint16)
- Battery Level: 1 byte (uint8, percentage)

Light Data Packet:
- Timestamp: 4 bytes (uint32, milliseconds)
- Lux Value: 4 bytes (float32)
```

### 6.4 Data Parsing

```dart
// lib/features/monitoring/data/signal_buffer.dart
class SignalBuffer {
  final List<EOGSample> _eogBuffer = [];
  final int _targetSampleRate = 128; // Hz
  final int _windowDuration = 10; // seconds
  
  void addSample(EOGSample sample) {
    _eogBuffer.add(sample);
    _maintainBufferSize();
  }
  
  void _maintainBufferSize() {
    final maxSamples = _targetSampleRate * _windowDuration;
    if (_eogBuffer.length > maxSamples) {
      _eogBuffer.removeRange(0, _eogBuffer.length - maxSamples);
    }
  }
  
  List<EOGSample> getWindow() {
    return List.from(_eogBuffer);
  }
  
  bool hasCompleteWindow() {
    return _eogBuffer.length >= (_targetSampleRate * _windowDuration);
  }
}
```

---

## 7. AI Service Integration

### 7.1 API Client Setup

```dart
// lib/services/ai_api/api_client.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

class AIApiClient {
  final String _baseUrl;
  final http.Client _client;
  
  AIApiClient({
    required String baseUrl,
    http.Client? client,
  }) : _baseUrl = baseUrl,
       _client = client ?? http.Client();
  
  Future<Map<String, dynamic>> predict({
    required List<double> samples,
    required int sampleRateHz,
    required String windowStart,
    required double windowDurationSeconds,
  }) async {
    // Get Firebase ID token
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }
    
    final idToken = await user.getIdToken();
    
    final response = await _client.post(
      Uri.parse('$_baseUrl/v1/predict'),
      headers: {
        'Authorization': 'Bearer $idToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'sample_rate_hz': sampleRateHz,
        'samples': samples,
        'window_start': windowStart,
        'window_duration_seconds': windowDurationSeconds,
        'unit': 'adc_normalized',
        'channel': 'vertical_eog',
      }),
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Prediction failed: ${response.body}');
    }
  }
  
  Future<void> close() {
    _client.close();
    return Future.value();
  }
}
```

### 7.2 API Endpoints

```dart
// lib/services/ai_api/api_endpoints.dart
class APIEndpoints {
  static const String healthCheck = '/health';
  static const String predict = '/v1/predict';
  static const String modelInfo = '/v1/model';
}
```

### 7.3 Request/Response Format

**Request**:
```json
{
  "sample_rate_hz": 128,
  "unit": "adc_normalized",
  "window_duration_seconds": 10,
  "samples": [0.12, 0.15, 0.11, ...],
  "window_start": "2026-11-11T15:30:00Z",
  "device_id": "esp32-001",
  "channel": "vertical_eog"
}
```

**Response**:
```json
{
  "prediction": "insufficient_evidence",
  "probabilities": null,
  "model_version": "not-yet-trained",
  "message": "Illustrative response only"
}
```

---

## 8. Data Models

### 8.1 User Model

```dart
// lib/features/authentication/domain/user_model.dart
class UserModel {
  final String uid;
  final String email;
  final String? displayName;
  final DateTime createdAt;
  
  UserModel({
    required this.uid,
    required this.email,
    this.displayName,
    required this.createdAt,
  });
  
  factory UserModel.fromFirestore(Map<String, dynamic> data) {
    return UserModel(
      uid: data['uid'] ?? '',
      email: data['email'] ?? '',
      displayName: data['displayName'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }
  
  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
```

### 8.2 Session Model

```dart
// lib/models/session.dart
class Session {
  final String id;
  final DateTime startedAt;
  final DateTime? endedAt;
  final String deviceId;
  final String status; // active, completed, interrupted
  final int duration; // seconds
  final int predictionCount;
  
  Session({
    required this.id,
    required this.startedAt,
    this.endedAt,
    required this.deviceId,
    required this.status,
    required this.duration,
    required this.predictionCount,
  });
  
  factory Session.fromFirestore(Map<String, dynamic> data) {
    return Session(
      id: data['id'] ?? '',
      startedAt: (data['startedAt'] as Timestamp).toDate(),
      endedAt: data['endedAt'] != null 
          ? (data['endedAt'] as Timestamp).toDate() 
          : null,
      deviceId: data['deviceId'] ?? '',
      status: data['status'] ?? 'active',
      duration: data['duration'] ?? 0,
      predictionCount: data['predictionCount'] ?? 0,
    );
  }
  
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'startedAt': Timestamp.fromDate(startedAt),
      'endedAt': endedAt != null ? Timestamp.fromDate(endedAt!) : null,
      'deviceId': deviceId,
      'status': status,
      'duration': duration,
      'predictionCount': predictionCount,
    };
  }
}
```

### 8.3 Prediction Model

```dart
// lib/models/prediction.dart
class Prediction {
  final String id;
  final DateTime createdAt;
  final String label;
  final double? confidence;
  final String modelVersion;
  final String qualityStatus;
  final int windowDuration;
  final int sampleRate;
  
  Prediction({
    required this.id,
    required this.createdAt,
    required this.label,
    this.confidence,
    required this.modelVersion,
    required this.qualityStatus,
    required this.windowDuration,
    required this.sampleRate,
  });
  
  factory Prediction.fromFirestore(Map<String, dynamic> data) {
    return Prediction(
      id: data['id'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      label: data['label'] ?? '',
      confidence: data['confidence'],
      modelVersion: data['modelVersion'] ?? '',
      qualityStatus: data['qualityStatus'] ?? '',
      windowDuration: data['windowDuration'] ?? 0,
      sampleRate: data['sampleRate'] ?? 0,
    );
  }
  
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'createdAt': Timestamp.fromDate(createdAt),
      'label': label,
      'confidence': confidence,
      'modelVersion': modelVersion,
      'qualityStatus': qualityStatus,
      'windowDuration': windowDuration,
      'sampleRate': sampleRate,
    };
  }
}
```

### 8.4 Signal Model

```dart
// lib/features/monitoring/domain/signal_model.dart
class EOGSample {
  final DateTime timestamp;
  final int adcValue;
  final int sequenceNumber;
  
  EOGSample({
    required this.timestamp,
    required this.adcValue,
    required this.sequenceNumber,
  });
  
  double get normalizedValue {
    // Convert ADC value to normalized voltage
    // Coordinate with hardware team for exact conversion
    return adcValue / 4096.0; // ESP32 12-bit ADC
  }
}

class LightReading {
  final DateTime timestamp;
  final double lux;
  
  LightReading({
    required this.timestamp,
    required this.lux,
  });
}
```

---

## 9. Security Considerations

### 9.1 Firebase Security

- **Never commit `google-services.json`** to public repositories
- Use Firebase Security Rules to restrict data access
- Verify user identity on all operations
- Enable App Check for additional security

### 9.2 API Security

- Use HTTPS for all API calls
- Verify Firebase ID tokens on API server
- Implement rate limiting on API endpoints
- Validate all input data

### 9.3 Data Privacy

- Collect only necessary data
- Use pseudonymous identifiers
- Implement data retention policies
- Provide data deletion capability
- Document data handling procedures

### 9.4 BLE Security

- Validate device identity before connection
- Encrypt sensitive data if required
- Handle connection errors securely

---

## 10. Setup Instructions

### 10.1 Prerequisites

- Flutter SDK (latest stable)
- Android Studio or VS Code
- Android device/emulator
- Firebase project
- Python 3.9+ (for AI backend)
- ESP32 device (for testing)

### 10.2 Flutter Setup

```bash
# Clone repository
git clone <repository-url>
cd eye_monitoring

# Install dependencies
flutter pub get

# Configure Firebase
# 1. Create Firebase project
# 2. Add Android app
# 3. Download google-services.json to android/app/

# Run app
flutter devices  # List available devices
flutter run      # Run on selected device
```

### 10.3 Python AI Backend Setup

```bash
# Navigate to AI backend directory
cd ai_backend

# Create virtual environment
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Run development server
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000

# Test API
curl http://localhost:8000/health
```

### 10.4 Firebase Setup

1. Go to https://console.firebase.google.com
2. Create new project
3. Add Android app (package name from `android/app/build.gradle`)
4. Download `google-services.json`
5. Place in `android/app/google-services.json`
6. Enable Authentication → Email/Password
7. Create Firestore database
8. Set security rules (see Section 5.3)

---

## 11. Testing Guide

### 11.1 Unit Tests

```bash
# Run all unit tests
flutter test

# Run specific test file
flutter test test/unit/auth_repository_test.dart

# Run with coverage
flutter test --coverage
```

### 11.2 Widget Tests

```bash
# Run widget tests
flutter test test/widget/

# Run specific widget test
flutter test test/widget/login_page_test.dart
```

### 11.3 Integration Tests

```bash
# Run integration tests
flutter test integration_test/

# Run on specific device
flutter drive --target=integration_test/app_test.dart
```

### 11.4 API Tests

```bash
# Navigate to AI backend
cd ai_backend

# Run tests
pytest tests/

# Run with coverage
pytest tests/ --cov=app --cov-report=html
```

### 11.5 Manual Testing Checklist

- [ ] User can register with email/password
- [ ] User can login
- [ ] User can logout
- [ ] App can scan for BLE devices
- [ ] App can connect to ESP32
- [ ] App displays live EOG waveform
- [ ] App displays ambient light readings
- [ ] App can start/stop session
- [ ] App can send prediction request to API
- [ ] App displays prediction result
- [ ] App saves session to Firestore
- [ ] App displays session history
- [ ] App handles errors gracefully
- [ ] App works offline (with appropriate error messages)

---

## 12. Deployment Guide

### 12.1 Flutter Release Build

```bash
# Build APK
flutter build apk --release

# Build AAB (for Google Play)
flutter build appbundle --release

# Install APK on connected device
flutter install
```

### 12.2 Python API Deployment

**Option 1: Google Cloud Run**

```bash
# Build Docker image
cd ai_backend
docker build -t eye-monitoring-api .

# Tag for Google Container Registry
docker tag eye-monitoring-api gcr.io/<project-id>/eye-monitoring-api

# Push to registry
docker push gcr.io/<project-id>/eye-monitoring-api

# Deploy to Cloud Run
gcloud run deploy eye-monitoring-api \
  --image gcr.io/<project-id>/eye-monitoring-api \
  --platform managed \
  --region us-central1 \
  --allow-unauthenticated
```

**Option 2: Other Python Hosting**

- Render.com
- Railway.app
- Heroku
- DigitalOcean App Platform

### 12.3 Firebase Deployment

**Firestore Rules**:

```bash
# Deploy security rules
firebase deploy --only firestore:rules
```

**Firestore Indexes**:

```bash
# Deploy indexes (if needed)
firebase deploy --only firestore:indexes
```

---

## 13. Troubleshooting

### 13.1 Common Issues

**Issue**: Firebase initialization fails
- **Solution**: Verify `google-services.json` is in `android/app/`
- **Solution**: Check Firebase project configuration

**Issue**: BLE scan finds no devices
- **Solution**: Check Android permissions in `AndroidManifest.xml`
- **Solution**: Ensure ESP32 is powered and advertising
- **Solution**: Verify BLE service UUIDs match

**Issue**: API returns 401 Unauthorized
- **Solution**: Verify user is authenticated with Firebase
- **Solution**: Check Firebase ID token is valid
- **Solution**: Verify API is checking tokens correctly

**Issue**: Prediction returns error
- **Solution**: Verify signal window format matches API schema
- **Solution**: Check sample rate matches model expectations
- **Solution**: Verify preprocessing is correct

**Issue**: Firestore writes fail
- **Solution**: Check security rules allow the operation
- **Solution**: Verify user is authenticated
- **Solution**: Check field types match schema

### 13.2 Debug Commands

```bash
# Check Flutter setup
flutter doctor

# List connected devices
flutter devices

# Run with verbose logging
flutter run -v

# Check Firebase configuration
flutter pub run firebase_core:setup

# View Android logs
adb logcat

# Test API locally
curl http://localhost:8000/health
```

### 13.3 Performance Issues

**Issue**: Waveform display is laggy
- **Solution**: Reduce chart update frequency
- **Solution**: Optimize data sampling rate
- **Solution**: Use `CustomPainter` for better performance

**Issue**: App uses too much memory
- **Solution**: Limit signal buffer size
- **Solution**: Clear old data periodically
- **Solution**: Profile with Dart DevTools

---

## 14. API Reference

### 14.1 Health Check

**Endpoint**: `GET /health`

**Response**:
```json
{
  "status": "healthy",
  "version": "1.0.0"
}
```

### 14.2 Prediction

**Endpoint**: `POST /v1/predict`

**Headers**:
```
Authorization: Bearer <firebase_id_token>
Content-Type: application/json
```

**Request Body**:
```json
{
  "sample_rate_hz": 128,
  "unit": "adc_normalized",
  "window_duration_seconds": 10,
  "samples": [0.12, 0.15, 0.11, ...],
  "window_start": "2026-11-11T15:30:00Z",
  "device_id": "esp32-001",
  "channel": "vertical_eog"
}
```

**Response** (200 OK):
```json
{
  "prediction": "insufficient_evidence",
  "probabilities": null,
  "model_version": "not-yet-trained",
  "message": "Illustrative response only"
}
```

**Error Responses**:
- 400 Bad Request: Invalid input data
- 401 Unauthorized: Missing or invalid token
- 500 Internal Server Error: Processing error

---

## 15. Contributing

### 15.1 Code Style

- Follow Dart style guidelines
- Use `flutter format` before committing
- Run `flutter analyze` to check for issues
- Write tests for new features

### 15.2 Git Workflow

1. Create feature branch from `main`
2. Make changes and commit
3. Push to remote
4. Create pull request
5. Get code review
6. Merge after approval

### 15.3 Documentation

- Update this document when making architectural changes
- Document all public APIs
- Add inline comments for complex logic
- Keep README.md up to date

---

## 16. Resources

### 16.1 Documentation Links

- [Flutter Documentation](https://docs.flutter.dev/)
- [Firebase Documentation](https://firebase.google.com/docs)
- [FastAPI Documentation](https://fastapi.tiangolo.com/)
- [BioAmp EXG Pill Documentation](https://upsidedownideas.com/)
- [ESP32 Documentation](https://docs.espressif.com/)

### 16.2 Project Documentation

- [Business Requirements](./BUSINESS.md)
- [Design Document](./DESIGN.md)
- [AI Engineering Guide](./AI.md)
- [Wave Plans](./WAVE_PLANS.md)
- [Signal Processing Guide](./WAVE.md)

---

## 17. Contact & Support

For questions or issues:
- Create GitHub issue
- Contact project supervisor
- Reach out to team members

---

## 18. License

This project is developed for academic purposes.

---

## 19. Changelog

### v1.0.0 (2026-11-11)
- Initial technical documentation
- Defined project architecture
- Documented setup instructions
- Added troubleshooting guide

---

**Document Status**: Complete  
**Next Review**: After Wave 2 completion
