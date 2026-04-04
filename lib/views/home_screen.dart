import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:writer/controllers/note_controller.dart';
import 'package:writer/data/services/auth_service.dart';
import 'package:writer/data/services/theme_service.dart';
import 'package:writer/utils/helpers/helpers.dart';
import 'package:writer/utils/widgets/note_tile.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final NoteController noteController = Get.put(NoteController());
    final TextEditingController searchController = TextEditingController();
    final AuthService? authService = Get.isRegistered<AuthService>()
        ? Get.find<AuthService>()
        : null;

    return SafeArea(
      top: false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('SwiftWrite'),
          actions: [
            IconButton(
              icon: const Icon(Icons.file_open_outlined),
              onPressed: () => AppHelpers.openFile(),
            ),
            IconButton(
              icon: const Icon(Icons.brightness_6),
              onPressed: () => Get.find<ThemeService>().switchTheme(),
              onLongPress: () =>
                  Get.find<ThemeService>().toggleFallTheme(context),
            ),
            IconButton(
              icon: const Icon(Icons.settings_outlined),
              onPressed: () => Get.toNamed('/settings'),
            ),
            IconButton(
              icon: Icon(
                authService?.isSignedIn == true
                    ? Icons.verified_user_outlined
                    : Icons.account_circle_outlined,
              ),
              onPressed: () => Get.toNamed('/auth'),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              TextField(
                controller: searchController,
                decoration: const InputDecoration(
                  hintText: 'Search notes...',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: noteController.setSearchQuery,
              ),
              const SizedBox(height: 10),
              Obx(
                () => SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Wrap(
                    spacing: 8.0,
                    children: noteController.uniqueTags.map((tag) {
                      return ChoiceChip(
                        label: Text(tag),
                        selected: noteController.selectedTag.value == tag,
                        onSelected: (_) => noteController.setSelectedTag(tag),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: Obx(
                  () => ReorderableListView.builder(
                    onReorder: (oldIndex, newIndex) {
                      noteController.reorderNotes(oldIndex, newIndex);
                    },
                    proxyDecorator:
                        (Widget child, int index, Animation<double> animation) {
                          return Material(
                            color: Theme.of(context).cardColor,
                            elevation: 6.0,
                            borderRadius: BorderRadius.circular(12.0),
                            child: child,
                          );
                        },
                    itemCount: noteController.filteredNotes.length,
                    itemBuilder: (context, index) {
                      final note = noteController.filteredNotes[index];
                      return Dismissible(
                        key: Key(note.key.toString()),
                        direction: DismissDirection.endToStart,
                        onDismissed: (direction) {
                          final deletedNote = note;
                          noteController.deleteNote(deletedNote.key);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'The note "${deletedNote.title}" has been deleted.',
                              ),
                              duration: const Duration(seconds: 2),
                              dismissDirection: direction,
                              action: SnackBarAction(
                                label: "Undo",
                                onPressed: () {
                                  noteController.addNote(deletedNote);
                                },
                              ),
                            ),
                          );
                        },
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20.0),
                          margin: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.error,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.delete,
                            color: Theme.of(context).colorScheme.onError,
                          ),
                        ),
                        child: NoteTile(
                          note: note,
                          index: index,
                          onTap: () => Get.toNamed('/writer', arguments: note),
                          onLongPress: () =>
                              AppHelpers.showNoteOptions(context, note),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => Get.toNamed('/writer'),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
