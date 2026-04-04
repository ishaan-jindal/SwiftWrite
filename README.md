# SwiftWrite

SwiftWrite is a local-first, cross-platform Flutter writing app with Markdown support, hybrid todo editing, optional cloud sync, and optional code execution.

## Documentation

All project documentation now lives in the root `docs/` folder:

- [`docs/README.md`](docs/README.md) - documentation index
- [`docs/feature-guide.md`](docs/feature-guide.md) - complete feature documentation
- [`docs/architecture.md`](docs/architecture.md) - architecture and data flow
- [`docs/database.md`](docs/database.md) - extensive local + cloud database management guide
- [`docs/setup.md`](docs/setup.md) - environment variables and setup instructions

## Highlights

- Local-first note storage with Hive
- Search, tags, reorder, swipe-to-delete, and undo
- Markdown editor + preview
- `.todo` hybrid checklist/markdown editor
- Import, export/save, and share flows
- Optional Firebase authentication and Firestore sync
- Optional authenticated code execution for supported languages
- Persistent light/dark theme settings with seasonal mode toggle

## Quick start

```bash
flutter pub get
flutter run
```

To enable cloud and code execution features, configure `.env` using `example.env` and follow [`docs/setup.md`](docs/setup.md).
