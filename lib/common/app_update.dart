import 'dart:convert';
import 'dart:ffi' show Abi;
import 'dart:io';
import 'dart:isolate';

import 'package:crypto/crypto.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/plugins/app.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:flutter/services.dart' show PlatformException;
import 'package:path/path.dart';

const releaseChecksumsName = 'SHA256SUMS';

sealed class UpdateDownload {
  const UpdateDownload(this.tag);

  final String tag;
}

final class UpdateDownloading extends UpdateDownload {
  const UpdateDownloading(super.tag, {this.received = 0, this.total = 0});

  final int received;

  /// Zero until the server reports a length.
  final int total;
}

final class UpdateReady extends UpdateDownload {
  const UpdateReady(super.tag, this.path);

  final String path;
}

@visibleForTesting
String? Function() resolveSelfUpdateSuffix = () => selfUpdateAssetSuffix(
  Abi.current(),
  windowsInstalled: system.isWindows && isInstalledWindowsBuild,
);

String? get selfUpdateSuffix => resolveSelfUpdateSuffix();

// The names follow the release matrix in .github/workflows/build.yaml.
String? selfUpdateAssetSuffix(Abi abi, {required bool windowsInstalled}) {
  return switch (abi) {
    Abi.androidArm64 => 'android-arm64-v8a.apk',
    Abi.androidArm => 'android-armeabi-v7a.apk',
    Abi.androidX64 => 'android-x86_64.apk',
    Abi.windowsX64 when windowsInstalled => 'windows-amd64-setup.exe',
    Abi.windowsArm64 when windowsInstalled => 'windows-arm64-setup.exe',
    _ => null,
  };
}

String releaseAssetName(String tag, String suffix) {
  final version = tag.startsWith('v') ? tag.substring(1) : tag;
  return '$appName-$version-$suffix';
}

Uri releaseAssetUri(String tag, String name) {
  return Uri.https('github.com', '/$repository/releases/download/$tag/$name');
}

final _checksumLine = RegExp(r'^([0-9a-fA-F]{64}) [ *](?:\./)?(.+)$');

String? releaseChecksum(String sums, String name) {
  for (final line in const LineSplitter().convert(sums)) {
    final match = _checksumLine.firstMatch(line.trim());
    if (match != null && match[2] == name) {
      return match[1]!.toLowerCase();
    }
  }
  return null;
}

Future<String> fileSha256(String path) {
  return Isolate.run(() async {
    final digest = await sha256.bind(File(path).openRead()).first;
    return digest.toString();
  });
}

// The installer that relaunched the app may still hold its file open.
Future<void> clearUpdateDownloads() async {
  try {
    await app?.clearDownloads();
    await safeDeletePath(await appPath.updateDirPath);
  } on PlatformException catch (error) {
    commonPrint.log(
      'Clearing system downloads failed: ${compactError(error)}',
      logLevel: LogLevel.warning,
    );
  } on FileSystemException catch (error) {
    commonPrint.log(
      'Clearing update downloads failed: ${compactError(error)}',
      logLevel: LogLevel.warning,
    );
  }
}

// Inno Setup writes unins000.exe beside the app; the portable zip has none.
bool get isInstalledWindowsBuild {
  return File(join(appPath.executableDirPath, 'unins000.exe')).existsSync();
}

// inno_setup.iss waits for `updatefrom` to exit, then relaunches the app.
String windowsUpdateArguments(int pid) {
  return '/SILENT /SUPPRESSMSGBOXES /NORESTART /SP- /updatefrom=$pid';
}
