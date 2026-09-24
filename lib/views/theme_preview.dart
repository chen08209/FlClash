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

  static _MiniPage _pageOf(int index) =>
      index.isEven ? _MiniPage.cards : _MiniPage.list;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        final width = constraints.maxWidth;
        final unit = width / 20;
        final margin = unit * 1.5;
        final barHeight = floatingBar ? unit * 3.2 : unit * 3.6;
        final fabSize = unit * 3.2;
        final previous = this.previous;
        final hasFab = previous == null || progress > 0.5
            ? selected == 0
            : previous == 0;
        final pageBottom = floatingBar ? 0.0 : barHeight;
        final direction = previous != null && previous > selected ? -1 : 1;
        Widget pageAt(int index, double offset, {double opacity = 1}) {
          return Positioned(
            left: offset,
            width: width,
            top: 0,
            bottom: pageBottom,
            child: Opacity(
              opacity: opacity,
              child: Padding(
                padding: EdgeInsets.fromLTRB(margin, margin, margin, 0),
                child: ClipRect(
                  child: OverflowBox(
                    alignment: Alignment.topCenter,
                    maxHeight: double.infinity,
                    child: _MiniPageContent(
                      colorScheme: colorScheme,
                      page: _pageOf(index),
                      seed: index,
                      unit: unit,
                    ),
                  ),
                ),
              ),
            ),
          );
        }

        List<Widget> switching(int previous) {
          if (tabAnimation == TabAnimation.fade) {
            return [
              pageAt(previous, 0, opacity: 1 - progress),
              pageAt(selected, 0, opacity: progress),
            ];
          }
          return [
            pageAt(previous, -direction * width * progress),
            pageAt(selected, direction * width * (1 - progress)),
          ];
        }

        final destinations = _MiniDestinations(
          colorScheme: colorScheme,
          selected: selected,
          unit: unit,
          onSelect: onSelect,
        );
        return ColoredBox(
          color: colorScheme.surface,
          child: Stack(
            children: [
              if (previous == null)
                pageAt(selected, 0)
              else
                ...switching(previous),
              if (hasFab && !floatingBar)
                Positioned(
                  right: margin,
                  bottom: barHeight + margin,
                  width: fabSize * 1.6,
                  height: fabSize,
                  child: _MiniBlock(
                    color: colorScheme.primaryContainer,
                    extent: fabSize,
                  ),
                ),
              if (floatingBar)
                Positioned(
                  left: margin,
                  right: margin + (hasFab ? fabSize + unit * 0.6 : 0),
                  bottom: margin,
                  height: barHeight,
                  child: DecoratedBox(
                    decoration: ShapeDecoration(
                      color: colorScheme.surfaceContainer,
                      shape: AppShape.full,
                      shadows: [
                        BoxShadow(
                          color: colorScheme.shadow.withValues(alpha: 0.12),
                          blurRadius: unit,
                          offset: Offset(0, unit * 0.3),
                        ),
                      ],
                    ),
                    child: destinations,
                  ),
                )
              else
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: barHeight,
                  child: ColoredBox(
                    color: colorScheme.surfaceContainer,
                    child: destinations,
                  ),
                ),
              if (hasFab && floatingBar)
                Positioned(
                  right: margin,
                  bottom: margin,
                  width: fabSize,
                  height: fabSize,
                  child: DecoratedBox(
                    decoration: ShapeDecoration(
                      color: colorScheme.primaryContainer,
                      shape: AppShape.full,
                    ),
                  ),
                ),
            ],
          ),
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

class _MiniPageContent extends StatelessWidget {
  const _MiniPageContent({
    required this.colorScheme,
    required this.page,
    required this.seed,
    required this.unit,
  });

  final ColorScheme colorScheme;
  final _MiniPage page;
  final int seed;
  final double unit;

