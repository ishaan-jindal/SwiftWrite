# SwiftWrite Database Guide (Extensive)

This is the authoritative data-management guide for SwiftWrite. It covers local persistence, cloud sync, record mapping, merge conflict rules, and operational guidance.

---

## 1) Database strategy at a glance

SwiftWrite uses a **dual-store architecture**:

1. **Local database (Hive)** for always-available, offline-first note storage.
2. **Cloud database (Firestore)** for optional account-based sync.

The local store is always primary for editing latency and offline reliability. Cloud operations are additive and best-effort when authenticated.

---

## 2) Local database (Hive)

### 2.1 Opened boxes

During startup, the app opens:

- `notes` (`Box<Note>`)  
  Main document store for note content and metadata.
- `settings` (`Box`)  
  App preferences, including theme mode and fall mode flags.
- `note_sync` (`Box`)  
  Mapping table between local keys and cloud document IDs.

### 2.2 `Note` schema

`Note` fields used in persistence and sync:

- `title` (`String`)
- `content` (`String`)
- `createdAt` (`DateTime`)
- `updatedAt` (`DateTime`)
- `tags` (`List<String>`)
- `order` (`int?`)
- `fileExtension` (`String?`)

Notes are stored as Hive objects (with generated adapter), and list order is derived from `order`.

### 2.3 Local CRUD behavior

`DatabaseService` provides:
- `addNote(note)` -> returns generated Hive key
- `updateNote(key, note)`
- `deleteNote(key)`
- `getAllNotes()` sorted by `(order ?? 0)` ascending

Controller-level operations always refresh reactive state after writes.

### 2.4 Order management and migration-by-read

On fetch, `NoteController` detects notes with `order == null` and assigns sequential order values. This works as a lightweight migration path for older data and ensures deterministic ordering.

### 2.5 Local resilience characteristics

- Full read/write without network.
- Startup does not depend on Firebase availability.
- Cloud sync failures do not block local writes.

---

## 3) Cloud database (Firestore)

### 3.1 Activation conditions

Cloud features activate only if:

1. Firebase env vars are present for active platform.
2. Firebase initializes successfully.
3. User signs in (for note operations requiring user scope).

If any condition fails, app remains local-only.

### 3.2 Firestore path model

Per-user namespace:

`users/{uid}/notes/{cloudNoteId}`

This isolates each account's notes and avoids cross-user collisions.

### 3.3 Cloud note payload

On upsert, payload includes:

- `title`
- `content`
- `tags`
- `order`
- `fileExtension`
- `createdAt` (stored as UTC Firestore `Timestamp`)
- `updatedAt` (stored as UTC Firestore `Timestamp`)
- `updatedBy` (`swiftwrite-client`)

### 3.4 Cloud CRUD semantics

- **Upsert**
  - If local->cloud mapping exists, update mapped doc with merge.
  - Otherwise create new document and persist mapping.
- **Fetch**
  - Read all user notes.
  - Coerce timestamps robustly with fallback logic.
- **Delete**
  - Requires existing local->cloud mapping.
  - Deletes mapped cloud doc and removes mapping entry.

### 3.5 Authentication coupling

CloudSyncService checks `currentUser` every operation. If user is signed out, methods return early without throwing, preventing UX interruption in local flows.

---

## 4) Local-cloud key mapping (`note_sync`)

### 4.1 Why mapping exists

Hive local keys are app-local identifiers and do not match Firestore document IDs. A mapping table is required for idempotent updates/deletes.

### 4.2 Mapping key format

`{userId}::{localKey}` -> `cloudDocumentId`

Including `userId` in the key prevents clashes across different signed-in users on same device profile.

### 4.3 Lifecycle

- Created on first successful cloud upsert for a local note.
- Reused for all subsequent updates/deletes.
- Deleted when local deletion propagates to cloud.

### 4.4 Recovery and remapping

During merge sync, if a note is matched without mapping, the app sets mapping via `setMapping(localKey, cloudId)`.

---

## 5) Merge sync algorithm (latest-wins)

Sync entrypoint: `NoteController.syncWithCloudMergeLatestWins()`.

### 5.1 High-level phases

