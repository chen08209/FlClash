import 'dart:io';

import 'package:test/test.dart';

import '../../tool/src/changelog/builder.dart';
import '../../tool/src/changelog/git.dart';
import '../../tool/src/changelog/models.dart';
import '../../tool/src/changelog/render.dart';
import '../../tool/src/changelog/verify.dart';

void main() {
  late Directory repo;
  late Git git;

  String run(List<String> arguments) {
    final result = Process.runSync(
      'git',
      arguments,
      workingDirectory: repo.path,
      environment: const {
        'GIT_AUTHOR_DATE': '2026-01-02T00:00:00Z',
        'GIT_COMMITTER_DATE': '2026-01-02T00:00:00Z',
      },
    );
    if (result.exitCode != 0) {
      fail('git ${arguments.join(' ')} failed: ${result.stderr}');
    }
    return (result.stdout as String).trim();
  }

  String commit(String message) {
    run(['commit', '--allow-empty', '--quiet', '--message', message]);
    return run(['rev-parse', '--short=7', 'HEAD']);
  }

  late String feature;
  late String fix;
  late String refactor;
  late String hidden;

  setUp(() {
    repo = Directory.systemTemp.createTempSync('flclash-changelog-verify-');
    git = Git(workingDirectory: repo.path);
    run(['init', '--quiet', '--initial-branch=main']);
    run(['config', 'user.email', 'changelog-test@example.com']);
    run(['config', 'user.name', 'Changelog test']);

    commit('feat: initial release');
    run(['tag', 'v1.0.0']);
    feature = commit('feat(a): add the panel');
    fix = commit('fix(a): keep the panel open');
    refactor = commit('refactor(b): add a PAC mode');
    hidden = commit('fix(c): handle a feature that ships off');
    run(['tag', 'v1.1.0']);
  });

  tearDown(() {
    repo.deleteSync(recursive: true);
  });

  ChangelogBuilder builder() => ChangelogBuilder(git, boundary: 'v1.0.0');

  ChangelogVersion derived() => builder().build().changelog.versions.single;

  ChangelogVersion curated({
    List<String> merges = const [],
    List<String> omit = const [],
    String entryId = '',
  }) => ChangelogVersion(
    version: '1.1.0',
    tag: 'v1.1.0',
    date: '2026-01-02',
    omit: omit,
    groups: [
      ChangelogGroup(
        type: ChangelogType.feat,
        entries: [
          ChangelogEntry(
            id: entryId.isEmpty ? feature : entryId,
            scope: 'a',
            text: 'A panel that stays open',
            merges: merges,
          ),
        ],
      ),
    ],
  );

  ChangelogCheck check(Changelog changelog) => checkChangelog(
    git: git,
    boundary: 'v1.0.0',
    changelog: changelog,
    markdown: renderMarkdown(changelog),
  );

  test('merges and omit cover the entries git derives', () {
    final changelog = Changelog(
      versions: [
        curated(merges: [fix, refactor], omit: [hidden]),
      ],
    );

    expect(check(changelog).problems, isEmpty);
  });

  test('a derived entry neither listed, merged nor omitted is missing', () {
    final changelog = Changelog(
      versions: [
        curated(merges: [fix]),
      ],
    );

    final problems = check(changelog).problems;
    expect(problems.single, contains('missing entries git can derive'));
    expect(problems.single, contains('fix:$hidden'));
  });

  test('an entry kept under another group still counts as missing', () {
    final changelog = Changelog(
      versions: [
        ChangelogVersion(
          version: '1.1.0',
          tag: 'v1.1.0',
          date: '2026-01-02',
          omit: [feature, hidden],
          groups: [
            ChangelogGroup(
              type: ChangelogType.feat,
              entries: [ChangelogEntry(id: fix, text: 'Keep the panel open')],
            ),
          ],
        ),
      ],
    );

    expect(check(changelog).problems.single, contains('fix:$fix'));
  });

  test('an id, merge or omission outside the range is reported', () {
    final outside = run(['rev-parse', '--short=7', 'v1.0.0']);
    final changelog = Changelog(
      versions: [
        curated(merges: [fix, refactor, outside], omit: [hidden, 'deadbee']),
      ],
    );

    final problems = check(changelog).problems;
    expect(problems.single, contains('outside its range'));
    expect(problems.single, contains(outside));
    expect(problems.single, contains('deadbee'));
  });

  test('the newest version is checked before its tag exists', () {
    run(['tag', '--delete', 'v1.1.0']);
    final changelog = Changelog(
      versions: [
        curated(merges: [fix]),
      ],
    );

    final problems = check(changelog).problems;
    expect(problems.single, contains('fix:$hidden'));
  });

  test('a CHANGELOG.md that does not match the data is reported', () {
    final changelog = Changelog(
      versions: [
        curated(merges: [fix, refactor], omit: [hidden]),
      ],
    );

    final problems = checkChangelog(
      git: git,
      boundary: 'v1.0.0',
      changelog: changelog,
      markdown: renderMarkdown(Changelog(versions: [derived()])),
    ).problems;
    expect(problems.single, contains('does not match'));
  });

  test('a recorded stable version survives the next build as written', () {
    commit('feat(d): next feature');
    final recorded = Changelog(
      versions: [
        curated(merges: [fix, refactor], omit: [hidden]),
      ],
    );

    final versions = builder()
        .build(
          pending: const PendingVersion(version: '1.2.0', date: '2026-02-03'),
          recorded: recorded,
        )
        .changelog
        .versions;

    expect(versions.map((version) => version.tag), ['v1.2.0', 'v1.1.0']);
    expect(
      encodeChangelog(Changelog(versions: [versions.last])),
      encodeChangelog(recorded),
    );
    expect(versions.first.groups.single.entries.single.text, 'Next feature');
  });

  test('a recorded prerelease section is derived again', () {
    commit('feat(d): next feature');
    final recorded = Changelog(
      versions: [
        const ChangelogVersion(
          version: '1.2.0',
          tag: 'v1.2.0',
          date: '2026-02-01',
          prerelease: true,
          groups: [],
        ),
        derived(),
      ],
    );

    final versions = builder()
        .build(
          pending: const PendingVersion(version: '1.2.0', date: '2026-02-03'),
          recorded: recorded,
        )
        .changelog
        .versions;

    expect(versions.first.date, '2026-02-03');
    expect(versions.first.groups.single.entries.single.text, 'Next feature');
  });

  test('merges and omit survive a JSON round trip', () {
    final changelog = Changelog(
      versions: [
        curated(merges: [fix], omit: [hidden]),
      ],
    );

    final decoded = decodeChangelog(encodeChangelog(changelog));

    expect(decoded.versions.single.omit, [hidden]);
    expect(decoded.versions.single.groups.single.entries.single.merges, [fix]);
    expect(encodeChangelog(decoded), encodeChangelog(changelog));
  });

  test(
    'an entry without merges and a version without omit keep their JSON',
    () {
      final json = derived().toJson();

      expect(json.containsKey('omit'), isFalse);
      expect(
        (json['groups'] as List<dynamic>)
            .cast<Map<String, dynamic>>()
            .expand((group) => group['entries'] as List<dynamic>)
            .cast<Map<String, dynamic>>()
            .any((entry) => entry.containsKey('merges')),
        isFalse,
      );
    },
  );
}
