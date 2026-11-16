import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:fl_clash/common/release_asset.dart';
import 'package:path/path.dart' as p;

import 'context.dart';
import 'steps.dart';

String windowsBundlePath(PackageContext context) {
  final flutterArch = context.arch == ReleaseArch.arm64 ? 'arm64' : 'x64';
  return context.path('build/windows/$flutterArch/runner/Release');
}

final _placeholder = RegExp(r'\{\{([A-Z_]+)\}\}');

/// Fills `{{NAME}}` placeholders; Inno Setup's own `{constant}` and `{{`
/// escapes never take that shape, so they pass through.
String renderInnoScript(String template, Map<String, String> variables) {
  final rendered = template.replaceAllMapped(_placeholder, (match) {
    final value = variables[match[1]];
    if (value == null) {
      throw PackageError(
        'inno_setup.iss uses {{${match[1]}}}, which has no value',
      );
    }
    return value;
  });
  if (rendered.contains('{%')) {
    throw const PackageError('inno_setup.iss still holds a {% %} tag');
  }
  return rendered;
}

String isccPath() {
  final configured = Platform.environment['INNO_SETUP_PATH'];
  for (final dir in [?configured, r'C:\Program Files (x86)\Inno Setup 6']) {
    final iscc = p.join(dir, 'ISCC.exe');
    if (File(iscc).existsSync()) return iscc;
  }
  return 'iscc';
}

Map<String, String> innoVariables(
  PackageContext context,
  Map<String, dynamic> config, {
  required String sourceDir,
  required String outputBaseName,
}) {
  final appName = config['app_name'] as String;
  return {
    'APP_ID': config['app_id'] as String,
    'APP_NAME': appName,
    'APP_VERSION': context.pubspecVersion,
    'DISPLAY_NAME': config['display_name'] as String,
    'PUBLISHER_NAME': config['publisher'] as String,
    'PUBLISHER_URL': config['publisher_url'] as String,
    'INSTALL_DIR_NAME':
        config['install_dir_name'] as String? ?? '{autopf64}\\$appName',
    'EXECUTABLE_NAME': config['executable_name'] as String,
    'OUTPUT_BASE_FILENAME': outputBaseName,
    'SOURCE_DIR': sourceDir,
    'SETUP_ICON_FILE': context.path(config['setup_icon_file'] as String),
    'CHINESE_SIMPLIFIED_MESSAGES': p.join(
      context.root,
      'windows',
      'packaging',
      'exe',
      'ChineseSimplified.isl',
    ),
    'ARCH': context.arch == ReleaseArch.arm64 ? 'arm64' : 'x64',
  };
}

TargetPlan planExe(PackageContext context) {
  final config = context.makeConfig('exe');
  final name = context.assetName(context.arch, 'exe', form: ReleaseForm.setup);
  final baseName = p.basenameWithoutExtension(name);
  final stage = context.outputPath('${baseName}_exe');
  final script = context.outputPath('$baseName.iss');
  final template = context.path(
    'windows/packaging/exe/${config['script_template']}',
  );

  return TargetPlan(
    steps: [
      Task(
        'copy ${windowsBundlePath(context)} to $stage and render $script',
        () async {
          await recreateDirectory(stage);
          await _copyTree(windowsBundlePath(context), stage);
          final content = renderInnoScript(
            File(template).readAsStringSync(),
            innoVariables(
              context,
              config,
              sourceDir: p.basename(stage),
              outputBaseName: baseName,
            ),
          );
          File(script).writeAsBytesSync(utf8.encode('\uFEFF$content'));
        },
      ),
      Command(isccPath(), [script]),
      Task('remove $stage and $script', () async {
        Directory(stage).deleteSync(recursive: true);
        File(script).deleteSync();
      }),
    ],
    artifacts: [
      PlannedArtifact(name: name, arch: context.arch, form: ReleaseForm.setup),
    ],
  );
}

TargetPlan planZip(PackageContext context) {
  final name = context.assetName(
    context.arch,
    'zip',
    form: ReleaseForm.portable,
  );
  final bundle = windowsBundlePath(context);
  return TargetPlan(
    steps: [
      Task(
        'zip the contents of $bundle into ${context.outputPath(name)}',
        () async {
          final encoder = ZipFileEncoder();
          await encoder.zipDirectory(
            Directory(bundle),
            filename: context.outputPath(name),
          );
        },
      ),
    ],
    artifacts: [
      PlannedArtifact(
        name: name,
        arch: context.arch,
        form: ReleaseForm.portable,
      ),
    ],
  );
}

Future<void> _copyTree(String from, String to) async {
  await for (final entity in Directory(from).list(recursive: true)) {
    final target = p.join(to, p.relative(entity.path, from: from));
    if (entity is Directory) {
      Directory(target).createSync(recursive: true);
    } else if (entity is File) {
      Directory(p.dirname(target)).createSync(recursive: true);
      entity.copySync(target);
    }
  }
}