1. Load local snapshot.
2. Fetch cloud snapshot.
3. Build local-key-by-cloud-id map from mapping box.
4. For each cloud record:
   - resolve matching local note (mapping first, fingerprint fallback)
   - if matched: compare timestamps and keep latest
   - if not matched: insert cloud note locally
5. Push local notes lacking cloud mapping to cloud.
6. Refresh reactive local list.

### 5.2 Matching strategy details

Priority order:
1. Direct mapping lookup by cloud ID.
2. Fingerprint fallback: same `title` and same `createdAt` (UTC).

### 5.3 Conflict rule

If local and cloud are matched, cloud overwrites local only when:

`cloud.updatedAt > local.updatedAt` (UTC comparison)

Else local version is pushed to cloud.

### 5.4 Implications of latest-wins

Pros:
- Simple and deterministic.
- Minimal user disruption for single-device edits.

Trade-offs:
- Concurrent edits near-simultaneously may overwrite one side.
- No field-level merge; merge unit is entire note object.

### 5.5 TODO for advanced conflict handling (future recommendation)

Potential improvements:
- Per-field merge (title/content/tags independently).
- Edit-operation logs (CRDT/OT style).
- Soft conflict copies (duplicate note with conflict suffix).

---

## 6) End-to-end data flows

### 6.1 Create note
1. Writer creates `Note` with timestamps.
2. Local add returns Hive key.
3. Optional cloud upsert creates/updates remote doc.
4. Mapping stored/updated.

### 6.2 Update note
1. Existing note fields updated locally.
2. Local put by key.
3. Optional cloud upsert using existing mapping.

### 6.3 Delete note
1. Local delete by key.
2. Optional cloud delete using mapping.
3. Mapping removed.

### 6.4 Pull-to-sync
1. User gesture triggers sync.
2. Merge resolves newest version per matched note.
3. Missing sides are hydrated.

---

## 7) Time and timezone handling

- Upsert writes `createdAt/updatedAt` in UTC timestamps.
- Comparison in merge explicitly normalizes to UTC.
- Display formatting is local-time friendly at UI layer.

Recommendation: keep all stored timestamps UTC (already done) and perform local-time conversion only for display.

---

## 8) Security and access model

### 8.1 Client-side behavior
- User-specific pathing (`users/{uid}/notes`) avoids accidental cross-account reads in app logic.
- No cloud operations without authenticated user context.

### 8.2 Firestore rules recommendation

Use strict server rules to enforce ownership (example conceptual policy):
- Allow read/write only when `request.auth.uid == userId` for documents under `users/{userId}`.

(Implement exact rules in Firebase console/project config.)

---

## 9) Operational setup checklist

### Local-only mode
- `.env` may omit Firebase keys.
- App should still run full local feature set.

### Cloud mode
- Populate Firebase env keys for target platform.
- Enable Email/Password auth provider in Firebase.
- Ensure Firestore exists and security rules are applied.
- Verify first sign-in triggers successful sync.

### Diagnostics to run when sync seems broken
1. Confirm signed-in state in Settings/Auth screen.
2. Confirm Firebase env values are non-empty.
3. Validate network connectivity.
4. Verify Firestore path has documents under expected UID.
5. Check whether mapping entries exist in `note_sync` box (for updates/deletes).

---

## 10) Data retention and backup notes

- Local Hive data is device-local and tied to app storage lifecycle.
- Cloud Firestore acts as remote backup/sync source when enabled.
- Deleting a note in app (while mapped and signed in) deletes cloud copy too.

If you want archive semantics (soft delete), add a `deletedAt` flag and filter in UI instead of hard delete.

---

## 11) Known constraints

- Code execution is gated by sign-in but not itself persisted in DB.
- Merge uses full-note replacement, not granular merge.
- Fingerprint fallback (`title + createdAt`) can misidentify in rare duplicate-title/time scenarios.

---

## 12) Suggested extension patterns

### Schema evolution
- Add new optional fields with safe defaults.
- Update Hive adapter and migration tests.
- Include field in cloud payload + fallback parser.

### Multi-device reliability
- Add `deviceId` and `lastEditedBy` metadata.
- Add conflict records for simultaneous divergent edits.

### Auditability
- Add a sync log collection or local sync event queue for debugging.
