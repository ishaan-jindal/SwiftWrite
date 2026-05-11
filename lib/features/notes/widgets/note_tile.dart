import 'package:flutter/material.dart';
import 'package:writer/features/notes/models/note.dart';
import 'package:writer/core/helpers/helpers.dart';

class NoteTile extends StatelessWidget {
  final Note note;
  final int index;
  final void Function()? onTap;
  final void Function()? onLongPress;

  const NoteTile({
    super.key,
    required this.note,
    required this.index,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final Widget content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          note.title,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        if (note.tags.isNotEmpty) ...[
          Wrap(
            spacing: 6.0,
            runSpacing: 6.0,
            children: note.tags
                .map(
                  (tag) => Chip(
                    label: Text(tag),
                    labelStyle: theme.textTheme.bodySmall,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    backgroundColor: theme.colorScheme.surface,
                    side: BorderSide(color: theme.dividerColor),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 8),
        ],
        Row(
          children: [
            Text(
              AppHelpers.formatDateTime(note.updatedAt),
              style: theme.textTheme.bodyMedium,
            ),
            const Spacer(),
            Chip(
              label: Text(note.fileExtension?.toUpperCase() ?? 'TXT'),
              labelStyle: theme.textTheme.bodySmall,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              backgroundColor: theme.colorScheme.surface,
              side: BorderSide(color: theme.dividerColor),
            ),
          ],
        ),
      ],
    );

    return Card(
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: onTap,
              onLongPress: onLongPress,
              child: Container(
                color: Colors.transparent,
                padding: const EdgeInsets.all(16),
                child: content,
              ),
            ),
          ),
          ReorderableDragStartListener(
            index: index,
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(Icons.drag_handle_sharp),
            ),
          ),
        ],
      ),
    );
  }
}
