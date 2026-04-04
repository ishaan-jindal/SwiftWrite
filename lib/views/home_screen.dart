import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:writer/controllers/note_controller.dart';
import 'package:writer/data/services/auth_service.dart';
import 'package:writer/data/services/theme_service.dart';
import 'package:writer/utils/helpers/helpers.dart';
import 'package:writer/utils/widgets/note_tile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final NoteController _noteController;
  late final TextEditingController _searchController;
  AuthService? _authService;

  @override
  void initState() {
    super.initState();
    _noteController = Get.find<NoteController>();
    _searchController = TextEditingController();
    if (Get.isRegistered<AuthService>()) {
      _authService = Get.find<AuthService>();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                _authService?.isSignedIn == true
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
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Search notes...',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: _noteController.setSearchQuery,
              ),
              const SizedBox(height: 10),
              Obx(
                () => SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Wrap(
                    spacing: 8.0,
                    children: _noteController.uniqueTags.map((tag) {
                      return ChoiceChip(
                        label: Text(tag),
                        selected: _noteController.selectedTag.value == tag,
                        onSelected: (_) => _noteController.setSelectedTag(tag),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: Obx(() {
                  final filtered = _noteController.filteredNotes;
                  return ReorderableListView.builder(
                    onReorder: (oldIndex, newIndex) {
                      _noteController.reorderNotes(oldIndex, newIndex);
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
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final note = filtered[index];
                      return Dismissible(
                        key: Key(note.key.toString()),
                        direction: DismissDirection.endToStart,
                        onDismissed: (direction) {
                          final deletedNote = note;
                          _noteController.deleteNote(deletedNote.key);

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
                                  _noteController.addNote(deletedNote);
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
                  );
                }),
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
