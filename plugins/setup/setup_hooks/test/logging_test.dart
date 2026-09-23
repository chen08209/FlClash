import 'dart:io';

import 'package:logging/logging.dart';
import 'package:path/path.dart' as p;
import 'package:setup_hooks/src/logging.dart';
import 'package:test/test.dart';

void main() {
  late Directory root;

  setUp(() {
    root = Directory.systemTemp.createTempSync('setup_logging_');
  });

  tearDown(() {
    closeLogging();
    if (root.existsSync()) {
      root.deleteSync(recursive: true);
    }
  });

  test('closeLogging releases the log file so its directory can go', () {
    final logPath = hookLogPath(root.path);
    initLogging(logFile: logPath);
    Logger('setup_hooks').info('first run');

    closeLogging();

    expect(File(logPath).readAsStringSync(), 'INFO: first run\n');
    expect(() => root.deleteSync(recursive: true), returnsNormally);
  });

  test('a run after closeLogging writes to its own log file', () {
    final first = p.join(root.path, 'one', 'hook.log');
    final second = p.join(root.path, 'two', 'hook.log');
    initLogging(logFile: first);
    Logger('setup_hooks').info('one');
    closeLogging();

    initLogging(logFile: second);
    Logger('setup_hooks').info('two');
    closeLogging();

    expect(File(first).readAsStringSync(), 'INFO: one\n');
    expect(File(second).readAsStringSync(), 'INFO: two\n');
  });

  test('closeLogging without an open session is a no-op', () {
    expect(closeLogging, returnsNormally);
  });
}
