import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/ui/ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// A titled group in a connection's detail. [compact] sets it a size
/// smaller, for a detail read beside a table.
class TrackerDetailSection extends StatelessWidget {
  final String title;
  final bool compact;
  final EdgeInsets padding;
  final String? footer;
  final Widget child;

  const TrackerDetailSection({
    super.key,
    required this.title,
    required this.compact,
    this.padding = EdgeInsets.zero,
    this.footer,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final secondary = context.colorScheme.onSurfaceVariant;
    final inset = EdgeInsets.symmetric(horizontal: compact ? 4 : 6);
    final footer = this.footer;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 6,
      children: [
        Padding(
          padding: inset,
          child: Semantics(
            header: true,
            child: Text(
              title,
              style: AppTextStyle.caption1
                  .of(context, emphasized: true)
                  .copyWith(color: secondary),
            ),
          ),
        ),
        Card(
          radius: compact ? AppCorner.md : AppCorner.xl,
          padding: padding,
          child: child,
        ),
        if (footer != null)
          Padding(
            padding: inset,
            child: Text(
              footer,
              style: AppTextStyle.caption1
                  .of(context)
                  .copyWith(color: secondary),
            ),
          ),
      ],
    );
  }
}

/// One hop of a connection's path, on a rail that runs to the next.
class TrackerPathStep extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? trailing;
  final Color? trailingColor;
  final bool last;
  final bool monospace;
  final bool compact;

  const TrackerPathStep({
    super.key,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.trailingColor,
    this.last = false,
    this.monospace = false,
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final secondary = colorScheme.onSurfaceVariant;
    final titleStyle = monospace
        ? (compact ? AppTextStyle.caption1 : AppTextStyle.footnote)
              .of(context)
              .toJetBrainsMono
        : (compact ? AppTextStyle.footnote : AppTextStyle.subheadline).of(
            context,
            emphasized: last,
          );
    final trailing = this.trailing;
    return CustomPaint(
      painter: _RailPainter(
        ring: colorScheme.outline,
        line: Divider.colorOf(context),
        end: last ? colorScheme.primary : null,
        diameter: compact ? 9 : 10,
        textDirection: Directionality.of(context),
      ),
      child: Padding(
        padding: EdgeInsetsDirectional.only(
          start: _RailPainter.width + 12,
          bottom: last ? 0 : (compact ? 10 : 12),
        ),
        child: Row(
          spacing: 8,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: titleStyle),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyle.caption1
                        .of(context)
                        .copyWith(color: secondary),
                  ),
                ],
              ),
            ),
            if (trailing != null)
              Text(
                trailing,
                style: (compact ? AppTextStyle.caption1 : AppTextStyle.footnote)
                    .of(context)
                    .toTabular
                    .copyWith(color: trailingColor ?? secondary),
              ),
          ],
        ),
      ),
    );
  }
}

class _RailPainter extends CustomPainter {
  static const width = 10.0;
  static const _top = 5.0;
  static const _stroke = 1.7;

  final Color ring;
  final Color line;

  /// Fills the point of the hop the path ends on.
  final Color? end;
  final double diameter;
  final TextDirection textDirection;

  const _RailPainter({
    required this.ring,
    required this.line,
    required this.end,
    required this.diameter,
    required this.textDirection,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final x = textDirection == TextDirection.rtl
        ? size.width - width / 2
        : width / 2;
    final center = Offset(x, _top + diameter / 2);
    final end = this.end;
    if (end != null) {
      canvas.drawCircle(center, diameter / 2, Paint()..color = end);
      return;
    }
    canvas.drawCircle(
      center,
      (diameter - _stroke) / 2,
      Paint()
        ..color = ring
        ..style = PaintingStyle.stroke
        ..strokeWidth = _stroke,
    );
    canvas.drawRect(
      Rect.fromLTRB(x - 0.75, _top + diameter + 3, x + 0.75, size.height),
      Paint()..color = line,
    );
  }

  @override
  bool shouldRepaint(_RailPainter oldDelegate) =>
      ring != oldDelegate.ring ||
      line != oldDelegate.line ||
      end != oldDelegate.end ||
      diameter != oldDelegate.diameter ||
      textDirection != oldDelegate.textDirection;
}

class TrackerTrafficColumn extends StatelessWidget {
  final String label;
  final Color mark;
  final int total;
  final int? speed;
  final bool compact;

  const TrackerTrafficColumn({
    super.key,
    required this.label,
    required this.mark,
    required this.total,
    required this.speed,
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    final secondary = context.colorScheme.onSurfaceVariant;
    final caption = AppTextStyle.caption1
        .of(context)
        .toTabular
        .copyWith(color: secondary);
    final speed = this.speed;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          spacing: 6,
          children: [
            DecoratedBox(
              decoration: ShapeDecoration(
                color: mark,
                shape: const CircleBorder(),
              ),
              child: const SizedBox.square(dimension: 6),
            ),
            Flexible(child: Text(label, style: caption)),
          ],
        ),
        Text(
          total.traffic.show,
          style: (compact ? AppTextStyle.subheadline : AppTextStyle.headline)
              .of(context, emphasized: true)
              .toTabular,
        ),
        if (speed != null) Text('${speed.traffic.show}/s', style: caption),
      ],
    );
  }
}

/// A labeled value in a connection's detail, copied on a press.
class TrackerDetailRow extends StatelessWidget {
  final String title;
  final String value;
  final bool monospace;
  final bool compact;

  const TrackerDetailRow({
    super.key,
    required this.title,
    required this.value,
    this.monospace = false,
    required this.compact,
  });

  Future<void> _copy(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: value));
    if (!context.mounted) return;
    dialogs.showBanner(context.appLocalizations.copySuccess);
  }

  @override
  Widget build(BuildContext context) {
    final text = compact ? AppTextStyle.footnote : AppTextStyle.subheadline;
    final valueStyle = monospace
        ? (compact ? AppTextStyle.caption1 : AppTextStyle.footnote)
              .of(context)
              .toJetBrainsMono
        : text.of(context);
    return PressSurface(
      fill: const Color(0x00000000),
      shape: AppShape.all(compact ? AppCorner.sm : AppCorner.md),
      minimum: BoxConstraints(minHeight: compact ? 32 : 44),
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 14 : 16,
        vertical: compact ? 7 : 10,
      ),
      onPressed: () => _copy(context),
      child: Row(
        spacing: 16,
        children: [
          Text(
            title,
            style: text
                .of(context)
                .copyWith(color: context.colorScheme.onSurfaceVariant),
          ),
          Expanded(
            child: Text(value, textAlign: TextAlign.end, style: valueStyle),
          ),
        ],
      ),
    );
  }
}
