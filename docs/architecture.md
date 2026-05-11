# SwiftWrite Architecture Overview

## 1) Runtime model

- **Framework**: Flutter
- **State management**: BLoC
- **Dependency Injection**: get_it + injectable
- **Local persistence**: Hive
- **Optional cloud**: Firebase Auth + Firestore
- **Optional remote compute**: External code execution API

The app is intentionally local-first, with cloud enhancements activated only when environment configuration is present and the user is authenticated.

## 2) Startup sequence (`main.dart`)

1. Flutter binding initialized.
2. `.env` loaded.
3. Hive initialized.
4. Hive boxes opened:
   - `settings`
   - `note_sync`
   - `notes` (typed with `Note` adapter)
5. Firebase initialization attempted from env.
6. If Firebase is ready:
   - register `AuthService` (permanent)
   - register `CloudSyncService` (permanent)
7. App starts with `MaterialApp` and route table.

Design consequence: cloud services are soft-optional and do not block local app startup.

## 3) Feature-sliced directory structure

The codebase is organized around features, with each feature owning its state, pages, and domain logic:

```
lib/
├── features/
│   ├── auth/
│   │   ├── bloc/
│   │   │   ├── auth_bloc.dart
│   │   │   ├── auth_event.dart
│   │   │   └── auth_state.dart
│   │   └── pages/
│   │       └── auth_screen.dart
│   ├── notes/
│   │   ├── bloc/
│   │   │   ├── note_bloc.dart
│   │   │   ├── note_event.dart
│   │   │   └── note_state.dart
│   │   ├── repository/
│   │   │   └── note_repository.dart
│   │   └── pages/
│   │       ├── home_screen.dart
│   │       └── writer_screen.dart
│   ├── settings/
│   │   ├── bloc/
│   │   │   ├── settings_bloc.dart
│   │   │   ├── settings_event.dart
│   │   │   └── settings_state.dart
│   │   └── pages/
│   │       └── settings_screen.dart
│   └── code_execution/
│       ├── bloc/
│       │   ├── code_execution_bloc.dart
│       │   ├── code_execution_event.dart
│       │   └── code_execution_state.dart
│       └── pages/
│           └── code_output_view.dart
├── core/
│   └── services/
│       ├── navigation_service.dart
│       ├── auth_service.dart
│       ├── cloud_sync_service.dart
│       ├── database_service.dart
│       ├── theme_service.dart
│       ├── firebase_service.dart
│       └── code_execution_service.dart
├── injection/
│   ├── dependency_injection.dart
│   └── dependency_injection.config.dart (generated)
├── utils/
│   ├── helpers/
│   │   └── helpers.dart
│   └── widgets/
├── app/
│   ├── app.dart
│   └── routes.dart
└── main.dart
```

**Feature ownership**: Each feature (auth, notes, settings, code_execution) owns its Bloc (state container), events, state definitions, and UI pages. Cross-feature communication happens via Bloc event dispatching (e.g., `NoteSyncRequested` from `AuthBloc` after successful sign-in).

**Service consolidation**: All shared services live in `core/services/`, registered as lazy singletons via `get_it` at app startup. Services are never directly instantiated in the UI layer; instead, Blocs depend on them and expose their functionality through events/state.

## 4) Layering

### UI layer
- Screens in `lib/views/*`.
- Reusable UI widgets in `lib/utils/widgets/*`.

### State management layer (Blocs)
- `NoteBloc`: manages note list state, search/filter/reorder, cloud merge orchestration via events (`NoteLoadRequested`, `NoteSearchQueryChanged`, `NoteTagSelected`, `NoteSaveRequested`, `NoteDeleteRequested`, `NoteReorderRequested`, `NoteSyncRequested`).
- `AuthBloc`: handles auth lifecycle, sign in/register/password reset, triggers note sync on successful auth.
- `SettingsBloc`: owns theme preferences (dark mode, seasonal palette) and persists to Hive via `ThemeService`.
- `CodeExecutionBloc`: manages code execution state transitions (`CodeExecutionRequested`, `CodeExecutionReset`) and provides result/error feedback.

### Service layer
- `DatabaseService`: Hive CRUD over notes.
- `CloudSyncService`: Firestore CRUD + local/cloud id mapping.
- `AuthService`: Firebase auth APIs + auth stream tracking.
- `ThemeService`: persisted theme and seasonal palette state.
- `FirebaseService`: centralized Firebase options construction from environment.
- `CodeExecutionService`: HTTP client for submit/poll execution jobs.

### Model layer
- `Note` Hive model.

## 5) Route and DI behavior

Dependency injection via `get_it` with `injectable` bootstrap (`lib/injection/dependency_injection.dart`):
- **Lazy singletons** registered for all services: `DatabaseService`, `ThemeService`, `NoteRepository`.
- **Factories** registered for all Blocs: `NoteBloc`, `AuthBloc`, `SettingsBloc`, `CodeExecutionBloc`.
- Firebase-dependent services (`AuthService`, `CloudSyncService`) registered at startup only if Firebase initialization succeeds.
- All Blocs provided to the widget tree via `MultiBlocProvider` at app startup in `main.dart`.
- Routes defined in `lib/app/routes.dart` using standard `Navigator` and `onGenerateRoute`.

This approach avoids hard failures in local-only mode while enabling cloud features progressively when auth is available.

## 6) Data flow patterns

### Note write path
- UI action -> dispatch `NoteSaveRequested` event to `NoteBloc` -> `NoteBloc` calls `NoteRepository.addNote/updateNote` -> `DatabaseService` stores in Hive -> optional `CloudSyncService.upsertNote` to Firestore.

### Note delete path
- UI swipe/action -> dispatch `NoteDeleteRequested` event to `NoteBloc` -> `NoteBloc` calls `NoteRepository.deleteNote` -> local delete via `DatabaseService` -> optional cloud delete via `CloudSyncService`.

### Sync path
- User pull-to-refresh or successful auth sign-in -> dispatch `NoteSyncRequested` event to `NoteBloc` -> `NoteBloc` calls `NoteRepository.syncWithCloudMergeLatestWins()`.
- Merge strategy chooses newer `updatedAt` between local and cloud when records match.

### Code execution path
- UI "Run" button -> dispatch `CodeExecutionRequested` event to `CodeExecutionBloc` with code/language -> `CodeExecutionBloc` calls `CodeExecutionService.executeCode()` -> state transitions to success/failure -> `BlocListener` navigates to output or shows error.


## 7) Feature gating strategy

The app uses capability gating instead of hard dependencies:
- Missing Firebase env -> `AuthService`/`CloudSyncService` not registered; `AuthBloc` gracefully handles uninitialized state.
- Signed out user -> cloud sync and code execution not available; UI disables buttons and shows informational snackbars.
- Unsupported code extension -> `CodeExecutionBloc` emits failure state with user-friendly error message.
- All feature checks happen in Bloc event handlers or UI widget conditions, allowing graceful degradation.

## 8) Error handling approach

- User-facing errors flow through Bloc state (e.g., `CodeExecutionStatus.failure` with `errorMessage`).
- Bloc listeners and UI builders react to error states and show SnackBars for recoverable feedback.
- Service-level operations throw exceptions where appropriate (e.g., code execution API failures, Firebase auth errors).
- Blocs catch exceptions, extract user-friendly messages (e.g., `AuthService.explainAuthError()`), and emit error states.
- UI layer never directly calls services; all service interactions flow through Bloc events and state.
