import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:writer/controllers/note_controller.dart';
import 'package:writer/data/models/note.dart';
import 'package:writer/utils/helpers/file_helper.dart';

class AppHelpers {
  const AppHelpers._();

  static double getDeviceHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  static double getDeviceWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static String formatDateTime(DateTime dt) {
    final time = DateFormat.Hm().format(dt);
    final day = DateFormat('d').format(dt);
    final suffix = daySuffix(dt.day);
    final month = DateFormat('MMM').format(dt);
    return '$time @$day$suffix $month';
  }

  static String daySuffix(int day) {
    if (day >= 11 && day <= 13) return 'th';
    switch (day % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }

  static void openFile() async {
    try {
      final result = await FilePicker.pickFiles(type: FileType.any);

      if (result != null) {
        final file = File(result.files.single.path!);
        final content = await file.readAsString();
        final title = result.files.single.name;

        final newNote = Note(
          title: title,
          content: content,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          fileExtension: FileHelper.extractExtension(title),
        );

        Get.toNamed('/writer', arguments: newNote);
      }
    } catch (e) {
      throw Exception("Error opening file: $e");
    }
  }

  static void showNoteOptions(BuildContext context, Note note) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.share),
                title: const Text('Share'),
                onTap: () {
                  Navigator.pop(context);
                  shareNote(note);
                },
              ),
              ListTile(
                leading: const Icon(Icons.save),
                title: const Text('Save'),
                onTap: () {
                  Navigator.pop(context);
                  saveNoteToFile(context, note);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Delete'),
                onTap: () {
                  Navigator.pop(context);
                  final noteController = Get.find<NoteController>();
                  noteController.deleteNote(note.key);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'The note "${note.title}" has been deleted.',
                      ),
                      duration: const Duration(seconds: 2),
                      action: SnackBarAction(
                        label: "Undo",
                        onPressed: () {
                          noteController.addNote(note);
                        },
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  static Future<void> shareNote(Note note) async {
    final dir = await getTemporaryDirectory();
    final fileName = FileHelper.prepareFileName(note.title, note.fileExtension);
    final file = File('${dir.path}/$fileName');
    await file.writeAsString(note.content);
    await SharePlus.instance.share(
      ShareParams(files: [XFile(file.path)], text: 'Sharing: $fileName'),
    );
  }

  static Future<void> saveNoteToFile(BuildContext context, Note note) async {
    final fileName = FileHelper.prepareFileName(note.title, note.fileExtension);
    try {
      final result = await FilePicker.saveFile(
        dialogTitle: 'Save your note',
        fileName: fileName,
        bytes: Uint8List.fromList(note.content.codeUnits),
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
}
