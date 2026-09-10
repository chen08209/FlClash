import 'package:fl_clash/common/string.dart';
import 'package:test/test.dart';

void main() {
  group('StringExtension.isUrl', () {
    test('valid http URL', () {
      expect('http://example.com'.isUrl, isTrue);
    });

    test('valid https URL', () {
      expect('https://example.com/path?q=1'.isUrl, isTrue);
    });

    test('valid ftp URL', () {
      expect('ftp://files.example.com'.isUrl, isTrue);
    });

    test('invalid scheme', () {
      expect('file:///path'.isUrl, isFalse);
    });

    test('no host', () {
      expect('http://'.isUrl, isFalse);
    });

    test('plain text', () {
      expect('not a url'.isUrl, isFalse);
    });
  });

  group('StringExtension.splitByMultipleSeparators', () {
    test('splits on comma', () {
      final result = 'a,b,c'.splitByMultipleSeparators;
      expect(result, ['a', 'b', 'c']);
    });

    test('splits on semicolon', () {
      final result = 'a;b;c'.splitByMultipleSeparators;
      expect(result, ['a', 'b', 'c']);
    });

    test('splits on space', () {
      final result = 'a b c'.splitByMultipleSeparators;
      expect(result, ['a', 'b', 'c']);
    });

    test('splits on mixed separators', () {
      final result = 'a, b; c'.splitByMultipleSeparators;
      expect(result, ['a', 'b', 'c']);
    });

    test('returns original string when single part', () {
      final result = 'hello'.splitByMultipleSeparators;
      expect(result, 'hello');
    });

    test('filters empty parts', () {
      final result = 'a,,b'.splitByMultipleSeparators;
      expect(result, ['a', 'b']);
    });
  });

  group('StringExtension.compareToLower', () {
    test('case insensitive comparison', () {
      expect('abc'.compareToLower('ABC'), 0);
      expect('a'.compareToLower('b'), lessThan(0));
      expect('b'.compareToLower('a'), greaterThan(0));
    });
  });

  group('StringExtension.safeSubstring', () {
    test('returns empty for empty string', () {
      expect(''.safeSubstring(0), '');
    });

    test('returns substring from start', () {
      expect('hello'.safeSubstring(2), 'llo');
    });

    test('clamps start to length', () {
      expect('hi'.safeSubstring(10), '');
    });

    test('clamps end to length', () {
      expect('hello'.safeSubstring(1, 10), 'ello');
    });

    test('clamps negative start to 0', () {
      expect('hello'.safeSubstring(-5), 'hello');
    });
  });

  group('StringExtension.getBase64', () {
    test('extracts base64 from data URI', () {
      const data = 'data:image/png;base64,aGVsbG8=';
      final result = data.getBase64;
      expect(result, isNotNull);
      expect(result!.isNotEmpty, isTrue);
    });

    test('returns null for non-base64 string', () {
      expect('hello world'.getBase64, isNull);
    });

    test('returns null for empty match', () {
      expect('base64,'.getBase64, isNull);
    });
  });

  group('StringExtension.isSvg', () {
    test('detects SVG files', () {
      expect('icon.svg'.isSvg, isTrue);
      expect('icon.PNG'.isSvg, isFalse);
      expect('icon.svg.bak'.isSvg, isFalse);
    });
  });

  group('StringExtension.isRegex', () {
    test('valid regex', () {
      expect(r'\d+'.isRegex, isTrue);
      expect(r'[a-z]+'.isRegex, isTrue);
    });

    test('invalid regex', () {
      expect(r'['.isRegex, isFalse);
      expect(r'(unclosed'.isRegex, isFalse);
    });
  });

  group('StringExtension.toMd5', () {
    test('produces consistent hash', () {
      final hash1 = 'hello'.toMd5();
      final hash2 = 'hello'.toMd5();
      expect(hash1, hash2);
    });

    test('different input produces different hash', () {
      expect('hello'.toMd5(), isNot(equals('world'.toMd5())));
    });

    test('produces 32 char hex string', () {
      final hash = 'test'.toMd5();
      expect(hash.length, 32);
      expect(RegExp(r'^[0-9a-f]{32}$').hasMatch(hash), isTrue);
    });
  });

  group('StringExtension.value', () {
    test('returns null for empty string', () {
      expect(''.value, isNull);
    });

    test('returns self for non-empty string', () {
      expect('hello'.value, 'hello');
    });
  });

  group('StringNullExt.takeFirstValid', () {
    test('returns self when non-null and non-empty', () {
      expect('hello'.takeFirstValid(['world']), 'hello');
    });

    test('returns first valid from others when self is null', () {
      expect(null.takeFirstValid(['world', 'foo']), 'world');
    });

    test('skips null and empty in others', () {
      expect(null.takeFirstValid([null, '', 'valid']), 'valid');
    });

    test('returns default when all are null or empty', () {
      expect(
        null.takeFirstValid([null, ''], defaultValue: 'default'),
        'default',
      );
    });

    test('trims whitespace', () {
      expect('  hello  '.takeFirstValid([]), 'hello');
    });
  });

  group('StringExtension.encodeUtf16LeWithBom', () {
    test('starts with BOM', () {
      final encoded = 'A'.encodeUtf16LeWithBom;
      expect(encoded[0], 0xFF);
      expect(encoded[1], 0xFE);
    });

    test('encodes ASCII correctly', () {
      final encoded = 'AB'.encodeUtf16LeWithBom;
      // BOM + 'A' (0x41 0x00) + 'B' (0x42 0x00)
      expect(encoded.length, 2 + 4); // 2 BOM + 2 chars * 2 bytes
      expect(encoded[2], 0x41);
      expect(encoded[3], 0x00);
      expect(encoded[4], 0x42);
      expect(encoded[5], 0x00);
    });
  });

  group('StringExtension.decodeJson', () {
    test('decodes small json on main thread', () async {
      final result = await '{"key": "value"}'
          .decodeJson<Map<String, dynamic>>();
      expect(result, {'key': 'value'});
    });

    test('decodes list json', () async {
      final result = await '[1, 2, 3]'.decodeJson<List<dynamic>>();
      expect(result, [1, 2, 3]);
    });
  });
}
