import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:writer/controllers/note_controller.dart';
import 'package:writer/data/models/note.dart';

class HomeScreenController extends GetxController {
  final GlobalKey addNoteKey = GlobalKey();
  final GlobalKey searchKey = GlobalKey();
  final GlobalKey themeKey = GlobalKey();
  final GlobalKey openFileKey = GlobalKey();
  final GlobalKey tagsKey = GlobalKey();

  @override
  void onInit() {
    super.onInit();
    _registerShowcase();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _checkAndShowTutorial(),
    );
  }

  void _registerShowcase() {
    ShowcaseView.register(
      onFinish: _onShowcaseFinish,
      onStart: (index, key) {
        debugPrint('Showcase started for item $index with key $key');
      },
      onComplete: (index, key) {
        debugPrint('Showcase completed for item $index with key $key');
        _onShowcaseFinish();
      },
      onDismiss: (key) {
        debugPrint('Showcase dismissed at key $key');
        _onShowcaseFinish();
      },
      blurValue: 1.0,
      autoPlayDelay: const Duration(seconds: 3),
      enableAutoScroll: true,
      scrollDuration: Duration(milliseconds: 500),

      // --- Global Skip Button ---
      globalFloatingActionWidget: (showcaseContext) => FloatingActionWidget(
        left: 16,
        bottom: 16,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
            onPressed: () => ShowcaseView.get().dismiss(),
            child: Text('Skip Tutorial'),
          ),
        ),
      ),
      hideFloatingActionWidgetForShowcase: [addNoteKey],
    );
  }

  void _createWelcomeNote() {
    final noteController = Get.find<NoteController>();
    final welcomeNote = Note(
      title: 'Welcome.md',
      content: """
# Welcome to SwiftWrite!

This is a simple note to get you started.

## Features
- **Markdown Support**: Write in Markdown and see it rendered.
- **Code Highlighting**: Write code blocks and see them highlighted.
- **File Support**: Open and save files in different formats.
- **Tags**: Organize your notes with tags.
- **Themes**: Switch between light, dark and fall themes.

## Getting Started
1. Create a new note by tapping the '+' button.
2. Write your note in Markdown.
3. Add tags to your note.
4. Save your note.

### Enjoy!
""",
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      tags: ['welcome', 'guide'],
    );
    noteController.addNote(welcomeNote);
  }

  void _checkAndShowTutorial() {
    final settingsBox = Hive.box('settings');
    bool hasCompletedOnboarding = settingsBox.get(
      'hasCompletedOnboarding',
      defaultValue: false,
    );

    if (!hasCompletedOnboarding) {
      _createWelcomeNote();
      Future.delayed(const Duration(milliseconds: 200), () {
        ShowcaseView.get().startShowCase([
          addNoteKey,
          searchKey,
          tagsKey,
          openFileKey,
          themeKey,
        ]);
      });
    }
  }

  void _onShowcaseFinish() {
    final settingsBox = Hive.box('settings');
    if (!settingsBox.get('hasCompletedOnboarding', defaultValue: false)) {
      settingsBox.put('hasCompletedOnboarding', true);
      debugPrint("Onboarding marked as complete.");
    }
  }

  @override
  void onClose() {
    ShowcaseView.get().unregister();
    super.onClose();
  }
}
