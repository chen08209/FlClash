import 'dart:io';

import 'package:fl_clash/common/release_asset.dart';

import 'context.dart';
import 'steps.dart';

const apkOutputPath = 'build/app/outputs/flutter-apk';

const androidAbis = {
  ReleaseArch.arm64: 'arm64-v8a',
  ReleaseArch.armv7: 'armeabi-v7a',
  ReleaseArch.amd64: 'x86_64',
};

const androidFlutterTargets = {
  ReleaseArch.arm64: 'android-arm64',
  ReleaseArch.armv7: 'android-arm',
  ReleaseArch.amd64: 'android-x64',
};

String flutterApkName(ReleaseArch arch) {
  return arch == ReleaseArch.universal
      ? 'app-release.apk'
      : 'app-${androidAbis[arch]}-release.apk';
}

TargetPlan planApk(PackageContext context, List<ReleaseArch> arches) {
  final artifacts = [
    for (final arch in arches)
      PlannedArtifact(name: context.assetName(arch, 'apk'), arch: arch),
  ];
  return TargetPlan(
    steps: [
      Task('copy ${arches.map(flutterApkName).join(', ')} from $apkOutputPath '
          'into ${context.outputDirectory}', () async {
        for (final (index, arch) in arches.indexed) {
          File(
            context.path('$apkOutputPath/${flutterApkName(arch)}'),
          ).copySync(context.outputPath(artifacts[index].name));
        }
      }),
    ],
    artifacts: artifacts,
  );
}
