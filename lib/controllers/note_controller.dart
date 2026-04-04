import 'package:get/get.dart';
import 'package:writer/data/models/note.dart';
import 'package:writer/data/services/cloud_sync_service.dart';
import 'package:writer/data/services/database_service.dart';

class NoteController extends GetxController {
  final DatabaseService _databaseService = DatabaseService();
  final CloudSyncService? _cloudSyncService =
      Get.isRegistered<CloudSyncService>()
      ? Get.find<CloudSyncService>()
      : null;

  var notes = <Note>[].obs;
  var uniqueTags = <String>{}.obs;

  var searchQuery = ''.obs;
  var selectedTag = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAllNotes();
  }

  List<Note> get filteredNotes {
    return notes.where((note) {
      final titleMatches = note.title.toLowerCase().contains(
        searchQuery.value.toLowerCase(),
      );
      final contentMatches = note.content.toLowerCase().contains(
        searchQuery.value.toLowerCase(),
      );
      final tagMatches =
          selectedTag.value.isEmpty || note.tags.contains(selectedTag.value);

      return (titleMatches || contentMatches) && tagMatches;
    }).toList();
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
    _addNoteWithSync(note);
  }

  void updateNote(dynamic key, Note note) {
    _updateNoteWithSync(key, note);
  }

  void deleteNote(dynamic key) {
    _deleteNoteWithSync(key);
  }

  Future<void> _addNoteWithSync(Note note) async {
    final key = await _databaseService.addNote(note);
    fetchAllNotes();
    await _cloudSyncService?.upsertNote(localKey: key, note: note);
  }

  Future<void> _updateNoteWithSync(dynamic key, Note note) async {
    await _databaseService.updateNote(key, note);
    fetchAllNotes();
    await _cloudSyncService?.upsertNote(localKey: key, note: note);
  }

  Future<void> _deleteNoteWithSync(dynamic key) async {
    await _databaseService.deleteNote(key);
    fetchAllNotes();
    await _cloudSyncService?.deleteNote(localKey: key);
  }

  Future<void> syncAllNotesToCloud() async {
    if (_cloudSyncService == null) {
      return;
    }

    for (final note in notes) {
      await _cloudSyncService.upsertNote(localKey: note.key, note: note);
    }
  }

  Future<void> syncWithCloudMergeLatestWins() async {
    final cloudSync = _cloudSyncService;
    if (cloudSync == null || !cloudSync.isReady) {
      return;
    }

    fetchAllNotes();

    final localSnapshot = List<Note>.from(notes);
    final cloudSnapshot = await cloudSync.fetchCloudNotes();

    final Map<dynamic, Note> localByKey = {
      for (final note in localSnapshot) note.key: note,
    };

    final Map<String, dynamic> localKeyByCloudId = {};
    for (final key in localByKey.keys) {
      final cloudId = cloudSync.getCloudIdForLocalKey(key);
      if (cloudId != null && cloudId.isNotEmpty) {
        localKeyByCloudId[cloudId] = key;
      }
    }

    final Set<dynamic> matchedLocalKeys = <dynamic>{};

    for (final cloudRecord in cloudSnapshot) {
      dynamic localKey = localKeyByCloudId[cloudRecord.cloudId];

      localKey ??= _findMatchingLocalKeyByFingerprint(
        cloudNote: cloudRecord.note,
        localByKey: localByKey,
        matchedLocalKeys: matchedLocalKeys,
      );

      if (localKey != null) {
        final localNote = localByKey[localKey]!;
        matchedLocalKeys.add(localKey);
        await cloudSync.setMapping(localKey: localKey, cloudId: cloudRecord.cloudId);

        if (_isCloudNewer(localNote: localNote, cloudNote: cloudRecord.note)) {
          final merged = _copyNoteFrom(cloudRecord.note, target: localNote);
          await _databaseService.updateNote(localKey, merged);
          localByKey[localKey] = merged;
        } else {
          await cloudSync.upsertNote(localKey: localKey, note: localNote);
        }
      } else {
        final addedKey = await _databaseService.addNote(_copyDetached(cloudRecord.note));
        await cloudSync.setMapping(localKey: addedKey, cloudId: cloudRecord.cloudId);
      }
    }

    for (final entry in localByKey.entries) {
      final localKey = entry.key;
      final localNote = entry.value;
      final mappedCloudId = cloudSync.getCloudIdForLocalKey(localKey);
      if (mappedCloudId == null || mappedCloudId.isEmpty) {
        await cloudSync.upsertNote(localKey: localKey, note: localNote);
      }
    }

    fetchAllNotes();
  }

  dynamic _findMatchingLocalKeyByFingerprint({
    required Note cloudNote,
    required Map<dynamic, Note> localByKey,
    required Set<dynamic> matchedLocalKeys,
  }) {
    for (final entry in localByKey.entries) {
      if (matchedLocalKeys.contains(entry.key)) {
        continue;
      }
      final local = entry.value;
      final isLikelySameNote =
          local.title == cloudNote.title &&
          local.createdAt.toUtc() == cloudNote.createdAt.toUtc();
      if (isLikelySameNote) {
        return entry.key;
      }
    }
    return null;
  }

  bool _isCloudNewer({required Note localNote, required Note cloudNote}) {
    return cloudNote.updatedAt.toUtc().isAfter(localNote.updatedAt.toUtc());
  }

  Note _copyNoteFrom(Note source, {required Note target}) {
    target
      ..title = source.title
      ..content = source.content
      ..createdAt = source.createdAt
      ..updatedAt = source.updatedAt
      ..tags = List<String>.from(source.tags)
      ..order = source.order
      ..fileExtension = source.fileExtension;
    return target;
  }

  Note _copyDetached(Note source) {
    return Note(
      title: source.title,
      content: source.content,
      createdAt: source.createdAt,
      updatedAt: source.updatedAt,
      tags: List<String>.from(source.tags),
      order: source.order,
      fileExtension: source.fileExtension,
    );
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

  void setSelectedTag(String tag) {
    if (selectedTag.value == tag) {
      selectedTag.value = '';
    } else {
      selectedTag.value = tag;
    }
  }
}
