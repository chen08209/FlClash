class BuildException implements Exception {
  final String message;

  BuildException(this.message);

  @override
  String toString() => 'BuildException: $message';
}

class CommandFailedException implements Exception {
  final String executable;
  final List<String> arguments;
  final int exitCode;
  final String stdout;
  final String stderr;

  CommandFailedException({
    required this.executable,
    required this.arguments,
    required this.exitCode,
    required this.stdout,
    required this.stderr,
  });

  @override
  String toString() {
    final sb = StringBuffer();
    sb.writeln('Command failed with exit code $exitCode:');
    sb.writeln('  $executable ${arguments.join(' ')}');
    final out = stdout.trim();
    if (out.isNotEmpty) {
      sb.writeln('--- stdout ---');
      sb.writeln(out);
    }
    final err = stderr.trim();
    if (err.isNotEmpty) {
      sb.writeln('--- stderr ---');
      sb.writeln(err);
    }
    return sb.toString();
  }
}
