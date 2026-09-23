import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:material_ui/material_ui.dart';

import 'builder.dart';
import 'card.dart';

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
          return FloatingActionButton.extended(
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
