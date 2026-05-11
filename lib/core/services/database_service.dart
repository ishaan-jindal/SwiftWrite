import 'package:hive/hive.dart';
import 'package:injectable/injectable.dart';
import 'package:writer/features/notes/models/note.dart';

@lazySingleton
class DatabaseService {
  final Box<Note> _noteBox = Hive.box<Note>('notes');

  Future<dynamic> addNote(Note note) async {
    return _noteBox.add(note);
  }

  Future<void> updateNote(dynamic key, Note note) async {
    await _noteBox.put(key, note);
  }

  Future<void> deleteNote(dynamic key) async {
    await _noteBox.delete(key);
  }

  List<Note> getAllNotes() {
    final notes = _noteBox.values.toList();
    notes.sort((a, b) => (a.order ?? 0).compareTo(b.order ?? 0));
    return notes;
  }
}
