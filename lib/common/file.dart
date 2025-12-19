import 'dart:io';

extension FileExt on File {
  Future<void> safeDelete({bool recursive = false}) async {
    if (!await exists()) {
      return;
    }
    await delete(recursive: recursive);
  }
}
