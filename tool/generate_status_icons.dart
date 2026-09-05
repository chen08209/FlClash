import 'dart:io';
import 'dart:typed_data';

import 'src/icons/ico.dart';

const sourceDir = 'assets_source/images/icon';
const pngOutputDir = 'assets/images/tray/unix';
const icoOutputDir = 'assets/images/tray/windows';
const statusIconNames = ['status_1', 'status_2', 'status_3'];
const trayBaseSize = 18;
const trayScales = [1, 2, 3, 4];
const appIconSource = 'assets/images/icon.png';
const appIconOutput = 'windows/runner/resources/app_icon.ico';

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
      await _writeTrayVariants(renderer, source, name);
      await _writeIco(
        renderer,
        source,
        File('$icoOutputDir/$name.ico'),
        sizes: trayIcoSizes,
      );
    }
    final appIcon = await renderer.wrapRaster(File(appIconSource));
    await _writeIco(renderer, appIcon, File(appIconOutput));
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
) async {
  for (final scale in trayScales) {
    final directory = scale == 1 ? pngOutputDir : '$pngOutputDir/$scale.0x';
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
  List<int> sizes = icoSizes,
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

  // librsvg only follows image references inside the SVG's own directory, so
  // the raster is copied next to its wrapper before rendering.
  Future<File> wrapRaster(File raster) async {
    final copy = await raster.copy('${tempDir.path}/${_basename(raster)}');
    final wrapper = File('${tempDir.path}/${_basename(raster)}.svg');
    await wrapper.writeAsString(
      '<svg xmlns="http://www.w3.org/2000/svg" '
      'xmlns:xlink="http://www.w3.org/1999/xlink" '
      'width="256" height="256" viewBox="0 0 256 256">'
      '<image xlink:href="${_basename(copy)}" width="256" height="256"/>'
      '</svg>',
    );
    return wrapper;
  }

  String _basename(File file) => file.uri.pathSegments.last;
}
