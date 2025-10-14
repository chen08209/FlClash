import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:path/path.dart';

extension ArchiveExt on Archive {
  void addDirectoryToArchive(String dirPath, String parentPath) {
    final dir = Directory(dirPath);
    if (!dir.existsSync()) {
      return;
    }
    final entities = dir.listSync(recursive: false);
    for (final entity in entities) {
      final relativePath = relative(entity.path, from: parentPath);
      if (entity is File) {
        final data = entity.readAsBytesSync();
        final archiveFile = ArchiveFile(relativePath, data.length, data);
        addFile(archiveFile);
      }
      // else if (entity is Directory) {
      //   addDirectoryToArchive(entity.path, parentPath);
      // }
    }
  }

  void addTextFile<T>(String name, T raw) {
    final data = json.encode(raw);
    addFile(ArchiveFile.string(name, data));
  }
}
