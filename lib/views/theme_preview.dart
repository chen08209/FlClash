import 'package:fl_clash/common/common.dart';
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
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final choice in choices)
                _ChoiceButton(
                  label: choice.label,
                  isSelected: choice.value == value,
                  onPressed: () => onChanged(choice.value),
                  pictogram: choice.pictogram,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ChoiceButton extends StatelessWidget {
  const _ChoiceButton({
    required this.label,
    required this.isSelected,
    required this.onPressed,
    required this.pictogram,
  });

  static const double _height = 48;

  final String label;
  final bool isSelected;
  final VoidCallback onPressed;
  final Widget pictogram;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: isSelected,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: _height),
        child: CommonCard(
          isSelected: isSelected,
          onPressed: onPressed,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 8,
            children: [
              ExcludeSemantics(child: pictogram),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
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
    final shape = AppShape.sm.copyWith(
      side: BorderSide(color: context.colorScheme.outlineVariant),
    );
    return SizedBox(
      height: _height,
      width: _height * _screenSize.width / _shownHeight,
      child: DecoratedBox(
        position: DecorationPosition.foreground,
        decoration: ShapeDecoration(shape: shape),
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
    final corner = AppCorner.fit(_phoneWidth);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 24),
      alignment: Alignment.center,
      decoration: ShapeDecoration(
        color: context.colorScheme.surfaceContainerLow,
        shape: AppShape.xxl,
      ),
      child: SizedBox(
        width: _phoneWidth,
        child: AspectRatio(
          aspectRatio: 9 / 17,
          child: DecoratedBox(
            position: DecorationPosition.foreground,
            decoration: ShapeDecoration(
              shape: AppShape.all(corner).copyWith(
                side: BorderSide(color: context.colorScheme.outlineVariant),
              ),
            ),
            child: ClipRSuperellipse(
              borderRadius: AppRadius.all(corner),
              child: TweenAnimationBuilder<ColorScheme>(
                tween: _ColorSchemeTween(end: colorScheme),
                duration: _duration,
                builder: (_, colorScheme, _) => AnimatedSwitcher(
                  duration: _duration,
                  child: AnimatedBuilder(
                    key: ValueKey(floatingBar),
                    animation: _slideCurve,
                    builder: (_, _) => MiniScreen(
                      colorScheme: colorScheme,
                      floatingBar: floatingBar,
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
      ),
    );
  }
}

enum _MiniPage { cards, list }

/// A phone-shaped sketch of the home page, drawn in [colorScheme].
///
/// With [previous], the page is caught [progress] of the way through a switch
/// from it, drawn as [tabAnimation] moves the pages.
class MiniScreen extends StatelessWidget {
  const MiniScreen({
    super.key,
    required this.colorScheme,
    required this.floatingBar,
    this.selected = 0,
    this.previous,
    this.progress = 1,
    this.tabAnimation = TabAnimation.slide,
    this.onSelect,
  });

  static const int destinationCount = 4;

  final ColorScheme colorScheme;
  final bool floatingBar;
  final int selected;
  final int? previous;
  final double progress;
  final TabAnimation tabAnimation;
  final ValueChanged<int>? onSelect;

  bool get _hasFab {
    final previous = this.previous;
    return previous == null || progress > 0.5 ? selected == 0 : previous == 0;
  }

  @override
  Widget build(BuildContext context) {
    final sketch = SizedBox.expand(
      child: CustomPaint(
        painter: _MiniScreenPainter(
          colorScheme: colorScheme,
          floatingBar: floatingBar,
          selected: selected,
          previous: previous,
          progress: progress,
          tabAnimation: tabAnimation,
          hasFab: _hasFab,
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
          hasFab: _hasFab,
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
  _MiniGeometry(this.size, {required bool floatingBar, required bool hasFab})
    : unit = size.width / 20 {
    margin = unit * 1.5;
    fabSize = unit * 3.2;
    final barHeight = floatingBar ? unit * 3.2 : unit * 3.6;
    pageBottom = floatingBar ? 0 : barHeight;
    if (floatingBar) {
      final right = margin + (hasFab ? fabSize + unit * 0.6 : 0);
      bar = Rect.fromLTWH(
        margin,
        size.height - margin - barHeight,
        size.width - right - margin,
        barHeight,
      );
      fab = Rect.fromLTWH(
        size.width - margin - fabSize,
        size.height - margin - fabSize,
        fabSize,
        fabSize,
      );
    } else {
      bar = Rect.fromLTWH(0, size.height - barHeight, size.width, barHeight);
      fab = Rect.fromLTWH(
        size.width - margin - fabSize * 1.6,
        size.height - (barHeight + margin) - fabSize,
        fabSize * 1.6,
        fabSize,
      );
    }
  }

  final Size size;
  final double unit;
  late final double margin;
  late final double fabSize;
  late final double pageBottom;
  late final Rect bar;
  late final Rect fab;
}

class _MiniScreenPainter extends CustomPainter {
  const _MiniScreenPainter({
    required this.colorScheme,
    required this.floatingBar,
    required this.selected,
    required this.previous,
    required this.progress,
    required this.tabAnimation,
    required this.hasFab,
  });

  final ColorScheme colorScheme;
  final bool floatingBar;
  final int selected;
  final int? previous;
  final double progress;
  final TabAnimation tabAnimation;
  final bool hasFab;

  static _MiniPage _pageOf(int index) =>
      index.isEven ? _MiniPage.cards : _MiniPage.list;

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

  static void _block(Canvas canvas, Rect rect, Color color, double extent) {
    _fill(canvas, rect, color, AppShape.all(AppCorner.fit(extent)));
  }

  @override
  void paint(Canvas canvas, Size size) {
    final geometry = _MiniGeometry(
      size,
      floatingBar: floatingBar,
      hasFab: hasFab,
    );
    canvas.drawRect(Offset.zero & size, Paint()..color = colorScheme.surface);
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
    final unit = geometry.unit;
    if (hasFab && !floatingBar) {
      _block(
        canvas,
        geometry.fab,
        colorScheme.primaryContainer,
        geometry.fabSize,
      );
    }
    if (floatingBar) {
      _fill(
        canvas,
        geometry.bar,
        colorScheme.surfaceContainer,
        AppShape.full,
        shadows: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.12),
            blurRadius: unit,
            offset: Offset(0, unit * 0.3),
          ),
        ],
      );
    } else {
      canvas.drawRect(
        geometry.bar,
        Paint()..color = colorScheme.surfaceContainer,
      );
    }
    _paintDestinations(canvas, geometry.bar, unit);
    if (hasFab && floatingBar) {
      _fill(canvas, geometry.fab, colorScheme.primaryContainer, AppShape.full);
    }
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
    final unit = geometry.unit;
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
    final left = content.left;
    final width = content.width;
    final card = colorScheme.surfaceContainer;
    final line = colorScheme.onSurfaceVariant.withValues(alpha: 0.4);
    var top = content.top;
    _fill(
      canvas,
      Rect.fromLTWH(left, top, unit * 7, unit * 1.1),
      colorScheme.onSurface.withValues(alpha: 0.72),
      AppShape.full,
    );
    top += unit * 1.1 + unit * 0.5 + unit;
    switch (_pageOf(index)) {
      case _MiniPage.cards:
        _block(
          canvas,
          Rect.fromLTWH(left, top, width, unit * 5),
          card,
          unit * 5,
        );
        _fill(
          canvas,
          Rect.fromLTWH(
            left + unit,
            top + (unit * 5 - unit * 2.2) / 2,
            unit * 2.2,
            unit * 2.2,
          ),
          colorScheme.primary,
          AppShape.circle,
        );
        final lineLeft = left + unit + unit * 2.2 + unit;
        final lineTop = top + (unit * 5 - (unit + unit * 0.6 + unit * 0.8)) / 2;
        _fill(
          canvas,
          Rect.fromLTWH(lineLeft, lineTop, unit * 6, unit),
          line,
          AppShape.full,
        );
        _fill(
          canvas,
          Rect.fromLTWH(
            lineLeft,
            lineTop + unit + unit * 0.6,
            unit * 3.5,
            unit * 0.8,
          ),
          line,
          AppShape.full,
        );
        top += unit * 5 + unit;
        final half = (width - unit) / 2;
        _block(
          canvas,
          Rect.fromLTWH(left, top, half, unit * 4),
          card,
          unit * 4,
        );
        _block(
          canvas,
          Rect.fromLTWH(left + half + unit, top, half, unit * 4),
          colorScheme.secondaryContainer,
          unit * 4,
        );
        top += unit * 4 + unit;
        for (var i = 0; i < 3; i++) {
          _block(
            canvas,
            Rect.fromLTWH(left, top, width, unit * 4.5),
            card,
            unit * 4.5,
          );
          top += unit * 4.5 + unit;
        }
      case _MiniPage.list:
        final lineLeft = left + unit * 2.2 + unit;
        for (var i = 0; i < 7; i++) {
          _fill(
            canvas,
            Rect.fromLTWH(
              left,
              top + (unit * 2.6 - unit * 2.2) / 2,
              unit * 2.2,
              unit * 2.2,
            ),
            i == 0
                ? colorScheme.tertiaryContainer
                : colorScheme.secondaryContainer,
            AppShape.circle,
          );
          final lineTop =
              top + (unit * 2.6 - (unit * 0.8 + unit * 0.5 + unit * 0.6)) / 2;
          _fill(
            canvas,
            Rect.fromLTWH(
              lineLeft,
              lineTop,
              unit * (8 - (i + index) % 3 * 1.5),
              unit * 0.8,
            ),
            line,
            AppShape.full,
          );
          _fill(
            canvas,
            Rect.fromLTWH(
              lineLeft,
              lineTop + unit * 0.8 + unit * 0.5,
              unit * 4,
              unit * 0.6,
            ),
            line.withValues(alpha: 0.2),
            AppShape.full,
          );
          top += unit * 2.6 + unit;
        }
    }
    canvas.restore();
  }

  void _paintDestinations(Canvas canvas, Rect bar, double unit) {
    final cell = bar.width / MiniScreen.destinationCount;
    for (var i = 0; i < MiniScreen.destinationCount; i++) {
      final center = Offset(bar.left + cell * i + cell / 2, bar.center.dy);
      final dot = Rect.fromCenter(
        center: center,
        width: unit * 0.9,
        height: unit * 0.9,
      );
      if (i != selected) {
        _fill(canvas, dot, colorScheme.onSurfaceVariant, AppShape.circle);
        continue;
      }
      _fill(
        canvas,
        Rect.fromCenter(center: center, width: unit * 2.8, height: unit * 1.6),
        colorScheme.secondaryContainer,
        AppShape.full,
      );
      _fill(canvas, dot, colorScheme.onSecondaryContainer, AppShape.circle);
    }
  }

  @override
  bool shouldRepaint(_MiniScreenPainter oldDelegate) {
    return oldDelegate.colorScheme != colorScheme ||
        oldDelegate.floatingBar != floatingBar ||
        oldDelegate.selected != selected ||
        oldDelegate.previous != previous ||
        oldDelegate.progress != progress ||
        oldDelegate.tabAnimation != tabAnimation ||
        oldDelegate.hasFab != hasFab;
  }
}
