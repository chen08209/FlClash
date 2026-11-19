import 'builder.dart';
import 'git.dart';
import 'models.dart';
import 'render.dart';

class ChangelogCheck {
  const ChangelogCheck({
    required this.problems,
    required this.warnings,
    required this.skipped,
  });

  final List<String> problems;
  final List<String> warnings;
  final List<String> skipped;
}

/// The newest version is checked before its tag exists too: that is the
/// release commit, where a missing entry is still cheap to fix.
ChangelogCheck checkChangelog({
  required Git git,
  required Changelog changelog,
  required String markdown,
  String boundary = frozenBoundaryTag,
}) {
  final problems = <String>[];
  if (!markdown.contains(changelogFrozenMarker)) {
    problems.add('$changelogMarkdownPath is missing the frozen marker');
  } else if (markdownHead(markdown).trimRight() !=
      renderMarkdown(changelog).trimRight()) {
    problems.add(
      '$changelogMarkdownPath does not match $changelogDataPath; '
      'run tool/changelog.dart markdown to regenerate it',
    );
  }

  final newest = changelog.versions.firstOrNull;
  final pending = newest != null && !git.tagExists(newest.tag)
      ? PendingVersion(version: newest.version, date: newest.date)
      : null;
  final expected = ChangelogBuilder(
    git,
    boundary: boundary,
  ).build(pending: pending);
  final expectedByTag = <String, ChangelogVersion>{
    for (final version in expected.changelog.versions) version.tag: version,
  };

  final skipped = <String>[];
  for (final version in changelog.versions) {
    final reference = expectedByTag[version.tag];
    if (reference == null) {
      if (git.tagIsReachable(version.tag)) {
        problems.add(
          '${version.tag} is in changelog.json but not derivable from git',
        );
      } else if (git.tagExists(version.tag)) {
        skipped.add(version.tag);
      }
      continue;
    }

    final covered = _covered(version);
    final missing = [
      for (final group in reference.groups)
        for (final entry in group.entries)
          if (!covered.contains('${group.type.id}:${entry.id}') &&
              !covered.contains(entry.id))
            '${group.type.id}:${entry.id}',
    ];
    if (missing.isNotEmpty) {
      problems.add(
        '${version.tag} is missing entries git can derive: '
        '${missing.join(', ')}.\n'
        '  Regenerate, list them under merges or omit, or mark those commits '
        'with "Changelog: skip".',
      );
    }

    final known = expected.commitIdsByTag[version.tag] ?? const <String>{};
    final unknown = [
      for (final id in _referenced(version))
        if (!known.contains(id)) id,
    ];
    if (unknown.isNotEmpty) {
      problems.add(
        '${version.tag} has entries pointing at commits outside its range: '
        '${unknown.join(', ')}',
      );
    }
  }

  for (final tag in missingReleaseTags(changelog, expected.changelog)) {
    problems.add(
      '$tag is tagged in git but missing from $changelogDataPath; '
      'run tool/changelog.dart release --version '
      '${tag.startsWith('v') ? tag.substring(1) : tag}',
    );
  }

  return ChangelogCheck(
    problems: problems,
    warnings: expected.warnings,
    skipped: skipped,
  );
}

/// An entry covers its commit only in its own group, so a commit that moved
/// group is caught; merges and omit cover a commit in any group.
Set<String> _covered(ChangelogVersion version) => <String>{
  for (final group in version.groups)
    for (final entry in group.entries) ...[
      '${group.type.id}:${entry.id}',
      ...entry.merges,
    ],
  ...version.omit,
};

Iterable<String> _referenced(ChangelogVersion version) => [
  for (final group in version.groups)
    for (final entry in group.entries) ...[entry.id, ...entry.merges],
  ...version.omit,
];
