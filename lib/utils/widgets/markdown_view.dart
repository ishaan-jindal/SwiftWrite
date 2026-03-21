import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:writer/utils/themes/markdown_style.dart';

class MarkdownView extends StatelessWidget {
  final String data;
  const MarkdownView({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Markdown(
      data: data,
      styleSheet: getMarkdownStyleSheet(context),
      selectable: true,
    );
  }
}
