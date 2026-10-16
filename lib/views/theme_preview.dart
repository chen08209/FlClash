import 'dart:math' as math;
import 'dart:ui' show ImageFilter;

import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/providers/state.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

class PreviewChoice<T> {
  const PreviewChoice({
    required this.value,
    required this.label,
    required this.pictogram,
  });

  final T value;
  final String label;
  final Widget pictogram;
}

class PreviewChoiceGroup<T> extends StatelessWidget {
  const PreviewChoiceGroup({
    super.key,
    required this.info,
    required this.choices,
    required this.value,
    required this.onChanged,
  });

  final Info info;
  final List<PreviewChoice<T>> choices;
  final T value;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InfoHeader(info: info),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: generateSection(
            items: [
              for (final choice in choices)
                DecorationListItem(
                  leading: ExcludeSemantics(child: choice.pictogram),
                  title: Text(choice.label),
                  isSelected: choice.value == value,
                  trailing: choice.value == value
                      ? const SelectionCheck()
                      : null,
                  onPressed: () => onChanged(choice.value),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// The foot of a [MiniScreen], where the options differ, drawn at the size of
/// an icon.
class MiniScreenThumb extends StatelessWidget {
  const MiniScreenThumb({super.key, required this.screen});

  static const Size _screenSize = Size(96, 128);
  static const double _shownHeight = 66;
  static const double _height = 30;

  final Widget screen;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _height,
      width: _height * _screenSize.width / _shownHeight,
      child: ClipRSuperellipse(
        borderRadius: AppRadius.sm,
        child: FittedBox(
          child: SizedBox(
            width: _screenSize.width,
            height: _shownHeight,
            child: ClipRect(
              child: OverflowBox(
                alignment: Alignment.bottomCenter,
                minHeight: _screenSize.height,
                maxHeight: _screenSize.height,
                child: screen,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ColorSchemeTween extends Tween<ColorScheme> {
  _ColorSchemeTween({super.end});

  @override
  ColorScheme lerp(double t) => ColorScheme.lerp(begin!, end!, t);
}

/// The home page as the theme settings will draw it; its destinations can be
/// tapped to try the tab animation.
class ThemeLivePreview extends ConsumerStatefulWidget {
  const ThemeLivePreview({super.key});

  @override
  ConsumerState<ThemeLivePreview> createState() => _ThemeLivePreviewState();
}

class _ThemeLivePreviewState extends ConsumerState<ThemeLivePreview>
    with SingleTickerProviderStateMixin {
  static const double _phoneWidth = 168;
  static const _duration = Duration(milliseconds: 300);

  late final AnimationController _slide = AnimationController(
    vsync: this,
    duration: kTabScrollDuration,
  );
  late final CurvedAnimation _slideCurve = CurvedAnimation(
    parent: _slide,
    curve: Curves.easeOut,
  );
  int _selected = 0;
  int? _previous;

  @override
  void initState() {
    super.initState();
    ref.listenManual(
      appSettingProvider.select((state) => state.tabAnimation),
      (_, _) => _select((_selected + 1) % MiniScreen.destinationCount),
    );
  }

  Future<void> _select(int index) async {
    if (index == _selected) {
      return;
    }
    final tabAnimation = ref.read(appSettingProvider).tabAnimation;
    final fade = tabAnimation == TabAnimation.fade;
    _slide.duration = fade ? fadeTabDuration : kTabScrollDuration;
    _slideCurve.curve = fade ? fadeTabCurve : Curves.easeOut;
    setState(() {
      _previous = _selected;
      _selected = index;
    });
    await _slide.forward(from: 0).orCancel.catchError((_) {});
    if (mounted && _selected == index) {
      setState(() => _previous = null);
    }
  }

  @override
  void dispose() {
    _slideCurve.dispose();
    _slide.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(
      themeSettingProvider.select((state) => state.themeMode),
    );
    final brightness = switch (themeMode) {
      ThemeMode.light => Brightness.light,
      ThemeMode.dark => Brightness.dark,
      ThemeMode.system => MediaQuery.platformBrightnessOf(context),
    };
    final colorScheme = ref.watch(genColorSchemeProvider(brightness));
    final floatingBar = ref.watch(
      appSettingProvider.select((state) => state.floatingNavigationBar),
    );
    final tabAnimation = ref.watch(
      appSettingProvider.select((state) => state.tabAnimation),
    );
    final liquidGlass = ref.watch(
      themeSettingProvider.select(
        (state) => state.liquidGlass != LiquidGlassMode.none,
      ),
    );
    final corner = AppCorner.fit(_phoneWidth);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 24),
      alignment: Alignment.center,
      decoration: ShapeDecoration(
        color: context.raisedSurfaceLevel.colorOf(context.colorScheme),
        shape: AppShape.xxl,
      ),
      child: SizedBox(
        width: _phoneWidth,
        child: AspectRatio(
          aspectRatio: 9 / 17,
          child: ClipRSuperellipse(
            borderRadius: AppRadius.all(corner),
            child: TweenAnimationBuilder<ColorScheme>(
              tween: _ColorSchemeTween(end: colorScheme),
              duration: _duration,
              builder: (_, colorScheme, _) => AnimatedSwitcher(
                duration: _duration,
                child: AnimatedBuilder(
                  key: ValueKey((floatingBar, liquidGlass)),
                  animation: _slideCurve,
                  builder: (_, _) => MiniScreen(
                    colorScheme: colorScheme,
                    floatingBar: floatingBar,
                    liquidGlass: liquidGlass,
                    selected: _selected,
                    previous: _previous,
                    progress: _previous == null ? 1 : _slideCurve.value,
                    tabAnimation: tabAnimation,
                    onSelect: _select,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum _MiniPage { dashboard, proxies, profiles, tools }

/// A phone-shaped sketch of the home page, drawn in [colorScheme].
///
/// With [previous], the page is caught [progress] of the way through a switch
/// from it, drawn as [tabAnimation] moves the pages.
class MiniScreen extends StatelessWidget {
  const MiniScreen({
    super.key,
    required this.colorScheme,
    required this.floatingBar,
    this.liquidGlass = false,
    this.selected = 0,
    this.previous,
    this.progress = 1,
    this.tabAnimation = TabAnimation.slide,
    this.onSelect,
  });

  static const int destinationCount = 4;

  final ColorScheme colorScheme;
  final bool floatingBar;

  /// Draws a floating bar as glass; a docked one stays a fill, as the app's
  /// does.
  final bool liquidGlass;

  final int selected;
  final int? previous;
  final double progress;
  final TabAnimation tabAnimation;
  final ValueChanged<int>? onSelect;

  @override
  Widget build(BuildContext context) {
    final sketch = SizedBox.expand(
      child: CustomPaint(
        painter: _MiniScreenPainter(
          colorScheme: colorScheme,
          floatingBar: floatingBar,
          liquidGlass: liquidGlass,
          selected: selected,
          previous: previous,
          progress: progress,
          tabAnimation: tabAnimation,
        ),
      ),
    );
    final onSelect = this.onSelect;
    if (onSelect == null) {
      return sketch;
    }
    return LayoutBuilder(
      builder: (_, constraints) {
        final geometry = _MiniGeometry(
          constraints.biggest,
          floatingBar: floatingBar,
        );
        return Stack(
          children: [
            sketch,
            Positioned.fromRect(
              rect: geometry.bar,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var i = 0; i < destinationCount; i++)
                    Expanded(
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => onSelect(i),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class MiniSplitScreen extends StatelessWidget {
  const MiniSplitScreen({super.key, required this.light, required this.dark});

  final Widget light;
  final Widget dark;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        light,
        ClipPath(clipper: _DiagonalClipper(), child: dark),
      ],
    );
  }
}

class _DiagonalClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    return Path()
      ..moveTo(size.width * 0.7, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(size.width * 0.3, size.height)
      ..close();
  }

  @override
  bool shouldReclip(_DiagonalClipper oldClipper) => false;
}

class _MiniGeometry {
  _MiniGeometry(this.size, {required bool floatingBar})
    : unit = size.width / 20 {
    margin = unit * 1.5;
    final barHeight = floatingBar ? unit * 3.2 : unit * 3.6;
    pageBottom = floatingBar ? 0 : barHeight;
    bar = floatingBar
        ? Rect.fromLTWH(
            margin,
            size.height - margin - barHeight,
            size.width - margin * 2,
            barHeight,
          )
        : Rect.fromLTWH(0, size.height - barHeight, size.width, barHeight);
  }

  final Size size;
  final double unit;
  late final double margin;
  late final double pageBottom;
  late final Rect bar;
}

class _MiniScreenPainter extends CustomPainter {
  const _MiniScreenPainter({
    required this.colorScheme,
    required this.floatingBar,
    required this.liquidGlass,
    required this.selected,
    required this.previous,
    required this.progress,
    required this.tabAnimation,
  });

  final ColorScheme colorScheme;
  final bool floatingBar;
  final bool liquidGlass;
  final int selected;
  final int? previous;
  final double progress;
  final TabAnimation tabAnimation;

  bool get _glass => floatingBar && liquidGlass;

  static _MiniPage _pageOf(int index) =>
      _MiniPage.values[index % _MiniPage.values.length];

  static void _fill(
    Canvas canvas,
    Rect rect,
    Color color,
    ShapeBorder shape, {
    List<BoxShadow>? shadows,
  }) {
    ShapeDecoration(color: color, shape: shape, shadows: shadows)
        .createBoxPainter(() {})
        .paint(canvas, rect.topLeft, ImageConfiguration(size: rect.size));
  }

  @override
  void paint(Canvas canvas, Size size) {
    final geometry = _MiniGeometry(size, floatingBar: floatingBar);
    _paintPages(canvas, geometry);
    final unit = geometry.unit;
    final dock = SurfaceLevel.floatingOf(colorScheme).colorOf(colorScheme);
    final shadow = BoxShadow(
      color: colorScheme.shadow.withValues(alpha: 0.12),
      blurRadius: unit,
      offset: Offset(0, unit * 0.3),
    );
    if (_glass) {
      _paintGlassBar(canvas, geometry, shadow);
    } else if (floatingBar) {
      _fill(canvas, geometry.bar, dock, AppShape.full, shadows: [shadow]);
    } else {
      canvas.drawRect(geometry.bar, Paint()..color = dock);
    }
    _paintDestinations(canvas, geometry.bar, unit);
  }

  void _paintPages(Canvas canvas, _MiniGeometry geometry) {
    final size = geometry.size;
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = SurfaceLevel.page.colorOf(colorScheme),
    );
    canvas.save();
    canvas.clipRect(Offset.zero & size, doAntiAlias: false);
    final previous = this.previous;
    if (previous == null) {
      _paintPage(canvas, geometry, selected, 0);
    } else if (tabAnimation == TabAnimation.fade) {
      _paintPage(canvas, geometry, previous, 0, opacity: 1 - progress);
      _paintPage(canvas, geometry, selected, 0, opacity: progress);
    } else {
      final direction = previous > selected ? -1 : 1;
      _paintPage(
        canvas,
        geometry,
        previous,
        -direction * size.width * progress,
      );
      _paintPage(
        canvas,
        geometry,
        selected,
        direction * size.width * (1 - progress),
      );
    }
    canvas.restore();
  }

  /// The page frosted under a tint, ringed with light and casting its shadow
  /// only outside, after what [LiquidGlass] does at full size.
  void _paintGlassBar(Canvas canvas, _MiniGeometry geometry, BoxShadow shadow) {
    final bar = geometry.bar;
    final unit = geometry.unit;
    final path = AppShape.full.getOuterPath(bar);
    final style = LiquidGlassStyle.pill(colorScheme);
    final blur = unit * 0.4;
    canvas
      ..save()
      ..clipPath(
        Path()
          ..fillType = PathFillType.evenOdd
          ..addRect(bar.inflate(unit * 3))
          ..addPath(path, Offset.zero),
      );
    AppShape.full.paintInterior(
      canvas,
      bar.shift(shadow.offset),
      shadow.toPaint(),
    );
    canvas
      ..restore()
      ..save()
      ..clipPath(path)
      ..saveLayer(
        bar,
        Paint()..imageFilter = ImageFilter.blur(sigmaX: blur, sigmaY: blur),
      );
    _paintPages(canvas, geometry);
    final rimWidth = unit * 0.15;
    canvas
      ..restore()
      ..drawPath(path, Paint()..color = style.tint)
      ..drawPath(
        AppShape.full.getOuterPath(bar.deflate(rimWidth / 2)),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = rimWidth
          ..shader = LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withValues(alpha: style.rim),
              Colors.white.withValues(alpha: style.rim * 0.15),
              Colors.white.withValues(alpha: style.rim * 0.5),
            ],
          ).createShader(bar),
      )
      ..restore();
  }

  void _paintPage(
    Canvas canvas,
    _MiniGeometry geometry,
    int index,
    double offset, {
    double opacity = 1,
  }) {
    final alpha = Color.getAlphaFromOpacity(opacity);
    if (alpha == 0) {
      return;
    }
    final size = geometry.size;
    final margin = geometry.margin;
    final content = Rect.fromLTRB(
      offset + margin,
      margin,
      offset + size.width - margin,
      size.height - geometry.pageBottom,
    );
    if (alpha < 255) {
      canvas.saveLayer(null, Paint()..color = Color.fromARGB(alpha, 0, 0, 0));
    } else {
      canvas.save();
    }
    canvas.clipRect(content, doAntiAlias: false);
    _PageSketch(
      canvas,
      colorScheme,
      geometry.unit,
      content,
    ).paint(_pageOf(index));
    canvas.restore();
  }

  void _paintDestinations(Canvas canvas, Rect bar, double unit) {
    final cell = bar.width / MiniScreen.destinationCount;
    final dark = colorScheme.brightness == Brightness.dark;
    final indicator = _glass
        ? colorScheme.onSurface.withValues(alpha: dark ? 0.14 : 0.08)
        : SurfaceLevel.floatingOf(colorScheme).next.colorOf(colorScheme);
    for (var i = 0; i < MiniScreen.destinationCount; i++) {
      final center = Offset(bar.left + cell * i + cell / 2, bar.center.dy);
      final icon = center.translate(0, -unit * 0.4);
      final isSelected = i == selected;
      if (isSelected) {
        _fill(
          canvas,
          floatingBar
              ? Rect.fromCenter(
                  center: center,
                  width: cell - unit * 0.5,
                  height: bar.height - unit * 0.5,
                )
              : Rect.fromCenter(
                  center: icon,
                  width: unit * 2.8,
                  height: unit * 1.5,
                ),
          indicator,
          AppShape.full,
        );
      }
      final ink = isSelected
          ? colorScheme.primary
          : colorScheme.onSurfaceVariant;
      _fill(
        canvas,
        Rect.fromCircle(center: icon, radius: unit * 0.45),
        ink,
        AppShape.circle,
      );
      _fill(
        canvas,
        Rect.fromCenter(
          center: center.translate(0, unit * 0.8),
          width: unit * 1.7,
          height: unit * 0.35,
        ),
        isSelected ? ink : ink.withValues(alpha: 0.6),
        AppShape.full,
      );
    }
  }

  @override
  bool shouldRepaint(_MiniScreenPainter oldDelegate) {
    return oldDelegate.colorScheme != colorScheme ||
        oldDelegate.floatingBar != floatingBar ||
        oldDelegate.liquidGlass != liquidGlass ||
        oldDelegate.selected != selected ||
        oldDelegate.previous != previous ||
        oldDelegate.progress != progress ||
        oldDelegate.tabAnimation != tabAnimation;
  }
}

/// One page of a [MiniScreen] after the app's own, laid out in units of a
/// twentieth of the screen's width from the top left of [content].
class _PageSketch {
  _PageSketch(this.canvas, this.colorScheme, this.unit, this.content)
    : width = content.width / unit,
      card = SurfaceLevel.card.colorOf(colorScheme),
      inset = SurfaceLevel.inset.colorOf(colorScheme),
      text = colorScheme.onSurface.withValues(alpha: 0.72),
      line = colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
      faint = colorScheme.onSurfaceVariant.withValues(alpha: 0.16);

  static const double _gap = 0.6;

  final Canvas canvas;
  final ColorScheme colorScheme;
  final double unit;
  final Rect content;
  final double width;
  final Color card;
  final Color inset;
  final Color text;
  final Color line;
  final Color faint;

  void paint(_MiniPage page) {
    switch (page) {
      case _MiniPage.dashboard:
        _dashboard(_header(actions: 1));
      case _MiniPage.proxies:
        _proxies(_header(actions: 2));
      case _MiniPage.profiles:
        _profiles(_header(actions: 2));
      case _MiniPage.tools:
        _tools(_header(actions: 0));
    }
  }

  Rect _rect(double x, double y, double w, double h) => Rect.fromLTWH(
    content.left + x * unit,
    content.top + y * unit,
    w * unit,
    h * unit,
  );

  ShapeBorder _shape(double extent) =>
      AppShape.all(AppCorner.fit(unit * extent));

  void _block(Rect rect, Color color, {double extent = 5}) {
    _MiniScreenPainter._fill(canvas, rect, color, _shape(extent));
  }

  void _pill(double x, double y, double w, double h, Color color) {
    _MiniScreenPainter._fill(canvas, _rect(x, y, w, h), color, AppShape.full);
  }

  void _dot(double x, double y, double radius, Color color) {
    _MiniScreenPainter._fill(
      canvas,
      _rect(x - radius, y - radius, radius * 2, radius * 2),
      color,
      AppShape.circle,
    );
  }

  /// The title and the bar's round buttons; returns where the body starts.
  double _header({required int actions}) {
    _pill(0, 0.45, 7, 1.1, text);
    for (var i = 0; i < actions; i++) {
      final x = width - 1 - i * 2.4;
      _dot(x, 1, 1, card);
      _dot(x, 1, 0.3, line);
    }
    return 2.8;
  }

  void _dashboard(double top) {
    var y = top;
    final status = _rect(0, y, width, 6.2);
    final buttonX = width - 3;
    final buttonY = y + 3.1;
    _block(status, card);
    canvas
      ..save()
      ..clipPath(_shape(5).getOuterPath(status))
      ..drawCircle(
        _rect(buttonX, buttonY, 0, 0).topLeft,
        unit * 4.6,
        Paint()..color = colorScheme.primary.withValues(alpha: 0.1),
      )
      ..restore();
    _dot(buttonX, buttonY, 1.8, colorScheme.primary);
    for (final dx in [-0.675, 0.325]) {
      _pill(buttonX + dx, buttonY - 0.6, 0.35, 1.2, colorScheme.onPrimary);
    }
    _pill(1, y + 0.9, 3, 0.7, line);
    _dot(1.9, y + 3, 0.9, inset);
    _pill(3.5, y + 2.3, 5, 0.9, text);
    _pill(3.5, y + 3.5, 2.4, 0.7, inset);
    _pill(1, y + 4.8, 2.4, 0.7, line);
    _pill(4.6, y + 4.8, 3.6, 0.7, line);
    y += 6.2 + _gap;

    _block(_rect(0, y, width, 5.8), card);
    _pill(1, y + 0.9, 4.5, 0.7, line);
    final tileWidth = (width - 2.6) / 2;
    for (var i = 0; i < 2; i++) {
      final x = 1 + i * (tileWidth + 0.6);
      final tile = _rect(x, y + 2.1, tileWidth, 2.9);
      _block(tile, inset, extent: 2.9);
      _pill(x + 0.6, y + 2.65, 2.4, 0.7, line);
      _speedGraph(
        tile,
        phase: i * 1.7,
        color: i == 0
            ? colorScheme.primary.withValues(alpha: 0.5)
            : colorScheme.primary,
      );
    }
    y += 5.8 + _gap;

    _block(_rect(0, y, width, 4.4), card);
    _pill(1, y + 0.9, 4, 0.7, line);
    final segment = (width - 2.6) / 3;
    for (var i = 0; i < 3; i++) {
      final x = 1 + i * (segment + 0.3);
      _pill(x, y + 2.1, segment, 1.6, i == 0 ? colorScheme.primary : inset);
      _dot(
        x + segment / 2,
        y + 2.9,
        0.3,
        i == 0 ? colorScheme.onPrimary : line,
      );
    }
    y += 4.4 + _gap;

    _block(_rect(0, y, width, 3), card);
    _dot(1.9, y + 1.5, 0.9, colorScheme.primary);
    _pill(3.4, y + 1.1, 2.4, 0.8, line);
    _pill(width - 3.6, y + 0.8, 2.6, 1.4, colorScheme.primary);
    _dot(width - 1.7, y + 1.5, 0.55, colorScheme.onPrimary);
    y += 3 + _gap;

    for (var i = 0; i < 3; i++) {
      _block(_rect(0, y, width, 4.5), card);
      _pill(1, y + 0.9, 3.5 + i % 2, 0.7, line);
      y += 4.5 + _gap;
    }
  }

  void _speedGraph(Rect tile, {required double phase, required Color color}) {
    const steps = 16;
    final path = Path();
    for (var i = 0; i <= steps; i++) {
      final x = tile.left + tile.width * i / steps;
      final y =
          tile.top +
          tile.height * 0.68 +
          math.sin(i * 0.9 + phase) * unit * 0.35;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    final area = Path.from(path)
      ..lineTo(tile.right, tile.bottom)
      ..lineTo(tile.left, tile.bottom)
      ..close();
    canvas
      ..save()
      ..clipPath(_shape(2.9).getOuterPath(tile))
      ..drawPath(area, Paint()..color = color.withValues(alpha: color.a * 0.2))
      ..drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = unit * 0.15
          ..color = color,
      )
      ..restore();
  }

  void _proxies(double top) {
    var y = top;
    for (var i = 0; i < 9; i++) {
      _block(_rect(0, y, width, 2.6), card);
      _dot(1.5, y + 1.3, 0.8, inset);
      _pill(3, y + 0.6, 3 + i % 3, 0.7, line);
      _pill(3, y + 1.55, 4, 0.5, faint);
      _pill(width - 4.4, y + 1.05, 1.8, 0.5, faint);
      _dot(width - 1.3, y + 1.3, 0.55, inset);
      y += 2.6 + _gap;
    }
  }

  void _profiles(double top) {
    var y = top;
    for (var i = 0; i < 3; i++) {
      _block(_rect(0, y, width, 2.8), card);
      _pill(1, y + 0.7, 3.4 - i * 0.6, 0.75, line);
      _pill(
        4.8 - i * 0.6,
        y + 0.72,
        2.6,
        0.7,
        colorScheme.primary.withValues(alpha: 0.16),
      );
      _pill(1, y + 1.7, 3, 0.5, faint);
      _pill(width - 4.1, y + 1.15, 1.6, 0.5, faint);
      if (i == 0) {
        _dot(width - 1.4, y + 1.4, 0.6, colorScheme.primary);
      }
      y += 2.8 + _gap;
    }
  }

  void _tools(double top) {
    const rowHeight = 2.4;
    var y = top;
    for (final rows in [4, 7]) {
      _pill(0.8, y + 0.2, 1.6 + rows * 0.15, 0.5, faint);
      y += 1.3;
      _block(_rect(0, y, width, rows * rowHeight), card);
      for (var i = 0; i < rows; i++) {
        final row = y + i * rowHeight;
        _dot(1.3, row + rowHeight / 2, 0.45, line);
        _pill(2.6, row + 0.85, 4 + (i * 3 + rows) % 4, 0.7, line);
        if (i < rows - 1) {
          canvas.drawRect(
            _rect(2.6, row + rowHeight - 0.03, width - 3.4, 0.06),
            Paint()..color = faint,
          );
        }
      }
      y += rows * rowHeight + _gap * 2;
    }
  }
}
