import 'package:writer/core/helpers/file_type_analyzer.dart';
import 'package:writer/core/constants/file_types.dart';

/// Helper class for file name and extension operations
class FileHelper {
  const FileHelper._();

  /// Prepares a filename with proper extension
  ///
  /// [baseTitle] - The base title or name for the file
  /// [currentExtension] - Optional current extension (without dot)
  ///
  /// Returns a properly formatted filename with extension
  static String prepareFileName(String baseTitle, String? currentExtension) {
    String fileName = baseTitle.isNotEmpty ? baseTitle : 'note';

    // If fileName already has the extension, return as is
    if (currentExtension != null && fileName.endsWith('.$currentExtension')) {
      return fileName;
    }

    // Add extension if provided and valid
    if (currentExtension != null) {
      fileName = '$fileName.$currentExtension';
    } else if (!fileName.contains('.')) {
      // Default to .txt if no extension
      fileName = '$fileName.txt';
    }

    return fileName;
  }

  /// Extracts file extension from a filename or title
  ///
  /// [fileName] - The filename to extract extension from
  ///
  /// Returns the extension without the dot, or null if no extension found
  static String? extractExtension(String fileName) {
    if (fileName.contains('.')) {
      return fileName.split('.').last;
    }
    return null;
  }

  /// Determines the final extension for a file based on title and classification
  ///
  /// [title] - The file title
  /// [existingExtension] - Optional existing extension
  ///
  /// Returns the final extension to use (without dot)
  static String determineFinalExtension(
    String title,
    String? existingExtension,
  ) {
    String? extension = existingExtension ?? extractExtension(title);

    final fileType = FileTypeAnalyzer.classifyExtension(extension);

    if (extension == null || fileType == FileType.unsupported) {
      return 'txt';
    } else {
      return extension;
    }
  }
}
