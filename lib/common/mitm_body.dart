import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:fl_clash/common/mitm_protobuf.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';

enum MitmBodyKind { text, image, binary }

enum MitmBodyFormat { plain, protobuf }

/// A captured body made ready to show: text, indented when it is JSON, or the
/// bytes of an image or of anything that does not read as text.
class MitmBodyContent {
  const MitmBodyContent({
    required this.kind,
    required this.bytes,
    this.text = '',
    this.preview = '',
    this.language = Language.text,
    this.truncated = false,
    this.encoding = '',
    this.format = MitmBodyFormat.plain,
    this.charset = '',
  });

  final MitmBodyKind kind;
  final Uint8List bytes;
  final String text;

  /// The start of [text] a detail page shows in place.
  final String preview;
  final Language language;
  final bool truncated;
  final String encoding;
  final MitmBodyFormat format;

  /// A charset the text is declared in, which only Rust can read.
  final String charset;

  bool get isCut => preview.length < text.length;
}

const _previewLines = 30;
const _previewChars = 3000;
const _maxControlShare = 0.01;
const _replacement = 0xfffd;
const _minOffsetDigits = 6;
const _charsetSniffBytes = 1024;

String mitmHeaderValue(Map<String, List<String>> header, String name) {
  final lower = name.toLowerCase();
  for (final MapEntry(:key, :value) in header.entries) {
    if (key.toLowerCase() == lower && value.isNotEmpty) {
      return value.first;
    }
  }
  return '';
}

/// Runs off the UI isolate: a body is up to the Core's size limit.
MitmBodyContent readMitmBody((MitmBody, String) input) {
  final (body, contentType) = input;
  final bytes = base64Decode(body.data);
  final mime = contentType.split(';').first.trim().toLowerCase();
  MitmBodyContent binary() => MitmBodyContent(
    kind: MitmBodyKind.binary,
    bytes: bytes,
    truncated: body.truncated,
    encoding: body.encoding,
  );
  if (body.encoding.isNotEmpty) {
    return binary();
  }
  if (mime.startsWith('image/') && !mime.contains('svg')) {
    return MitmBodyContent(
      kind: MitmBodyKind.image,
      bytes: bytes,
      truncated: body.truncated,
    );
  }
  MitmBodyContent? parsed(String? text) => text == null
      ? null
      : MitmBodyContent(
          kind: MitmBodyKind.text,
          bytes: bytes,
          text: text,
          preview: _previewOf(text),
          truncated: body.truncated,
          format: MitmBodyFormat.protobuf,
        );
  if (mime.startsWith('application/grpc')) {
    final grpc = parsed(mitmGrpcText(bytes, truncated: body.truncated));
    if (grpc != null) {
      return grpc;
    }
  } else if (mime.contains('proto')) {
    final protobuf = parsed(mitmProtobufText(bytes, cut: body.truncated));
    if (protobuf != null) {
      return protobuf;
    }
  }
  final charset = _declaredCharset(bytes, contentType, mime);
  final utf8Text = _utf8Text(bytes, truncated: body.truncated);
  final text = utf8Text == null ? null : _readableText(utf8Text);
  if (text == null) {
    if (charset.isNotEmpty) {
      return MitmBodyContent(
        kind: MitmBodyKind.binary,
        bytes: bytes,
        truncated: body.truncated,
        charset: charset,
      );
    }
    final guessed = !body.truncated && _mayBeProtobuf(mime)
        ? parsed(mitmProtobufText(bytes, guessed: true))
        : null;
    return guessed ?? binary();
  }
  return _textContent(bytes, text, mime, body.truncated, charset: charset);
}

/// [content] once Rust has read its declared charset into [input]'s UTF-8.
MitmBodyContent readMitmCharsetText(
  (MitmBodyContent content, Uint8List utf8Bytes, String contentType) input,
) {
  final (content, utf8Bytes, contentType) = input;
  final text = _readableText(utf8.decode(utf8Bytes, allowMalformed: true));
  if (text == null) {
    return content;
  }
  return _textContent(
    content.bytes,
    text,
    contentType.split(';').first.trim().toLowerCase(),
    content.truncated,
  );
}

MitmBodyContent _textContent(
  Uint8List bytes,
  String text,
  String mime,
  bool truncated, {
  String charset = '',
}) {
  final language = _languageOf(mime, text);
  final shown = language == Language.json ? _indented(text) : text;
  return MitmBodyContent(
    kind: MitmBodyKind.text,
    bytes: bytes,
    text: shown,
    preview: _previewOf(shown),
    language: language,
    truncated: truncated,
    charset: charset,
  );
}

