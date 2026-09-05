import 'dart:convert';

import 'package:fl_clash/models/changelog.dart';
import 'package:flutter_test/flutter_test.dart';

const _payload = '''
{
  "schemaVersion": 2,
  "versions": [
    {
      "version": "0.8.96",
      "tag": "v0.8.96",
      "date": "2026-08-16",
      "prerelease": false,
      "groups": [
        {
          "type": "breaking",
          "entries": [
            {
              "id": "af20769",
              "scope": "lib",
              "text": "Backups need re-import"
            }
          ]
        },
        {
          "type": "feat",
          "entries": [
            {
              "id": "1a2b3c4",
              "text": "Override scripts"
            }
          ]
        }
      ]
    }
  ]
}
''';

Changelog decode(String source) =>
    Changelog.fromJson(jsonDecode(source) as Map<String, dynamic>);

void main() {
  group('Changelog.fromJson', () {
    test('decodes the payload written by tool/changelog.dart', () {
      final changelog = decode(_payload);

      expect(changelog.isSupported, isTrue);
      expect(changelog.versions.single.tag, 'v0.8.96');
      expect(changelog.versions.single.date, '2026-08-16');
      expect(changelog.versions.single.prerelease, isFalse);
      expect(
        changelog.versions.single.groups.first.type,
        ChangelogType.breaking,
      );
      expect(
        changelog.versions.single.groups.first.entries.single.scope,
        'lib',
      );
    });

    test('maps an unrecognised group type to unknown instead of throwing', () {
      final changelog = decode('''
{
  "schemaVersion": 2,
  "versions": [
    {
      "version": "0.9.0",
      "tag": "v0.9.0",
      "groups": [
        {"type": "docs", "entries": [{"id": "abc1234", "text": "x"}]}
      ]
    }
  ]
}
''');

      expect(
        changelog.versions.single.groups.single.type,
        ChangelogType.unknown,
      );
      expect(changelog.versions.single.visibleGroups, isEmpty);
      expect(changelog.versions.single.isEmpty, isTrue);
    });

    test('reports an unsupported schema version', () {
      expect(
        decode('{"schemaVersion": 99, "versions": []}').isSupported,
        isFalse,
      );
    });

    test('tolerates a version without optional fields', () {
      final changelog = decode(
        '{"schemaVersion": 2, "versions": [{"version": "1.0.0", "tag": "v1.0.0"}]}',
      );

      expect(changelog.versions.single.date, '');
      expect(changelog.versions.single.groups, isEmpty);
    });
  });

  group('ChangelogEntry.text', () {
    test('decodes the entry text as a plain string', () {
      final entry = decode(_payload).versions.single.groups.last.entries.single;

      expect(entry.text, 'Override scripts');
    });

    test('defaults to an empty string when the field is missing', () {
      const entry = ChangelogEntry(id: 'abc1234');

      expect(entry.text, '');
    });
  });
}
