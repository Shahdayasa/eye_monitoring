# Wave 0: Project Setup & Foundation

> **Status**: ✅ Complete  
> **Duration**: 3-5 days  
> **Dependencies**: None (starting point)

---

## Objectives

- Set up project structure and development environment
- Configure Firebase project and security rules
- Establish version control workflow
- Set up Python virtual environment for AI backend

---

## Tasks

- [x] Create Flutter project structure
- [x] Add Firebase configuration files
- [x] Create folder structure per DESIGN.md (core/, features/, services/, models/, shared/)
- [ ] Set up Firebase project in Firebase Console *(manual - see notes)*
- [ ] Enable Firebase Authentication (Email/Password) *(manual - see notes)*
- [ ] Create Firestore database in test mode *(manual - see notes)*
- [x] Write initial Firebase security rules
- [x] Create Python virtual environment for AI backend
- [ ] Set up Git branches and collaboration workflow *(manual - see notes)*

---

## Deliverables

- Firebase project configured
- Flutter project structure organized
- Python environment ready
- Security rules document

---

## Dependencies

- None (starting point)

---

## Success Criteria

Wave is considered complete when:
- [x] All code tasks are checked off
- [ ] Firebase project is created and configured *(manual)*
- [x] Flutter project has proper folder structure
- [x] Python backend structure is set up
- [ ] Git workflow is established *(manual)*
- [x] Security rules are written

---

## Notes

- Basic Flutter project already exists with Firebase configuration
- Full folder structure created per DESIGN.md
- Firebase security rules written (firestore.rules, storage.rules)
- Python backend structure created in ai_backend/

### Manual Setup Required (Team Lead/DevOps):
1. **Firebase Console Setup**:
   - Go to https://console.firebase.google.com/
   - Create/select project: `eye-monitoring-63ebb`
   - Enable Authentication > Email/Password sign-in method
   - Create Firestore database (start in test mode for development)
   
2. **Git Workflow**:
   - Create `develop` branch from `main`
   - Set up branch protection rules
   - Agree on feature branch naming convention (e.g., `feature/WAVE_01_auth`)

3. **Python Environment**:
   ```bash
   cd ai_backend
   python -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   pip install -r requirements.txt
   ```

---

**Next**: [Wave 1: Firebase Authentication & User Management](./WAVE_01_AUTHENTICATION.md)
