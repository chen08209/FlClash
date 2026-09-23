import 'package:setup_hooks/src/error.dart';
import 'package:setup_hooks/src/target.dart';
import 'package:test/test.dart';

void main() {
  group('resolve', () {
    test('finds the target for a platform and GOARCH', () {
      expect(
        Target.resolve(platform: 'android', goarch: 'arm'),
        Target.androidArm,
      );
      expect(
        Target.resolve(platform: 'macos', goarch: 'arm64'),
        Target.macosArm64,
      );
      expect(
        Target.resolve(platform: 'windows', goarch: 'amd64'),
        Target.windowsAmd64,
      );
    });

    test('rejects a GOARCH or platform without a Core', () {
      expect(
        () => Target.resolve(platform: 'linux', goarch: 'riscv64'),
        throwsA(isA<BuildException>()),
      );
      expect(
        () => Target.resolve(platform: 'ios', goarch: 'arm64'),
        throwsA(isA<BuildException>()),
      );
    });
  });

  test('Android ABIs match the :core Gradle module', () {
    expect(Target.forPlatform('android').map((target) => target.abi), [
      'armeabi-v7a',
      'arm64-v8a',
      'x86_64',
    ]);
  });

  test('only Linux and Windows ship the Helper', () {
    expect(Target.all.where((target) => target.hasHelper), [
      Target.linuxArm64,
      Target.linuxAmd64,
      Target.windowsAmd64,
      Target.windowsArm64,
    ]);
  });

  test('names the NDK clang wrapper per ABI', () {
    expect(Target.androidArm.ndkTriple, 'armv7a-linux-androideabi');
    expect(Target.androidArm64.ndkTriple, 'aarch64-linux-android');
    expect(Target.androidAmd64.ndkTriple, 'x86_64-linux-android');
    expect(() => Target.macosArm64.ndkTriple, throwsA(isA<BuildException>()));
  });

  test('names the Rust target triple for Helper platforms', () {
    expect(Target.windowsAmd64.rustTriple, 'x86_64-pc-windows-msvc');
    expect(Target.linuxArm64.rustTriple, 'aarch64-unknown-linux-gnu');
    expect(() => Target.macosArm64.rustTriple, throwsA(isA<BuildException>()));
  });
}
