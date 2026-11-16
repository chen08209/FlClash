import 'package:fl_clash/common/release_asset.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('releaseAssetName', () {
    String name(
      ReleaseOs os,
      ReleaseArch arch,
      String extension, {
      ReleaseForm? form,
      ReleaseLine line = ReleaseLine.dev,
      String version = '0.9.4',
    }) {
      return releaseAssetName(
        line: line,
        version: version,
        os: os,
        arch: arch,
        form: form,
        extension: extension,
      );
    }

    test('names every Windows file by arch and form', () {
      for (final arch in [ReleaseArch.amd64, ReleaseArch.arm64]) {
        expect(
          name(ReleaseOs.windows, arch, 'exe', form: ReleaseForm.setup),
          'FlClash-dev-0.9.4-windows-${arch.name}-setup.exe',
        );
        expect(
          name(ReleaseOs.windows, arch, 'zip', form: ReleaseForm.portable),
          'FlClash-dev-0.9.4-windows-${arch.name}-portable.zip',
        );
      }
    });

    test('gives macOS and Linux packages no form', () {
      for (final arch in [ReleaseArch.amd64, ReleaseArch.arm64]) {
        expect(
          name(ReleaseOs.macos, arch, 'dmg'),
          'FlClash-dev-0.9.4-macos-${arch.name}.dmg',
        );
        for (final extension in ['deb', 'rpm', 'AppImage']) {
          expect(
            name(ReleaseOs.linux, arch, extension),
            'FlClash-dev-0.9.4-linux-${arch.name}.$extension',
          );
        }
      }
    });

    test('names an APK by its ABI, or universal', () {
      expect(
        [
          for (final arch in ReleaseArch.values)
            name(ReleaseOs.android, arch, 'apk'),
        ],
        [
          'FlClash-dev-0.9.4-android-amd64.apk',
          'FlClash-dev-0.9.4-android-arm64.apk',
          'FlClash-dev-0.9.4-android-armv7.apk',
          'FlClash-dev-0.9.4-android-universal.apk',
        ],
      );
    });

    test('carries the line and the whole prerelease version', () {
      expect(
        name(
          ReleaseOs.windows,
          ReleaseArch.amd64,
          'exe',
          form: ReleaseForm.setup,
          line: ReleaseLine.rs,
          version: releaseVersionOfTag('v0.9.4-pre.2'),
        ),
        'FlClash-rs-0.9.4-pre.2-windows-amd64-setup.exe',
      );
    });

    test('names a nightly by commit date and short hash', () {
      final version = nightlyReleaseVersion(
        '0.9.4',
        DateTime.utc(2026, 11, 6, 23, 59),
        '394f5bb82a524db3838aa441a8a348d038666ad7',
      );

      expect(version, '0.9.4-nightly.20261106.394f5bb');
      expect(
        name(ReleaseOs.linux, ReleaseArch.amd64, 'AppImage', version: version),
        'FlClash-dev-0.9.4-nightly.20261106.394f5bb-linux-amd64.AppImage',
      );
    });

    test('refuses a version GitHub would rewrite', () {
      expect(
        () => name(ReleaseOs.macos, ReleaseArch.arm64, 'dmg', version: '1+2'),
        throwsArgumentError,
      );
      expect(
        () =>
            name(ReleaseOs.macos, ReleaseArch.arm64, 'dmg', version: '0.9.4+2'),
        throwsArgumentError,
      );
    });
  });

  test('a rebuild tag keeps its number without a plus', () {
    expect(releaseVersionOfTag('v0.9.4'), '0.9.4');
    expect(releaseVersionOfTag('v0.9.4-rs.1+2'), '0.9.4-rs.1.2');
  });

  test('the checksum file is named per line and version', () {
    expect(
      releaseChecksumsName(ReleaseLine.rs, '0.9.4-pre.2'),
      'FlClash-rs-0.9.4-pre.2-SHA256SUMS',
    );
  });
}
