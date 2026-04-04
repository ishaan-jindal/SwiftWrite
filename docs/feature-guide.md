# SwiftWrite Feature Guide

This document describes every currently implemented app feature and where it appears in the product.

## 1) Core note editing

### Create and edit notes
- Tap **+** on Home to create a new note.
- Tap an existing note to open and edit it.
- Notes auto-save when you leave the writer screen (back navigation triggers save).
- Empty title + empty body is ignored (no note created).

### File-aware editing modes
SwiftWrite determines editing mode from the note title extension.

- **Markdown (`.md`, `.markdown`)**
  - Supports live Markdown preview.
  - Toggle preview with the eye icon.
- **Todo (`.todo`)**
  - Supports dual mode:
    - structured checklist UI
    - source Markdown editor view
- **Programming files (`.py`, `.c`, `.js`, etc.)**
  - Treated as code-capable files.
  - Run button appears when signed in (for supported run languages currently `py` and `c`).
- **Unsupported or extensionless titles**
  - Treated as plain text.
  - Persisted with a `.txt` extension by default.

### Tagging
- Add/remove tags in the writer screen.
- Tags are persisted per note.
- Tags are shown on note tiles and exposed as filter chips on Home.

## 2) Home screen note management

### Search
- Search matches note **title** and **content**.
- Search is case-insensitive.

### Tag filtering
- Tap a tag chip to filter notes by that tag.
- Tap the same chip again to clear the filter.

### Reordering
- Notes are draggable via `ReorderableListView`.
- Reorder updates each note's persisted `order` value.

### Delete and undo
- Swipe note tile to delete.
- Snackbar provides **Undo**.
- Long-press note also offers delete from bottom sheet.

### Pull-to-refresh cloud merge
- Pull-to-refresh triggers merge sync with cloud (if signed in and cloud services are initialized).
- If signed out, local list still refreshes and user receives a helpful message.

## 3) File import/export/share

### Import
- Home app bar file icon opens file picker.
- Selected file is loaded into writer with:
  - title = original filename
  - content = file text

### Save/export
- Writer save icon opens a save-file dialog and writes note content as bytes.
- Extension handling tries to preserve current type and normalize unsupported extensions.

### Share
- Writer share icon writes a temporary file and shares it using OS share sheet.
- Home note long-press menu also supports share.

## 4) Todo hybrid experience

For `.todo` notes:
- Checklist rows are parsed from Markdown checkbox syntax (`- [ ]`, `- [x]`).
- Non-checkbox lines are retained as Markdown items.
- You can:
  - reorder checklist/markdown rows
  - toggle completion
  - rename checklist items
  - add/remove todo items
- All operations regenerate Markdown and push updated content back to writer state.

## 5) Markdown rendering

- Markdown preview uses a dedicated styled Markdown widget.
- Code blocks and inline code use theme-aware style settings.
- Horizontal rules and mixed Markdown content are supported in todo rendered mode.

## 6) Authentication and account management

### Sign in / registration
- Email + password sign in and account creation via Firebase Auth.
- Password reset flow sends reset email.
- Auth-specific error codes are translated into user-friendly text.

### Account status surfaces
- Home app bar account icon changes depending on sign-in state.
- Settings and Account screens both show cloud/account availability and sign-out option.

## 7) Cloud-enabled features

When signed in and Firebase initializes successfully:
- Cloud sync service is registered.
- Local edits are mirrored to Firestore on add/update/delete.
- Pull-to-refresh and post-auth actions trigger two-way merge sync.
- Code execution feature is unlocked.

When cloud is unavailable:
- App continues working in local-first mode.
- Cloud-only actions show user-facing guidance.

## 8) Code execution

### Access control
- Requires signed-in cloud account.
- If not signed in, run attempts show locked-feature snackbar.

### Behavior
- Writer maps extension to execution language:
  - `.py` -> `python`
  - `.c` -> `c`
- Flow:
  1. health check against execution server
  2. submit code
  3. poll for result until terminal state or timeout
- Output screen displays original code plus formatted result (stdout/stderr per run).

## 9) Theming

- Light and dark themes are supported.
- Theme preference is persisted in local settings storage.
- Optional seasonal "Fall mode" palette can be toggled via long-press on theme action.

## 10) Navigation and route map

Registered routes:
- `/` -> Home
- `/writer` -> Writer
- `/settings` -> Settings
- `/auth` -> Account/Auth
- `/code-output` -> Code results

Route setup also ensures required controllers are registered when needed.
