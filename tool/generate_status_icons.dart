import 'dart:io';
import 'dart:typed_data';

import 'src/icons/ico.dart';

const sourceDir = 'assets_source/images/icon';
const pngOutputDir = 'assets/images/tray/unix';
const icoOutputDir = 'assets/images/tray/windows';
const macosOutputDir = 'assets/images/tray/macos';
const statusIconNames = ['status_1', 'status_2', 'status_3', 'status_4'];
const macosStatusIconSources = {
  'status_1': '$sourceDir/glyph.svg',
  'status_4': '$sourceDir/status_4.svg',
};
const trayBaseSize = 18;
const trayScales = [1, 2, 3, 4];

Future<void> main() async {
  final rsvgConvert = await _findExecutable('rsvg-convert');
  if (rsvgConvert == null) {
    stderr.writeln(
      'rsvg-convert is required. Install librsvg before generating icons.',
    );
    exitCode = 1;
    return;
  }

  await Directory(icoOutputDir).create(recursive: true);
  final tempDir = await Directory.systemTemp.createTemp('status_icons_');
  final renderer = _Renderer(rsvgConvert, tempDir);
  try {
    for (final name in statusIconNames) {
      final source = File('$sourceDir/$name.svg');
      if (!source.existsSync()) {
        stderr.writeln('Missing source SVG: ${source.path}');
        exitCode = 1;
        return;
      }
      await _writeTrayVariants(renderer, source, name, pngOutputDir);
      await _writeIco(
        renderer,
        source,
        File('$icoOutputDir/$name.ico'),
        sizes: trayIcoSizes,
      );
    }
    for (final MapEntry(key: name, value: path)
        in macosStatusIconSources.entries) {
      final source = File(path);
      if (!source.existsSync()) {
        stderr.writeln('Missing source SVG: ${source.path}');
        exitCode = 1;
        return;
      }
      await _writeTrayVariants(
        renderer,
        await renderer.monochrome(source),
        name,
        macosOutputDir,
      );
    }
  } finally {
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  }
}

Future<void> _writeTrayVariants(
  _Renderer renderer,
  File source,
  String name,
  String outputDir,
) async {
  for (final scale in trayScales) {
    final directory = scale == 1 ? outputDir : '$outputDir/$scale.0x';
    await Directory(directory).create(recursive: true);
    final output = File('$directory/$name.png');
    await output.writeAsBytes(
      await renderer.render(source, trayBaseSize * scale),
    );
    stdout.writeln('Generated ${output.path}');
  }
}

Future<void> _writeIco(
  _Renderer renderer,
  File source,
  File output, {
  required List<int> sizes,
}) async {
  final entries = [
    for (final size in sizes)
      IcoEntry(size: size, png: await renderer.render(source, size)),
  ];
  await output.parent.create(recursive: true);
  await output.writeAsBytes(buildIco(entries));
  stdout.writeln('Generated ${output.path}');
}

Future<String?> _findExecutable(String executable) async {
  final result = await Process.run('which', [executable]);
  if (result.exitCode != 0) {
    return null;
  }
  return (result.stdout as String).trim();
}

class _Renderer {
  _Renderer(this.rsvgConvert, this.tempDir);

  final String rsvgConvert;
  final Directory tempDir;
  int _sequence = 0;

  Future<Uint8List> render(File source, int size) async {
    final output = File('${tempDir.path}/${_sequence++}-$size.png');
    final result = await Process.run(rsvgConvert, [
      '-w',
      '$size',
      '-h',
      '$size',
      '-o',
      output.path,
      source.path,
    ]);
    if (result.exitCode != 0) {
      stderr
        ..writeln('Failed to render ${source.path} at ${size}px')
        ..writeln(result.stderr);
      exit(result.exitCode);
    }
    return output.readAsBytes();
  }

  Future<File> monochrome(File source) async {
    final copy = File('${tempDir.path}/mono-${_basename(source)}');
    await copy.writeAsString(
      (await source.readAsString()).replaceAllMapped(
        RegExp(r'\b(fill|stroke)="(?!none")[^"]*"'),
        (match) => '${match[1]}="#000000"',
      ),
    );
    return copy;
  }

  String _basename(File file) => file.uri.pathSegments.last;
}