  @override
  Widget build(BuildContext context) {
    final card = colorScheme.surfaceContainer;
    final line = colorScheme.onSurfaceVariant.withValues(alpha: 0.4);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: unit,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: unit * 0.5),
          child: _MiniLine(
            color: colorScheme.onSurface.withValues(alpha: 0.72),
            width: unit * 7,
            height: unit * 1.1,
          ),
        ),
        ...switch (page) {
          _MiniPage.cards => [
            _MiniCard(
              color: card,
              height: unit * 5,
              unit: unit,
              child: Row(
                spacing: unit,
                children: [
                  _MiniDot(color: colorScheme.primary, size: unit * 2.2),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: unit * 0.6,
                      children: [
                        _MiniLine(color: line, width: unit * 6, height: unit),
                        _MiniLine(
                          color: line,
                          width: unit * 3.5,
                          height: unit * 0.8,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Row(
              spacing: unit,
              children: [
                Expanded(
                  child: _MiniCard(color: card, height: unit * 4, unit: unit),
                ),
                Expanded(
                  child: _MiniCard(
                    color: colorScheme.secondaryContainer,
                    height: unit * 4,
                    unit: unit,
                  ),
                ),
              ],
            ),
            for (var i = 0; i < 3; i++)
              _MiniCard(color: card, height: unit * 4.5, unit: unit),
          ],
          _MiniPage.list => [
            for (var i = 0; i < 7; i++)
              SizedBox(
                height: unit * 2.6,
                child: Row(
                  spacing: unit,
                  children: [
                    _MiniDot(
                      color: i == 0
                          ? colorScheme.tertiaryContainer
                          : colorScheme.secondaryContainer,
                      size: unit * 2.2,
                    ),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: unit * 0.5,
                        children: [
                          _MiniLine(
                            color: line,
                            width: unit * (8 - (i + seed) % 3 * 1.5),
                            height: unit * 0.8,
                          ),
                          _MiniLine(
                            color: line.withValues(alpha: 0.2),
                            width: unit * 4,
                            height: unit * 0.6,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        },
      ],
    );
  }
}

class _MiniDestinations extends StatelessWidget {
  const _MiniDestinations({
    required this.colorScheme,
    required this.selected,
    required this.unit,
    required this.onSelect,
  });

  final ColorScheme colorScheme;
  final int selected;
  final double unit;
  final ValueChanged<int>? onSelect;

  Widget _buildDestination(int index) {
    if (index != selected) {
      return _MiniDot(color: colorScheme.onSurfaceVariant, size: unit * 0.9);
    }
    return Container(
      width: unit * 2.8,
      height: unit * 1.6,
      alignment: Alignment.center,
      decoration: ShapeDecoration(
        color: colorScheme.secondaryContainer,
        shape: AppShape.full,
      ),
      child: _MiniDot(
        color: colorScheme.onSecondaryContainer,
        size: unit * 0.9,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final onSelect = this.onSelect;
    return Row(
      children: [
        for (var i = 0; i < MiniScreen.destinationCount; i++)
          Expanded(
            child: onSelect == null
                ? Center(child: _buildDestination(i))
                : MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => onSelect(i),
                      child: Center(child: _buildDestination(i)),
                    ),
                  ),
          ),
      ],
    );
  }
}

class _MiniCard extends StatelessWidget {
  const _MiniCard({
    required this.color,
    required this.height,
    required this.unit,
    this.child,
  });

  final Color color;
  final double height;
  final double unit;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: _MiniBlock(
        color: color,
        extent: height,
        padding: EdgeInsets.symmetric(horizontal: unit),
        child: child,
      ),
    );
  }
}

class _MiniBlock extends StatelessWidget {
  const _MiniBlock({
    required this.color,
    required this.extent,
    this.padding,
    this.child,
  });

  final Color color;
  final double extent;
  final EdgeInsets? padding;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: ShapeDecoration(
        color: color,
        shape: AppShape.all(AppCorner.fit(extent)),
      ),
      child: child,
    );
  }
}

class _MiniLine extends StatelessWidget {
  const _MiniLine({
    required this.color,
    required this.width,
    required this.height,
  });

  final Color color;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: ShapeDecoration(color: color, shape: AppShape.full),
    );
  }
}

class _MiniDot extends StatelessWidget {
  const _MiniDot({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: ShapeDecoration(color: color, shape: AppShape.circle),
    );
  }
}
