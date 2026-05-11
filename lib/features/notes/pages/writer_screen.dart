import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart' hide FileType;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:writer/core/constants/file_types.dart';
import 'package:writer/core/services/auth_service.dart';
import 'package:writer/features/code_execution/bloc/code_execution_bloc.dart';
import 'package:writer/features/code_execution/bloc/code_execution_event.dart';
import 'package:writer/features/code_execution/bloc/code_execution_state.dart';
import 'package:writer/injection/dependency_injection.dart';
import 'package:writer/features/notes/bloc/note_bloc.dart';
import 'package:writer/features/notes/bloc/note_event.dart';
import 'package:writer/features/notes/models/note.dart';
import 'package:writer/features/notes/widgets/content_editor.dart';
import 'package:writer/core/helpers/file_helper.dart';
import 'package:writer/core/helpers/file_type_analyzer.dart';
import 'package:writer/features/notes/widgets/markdown_view.dart';
import 'package:writer/core/widgets/tag_editor.dart';

class WriterScreen extends StatefulWidget {
  const WriterScreen({super.key});

  @override
  State<WriterScreen> createState() => _WriterScreenState();
}

class _WriterScreenState extends State<WriterScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _tagController = TextEditingController();

  Note? _existingNote;
  bool _isPreview = true;
  final List<String> _tags = [];
  FileType _type = FileType.plainText;

  bool _didLoadArgs = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didLoadArgs) {
      final arguments = ModalRoute.of(context)?.settings.arguments;
      if (arguments is Note) {
        _existingNote = arguments;
        _titleController.text = arguments.title;
        _contentController.text = arguments.content;
        _tags.addAll(arguments.tags);
      }
      _titleController.addListener(_updateFileType);
      _contentController.addListener(_updatePreviewState);
      _updateFileType();
      _didLoadArgs = true;
    }
  }

  @override
  void dispose() {
    _titleController.removeListener(_updateFileType);
    _contentController.removeListener(_updatePreviewState);
    _titleController.dispose();
    _contentController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  void _updateFileType() {
    final title = _titleController.text;
    String? newExtension;
    if (title.contains('.')) {
      newExtension = title.split('.').last;
    }
    _type = FileTypeAnalyzer.classifyExtension(newExtension);
    _updatePreviewState();
    setState(() {});
  }

  void _updatePreviewState() {
    if (_type == FileType.markdown &&
        _contentController.text.isNotEmpty &&
        _isPreview == true) {
      _isPreview = true;
    } else {
      _isPreview = false;
    }
    setState(() {});
  }

  void _saveNote() {
    final title = _titleController.text;
    final content = _contentController.text;
    if (title.isEmpty && content.isEmpty) {
      return;
    }

    final finalExtension = FileHelper.determineFinalExtension(title, null);
    final bloc = context.read<NoteBloc>();

    if (_existingNote != null) {
      _existingNote!
        ..title = title
        ..content = content
        ..updatedAt = DateTime.now()
        ..tags = List<String>.from(_tags)
        ..fileExtension = finalExtension;
      bloc.add(NoteSaveRequested(_existingNote!));
    } else {
      final newNote = Note(
        title: title.isEmpty ? 'New Note' : title,
        content: content,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        tags: List<String>.from(_tags),
        fileExtension: finalExtension,
      );
      bloc.add(NoteSaveRequested(newNote));
      _existingNote = newNote;
    }
  }

  Future<void> _shareNote() async {
    final rawTitle = _titleController.text.trim();
    final content = _contentController.text;
    final dir = await getTemporaryDirectory();

    final extension = FileHelper.extractExtension(rawTitle);
    final fileName = FileHelper.prepareFileName(rawTitle, extension);

    final file = File('${dir.path}/$fileName');
    await file.writeAsString(content);

    await SharePlus.instance.share(
      ShareParams(files: [XFile(file.path)], text: 'Sharing: $fileName'),
    );
  }

  Future<void> _saveNoteToFile(BuildContext context) async {
    final rawTitle = _titleController.text.trim();
    final content = _contentController.text;

    final extension = FileHelper.extractExtension(rawTitle);
    final fileName = FileHelper.prepareFileName(rawTitle, extension);

    try {
      final result = await FilePicker.saveFile(
        dialogTitle: 'Save your note',
        fileName: fileName,
        bytes: Uint8List.fromList(content.codeUnits),
      );

      if (result != null && context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Note saved')));
      }
    } catch (e) {
      throw Exception('Error saving note: $e');
    }
  }

  void _addTag(String tag) {
    final newTag = tag.trim();
    if (newTag.isNotEmpty && !_tags.contains(newTag)) {
      _tags.add(newTag);
      _tagController.clear();
      setState(() {});
    }
  }

  void _removeTag(String tag) {
    _tags.remove(tag);
    setState(() {});
  }

  void _togglePreview() {
    setState(() {
      _isPreview = !_isPreview;
    });
  }

  bool get _canRunCode =>
      getIt.isRegistered<AuthService>() && getIt.get<AuthService>().isSignedIn;

  void _showFeatureLockedMessage(
    BuildContext context, {
    required String featureName,
  }) {
    final message =
        '$featureName is disabled until you sign in to your cloud account.';

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _runCode(BuildContext context) {
    if (!_canRunCode) {
      _showFeatureLockedMessage(context, featureName: 'Code execution');
      return;
    }

    final extension = _titleController.text.split('.').last.toLowerCase();
    final languageMap = {'py': 'python', 'c': 'c'};
    final language = languageMap[extension];

    if (language == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error\nUnsupported Language')),
      );
      return;
    }

    context.read<CodeExecutionBloc>().add(
      CodeExecutionRequested(
        code: _contentController.text,
        language: language,
        inputs: const [''],
      ),
    );
  }

  Widget _buildEditorWithTags(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ContentEditor(
            controller: _contentController,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
        const SizedBox(height: 10),
        TagEditor(
          tags: _tags,
          tagController: _tagController,
          onAddTag: _addTag,
          onRemoveTag: _removeTag,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final executionState = context.watch<CodeExecutionBloc>().state;

    return BlocListener<CodeExecutionBloc, CodeExecutionState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.status == CodeExecutionStatus.success &&
            state.result != null &&
            state.code != null &&
            state.language != null) {
          Navigator.of(context).pushNamed(
            '/code-output',
            arguments: {
              'code': state.code,
              'result': state.result,
              'language': state.language,
            },
          );
          context.read<CodeExecutionBloc>().add(const CodeExecutionReset());
        } else if (state.status == CodeExecutionStatus.failure &&
            state.errorMessage != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
        }
      },
      child: PopScope(
        canPop: true,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) _saveNote();
        },
        child: SafeArea(
          top: false,
          child: Scaffold(
            appBar: AppBar(
              title: _isPreview
                  ? Text(_titleController.text)
                  : TextField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        hintText: 'Title',
                        border: InputBorder.none,
                        filled: false,
                      ),
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
              actions: [
                if (_type == FileType.markdown)
                  IconButton(
                    icon: Icon(
                      _isPreview ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: _togglePreview,
                  ),
                if (_type == FileType.programmingLanguage)
                  _canRunCode
                      ? IconButton(
                          icon: executionState.isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.play_arrow_rounded),
                          onPressed: () {
                            if (!executionState.isLoading) {
                              _runCode(context);
                            }
                          },
                        )
                      : IconButton(
                          icon: const Icon(Icons.cloud_off),
                          tooltip:
                              'Code execution is disabled until you sign in.',
                          onPressed: () => _showFeatureLockedMessage(
                            context,
                            featureName: 'Code execution',
                          ),
                        ),
                if (_type == FileType.unsupported ||
                    _type == FileType.plainText)
                  Center(
                    child: Chip(
                      padding: const EdgeInsets.all(0),
                      label: const Text('Plain Text'),
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      side: BorderSide(
                        color: Theme.of(context).dividerColor,
                        width: 2,
                      ),
                      labelStyle: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                IconButton(
                  icon: const Icon(Icons.save),
                  onPressed: () => _saveNoteToFile(context),
                ),
                IconButton(
                  icon: const Icon(Icons.share),
                  onPressed: _shareNote,
                ),
              ],
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: _isPreview && _type == FileType.markdown
                  ? MarkdownView(data: _contentController.text)
                  : _buildEditorWithTags(context),
            ),
          ),
        ),
      ),
    );
  }
}
