import 'package:fl_clash/ui/context.dart';
import 'package:fl_clash/ui/icons/icons.dart';
import 'package:fl_clash/ui/metrics.dart';
import 'package:fl_clash/ui/shape.dart';
import 'package:fl_clash/ui/surface.dart';
import 'package:flutter/gestures.dart';
import 'package:material_ui/material_ui.dart';

import 'card.dart';
import 'liquid_glass.dart';
import 'navigation_dock.dart';

class MoreActionButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String label;
  final Widget? trailing;

  const MoreActionButton({
    super.key,
    this.onPressed,
    required this.label,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: CommonCard(
        radius: AppCorner.xl,
        onPressed: onPressed,
        child: ListTile(
          minTileHeight: listRowMinHeight,
          minVerticalPadding: listRowVerticalPadding,
          titleTextStyle: context.listTitleStyle,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          title: Text(label),
          trailing:
              trailing ?? const GlyphIcon(AppGlyphs.chevronForward, size: 18),
        ),
      ),
    );
  }
}

enum TonalButtonSize {
  bar(button: 44, icon: 24),
  section(button: 36, icon: 20),
  compact(button: 32, icon: 20);

  const TonalButtonSize({required this.button, required this.icon});

  final double button;
  final double icon;
}

/// Buttons sharing one filled pill, which answers a press on any of them as a
/// single button does.
class TonalButtonGroup extends StatefulWidget {
  const TonalButtonGroup({
    super.key,
    this.size = TonalButtonSize.bar,
    required this.children,
  });

  final TonalButtonSize size;
  final List<Widget> children;

  @override
  State<TonalButtonGroup> createState() => _TonalButtonGroupState();
}

class _TonalButtonGroupState extends State<TonalButtonGroup> {
  final _pointer = ValueNotifier<int?>(null);

  @override
  void dispose() {
    _pointer.dispose();
    super.dispose();
  }

  void _handlePointerDown(PointerDownEvent event) {
    if (_pointer.value == null && event.buttons & kPrimaryButton != 0) {
      _pointer.value = event.pointer;
    }
  }

  void _handlePointerEnd(PointerEvent event) {
    if (event.pointer == _pointer.value) {
      _pointer.value = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final buttons = TonalButtonTheme(
      grouped: true,
      size: widget.size,
      child: Row(mainAxisSize: MainAxisSize.min, children: widget.children),
    );
    return ElasticPress(
      child: TonalButtonTheme.glassOf(context)
          ? Listener(
              onPointerDown: _handlePointerDown,
              onPointerUp: _handlePointerEnd,
              onPointerCancel: _handlePointerEnd,
              child: ValueListenableBuilder(
                valueListenable: _pointer,
                builder: (_, pointer, child) => LiquidGlass(
                  style: LiquidGlassStyle.regular(colorScheme),
                  pressed: pointer != null,
                  child: child,
                ),
                child: buttons,
              ),
            )
          : DecoratedBox(
              decoration: ShapeDecoration(
                color: context.raisedSurfaceLevel.colorOf(colorScheme),
                shape: AppShape.full,
              ),
              child: buttons,
            ),
    );
  }
}

/// A labelled button on the fill of a [TonalButtonGroup], for an action that
/// is not the one a screen is for.
class TonalButton extends StatelessWidget {
  const TonalButton({
    super.key,
    this.size = TonalButtonSize.section,
    this.glyph,
    required this.label,
    required this.onPressed,
  });

  final TonalButtonSize size;
  final Glyph? glyph;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final glyph = this.glyph;
    final label = Text(this.label);
    return ElasticPress(
      enabled: onPressed != null,
      child: DecoratedBox(
        decoration: ShapeDecoration(
          color: context.raisedSurfaceLevel.colorOf(context.colorScheme),
          shape: AppShape.full,
        ),
        child: TonalButtonTheme(
          grouped: true,
          size: size,
          child: glyph == null
              ? FilledButton(onPressed: onPressed, child: label)
              : FilledButton.icon(
                  onPressed: onPressed,
                  icon: GlyphIcon(glyph, fill: 1),
                  label: label,
                ),
        ),
      ),
    );
  }
}

