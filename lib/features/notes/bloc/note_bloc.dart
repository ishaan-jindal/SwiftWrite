import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:writer/features/notes/bloc/note_event.dart';
import 'package:writer/features/notes/bloc/note_state.dart';
import 'package:writer/features/notes/repository/note_repository.dart';

@injectable
class NoteBloc extends Bloc<NoteEvent, NoteState> {
  NoteBloc(this._repository) : super(const NoteState()) {
    on<NoteLoadRequested>(_onLoadRequested);
    on<NoteSearchQueryChanged>(_onSearchQueryChanged);
    on<NoteTagSelected>(_onTagSelected);
    on<NoteSaveRequested>(_onSaveRequested);
    on<NoteDeleteRequested>(_onDeleteRequested);
    on<NoteReorderRequested>(_onReorderRequested);
    on<NoteSyncRequested>(_onSyncRequested);

    add(const NoteLoadRequested());
  }

  final NoteRepository _repository;

  Future<void> _onLoadRequested(
    NoteLoadRequested event,
    Emitter<NoteState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    final notes = _repository.getAllNotes();
    emit(state.copyWith(notes: notes, isLoading: false));
  }

  Future<void> _onSearchQueryChanged(
    NoteSearchQueryChanged event,
    Emitter<NoteState> emit,
  ) async {
    emit(state.copyWith(searchQuery: event.query));
  }

  Future<void> _onTagSelected(
    NoteTagSelected event,
    Emitter<NoteState> emit,
  ) async {
    final nextTag = state.selectedTag == event.tag ? '' : event.tag;
    emit(state.copyWith(selectedTag: nextTag));
  }

  Future<void> _onSaveRequested(
    NoteSaveRequested event,
    Emitter<NoteState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    if (event.note.key == null) {
      await _repository.addNote(event.note);
    } else {
      await _repository.updateNote(event.note.key, event.note);
    }
    final notes = _repository.getAllNotes();
    emit(state.copyWith(notes: notes, isLoading: false));
  }

  Future<void> _onDeleteRequested(
    NoteDeleteRequested event,
    Emitter<NoteState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    await _repository.deleteNote(event.note.key);
    emit(state.copyWith(notes: _repository.getAllNotes(), isLoading: false));
  }

  Future<void> _onReorderRequested(
    NoteReorderRequested event,
    Emitter<NoteState> emit,
  ) async {
    var newIndex = event.newIndex;
    if (newIndex > event.oldIndex) {
      newIndex -= 1;
    }

    final currentList = state.filteredNotes.toList();
    final movedNote = currentList.removeAt(event.oldIndex);
    currentList.insert(newIndex, movedNote);

    final reorderedKeys = currentList.map((n) => n.key).toSet();
    final otherNotes = state.notes
        .where((n) => !reorderedKeys.contains(n.key))
        .toList();
    final fullNewOrder = [...currentList, ...otherNotes];

    emit(state.copyWith(isLoading: true));
    await _repository.reorderNotes(fullNewOrder);
    emit(state.copyWith(notes: _repository.getAllNotes(), isLoading: false));
  }

  Future<void> _onSyncRequested(
    NoteSyncRequested event,
    Emitter<NoteState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    await _repository.syncWithCloudMergeLatestWins();
    emit(state.copyWith(notes: _repository.getAllNotes(), isLoading: false));
  }
}
