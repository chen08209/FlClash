import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'generate_status_icons.dart' as status_icons;
import 'src/icons/ico.dart';

const _source = 'assets_source/images/icon/app.svg';
const _res = 'android/app/src/main/res';
const _appIconSet = 'macos/Runner/Assets.xcassets/AppIcon.appiconset';
const _runningGlyphs = [
  'assets_source/images/icon/glyph.svg',
  'assets_source/images/icon/status_2.svg',
];
const _serviceIcon = 'android/service/src/main/res/drawable/ic_service.xml';

// Glyph heights of the icons on main, which every output keeps: the phone
// adaptive foreground in dp of its 108 dp canvas, the TV foreground and TV
// launcher rasters likewise, and the Play Store image in px of 512.
const _phoneGlyphDp = 45.69;
const _tvGlyphDp = 70.12;
const _playGlyphPx = 336.0;

const _adaptiveDp = 108.0;
const _adaptiveVisibleDp = 72.0;
const _artPx = 720;
const _platePx = 432;

const _densities = {
  'mdpi': 1.0,
  'hdpi': 1.5,
  'xhdpi': 2.0,
  'xxhdpi': 3.0,
  'xxxhdpi': 4.0,
};

Future<void> main() async {
  for (final tool in ['rsvg-convert', 'cwebp']) {
    if ((await Process.run('which', [tool])).exitCode != 0) {
      stderr.writeln('$tool is required (librsvg and webp).');
      exitCode = 1;
      return;
    }
  }
  final source = File(_source).readAsStringSync();
  final icon = _AppIcon.parse(source);
  final temp = await Directory.systemTemp.createTemp('app_icons_');
  final out = _Output(icon, temp);
  try {
    await out.png(
      'assets/images/icon.png',
      icon.document(1024, 1024, icon.plated(0, 0, 1024)),
    );
    final ico = buildIco([
      for (final size in icoSizes)
        IcoEntry(
          size: size,
          png: await out.render(
            icon.document(size, size, icon.plated(0, 0, size.toDouble())),
          ),
        ),
    ]);
    for (final path in [
      'assets/images/icon.ico',
      'windows/runner/resources/app_icon.ico',
    ]) {
      File(path).writeAsBytesSync(ico);
      stdout.writeln('Generated $path');
    }

    for (final size in [16, 32, 64, 128, 256, 512, 1024]) {
      final u = size / 1024;
      await out.png(
        '$_appIconSet/app_icon_$size.png',
        icon.document(
          size,
          size,
          icon.plated(
            100 * u,
            100 * u,
            824 * u,
            shadow: _Shadow(dy: 14 * u, blur: 10 * u, opacity: .25),
          ),
        ),
      );
    }

    await out.webp(
      '$_res/drawable-xxxhdpi/ic_launcher_plate.webp',
      icon.document(
        _platePx,
        _platePx,
        icon.plateFill(0, 0, _platePx.toDouble()),
      ),
    );
    await out.webp(
      '$_res/drawable-xxxhdpi/ic_launcher_art.webp',
      icon.artDocument(_artPx),
    );
    _writeInset(
      '$_res/drawable/ic_launcher_foreground.xml',
      icon,
      _phoneGlyphDp,
    );
    _writeInset(
      '$_res/drawable/ic_launcher_foreground_tv.xml',
      icon,
      _tvGlyphDp,
    );
    _writeMonochrome('$_res/drawable/ic_launcher_monochrome.xml', icon);

    for (final MapEntry(key: density, value: scale) in _densities.entries) {
      final size = 48 * scale;
      final u = size / 192;
      await out.webp(
        '$_res/mipmap-$density/ic_launcher.webp',
        icon.document(
          size,
          size,
          icon.framed(
            _Frame.square(20 * u, 152 * u, 12 * u),
            _Shadow(dy: 2 * u, blur: 2 * u, opacity: .49),
          ),
        ),
      );
      await out.webp(
        '$_res/mipmap-$density/ic_launcher_round.webp',
        icon.document(
          size,
          size,
          icon.framed(
            _Frame.circle(96 * u, 88 * u),
            _Shadow(dy: 2 * u, blur: 2 * u, opacity: .38),
          ),
        ),
      );
      final tv = 80 * scale;
      await out.webp(
        '$_res/mipmap-television-$density/ic_launcher.webp',
        icon.document(
          tv,
          tv,
          icon.fullBleed(tv, tv * _tvGlyphDp / _adaptiveDp),
        ),
      );
    }

    await out.png(
      'android/app/src/main/ic_launcher-playstore.png',
      icon.document(512, 512, icon.fullBleed(512, _playGlyphPx)),
    );

    const banner = '$_res/mipmap-xhdpi/ic_banner.png';
    final wordmark = await File(banner).copy('${temp.path}/wordmark.png');
    await out.png(
      banner,
      icon.document(
        320,
        180,
        '<image xlink:href="${wordmark.uri.pathSegments.last}" '
        'width="320" height="180"/>'
        '<rect width="140" height="180" fill="#F5F5F5"/>'
        '${icon.art(96, 73.5, 89.5)}',
      ),
    );
  } finally {
    await temp.delete(recursive: true);
  }

  _writeRunningGradient(icon);
  await status_icons.main();
}

