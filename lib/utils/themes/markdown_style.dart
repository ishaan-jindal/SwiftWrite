import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

MarkdownStyleSheet getMarkdownStyleSheet(BuildContext context) {
  final theme = Theme.of(context);
  final textTheme = theme.textTheme;
  final colorScheme = theme.colorScheme;

  return MarkdownStyleSheet(
    a: TextStyle(
      color: colorScheme.primary,
      decoration: TextDecoration.underline,
    ),
    p: textTheme.bodyLarge,
    pPadding: const EdgeInsets.symmetric(vertical: 4),
    h1: textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold),
    h1Padding: const EdgeInsets.symmetric(vertical: 8),
    h2: textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
    h2Padding: const EdgeInsets.symmetric(vertical: 6),
    h3: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
    h3Padding: const EdgeInsets.symmetric(vertical: 4),
    h4: textTheme.titleLarge,
    h4Padding: const EdgeInsets.symmetric(vertical: 4),
    h5: textTheme.titleMedium,
    h5Padding: const EdgeInsets.symmetric(vertical: 2),
    h6: textTheme.titleSmall,
    h6Padding: const EdgeInsets.symmetric(vertical: 2),
    em: const TextStyle(fontStyle: FontStyle.italic),
    strong: const TextStyle(fontWeight: FontWeight.bold),
    del: const TextStyle(decoration: TextDecoration.lineThrough),
    blockquote: textTheme.bodyMedium?.copyWith(
      fontStyle: FontStyle.italic,
      color: textTheme.bodyMedium?.color?.withAlpha(180),
    ),
    blockquoteDecoration: BoxDecoration(
      color: theme.cardColor,
      borderRadius: BorderRadius.circular(8),
      border: Border(left: BorderSide(color: theme.dividerColor, width: 4)),
    ),
    code: textTheme.bodyMedium?.copyWith(
      fontFamily: 'monospace',
      backgroundColor: theme.cardColor,
    ),
    codeblockDecoration: BoxDecoration(
      color: theme.cardColor,
      borderRadius: BorderRadius.circular(8),
    ),
    blockSpacing: 8.0,
    listIndent: 24.0,
    listBullet: const TextStyle(fontSize: 16),
    checkbox: const TextStyle(fontSize: 16),
    unorderedListAlign: WrapAlignment.start,
    orderedListAlign: WrapAlignment.start,
    tableHead: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
    tableBody: textTheme.bodyMedium,
    tableBorder: TableBorder.all(color: theme.dividerColor),
    tableColumnWidth: const IntrinsicColumnWidth(),
    tableCellsDecoration: BoxDecoration(
      border: Border(
        top: BorderSide(color: theme.dividerColor),
        right: BorderSide(color: theme.dividerColor),
        bottom: BorderSide(color: theme.dividerColor),
        left: BorderSide(color: theme.dividerColor),
      ),
    ),
    tableCellsPadding: const EdgeInsets.all(6),
    horizontalRuleDecoration: BoxDecoration(
      border: Border(bottom: BorderSide(width: 1.0, color: theme.dividerColor)),
    ),
    img: textTheme.bodyMedium,
  );
}
