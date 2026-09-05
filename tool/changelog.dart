import 'dart:io';

import 'package:args/args.dart';

import 'src/changelog/builder.dart';
import 'src/changelog/git.dart';
import 'src/changelog/models.dart';
import 'src/changelog/render.dart';

const _repository = 'chen08209/FlClash';

Future<void> main(List<String> arguments) async {
  final parser = ArgParser()
    ..addOption('root', help: 'Repository root, defaults to the cwd.');

  parser.addCommand('release')
    ..addOption('version', help: 'Version being released, without the v.')
    ..addOption('date', help: 'Release date, defaults to today.');

  parser
      .addCommand('build')
      .addFlag(
        'unreleased',
        negatable: false,
        help: 'Include commits made after the newest stable tag.',
      );

  parser.addCommand('render')
    ..addOption('tag', help: 'Version tag to render, defaults to the newest.')
    ..addOption('out', help: 'Output file, defaults to stdout.');

  parser.addCommand('verify');

  final ArgResults results;
  try {
    results = parser.parse(arguments);
  } on FormatException catch (error) {
    _fail('${error.message}\n\n${_usage(parser)}');
  }

  final command = results.command;
  if (command == null) {
    _fail(_usage(parser));
  }

  final root = results.option('root') ?? Directory.current.path;
  final exitCodeValue = switch (command.name) {
    'release' => _release(root, command),
    'build' => _build(root, command),
    'render' => _render(root, command),
    'verify' => _verify(root),
    _ => _fail(_usage(parser)),
  };
  exit(exitCodeValue);
}

int _release(String root, ArgResults command) {
  final version = command.option('version');
  if (version == null) {
    _fail('release needs --version, for example --version 0.8.96');
  }
  final result = ChangelogBuilder(Git(workingDirectory: root)).build(
    pending: PendingVersion(
      version: version,
      date: command.option('date') ?? today(),
    ),
  );
  _printWarnings(result.warnings);
  _writeData(root, result.changelog);
  _writeMarkdown(root, result.changelog);
  stdout.writeln('Wrote $changelogMarkdownPath and $changelogDataPath');
  return 0;
}

int _build(String root, ArgResults command) {
  final unreleased = command.flag('unreleased');
  final pubspec = resolve(root, 'pubspec.yaml').readAsStringSync();
  final git = Git(workingDirectory: root);
  PendingVersion? pending;
  if (unreleased) {
    pending = PendingVersion(
      version: readPubspecVersion(pubspec),
      date: today(),
      prerelease: true,
    );
    // The builder drops a pending version whose tag already exists, which for a
    // prerelease build is silent and wrong: render then picks the newest
    // version in the file, and the prerelease ships the previous release's
    // notes under its own name.
    if (git.tagExists(pending.tag)) {
      _fail(
        'build --unreleased has nothing to collect: ${pending.tag} is already '
        'tagged. Bump the version in pubspec.yaml first, or this build would '
        "publish the previous release's notes.",
      );
    }
  }
  final result = ChangelogBuilder(git).build(pending: pending);
  _printWarnings(result.warnings);
  _writeData(root, result.changelog);
  stdout.writeln('Wrote $changelogDataPath');
  return 0;
}

int _render(String root, ArgResults command) {
  final rest = command.rest;
  if (rest.isEmpty) {
    _fail('render needs a target: release or telegram');
  }
  final changelog = decodeChangelog(
    resolve(root, changelogDataPath).readAsStringSync(),
  );
  if (changelog.versions.isEmpty) {
    _fail('$changelogDataPath has no versions to render');
  }
  final tag = command.option('tag');
  final version = tag == null
      ? changelog.versions.first
      : changelog.versions.firstWhere(
          (item) => item.tag == tag,
          orElse: () => _fail('$changelogDataPath has no version $tag'),
        );

  final output = switch (rest.first) {
    'release' => renderRelease(version),
    'telegram' => renderTelegram(
      version,
      moreUrl: 'https://github.com/$_repository/releases',
    ),
    _ => _fail('Unknown render target: ${rest.first}'),
  };

  final out = command.option('out');
  if (out == null) {
    stdout.write(output);
  } else {
    resolve(root, out).writeAsStringSync(output);
  }
  return 0;
}

