import 'dart:io';
import '../../directory/methods/directory_methods.exports.dart';
import '../../../models/exception.model.dart';

Future<
    Map<
        String,
        List<
            (
              int matchLine,
              String lineContent,
              Map<int, String> matchPositions
            )>>> searchFilesContent(
  String rootPath,
  RegExp query, {
  bool ignoreHidden = true,
  List<RegExp>? excluded,
  List<RegExp>? only,
  String? replacement,
}) async {
  final matches = <String,
      List<
          (
            int matchLine,
            String lineContent,
            Map<int, String> matchPositions
          )>>{};
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

      // Check if the entity is allowed by "only" patterns
      if (only != null &&
          only.isNotEmpty &&
          only.every((pattern) => !pattern.hasMatch(name))) {
        continue;
      }

      if (entity is File && (!ignoreHidden || !name.startsWith('.'))) {
        try {
          // Read the entire file as a single string
          final content = await entity.readAsString();

          // Encode the content to handle placeholders
          final encodedContent = encodeString(content);

          // Match the regex against the encoded content
          final matchesInFile = query.allMatches(encodedContent);
          final lineMatches =
              <int, (String lineContent, Map<int, String> matchPositions)>{};

          for (final match in matchesInFile) {
            // Decode the match to restore the original content
            final matchedText = decodeString(match.group(0)!, content);

            // Determine the line number and match position
            final matchStart = match.start;
            final lineNumber =
                content.substring(0, matchStart).split('\n').length;
            final lineContent = content.split('\n')[lineNumber - 1];
            final relativePosition = matchStart -
                content.substring(0, matchStart).lastIndexOf('\n') -
                1;

            // If the line already exists, merge matches
            if (lineMatches.containsKey(lineNumber)) {
              lineMatches[lineNumber]?.$2[relativePosition] = matchedText;
            } else {
              lineMatches[lineNumber] =
                  (lineContent.trim(), {relativePosition: matchedText});
            }
          }

          // Add all matches from this file to the final result
          lineMatches.forEach((lineNumber, matchData) {
            matches
                .putIfAbsent(entity.path, () => [])
                .add((lineNumber, matchData.$1, matchData.$2));
          });

          // Handle replacement if specified
          if (replacement != null) {
            final updatedContent =
                encodedContent.replaceAll(query, replacement);
            final decodedContent = decodeString(updatedContent, content);

            // Write updated content back to the file only if changes were made
            if (decodedContent != content) {
              await entity.writeAsString(decodedContent);
            }
          }
        } catch (e) {
          // Handle non-UTF-8 files or other exceptions as needed
        }
      }
    }
  } else {
    throw DirectoryDoesntExist(path: rootPath);
  }

  return matches;
}

String encodeString(String input) {
  return input.replaceAllMapped(
    RegExp(r'\$\{[^}]*\}'),
    (match) =>
        '__PLACEHOLDER__${match.start}__', // Replace embedded expressions with placeholders
  );
}

String decodeString(String encoded, String original) {
  return encoded.replaceAllMapped(
    RegExp(r'__PLACEHOLDER__(\d+)__'),
    (match) {
      final start = int.parse(match.group(1)!);
      final end = original.indexOf('}', start) + 1;
      return original.substring(start, end);
    },
  );
}
