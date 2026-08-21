import 'package:test/test.dart';

import '../../tool/src/changelog/models.dart';
import '../../tool/src/changelog/parser.dart';

RawCommit commit(String subject, [String body = '']) =>
    RawCommit(hash: 'abcdef1234567890', subject: subject, body: body);

void main() {
  group('ChangelogParser', () {
    test('uses the Changelog trailer as the user facing text', () {
      final parser = ChangelogParser();
      final items = parser.parse(
        commit('feat(profiles): support per-profile override script', '''
Adds a Dart-side hook.

Changelog: Per-profile override scripts
'''),
      );

      expect(items, hasLength(1));
      expect(items.single.type, ChangelogType.feat);
      expect(items.single.entry.scope, 'profiles');
      expect(items.single.entry.id, 'abcdef1');
      expect(items.single.entry.text, 'Per-profile override scripts');
      expect(parser.warnings, isEmpty);
    });

    test('falls back to the capitalized subject description', () {
      final items = ChangelogParser().parse(
        commit('fix(windows): keep the TUN adapter alive'),
      );

      expect(items.single.type, ChangelogType.fix);
      expect(items.single.entry.text, 'Keep the TUN adapter alive');
    });

    test('drops commits marked Changelog: skip', () {
      final items = ChangelogParser().parse(
        commit('feat(core): internal only', 'Changelog: skip'),
      );

      expect(items, isEmpty);
    });

    test('drops non user facing types without a trailer', () {
      final parser = ChangelogParser();

      expect(parser.parse(commit('refactor(lib): restructure state')), isEmpty);
      expect(parser.parse(commit('ci: enforce lint')), isEmpty);
      expect(parser.parse(commit('test: cover lifecycle')), isEmpty);
      expect(parser.warnings, isEmpty);
    });

    test('keeps a non user facing type when it carries a trailer', () {
      final items = ChangelogParser().parse(
        commit('refactor(tray): replace the fork', 'Changelog: Rebuilt tray'),
      );

      expect(items.single.type, ChangelogType.feat);
      expect(items.single.entry.text, 'Rebuilt tray');
    });

    test('honours Changelog-Type over the commit type', () {
      final items = ChangelogParser().parse(
        commit('chore(core): bump core', '''
Changelog: Update core
Changelog-Type: perf
'''),
      );

      expect(items.single.type, ChangelogType.perf);
    });

    test('warns and drops an unknown Changelog-Type', () {
      final parser = ChangelogParser();
      final items = parser.parse(
        commit('chore(core): bump core', '''
Changelog: Update core
Changelog-Type: unknown-type
'''),
      );

      expect(items, isEmpty);
      expect(parser.warnings.single, contains('unknown Changelog-Type'));
    });

    test('emits a breaking entry next to the regular one', () {
      final parser = ChangelogParser();
      final items = parser.parse(
        commit('feat(backup)!: new archive layout', '''
Changelog: Faster backups

BREAKING CHANGE: Archives from 0.8.95 and earlier need re-import
'''),
      );

      expect(items.map((item) => item.type), [
        ChangelogType.breaking,
        ChangelogType.feat,
      ]);
      expect(
        items.first.entry.text,
        'Archives from 0.8.95 and earlier need re-import',
      );
      expect(items.last.entry.text, 'Faster backups');
      expect(parser.warnings, isEmpty);
    });

    test('warns when a breaking commit has no footer', () {
      final parser = ChangelogParser();
      final items = parser.parse(commit('fix(core)!: drop the legacy socket'));

      expect(items.first.type, ChangelogType.breaking);
      expect(items.first.entry.text, 'Drop the legacy socket');
      expect(parser.warnings.single, contains('BREAKING CHANGE'));
    });

    test('treats a BREAKING CHANGE footer alone as breaking', () {
      final items = ChangelogParser().parse(
        commit(
          'fix(core): tighten the handshake',
          'BREAKING CHANGE: Old cores',
        ),
      );

      expect(items.map((item) => item.type), [
        ChangelogType.breaking,
        ChangelogType.fix,
      ]);
    });

    test('joins continuation lines of a trailer', () {
      final items = ChangelogParser().parse(
        commit('feat: multi line', '''
Changelog: A long entry
  that wraps onto a second line

Some other paragraph.
'''),
      );

      expect(
        items.single.entry.text,
        'A long entry that wraps onto a second line',
      );
    });

    test('warns about a translation trailer left in a commit', () {
      final parser = ChangelogParser();
      final items = parser.parse(commit('feat: x', 'Changelog-zh-CN: 新功能'));

      expect(items.single.entry.text, 'X');
      expect(
        parser.warnings.single,
        contains('unsupported changelog trailer: Changelog-zh-CN'),
      );
    });

    test('warns about a breaking translation trailer', () {
      final parser = ChangelogParser();
      parser.parse(commit('feat: x', 'Breaking-zh-CN: 变更'));

      expect(
        parser.warnings.single,
        contains('unsupported changelog trailer: Breaking-zh-CN'),
      );
    });

    test('falls back to the subject when Changelog: carries no text', () {
      final items = ChangelogParser().parse(
        commit('fix(core): keep the socket alive', 'Changelog:'),
      );

      expect(items.single.entry.text, 'Keep the socket alive');
    });

    test('warns about a commit that is not conventional', () {
      final parser = ChangelogParser();

      expect(parser.parse(commit('Optimize core service')), isEmpty);
      expect(parser.warnings.single, contains('not a conventional commit'));
    });

    test('handles a missing scope', () {
      final items = ChangelogParser().parse(commit('feat: add a thing'));

      expect(items.single.entry.scope, isNull);
    });
  });

  group('groupItems', () {
    test('orders groups by declaration and drops empty ones', () {
      final items = ChangelogParser().parseAll([
        commit('fix: b'),
        commit('feat: a'),
        commit('perf: c'),
        commit('feat: d'),
      ]);

      final groups = groupItems(items);

      expect(groups.map((group) => group.type), [
        ChangelogType.feat,
        ChangelogType.fix,
        ChangelogType.perf,
      ]);
      expect(groups.first.entries.map((entry) => entry.text), ['A', 'D']);
    });
  });
}