// The running tray icon, the bare glyph and the Android service icon fill the
// unscaled glyph with the app icon's face gradient.
void _writeRunningGradient(_AppIcon icon) {
  final face = icon.rawFace;
  for (final path in _runningGlyphs) {
    final file = File(path);
    final svg = file.readAsStringSync().replaceFirstMapped(
      RegExp(r'( *)<linearGradient id="fill"[\s\S]*?</linearGradient>'),
      (match) {
        final indent = match[1]!;
        return '$indent<linearGradient id="fill" ${face.svgAxis} '
            'gradientUnits="userSpaceOnUse">\n'
            '${face.stops.map((stop) => '$indent  <stop offset="${_fixed(stop.offset, 4)}" '
                'stop-color="${stop.color.toUpperCase()}"/>\n').join()}'
            '$indent</linearGradient>';
      },
    );
    file.writeAsStringSync(svg);
    stdout.writeln('Generated $path');
  }
  final service = File(_serviceIcon);
  service.writeAsStringSync(
    service.readAsStringSync().replaceAllMapped(
      RegExp(r'( *)<gradient[\s\S]*?</gradient>'),
      (match) {
        final indent = match[1]!;
        return '$indent<gradient\n'
            '$indent    android:type="linear"\n'
            '${face.androidAxis('$indent    ')}>\n'
            '${face.stops.map((stop) => '$indent    <item android:offset="${_fixed(stop.offset, 4)}" '
                'android:color="#FF${stop.color.substring(1).toUpperCase()}" />\n').join()}'
            '$indent</gradient>';
      },
    ),
  );
  stdout.writeln('Generated $_serviceIcon');
}

void _writeInset(String path, _AppIcon icon, double glyphDp) {
  final artDp = glyphDp * 240 / icon.glyphHeight;
  final inset = (_adaptiveDp - artDp) / 2 / _adaptiveDp * 100;
  File(path).writeAsStringSync(
    '<inset xmlns:android="http://schemas.android.com/apk/res/android"\n'
    '    android:drawable="@drawable/ic_launcher_art"\n'
    '    android:inset="${_fixed(inset, 4)}%" />\n',
  );
  stdout.writeln('Generated $path');
}

