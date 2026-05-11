import 'package:flutter/material.dart';

/// A reusable tag editor widget that displays tags and allows adding new ones
class TagEditor extends StatelessWidget {
  final List<String> tags;
  final TextEditingController tagController;
  final Function(String) onAddTag;
  final Function(String) onRemoveTag;

  const TagEditor({
    super.key,
    required this.tags,
    required this.tagController,
    required this.onAddTag,
    required this.onRemoveTag,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Wrap(
          spacing: 8.0,
          runSpacing: 4.0,
          children: tags.map((tag) {
            return Chip(label: Text(tag), onDeleted: () => onRemoveTag(tag));
          }).toList(),
        ),
        TextField(
          controller: tagController,
          decoration: const InputDecoration(hintText: 'Add a tag...'),
          onSubmitted: onAddTag,
        ),
      ],
    );
  }
}
