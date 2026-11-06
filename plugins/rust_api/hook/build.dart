import 'dart:io';

import 'package:code_assets/code_assets.dart';
import 'package:flutter_rust_bridge_hooks/flutter_rust_bridge_hooks.dart';
import 'package:setup_hooks/setup_hooks.dart';

void main(List<String> args) async {
  await build(args, (input, output) async {
    if (input.userDefines['build_assets'] == false) {
      stdout.writeln('Skipping the Rust build: user-define build_assets=false');
      return;
    }
    await FlutterRustBridgeNativeAssetsBuilder(
      cratePath: _cratePath,
      extraCargoEnvironmentVariables: {
        ..._bindgenEnvironment(input),
        ..._trimmedPathEnvironment(input),
      },
    ).run(input: input, output: output);
  });
}

const _cratePath = 'rust';

Map<String, String> _trimmedPathEnvironment(BuildInput input) {
  if (!input.config.buildCodeAssets) return const {};
  return trimmedPathEnvironment(
    checkoutDir: Directory.fromUri(input.packageRoot.resolve('../..')).path,
    toolchainDir: Directory.fromUri(input.packageRoot.resolve(_cratePath)).path,
    targetTriple: rustTargetTriple(input.config.code),
  );
}

// rquickjs runs bindgen on Android, which must load the NDK's libclang; Linux
// NDKs before r26 keep it under lib64, later ones and every macOS NDK under lib.
Map<String, String> _bindgenEnvironment(BuildInput input) {
  if (!input.config.buildCodeAssets ||
      input.config.code.targetOS != OS.android) {
    return const {};
  }
  final compiler = input.config.code.cCompiler?.compiler;
  if (compiler == null) {
    return const {};
  }
  final llvmRoot = File.fromUri(compiler).parent.parent;
  for (final name in const ['lib', 'lib64']) {
    final directory = Directory(
      '${llvmRoot.path}${Platform.pathSeparator}$name',
    );
    if (directory.existsSync() && directory.listSync().any(_isLibclang)) {
      return {'LIBCLANG_PATH': directory.path};
    }
  }
  throw StateError(
    'No libclang under ${llvmRoot.path} (lib or lib64); the NDK Flutter '
    'passed cannot run bindgen for rquickjs',
  );
}

bool _isLibclang(FileSystemEntity entity) {
  return entity.path.split(Platform.pathSeparator).last.startsWith('libclang.');
}