void _writeMonochrome(String path, _AppIcon icon) {
  final scale = _phoneGlyphDp / _adaptiveDp * 240 / icon.rawHeight;
  final paths = [
    for (final bar in icon.bars) bar.pathData(icon.radius),
    icon.dot.pathData(icon.radius),
  ];
  File(path).writeAsStringSync(
    '<vector xmlns:android="http://schemas.android.com/apk/res/android"\n'
    '    android:width="108dp"\n'
    '    android:height="108dp"\n'
    '    android:viewportWidth="240"\n'
    '    android:viewportHeight="240">\n'
    '    <group\n'
    '        android:scaleX="${_fixed(scale, 5)}"\n'
    '        android:scaleY="${_fixed(scale, 5)}"\n'
    '        android:translateX="${_fixed(120 - scale * icon.rawCenter.x, 3)}"\n'
    '        android:translateY="${_fixed(120 - scale * icon.rawCenter.y, 3)}">\n'
    '${paths.map((data) => '        <path android:fillColor="#FF000000"\n'
        '            android:pathData="$data" />\n').join()}'
    '    </group>\n'
    '</vector>\n',
  );
  stdout.writeln('Generated $path');
}

String _fixed(double value, int digits) {
  final text = value.toStringAsFixed(digits);
  return text.contains('.')
      ? text.replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '')
      : text;
}

final class _Gradient {
  const _Gradient(this.start, this.end, this.stops);

  final math.Point<double> start;
  final math.Point<double> end;
  final List<({double offset, String color})> stops;

  String get svgAxis =>
      'x1="${_fixed(start.x, 2)}" y1="${_fixed(start.y, 2)}" '
      'x2="${_fixed(end.x, 2)}" y2="${_fixed(end.y, 2)}"';

  String androidAxis(String indent) =>
      '${indent}android:startX="${_fixed(start.x, 2)}"\n'
      '${indent}android:startY="${_fixed(start.y, 2)}"\n'
      '${indent}android:endX="${_fixed(end.x, 2)}"\n'
      '${indent}android:endY="${_fixed(end.y, 2)}"';
}

final class _Shadow {
  const _Shadow({required this.dy, required this.blur, required this.opacity});

  final double dy;
  final double blur;
  final double opacity;
}

final class _Frame {
  _Frame.square(double inset, double size, double radius)
    : element =
          '<rect x="$inset" y="$inset" width="$size" height="$size" '
          'rx="$radius"/>',
      center = inset + size / 2,
      size = size;

  _Frame.circle(this.center, double radius)
    : element = '<circle cx="$center" cy="$center" r="$radius"/>',
      size = radius * 2;

  final String element;
  final double center;
  final double size;
}

final class _Bar {
  const _Bar(this.from, this.to);

  final math.Point<double> from;
  final math.Point<double> to;

  String pathData(double r) {
    final length = from.distanceTo(to);
    final nx = (to.y - from.y) / length * r;
    final ny = -(to.x - from.x) / length * r;
    String p(double x, double y) => '${_fixed(x, 2)},${_fixed(y, 2)}';
    final r2 = _fixed(r, 2);
    return 'M${p(from.x + nx, from.y + ny)}L${p(to.x + nx, to.y + ny)}'
        'A$r2,$r2 0,0 1,${p(to.x - nx, to.y - ny)}'
        'L${p(from.x - nx, from.y - ny)}'
        'A$r2,$r2 0,0 1,${p(from.x + nx, from.y + ny)}Z';
  }
}

final class _Dot {
  const _Dot(this.center);

  final math.Point<double> center;

  String pathData(double r) {
    String p(double x) => '${_fixed(x, 2)},${_fixed(center.y, 2)}';
    final r2 = _fixed(r, 2);
    return 'M${p(center.x - r)}A$r2,$r2 0,1 1,${p(center.x + r)}'
        'A$r2,$r2 0,1 1,${p(center.x - r)}Z';
  }
}

// app.svg draws in a 240 unit space: `#base` is the plate, `#plate-fill` its
// colors over the whole square, and `#art` the glyph with its shadows, scaled
// about (120, 120) by the factor on the `#mask` group.
final class _AppIcon {
  _AppIcon._(
    this.defs,
    this.bars,
    this.dot,
    this.radius,
    this.glyphScale,
    this.face,
  );

