import 'dart:convert';
import 'dart:io';

sealed class Step {
  const Step();

  String describe();

  Future<void> run({required bool verbose});
}

final class Command extends Step {
  const Command(
    this.executable,
    this.arguments, {
    this.workingDirectory,
    this.environment = const {},
  });

  final String executable;
  final List<String> arguments;
  final String? workingDirectory;
  final Map<String, String> environment;

  @override
  String describe() {
    return [
      if (workingDirectory != null) '(cd ${_quote(workingDirectory!)}) ',
      for (final MapEntry(:key, :value) in environment.entries)
        '$key=${_quote(value)} ',
      [executable, ...arguments].map(_quote).join(' '),
    ].join();
  }

  @override
  Future<void> run({required bool verbose}) async {
    stdout.writeln('\$ ${describe()}');
    final process = await Process.start(
      executable,
      arguments,
      workingDirectory: workingDirectory,
      environment: environment,
      runInShell: Platform.isWindows,
    );
    await Future.wait([
      stdout.addStream(process.stdout),
      stderr.addStream(process.stderr),
    ]);
    final code = await process.exitCode;
    if (code != 0) {
      throw PackageError('${describe()} exited with $code');
    }
  }
}

final class Task extends Step {
  const Task(this.description, this.action);

  final String description;
  final Future<void> Function() action;

  @override
  String describe() => '# $description';

  @override
  Future<void> run({required bool verbose}) async {
    stdout.writeln(describe());
    await action();
  }
}

class PackageError implements Exception {
  const PackageError(this.message);

  final String message;

  @override
  String toString() => message;
}

Future<String> capture(
  String executable,
  List<String> arguments, {
  String? workingDirectory,
}) async {
  final result = await Process.run(
    executable,
    arguments,
    workingDirectory: workingDirectory,
    runInShell: Platform.isWindows,
    stdoutEncoding: utf8,
  );
  if (result.exitCode != 0) {
    throw PackageError(
      '$executable ${arguments.join(' ')} exited with ${result.exitCode}: '
      '${result.stderr}',
    );
  }
  return (result.stdout as String).trim();
}

final _plain = RegExp(r'^[A-Za-z0-9_@%+=:,./\\-]+$');

String _quote(String value) {
  if (value.isNotEmpty && _plain.hasMatch(value)) return value;
  return "'${value.replaceAll("'", r"'\''")}'";
}

Future<void> recreateDirectory(String directory) async {
  final dir = Directory(directory);
  if (dir.existsSync()) dir.deleteSync(recursive: true);
  dir.createSync(recursive: true);
}
