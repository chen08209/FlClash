import 'dart:io';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;

typedef InputProcessRunner =
    Future<ProcessResult> Function(
      String executable,
      List<String> arguments,
      String input,
    );

typedef PasswordPrompt = Future<String?> Function();

/// pkexec exits 127 when it cannot obtain an authorization at all, which is
/// what happens without a polkit agent, as under many tiling window managers;
/// 126 is the user dismissing the dialog and is final.
const _pkexecNotAuthorized = 127;

class LinuxElevation {
  @visibleForTesting
  ProcessRunner run = Process.run;

  @visibleForTesting
  InputProcessRunner runWithInput = _runWithInput;

  @visibleForTesting
  PasswordPrompt askPassword = _askPassword;

  Future<bool> elevate(List<String> command) async {
    try {
      final result = await run('pkexec', command);
      if (result.exitCode != _pkexecNotAuthorized) {
        return _succeeded('pkexec', result);
      }
      commonPrint.log(
        'pkexec could not ask for authorization, falling back to sudo: '
        '${result.stderr.toString().trim()}',
        logLevel: LogLevel.warning,
      );
    } on ProcessException catch (error) {
      commonPrint.log(
        'pkexec is unavailable, falling back to sudo: ${compactError(error)}',
        logLevel: LogLevel.warning,
      );
    }
    return _sudo(command);
  }

  Future<bool> _sudo(List<String> command) async {
    try {
      final cached = await run('sudo', ['-n', '--', ...command]);
      if (cached.exitCode == 0) {
        return true;
      }
      final probe = await run('sudo', ['-n', 'true']);
      if (probe.exitCode == 0) {
        return _succeeded('sudo', cached);
      }
      final password = await askPassword();
      if (password == null) {
        return false;
      }
      final result = await runWithInput('sudo', [
        '-S',
        '-p',
        '',
        '--',
        ...command,
      ], '$password\n');
      return _succeeded('sudo', result);
    } on ProcessException catch (error) {
      commonPrint.log(
        'sudo is unavailable: ${compactError(error)}',
        logLevel: LogLevel.error,
      );
      return false;
    }
  }

  bool _succeeded(String executable, ProcessResult result) {
    if (result.exitCode != 0) {
      commonPrint.log(
        '$executable exited with ${result.exitCode}: '
        '${result.stderr.toString().trim()}',
        logLevel: LogLevel.error,
      );
    }
    return result.exitCode == 0;
  }

  static Future<ProcessResult> _runWithInput(
    String executable,
    List<String> arguments,
    String input,
  ) async {
    final process = await Process.start(executable, arguments);
    final stdout = process.stdout.transform(systemEncoding.decoder).join();
    final stderr = process.stderr.transform(systemEncoding.decoder).join();
    try {
      process.stdin.write(input);
      await process.stdin.close();
    } on IOException {
      // A sudo that needed no password may have exited before reading it.
    }
    return ProcessResult(
      process.pid,
      await process.exitCode,
      await stdout,
      await stderr,
    );
  }

  static Future<String?> _askPassword() async {
    await windowPort?.show();
    return dialogs.showPasswordInput(
      title: currentAppLocalizations.sudoPasswordTitle,
    );
  }
}

final linuxElevation = LinuxElevation();
