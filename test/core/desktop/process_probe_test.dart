import 'dart:io';

import 'package:fl_clash/core/desktop/process_probe.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('the current process is alive', () async {
    expect(await isProcessAlive(pid), isTrue);
  });

  test('an exited child process is not alive', () async {
    final process = await Process.start(
      Platform.isWindows ? 'cmd' : 'sh',
      Platform.isWindows ? ['/c', 'exit 0'] : ['-c', 'exit 0'],
    );
    await process.exitCode;

    expect(await isProcessAlive(process.pid), isFalse);
  });

  test('non-positive pids are never alive', () async {
    expect(await isProcessAlive(0), isFalse);
    expect(await isProcessAlive(-1), isFalse);
  });
}
