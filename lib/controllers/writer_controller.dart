import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart' hide FileType;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:writer/api/code_execution_service.dart';
import 'package:writer/controllers/note_controller.dart';
import 'package:writer/data/models/note.dart';
import 'package:writer/data/services/auth_service.dart';
import 'package:writer/utils/helpers/file_type_analyzer.dart';
import 'package:writer/utils/helpers/file_helper.dart';

import 'package:writer/core/constants/file_types.dart';

class WriterController extends GetxController {
  final NoteController noteController = Get.find<NoteController>();
  final AuthService? authService = Get.isRegistered<AuthService>()
      ? Get.find<AuthService>()
      : null;
  final CodeExecutionService codeExecutionService = CodeExecutionService();

  final titleController = TextEditingController();
  final contentController = TextEditingController();
  final tagController = TextEditingController();

  Note? existingNote;
  final isPreview = true.obs;
  final tags = <String>[].obs;
  final type = FileType.plainText.obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null) {
      existingNote = Get.arguments as Note;
      titleController.text = existingNote!.title;
      contentController.text = existingNote!.content;
      tags.value = List<String>.from(existingNote!.tags);
    }
    titleController.addListener(_updateFileType);
    contentController.addListener(_updatePreviewState);
    _updateFileType();
  }

  @override
  void onClose() {
    titleController.removeListener(_updateFileType);
    contentController.removeListener(_updatePreviewState);
    titleController.dispose();
    contentController.dispose();
    tagController.dispose();
    super.onClose();
  }

  void _updateFileType() {
    final title = titleController.text;
    String? newExtension;
    if (title.contains('.')) {
      newExtension = title.split('.').last;
    }
    type.value = FileTypeAnalyzer.classifyExtension(newExtension);
    _updatePreviewState();
  }

  void _updatePreviewState() {
    if (type.value == FileType.markdown &&
        contentController.text.isNotEmpty &&
        isPreview.value == true) {
      isPreview.value = true;
    } else {
      isPreview.value = false;
    }
  }

  void saveNote() {
    final title = titleController.text;
    final content = contentController.text;

    if (title.isEmpty && content.isEmpty) {
      return;
    }

    final finalExtension = FileHelper.determineFinalExtension(title, null);

    if (existingNote != null) {
      final isNewNote = !noteController.notes.any(
        (note) => note.key == existingNote!.key,
      );

      existingNote!.title = title;
      existingNote!.content = content;
      existingNote!.updatedAt = DateTime.now();
      existingNote!.tags = tags;
      existingNote!.fileExtension = finalExtension;

      if (isNewNote) {
        noteController.addNote(existingNote!);
      } else {
        noteController.updateNote(existingNote!.key, existingNote!);
      }
    } else {
      final newNote = Note(
        title: title.isEmpty ? "New Note" : title,
        content: content,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        tags: tags,
        fileExtension: finalExtension,
      );
      noteController.addNote(newNote);
    }
  }

  Future<void> shareNote() async {
    final rawTitle = titleController.text.trim();
    final content = contentController.text;
    final dir = await getTemporaryDirectory();

    final extension = FileHelper.extractExtension(rawTitle);
    final fileName = FileHelper.prepareFileName(rawTitle, extension);

    final file = File('${dir.path}/$fileName');
    await file.writeAsString(content);

    await SharePlus.instance.share(
      ShareParams(files: [XFile(file.path)], text: 'Sharing: $fileName'),
    );
  }

  Future<void> saveNoteToFile(BuildContext context) async {
    final rawTitle = titleController.text.trim();
    final content = contentController.text;

    final extension = FileHelper.extractExtension(rawTitle);
    final fileName = FileHelper.prepareFileName(rawTitle, extension);

    try {
      final result = await FilePicker.saveFile(
        dialogTitle: 'Save your note',
        fileName: fileName,
        bytes: Uint8List.fromList(content.codeUnits),
      );

      if (result != null && context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Note saved')));
      }
    } catch (e) {
      throw Exception("Error saving note: $e");
    }
  }

  void addTag(String tag) {
    final newTag = tag.trim();
    if (newTag.isNotEmpty && !tags.contains(newTag)) {
      tags.add(newTag);
      tagController.clear();
    }
  }

  void removeTag(String tag) {
    tags.remove(tag);
  }

  void togglePreview() {
    isPreview.toggle();
  }

  bool get canRunCode => authService?.isSignedIn == true;

  void showFeatureLockedMessage(
    BuildContext context, {
    required String featureName,
  }) {
    final message =
        '$featureName is disabled until you sign in to your cloud account.';

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> runCode(BuildContext context) async {
    if (!canRunCode) {
      showFeatureLockedMessage(context, featureName: 'Code execution');
      return;
    }

    final extension = titleController.text.split('.').last.toLowerCase();

    // Map file extension → API language string
    final languageMap = {'py': 'python', 'c': 'c'};

    final language = languageMap[extension];

    if (language == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error\nUnsupported Language")),
      );
      return;
    }

    isLoading.value = true;

    try {
      final result = await codeExecutionService.executeCode(
        code: contentController.text,
        language: language,
        inputs: [''], // optional, can be dynamic later
      );

      Get.toNamed(
        '/code-output',
        arguments: {
          'code': contentController.text,
          'result': result,
          'language': language,
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      isLoading.value = false;
    }
  }
}
