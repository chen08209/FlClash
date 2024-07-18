// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';
import 'package:args/command_runner.dart';
import 'package:path/path.dart';

enum PlatformType {
  windows,
  linux,
  android,
  macos,
}

enum Arch { amd64, arm64, arm }

class BuildLibItem {
  PlatformType platform;
  Arch arch;
  String archName;

  BuildLibItem({
    required this.platform,
    required this.arch,
    required this.archName,
  });

  String get dynamicLibExtensionName {
    final String extensionName;
    switch (platform) {
      case PlatformType.android || PlatformType.linux:
        extensionName = "so";
        break;
      case PlatformType.windows:
        extensionName = "dll";
        break;
      case PlatformType.macos:
        extensionName = "dylib";
        break;
    }
    return extensionName;
  }

  String get os {
    if (platform == PlatformType.macos) {
      return "darwin";
    }
    return platform.name;
  }

  @override
  String toString() {
    return 'BuildLibItem{platform: $platform, arch: $arch, archName: $archName}';
  }
}

class Build {
  static List<BuildLibItem> get buildItems => [
        BuildLibItem(
          platform: PlatformType.macos,
          arch: Arch.amd64,
          archName: '',
        ),
        BuildLibItem(
          platform: PlatformType.macos,
          arch: Arch.arm64,
          archName: '',
        ),
        BuildLibItem(
          platform: PlatformType.windows,
          arch: Arch.amd64,
          archName: '',
        ),
        BuildLibItem(
          platform: PlatformType.windows,
          arch: Arch.arm64,
          archName: '',
        ),
        BuildLibItem(
          platform: PlatformType.android,
          arch: Arch.arm,
          archName: 'armeabi-v7a',
        ),
        BuildLibItem(
          platform: PlatformType.android,
          arch: Arch.arm64,
          archName: 'arm64-v8a',
        ),
        BuildLibItem(
          platform: PlatformType.android,
          arch: Arch.amd64,
          archName: 'x86_64',
        ),
        BuildLibItem(
          platform: PlatformType.linux,
          arch: Arch.amd64,
          archName: '',
        ),
      ];

  static String get appName => "FlClash";

  static String get libName => "libclash";

  static String get outDir => join(current, libName);

  static String get _coreDir => join(current, "core");

  static String get distPath => join(current, "dist");

  static String _getCc(BuildLibItem buildItem) {
    final environment = Platform.environment;
    if (buildItem.platform == PlatformType.android) {
      final ndk = environment["ANDROID_NDK"];
      assert(ndk != null);
      final prebuiltDir =
          Directory(join(ndk!, "toolchains", "llvm", "prebuilt"));
      final prebuiltDirList = prebuiltDir.listSync();
      final map = {
        "armeabi-v7a": "armv7a-linux-androideabi21-clang",
        "arm64-v8a": "aarch64-linux-android21-clang",
        "x86": "i686-linux-android21-clang",
        "x86_64": "x86_64-linux-android21-clang"
      };
      return join(
        prebuiltDirList.first.path,
        "bin",
        map[buildItem.archName],
      );
    }
    return "gcc";
  }

  static get tags => "with_gvisor";

  static Future<void> exec(
    List<String> executable, {
    String? name,
    Map<String, String>? environment,
    String? workingDirectory,
    bool runInShell = true,
  }) async {
    if (name != null) print("run $name");
    final process = await Process.start(
      executable[0],
      executable.sublist(1),
      environment: environment,
      workingDirectory: workingDirectory,
      runInShell: runInShell,
    );
    process.stdout.listen((data) {
      print(utf8.decode(data));
    });
    process.stderr.listen((data) {
      print(utf8.decode(data));
    });
    final exitCode = await process.exitCode;
    if (exitCode != 0 && name != null) throw "$name error";
  }

  static buildLib({
    required PlatformType platform,
    Arch? arch,
  }) async {
    final items = buildItems.where(
      (element) {
        return element.platform == platform &&
            (arch == null ? true : element.arch == arch);
      },
    ).toList();
    for (final item in items) {
      final outFileDir = join(
        outDir,
        item.platform.name,
        item.archName,
      );
      final file = File(outFileDir);
      if (file.existsSync()) {
        file.deleteSync(recursive: true);
      }
      final outPath = join(
        outFileDir,
        "$libName.${item.dynamicLibExtensionName}",
      );
      final Map<String, String> env = {};
      env["GOOS"] = item.os;
      env["GOARCH"] = item.arch.name;
      env["CGO_ENABLED"] = "1";
      env["CC"] = _getCc(item);

      await exec(
        [
          "go",
          "build",
          "-ldflags=-w -s",
          "-tags=$tags",
          "-buildmode=c-shared",
          "-o",
          outPath,
        ],
        name: "build libclash",
        environment: env,
        workingDirectory: _coreDir,
      );
    }
  }

  static List<String> getExecutable(String command) {
    return command.split(" ");
  }

