import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:writer/core/services/auth_service.dart';
import 'package:writer/core/helpers/helpers.dart';
import 'package:writer/injection/dependency_injection.dart';
import 'package:writer/features/notes/bloc/note_bloc.dart';
import 'package:writer/features/notes/bloc/note_event.dart';
import 'package:writer/features/notes/bloc/note_state.dart';
import 'package:writer/features/notes/widgets/note_tile.dart';
import 'package:writer/features/settings/bloc/settings_bloc.dart';
import 'package:writer/features/settings/bloc/settings_event.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final TextEditingController _searchController;
  AuthService? _authService;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    if (getIt.isRegistered<AuthService>()) {
      _authService = getIt.get<AuthService>();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _pullToSync() async {
    context.read<NoteBloc>().add(const NoteSyncRequested());
    if (!mounted) {
      return;
    }

    final isSignedIn = _authService?.isSignedIn == true;
    final message = isSignedIn
        ? 'Notes synced with cloud database.'
        : 'Local notes refreshed. Sign in to sync with cloud.';

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
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
              onPressed: () => context.read<SettingsBloc>().add(
                const SettingsThemeToggled(),
              ),
              onLongPress: () {
                final settingsState = context.read<SettingsBloc>().state;
                final nextFallState = !settingsState.isFallModeActive;
                context.read<SettingsBloc>().add(
                  const SettingsFallThemeToggled(),
                );
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      nextFallState
                          ? 'Autumn theme activated! 🍁'
                          : 'Original theme restored.',
                    ),
                    duration: const Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.settings_outlined),
              onPressed: () => Navigator.of(context).pushNamed('/settings'),
            ),
            IconButton(
              icon: Icon(
                _authService?.isSignedIn == true
                    ? Icons.verified_user_outlined
                    : Icons.account_circle_outlined,
              ),
              onPressed: () => Navigator.of(context).pushNamed('/auth'),
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
                onChanged: (value) =>
                    context.read<NoteBloc>().add(NoteSearchQueryChanged(value)),
              ),
              const SizedBox(height: 10),
              BlocBuilder<NoteBloc, NoteState>(
                buildWhen: (previous, current) =>
                    previous.uniqueTags != current.uniqueTags ||
                    previous.selectedTag != current.selectedTag,
                builder: (context, state) {
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Wrap(
                      spacing: 8.0,
                      children: state.uniqueTags.map((tag) {
                        return ChoiceChip(
                          label: Text(tag),
                          selected: state.selectedTag == tag,
                          onSelected: (_) => context.read<NoteBloc>().add(
                            NoteTagSelected(tag),
                          ),
                        );
                      }).toList(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),
              Expanded(
                child: BlocBuilder<NoteBloc, NoteState>(
                  builder: (context, state) {
                    final filtered = state.filteredNotes;
                    return RefreshIndicator(
                      onRefresh: _pullToSync,
                      child: ReorderableListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        onReorderItem: (int oldIndex, int newIndex) {
                          context.read<NoteBloc>().add(
                            NoteReorderRequested(oldIndex, newIndex),
                          );
                        },
                        proxyDecorator:
                            (
                              Widget child,
                              int index,
                              Animation<double> animation,
                            ) {
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
                              context.read<NoteBloc>().add(
                                NoteDeleteRequested(deletedNote),
                              );

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'The note "${deletedNote.title}" has been deleted.',
                                  ),
                                  duration: const Duration(seconds: 2),
                                  dismissDirection: direction,
                                  action: SnackBarAction(
                                    label: 'Undo',
                                    onPressed: () {
                                      context.read<NoteBloc>().add(
                                        NoteSaveRequested(deletedNote),
                                      );
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
                              onTap: () => Navigator.of(
                                context,
                              ).pushNamed('/writer', arguments: note),
                              onLongPress: () =>
                                  AppHelpers.showNoteOptions(context, note),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => Navigator.of(context).pushNamed('/writer'),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
