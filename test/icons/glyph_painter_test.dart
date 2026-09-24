import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:fl_clash/icons/icons.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

const _scale = 3;
const _side = 24 * _scale;

final _glyphs = {
  'dashboard': AppGlyphs.dashboard,
  'proxies': AppGlyphs.proxies,
  'profiles': AppGlyphs.profiles,
  'requests': AppGlyphs.requests,
  'history': AppGlyphs.history,
  'connections': AppGlyphs.connections,
  'dns': AppGlyphs.dns,
  'resources': AppGlyphs.resources,
  'logs': AppGlyphs.logs,
  'tools': AppGlyphs.tools,
  'target': AppGlyphs.target,
  'arrowBack': AppGlyphs.arrowBack,
  'chevronBack': AppGlyphs.chevronBack,
  'chevronForward': AppGlyphs.chevronForward,
  'chevronDown': AppGlyphs.chevronDown,
  'chevronUp': AppGlyphs.chevronUp,
  'caretDown': AppGlyphs.caretDown,
  'arrowUp': AppGlyphs.arrowUp,
  'arrowDown': AppGlyphs.arrowDown,
  'scrollToTop': AppGlyphs.scrollToTop,
  'openExternal': AppGlyphs.openExternal,
  'undo': AppGlyphs.undo,
  'redo': AppGlyphs.redo,
  'sync': AppGlyphs.sync,
  'refresh': AppGlyphs.refresh,
  'reset': AppGlyphs.reset,
  'export': AppGlyphs.export,
  'upload': AppGlyphs.upload,
  'add': AppGlyphs.add,
  'addCircle': AppGlyphs.addCircle,
  'remove': AppGlyphs.remove,
  'close': AppGlyphs.close,
  'check': AppGlyphs.check,
  'checkDouble': AppGlyphs.checkDouble,
  'checkCircle': AppGlyphs.checkCircle,
  'block': AppGlyphs.block,
  'info': AppGlyphs.info,
  'warning': AppGlyphs.warning,
  'error': AppGlyphs.error,
  'more': AppGlyphs.more,
  'moreCircle': AppGlyphs.moreCircle,
  'dragHandle': AppGlyphs.dragHandle,
  'sort': AppGlyphs.sort,
  'sortAlpha': AppGlyphs.sortAlpha,
  'textShort': AppGlyphs.textShort,
  'wrap': AppGlyphs.wrap,
  'listAdd': AppGlyphs.listAdd,
  'edit': AppGlyphs.edit,
  'compose': AppGlyphs.compose,
  'delete': AppGlyphs.delete,
  'clearAll': AppGlyphs.clearAll,
  'copy': AppGlyphs.copy,
  'cut': AppGlyphs.cut,
  'paste': AppGlyphs.paste,
  'selectAll': AppGlyphs.selectAll,
  'deselect': AppGlyphs.deselect,
  'search': AppGlyphs.search,
  'findReplace': AppGlyphs.findReplace,
  'save': AppGlyphs.save,
  'importFile': AppGlyphs.importFile,
  'cloudDownload': AppGlyphs.cloudDownload,
  'cloudSync': AppGlyphs.cloudSync,
  'link': AppGlyphs.link,
  'send': AppGlyphs.send,
  'rules': AppGlyphs.rules,
  'code': AppGlyphs.code,
  'settings': AppGlyphs.settings,
  'sliders': AppGlyphs.sliders,
  'wrench': AppGlyphs.wrench,
  'toggle': AppGlyphs.toggle,
  'pin': AppGlyphs.pin,
  'eye': AppGlyphs.eye,
  'eyeOff': AppGlyphs.eyeOff,
  'lock': AppGlyphs.lock,
  'lockOpen': AppGlyphs.lockOpen,
  'key': AppGlyphs.key,
  'password': AppGlyphs.password,
  'account': AppGlyphs.account,
  'sparkle': AppGlyphs.sparkle,
  'bolt': AppGlyphs.bolt,
  'locate': AppGlyphs.locate,
  'star': AppGlyphs.star,
  'puzzle': AppGlyphs.puzzle,
  'customize': AppGlyphs.customize,
  'layers': AppGlyphs.layers,
  'sun': AppGlyphs.sun,
  'moon': AppGlyphs.moon,
  'themeAuto': AppGlyphs.themeAuto,
  'pureBlack': AppGlyphs.pureBlack,
  'palette': AppGlyphs.palette,
  'paintbrush': AppGlyphs.paintbrush,
  'eyedropper': AppGlyphs.eyedropper,
  'motion': AppGlyphs.motion,
  'blur': AppGlyphs.blur,
  'textSize': AppGlyphs.textSize,
  'language': AppGlyphs.language,
  'keyboard': AppGlyphs.keyboard,
  'photos': AppGlyphs.photos,
  'camera': AppGlyphs.camera,
  'qrCode': AppGlyphs.qrCode,
  'torch': AppGlyphs.torch,
  'torchOff': AppGlyphs.torchOff,
  'torchAuto': AppGlyphs.torchAuto,
  'vpn': AppGlyphs.vpn,
  'shuffle': AppGlyphs.shuffle,
  'split': AppGlyphs.split,
  'speed': AppGlyphs.speed,
  'dataUsage': AppGlyphs.dataUsage,
  'memory': AppGlyphs.memory,
  'cpu': AppGlyphs.cpu,
  'devices': AppGlyphs.devices,
  'broom': AppGlyphs.broom,
  'wifi': AppGlyphs.wifi,
  'wifiOff': AppGlyphs.wifiOff,
  'networkCheck': AppGlyphs.networkCheck,
  'gavel': AppGlyphs.gavel,
  'appsList': AppGlyphs.appsList,
  'layoutList': AppGlyphs.layoutList,
  'layoutTabs': AppGlyphs.layoutTabs,
  'collapsed sidebar': AppGlyphs.sidebar(0),
  'expanded sidebar': AppGlyphs.sidebar(1),
  'play': AppGlyphs.playPause(0),
  'pause': AppGlyphs.playPause(1),
  'play pause midway': AppGlyphs.playPause(0.5),
  'play pause overshoot': AppGlyphs.playPause(1.1),
};

