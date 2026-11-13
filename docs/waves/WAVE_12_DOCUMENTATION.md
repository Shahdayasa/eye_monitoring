# Wave 12: Documentation & Deployment Preparation

> **Status**: ⏳ In Progress  
> **Duration**: 5-7 days  
> **Dependencies**: All previous waves must be complete

---

## Objectives

- Complete all documentation
- Prepare for deployment
- Create user manual
- Final testing

---

## Tasks

- [x] Complete README.md with setup instructions
- [x] Write user manual
- [x] Document API endpoints
- [x] Create deployment guide for Python service
- [x] Document Firebase security rules
- [x] Create troubleshooting guide
- [ ] Build release APK/AAB
- [ ] Test release build
- [x] Create presentation materials
- [ ] Final system testing (end-to-end: hardware, live Firebase/API, device matrix)
- [x] Document known limitations
- [x] Prepare demo script

---

## Deliverables

- [x] Core documentation set (README, user/deploy/API/troubleshooting/security/limitations/demo/presentation)
- [ ] Release build (APK/AAB) produced and verified
- [x] User manual
- [x] Deployment guide
- [x] Presentation materials

---

## Dependencies

- All previous waves must be complete

---

## Success Criteria

Wave is considered complete when:
- [ ] All tasks are checked off
- [x] README.md is comprehensive (setup, config, run/build/test, structure, links)
- [x] User manual is clear and complete for prototype flows
- [x] API documentation is accurate to current backend contract
- [x] Deployment guide covers app, API, Firebase (execution in target env pending)
- [ ] Release build is tested
- [x] Presentation materials are ready (outline/assets checklist)
- [ ] Final system testing passes
- [x] Known limitations are documented

---

## Notes

- Focus on clarity and completeness
- Test all documentation for accuracy
- Prepare for academic presentation
- Document all decisions and trade-offs

## Implementation Notes (2026-11-13)

- Updated `README.md` with setup/configuration (`AI_API_BASE_URL`, `APP_ENV`, `USE_MOCK_BLE`), build/test commands, structure, and doc links.
- Added docs: `docs/USER_MANUAL.md`, `docs/API.md`, `docs/DEPLOYMENT.md`, `docs/FIREBASE_SECURITY.md`, `docs/TROUBLESHOOTING.md`, `docs/KNOWN_LIMITATIONS.md`, `docs/DEMO_SCRIPT.md`, `docs/PRESENTATION.md`.
- Updated `docs/README.md` documentation index to include new operational/user-facing docs.
- Pending in this environment: release APK/AAB build+signing verification on target devices, Docker/hosting deployment execution, Firebase production deploy/index validation, and full end-to-end/hardware system testing.

---

## Deployment Checklist

### Flutter App
- [ ] Build release APK: `flutter build apk --release`
- [ ] Build release AAB: `flutter build appbundle --release`
- [ ] Test release build on device
- [ ] Update version numbers (current: `1.0.0+1` in `pubspec.yaml`)
- [ ] Create release notes

### Python API
- [ ] Build Docker image (`ai_backend/Dockerfile`)
- [ ] Test Docker container
- [ ] Deploy to hosting platform
- [ ] Configure environment variables (`REQUIRE_AUTH`, Firebase creds, `CORS_ALLOW_ORIGINS`, model/artifacts)
- [ ] Test deployed API (`/health`, `/v1/model`, `/v1/predict`)
- [ ] Set up monitoring

### Firebase
- [ ] Deploy security rules (`firebase deploy --only firestore:rules,storage:rules`)
- [ ] Create Firestore indexes (as required by queries)
- [ ] Test production configuration
- [ ] Set up backups

### Documentation
- [x] Complete core technical/operational documentation
- [x] Create user guide
- [x] Document known issues/limitations
- [x] Prepare troubleshooting guide

---

**Previous**: [Wave 11: Testing & Quality Assurance](./WAVE_11_TESTING.md)  
**Next**: [Back to Waves Index](./README.md)
