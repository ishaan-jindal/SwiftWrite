# SwiftWrite

A high-performance, cross-platform writer app built with Flutter, focused on speed, efficiency, and Markdown support.

## Goal

To build a minimalist writer app that prioritizes a fast, distraction-free experience. It's designed for writers, developers, and students who need a reliable tool for capturing notes, drafting content, and organizing ideas with Markdown.

## Features

- **Fast, distraction-free editor:** A simple, clean interface that lets you focus on writing.
- **Local First Storage:** All notes are stored locally on your device using Hive, ensuring your data is always available, even offline.
- **Theme Support:** Switch between light and dark modes to suit your preference.
- **Note Management:** Create, edit, and delete notes with ease. Notes are saved automatically.
- **Swipe to Delete:** Quickly delete notes from the list with a simple swipe gesture.
- **Undo Delete:** Undo the deletion of a note.
- **Markdown Support:** Write in Markdown and preview the rendered output.
- **Todo Lists:** Create and manage todo lists using `.todo` files with Markdown checkbox syntax.
- **Hybrid Todo View:** Seamlessly switch between a user-friendly UI and the raw Markdown source for your todo lists.
- **Code Snippet Support:** Enhanced support for code snippets with syntax highlighting for various languages.
- **Code Execution:** Run code snippets directly within the app.
- **Tagging and Filtering:** Organize your notes with tags and filter them.
- **Full-text search:** Quickly find the note you are looking for.
- **File Operations:**
  - Import notes from files.
  - Export notes to `.txt` files or any format you wish!.
  - Share notes with other apps.

## Tech Stack

- **Framework:** [Flutter](https://flutter.dev/)
- **State Management:** [GetX](https://pub.dev/packages/get)
- **Local Database:** [Hive](https://pub.dev/packages/hive)
- **Markdown Rendering:** [flutter_markdown](https://pub.dev/packages/flutter_markdown)
- **File Sharing:** [share_plus](https://pub.dev/packages/share_plus)
- **File Picking:** [file_picker](https://pub.dev/packages/file_picker)
- **Code Execution:** [code-executor](https://github.com/SacredNightmare99/code-executor)

## Future Features

- **PDF Viewer and Editor:** Open and annotate PDF documents without leaving the app.
- **Improve reordering of todo screen items:** Enhance the drag-and-drop experience for todo items.
