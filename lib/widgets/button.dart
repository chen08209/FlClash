import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:material_ui/material_ui.dart';

import 'builder.dart';
import 'card.dart';
import 'navigation_dock.dart';

class CommonFloatingActionButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final GlyphIcon icon;
  final String label;

  const CommonFloatingActionButton({
    super.key,
    this.onPressed,
    required this.icon,
    required this.label,
  });

  @override
  State<CommonFloatingActionButton> createState() =>
      _CommonFloatingActionButtonState();
}

class _CommonFloatingActionButtonState
    extends State<CommonFloatingActionButton> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    final isFocused = _focusNode.hasFocus;
    if (isFocused == _isFocused) {
      return;
    }
    setState(() {
      _isFocused = isFocused;
    });
  }

  OutlinedBorder? _buildFocusedShape(ThemeData theme) {
    if (!_isFocused) {
      return null;
    }
    final base = switch (theme.floatingActionButtonTheme.shape) {
      final OutlinedBorder shape => shape,
      _ => AppShape.md,
    };
    return base.copyWith(
      side: BorderSide(color: theme.colorScheme.primary, width: 3),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Theme(
      data: theme.copyWith(
        floatingActionButtonTheme: theme.floatingActionButtonTheme.copyWith(
          extendedIconLabelSpacing: 0,
          extendedPadding: const EdgeInsets.all(16),
        ),
      ),
      child: FloatingActionButtonExtendedBuilder(
        builder: (isExtended) {
          return ElasticButton(
            enabled: widget.onPressed != null,
            child: FloatingActionButton.extended(
              heroTag: null,
              focusNode: _focusNode,
              shape: _buildFocusedShape(theme),
              icon: widget.icon,
              onPressed: widget.onPressed,
              isExtended: true,
              label: Semantics(
                label: isExtended ? null : widget.label,
                child: AnimatedSize(
                  alignment: Alignment.centerLeft,
                  duration: midDuration,
                  curve: Curves.easeOutBack,
                  child: AnimatedOpacity(
                    duration: midDuration,
                    opacity: isExtended ? 1.0 : 0.4,
                    curve: Curves.linear,
                    child: isExtended
                        ? Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Text(widget.label, softWrap: false),
                          )
                        : const SizedBox.shrink(),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

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
          minTileHeight: 0,
          minVerticalPadding: 0,
          titleTextStyle: context.textTheme.bodyMedium?.toJetBrainsMono,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          title: Text(label, style: context.textTheme.bodyLarge),
          trailing:
              trailing ?? const GlyphIcon(AppGlyphs.chevronForward, size: 18),
        ),
      ),
    );
  }
}

enum TonalButtonSize {
  bar(button: 40, icon: 22),
  compact(button: 32, icon: 20);

  const TonalButtonSize({required this.button, required this.icon});

  final double button;
  final double icon;
}

/// Buttons sharing one filled pill, which answers a press on any of them as a
/// single button does.
class TonalButtonGroup extends StatelessWidget {
  const TonalButtonGroup({
    super.key,
    this.size = TonalButtonSize.bar,
    required this.children,
  });

  final TonalButtonSize size;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return ElasticPress(
      child: DecoratedBox(
        decoration: ShapeDecoration(
          color: context.colorScheme.secondaryContainer,
          shape: AppShape.full,
        ),
        child: TonalButtonTheme(
          grouped: true,
          size: size,
          child: Row(mainAxisSize: MainAxisSize.min, children: children),
        ),
      ),
    );
  }
}

/// Fills every button below and, as iOS does, leaves a press to the swell of
/// [ElasticPress]; inside a [TonalButtonGroup] the group is filled.
class TonalButtonTheme extends StatelessWidget {
  const TonalButtonTheme({
    super.key,
    this.grouped = false,
    this.size = TonalButtonSize.bar,
    required this.child,
  });

  final bool grouped;
  final TonalButtonSize size;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final fill = grouped ? Colors.transparent : colorScheme.secondaryContainer;
    final foreground = colorScheme.onSecondaryContainer;
    final disabledForeground = foreground.withValues(alpha: 0.38);
    ButtonStyle feedback(Color? tint) => ButtonStyle(
      splashFactory: NoSplash.splashFactory,
      overlayColor: WidgetStateProperty<Color?>.fromMap({
        if (tint != null) WidgetState.focused: tint.withValues(alpha: 0.1),
        WidgetState.pressed: Colors.transparent,
        if (tint != null) WidgetState.hovered: tint.withValues(alpha: 0.08),
      }),
    );
    return IconButtonTheme(
      data: IconButtonThemeData(
        style: feedback(foreground).merge(
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
          style: feedback(grouped ? foreground : null).merge(
            FilledButton.styleFrom(
              backgroundColor: grouped ? fill : null,
              foregroundColor: grouped ? foreground : null,
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
  }
}
