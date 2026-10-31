import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

const _maxDepth = 16;
const _maxHexBytes = 256;
const _maxGuessedFieldNumber = 1 << 16;

class _Field {
  const _Field(this.number, this.show);

  final int number;
  final void Function(StringBuffer out, String indent) show;
}

/// Reads [bytes] as `protoc --decode_raw` does, without a schema. A field of
/// bytes shows as text first: the same bytes often also parse as a message.
/// [cut] takes a body that stops inside a field, up to that field; [guessed]
/// is for a body no header calls Protobuf, and asks for plausible numbers.
String? mitmProtobufText(
  Uint8List bytes, {
  bool cut = false,
  bool guessed = false,
}) {
  final fields = _parse(bytes, 0, bytes.length, 0, cut: cut);
  if (fields == null || fields.isEmpty) {
    return null;
  }
  if (guessed && fields.any((field) => field.number > _maxGuessedFieldNumber)) {
    return null;
  }
  final out = StringBuffer();
  _write(out, fields, '');
  return out.toString().trimRight();
}

const mitmGrpcInflateLimit = 8 << 20;

/// The messages of a gRPC or gRPC-Web body, each read as Protobuf.
String? mitmGrpcText(Uint8List bytes, {bool truncated = false}) {
  final out = StringBuffer();
  var inflated = 0;
  final view = ByteData.sublistView(bytes);
  var offset = 0;
  var index = 0;
  while (offset + 5 <= bytes.length) {
    final flag = bytes[offset];
    final length = view.getUint32(offset + 1);
    final start = offset + 5;
    final end = start + length;
    if (end > bytes.length) {
      if (!truncated) {
        return null;
      }
      break;
    }
    final frame = Uint8List.sublistView(bytes, start, end);
    out.writeln('# ${++index}');
    // gRPC-Web sends its trailers as a last frame of header lines.
    if (flag & 0x80 != 0) {
      out.writeln(latin1.decode(frame).trim());
    } else {
      final compressed = flag & 1 != 0;
      final message = compressed
          ? _gunzip(frame, mitmGrpcInflateLimit - inflated)
          : frame;
      if (compressed) {
        inflated += message?.length ?? 0;
      }
      final text = message == null ? null : mitmProtobufText(message);
      out.writeln(text ?? _hex(message ?? frame));
    }
    offset = end;
  }
  if (index == 0 || !truncated && offset != bytes.length) {
    return null;
  }
  return out.toString().trimRight();
}

/// Null for a frame that is not gzip or inflates past [limit].
Uint8List? _gunzip(Uint8List frame, int limit) {
  final filter = RawZLibFilter.inflateFilter();
  final out = BytesBuilder(copy: false);
  bool drain({bool end = false}) {
    while (true) {
      final chunk = filter.processed(flush: end, end: end);
      if (chunk == null) {
        return true;
      }
      out.add(chunk);
      if (out.length > limit) {
        return false;
      }
    }
  }

  try {
    filter.process(frame, 0, frame.length);
    if (!drain()) {
      return null;
    }
    filter.process(const [], 0, 0);
    return drain(end: true) ? out.takeBytes() : null;
  } on FormatException {
    return null;
  }
}

List<_Field>? _parse(
  Uint8List bytes,
  int start,
  int end,
  int depth, {
  bool cut = false,
}) {
  final view = ByteData.sublistView(bytes);
  final fields = <_Field>[];
  var offset = start;
  (int, int)? varint() {
    var value = 0;
    for (var shift = 0, at = offset; shift < 70 && at < end; shift += 7, at++) {
      final byte = bytes[at];
      value |= (byte & 0x7f) << shift;
      if (byte & 0x80 == 0) {
        return (value, at + 1);
      }
    }
    return null;
  }

  List<_Field>? stopped() => cut && fields.isNotEmpty ? fields : null;

  while (offset < end) {
    final key = varint();
    if (key == null) {
      return stopped();
    }
    final (tag, afterKey) = key;
    final number = tag >>> 3;
    if (number == 0 || number > 0x1fffffff) {
      return stopped();
    }
    offset = afterKey;
    switch (tag & 7) {
      case 0:
        final value = varint();
        if (value == null) {
          return stopped();
        }
        offset = value.$2;
        final shown = value.$1 < 0
            ? BigInt.from(value.$1).toUnsigned(64).toString()
            : '${value.$1}';
        fields.add(
          _Field(number, (out, indent) {
            out.writeln('$indent$number: $shown');
          }),
        );
      case 1:
        if (offset + 8 > end) {
          return stopped();
        }
        final value = view.getUint64(offset, Endian.little);
        final shown = BigInt.from(value).toUnsigned(64).toRadixString(16);
        offset += 8;
        fields.add(
          _Field(number, (out, indent) {
            out.writeln('$indent$number: 0x${shown.padLeft(16, '0')}');
          }),
        );
      case 2:
        final length = varint();
        if (length == null) {
          return stopped();
        }
        final bodyStart = length.$2;
        final bodyEnd = bodyStart + length.$1;
        if (length.$1 < 0 || bodyEnd > end) {
          return stopped();
        }
        offset = bodyEnd;
        fields.add(_lengthDelimited(bytes, number, bodyStart, bodyEnd, depth));
      case 5:
        if (offset + 4 > end) {
          return stopped();
        }
        final value = view.getUint32(offset, Endian.little);
        offset += 4;
        fields.add(
          _Field(number, (out, indent) {
            out.writeln(
              '$indent$number: 0x${value.toRadixString(16).padLeft(8, '0')}',
            );
          }),
        );
      default:
        return stopped();
    }
  }
  return fields;
}

_Field _lengthDelimited(
  Uint8List bytes,
  int number,
  int start,
  int end,
  int depth,
) {
  final body = Uint8List.sublistView(bytes, start, end);
  final text = _printable(body);
  if (text != null) {
    return _Field(number, (out, indent) {
      out.writeln('$indent$number: ${jsonEncode(text)}');
    });
  }
  final nested = depth < _maxDepth
      ? _parse(bytes, start, end, depth + 1)
      : null;
  if (nested == null || nested.isEmpty) {
    return _Field(number, (out, indent) {
      out.writeln('$indent$number: ${_hex(body)}');
    });
  }
  return _Field(number, (out, indent) {
    out.writeln('$indent$number {');
    _write(out, nested, '$indent  ');
    out.writeln('$indent}');
  });
}

String? _printable(Uint8List bytes) {
  for (final byte in bytes) {
    if (byte < 0x20 && byte != 0x09 && byte != 0x0a && byte != 0x0d) {
      return null;
    }
  }
  try {
    return utf8.decode(bytes);
  } on FormatException {
    return null;
  }
}

void _write(StringBuffer out, List<_Field> fields, String indent) {
  for (final field in fields) {
    field.show(out, indent);
  }
}

String _hex(Uint8List bytes) {
  final shown = bytes.length > _maxHexBytes
      ? Uint8List.sublistView(bytes, 0, _maxHexBytes)
      : bytes;
  final hex = shown
      .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
      .join();
  return bytes.length > _maxHexBytes
      ? '<$hex… ${bytes.length} bytes>'
      : '<$hex>';
}