  static getDistributor() async {
    final distributorDir = join(
      current,
      "plugins",
      "flutter_distributor",
      "packages",
      "flutter_distributor",
    );

    await exec(
      name: "clean distributor",
      Build.getExecutable("flutter clean"),
      workingDirectory: distributorDir,
    );
    await exec(
      name: "get distributor",
      Build.getExecutable("dart pub global activate -s path $distributorDir"),
    );
  }

  static copyFile(String sourceFilePath, String destinationFilePath) {
    final sourceFile = File(sourceFilePath);
    if (!sourceFile.existsSync()) {
      throw "SourceFilePath not exists";
    }
    final destinationFile = File(destinationFilePath);
    final destinationDirectory = destinationFile.parent;
    if (!destinationDirectory.existsSync()) {
      destinationDirectory.createSync(recursive: true);
    }
    try {
      sourceFile.copySync(destinationFilePath);
      print("File copied successfully!");
    } catch (e) {
      print("Failed to copy file: $e");
    }
  }
}

class BuildCommand extends Command {
  PlatformType platform;

  BuildCommand({
    required this.platform,
  }) {
    argParser.addOption(
      "build",
      valueHelp: [
        'all',
        'lib',
      ].join(','),
      help: 'The $name build type',
    );
    argParser.addOption(
      "arch",
      valueHelp: arches.map((e) => e.name).join(','),
      help: 'The $name build arch',
    );
  }

  @override
  String get description => "build $name application";

  @override
  String get name => platform.name;

  List<Arch> get arches => Build.buildItems
      .where((element) => element.platform == platform)
      .map((e) => e.arch)
      .toList();

  Future<void> _buildLib(Arch? arch) async {
    await Build.buildLib(platform: platform, arch: arch);
  }

  _getLinuxDependencies() async {
    await Build.exec(
      Build.getExecutable("sudo apt update -y"),
    );
    await Build.exec(
      Build.getExecutable("sudo apt install -y ninja-build libgtk-3-dev"),
    );
    await Build.exec(
      Build.getExecutable("sudo apt install -y libayatana-appindicator3-dev"),
    );
    await Build.exec(
      Build.getExecutable("sudo apt install -y rpm patchelf"),
    );
    await Build.exec(
      Build.getExecutable("sudo apt install -y locate"),
    );
    await Build.exec(
      Build.getExecutable("sudo apt install -y libfuse2"),
    );
    await Build.exec(
      Build.getExecutable(
        "wget -O appimagetool https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage",
      ),
    );
    await Build.exec(
      Build.getExecutable(
        "chmod +x appimagetool",
      ),
    );
    await Build.exec(
      Build.getExecutable(
        "sudo mv appimagetool /usr/local/bin/",
      ),
    );
  }

  _getMacosDependencies() async {
    await Build.exec(
      Build.getExecutable("npm install -g appdmg"),
    );
  }

  _buildDistributor({
    required PlatformType platform,
    required String targets,
    String args = '',
  }) async {
    await Build.getDistributor();
    await Build.exec(
      name: name,
      Build.getExecutable(
        "flutter_distributor package --skip-clean --platform ${platform.name} --targets $targets --flutter-build-args=verbose $args",
      ),
    );
  }

  @override
  Future<void> run() async {
    final String build = argResults?['build'] ?? 'all';
    final archName = argResults?['arch'];
    final currentArches =
        arches.where((element) => element.name == archName).toList();
    final arch = currentArches.isEmpty ? null : currentArches.first;
    if (arch == null && platform == PlatformType.windows) {
      throw "Invalid arch";
    }
    await _buildLib(arch);
    if (build != "all") {
      return;
    }
    switch (platform) {
      case PlatformType.windows:
        _buildDistributor(
          platform: platform,
          targets: "exe,zip",
          args: "--description ${arch!.name}",
        );
      case PlatformType.linux:
        await _getLinuxDependencies();
        _buildDistributor(
          platform: platform,
          targets: "appimage,deb,rpm",
          args: "--description ${arch!.name}",
        );
      case PlatformType.android:
        final targetMap = {
          Arch.arm: "android-arm",
          Arch.arm64: "android-arm64",
          Arch.amd64: "android-x64",
        };
        final defaultArches = [Arch.arm, Arch.arm64, Arch.amd64];
        final defaultTargets = defaultArches
            .where((element) => arch == null ? true : element == arch)
            .map((e) => targetMap[e])
            .toList();
        _buildDistributor(
          platform: platform,
          targets: "apk",
          args:
              "--flutter-build-args split-per-abi --build-target-platform ${defaultTargets.join(",")}",
        );
      case PlatformType.macos:
        await _getMacosDependencies();
        _buildDistributor(
          platform: platform,
          targets: "dmg",
          args: "--description ${arch!.name}",
        );
    }
  }
}

main(args) async {
  final runner = CommandRunner("setup", "build Application");
  runner.addCommand(BuildCommand(platform: PlatformType.android));
  if (Platform.isWindows) {
    runner.addCommand(BuildCommand(platform: PlatformType.windows));
  }
  if (Platform.isLinux) {
    runner.addCommand(BuildCommand(platform: PlatformType.linux));
  }
  if (Platform.isMacOS) {
    runner.addCommand(BuildCommand(platform: PlatformType.macos));
  }
  runner.run(args);
}
