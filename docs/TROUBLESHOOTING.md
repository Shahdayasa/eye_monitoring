# Troubleshooting Guide

## App & Build
| Symptom | Likely cause | Action |
|---|---|---|
| `flutter` not found / wrong SDK | Flutter not installed or PATH misconfigured | Install Flutter stable, run `flutter doctor`, fix Android licenses/toolchain |
| Dependency/Gradle errors | Stale cache or SDK mismatch | `flutter pub get`, `flutter clean`, ensure JDK/Android SDK versions compatible |
| Firebase init/auth errors | Missing/mismatched config | Verify `google-services.json`, `firebase_options.dart`, package name, and enabled Auth in Firebase Console |
| Release build fails signing | No release keystore/config | Configure signing in `android/app/build.gradle.kts` or use debug signing only for local testing |

## Bluetooth / Device
| Symptom | Likely cause | Action |
|---|---|---|
| No devices found | BT/Location off, permissions denied, device off/out of range | Enable Bluetooth & Location, grant scan/connect permissions, power-cycle device, move closer |
| Scan/connection timeout | Radio interference or device busy | Retry scan, restart Bluetooth, ensure device not connected to another phone |
| Connects but no data | Wrong service/characteristic UUIDs, firmware format mismatch | Confirm ESP32 BLE UUIDs and packet format; use mock BLE for app-flow testing (`USE_MOCK_BLE=true`) |
| Frequent disconnects | Low battery, range, power issues | Charge device, reduce distance/movement, check hardware power stability |
| Session interrupted | BLE drop or app lifecycle event | Reconnect and start a new session; check session status in History/Monitor |

## Monitoring & Signal
| Symptom | Likely cause | Action |
|---|---|---|
| Poor/noisy signal or low quality | Electrode placement/contact, motion artifacts | Adjust electrodes/fit, reduce movement, ensure good skin contact and reference |
| Missing samples / invalid packets | Transmission or parsing issues | Verify firmware packet rate/format; inspect app logs/indicators |
| Prediction unavailable | Insufficient window/quality | Collect a full, good-quality window (default 10s @ 128 Hz) before requesting prediction |

## AI / Network
| Symptom | Likely cause | Action |
|---|---|---|
| API timeout/unreachable | Backend down, wrong base URL, no network | Check connectivity, verify `AI_API_BASE_URL`, confirm server `/health` reachable |
| 401 Unauthorized | Missing/expired/invalid Firebase token or auth required | Re-authenticate; ensure backend `REQUIRE_AUTH`/Firebase credentials configured correctly |
| 422 Invalid signal/window | Rate/window/length/unit mismatch vs API/model | Match app contract (128 Hz, 10s, expected sample count/±tolerance); align model expected metadata |
| `insufficient_evidence` result | No trained model loaded or poor quality | Load valid artifacts in `ai_backend/artifacts/`, improve signal quality; expected fallback in prototype |

## Firebase / Data
| Symptom | Likely cause | Action |
|---|---|---|
| Permission denied (Firestore) | Rules/project mismatch or wrong auth state | Deploy correct `firestore.rules`, confirm signed-in UID matches `users/{uid}` path |
| History empty or not syncing | Offline, write failed, or different account | Check network/offline banner, sign-in account, retry; verify session save completed |
| Delete data fails | Network/rules/auth issue | Ensure online and authorized; retry from Settings → Delete my data |

## Useful Checks
- App version/env: Settings screen and `--dart-define` values.
- API: `curl <base>/health` and `curl <base>/v1/model`.
- Flutter logs: `flutter run` console / device logcat.
- Tests: `cd eye_monitoring && flutter test` (Windows: `cmd.exe /c "flutter test"` in this workspace setup).
