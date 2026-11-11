import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

String _shellQuote(String value) => "'${value.replaceAll("'", "'\\''")}'";

String _appleScriptQuote(String value) =>
    '"${value.replaceAll('\\', '\\\\').replaceAll('"', '\\"').replaceAll('\n', '\\n').replaceAll('\r', '\\r')}"';

class MacOSUpdater {
  Future<void> install({
    required String imagePath,
    required String version,
    required String failureTitle,
    required String failureMessage,
  }) async {
    final target = macOSAppBundlePath(Platform.resolvedExecutable);
    final directory = await Directory.systemTemp.createTemp('flclash-update-');
    final mount = p.join(directory.path, 'volume');
    var handedOff = false;
    try {
      await _run('/usr/bin/hdiutil', [
        'attach',
        '-readonly',
        '-nobrowse',
        '-noautoopen',
        '-mountpoint',
        mount,
        imagePath,
      ]);
      final source = p.join(mount, 'FlClash.app');
      final currentId = await _plistValue(target, 'CFBundleIdentifier');
      final sourceId = await _plistValue(source, 'CFBundleIdentifier');
      final sourceVersion = await _plistValue(
        source,
        'CFBundleShortVersionString',
      );
      if (sourceId != currentId || sourceVersion != version) {
        throw const FormatException('The update does not match this app');
      }
      final writable = await Process.run('/bin/test', [
        '-w',
        p.dirname(target),
      ]);
      final appWritable = await Process.run('/bin/test', ['-w', target]);
      final command = [
        '/bin/sh',
        '-c',
        macOSInstallScript,
        'flclash-update',
        source,
        target,
        '$pid',
        directory.path,
      ].map(_shellQuote).join(' ');
      final install = writable.exitCode == 0 && appWritable.exitCode == 0
          ? command
          : '/usr/bin/osascript -e ${_shellQuote('do shell script ${_appleScriptQuote(command)} with administrator privileges')}';
      final alert =
          'display alert ${_appleScriptQuote(failureTitle)} '
          'message ${_appleScriptQuote(failureMessage)} as critical';
      final launcher =
          '''
exec >${_shellQuote(p.join(directory.path, 'install.log'))} 2>&1
$install
status=\$?
/usr/bin/hdiutil detach ${_shellQuote(mount)} -quiet
if [ "\$status" -ne 0 ]; then
  /usr/bin/touch ${_shellQuote(p.join(directory.path, 'failed'))}
fi
if [ -f ${_shellQuote(p.join(directory.path, 'commit'))} ] && ! kill -0 $pid 2>/dev/null; then
  /usr/bin/open -n ${_shellQuote(target)} || status=1
  if [ "\$status" -ne 0 ]; then
    /usr/bin/osascript -e ${_shellQuote(alert)}
  fi
fi
if [ "\$status" -eq 0 ]; then
  /bin/rm -rf ${_shellQuote(directory.path)}
fi
''';
      await Process.start('/bin/sh', [
        '-c',
        launcher,
      ], mode: ProcessStartMode.detached);
      handedOff = true;
      await _waitUntilReady(directory);
      await File(p.join(directory.path, 'commit')).writeAsString('');
    } finally {
      if (!handedOff) {
        await Process.run('/usr/bin/hdiutil', ['detach', mount, '-quiet']);
        await directory.delete(recursive: true);
      }
    }
  }

  Future<void> _waitUntilReady(Directory directory) async {
    final ready = File(p.join(directory.path, 'ready'));
    final failed = File(p.join(directory.path, 'failed'));
    final deadline = DateTime.now().add(const Duration(minutes: 5));
    while (!await ready.exists()) {
      if (await failed.exists() || DateTime.now().isAfter(deadline)) {
        await File(p.join(directory.path, 'abort')).writeAsString('');
        throw const FileSystemException('Could not prepare the macOS update');
      }
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }
  }

  Future<String> _plistValue(String bundle, String key) async {
    final result = await _run('/usr/bin/plutil', [
      '-extract',
      key,
      'raw',
      '-o',
      '-',
      p.join(bundle, 'Contents', 'Info.plist'),
    ]);
    return result.stdout.toString().trim();
  }

  Future<ProcessResult> _run(String executable, List<String> arguments) async {
    final result = await Process.run(executable, arguments);
    if (result.exitCode != 0) {
      throw ProcessException(
        executable,
        arguments,
        result.stderr.toString(),
        result.exitCode,
      );
    }
    return result;
  }
}

@visibleForTesting
String macOSAppBundlePath(String executable) {
  final macOS = p.dirname(executable);
  final contents = p.dirname(macOS);
  final bundle = p.dirname(contents);
  if (p.basename(macOS) != 'MacOS' ||
      p.basename(contents) != 'Contents' ||
      !bundle.endsWith('.app') ||
      !p.isAbsolute(bundle) ||
      p.split(bundle).contains('AppTranslocation')) {
    throw const FileSystemException('Update requires an installed app bundle');
  }
  return bundle;
}

// Runs independently of Flutter; only the recorded application PID gates replacement.
@visibleForTesting
const macOSInstallScript = r'''
set -eu
source=$1
target=$2
owner=$3
control=$4
stage=$(/usr/bin/mktemp -d "${target%/*}/.flclash-update.XXXXXX")
cleanup() {
  status=$?
  trap - EXIT
  if [ "$status" -ne 0 ] && [ -d "$stage/previous.app" ]; then
    [ ! -e "$target" ] || exit 1
    /bin/mv "$stage/previous.app" "$target" || exit 1
  fi
  /bin/rm -rf "$stage"
  exit "$status"
}
trap cleanup EXIT
[ -d "$target" ]
[ ! -L "$target" ]
/usr/bin/ditto "$source" "$stage/update.app"
/usr/bin/codesign --verify --deep --strict "$stage/update.app"
/usr/bin/touch "$control/ready"
attempt=0
while [ ! -f "$control/commit" ] || kill -0 "$owner" 2>/dev/null; do
  [ ! -f "$control/abort" ]
  attempt=$((attempt + 1))
  [ "$attempt" -lt 300 ]
  /bin/sleep 0.2
done
/bin/mv "$target" "$stage/previous.app"
[ ! -e "$target" ]
/bin/mv "$stage/update.app" "$target"
''';
