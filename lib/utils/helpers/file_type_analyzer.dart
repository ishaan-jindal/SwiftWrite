import 'package:writer/utils/constants/file_types.dart';

class FileTypeAnalyzer {
  static FileType classifyExtension(String? extension) {
    if (extension == null) {
      return FileType.plainText;
    }

    final ext = extension.toLowerCase();

    if (FileTypes.markdown.contains(ext)) {
      return FileType.markdown;
    }
    if (FileTypes.plainText.contains(ext)) {
      return FileType.plainText;
    }
    if (FileTypes.programmingLanguage.contains(ext) ||
        languageIdMap.containsKey(ext)) {
      return FileType.programmingLanguage;
    }
    if (FileTypes.todo.contains(ext)) {
      return FileType.todo;
    }

    return FileType.unsupported;
  }
}
