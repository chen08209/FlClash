import 'dart:io';

import 'package:code_assets/code_assets.dart';
import 'package:hooks/hooks.dart';
import 'package:path/path.dart' as p;
import 'package:setup_hooks/src/build.dart';
import 'package:setup_hooks/src/core_builder.dart';
import 'package:setup_hooks/src/error.dart';
import 'package:setup_hooks/src/target.dart';
import 'package:test/test.dart';

void main() {
  late Directory repository;
  late Directory packageRoot;
  late Directory outputShared;

  setUp(() {
    repository = Directory.systemTemp.createTempSync('setup_core_builder_');
    repository = Directory(repository.resolveSymbolicLinksSync());
    File(
      p.join(repository.path, 'pubspec.yaml'),
    ).writeAsStringSync('name: x\n');
    Directory(p.join(repository.path, 'core')).createSync();
    packageRoot = Directory(p.join(repository.path, 'plugins', 'setup'))
      ..createSync(recursive: true);
    outputShared = Directory(p.join(repository.path, 'out'))..createSync();
  });

  tearDown(() {
    repository.deleteSync(recursive: true);
  });

  BuildInput buildInput({
    required OS os,
    required Architecture architecture,
    bool codeAssets = true,
    Uri? compiler,
    int ndkApi = 23,
    Directory? package,
    Map<String, Object?> userDefines = const {},
  }) {
    final builder = BuildInputBuilder()
      ..setupShared(
        packageRoot: (package ?? packageRoot).uri,
        packageName: 'setup',
        outputDirectoryShared: outputShared.uri,
        outputFile: repository.uri.resolve('output.json'),
        userDefines: PackageUserDefines(
          workspacePubspec: PackageUserDefinesSource(
            defines: userDefines,
            basePath: repository.uri,
          ),
        ),
      )
      ..setupBuildInput()
      ..config.setupBuild(linkingEnabled: false);
    if (codeAssets) {
      CodeAssetExtension(
        targetArchitecture: architecture,
        targetOS: os,
        linkModePreference: LinkModePreference.dynamic,
        cCompiler: compiler == null
            ? null
            : CCompilerConfig(
                compiler: compiler,
                archiver: compiler.resolve('llvm-ar'),
                linker: compiler.resolve('ld.lld'),
              ),
        android: os == OS.android
            ? AndroidCodeConfig(targetNdkApi: ndkApi)
            : null,
      ).setupBuildInput(builder);
    }
    return builder.build();
  }

  group('requestFor', () {
    test('has nothing to build without code assets or on iOS', () {
      const builder = CoreBuilder();

      expect(
        builder.requestFor(
          buildInput(
            os: OS.linux,
            architecture: Architecture.x64,
            codeAssets: false,
          ),
        ),
        isNull,
      );
      expect(
        builder.requestFor(
          buildInput(os: OS.iOS, architecture: Architecture.arm64),
        ),
        isNull,
      );
    });

    test('resolves the repository and target from the hook input', () {
      final request = const CoreBuilder().requestFor(
        buildInput(os: OS.linux, architecture: Architecture.x64),
      )!;

      expect(request.rootDir, repository.path);
      expect(request.harnessDir, p.join(packageRoot.path, 'setup_hooks'));
      expect(request.target, Target.linuxAmd64);
      expect(request.androidToolchain, isNull);
    });

    test('skips the macOS slice the host does not run', () {
      const builder = CoreBuilder(hostArchitecture: Architecture.arm64);

      expect(
        builder.requestFor(
          buildInput(os: OS.macOS, architecture: Architecture.x64),
        ),
        isNull,
      );
      expect(
        builder
            .requestFor(
              buildInput(os: OS.macOS, architecture: Architecture.arm64),
            )!
            .target,
        Target.macosArm64,
      );
    });

    test('derives the Android compiler from the NDK clang Flutter passes', () {
      final bin = p.join(repository.path, 'ndk', 'prebuilt', 'host', 'bin');
      final request = const CoreBuilder().requestFor(
        buildInput(
          os: OS.android,
          architecture: Architecture.arm64,
          compiler: Uri.file(p.join(bin, 'clang')),
          ndkApi: 23,
        ),
      )!;

      expect(request.target, Target.androidArm64);
      expect(
        request.androidToolchain!.clangFor(Target.androidArm64),
        p.join(bin, 'aarch64-linux-android23-clang'),
      );
    });

    test('fails when Flutter passes no Android compiler', () {
      expect(
        () => const CoreBuilder().requestFor(
          buildInput(os: OS.android, architecture: Architecture.arm64),
        ),
        throwsA(isA<InfraError>()),
      );
    });

    test('rejects an architecture without a Core', () {
      expect(
        () => const CoreBuilder().requestFor(
          buildInput(os: OS.windows, architecture: Architecture.ia32),
        ),
        throwsA(isA<BuildException>()),
      );
    });

    test('fails when the package is not inside the repository', () {
      final elsewhere = Directory(
        p.join(repository.path, 'elsewhere', 'plugins', 'setup'),
      )..createSync(recursive: true);

      expect(
        () => const CoreBuilder().requestFor(
          buildInput(
            os: OS.linux,
            architecture: Architecture.x64,
            package: elsewhere,
          ),
        ),
        throwsA(isA<InfraError>()),
      );
    });
  });

  group('run', () {
    test(
      'reports read files and written directories as dependencies',
      () async {
        final goFile = p.join(repository.path, 'core', 'lib.go');
        final coreDir = p.join(repository.path, 'libclash', 'linux');
        BuildRequest? seen;
        final builder = CoreBuilder(
          build: (request) async {
            seen = request;
            return BuildReport(
              inputs: [goFile],
              outputs: [
                p.join(coreDir, 'FlClashCore'),
                p.join(coreDir, 'manifest.json'),
              ],
              rebuilt: true,
            );
          },
        );
        final output = BuildOutputBuilder();

        await builder.run(
          input: buildInput(os: OS.linux, architecture: Architecture.x64),
          output: output,
        );

        expect(seen?.target, Target.linuxAmd64);
        expect(BuildOutput(output.json).dependencies, [
          Uri.file(goFile),
          Uri.directory(coreDir),
        ]);
      },
    );

    test('declares no dependencies when nothing is built', () async {
      var built = false;
      final builder = CoreBuilder(
        build: (_) async {
          built = true;
          throw StateError('unreachable');
        },
      );
      final output = BuildOutputBuilder();

      await builder.run(
        input: buildInput(os: OS.iOS, architecture: Architecture.arm64),
        output: output,
      );

      expect(built, isFalse);
      expect(BuildOutput(output.json).dependencies, isEmpty);
    });

    test('skips the build when the user-define asks for it', () async {
      var built = false;
      final builder = CoreBuilder(
        build: (_) async {
          built = true;
          throw StateError('unreachable');
        },
      );
      final output = BuildOutputBuilder();

      await builder.run(
        input: buildInput(
          os: OS.linux,
          architecture: Architecture.x64,
          userDefines: {'build_assets': false},
        ),
        output: output,
      );

      expect(built, isFalse);
      expect(BuildOutput(output.json).dependencies, isEmpty);
      final log = File(
        p.join(repository.path, '.dart_tool', 'setup_build_cache', 'hook.log'),
      ).readAsStringSync();
      expect(log, contains('skipped: user-define build_assets=false'));
    });

    test('builds when the user-define holds any other value', () {
      const builder = CoreBuilder();

      expect(
        builder.requestFor(
          buildInput(
            os: OS.linux,
            architecture: Architecture.x64,
            userDefines: {'build_assets': true},
          ),
        ),
        isNotNull,
      );
    });

    test('reports a failed compile as a build failure', () {
      final builder = CoreBuilder(
        build: (_) async => throw CommandFailedException(
          executable: 'go',
          arguments: const ['build'],
          exitCode: 2,
          stdout: '',
          stderr: 'undefined: x',
        ),
      );

      expect(
        builder.run(
          input: buildInput(os: OS.linux, architecture: Architecture.x64),
          output: BuildOutputBuilder(),
        ),
        throwsA(
          isA<BuildError>().having(
            (error) => error.message,
            'message',
            contains('undefined: x'),
          ),
        ),
      );
    });

    test('reports a vanished build input as an infrastructure failure', () {
      final builder = CoreBuilder(
        build: (_) async =>
            throw const FileSystemException('Cannot open file', 'core/lib.go'),
      );

      expect(
        builder.run(
          input: buildInput(os: OS.linux, architecture: Architecture.x64),
          output: BuildOutputBuilder(),
        ),
        throwsA(
          isA<InfraError>().having(
            (error) => error.message,
            'message',
            contains('core/lib.go'),
          ),
        ),
      );
    });

    test('reports a missing toolchain as an infrastructure failure', () {
      final builder = CoreBuilder(
        build: (_) async =>
            throw const ProcessException('go', ['version'], 'not found'),
      );

      expect(
        builder.run(
          input: buildInput(os: OS.linux, architecture: Architecture.x64),
          output: BuildOutputBuilder(),
        ),
        throwsA(
          isA<InfraError>().having(
            (error) => error.message,
            'message',
            contains('go'),
          ),
        ),
      );
    });
  });
}
