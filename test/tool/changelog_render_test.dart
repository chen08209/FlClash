import 'package:test/test.dart';

import '../../tool/src/changelog/builder.dart';
import '../../tool/src/changelog/models.dart';
import '../../tool/src/changelog/render.dart';

ChangelogVersion version({
  String tag = 'v0.8.96',
  String date = '2026-08-16',
  bool prerelease = false,
  List<ChangelogGroup> groups = const [],
}) => ChangelogVersion(
  version: tag.substring(1),
  tag: tag,
  date: date,
  prerelease: prerelease,
  groups: groups,
);

ChangelogGroup entryGroup(
  ChangelogType type,
  List<(String, String?, String)> entries,
) => ChangelogGroup(
  type: type,
  entries: [
    for (final (id, scope, text) in entries)
      ChangelogEntry(id: id, scope: scope, text: text),
  ],
);

void main() {
  group('renderMarkdown', () {
    test('renders versions, groups and the frozen marker', () {
      final markdown = renderMarkdown(
        Changelog(
          versions: [
            version(
              groups: [
                entryGroup(ChangelogType.breaking, [
                  ('af20769', 'lib', 'Backups need re-import'),
                ]),
                entryGroup(ChangelogType.feat, [
                  ('1a2b3c4', 'profiles', 'Per-profile override scripts'),
                  ('2b3c4d5', null, 'Scopeless entry'),
                ]),
              ],
            ),
          ],
        ),
      );

      expect(markdown, startsWith('# Changelog\n'));
      expect(markdown, contains('## v0.8.96 (2026-08-16)'));
      expect(markdown, contains('**Breaking Changes**'));
      expect(markdown, contains('- **lib** Backups need re-import (af20769)'));
      expect(markdown, contains('- Scopeless entry (2b3c4d5)'));
      expect(markdown, contains(changelogFrozenMarker));
      expect(markdown.indexOf('**Features**'), greaterThan(0));
      expect(markdown, isNot(contains('### ')));
    });
  });

  group('mergeMarkdown', () {
    const legacy = '## v0.8.95\n\n- Optimize core service\n';

    test('keeps a legacy file below the frozen marker', () {
      final merged = mergeMarkdown(
        renderMarkdown(const Changelog(versions: [])),
        legacy,
      );

      expect(merged, contains(changelogFrozenMarker));
      expect(merged, endsWith(legacy));
      expect(
        merged.indexOf(legacy),
        greaterThan(merged.indexOf(changelogFrozenMarker)),
      );
    });

    test('is idempotent once the marker exists', () {
      final rendered = renderMarkdown(const Changelog(versions: []));
      final once = mergeMarkdown(rendered, legacy);
      final twice = mergeMarkdown(rendered, once);

      expect(twice, once);
    });

    test('replaces only the generated head on a rerun', () {
      final first = mergeMarkdown(
        renderMarkdown(const Changelog(versions: [])),
        legacy,
      );
      final second = mergeMarkdown(
        renderMarkdown(
          Changelog(
            versions: [
              version(
                groups: [
                  entryGroup(ChangelogType.fix, [
                    ('5d6e7f8', 'windows', 'Fix TUN'),
                  ]),
                ],
              ),
            ],
          ),
        ),
        first,
      );

      expect(second, contains('- **windows** Fix TUN (5d6e7f8)'));
      expect(second, endsWith(legacy));
    });
  });

  group('markdownHead', () {
    test('survives a reworded frozen note', () {
      const rendered =
          '# Changelog\n\n$changelogFrozenMarker\n<!-- an older wording -->\n\n';
      final merged = mergeMarkdown(rendered, '## v0.8.95\n\n- Old\n');

      expect(merged, isNot(contains('an older wording\n<!--')));
      expect(merged.split('<!--').length - 1, 2);
      expect(merged, endsWith('- Old\n'));
    });

    test('cuts at the frozen note', () {
      final rendered = renderMarkdown(const Changelog(versions: []));
      final merged = mergeMarkdown(rendered, '## v0.8.95\n\n- Old\n');

      expect(markdownHead(merged), rendered.trimRight());
      expect(markdownHead(merged), isNot(contains('Old')));
    });
  });

  group('renderRelease', () {
    test('wraps entries in the app readable markers', () {
      final body = renderRelease(
        version(
          groups: [
            entryGroup(ChangelogType.feat, [
              ('1a2b3c4', 'profiles', 'Scripts'),
            ]),
          ],
        ),
      );

      expect(body, startsWith(releaseBeginMarker));
      expect(body, contains(releaseEndMarker));
      expect(body, contains('- **profiles** Scripts'));
    });

    test('escapes the characters the caption parse mode would read', () {
      final text = renderTelegram(
        version(
          groups: [
            entryGroup(ChangelogType.fix, [
              ('5d6e7f8', 'core', 'Reject <script> & "quoted" input'),
            ]),
          ],
        ),
        moreUrl: 'https://example.com',
      );

      expect(
        text,
        '<b>Bug Fixes</b>\n• Reject &lt;script&gt; &amp; "quoted" input',
      );
    });

    test('says so when a version has no user facing changes', () {
      expect(renderRelease(version()), contains(emptyVersionNote));
    });

    test('carries the translated payload the app reads', () {
      final body = renderRelease(
        version(
          groups: [
            const ChangelogGroup(
              type: ChangelogType.feat,
              entries: [ChangelogEntry(id: '1a2b3c4', text: 'Scripts')],
            ),
          ],
        ),
      );

      final payload = _payloadOf(body);
      final decoded = decodeChangelog(payload);
      expect(decoded.versions.single.tag, 'v0.8.96');
      expect(
        decoded.versions.single.groups.single.entries.single.text,
        'Scripts',
      );
      expect(body.trimRight(), endsWith(releaseJsonEndMarker));
    });

    test('escapes > so an entry cannot close the comment early', () {
      final body = renderRelease(
        version(
          groups: [
            entryGroup(ChangelogType.fix, [
              ('1a2b3c4', null, 'Handle a --> sequence'),
            ]),
          ],
        ),
      );

      final payload = _payloadOf(body);
      expect(payload, isNot(contains(releaseJsonEndMarker)));
      expect(
        decodeChangelog(
          payload,
        ).versions.single.groups.single.entries.single.text,
        'Handle a --> sequence',
      );
    });
  });

  group('renderTelegram', () {
    test('renders bullets without markdown scopes', () {
      final text = renderTelegram(
        version(
          groups: [
            entryGroup(ChangelogType.fix, [('5d6e7f8', 'windows', 'Fix TUN')]),
          ],
        ),
        moreUrl: 'https://example.com',
      );

      expect(text, '<b>Bug Fixes</b>\n• Fix TUN');
    });

    test('says so when a version has no user facing changes', () {
      expect(
        renderTelegram(version(), moreUrl: 'https://example.com'),
        '• $emptyVersionNote',
      );
    });

    test('truncates past the caption limit and links out', () {
      final text = renderTelegram(
        version(
          groups: [
            entryGroup(ChangelogType.feat, [
              for (var index = 0; index < 200; index++)
                ('hash$index', null, 'A reasonably long changelog entry'),
            ]),
          ],
        ),
        moreUrl: 'https://example.com',
      );

      expect(text.length, lessThan(telegramLimit + 40));
      expect(text, endsWith('https://example.com'));
    });
  });

  group('encodeChangelog', () {
    test('round trips through json', () {
      final changelog = Changelog(
        versions: [
          version(
            groups: [
              entryGroup(ChangelogType.feat, [
                ('1a2b3c4', 'profiles', 'Scripts'),
              ]),
            ],
          ),
        ],
      );

      final decoded = decodeChangelog(encodeChangelog(changelog));

      expect(decoded.versions.single.tag, 'v0.8.96');
      expect(decoded.versions.single.groups.single.type, ChangelogType.feat);
      expect(
        decoded.versions.single.groups.single.entries.single.scope,
        'profiles',
      );
    });

    test('rejects a future schema version', () {
      final decoded = decodeChangelog('{"schemaVersion": 99, "versions": []}');

      expect(decoded.versions, isEmpty);
    });

    test('ends with a newline so the file is diff friendly', () {
      expect(encodeChangelog(const Changelog(versions: [])), endsWith('\n'));
    });
  });

  group('readPubspecVersion', () {
    test('reads the app version without the build number', () {
      expect(
        readPubspecVersion('name: fl_clash\nversion: 0.8.96+2026081501\n'),
        '0.8.96',
      );
    });
  });
}

/// The JSON between the comment markers `renderRelease` appends.
String _payloadOf(String body) {
  final start =
      body.indexOf(releaseJsonBeginMarker) + releaseJsonBeginMarker.length;
  return body.substring(start, body.indexOf(releaseJsonEndMarker, start));
}
