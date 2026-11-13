# User Manual - EOG Eye Monitoring (Prototype)

> **Status:** Academic prototype, **not a medical device**. Outputs are experimental fatigue estimates and must not be used for diagnosis or safety-critical decisions.

## 1. Getting Started
1. Install the Android app (debug/release APK provided by the team).
2. Power on the ESP32 EOG glasses device and ensure it is charged.
3. Enable **Bluetooth** and **Location** (required for BLE scanning on many Android versions).
4. Open the app and **Sign up / Sign in** with email and password.
5. Complete profile setup if prompted.

## 2. Main Screens
- **Home (Dashboard):** Overview and quick navigation.
- **Device:** Scan for, connect to, and manage the EOG glasses (BLE).
- **Monitor:** Live EOG waveform, ambient light, signal quality, and session controls.
- **Results:** Run/view AI fatigue predictions from a valid signal window.
- **History:** Review past sessions and stored prediction summaries/details.
- **Settings:** Account info, preferences, device help, privacy/data actions, app version.

Navigation uses the bottom bar; tap an icon to switch screens.

## 3. Connecting the Device
1. Go to **Device**.
2. Tap **Scan** and grant Bluetooth permissions if requested.
3. Select your device from the list and tap/connect.
4. Wait for status **Connected**.
5. If connection fails, move closer, ensure the device is not paired elsewhere, restart Bluetooth/device, then retry or use **Reconnect**.

## 4. Monitoring a Session
1. Ensure the device is **Connected** (Device screen).
2. Go to **Monitor** to confirm live waveform/light data and signal quality.
3. Tap **Start Session** to begin recording/tracking a session.
4. Monitor indicators: connection state, signal quality, buffer/sample status, missing/invalid data warnings.
5. Tap **Stop Session** to end and save the session. If BLE disconnects or the app is interrupted, the session may be marked interrupted (data saved as available).

**Tips:** Keep electrodes properly placed, minimize movement/noise, and maintain stable BLE range.

## 5. Viewing AI Results
1. Collect sufficient good-quality signal data (default window: ~10s at configured sample rate).
2. Go to **Results/Predictions** and request a prediction when a valid window is available.
3. Review the experimental output, confidence/probabilities (if provided), model/version and quality/status messages.
4. Results may show `insufficient_evidence` when data quality/window/model availability is inadequate—this is expected behavior.

**Disclaimer:** Predictions are estimates for research demonstration only.

## 6. History & Session Details
1. Open **History** to see saved sessions (requires sign-in and network for Firestore sync).
2. Tap a session to view metadata, summary, and prediction trend/list when available.
3. If offline or unavailable, retry when connectivity is restored.

## 7. Settings & Privacy
- **Account information:** View profile/account details.
- **Preferences:** Notifications, high-contrast charts (stored locally).
- **Device connection help:** Pairing and troubleshooting steps.
- **Data & privacy:** How data is handled in this prototype.
- **Delete my data:** Removes saved session history for the signed-in account (cannot be undone).
- **Sign out:** Ends the local session.

## 8. Offline & Errors
- An offline banner may appear when network is unavailable; BLE monitoring can work locally but cloud sync/AI calls may fail.
- Use **Retry** actions where provided. Check permissions, Bluetooth, internet, and backend availability as applicable.

## 9. Known Limitations (Summary)
- Prototype hardware/firmware and model performance are experimental.
- Predictions are not clinically validated.
- Some features depend on configured Firebase project, deployed AI backend, and real ESP32 data format/UUIDs.
See `docs/KNOWN_LIMITATIONS.md` for details.