  factory _AppIcon.parse(String source) {
    final defs = RegExp(
      r'<defs>([\s\S]*)</defs>',
    ).firstMatch(source)!.group(1)!;
    final mask = RegExp(
      r'<mask id="mask"[\s\S]*?</mask>',
    ).firstMatch(defs)!.group(0)!;
    double attr(String element, String name) => double.parse(
      RegExp('$name="([-\\d.]+)"').firstMatch(element)!.group(1)!,
    );
    final bars = [
      for (final line in RegExp(r'<line [^>]*>').allMatches(mask))
        _Bar(
          math.Point(attr(line[0]!, 'x1'), attr(line[0]!, 'y1')),
          math.Point(attr(line[0]!, 'x2'), attr(line[0]!, 'y2')),
        ),
    ];
    final circle = RegExp(r'<circle [^>]*>').firstMatch(mask)![0]!;
    final face = RegExp(
      r'<linearGradient id="face"[\s\S]*?</linearGradient>',
    ).firstMatch(defs)![0]!;
    final faceTag = RegExp(r'<linearGradient [^>]*>').firstMatch(face)![0]!;
    return _AppIcon._(
      defs,
      bars,
      _Dot(math.Point(attr(circle, 'cx'), attr(circle, 'cy'))),
      attr(mask, 'stroke-width') / 2,
      double.parse(RegExp(r'scale\(([\d.]+)\)').firstMatch(mask)!.group(1)!),
      _Gradient(
        math.Point(attr(faceTag, 'x1'), attr(faceTag, 'y1')),
        math.Point(attr(faceTag, 'x2'), attr(faceTag, 'y2')),
        [
          for (final stop in RegExp(r'<stop [^>]*>').allMatches(face))
            (
              offset: attr(stop[0]!, 'offset'),
              color: RegExp(
                'stop-color="(#[0-9a-fA-F]{6})"',
              ).firstMatch(stop[0]!)!.group(1)!,
            ),
        ],
      ),
    );
  }

  final String defs;
  final List<_Bar> bars;
  final _Dot dot;
  final double radius;
  final double glyphScale;
  final _Gradient face;

  _Gradient get rawFace {
    math.Point<double> unscale(math.Point<double> p) => math.Point(
      120 + (p.x - 120) / glyphScale,
      120 + (p.y - 120) / glyphScale,
    );
    return _Gradient(unscale(face.start), unscale(face.end), face.stops);
  }

  math.Rectangle<double> get _rawBounds {
    final xs = [
      for (final bar in bars) ...[bar.from.x, bar.to.x],
      dot.center.x,
    ];
    final ys = [
      for (final bar in bars) ...[bar.from.y, bar.to.y],
      dot.center.y,
    ];
    final left = xs.reduce(math.min) - radius;
    final top = ys.reduce(math.min) - radius;
    return math.Rectangle(
      left,
      top,
      xs.reduce(math.max) + radius - left,
      ys.reduce(math.max) + radius - top,
    );
  }

  double get rawHeight => _rawBounds.height;

  math.Point<double> get rawCenter {
    final bounds = _rawBounds;
    return math.Point(
      bounds.left + bounds.width / 2,
      bounds.top + bounds.height / 2,
    );
  }

  double get glyphHeight => rawHeight * glyphScale;

  math.Point<double> get glyphCenter => math.Point(
    120 + (rawCenter.x - 120) * glyphScale,
    120 + (rawCenter.y - 120) * glyphScale,
  );

  String document(num width, num height, String body, {String defs = ''}) =>
      '<svg xmlns="http://www.w3.org/2000/svg" '
      'xmlns:xlink="http://www.w3.org/1999/xlink" '
      'width="$width" height="$height" viewBox="0 0 $width $height">'
      '<defs>${this.defs}$defs</defs>$body</svg>';

  String artDocument(int size) {
    final center = glyphCenter;
    return '<svg xmlns="http://www.w3.org/2000/svg" '
        'xmlns:xlink="http://www.w3.org/1999/xlink" '
        'width="$size" height="$size" '
        'viewBox="${center.x - 120} ${center.y - 120} 240 240">'
        '<defs>$defs</defs><use xlink:href="#art"/></svg>';
  }

