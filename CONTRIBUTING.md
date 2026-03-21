# Contributing to SwiftWrite

First off, thank you for considering contributing to SwiftWrite! It's great to have you here. As a solo developer, I appreciate any help I can get. This document will provide a brief overview of the project and guide you on how to contribute.

## Project Overview

SwiftWrite is a simple, fast, and elegant note-taking application built with Flutter. The goal is to provide a clean and distraction-free writing experience.

### Tech Stack

- **Framework:** [Flutter](https://flutter.dev/)
- **State Management:** [GetX](https://pub.dev/packages/get)
- **Local Storage:** [Hive](https://pub.dev/packages/hive)
- **UI:** Material Design with a custom theme.

### Project Structure

The project follows a feature-driven architecture. Here's a quick rundown of the key directories under `lib/`:

-   `api/`: Contains services for interacting with external APIs.
-   `controllers/`: Holds the GetX controllers that manage the application's state and business logic.
-   `data/`: Includes data models (`models/`) and services for data persistence (`services/`).
-   `utils/`: A place for shared constants, helper functions, themes, and custom widgets.
-   `views/`: Contains the UI screens of the application.

## Getting Started

1.  **Fork & Clone:** Fork the repository and clone it to your local machine.
2.  **Install Dependencies:** Run `flutter pub get` in the root directory.
3.  **Run Code Generation:** The project uses Hive, which requires code generation. Run the following command to generate the necessary files:
    ```bash
    flutter pub run build_runner build --delete-conflicting-outputs
    ```
4.  **Run the App:** Use `flutter run` to start the application on your preferred device or emulator.

## How to Contribute

Since this is a small project, the contribution process is straightforward.

1.  **Open an Issue:** Before starting any work, please open an issue to discuss the feature, bug, or improvement you have in mind. This helps to ensure that your work aligns with the project's goals.
2.  **Create a Branch:** Create a new branch from `main` for your changes. A good branch name would be `feat/your-feature-name` or `fix/your-bug-fix`.
3.  **Write Code:** Make your changes, following the existing code style and conventions.
4.  **Submit a Pull Request:** Once you're ready, submit a pull request to the `main` branch. Please provide a clear description of the changes you've made.

## Coding Style & Conventions

-   **Linting:** The project uses `flutter_lints`. Please ensure your code adheres to these rules.
-   **File Naming:** Use `snake_case` for file names (e.g., `writer_screen.dart`).
-   **Structure:** Please follow the existing directory structure. For example, new UI screens go in `views/`, and their corresponding state management logic goes in `controllers/`.
-   **Commit Messages:** Write clear and concise commit messages that explain the "why" behind your changes.

Thank you again for your interest in contributing!
