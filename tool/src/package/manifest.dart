import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:fl_clash/common/release_asset.dart';
import 'package:path/path.dart' as p;

import 'context.dart';
import 'steps.dart';

const manifestName = 'manifest.json';

class ManifestEntry {
  const ManifestEntry({
    required this.name,
    required this.sha256,
    required this.size,
    required this.line,
    required this.version,
    required this.channel,
    required this.os,
    required this.arch,
    required this.form,
    required this.commit,
  });

  factory ManifestEntry.fromJson(Map<String, dynamic> json) {
    return ManifestEntry(
      name: json['name'] as String,
      sha256: json['sha256'] as String,
      size: json['size'] as int,
      line: ReleaseLine.values.byName(json['line'] as String),
      version: json['version'] as String,
      channel: json['channel'] as String,
      os: ReleaseOs.values.byName(json['os'] as String),
      arch: ReleaseArch.values.byName(json['arch'] as String),
      form: switch (json['form']) {
        final String form => ReleaseForm.values.byName(form),
        _ => null,
      },
      commit: json['commit'] as String,
    );
  }

  final String name;
  final String sha256;
  final int size;
  final ReleaseLine line;
  final String version;
  final String channel;
  final ReleaseOs os;
  final ReleaseArch arch;
  final ReleaseForm? form;
  final String commit;

  Map<String, Object?> toJson() => {
    'name': name,
    'sha256': sha256,
    'size': size,
    'line': line.name,
    'version': version,
    'channel': channel,
    'os': os.name,
    'arch': arch.name,
    'form': form?.name,
    'commit': commit,
  };
}

Future<ManifestEntry> describeArtifact(
  PackageContext context,
  PlannedArtifact artifact,
) async {
  final file = File(context.outputPath(artifact.name));
  if (!file.existsSync()) {
    throw PackageError('${file.path} was planned but not written');
  }
  return ManifestEntry(
    name: artifact.name,
    sha256: (await sha256.bind(file.openRead()).first).toString(),
    size: file.lengthSync(),
    line: context.line,
    version: context.version,
    channel: context.channel,
    os: context.os,
    arch: artifact.arch,
    form: artifact.form,
    commit: context.commit,
  );
}

String checksumsText(List<ManifestEntry> entries) {
  return entries.map((entry) => '${entry.sha256}  ${entry.name}\n').join();
}

String writeManifest(String directory, List<ManifestEntry> entries) {
  final lines = {for (final entry in entries) (entry.line, entry.version)};
  if (lines.length != 1) {
    throw PackageError(
      'one manifest holds one line and version, these artifacts have $lines',
    );
  }
  final checksums = releaseChecksumsName(lines.single.$2);
  final sorted = [...entries]..sort((a, b) => a.name.compareTo(b.name));
  File(p.join(directory, checksums)).writeAsStringSync(checksumsText(sorted));
  File(p.join(directory, manifestName)).writeAsStringSync(
    '${const JsonEncoder.withIndent('  ').convert({
      'checksums': checksums,
      'artifacts': [for (final entry in sorted) entry.toJson()],
    })}\n',
  );
  return checksums;
}

List<ManifestEntry> readManifest(String directory) {
  final json = jsonDecode(
    File(p.join(directory, manifestName)).readAsStringSync(),
  );
  return [
    for (final entry in (json as Map<String, dynamic>)['artifacts'] as List)
      ManifestEntry.fromJson(entry as Map<String, dynamic>),
  ];
}

/// Gathers the artifacts of several runs, as CI's per-platform jobs leave
/// them, into one directory with one manifest and one checksum file.
Future<String> mergeManifests(List<String> inputs, String output) async {
  Directory(output).createSync(recursive: true);
  final entries = <ManifestEntry>[];
  final names = <String>{};
  for (final input in inputs) {
    for (final entry in readManifest(input)) {
      if (!names.add(entry.name)) {
        throw PackageError('${entry.name} appears in more than one manifest');
      }
      final source = File(p.join(input, entry.name));
      final digest = (await sha256.bind(source.openRead()).first).toString();
      if (digest != entry.sha256) {
        throw PackageError('${source.path} does not match its manifest');
      }
      if (!p.equals(input, output)) {
        source.copySync(p.join(output, entry.name));
      }
      entries.add(entry);
    }
  }
  return writeManifest(output, entries);
}
