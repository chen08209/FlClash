import 'dart:io';

import 'package:test/test.dart';

import '../../tool/src/changelog/builder.dart';
import '../../tool/src/changelog/git.dart';
import '../../tool/src/changelog/models.dart';

void main() {
  late Directory repo;

  void git(List<String> arguments) {
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
  }

  void commit(String message) {
    git(['commit', '--allow-empty', '--quiet', '--message', message]);
  }

  setUp(() {
    repo = Directory.systemTemp.createTempSync('flclash-changelog-');
    git(['init', '--quiet', '--initial-branch=main']);
    git(['config', 'user.email', 'changelog-test@example.com']);
    git(['config', 'user.name', 'Changelog test']);

    commit('feat: initial release');
    git(['tag', 'v1.0.0']);

    commit('feat(a): first feature');
    commit('fix(b): first fix');
    git(['tag', 'backup-pre-squash-deadbee']);
    git(['tag', 'v1.1.0-pre.1']);

    commit('feat(c)!: second feature\n\nBREAKING CHANGE: The old flag is gone');
    git(['tag', 'v1.1.0']);

    commit('chore: bump build number');
  });

  tearDown(() {
    repo.deleteSync(recursive: true);
  });

  ChangelogBuildResult build({PendingVersion? pending}) => ChangelogBuilder(
    Git(workingDirectory: repo.path),
    boundary: 'v1.0.0',
  ).build(pending: pending);

  test('collects one section per stable tag above the boundary', () {
    final versions = build().changelog.versions;

    expect(versions.map((version) => version.tag), ['v1.1.0']);
    expect(versions.single.date, '2026-01-02');
  });

  test('a prerelease tag does not split the stable range', () {
    final groups = build().changelog.versions.single.groups;
    final features = groups
        .firstWhere((group) => group.type == ChangelogType.feat)
        .entries
        .map((entry) => entry.text);

    expect(features, ['Second feature', 'First feature']);
  });

  test('ignores tags that are not release tags', () {
    final tags = Git(workingDirectory: repo.path).versionTags();

    expect(tags.map((tag) => tag.name), ['v1.1.0', 'v1.1.0-pre.1', 'v1.0.0']);
  });

  test('lifts breaking changes into their own group', () {
    final groups = build().changelog.versions.single.groups;

    expect(groups.first.type, ChangelogType.breaking);
    expect(groups.first.entries.single.text, 'The old flag is gone');
  });

  test('a pending version covers the commits after the newest stable tag', () {
    final versions = build(
      pending: const PendingVersion(version: '1.2.0', date: '2026-02-03'),
    ).changelog.versions;

    expect(versions.map((version) => version.tag), ['v1.2.0', 'v1.1.0']);
    expect(versions.first.date, '2026-02-03');
    expect(versions.first.isEmpty, isTrue);
  });

  test('a pending version is skipped once its tag exists', () {
    final versions = build(
      pending: const PendingVersion(version: '1.1.0', date: '2026-02-03'),
    ).changelog.versions;

    expect(versions.map((version) => version.tag), ['v1.1.0']);
    expect(versions.single.date, '2026-01-02');
  });

  test('a release tag on another branch is not reachable from this one', () {
    git(['checkout', '--quiet', '-b', 'feature', 'v1.0.0']);
    commit('feat(d): work started before the release');

    final scoped = Git(workingDirectory: repo.path);

    expect(
      scoped.tagExists('v1.1.0'),
      isTrue,
      reason: 'the tag is still in the repository',
    );
    expect(
      scoped.tagIsReachable('v1.1.0'),
      isFalse,
      reason:
          'verify must skip versions the builder cannot derive here, or every '
          'branch forked before the newest release fails on an unrelated tag.',
    );
    expect(
      scoped.versionTags().map((tag) => tag.name),
      isNot(contains('v1.1.0')),
      reason: 'tagIsReachable must agree with the tags the builder walks.',
    );
    expect(
      scoped.tagIsReachable('v1.0.0'),
      isTrue,
      reason: 'a tag this branch was cut from is still checked.',
    );
  });

  test('a release tag on this branch stays checked', () {
    final scoped = Git(workingDirectory: repo.path);

    expect(scoped.tagIsReachable('v1.1.0'), isTrue);
    expect(
      scoped.versionTags().map((tag) => tag.name),
      contains('v1.1.0'),
      reason:
          'the skip must be narrow; on the release branch verify still '
          'compares every derivable version.',
    );
  });

  test('a tag with no version in changelog.json is reported', () {
    final derived = build().changelog;
    final recorded = Changelog(
      versions: derived.versions
          .where((version) => version.tag != 'v1.1.0')
          .toList(),
    );

    expect(missingReleaseTags(recorded, derived), ['v1.1.0']);
    expect(missingReleaseTags(derived, derived), isEmpty);
  });

  test('is deterministic across runs', () {
    expect(
      encodeChangelog(build().changelog),
      encodeChangelog(build().changelog),
    );
  });

  test('reports commits that are not conventional', () {
    commit('Optimize core service');

    final warnings = build(
      pending: const PendingVersion(version: '1.2.0', date: '2026-02-03'),
    ).warnings;

    expect(warnings.single, contains('not a conventional commit'));
  });
}
