import 'package:flutter/material.dart';
import 'package:writer/features/notes/widgets/markdown_view.dart';

class CodeOutputView extends StatelessWidget {
  const CodeOutputView({super.key});

  String _buildOutputData(Map<String, dynamic> result) {
    final String status = result['status'] ?? 'UNKNOWN';
    final List results = result['results'] ?? [];

    if (results.isEmpty) {
      return '# Error\n\nNo execution results found.';
    }

    final buffer = StringBuffer();

    for (int i = 0; i < results.length; i++) {
      final r = results[i];
      final stdout = r['stdout'] ?? '';
      final stderr = r['stderr'] ?? '';

      buffer.writeln('### Run ${i + 1}\n');

      if (status == 'ACCEPTED') {
        buffer.writeln('```\n${stdout.isNotEmpty ? stdout : 'No output'}\n```');
      } else {
        buffer.writeln(
          '```\n${stderr.isNotEmpty ? stderr : 'Error occurred'}\n```',
        );
      }

      buffer.writeln();
    }

    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    final arguments =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (arguments == null) {
      return const Scaffold(body: Center(child: Text('No output available')));
    }
    final String code = arguments['code'];
    final Map<String, dynamic> result = arguments['result'];
    final String language = arguments['language'];

    final String outputData = _buildOutputData(result);

    final String data = '# Code\n\n```$language\n$code\n```\n\n$outputData';

    return Scaffold(
      appBar: AppBar(title: const Text('Code Output')),
      body: MarkdownView(data: data),
    );
  }
}
