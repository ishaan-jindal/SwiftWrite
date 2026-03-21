enum FileType { markdown, programmingLanguage, plainText, todo, unsupported }

const Map<String, int> languageIdMap = {
  'cpp': 52,
  'java': 62,
  'py': 71,
  'js': 63,
  'c': 50,
  'cs': 51,
  'go': 60,
  'kt': 78,
  'php': 70,
  'rb': 72,
  'rs': 73,
  'swift': 83,
  'ts': 74,
};

class FileTypes {
  const FileTypes._();

  static const List<String> markdown = ['md', 'markdown'];

  static const List<String> plainText = ['txt', 'log', 'rtf'];

  static const List<String> programmingLanguage = [
    // Web
    'html',
    'css',
    'js',
    'ts',
    'json',
    'xml',
    'yaml',
    'yml',

    // Compiled/General
    'c',
    'cpp',
    'h',
    'cs',
    'java',
    'kt',
    'dart',
    'py',
    'go',
    'rb',
    'rs',
    'swift',
    'sh',

    // Data
    'csv',
  ];

  static const List<String> todo = ['todo'];

  static final List<String> supportedExtensions = [
    ...markdown,
    ...plainText,
    ...programmingLanguage,
    ...todo,
  ];
}