  String art(double height, double centerX, double centerY) {
    final k = height / glyphHeight;
    final center = glyphCenter;
    return '<use xlink:href="#art" transform="matrix($k 0 0 $k '
        '${centerX - k * center.x} ${centerY - k * center.y})"/>';
  }

  String plateFill(double left, double top, double size) {
    final k = size / 240;
    return '<use xlink:href="#plate-fill" '
        'transform="matrix($k 0 0 $k $left $top)"/>';
  }

  /// The plate of app.svg with its rim, placed so `#base` spans [size] px.
  String plated(double left, double top, double size, {_Shadow? shadow}) {
    final k = size / 234;
    final transform = 'matrix($k 0 0 $k ${left - 3 * k} ${top - 3 * k})';
    final drop = shadow == null
        ? ''
        : '<filter id="drop" x="-20%" y="-20%" width="140%" height="140%">'
              '<feGaussianBlur stdDeviation="${shadow.blur / k}"/></filter>'
              '<use xlink:href="#base" fill="#000" opacity="${shadow.opacity}" '
              'transform="translate(0 ${shadow.dy / k})" filter="url(#drop)"/>';
    return '<g transform="$transform">$drop<g clip-path="url(#plate)">'
        '<use xlink:href="#plate-fill"/>'
        '<use xlink:href="#base" fill="none" stroke="url(#rim)" '
        'stroke-width="2"/><use xlink:href="#art"/></g></g>';
  }

  /// An adaptive icon as a pre-O launcher draws it: the visible 72 dp of the
  /// 108 dp layers fill [frame], which casts [shadow].
  String framed(_Frame frame, _Shadow shadow) {
    final dp = frame.size / _adaptiveVisibleDp;
    final plate = _adaptiveDp * dp;
    return '<clipPath id="frame">${frame.element}</clipPath>'
        '<filter id="drop" x="-20%" y="-20%" width="140%" height="140%">'
        '<feGaussianBlur stdDeviation="${shadow.blur}"/></filter>'
        '<g fill="#000" opacity="${shadow.opacity}" '
        'transform="translate(0 ${shadow.dy})" filter="url(#drop)">'
        '${frame.element}</g>'
        '<g clip-path="url(#frame)">'
        '${plateFill(frame.center - plate / 2, frame.center - plate / 2, plate)}'
        '${art(_phoneGlyphDp * dp, frame.center, frame.center)}</g>';
  }

  String fullBleed(double size, double glyph) =>
      '${plateFill(0, 0, size)}${art(glyph, size / 2, size / 2)}';
}

final class _Output {
  _Output(this.icon, this.temp);

  final _AppIcon icon;
  final Directory temp;
  int _sequence = 0;

  Future<Uint8List> render(String svg) async {
    final input = File('${temp.path}/${_sequence++}.svg')
      ..writeAsStringSync(svg);
    final output = File('${input.path}.png');
    final result = await Process.run('rsvg-convert', [
      '-o',
      output.path,
      input.path,
    ]);
    if (result.exitCode != 0) {
      stderr.writeln(result.stderr);
      exit(result.exitCode);
    }
    return output.readAsBytesSync();
  }

  Future<void> png(String path, String svg) async {
    File(path).writeAsBytesSync(await render(svg));
    stdout.writeln('Generated $path');
  }

  Future<void> webp(String path, String svg) async {
    final png = File('${temp.path}/${_sequence++}.png')
      ..writeAsBytesSync(await render(svg));
    final result = await Process.run('cwebp', [
      '-quiet',
      '-lossless',
      '-exact',
      '-z',
      '9',
      png.path,
      '-o',
      path,
    ]);
    if (result.exitCode != 0) {
      stderr.writeln(result.stderr);
      exit(result.exitCode);
    }
    stdout.writeln('Generated $path');
  }
}
