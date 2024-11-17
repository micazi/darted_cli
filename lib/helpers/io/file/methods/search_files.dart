import 'dart:io';
import '../../directory/methods/directory_methods.exports.dart';
import '../../../../models/io/exception.model.dart';

Future<Map<String, List<(int matchLine, String lineContent)>>>
    searchFilesContent(String rootPath, RegExp query,
        {bool ignoreHidden = true,
        List<RegExp>? excluded,
        String? replacement}) async {
  final matches = <String, List<(int matchLine, String lineContent)>>{};
  final dir = Directory(rootPath);

  if (await directoryExists(rootPath)) {
    await for (final entity in dir.list(recursive: true, followLinks: false)) {
      final name = entity.uri.pathSegments.last;
      // Check if the entity should be excluded based on RegExp patterns
      if (excluded != null &&
          excluded.isNotEmpty &&
          excluded.any((pattern) => pattern.hasMatch(name))) {
        continue;
      }
      if (entity is File && (!ignoreHidden || !name.startsWith('.'))) {
        try {
          // Try to read lines as UTF-8, catch any encoding errors
          final lines = await entity.readAsLines();

          for (var i = 0; i < lines.length; i++) {
            final line = lines[i];
            if (query.hasMatch(line)) {
              // Add match to the results, creating a list entry if the file path doesn't exist yet
              matches
                  .putIfAbsent(entity.path, () => [])
                  .add((i + 1, line.trim()));
              //---
              if (replacement != null) {
                final content = await entity.readAsString();
                // Replace all matches in the line
                final updatedContent = content.replaceAll(query, replacement);

                // Write updated content back to the file only if changes were made
                if (updatedContent != content) {
                  await entity.writeAsString(updatedContent);
                }
              }
              //---
            }
          }
        } catch (e) {
          // Log or handle non-UTF-8 files as needed, skipping this file
        }
      }
    }
  } else {
    throw DirectoryDoesntExist(path: rootPath);
  }

  return matches;
}
