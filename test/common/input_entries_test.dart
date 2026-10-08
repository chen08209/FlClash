import 'package:fl_clash/common/input_entries.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('parseListInput', () {
    test('splits on newlines and both comma widths', () {
      final parsed = parseListInput('a, b，c\r\nd\n\n e ');

      expect(parsed.entries, ['a', 'b', 'c', 'd', 'e']);
      expect(parsed.isValid, isTrue);
      expect(parsed.skippedExisting, 0);
    });

    test('keeps spaces inside an item', () {
      final parsed = parseListInput('https://dns.google/dns-query#Proxy A');

      expect(parsed.entries, ['https://dns.google/dns-query#Proxy A']);
    });

    test('strips YAML sequence markers and quotes', () {
      final parsed = parseListInput("- 'geosite:cn'\n- \"+.lan\",\n- plain");

      expect(parsed.entries, ['geosite:cn', '+.lan', 'plain']);
    });

    test('keeps a rule line whole', () {
      final parsed = parseListInput(
        "DOMAIN-SUFFIX,lan,real-ip\n- 'rule-set,cn,fake-ip'\nMATCH,fake-ip\n"
        'a.com, b.com',
      );

      expect(parsed.entries, [
        'DOMAIN-SUFFIX,lan,real-ip',
        'rule-set,cn,fake-ip',
        'MATCH,fake-ip',
        'a.com',
        'b.com',
      ]);
    });

    test('merges duplicates and skips existing values', () {
      final parsed = parseListInput('a, b, a, c', existing: {'b', 'c'});

      expect(parsed.entries, ['a']);
      expect(parsed.skippedExisting, 2);
    });

    test('reports over-long items with their line', () {
      final parsed = parseListInput('ok\nfar-too-long\nfine', maxLength: 4);

      expect(parsed.entries, ['ok', 'fine']);
      expect(parsed.issues, [
        const InputIssue(
          line: 2,
          raw: 'far-too-long',
          kind: InputIssueKind.valueTooLong,
        ),
      ]);
      expect(parsed.isValid, isFalse);
    });
  });

  group('parseUrlInput', () {
    bool isHttp(String url) => url.startsWith('https://');

    test('splits on lines and any whitespace, stripping YAML markup', () {
      final parsed = parseUrlInput(
        "https://a.com/x?q=1,2  https://b.com\r\n\n- 'https://c.com'\n",
        isValid: isHttp,
      );

      expect(parsed.entries, [
        'https://a.com/x?q=1,2',
        'https://b.com',
        'https://c.com',
      ]);
      expect(parsed.isValid, isTrue);
    });

    test('keeps a share link line whole', () {
      final parsed = parseUrlInput(
        'trojan://pass@example.com:443#Hong Kong 01\nhttps://a.com https://b.com',
        isValid: (_) => true,
      );

      expect(parsed.entries, [
        'trojan://pass@example.com:443#Hong Kong 01',
        'https://a.com',
        'https://b.com',
      ]);
    });

    test('merges duplicates and skips existing urls', () {
      final parsed = parseUrlInput(
        'https://a.com\nhttps://b.com\nhttps://a.com\nhttps://c.com',
        isValid: isHttp,
        existing: {'https://b.com'},
      );

      expect(parsed.entries, ['https://a.com', 'https://c.com']);
      expect(parsed.skippedExisting, 1);
    });

    test('reports invalid urls with their line', () {
      final parsed = parseUrlInput(
        'https://a.com\nftp://b.com https://c.com',
        isValid: isHttp,
      );

      expect(parsed.entries, ['https://a.com', 'https://c.com']);
      expect(parsed.issues, [
        const InputIssue(
          line: 2,
          raw: 'ftp://b.com',
          kind: InputIssueKind.invalidUrl,
        ),
      ]);
    });
  });

  group('parseMapInput', () {
    test('splits on the first whitespace and keeps colons', () {
      final parsed = parseMapInput(
        'geosite:cn tls://1.1.1.1:853\n'
        'example.com 2001:4860:4860::8888\n'
        'local ::1',
      );

      expect(parsed.entries.map((e) => e.key), [
        'geosite:cn',
        'example.com',
        'local',
      ]);
      expect(parsed.entries.map((e) => e.value), [
        'tls://1.1.1.1:853',
        '2001:4860:4860::8888',
        '::1',
      ]);
    });

    test('accepts YAML mapping lines and key=value', () {
      final parsed = parseMapInput(
        "'geosite:cn': https://dns.google/dns-query\n"
        '"+.lan": 127.0.0.1,\n'
        'a = b\n'
        'c=d\n'
        'e : ::1',
      );

      expect(Map.fromEntries(parsed.entries), {
        'geosite:cn': 'https://dns.google/dns-query',
        '+.lan': '127.0.0.1',
        'a': 'b',
        'c': 'd',
        'e': '::1',
      });
    });

    test('reports lines without a value', () {
      final parsed = parseMapInput('ok 1\nlonely\nempty=\nfine 2');

      expect(parsed.entries.map((e) => e.key), ['ok', 'fine']);
      expect(parsed.issues, [
        const InputIssue(
          line: 2,
          raw: 'lonely',
          kind: InputIssueKind.missingValue,
        ),
        const InputIssue(
          line: 3,
          raw: 'empty=',
          kind: InputIssueKind.missingValue,
        ),
      ]);
    });

    test('reports over-long keys and values separately', () {
      final parsed = parseMapInput(
        'toolongkey v\nk toolongvalue',
        keyMaxLength: 4,
        valueMaxLength: 4,
      );

      expect(parsed.entries, isEmpty);
      expect(parsed.issues.map((issue) => issue.kind), [
        InputIssueKind.keyTooLong,
        InputIssueKind.valueTooLong,
      ]);
      expect(parsed.issues.map((issue) => issue.raw), [
        'toolongkey',
        'toolongvalue',
      ]);
    });

    test('keeps the first of duplicate keys and skips existing keys', () {
      final parsed = parseMapInput('a 1\na 2\nb 3\nc 4', existingKeys: {'b'});

      expect(Map.fromEntries(parsed.entries), {'a': '1', 'c': '4'});
      expect(parsed.skippedExisting, 1);
    });
  });
}
