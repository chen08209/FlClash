part of '../controller.dart';

/// Stays its creator's to dispose, also once a controller has loaded it.
final class CodeForgeDocument {
  CodeForgeDocument._(this._rope, [this._text]);

  final Rope _rope;
  final String? _text;

  static Future<CodeForgeDocument> openFile(String path) async {
    try {
      return CodeForgeDocument._(await Rope.openFile(path));
    } on EditorOpenError catch (error) {
      throw switch (error.kind) {
        EditorOpenErrorKind.notFound => PathNotFoundException(
          path,
          OSError(error.message),
        ),
        EditorOpenErrorKind.notUtf8 => FormatException(error.message),
        EditorOpenErrorKind.unreadable => FileSystemException(
          error.message,
          path,
        ),
      };
    }
  }

  static Future<CodeForgeDocument> fromUtf8(Uint8List bytes) async {
    try {
      return CodeForgeDocument._(await Rope.fromUtf8(bytes));
    } on EditorOpenError catch (error) {
      throw FormatException(error.message);
    }
  }

  static Future<CodeForgeDocument> fromText(String text) async {
    if (text.length < backgroundTextLength) {
      final document = CodeForgeController.normalizeLineBreaks(text);
      return CodeForgeDocument._(Rope(document), document);
    }
    return fromUtf8(await Isolate.run(() => utf8.encode(text)));
  }

  void dispose() => _rope.dispose();
}
