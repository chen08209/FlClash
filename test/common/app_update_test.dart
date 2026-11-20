import 'dart:convert';
import 'dart:ffi' show Abi;
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:fl_clash/common/app_update.dart';
import 'package:fl_clash/common/release_asset.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  String? nameOn(Abi abi, {required bool windowsInstalled}) {
    final asset = selfUpdateAssetFor(abi, windowsInstalled: windowsInstalled);
    return asset == null ? null : updateAssetName('v0.9.4', asset);
  }

  group('selfUpdateAssetFor', () {
    test('names the APK built for the running ABI', () {
      expect(
        nameOn(Abi.androidArm64, windowsInstalled: false),
        'FlClash-0.9.4-android-arm64.apk',
      );
      expect(
        nameOn(Abi.androidArm, windowsInstalled: false),
        'FlClash-0.9.4-android-armv7.apk',
      );
      expect(
        nameOn(Abi.androidX64, windowsInstalled: false),
        'FlClash-0.9.4-android-amd64.apk',
      );
    });

    test('names the Windows installer only for an installed build', () {
      expect(
        nameOn(Abi.windowsX64, windowsInstalled: true),
        'FlClash-0.9.4-windows-amd64-setup.exe',
      );
      expect(
        nameOn(Abi.windowsArm64, windowsInstalled: true),
        'FlClash-0.9.4-windows-arm64-setup.exe',
      );
      expect(nameOn(Abi.windowsX64, windowsInstalled: false), isNull);
    });

    test('leaves macOS and Linux to the release page', () {
      for (final abi in [
        Abi.macosArm64,
        Abi.macosX64,
        Abi.linuxX64,
        Abi.linuxArm64,
      ]) {
        expect(nameOn(abi, windowsInstalled: true), isNull);
      }
    });
  });

  test('asks for the files a rebuild tag published', () {
    final asset = selfUpdateAssetFor(
      Abi.androidArm64,
      windowsInstalled: false,
    )!;

    expect(
      updateAssetName('v0.9.4-pre.1+2', asset),
      'FlClash-0.9.4-pre.1.2-android-arm64.apk',
    );
    expect(
      updateChecksumsName('v0.9.4-pre.1+2'),
      'FlClash-0.9.4-pre.1.2-SHA256SUMS',
    );
  });

  test('an rs build has no self-update asset to download', () {
    expect(selfUpdateAsset, isNull);
  });

  group('releaseChecksum', () {
    const digest =
        'ff6a953c0f5c12e6bdc97b49428b565b64c4a62d85e50081823ba297407529b1';

    test('reads the entry sha256sum wrote for a file', () {
      final sums =
          '$digest  FlClash-0.9.5-android-arm64.apk\n'
          '${'0' * 64}  FlClash-0.9.5-windows-amd64-setup.exe\n';

      expect(releaseChecksum(sums, 'FlClash-0.9.5-android-arm64.apk'), digest);
    });

    test('accepts the binary marker, upper case and CRLF', () {
      final sums = '${digest.toUpperCase()} *FlClash.apk\r\n';

      expect(releaseChecksum(sums, 'FlClash.apk'), digest);
    });

    test('answers null for a file the listing does not name', () {
      expect(releaseChecksum('$digest  other.apk\n', 'FlClash.apk'), isNull);
      expect(releaseChecksum('not a listing', 'FlClash.apk'), isNull);
    });
  });

  test('fileSha256 hashes the file on disk', () async {
    final directory = await Directory.systemTemp.createTemp('app_update');
    addTearDown(() => directory.delete(recursive: true));
    final file = File('${directory.path}/package');
    await file.writeAsString('package');

    expect(
      await fileSha256(file.path),
      sha256.convert(utf8.encode('package')).toString(),
    );
  });

  test('windowsUpdateArguments installs silently on behalf of a pid', () {
    final arguments = windowsUpdateArguments(4242).split(' ');

    expect(arguments, containsAll(['/SILENT', '/SUPPRESSMSGBOXES']));
    expect(arguments, contains('/updatefrom=4242'));
  });
}
