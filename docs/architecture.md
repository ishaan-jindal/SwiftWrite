# SwiftWrite Architecture Overview

## 1) Runtime model

- **Framework**: Flutter
- **State management / navigation / DI**: GetX
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
7. App starts with `GetMaterialApp` and route table.

Design consequence: cloud services are soft-optional and do not block local app startup.

## 3) Layering

### UI layer
- Screens in `lib/views/*`.
- Reusable UI widgets in `lib/utils/widgets/*`.

### Controller layer
- `NoteController`: list state, search/filter/reorder, cloud merge orchestration.
- `WriterController`: note editing lifecycle, tags, save/share/export, code execution trigger.
- `TodoController`: markdown <-> checklist projection for `.todo` editing.

### Service layer
- `DatabaseService`: Hive CRUD over notes.
- `CloudSyncService`: Firestore CRUD + local/cloud id mapping.
- `AuthService`: Firebase auth APIs + auth stream tracking.
- `ThemeService`: persisted theme and seasonal palette state.
- `FirebaseService`: centralized Firebase options construction from environment.
- `CodeExecutionService`: HTTP client for submit/poll execution jobs.

### Model layer
- `Note` Hive model.
- `TodoListItem` polymorphic in-memory model (`ChecklistItem`, `MarkdownItem`).

## 4) Route and DI behavior

GetX routes define lazy-ish dependency registration:
- Home route ensures `NoteController` exists.
- Writer route ensures both `NoteController` and `WriterController`.
- Auth/settings rely on shared permanent auth/cloud services when available.

This avoids hard failures in local-only mode while enabling features progressively.

## 5) Data flow patterns

### Note write path
- UI action -> `WriterController.saveNote()` -> `NoteController.add/update` -> `DatabaseService` -> optional `CloudSyncService.upsertNote`.

### Note delete path
- UI swipe or action -> `NoteController.deleteNote` -> local delete -> optional cloud delete.

### Sync path
- User pull-to-refresh or successful auth -> `NoteController.syncWithCloudMergeLatestWins()`.
- Merge strategy chooses newer `updatedAt` between local and cloud when records match.

### Todo path
- Todo UI manipulates `TodoController.items`.
- `TodoController` regenerates markdown and calls back into writer content.
- Writer persists content as a standard note body.

## 6) Feature gating strategy

The app uses capability gating instead of hard dependencies:
- Missing Firebase env -> auth/cloud features disabled gracefully.
- Signed out user -> cloud sync and code execution not available.
- Unsupported code extension -> execution blocked with user feedback.

## 7) Error handling approach

- User-facing operations mostly use SnackBars for recoverable UX feedback.
- Service-level operations throw exceptions where appropriate (e.g., code execution API failures).
- Some utilities currently rethrow generic exceptions; this is acceptable for internal tooling but could be refined for richer diagnostics.
