# Contributing to SwiftWrite

Thank you for your interest in contributing to SwiftWrite!

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Setup](#development-setup)
- [Project Structure](#project-structure)
- [Making Changes](#making-changes)
- [Style Guidelines](#style-guidelines)
- [Testing](#testing)
- [Pull Request Process](#pull-request-process)
- [Questions?](#questions)

## Code of Conduct

This project is governed by the [Contributor Covenant](https://www.contributor-covenant.org/version/2/1/code_of_conduct/). By participating, you are expected to uphold this code.

## Getting Started

1. **Open an Issue** — Before submitting a Pull Request, please open a corresponding issue to discuss your proposed changes.
2. **Fork the repository** on GitHub.
3. **Clone your fork** to your local machine.
4. **Create a new branch** — Use a descriptive name like `feat/word-count` or `fix/markdown-preview`.

## Development Setup

### Prerequisites

- **Flutter** (stable channel) — [Install](https://docs.flutter.dev/get-started/install)
- **Dart** (bundled with Flutter)
- (Optional) A Firebase project for cloud sync features

### Setup

```bash
# Get dependencies
flutter pub get

# Run code generation (if you changed Hive models)
flutter pub run build_runner build --delete-conflicting-outputs

# Copy and configure environment
cp example.env .env
# Edit .env with your API keys if needed

# Run the app
flutter run
```

## Project Structure

```
lib/
  app/              — App entry point, routes, theme
  core/
    theme/          — Light/dark theme, Markdown styles
    services/       — Shared services (auth, Firebase)
    helpers/        — File helpers, type analysis
    constants/      — File type constants
    widgets/        — Shared widgets (tag editor, etc.)
  features/
    notes/          — Note model, BLoC, repository, writer UI
    code_execution/ — Run Python/C via external API
    auth/           — Firebase authentication
    settings/       — Theme, identity settings
  injection/        — Dependency injection (GetIt + Injectable)
```

State management uses **BLoC** (`flutter_bloc`). Local storage uses **Hive**. Cloud sync (optional) uses **Firebase Auth + Firestore**.

## Making Changes

### What to Work On

Check [open issues](https://github.com/ishaan-jindal/SwiftWrite/issues) for `good first issue` or `help wanted` labels. Good places to start:
- Add word count and reading time
- Add PDF export
- Add a Markdown formatting toolbar
- Add unit tests for BLoCs

### Commit Messages

Write clear, concise commit messages:

```
feat: add word count and reading time to writer
fix: handle empty note title gracefully
refactor: extract markdown preview into reusable widget
```

## Style Guidelines

- Run `flutter analyze` and fix all warnings before committing.
- Follow the [Flutter style guide](https://docs.flutter.dev/style-guide).
- Use `snake_case` for file and directory names.
- Use `lowerCamelCase` for variables and methods.
- Use `UpperCamelCase` for types and classes.
- Prefer `const` constructors where possible.

## Testing

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

We welcome tests for BLoCs, repositories, and utility functions.

## Pull Request Process

1. Ensure your code passes `flutter analyze` with no warnings.
2. Run `flutter test` and ensure all tests pass. Add tests for new functionality.
3. If you changed Hive models, run code generation and commit the generated files.
4. Reference the issue number in your PR description (e.g., `Fixes #123`).
5. Provide a clear, concise description of your changes.
6. Wait for feedback and address any requested changes.

## Questions?

Open a [discussion](https://github.com/ishaan-jindal/SwiftWrite/discussions) or ask in the issue you're working on.
