import 'dart:io';
import 'dart:typed_data';
import 'package:darted_cli/io_helper.dart';
import 'package:test/test.dart';

void main() {
  group('Filesystem Operations Regression', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('darted_io_test_');
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('creates, reads, writes and deletes files', () async {
      final filePath = '${tempDir.path}/hello.txt';

      await IOHelper.file.create(filePath);
      expect(await IOHelper.file.exists(filePath), isTrue);

      await IOHelper.file.writeString(filePath, 'Hello Darted!');
      final content = await IOHelper.file.readAsString(filePath);
      expect(content, equals('Hello Darted!'));

      // Test byte writing with rewrite parameter
      final bytes = Uint8List.fromList([1, 2, 3, 4]);
      final byteFilePath = '${tempDir.path}/bytes.bin';
      await IOHelper.file.writeBytes(byteFilePath, bytes, rewrite: true);
      final readBytes = await IOHelper.file.readAsBytes(byteFilePath);
      expect(readBytes, equals(bytes));

      await IOHelper.file.delete(filePath);
      expect(await IOHelper.file.exists(filePath), isFalse);
    });

    test('creates, lists, copies, moves, and deletes directories', () async {
      final subDirPath = '${tempDir.path}/sub_dir';
      final createdDir = await IOHelper.directory.create(subDirPath);
      expect(await IOHelper.directory.exists(subDirPath), isTrue);
      expect(createdDir.existsSync(), isTrue);

      final testFile = '${subDirPath}/nested.txt';
      await IOHelper.file.writeString(testFile, 'nested content');

      // Copy directory
      final copiedDirPath = '${tempDir.path}/copied_dir';
      await IOHelper.directory.copy(subDirPath, copiedDirPath);
      expect(await IOHelper.directory.exists(copiedDirPath), isTrue);
      expect(await IOHelper.file.exists('${copiedDirPath}/nested.txt'), isTrue);

      // Move directory into target parent
      final targetParentDir = '${tempDir.path}/target_parent';
      await IOHelper.directory.create(targetParentDir);
      await IOHelper.directory.move(copiedDirPath, targetParentDir);
      expect(await IOHelper.directory.exists(copiedDirPath), isFalse);
      expect(await IOHelper.directory.exists('$targetParentDir/copied_dir'),
          isTrue);

      // Delete directory
      await IOHelper.directory.delete(targetParentDir, recursive: true);
      expect(await IOHelper.directory.exists(targetParentDir), isFalse);
    });

    test('searches and replaces file content with regex', () async {
      final file1 = '${tempDir.path}/file1.txt';
      final file2 = '${tempDir.path}/file2.txt';

      await IOHelper.file
          .writeString(file1, 'target_alpha in line 1\nsecond line');
      await IOHelper.file.writeString(file2, 'no match here');

      final searchResults = await IOHelper.file.search(
        tempDir.path,
        RegExp(r'target_\w+'),
      );
      expect(searchResults.keys.any((k) => k.contains('file1.txt')), isTrue);

      await IOHelper.file.searchAndReplace(
        tempDir.path,
        RegExp(r'target_alpha'),
        replacement: 'replaced_alpha',
      );

      final updatedContent = await IOHelper.file.readAsString(file1);
      expect(updatedContent, contains('replaced_alpha'));
      expect(updatedContent, isNot(contains('target_alpha')));
    });
  });
}
