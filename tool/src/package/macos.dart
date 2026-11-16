import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

import 'context.dart';
import 'steps.dart';

const macosProductsPath = 'build/macos/Build/Products/Release';

/// appdmg writes the window layout into `.DS_Store` itself, so packaging
/// never drives Finder.
TargetPlan planDmg(PackageContext context) {
  final config = context.makeConfig('dmg');
  final name = context.assetName(context.arch, 'dmg');
  final stage = context.stagingPath('dmg');
  final spec = p.join(stage, 'appdmg.json');
  final output = context.outputPath(name);

  return TargetPlan(
    steps: [
      Task(
        'copy the .app from $macosProductsPath into $stage and write $spec',
        () async {
          await recreateDirectory(stage);
          final apps = Directory(
            context.path(macosProductsPath),
          ).listSync().where((entity) => entity.path.endsWith('.app')).toList();
          if (apps.length != 1) {
            throw PackageError(
              '$macosProductsPath holds ${apps.length} .app bundles, expected 1',
            );
          }
          await Command('cp', [
            '-RH',
            apps.single.path,
            stage,
          ]).run(verbose: false);
          File(spec).writeAsStringSync(jsonEncode(config));
          final previous = File(output);
          if (previous.existsSync()) previous.deleteSync();
        },
      ),
      Command('appdmg', [spec, output]),
    ],
    artifacts: [PlannedArtifact(name: name, arch: context.arch)],
  );
}
