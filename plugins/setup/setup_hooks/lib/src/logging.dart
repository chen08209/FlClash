import 'dart:async';
import 'dart:io';

import 'package:logging/logging.dart';
import 'package:path/path.dart' as p;

const _logFileLimit = 512 * 1024;

StreamSubscription<LogRecord>? _subscription;
RandomAccessFile? _logFile;

String hookLogPath(String rootDir) =>
    p.join(rootDir, '.dart_tool', 'setup_build_cache', 'hook.log');

/// Mirrors records into [logFile]: the hook runner shows hook output only on failure.
void initLogging({Level level = Level.INFO, String? logFile}) {
  if (_subscription != null) return;
  Logger.root.level = level;
  final file = logFile == null ? null : _openLogFile(logFile);
  _logFile = file;
  _subscription = Logger.root.onRecord.listen((record) {
    final toStderr = record.level >= Level.SEVERE;
    for (final line in record.message.split('\n')) {
      if (line.isEmpty) continue;
      final text = '${record.level.name}: $line';
      toStderr ? stderr.writeln(text) : stdout.writeln(text);
      file?.writeStringSync('$text\n');
    }
  });
}

/// Releases the log file; Windows refuses to delete a directory while it is open.
void closeLogging() {
  _subscription?.cancel();
  _subscription = null;
  try {
    _logFile?.closeSync();
  } on FileSystemException {
    // Nothing left to flush: the records were written synchronously.
  }
  _logFile = null;
}

RandomAccessFile? _openLogFile(String path) {
  final file = File(path);
  try {
    file.parent.createSync(recursive: true);
    _rotate(file);
    return file.openSync(mode: FileMode.append);
  } on FileSystemException {
    return null;
  }
}

void _rotate(File file) {
  try {
    if (file.existsSync() && file.lengthSync() > _logFileLimit) {
      file.renameSync('${file.path}.1');
    }
  } on FileSystemException {
    // Windows refuses the rename while a concurrent hook holds the file open;
    // appending to the oversized log beats losing this run's output.
  }
}