/// Fills every button below and, as iOS does, leaves a press to the swell of
/// [ElasticPress]; inside a [TonalButtonGroup] the group is filled. With
/// [glass] the fills are panes of [LiquidGlass], a filled button's tinted.
class TonalButtonTheme extends StatelessWidget {
  const TonalButtonTheme({
    super.key,
    this.grouped = false,
    this.glass = false,
    this.size = TonalButtonSize.bar,
    required this.child,
  });

  final bool grouped;
  final bool glass;
  final TonalButtonSize size;
  final Widget child;

  /// Whether a button here stands on glass of its own.
  static bool glassOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_GlassButtons>()?.glass ??
      false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final paned = glass && !grouped;
    final fill = grouped || paned
        ? Colors.transparent
        : context.raisedSurfaceLevel.colorOf(colorScheme);
    final foreground = colorScheme.onSurface;
    final disabledForeground = foreground.withValues(alpha: 0.38);
    ButtonStyle? paneOf(bool Function(Set<WidgetState> states) tinted) {
      if (!paned) {
        return null;
      }
      final regularGlass = LiquidGlassStyle.regular(colorScheme);
      final tintedGlass = LiquidGlassStyle.tinted(
        colorScheme,
        colorScheme.primary,
      );
      return LiquidGlass.buttonStyle(
        (states) => tinted(states) ? tintedGlass : regularGlass,
      );
    }

    ButtonStyle feedback(
      Color? tint,
      ButtonStyle? pane, {
      required bool standsOff,
    }) => ButtonStyle(
      splashFactory: NoSplash.splashFactory,
      overlayColor: WidgetStateProperty<Color?>.fromMap({
        if (tint != null) WidgetState.focused: tint.withValues(alpha: 0.1),
        WidgetState.pressed: Colors.transparent,
        if (tint != null) WidgetState.hovered: tint.withValues(alpha: 0.08),
      }),
    ).merge(pane).merge(focusRingStyle(colorScheme, standsOff: standsOff));
    final iconPane = paneOf((states) => states.contains(WidgetState.selected));
    final filledPane = paneOf(
      (states) => !states.contains(WidgetState.disabled),
    );
    final filledFeedback = feedback(
      grouped ? foreground : null,
      filledPane,
      standsOff: !grouped,
    );
    final themed = IconButtonTheme(
      data: IconButtonThemeData(
        style: feedback(foreground, iconPane, standsOff: paned).merge(
          IconButton.styleFrom(
            backgroundColor: fill,
            foregroundColor: foreground,
            disabledBackgroundColor: fill,
            disabledForegroundColor: disabledForeground,
            fixedSize: Size.square(size.button),
            minimumSize: Size.square(size.button),
            padding: EdgeInsets.zero,
            iconSize: size.icon,
            visualDensity: VisualDensity.standard,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
      ),
      child: FilledButtonTheme(
        data: FilledButtonThemeData(
          style: filledFeedback.merge(
            FilledButton.styleFrom(
              backgroundColor: grouped ? fill : null,
              foregroundColor: grouped
                  ? foreground
                  : paned
                  ? colorScheme.onPrimary
                  : null,
              disabledBackgroundColor: grouped ? fill : null,
              disabledForegroundColor: grouped ? disabledForeground : null,
              minimumSize: Size.square(size.button),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              shape: AppShape.full,
              visualDensity: VisualDensity.standard,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ),
        child: IconTheme.merge(
          data: const IconThemeData(fill: 1),
          child: child,
        ),
      ),
    );
    return _GlassButtons(glass: paned, child: themed);
  }
}

class _GlassButtons extends InheritedWidget {
  const _GlassButtons({required this.glass, required super.child});

  final bool glass;

  @override
  bool updateShouldNotify(_GlassButtons oldWidget) => glass != oldWidget.glass;
}
