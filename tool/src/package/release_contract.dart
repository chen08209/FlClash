import 'dart:ffi' show Abi;
import 'dart:io';

import 'package:fl_clash/common/release_asset.dart';
import 'package:path/path.dart' as p;

import 'manifest.dart';
import 'steps.dart';

const siteScript = 'site/assets/app.js';
const releaseNotesTemplate = '.github/release_template.md';
const homebrewCaskTemplate = '.github/homebrew_cask_template.rb';

typedef ReleaseLookup = ({String reader, String name});

const _desktopArches = ['amd64', 'arm64'];

List<String> siteAssetNames(String script, String version) {
  const naming = r'`FlClash-${release.version}-${id}`';
  if (!script.contains(naming)) {
    throw const PackageError(
      '$siteScript no longer builds names as $naming; '
      'teach tool/src/package/release_contract.dart its new form',
    );
  }
  final ids = [
    for (final match in RegExp(
      r"\bid: (?:'([^']+)'|`([^`]+)`)",
    ).allMatches(script))
      match[1] ?? match[2]!,
    for (final match in RegExp(
      r"assetName\(release, '([^']+)'\)",
    ).allMatches(script))
      match[1]!,
  ];
  return [
    for (final id in ids)
      for (final expanded in _expandArch(id, r'${goArch(arch)}'))
        'FlClash-$version-$expanded',
  ];
}

List<String> releaseNotesAssetNames(String template, String version) {
  return [
    for (final match in RegExp(
      r'releases/download/TAG/([^"]+)"',
    ).allMatches(template))
      _placeholderFree(
        match[1]!.replaceAll('VERSION', version),
        releaseNotesTemplate,
      ),
  ];
}

List<String> homebrewAssetNames(String cask, String version) {
  final url = RegExp(
    r'url "[^"]*/releases/download/v#\{version\}/([^"]+)"',
  ).firstMatch(cask);
  final arches = RegExp(
    r'arch arm: "([^"]+)", intel: "([^"]+)"',
  ).firstMatch(cask);
  if (url == null || arches == null) {
    throw const PackageError(
      '$homebrewCaskTemplate has no release url or arch line',
    );
  }
  final name = url[1]!.replaceAll('#{version}', version);
  return [
    for (final arch in [arches[1]!, arches[2]!])
      _placeholderFree(name.replaceAll('#{arch}', arch), homebrewCaskTemplate),
  ];
}

List<String> updaterAssetNames(String version) {
  final assets = {
    for (final abi in Abi.values) ?selfUpdateAssetFor(abi, replaceable: true),
  };
  return [
    for (final asset in assets)
      releaseAssetName(
        version: version,
        os: asset.os,
        arch: asset.arch,
        form: asset.form,
        extension: asset.extension,
      ),
  ];
}

List<ReleaseLookup> releaseLookups(String root, String version) {
  String read(String relative) =>
      File(p.join(root, relative)).readAsStringSync();
  return [
    for (final name in siteAssetNames(read(siteScript), version))
      (reader: siteScript, name: name),
    for (final name in releaseNotesAssetNames(
      read(releaseNotesTemplate),
      version,
    ))
      (reader: releaseNotesTemplate, name: name),
    for (final name in homebrewAssetNames(read(homebrewCaskTemplate), version))
      (reader: homebrewCaskTemplate, name: name),
    for (final name in [
      ...updaterAssetNames(version),
      releaseChecksumsName(version),
    ])
      (reader: 'in-app updater', name: name),
  ];
}

/// Every lookup the release gathered in [directory] would fail, as one line
/// each; empty when the release serves them all.
List<String> releaseContractFailures(String root, String directory) {
  final entries = readManifest(directory);
  final versions = {for (final entry in entries) entry.version};
  if (versions.length != 1) {
    throw PackageError('$directory holds versions $versions, not one');
  }
  final version = versions.single;
  final present = {
    for (final file in Directory(directory).listSync().whereType<File>())
      p.basename(file.path),
  };
  final failures = [
    for (final lookup in releaseLookups(root, version))
      if (!present.contains(lookup.name))
        '${lookup.reader} looks for ${lookup.name}, which is missing',
  ];
  final checksums = releaseChecksumsName(version);
  if (!present.contains(checksums)) return failures;
  final sums = File(p.join(directory, checksums)).readAsStringSync();
  final digests = {for (final entry in entries) entry.name: entry.sha256};
  for (final name in updaterAssetNames(version)) {
    if (!present.contains(name)) continue;
    final digest = digests[name];
    if (digest == null) {
      failures.add('in-app updater finds no sha256 for $name in the manifest');
    } else if (releaseChecksum(sums, name) != digest) {
      failures.add(
        'in-app updater finds no matching sha256 for $name in $checksums',
      );
    }
  }
  return failures;
}

Iterable<String> _expandArch(String id, String placeholder) {
  if (!id.contains(placeholder)) return [_placeholderFree(id, siteScript)];
  return [
    for (final arch in _desktopArches)
      _placeholderFree(id.replaceAll(placeholder, arch), siteScript),
  ];
}

String _placeholderFree(String name, String source) {
  if (RegExp(r'\$\{|#\{|TAG|LINE').hasMatch(name)) {
    throw PackageError('$source names $name, with a placeholder left in it');
  }
  return name;
}
