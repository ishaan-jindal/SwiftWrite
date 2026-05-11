import 'package:equatable/equatable.dart';
import 'package:writer/features/notes/models/note.dart';

class NoteState extends Equatable {
  const NoteState({
    this.notes = const [],
    this.searchQuery = '',
    this.selectedTag = '',
    this.isLoading = false,
  });

  final List<Note> notes;
  final String searchQuery;
  final String selectedTag;
  final bool isLoading;

  List<Note> get filteredNotes {
    return notes.where((note) {
      final query = searchQuery.toLowerCase();
      final titleMatches = note.title.toLowerCase().contains(query);
      final contentMatches = note.content.toLowerCase().contains(query);
      final tagMatches = selectedTag.isEmpty || note.tags.contains(selectedTag);
      return (titleMatches || contentMatches) && tagMatches;
    }).toList();
  }

  Set<String> get uniqueTags {
    return notes.expand((note) => note.tags).toSet();
  }

  NoteState copyWith({
    List<Note>? notes,
    String? searchQuery,
    String? selectedTag,
    bool? isLoading,
  }) {
    return NoteState(
      notes: notes ?? this.notes,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedTag: selectedTag ?? this.selectedTag,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object> get props => [notes, searchQuery, selectedTag, isLoading];
}
