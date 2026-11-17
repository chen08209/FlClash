import 'dart:convert';
import 'dart:io';

const _usage = '''
Checks that Concord takes every key FlClash sends it.

usage: dart tool/check_sent_config.dart

Each test/fixtures/sent_config/<os>.yaml, written by
test/core/sent_config_golden_test.dart, goes through `concord -t`, which must
load it with no unknown_key, unsupported_key or not_applied warning beyond the
allowed ones below. The live patch is checked against the Core's schema by that
test. Without cargo the check is skipped and says so.''';

const _fixtures = 'test/fixtures/sent_config';

const _failing = {'unknown_key', 'unsupported_key', 'not_applied'};

/// (os, code, path) a golden may still warn about, each with the reason.
const _allowed = <(String, String, String), String>{};

Future<void> main(List<String> arguments) async {
  if (arguments.contains('-h') || arguments.contains('--help')) {
    stdout.writeln(_usage);
    return;
  }
  final cargo = await Process.run('cargo', [
    '--version',
  ]).then((result) => result.exitCode == 0, onError: (_) => false);
  if (!cargo) {
    stdout.writeln('skipped: cargo is not on PATH, so concord -t cannot run');
    return;
  }
  final failures = <String>[];
  final goldens =
      Directory(_fixtures)
          .listSync()
          .whereType<File>()
          .where((file) => file.path.endsWith('.yaml'))
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));
  if (goldens.isEmpty) {
    failures.add('$_fixtures has no goldens');
  }
  for (final golden in goldens) {
    failures.addAll(await _checkProfile(golden));
  }
  if (failures.isNotEmpty) {
    stderr.writeln(failures.join('\n'));
    exitCode = 1;
    return;
  }
  stdout.writeln('ok: ${goldens.length} profiles');
}

Future<List<String>> _checkProfile(File golden) async {
  final os = golden.uri.pathSegments.last.replaceAll('.yaml', '');
  final result = await Process.run('cargo', [
    'run',
    '--quiet',
    '--locked',
    '-p',
    'concord-desktop',
    '--',
    '-t',
    '-c',
    golden.absolute.path,
    if (os == 'android') '--android',
  ], workingDirectory: 'concord');
  final Object? report;
  try {
    report = jsonDecode(result.stdout as String);
  } on FormatException {
    return ['$os: concord -t printed no report\n${result.stderr}'];
  }
  if (report is! Map || result.exitCode != 0) {
    return ['$os: does not load: ${report is Map ? report['error'] : report}'];
  }
  return [
    for (final Map warning in report['warnings'] as List)
      if (_failing.contains(warning['code']) &&
          !_allowed.containsKey((os, warning['code'], warning['path'])))
        '$os: ${warning['code']} ${warning['path']}: ${warning['message']}',
  ];
}
