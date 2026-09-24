import 'dart:math';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/dashboard/widget_metrics.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';

const _rowGap = 8.0;
const _rowSpacing = 4.0;
const _pillInset = 8.0;
const _lineRowVerticalPadding = 8.0;

double _pillInsetOf(BuildContext context) {
  return min(_pillInset.mAp, DashboardWidgetMetrics.insetOf(context));
}

/// The shortest row that holds one line of body text.
double rowCardLineExtentOf(BuildContext context) {
  return globalState.measure.bodyMediumHeight *
          DashboardWidgetMetrics.textScaleOf(context) +
      _lineRowVerticalPadding.mAp * 2;
}

/// A two-line dashboard card whose rows, not the card, take the taps.
class RowCardFrame extends StatelessWidget {
  const RowCardFrame({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final shape = AppShape.all(DashboardWidgetMetrics.radiusOf(context));
    return SizedBox(
      height: DashboardWidgetMetrics.heightOf(context, 2),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: ShapeDecoration(
          color: colorScheme.surfaceContainerLow,
          shape: shape,
        ),
        // A border on the decoration would inset the content by its width.
        foregroundDecoration: ShapeDecoration(
          shape: shape.copyWith(
            side: BorderSide(color: colorScheme.surfaceContainerHighest),
          ),
        ),
        child: IconTheme.merge(
          data: const IconThemeData(size: commonCardIconSize),
          child: child,
        ),
      ),
    );
  }
}

class RowCardPane extends StatelessWidget {
  const RowCardPane({
    super.key,
    required this.header,
    required this.body,
    this.headerOverhang = 0,
  });

  final Widget header;
  final Widget body;
  final double headerOverhang;

  @override
  Widget build(BuildContext context) {
    final pillInset = _pillInsetOf(context);
    return Column(
      children: [
        header,
        Expanded(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              pillInset,
              _rowGap.mAp - headerOverhang,
              pillInset,
              pillInset,
            ),
            child: body,
          ),
        ),
      ],
    );
  }
}

/// Splits the body into as many rows of at least [rowExtent] as fit, up to
/// [maxSlots], and stretches them to fill it.
class RowCardSlots extends StatelessWidget {
  const RowCardSlots({
    super.key,
    this.rowExtent = 0,
    this.maxSlots,
    required this.builder,
  });

  final double rowExtent;
  final int? maxSlots;
  final Widget Function(int slots, double rowHeight, double spacing) builder;

  @override
  Widget build(BuildContext context) {
    final spacing = _rowSpacing.mAp;
    return LayoutBuilder(
      builder: (_, constraints) {
        final fit = max(
          ((constraints.maxHeight + spacing) / (rowExtent + spacing)).floor(),
          1,
        );
        final slots = min(fit, maxSlots ?? fit);
        final rowHeight = max(
          (constraints.maxHeight - spacing * (slots - 1)) / slots,
          0.0,
        );
        return builder(slots, rowHeight, spacing);
      },
    );
  }
}

class RowCardPill extends StatelessWidget {
  const RowCardPill({
    super.key,
    required this.onTap,
    this.color,
    this.edge,
    this.trailingGlyph = true,
    required this.child,
  });

  final VoidCallback onTap;
  final Color? color;

  /// Sits flush against the start edge, clipped by the pill's corners.
  final Widget? edge;

  /// A trailing glyph brings its own side bearing, so the end inset shrinks.
  final bool trailingGlyph;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final inset = DashboardWidgetMetrics.insetOf(context);
    final pillInset = _pillInsetOf(context);
    final contentInset = inset - pillInset;
    return LayoutBuilder(
      builder: (context, constraints) {
        final shape = AppShape.all(
          DashboardWidgetMetrics.innerRadiusOf(
            context,
            inset: pillInset,
            height: constraints.maxHeight,
          ),
        );
        return Material(
          color: color ?? context.colorScheme.surfaceContainer,
          shape: shape,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            customBorder: shape,
            onTap: onTap,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ?edge,
                Expanded(
                  child: Padding(
                    padding: EdgeInsetsDirectional.only(
                      start: contentInset,
                      end: trailingGlyph
                          ? max(contentInset - 4, 0)
                          : contentInset,
                    ),
                    child: child,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class RowCardEmpty extends StatelessWidget {
  const RowCardEmpty({
    super.key,
    required this.illustration,
    this.label,
    this.action,
  }) : assert((label == null) != (action == null));

  static const _maxArt = 72.0;
  static const _minArt = 32.0;

  final NullStatusIllustration illustration;
  final String? label;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final label = this.label;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: _rowGap.mAp,
        children: [
          Flexible(
            child: LayoutBuilder(
              builder: (_, constraints) {
                final dimension = min(
                  _maxArt,
                  min(constraints.maxWidth, constraints.maxHeight),
                );
                if (dimension < _minArt) {
                  return const SizedBox.shrink();
                }
                return EmptyIllustration(
                  type: illustration,
                  dimension: dimension,
                );
              },
            ),
          ),
          if (label != null)
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium?.toLight,
            ),
          ?action,
        ],
      ),
    );
  }
}

/// Clips to one line and, only when clipped, shows the full text on hover or
/// long press.
class OverflowTooltipText extends StatelessWidget {
  const OverflowTooltipText({super.key, required this.text, this.style});

  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final label = EmojiText(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: style,
    );
    return LayoutBuilder(
      builder: (_, constraints) {
        final isOverflow = globalState.measure.computeTextIsOverflow(
          Text(text, maxLines: 1, style: style),
          maxWidth: constraints.maxWidth,
        );
        if (!isOverflow) {
          return label;
        }
        return Tooltip(
          triggerMode: TooltipTriggerMode.longPress,
          preferBelow: false,
          message: text,
          child: label,
        );
      },
    );
  }
}
