import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:fl_clash/common/mitm_body.dart';
import 'package:fl_clash/common/mitm_protobuf.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

MitmBodyContent _read(
  List<int> bytes, {
  String contentType = '',
  bool truncated = false,
  String encoding = '',
}) => readMitmBody((
  MitmBody(data: base64Encode(bytes), truncated: truncated, encoding: encoding),
  contentType,
));

void main() {
  test('JSON is indented, by its type or by how it starts', () {
    for (final contentType in ['application/json; charset=utf-8', '']) {
      final content = _read(utf8.encode('{"a":[1]}'), contentType: contentType);
      expect(content.kind, MitmBodyKind.text);
      expect(content.language, Language.json);
      expect(content.text, '{\n  "a": [\n    1\n  ]\n}');
    }
    final cut = _read(
      utf8.encode('{"a":'),
      contentType: 'application/json',
      truncated: true,
    );
    expect(cut.text, '{"a":');
    expect(cut.truncated, isTrue);
  });

  test('text takes the highlighting of its type', () {
    expect(
      _read(utf8.encode('<p/>'), contentType: 'text/html').language,
      Language.xml,
    );
    expect(
      _read(utf8.encode('f()'), contentType: 'application/javascript').language,
      Language.javaScript,
    );
    expect(
      _read(utf8.encode('a=1'), contentType: 'text/plain').language,
      Language.text,
    );
  });

  test('a body cut inside a character still reads as text', () {
    final bytes = utf8.encode('名字');
    final content = _read(bytes.sublist(0, 4), truncated: true);
    expect(content.kind, MitmBodyKind.text);
    expect(content.text, startsWith('名'));
    expect(
      _read(bytes.sublist(0, 4)).kind,
      MitmBodyKind.binary,
      reason: 'a whole body that is not UTF-8 is not text',
    );
  });

  test('images, control bytes and undecoded codings keep their bytes', () {
    expect(
      _read([0x89, 0x50], contentType: 'image/png').kind,
      MitmBodyKind.image,
    );
    expect(
      _read(utf8.encode('<svg/>'), contentType: 'image/svg+xml').kind,
      MitmBodyKind.text,
    );
    expect(_read([0x41, 0x00, 0x42]).kind, MitmBodyKind.binary);
    final undecoded = _read(utf8.encode('abc'), encoding: 'compress');
    expect(undecoded.kind, MitmBodyKind.binary);
    expect(undecoded.encoding, 'compress');
  });

  test('stray control characters still read as text, shown replaced', () {
    final log = [...utf8.encode('a' * 200), 0x1b, ...utf8.encode('b' * 200)];
    final content = _read(log);
    expect(content.kind, MitmBodyKind.text);
    expect(content.text, '${'a' * 200}\ufffd${'b' * 200}');
    expect(mitmBodyText(log), isNull, reason: 'an export keeps exact bytes');
  });

  test('a NUL or a dense run of control characters is binary', () {
    expect(_read([...utf8.encode('a' * 500), 0]).kind, MitmBodyKind.binary);
    expect(_read([0x08, 0x01, 0x12, 0x03, 0x61]).kind, MitmBodyKind.binary);
  });

  test('a hex line lines up its columns, a short last line included', () {
    final bytes = Uint8List.fromList([0x41, 0x00, 0xff, 0x7e, 0x20]);
    expect(mitmHexLine(bytes, 0, 4), '000000  41 00 ff 7e  A..~');
    expect(
      mitmHexLine(bytes, 4, 4),
      '000004  20           '
      ' ',
    );
    expect(mitmHexLineLength(bytes.length, 4), 6 + 2 + 12 + 1 + 4);
    expect(mitmHexLineLength(1 << 28, 4), 8 + 2 + 12 + 1 + 4);
  });

  group('Protobuf', () {
    // 1: 150, 2: "hi", 3 { 1: 2 }
    const message = [
      0x08,
      0x96,
      0x01,
      0x12,
      0x02,
      0x68,
      0x69,
      0x1a,
      0x02,
      0x08,
      0x02,
    ];
    const shown = '1: 150\n2: "hi"\n3 {\n  1: 2\n}';

    test('reads a body its type calls Protobuf', () {
      final content = _read(message, contentType: 'application/x-protobuf');
      expect(content.format, MitmBodyFormat.protobuf);
      expect(content.text, shown);
    });

    test('guesses only where no type says what the body is', () {
      expect(
        _read(message, contentType: 'application/octet-stream').format,
        MitmBodyFormat.protobuf,
      );
      expect(
        _read(message, contentType: 'font/woff2').kind,
        MitmBodyKind.binary,
      );
      expect(_read([0xff, 0xff, 0xff]).kind, MitmBodyKind.binary);
    });

    test('a cut body reads up to the field it stops in', () {
      final content = _read(
        message.sublist(0, 6),
        contentType: 'application/protobuf',
        truncated: true,
      );
      expect(content.text, '1: 150');
      expect(content.truncated, isTrue);
    });

    test('gRPC stops inflating a frame past the limit', () {
      List<int> frame(List<int> gzipped) => [
        1,
        ...(ByteData(4)..setUint32(0, gzipped.length)).buffer.asUint8List(),
        ...gzipped,
      ];
      final bomb = gzip.encode(Uint8List(mitmGrpcInflateLimit + 1));
      final small = gzip.encode(const [0x08, 0x01]);

      final text = mitmGrpcText(
        Uint8List.fromList([...frame(small), ...frame(bomb), ...frame(small)]),
      )!;

      expect(text, startsWith('# 1\n1: 1\n# 2\n'));
      expect(text.length, lessThan(mitmGrpcInflateLimit));
      expect(text, endsWith('# 3\n1: 1'));
    });

    test('gRPC reads each frame, gzipped ones and trailers too', () {
      List<int> frame(int flag, List<int> data) => [
        flag,
        ...[0, 0, 0, data.length],
        ...data,
      ];
      final content = _read([
        ...frame(0, const [0x08, 0x01]),
        ...frame(1, gzip.encode(const [0x08, 0x02])),
        ...frame(0x80, utf8.encode('grpc-status: 0')),
      ], contentType: 'application/grpc-web+proto');
      expect(content.format, MitmBodyFormat.protobuf);
      expect(content.text, '# 1\n1: 1\n# 2\n1: 2\n# 3\ngrpc-status: 0');
    });
  });

  group('charset', () {
    const gbk = [0xc4, 0xe3, 0xba, 0xc3];

    test('a declared charset is left for Rust to read', () {
      expect(_read(gbk, contentType: 'text/plain; charset=GBK').charset, 'gbk');
      expect(_read(gbk, contentType: 'text/plain').charset, '');
      expect(
        _read(
          utf8.encode('a'),
          contentType: 'text/plain; charset=utf-8',
        ).charset,
        '',
      );
      expect(
        _read(
          latin1.encode('<meta charset="big5">'),
          contentType: 'text/html',
        ).charset,
        'big5',
      );
    });

    test('the text Rust read takes the place of the bytes', () {
      final content = _read(gbk, contentType: 'text/plain; charset=gbk');
      final read = readMitmCharsetText((
        content,
        utf8.encode('你好'),
        'text/plain; charset=gbk',
      ));
      expect(read.kind, MitmBodyKind.text);
      expect(read.text, '你好');
      expect(read.bytes, gbk);
    });
  });

  test('the preview stops at its line limit', () {
    final text = List.generate(100, (index) => 'line $index').join('\n');
    final content = _read(utf8.encode(text), contentType: 'text/plain');
    expect(content.preview.split('\n'), hasLength(30));
    expect(content.isCut, isTrue);
    expect(_read(utf8.encode('short')).isCut, isFalse);
  });

  test('a header is found whatever its case', () {
    expect(
      mitmHeaderValue({
        'content-type': ['text/plain'],
      }, 'Content-Type'),
      'text/plain',
    );
    expect(mitmHeaderValue({}, 'Content-Type'), '');
  });
}