int _verify(String root) {
  final dataFile = resolve(root, changelogDataPath);
  final markdownFile = resolve(root, changelogMarkdownPath);
  final problems = <String>[];

  if (!dataFile.existsSync()) {
    _fail('$changelogDataPath is missing; run tool/changelog.dart release');
  }

  final changelog = decodeChangelog(dataFile.readAsStringSync());
  if (changelog.versions.isEmpty) {
    problems.add('$changelogDataPath decoded to an empty changelog');
  }

  final markdown = markdownFile.readAsStringSync();
  if (!markdown.contains(changelogFrozenMarker)) {
    problems.add('$changelogMarkdownPath is missing the frozen marker');
  } else if (markdownHead(markdown).trimRight() !=
      renderMarkdown(changelog).trimRight()) {
    problems.add(
      '$changelogMarkdownPath does not match $changelogDataPath; '
      'run tool/changelog.dart release to regenerate it',
    );
  }

  final git = Git(workingDirectory: root);
  final expected = ChangelogBuilder(git).build();
  _printWarnings(expected.warnings);
  final expectedByTag = <String, ChangelogVersion>{
    for (final version in expected.changelog.versions) version.tag: version,
  };

  final unreachable = <String>[];
  for (final version in changelog.versions) {
    if (!git.tagIsReachable(version.tag)) {
      if (git.tagExists(version.tag)) {
        unreachable.add(version.tag);
      }
      continue;
    }
    final reference = expectedByTag[version.tag];
    if (reference == null) {
      problems.add(
        '${version.tag} is in changelog.json but not derivable from git',
      );
      continue;
    }

    final missing = _fingerprint(reference).difference(_fingerprint(version));
    if (missing.isNotEmpty) {
      problems.add(
        '${version.tag} is missing entries git can derive: '
        '${missing.join(', ')}.\n'
        '  Regenerate, or mark those commits with "Changelog: skip".',
      );
    }

    final known = expected.commitIdsByTag[version.tag] ?? const <String>{};
    final unknown = <String>[
      for (final group in version.groups)
        for (final entry in group.entries)
          if (!known.contains(entry.id)) entry.id,
    ];
    if (unknown.isNotEmpty) {
      problems.add(
        '${version.tag} has entries pointing at commits outside its range: '
        '${unknown.join(', ')}',
      );
    }
  }

  // A tag git can derive a version for but changelog.json never recorded means
  // someone tagged a release without running `release` first. Without this the
  // omission only shows up at the very end of the release, when `render` finds
  // no notes for the tag being published.
  for (final tag in missingReleaseTags(changelog, expected.changelog)) {
    problems.add(
      '$tag is tagged in git but missing from $changelogDataPath; '
      'run tool/changelog.dart release --version '
      '${tag.startsWith('v') ? tag.substring(1) : tag}',
    );
  }

  if (unreachable.isNotEmpty) {
    stdout.writeln(
      'Skipped ${unreachable.join(', ')}: tagged outside this branch, so git '
      'derives nothing to compare here.',
    );
  }

  if (problems.isEmpty) {
    stdout.writeln('Changelog is consistent with git.');
    return 0;
  }
  for (final problem in problems) {
    stderr.writeln('✗ $problem');
  }
  return 1;
}

/// Identity of an entry for drift detection: which group it landed in and which
/// commit it came from. Wording and scope are deliberately excluded so a
/// maintainer can polish the text of a released version without failing CI.
Set<String> _fingerprint(ChangelogVersion version) => <String>{
  for (final group in version.groups)
    for (final entry in group.entries) '${group.type.id}:${entry.id}',
};

void _writeData(String root, Changelog changelog) {
  final file = resolve(root, changelogDataPath);
  file.parent.createSync(recursive: true);
  file.writeAsStringSync(encodeChangelog(changelog));
}

void _writeMarkdown(String root, Changelog changelog) {
  final file = resolve(root, changelogMarkdownPath);
  final existing = file.existsSync() ? file.readAsStringSync() : '';
  file.writeAsStringSync(mergeMarkdown(renderMarkdown(changelog), existing));
}

void _printWarnings(List<String> warnings) {
  for (final warning in warnings) {
    stderr.writeln('! $warning');
  }
}

String _usage(ArgParser parser) => '''
Usage: dart run tool/changelog.dart <command> [options]

Commands:
  release --version X   Rewrite CHANGELOG.md and changelog.json.
  build [--unreleased]  Rewrite changelog.json only.
  render <release|telegram> [--tag vX] [--out file]
  verify                Check the committed changelog against git.

${parser.usage}''';

Never _fail(String message) {
  stderr.writeln(message);
  exit(64);
}
