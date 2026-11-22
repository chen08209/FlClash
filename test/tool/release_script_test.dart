@TestOn('!windows')
library;

import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  late Directory repo;

  ProcessResult run(String executable, List<String> arguments) {
    return Process.runSync(
      executable,
      arguments,
      workingDirectory: repo.path,
      environment: {
        'PATH': '${p.join(repo.path, 'bin')}:${Platform.environment['PATH']}',
        'GIT_AUTHOR_NAME': 'Release test',
        'GIT_AUTHOR_EMAIL': 'release-test@example.com',
        'GIT_COMMITTER_NAME': 'Release test',
        'GIT_COMMITTER_EMAIL': 'release-test@example.com',
      },
    );
  }

  setUp(() {
    repo = Directory.systemTemp.createTempSync('flclash-release-');
    Directory(p.join(repo.path, 'tool')).createSync();
    File('tool/release.sh').copySync(p.join(repo.path, 'tool', 'release.sh'));
    File(
      p.join(repo.path, 'pubspec.yaml'),
    ).writeAsStringSync('name: app\nversion: 1.0.0+1\n');
    final dart = File(p.join(repo.path, 'bin', 'dart'))
      ..createSync(recursive: true)
      ..writeAsStringSync(
        '#!/bin/sh\n'
        'case "\$*" in *"build --unreleased"*)\n'
        '  echo "changelog.json cannot be read" >&2; exit 1 ;;\n'
        'esac\n',
      );
    run('chmod', ['+x', dart.path]);
    run('git', ['init', '--quiet', '--initial-branch=main']);
    run('git', ['add', '.']);
    run('git', ['commit', '--quiet', '--message', 'chore: start']);
  });

  tearDown(() => repo.deleteSync(recursive: true));

  test('a dry run shows why the notes could not be previewed', () {
    final result = run('bash', ['tool/release.sh', 'pre', '--dry-run']);

    expect(result.exitCode, 0, reason: '${result.stderr}');
    expect(result.stdout, contains('changelog.json cannot be read'));
    expect(run('git', ['status', '--porcelain']).stdout, isEmpty);
  });
}
