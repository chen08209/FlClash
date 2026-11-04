import 'dart:io';

import 'package:path/path.dart' as p;

Future<void> startMacOSUpdate(String imagePath) async {
  final target = p.dirname(p.dirname(p.dirname(Platform.resolvedExecutable)));
  if (!target.endsWith('.app') || !await File(imagePath).exists()) {
    throw const FileSystemException('Invalid macOS update package');
  }
  final directory = await Directory.systemTemp.createTemp('FlClashUpdate.');
  final probe = File(p.join(p.dirname(target), '.FlClashUpdate-$pid'));
  try {
    await probe.writeAsString('');
    await probe.delete();
    final installer = File(p.join(directory.path, 'install.sh'));
    await installer.writeAsString(macOSUpdateInstaller);
    await Process.start('/bin/sh', [
      installer.path,
      '$pid',
      imagePath,
      target,
      directory.path,
    ], mode: ProcessStartMode.detached);
  } catch (_) {
    await directory.delete(recursive: true);
    rethrow;
  }
}

const macOSUpdateInstaller = r'''
set -eu
app_pid=$1
image=$2
target=$3
work=$4
exec >>"$work/install.log" 2>&1
mount="$work/mount"
previous="$work/previous.app"
next="$work/next.app"
mounted=false
swapped=false
finish() {
  status=$?
  if [ "$mounted" = true ]; then /usr/bin/hdiutil detach "$mount" -quiet || true; fi
  if [ "$status" -ne 0 ]; then
    if [ "$swapped" = true ] && [ -d "$previous" ]; then
      mv "$target" "$work/failed.app" || true
      mv "$previous" "$target"
    fi
    /usr/bin/open "$target" || true
  fi
}
trap finish EXIT
tries=0
while /bin/kill -0 "$app_pid" 2>/dev/null; do
  tries=$((tries + 1))
  if [ "$tries" -gt 150 ]; then exit 1; fi
  sleep 0.1
done
mkdir -p "$mount"
/usr/bin/hdiutil attach "$image" -readonly -nobrowse -mountpoint "$mount" -quiet
mounted=true
source="$mount/FlClash.app"
test "$(/usr/bin/plutil -extract CFBundleIdentifier raw "$source/Contents/Info.plist")" = com.follow.clash
/usr/bin/codesign --verify --deep --strict "$source"
/usr/bin/ditto "$source" "$next"
/usr/bin/codesign --verify --deep --strict "$next"
mv "$target" "$previous"
swapped=true
mv "$next" "$target"
/usr/bin/open "$target"
touch "$work/complete"
''';
