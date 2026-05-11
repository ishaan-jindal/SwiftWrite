import 'package:flutter/material.dart';

/// A reusable content editor TextField widget
class ContentEditor extends StatelessWidget {
  final TextEditingController controller;
  final TextStyle? style;

  const ContentEditor({
    super.key,
    required this.controller,
    required this.style,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      autocorrect: false,
      keyboardType: TextInputType.multiline,
      controller: controller,
      maxLines: null,
      expands: true,
      decoration: const InputDecoration(
        hintText: 'Start writing...',
        border: InputBorder.none,
        filled: false,
      ),
      style: style,
    );
  }
}
