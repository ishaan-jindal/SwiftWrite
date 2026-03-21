import 'package:get/get.dart';
import 'package:writer/data/models/note.dart';
import 'package:writer/data/services/database_service.dart';

class NoteController extends GetxController {
  final DatabaseService _databaseService = DatabaseService();
  var notes = <Note>[].obs;
  var uniqueTags = <String>{}.obs;

  var searchQuery = ''.obs;
  var selectedTag = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAllNotes();
  }

  RxList<Note> get filteredNotes {
    return notes
        .where((note) {
          final titleMaches = note.title.toLowerCase().contains(
            searchQuery.value.toLowerCase(),
          );
          final contentMaches = note.content.toLowerCase().contains(
            searchQuery.value.toLowerCase(),
          );
          final tagMaches =
              selectedTag.value.isEmpty ||
              note.tags.contains(selectedTag.value);

          return (titleMaches || contentMaches) && tagMaches;
        })
        .toList()
        .obs;
  }

  void fetchAllNotes() {
    notes.value = _databaseService.getAllNotes();
    final notesWithNullOrder = notes.where((n) => n.order == null).toList();
    if (notesWithNullOrder.isNotEmpty) {
      int maxOrder = notes
          .map((n) => n.order ?? -1)
          .reduce((a, b) => a > b ? a : b);
      for (var note in notesWithNullOrder) {
        maxOrder++;
        note.order = maxOrder;
        _databaseService.updateNote(note.key, note);
      }
      notes.value = _databaseService.getAllNotes();
    }
    _updateUniqueTags();
  }

  void reorderNotes(int oldIndex, int newIndex) async {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }

    final List<Note> currentList = filteredNotes.toList();
    final Note movedNote = currentList.removeAt(oldIndex);
    currentList.insert(newIndex, movedNote);

    final reorderedKeys = currentList.map((n) => n.key).toSet();
    final otherNotes = notes
        .where((n) => !reorderedKeys.contains(n.key))
        .toList();
    final List<Note> fullNewOrder = [...currentList, ...otherNotes];

    for (int i = 0; i < fullNewOrder.length; i++) {
      final note = fullNewOrder[i];
      if (note.order != i) {
        note.order = i;
        _databaseService.updateNote(note.key, note);
      }
    }

    fetchAllNotes();
  }

  void addNote(Note note) {
    _databaseService.addNote(note);
    fetchAllNotes();
  }

  void updateNote(dynamic key, Note note) {
    _databaseService.updateNote(key, note);
    fetchAllNotes();
  }

  void deleteNote(dynamic key) {
    _databaseService.deleteNote(key);
    fetchAllNotes();
  }

  void _updateUniqueTags() {
    final allTags = notes.expand((note) => note.tags).toSet();
    uniqueTags
      ..clear()
      ..addAll(allTags);
  }

  void setSearchQuery(String query) {
    searchQuery.value = query;
  }

  void setSeletedTag(String tag) {
    if (selectedTag.value == tag) {
      selectedTag.value = '';
    } else {
      selectedTag.value = tag;
    }
  }
}