bool _mayBeProtobuf(String mime) =>
    mime.isEmpty || mime == 'application/octet-stream';

final _charsetInType = RegExp(r'''charset\s*=\s*["']?([\w.:-]+)''');
final _charsetInMarkup = RegExp(
  r'''<(?:meta[^>]+charset|\?xml[^>]+encoding)\s*=\s*["']?([\w.:-]+)''',
  caseSensitive: false,
);

/// Empty for UTF-8. Pages often declare it only in their markup, which HTML
/// keeps to the first 1024 bytes.
String _declaredCharset(Uint8List bytes, String contentType, String mime) {
  var match = _charsetInType.firstMatch(contentType);
  if (match == null && (mime.isEmpty || mime.contains('ml'))) {
    final head = bytes.length > _charsetSniffBytes
        ? Uint8List.sublistView(bytes, 0, _charsetSniffBytes)
        : bytes;
    match = _charsetInMarkup.firstMatch(latin1.decode(head));
  }
  final charset = match?.group(1)?.toLowerCase() ?? '';
  return const {'utf-8', 'utf8', 'us-ascii', 'ascii'}.contains(charset)
      ? ''
      : charset;
}

/// Null for bytes that are not UTF-8 or carry control characters.
String? mitmBodyText(List<int> bytes, {bool truncated = false}) {
  final text = _utf8Text(bytes, truncated: truncated);
  if (text == null) {
    return null;
  }
  return text.codeUnits.any(_isControl) ? null : text;
}

/// A body whose text [mitmBodyText] would not hand back is copied as Base64.
String mitmBodyCopyText(MitmBody body) {
  if (body.encoding.isNotEmpty) {
    return body.data;
  }
  return mitmBodyText(base64Decode(body.data), truncated: body.truncated) ??
      body.data;
}

/// Logs carry stray colour codes; a NUL or a denser run is a binary format that
/// happens to be valid UTF-8.
String? _readableText(String text) {
  final units = text.codeUnits;
  var controls = 0;
  for (final unit in units) {
    if (unit == 0) {
      return null;
    }
    if (_isControl(unit)) {
      controls++;
    }
  }
  if (controls == 0) {
    return text;
  }
  if (controls > units.length * _maxControlShare) {
    return null;
  }
  return String.fromCharCodes(
    units.map((unit) => _isControl(unit) ? _replacement : unit),
  );
}

String? _utf8Text(List<int> bytes, {required bool truncated}) {
  try {
    // A body cut at the limit can end inside a character.
    return utf8.decode(bytes, allowMalformed: truncated);
  } on FormatException {
    return null;
  }
}

bool _isControl(int unit) =>
    unit < 0x20 && unit != 0x09 && unit != 0x0a && unit != 0x0d;

String mitmHexLine(Uint8List bytes, int offset, int perLine) {
  final digits = mitmHexOffsetDigits(bytes.length);
  final end = min(offset + perLine, bytes.length);
  final hex = StringBuffer();
  final ascii = StringBuffer();
  for (var i = offset; i < offset + perLine; i++) {
    if (i >= end) {
      hex.write('   ');
      continue;
    }
    final byte = bytes[i];
    hex
      ..write(byte.toRadixString(16).padLeft(2, '0'))
      ..write(' ');
    ascii.writeCharCode(byte >= 0x20 && byte < 0x7f ? byte : 0x2e);
  }
  return '${offset.toRadixString(16).padLeft(digits, '0')}  $hex $ascii';
}

int mitmHexOffsetDigits(int length) =>
    max(_minOffsetDigits, length.toRadixString(16).length);

int mitmHexLineLength(int length, int perLine) =>
    mitmHexOffsetDigits(length) + 2 + perLine * 3 + 1 + perLine;

Language _languageOf(String mime, String text) {
  if (mime.contains('json')) {
    return Language.json;
  }
  if (mime.contains('javascript') || mime.contains('ecmascript')) {
    return Language.javaScript;
  }
  if (mime.contains('xml') || mime.contains('html')) {
    return Language.xml;
  }
  final start = text.trimLeft();
  if (mime.isEmpty && (start.startsWith('{') || start.startsWith('['))) {
    return Language.json;
  }
  return Language.text;
}

String _indented(String text) {
  try {
    return const JsonEncoder.withIndent('  ').convert(jsonDecode(text));
  } on FormatException {
    return text;
  }
}

String _previewOf(String text) {
  var end = text.length < _previewChars ? text.length : _previewChars;
  var lines = 0;
  for (var i = 0; i < end; i++) {
    if (text.codeUnitAt(i) == 0x0a && ++lines == _previewLines) {
      end = i;
      break;
    }
  }
  return text.substring(0, end);
}