Future<Uint8List> _render(
  Glyph glyph,
  double fill, {
  Color color = const Color(0xFF000000),
}) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder)..scale(_scale.toDouble());
  GlyphPainter(
    glyph: glyph,
    fill: fill,
    color: color,
  ).paint(canvas, const Size.square(24));
  final image = await recorder.endRecording().toImage(_side, _side);
  final bytes = await image.toByteData();
  image.dispose();
  return bytes!.buffer.asUint8List();
}

int _alpha(Uint8List pixels, int pixel) => pixels[pixel * 4 + 3];

int _alphaAt(Uint8List pixels, double x, double y) =>
    _alpha(pixels, (y * _scale).floor() * _side + (x * _scale).floor());

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const ring = Glyph([
    GlyphCircle(12, 12, 8),
    GlyphPolyline([
      GlyphVertex(12, 4),
      GlyphVertex(12, 20),
    ], role: GlyphRole.detail),
  ]);

  test('a body fills inward from its outline', () async {
    final pixels = await _render(ring, 0.5);

    expect(_alphaAt(pixels, 18, 12), 255, reason: 'filled near the outline');
    expect(_alphaAt(pixels, 14, 12), 0, reason: 'still hollow at the core');
  });

  test('a detail thins away, then returns as a cutout', () async {
    final thinning = await _render(ring, 0.25);
    expect(_alphaAt(thinning, 12, 14), 255, reason: 'still stroked');
    expect(_alphaAt(thinning, 11.4, 14), lessThan(128), reason: 'thinner');

    final returning = await _render(ring, 0.75);
    expect(_alphaAt(returning, 12, 18), 0, reason: 'cut out of the fill');
    expect(_alphaAt(returning, 11.4, 18), greaterThan(128), reason: 'narrower');
  });

  test('a line gains weight as the glyph fills', () async {
    const bar = Glyph([
      GlyphPolyline([
        GlyphVertex(4, 12),
        GlyphVertex(20, 12),
      ], role: GlyphRole.line),
    ]);
    final outline = await _render(bar, 0);
    final filled = await _render(bar, 1);

    expect(_alphaAt(outline, 12, 13.1), 0);
    expect(_alphaAt(filled, 12, 13.1), greaterThan(0));
  });

  for (final MapEntry(key: name, value: glyph) in _glyphs.entries) {
    test('$name fills into a different shape than its outline', () async {
      final outline = await _render(glyph, 0);
      final filled = await _render(glyph, 1);

      expect(outline.any((channel) => channel != 0), isTrue);
      if (glyph.shapes.any((shape) => !shape.solid)) {
        expect(filled, isNot(outline));
      } else {
        expect(filled, outline, reason: 'solid shapes are already filled');
      }
    });

    test('$name shows no detail midway', () async {
      final bodies = Glyph([
        for (final shape in glyph.shapes)
          if (shape.role != GlyphRole.detail) shape,
      ]);

      expect(await _render(glyph, 0.5), await _render(bodies, 0.5));
    });

    test('$name stays even under a translucent color', () async {
      for (final fill in [0.0, 0.25, 0.75, 1.0]) {
        final pixels = await _render(
          glyph,
          fill,
          color: const Color(0x80000000),
        );
        final alphas = [
          for (var channel = 3; channel < pixels.length; channel += 4)
            pixels[channel],
        ];
        expect(alphas.reduce(math.max), lessThanOrEqualTo(0x80));
      }
    });
  }
}
