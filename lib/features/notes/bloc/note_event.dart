import 'package:equatable/equatable.dart';
import 'package:writer/features/notes/models/note.dart';

abstract class NoteEvent extends Equatable {
  const NoteEvent();

  @override
  List<Object?> get props => [];
}

class NoteLoadRequested extends NoteEvent {
  const NoteLoadRequested();
}

class NoteSearchQueryChanged extends NoteEvent {
  const NoteSearchQueryChanged(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}

class NoteTagSelected extends NoteEvent {
  const NoteTagSelected(this.tag);

  final String tag;

  @override
  List<Object?> get props => [tag];
}

class NoteSaveRequested extends NoteEvent {
  const NoteSaveRequested(this.note);

  final Note note;

  @override
  List<Object?> get props => [note];
}

class NoteDeleteRequested extends NoteEvent {
  const NoteDeleteRequested(this.note);

  final Note note;

  @override
  List<Object?> get props => [note];
}

class NoteReorderRequested extends NoteEvent {
  const NoteReorderRequested(this.oldIndex, this.newIndex);

  final int oldIndex;
  final int newIndex;

  @override
  List<Object?> get props => [oldIndex, newIndex];
}

class NoteSyncRequested extends NoteEvent {
  const NoteSyncRequested();
}
