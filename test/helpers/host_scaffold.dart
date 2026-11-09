import 'package:flutter/widgets.dart';
import 'package:prism_ui/prism_ui.dart';

/// A page to stand a widget on where a test is not about the page.
class HostScaffold extends StatelessWidget {
  const HostScaffold({
    super.key,
    this.backgroundColor,
    this.body = const SizedBox.shrink(),
  });

  final Color? backgroundColor;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    return Surface(
      color: backgroundColor ?? context.colorScheme.surface,
      child: Align(alignment: Alignment.topLeft, child: body),
    );
  }
}

/// A plain row for a test that only needs something tappable to fill a list.
class TestRow extends StatelessWidget {
  const TestRow({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.contentPadding = const EdgeInsets.symmetric(horizontal: 16),
    this.minTileHeight = 56,
  });

  final Widget title;
  final Widget? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry contentPadding;
  final double minTileHeight;

  @override
  Widget build(BuildContext context) {
    return PressRegion(
      onTap: onTap,
      child: ListRow(
        leading: leading,
        title: title,
        subtitle: subtitle,
        trailing: trailing,
        padding: contentPadding,
        minHeight: minTileHeight,
      ),
    );
  }
}
