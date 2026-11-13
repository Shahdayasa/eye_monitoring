# Wave 7: AI Integration with Flutter

> **Status**: 🟡 In Progress (implementation complete; runtime verification pending Flutter SDK/API runtime)  
> **Duration**: 5-7 days  
> **Dependencies**: Wave 4 and Wave 6 must be complete

---

## Objectives

- Connect Flutter app to AI API
- Send signal windows for inference
- Display prediction results
- Handle API errors

---

## Tasks

- [x] Add http package to pubspec.yaml
- [x] Create API client service (`lib/services/ai_api/api_client.dart`)
- [x] Define API endpoints (`lib/services/ai_api/api_endpoints.dart`)
- [x] Create prediction model (`lib/models/prediction.dart`)
- [x] Build prediction repository (`lib/features/predictions/data/prediction_repository.dart`)
- [x] Implement signal window formation (correct duration and sample rate)
- [x] Add API request logic
- [x] Build prediction result UI screen
- [x] Display prediction with timestamp
- [x] Show model version information
- [x] Add experimental-use disclaimer
- [x] Handle API errors (network failure, timeout, invalid response)
- [x] Add loading states
- [x] Write integration/unit/widget tests for prediction flow
- [ ] Test with actual API (end-to-end, live backend)

---

## Deliverables

- Flutter-API integration
- Prediction result display
- Error handling
- Integration/unit/widget tests (written)

---

## Dependencies

- Wave 4 must be complete (need signal data)
- Wave 6 must be complete (need API available)

---

## Success Criteria

Wave is considered complete when:
- [ ] All tasks are checked off
- [x] Signal windows are formed correctly (from `SignalBuffer` tail using `AppConfig.sampleRateHz`/`windowDurationSeconds`)
- [ ] API requests are sent successfully against live backend
- [x] Prediction results are displayed (prediction, timestamp, window, quality, probabilities, model version)
- [x] Model version is shown
- [x] Experimental disclaimer is visible
- [x] API errors are handled gracefully (timeout/network/401/422/5xx + retry/dismiss)
- [ ] All tests pass in provisioned environment
- [ ] Integration is verified end-to-end

---

## Implementation Notes

- **Config/deps:** `pubspec.yaml` adds `http`; `AppConfig.aiApiBaseUrl` (`AI_API_BASE_URL`, default `http://10.0.2.2:8000`) used by `lib/services/ai_api/api_endpoints.dart`.
- **Client/model:** `lib/services/ai_api/api_client.dart` posts to `/v1/predict` with contract fields (`sample_rate_hz`, `samples`, `channel`, `unit`, `window_start` UTC ISO8601, `window_duration_seconds`, optional `device_id`/`ambient_light_lux`, optional bearer token). `lib/models/prediction.dart` parses response (`prediction`, `probabilities`, `model_version`, `message`, `quality_status`, `features`) and maps errors.
- **Repository/windowing:** `lib/features/predictions/data/prediction_repository.dart` builds a contiguous tail window from `MonitoringProvider`'s `SignalBuffer` (requires `AppConfig.sampleRateHz * AppConfig.windowDurationSeconds` samples; passes normalized values, window start, duration, lux).
- **State/UI:** `lib/features/predictions/presentation/prediction_provider.dart` + `prediction_page.dart` provide analyze action, loading state, experimental-use disclaimer, result card (prediction/timestamp/model version/quality/message/probabilities), and friendly error handling/retry. Wired in `lib/main.dart`.
- **Tests added:** `test/unit/predictions/prediction_model_test.dart`, `test/unit/predictions/prediction_repository_test.dart`, `test/widget/predictions/prediction_page_test.dart`.
- **Verification:** Could not run `flutter pub get`/`flutter test`/`dart analyze` here because the WSL Flutter/Dart SDK toolchain is unavailable (`dart: No such file or directory`). Live `/v1/predict` integration not executed in this session.

---

## Notes

- Ensure signal window matches model training specifications
- Verify sampling rate consistency
- Test with various API response scenarios
- Consider offline states

---

**Previous**: [Wave 6: Python AI Backend & API](./WAVE_06_PYTHON_BACKEND.md)  
**Next**: [Wave 8: History & Reports](./WAVE_08_HISTORY_REPORTS.md)
