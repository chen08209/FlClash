import 'dart:ffi' show Abi;
import 'dart:io';
import 'dart:isolate';

import 'package:crypto/crypto.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/common/release_asset.dart';
import 'package:fl_clash/common/release_version.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/plugins/app.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:flutter/services.dart' show PlatformException;
import 'package:path/path.dart';
import 'package:url_launcher/url_launcher.dart';

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
SelfUpdateAsset? Function() resolveSelfUpdateAsset = () => selfUpdateAssetFor(
  Abi.current(),
  windowsInstalled: system.isWindows && isInstalledWindowsBuild,
);

SelfUpdateAsset? get selfUpdateAsset => resolveSelfUpdateAsset();

@visibleForTesting
Future<bool> Function(Uri uri) launchReleasePage = launchUrl;

const appReleaseLine = ReleaseLine.rs;

const _builtReleaseTag = String.fromEnvironment('RELEASE_TAG');

/// A prerelease build carries only `X.Y.Z` as its version name, so the tag
/// tool/package.dart writes into env.json is what tells it apart.
ReleaseVersion installedReleaseVersion(
  String packageVersion, {
  String builtTag = _builtReleaseTag,
}) {
  return ReleaseVersion.tryParse(builtTag) ??
      ReleaseVersion.tryParse(packageVersion) ??
      const ReleaseVersion(0, 0, 0);
}

/// About names a prerelease by its tag, which its version name leaves out.
String installedVersionLabel(
  String packageVersion, {
  String builtTag = _builtReleaseTag,
}) => ReleaseVersion.tryParse(builtTag)?.toString() ?? 'v$packageVersion';

/// The installed version as the update card sets it beside a tag without its
/// leading `v`.
String installedVersionName(
  String packageVersion, {
  String builtTag = _builtReleaseTag,
}) => installedVersionLabel(
  packageVersion,
  builtTag: builtTag,
).replaceFirst(RegExp('^v'), '');

Future<bool> openReleasePage(String tag) {
  return launchReleasePage(
    Uri.https('github.com', '/$repository/releases/tag/$tag'),
  );
}

Uri releaseAssetUri(String tag, String name) {
  return Uri.https('github.com', '/$repository/releases/download/$tag/$name');
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
