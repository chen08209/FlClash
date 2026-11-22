import 'dart:io';

import 'package:args/args.dart';

import 'src/changelog/builder.dart';
import 'src/changelog/git.dart';
import 'src/changelog/models.dart';
import 'src/changelog/render.dart';
import 'src/changelog/verify.dart';

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

  parser.addCommand('markdown');

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
    'markdown' => _markdown(root),
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
    recorded: _recorded(root),
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
  final result = ChangelogBuilder(
    git,
  ).build(pending: pending, recorded: _recorded(root));
  _printWarnings(result.warnings);
  _writeData(root, result.changelog);
  stdout.writeln('Wrote $changelogDataPath');
  return 0;
}

int _render(String root, ArgResults command) {
  final rest = command.rest;
  if (rest.isEmpty) {
    _fail('render needs a target: release');
  }
  final changelog = _readData(root);
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
  if (!dataFile.existsSync()) {
    _fail('$changelogDataPath is missing; run tool/changelog.dart release');
  }
  final check = checkChangelog(
    git: Git(workingDirectory: root),
    changelog: decodeChangelog(dataFile.readAsStringSync()),
    markdown: resolve(root, changelogMarkdownPath).readAsStringSync(),
  );
  _printWarnings(check.warnings);
  if (check.skipped.isNotEmpty) {
    stdout.writeln(
      'Skipped ${check.skipped.join(', ')}: tagged outside this branch, so git '
      'derives nothing to compare here.',
    );
  }
  if (check.problems.isEmpty) {
    stdout.writeln('Changelog is consistent with git.');
    return 0;
  }
  for (final problem in check.problems) {
    stderr.writeln('✗ $problem');
  }
  return 1;
}

int _markdown(String root) {
  _writeMarkdown(root, _readData(root));
  stdout.writeln('Wrote $changelogMarkdownPath');
  return 0;
}

Changelog? _recorded(String root) {
  final file = resolve(root, changelogDataPath);
  return file.existsSync() ? decodeChangelog(file.readAsStringSync()) : null;
}

Changelog _readData(String root) =>
    decodeChangelog(resolve(root, changelogDataPath).readAsStringSync());

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
  markdown              Rewrite CHANGELOG.md from changelog.json.
  render release [--tag vX] [--out file]
  verify                Check the committed changelog against git.

${parser.usage}''';

Never _fail(String message) {
  stderr.writeln(message);
  exit(64);
}
