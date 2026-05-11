import 'package:injectable/injectable.dart';
import 'package:writer/core/services/cloud_sync_service.dart';
import 'package:writer/core/services/database_service.dart';
import 'package:writer/features/notes/models/note.dart';
import 'package:writer/injection/dependency_injection.dart';

@lazySingleton
class NoteRepository {
  NoteRepository(this._databaseService);

  final DatabaseService _databaseService;

  CloudSyncService? get _cloudSyncService {
    return getIt.isRegistered<CloudSyncService>()
        ? getIt.get<CloudSyncService>()
        : null;
  }

  List<Note> getAllNotes() {
    final notes = _databaseService.getAllNotes();
    final notesWithNullOrder = notes.where((n) => n.order == null).toList();
    if (notesWithNullOrder.isNotEmpty) {
      var maxOrder = notes
          .map((n) => n.order ?? -1)
          .fold<int>(-1, (a, b) => a > b ? a : b);
      for (final note in notesWithNullOrder) {
        maxOrder++;
        note.order = maxOrder;
        _databaseService.updateNote(note.key, note);
      }
      return _databaseService.getAllNotes();
    }
    return notes;
  }

  Future<dynamic> addNote(Note note) async {
    final key = await _databaseService.addNote(note);
    await _cloudSyncService?.upsertNote(localKey: key, note: note);
    return key;
  }

  Future<void> updateNote(dynamic key, Note note) async {
    await _databaseService.updateNote(key, note);
    await _cloudSyncService?.upsertNote(localKey: key, note: note);
  }

  Future<void> deleteNote(dynamic key) async {
    await _databaseService.deleteNote(key);
    await _cloudSyncService?.deleteNote(localKey: key);
  }

  Future<void> reorderNotes(List<Note> reorderedList) async {
    for (var i = 0; i < reorderedList.length; i++) {
      final note = reorderedList[i];
      if (note.order != i) {
        note.order = i;
        await _databaseService.updateNote(note.key, note);
      }
    }
  }

  Future<void> syncWithCloudMergeLatestWins() async {
    final cloudSync = _cloudSyncService;
    if (cloudSync == null || !cloudSync.isReady) {
      return;
    }

    final localSnapshot = List<Note>.from(getAllNotes());
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
        await cloudSync.setMapping(
          localKey: localKey,
          cloudId: cloudRecord.cloudId,
        );

        if (_isCloudNewer(localNote: localNote, cloudNote: cloudRecord.note)) {
          final merged = _copyNoteFrom(cloudRecord.note, target: localNote);
          await _databaseService.updateNote(localKey, merged);
          localByKey[localKey] = merged;
        } else {
          await cloudSync.upsertNote(localKey: localKey, note: localNote);
        }
      } else {
        final addedKey = await _databaseService.addNote(
          _copyDetached(cloudRecord.note),
        );
        await cloudSync.setMapping(
          localKey: addedKey,
          cloudId: cloudRecord.cloudId,
        );
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
}
