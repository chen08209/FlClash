import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:fl_clash/common/system.dart' show ProcessRunner;
import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:path/path.dart';

const _writeAccess = 2;

final _access = DynamicLibrary.process()
    .lookupFunction<
      Int Function(Pointer<Utf8>, Int),
      int Function(Pointer<Utf8>, int)
    >('access');

bool _writable(String path) {
  return using(
    (arena) => _access(path.toNativeUtf8(allocator: arena), _writeAccess) == 0,
  );
}

String? appBundleOf(String executable) {
  final macos = dirname(executable);
  final contents = dirname(macos);
  final bundle = dirname(contents);
  if (basename(macos) != 'MacOS' ||
      basename(contents) != 'Contents' ||
      extension(bundle) != '.app') {
    return null;
  }
  return bundle;
}

class MacosUpdateException implements Exception {
  const MacosUpdateException(this.message);

  final String message;

  @override
  String toString() => 'MacosUpdateException: $message';
}

typedef MacosInstallFailure = ({String tag, String reason});

/// Copies the staged app beside the bundle so both renames stay on one
/// volume, where a rename cannot leave half an app.
@visibleForTesting
const macosSwapScript = r'''
pid=$1 app=$2 staged=$3 marker=$4 tag=$5 opener=$6 ticks=$7
dir=$(dirname "$app")
name=$(basename "$app")
new="$dir/.$name.new.$$"
old="$dir/.$name.old.$$"
lock="$marker.lock"
mkdir "$lock" 2>/dev/null || exit 0
fail() {
  printf '%s\n%s\n' "$tag" "$1" > "$marker"
}
reopen() {
  rmdir "$lock"
  "$opener" "$app"
}
running() {
  case $(ps -p "$pid" -o comm= 2>/dev/null) in
  "$app"/Contents/MacOS/*) return 0 ;;
  esac
  return 1
}
waited=0
while running; do
  waited=$((waited + 1))
  if [ "$waited" -gt "$ticks" ]; then
    fail 'the app did not exit'
    reopen
    exit 1
  fi
  sleep 0.1
done
for leftover in "$dir/.$name".old.* "$dir/.$name".new.*; do
  [ -e "$leftover" ] && rm -rf "$leftover" 2>/dev/null
done
if ! error=$(ditto "$staged" "$new" 2>&1); then
  fail "$error"
  rm -rf "$new"
  reopen
  exit 1
fi
if ! error=$(mv "$app" "$old" 2>&1); then
  fail "$error"
  rm -rf "$new"
  reopen
  exit 1
fi
if ! error=$(mv "$new" "$app" 2>&1); then
  if [ -e "$app" ] || ! mv "$old" "$app" 2>/dev/null; then
    fail "$error; the old app is at $old"
    rmdir "$lock"
    exit 1
  fi
  fail "$error"
  rm -rf "$new"
  reopen
  exit 1
fi
rm -rf "$old" 2>/dev/null
reopen
''';

class MacosAppUpdate {
  MacosAppUpdate(
    this.bundle, {
    @visibleForTesting ProcessRunner? runProcess,
    @visibleForTesting String opener = '/usr/bin/open',
  }) : _runProcess = runProcess ?? Process.run,
       _opener = opener;

  final String bundle;

  final ProcessRunner _runProcess;

  final String _opener;

  var _installing = false;

  /// A standard user's `/Applications`, a mounted dmg and a translocated app
  /// all fail this.
  bool get canReplace => _writable(bundle) && _writable(dirname(bundle));

  Future<String> stage(String dmg, String directory) async {
    final mount = join(directory, 'mount');
    final staged = join(directory, basename(bundle));
    await Directory(mount).create();
    await _run('hdiutil', [
      'attach',
      dmg,
      '-nobrowse',
      '-readonly',
      '-noautoopen',
      '-mountpoint',
      mount,
    ]);
    try {
      final apps = Directory(
        mount,
      ).listSync().where((entity) => extension(entity.path) == '.app').toList();
      if (apps.length != 1) {
        throw MacosUpdateException(
          '${basename(dmg)} holds ${apps.length} apps, expected 1',
        );
      }
      await _run('ditto', [apps.single.path, staged]);
    } finally {
      await _runProcess('hdiutil', ['detach', mount, '-force']);
    }
    await File(dmg).delete();
    final want = await _bundleId(bundle);
    final got = await _bundleId(staged);
    if (got != want) {
      throw MacosUpdateException('the update is $got, not $want');
    }
    await _run('xattr', ['-dr', 'com.apple.quarantine', staged]);
    return staged;
  }

  /// Shows a refusal `access(2)` misses, such as App Management, before the
  /// app quits.
  @visibleForTesting
  Future<void> checkWritable() async {
    final probe = File(join(bundle, 'Contents', '.update-check'));
    await probe.writeAsString('');
    await probe.delete();
  }

  Future<bool> install({
    required String staged,
    required String tag,
    required String marker,
  }) async {
    if (_installing) return false;
    _installing = true;
    try {
      await checkWritable();
      await Process.start('/bin/sh', [
        '-c',
        macosSwapScript,
        'flclash-update',
        '$pid',
        bundle,
        staged,
        marker,
        tag,
        _opener,
        '300',
      ], mode: ProcessStartMode.detached);
    } catch (_) {
      _installing = false;
      rethrow;
    }
    return true;
  }

  Future<String> _bundleId(String app) async {
    final result = await _run('plutil', [
      '-extract',
      'CFBundleIdentifier',
      'raw',
      '-o',
      '-',
      join(app, 'Contents', 'Info.plist'),
    ]);
    return result.stdout.toString().trim();
  }

  Future<ProcessResult> _run(String executable, List<String> arguments) async {
    final result = await _runProcess(executable, arguments);
    if (result.exitCode != 0) {
      throw MacosUpdateException(
        '$executable ${arguments.first} exited with ${result.exitCode}: '
        '${result.stderr.toString().trim()}',
      );
    }
    return result;
  }
}

Future<MacosInstallFailure?> takeMacosInstallFailure(String marker) async {
  final file = File(marker);
  if (!await file.exists()) return null;
  final lines = await file.readAsLines();
  await file.delete();
  if (lines.isEmpty) return null;
  return (tag: lines.first, reason: lines.skip(1).join('\n'));
}
