import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/widgets/navigation_dock.dart';
import 'package:material_ui/material_ui.dart';

const double _itemHeight = 64;
const double _iconSize = 26;
const double _iconTop = 8;
const double _labelSize = 12;
const double _dividerThickness = 0.75;
const double _unselectedAlpha = 0.4;
const double _selectedPressedAlpha = 0.5;
const double _unselectedPressedAlpha = 0.6;
const double _focusAlpha = 0.1;
const double _focusWidth = 2;

/// compose-miuix's docked `NavigationBar`: monochrome destinations under a
/// hairline, the selected one bold and at full strength, with no indicator.
class MiuixNavigationBar extends StatelessWidget {
  const MiuixNavigationBar({
    super.key,
    required this.destinations,
    required this.selectedIndex,
    required this.onSelected,
    this.color,
  });

  final List<NavigationDockDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  /// The bar's background, the page's surface unless given.
  final Color? color;

  static double _itemHeightOf(BuildContext context) {
    return _itemHeight +
        MediaQuery.textScalerOf(context).scale(_labelSize) -
        _labelSize;
  }

  /// The bar's height, the system navigation's room under it included.
  static double heightOf(BuildContext context) {
    return _dividerThickness +
        _itemHeightOf(context) +
        MediaQuery.paddingOf(context).bottom;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return ColoredBox(
      color: color ?? colorScheme.surface,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Divider(
            height: _dividerThickness,
            thickness: _dividerThickness,
            color: colorScheme.outlineVariant,
          ),
          SizedBox(
            height: _itemHeightOf(context),
            child: Row(
              children: [
                for (final (index, destination) in destinations.indexed)
                  Expanded(
                    child: _MiuixNavigationItem(
                      destination: destination,
                      selected: index == selectedIndex,
                      onTap: () => onSelected(index),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(height: MediaQuery.paddingOf(context).bottom),
        ],
      ),
    );
  }
}

class _MiuixNavigationItem extends StatefulWidget {
  const _MiuixNavigationItem({
    required this.destination,
    required this.selected,
    required this.onTap,
  });

  final NavigationDockDestination destination;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_MiuixNavigationItem> createState() => _MiuixNavigationItemState();
}

class _MiuixNavigationItemState extends State<_MiuixNavigationItem> {
  late final Map<Type, Action<Intent>> _actions = {
    ActivateIntent: CallbackAction<ActivateIntent>(
      onInvoke: (_) {
        widget.onTap();
        return null;
      },
    ),
  };
  bool _pressed = false;
  bool _focused = false;

  void _press(bool pressed) {
    if (pressed != _pressed) {
      setState(() => _pressed = pressed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final strength = switch ((widget.selected, _pressed)) {
      (true, false) => 1.0,
      (true, true) => _selectedPressedAlpha,
      (false, false) => _unselectedAlpha,
      (false, true) => _unselectedPressedAlpha,
    };
    final color = colorScheme.onSurface.withValues(
      alpha: colorScheme.onSurface.a * strength,
    );
    return FocusableActionDetector(
      actions: _actions,
      mouseCursor: SystemMouseCursors.click,
      onShowFocusHighlight: (value) => setState(() => _focused = value),
      child: Semantics(
        container: true,
        button: true,
        selected: widget.selected,
        label: widget.destination.label,
        excludeSemantics: true,
        onTap: widget.onTap,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onTap,
          onTapDown: (_) => _press(true),
          onTapUp: (_) => _press(false),
          onTapCancel: () => _press(false),
          child: DecoratedBox(
            decoration: ShapeDecoration(
              color: _focused
                  ? colorScheme.onSurface.withValues(alpha: _focusAlpha)
                  : Colors.transparent,
              shape: AppShape.md.copyWith(
                side: _focused
                    ? BorderSide(
                        color: colorScheme.secondary,
                        width: _focusWidth,
                      )
                    : BorderSide.none,
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: _iconTop),
                GlyphIcon(
                  widget.destination.glyph,
                  size: _iconSize,
                  color: color,
                  fill: 1,
                ),
                Text(
                  widget.destination.label,
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.labelMedium?.copyWith(
                    fontSize: _labelSize,
                    fontWeight: widget.selected
                        ? FontWeight.w700
                        : FontWeight.w400,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
