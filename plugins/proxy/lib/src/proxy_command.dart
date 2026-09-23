import 'dart:io';

import 'package:flutter/foundation.dart';

const proxyHost = '127.0.0.1';

typedef ProxyProcessRunner =
    Future<ProcessResult> Function(
      String executable,
      List<String> arguments, {
      bool runInShell,
    });

typedef ProxyExecutableChecker = Future<bool> Function(String executable);

@immutable
class ProxyCommand {
  final String executable;
  final List<String> args;
  final bool runInShell;

  ProxyCommand(this.executable, List<String> args, {this.runInShell = false})
    : args = List.unmodifiable(args);
}

class ProxyCommandRunner {
  final ProxyProcessRunner _processRunner;

  ProxyCommandRunner(this._processRunner);

  Future<ProcessResult> process(
    String executable,
    List<String> arguments, {
    bool runInShell = false,
  }) {
    return _processRunner(executable, arguments, runInShell: runInShell);
  }

  Future<bool> run(Iterable<ProxyCommand> commands) async {
    var executed = false;
    try {
      for (final command in commands) {
        executed = true;
        final result = await process(
          command.executable,
          command.args,
          runInShell: command.runInShell,
        );
        if (result.exitCode != 0) {
          return false;
        }
      }
    } on ProcessException {
      return false;
    }
    return executed;
  }
}
