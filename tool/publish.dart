import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';

import 'src/publish/prune.dart';
import 'src/publish/telegram.dart';

const _defaultRepository = 'chen08209/FlClash';

ArgParser createPublishArgParser() {
  return ArgParser()
    ..addOption(
      'repo',
      defaultsTo:
          Platform.environment['GITHUB_REPOSITORY'] ?? _defaultRepository,
      help: 'owner/name of the repository the release is in.',
    )
    ..addFlag(
      'dry-run',
      negatable: false,
      help: 'Print what would be sent or deleted, change nothing.',
    )
    ..addFlag('help', abbr: 'h', negatable: false)
    ..addCommand('telegram')
    ..addCommand(
      'prune',
      ArgParser()..addOption(
        'releases',
        mandatory: true,
        help: 'JSON array from the GitHub releases API.',
      ),
    );
}

Future<void> main(List<String> arguments) async {
  final parser = createPublishArgParser();
  final results = parser.parse(arguments);
  final command = results.command;
  if (results.flag('help') || command == null || command.rest.length != 1) {
    stderr
      ..writeln('Usage: dart tool/publish.dart [--dry-run] telegram <tag>')
      ..writeln(
        '       dart tool/publish.dart [--dry-run] prune <tag> '
        '--releases releases.json',
      )
      ..writeln(parser.usage);
    exitCode = 64;
    return;
  }
  final repository = results.option('repo')!;
  final dryRun = results.flag('dry-run');
  final tag = command.rest.single;
  exitCode = switch (command.name) {
    'telegram' => await _telegram(repository, tag, dryRun: dryRun),
    _ => await _prune(
      repository,
      tag,
      command.option('releases')!,
      dryRun: dryRun,
    ),
  };
}

Future<int> _telegram(
  String repository,
  String tag, {
  required bool dryRun,
}) async {
  final message = telegramReleaseMessage(repository, tag);
  if (dryRun) {
    stdout.writeln(const JsonEncoder.withIndent('  ').convert(message));
    return 0;
  }
  final token = Platform.environment['TELEGRAM_BOT_TOKEN'];
  if (token == null || token.isEmpty) {
    stderr.writeln('TELEGRAM_BOT_TOKEN is not set');
    return 1;
  }
  final problem = await postToTelegram(message, token);
  if (problem != null) {
    stderr.writeln(problem);
    return 1;
  }
  stdout.writeln('Posted $tag to $telegramChannel');
  return 0;
}

Future<int> _prune(
  String repository,
  String tag,
  String releasesPath, {
  required bool dryRun,
}) async {
  final releases = (jsonDecode(File(releasesPath).readAsStringSync()) as List)
      .cast<Map<String, dynamic>>();
  final doomed = prereleasesToPrune(releases, tag);
  if (doomed.isEmpty) {
    stdout.writeln('No prerelease to delete after $tag');
    return 0;
  }
  stdout
    ..writeln(
      '${dryRun ? 'Would delete' : 'Deleting'} these releases, keeping their '
      'tags:',
    )
    ..writeAll(doomed.map((tag) => '  $tag\n'));
  if (dryRun) return 0;
  final failed = await deleteReleases(doomed, (doomedTag) async {
    final result = await Process.run('gh', [
      'release',
      'delete',
      doomedTag,
      '--repo',
      repository,
      '--yes',
    ]);
    return result.exitCode == 0 ? null : '${result.stderr}'.trim();
  });
  failed.forEach((tag, problem) {
    stderr.writeln('Deleting $tag failed: $problem');
  });
  return failed.isEmpty ? 0 : 1;
}
