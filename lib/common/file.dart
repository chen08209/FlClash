import 'dart:io';

extension FileExt on File {
  Future<void> safeCopy(String newPath) async {
    if (!await exists()) {
      await create(recursive: true);
      return;
    }
    final targetFile = File(newPath);
    if (!await targetFile.exists()) {
      await targetFile.create(recursive: true);
    }
    await copy(newPath);
  }

  Future<File> safeWriteAsString(String str) async {
    if (!await exists()) {
      await create(recursive: true);
    }
    return writeAsString(str);
  }

  Future<File> safeWriteAsBytes(List<int> bytes) async {
    if (!await exists()) {
      await create(recursive: true);
    }
    return writeAsBytes(bytes);
  }
}

extension FileSystemEntityExt on FileSystemEntity {
  Future<void> safeDelete({bool recursive = false}) async {
    if (!await exists()) {
      return;
    }
    await delete(recursive: recursive);
  }
}

Future<void> safeDeletePath(String path) async {
  final entity = switch (FileSystemEntity.typeSync(path)) {
    FileSystemEntityType.directory => Directory(path),
    _ => File(path),
  };
  await entity.safeDelete(recursive: true);
}
