import 'package:fl_clash/state.dart';
import 'package:fl_clash/ui/icons/icons.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/widgets.dart';
import 'package:prism_ui/prism_ui.dart';

/// The fill of a status button in the dashboard bar: tinted glass when the
/// bar is glass, the plain [background] otherwise.
ButtonStyle statusBadgeStyle(
  BuildContext context, {
  Color? background,
  Color? foreground,
}) {
  final colorScheme = context.colorScheme;
  final pane = TonalButtonTheme.glassOf(context) && background != null
      ? LiquidGlassStyle.tinted(colorScheme, background)
      : null;
  return ButtonStyle.from(
    backgroundColor: pane == null ? background : Colors.transparent,
    foregroundColor: foreground,
    backgroundBuilder: pane == null
        ? null
        : LiquidGlass.buttonBackground((_) => pane),
    pressLook: PressLook.none,
  );
}

class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.tooltip,
    required this.glyph,
    required this.label,
    required this.onPressed,
    this.background,
    this.foreground,
  });

  final String tooltip;
  final Glyph glyph;
  final String label;
  final VoidCallback onPressed;
  final Color? background;
  final Color? foreground;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: FilledButton.icon(
        onPressed: onPressed,
        style: statusBadgeStyle(
          context,
          background: background,
          foreground: foreground,
        ),
        icon: GlyphIcon(
          glyph,
          fill: 1,
          size: globalState.measure.textHeight(AppTextStyle.subheadline),
        ),
        label: Text(label),
      ),
    );
  }
}
