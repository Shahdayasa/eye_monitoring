# Firebase Security Documentation

## Overview
Firebase is used for:
- **Authentication:** Email/Password (user identity)
- **Cloud Firestore:** per-user profile, monitoring sessions, and prediction results
- **Cloud Storage (rules present):** per-user files under `users/{uid}/**` (if used)

Security model: **authenticated owner-only access** based on `request.auth.uid == userId` path segment.

## Firestore Rules (`firestore.rules`)
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    function isSignedIn() { return request.auth != null; }
    function isOwner(userId) { return isSignedIn() && request.auth.uid == userId; }

    match /users/{userId} {
      allow read: if isOwner(userId);
      allow create: if isOwner(userId)
        && request.resource.data.uid == userId
        && request.resource.data.email is string
        && request.resource.data.createdAt is timestamp;
      allow update: if isOwner(userId)
        && request.resource.data.uid == userId;
      allow delete: if isOwner(userId);

      match /sessions/{sessionId} {
        allow read, write: if isOwner(userId);
        match /predictions/{predictionId} {
          allow read, write: if isOwner(userId);
        }
      }
    }

    match /{document=**} { allow read, write: if false; }
  }
}
```

### Data paths
- `users/{uid}`: profile document (must include matching `uid`, string `email`, `createdAt` timestamp on create)
- `users/{uid}/sessions/{sessionId}`: session records
- `users/{uid}/sessions/{sessionId}/predictions/{predictionId}`: prediction records

### Guarantees & notes
- Users cannot read/write other users' documents.
- Default deny for all non-matched paths.
- Session/prediction subcollections trust owner access; field-level validation is minimal (prototype). Consider stricter schema/type/range checks for production.
- Client must be authenticated; expired tokens will fail until refreshed.

## Storage Rules (`storage.rules`)
```
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /users/{userId}/{allPaths=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    match /{allPaths=**} { allow read, write: if false; }
  }
}
```
- Restricts all user files to owner path `users/{uid}/...`.

## Deployment
```bash
cd eye_monitoring
firebase deploy --only firestore:rules
firebase deploy --only storage:rules
```
Ensure correct Firebase project selection (`firebase use <project>` / `.firebaserc`) and CLI authentication.

## Verification checklist
- [ ] Authenticated user can create/read/update own `users/{uid}` profile
- [ ] Authenticated user can CRUD own sessions/predictions
- [ ] Access to another user's paths is denied
- [ ] Unauthenticated access denied
- [ ] Rules deployed to intended environment (dev/staging/prod)

## Limitations
- Prototype-level validation; no App Check/enforcement beyond rules shown.
- Admin/server-side operations (if added) should use Admin SDK with appropriate controls, not client rules bypass assumptions.
- Review before any production or sensitive-data deployment.
