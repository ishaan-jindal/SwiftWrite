# Environment & Setup

## 1) Prerequisites

- Flutter SDK compatible with the project `pubspec.yaml`.
- Dart SDK matching Flutter channel constraints.
- Firebase project (only if using cloud mode).
- Optional code execution backend (for run-code feature).

## 2) Install dependencies

```bash
flutter pub get
```

## 3) Environment variables

Create a `.env` file at repository root (you can copy from `example.env`).

### Required for local-only usage
No required variables for basic local notes/theme/search/tagging usage.

### Required for code execution feature
- `codeExecutionBaseURL`
- `codeExecutionAPI`

### Required for cloud mode (Firebase)
- `FIREBASE_PROJECT_ID`
- `FIREBASE_MESSAGING_SENDER_ID`
- `FIREBASE_STORAGE_BUCKET` (optional in some projects, but supported)
- `FIREBASE_AUTH_DOMAIN` (used for web)
- `FIREBASE_ANDROID_APP_ID`
- `FIREBASE_ANDROID_API_KEY`
- `FIREBASE_WEB_APP_ID`
- `FIREBASE_WEB_API_KEY`

If the required keys for the active platform are missing, Firebase initialization is skipped and app continues in local-only mode.

## 4) Running the app

```bash
flutter run
```

## 5) Cloud setup checklist

1. Create Firebase project.
2. Enable **Authentication > Email/Password** provider.
3. Create Firestore database.
4. Add Android/Web app credentials and copy IDs/keys into `.env`.
5. Start app and verify:
   - Account screen allows sign in.
   - Pull-to-refresh on Home shows cloud sync message when signed in.

## 6) Code execution server expectations

The code execution client expects endpoints:
- `GET /health` -> status payload containing healthy state
- `POST /submit` -> returns `job_id`
- `GET /result/{job_id}` -> returns execution status + outputs

Requests include `X-API-Key` header from `codeExecutionAPI`.

## 7) Common troubleshooting

- **Cloud features missing**: check Firebase keys and platform-specific values.
- **Cannot sign in**: ensure Email/Password provider enabled in Firebase Auth.
- **Code run fails with server not running**: verify `codeExecutionBaseURL` reachability and `/health` response.
- **No sync after sign in**: trigger pull-to-refresh and verify network/firestore rules.
