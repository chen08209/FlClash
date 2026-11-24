import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/models/models.dart';
import 'package:flutter/widgets.dart';
import 'package:fl_clash/ui/icons/icons.dart';
import 'package:fl_clash/widgets/widgets.dart';

/// A rule as a profile writes it, type and payload on one line.
String trackerRuleLine(AppLocalizations appLocalizations, TrackerInfo info) {
  if (info.rule.isEmpty) {
    return trackerRuleText(appLocalizations, info);
  }
  return info.rulePayload.isEmpty
      ? info.rule
      : '${info.rule},${info.rulePayload}';
}

enum RailMark { step, end, error }

/// A row of a connection's path or timeline, its point on a rail that runs
/// on through the rows above and below it, level with the title.
class TrackerRailRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Widget> labels;
  final Widget? trailing;
  final RailMark mark;
  final bool first;
  final bool last;
  final VoidCallback? onPressed;

  const TrackerRailRow({
    super.key,
    required this.title,
    this.subtitle = '',
    this.labels = const [],
    this.trailing,
    this.mark = RailMark.step,
    this.first = false,
    this.last = false,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final subtitleStyle = context.listSubtitleStyle;
    final trailing = this.trailing;
    final insets = context.listInsets;
    final opens = onPressed != null;
    return CustomPaint(
      foregroundPainter: _RailPainter(
        x: insets.leading + listLeadingSlotWidth / 2,
        subtitleLine:
            (subtitle.isEmpty
                ? 0
                : MediaQuery.textScalerOf(
                        context,
                      ).scale(subtitleStyle.fontSize!) *
                      subtitleStyle.height!) +
            (labels.isEmpty ? 0 : recordLabelLineGap),
        ring: colorScheme.outline,
        line: Divider.colorOf(context),
        fill: switch (mark) {
          RailMark.step => null,
          RailMark.end => colorScheme.primary,
          RailMark.error => colorScheme.error,
        },
        above: !first,
        below: !last,
        textDirection: Directionality.of(context),
      ),
      child: DecorationListItem(
        separated: false,
        onPressed: onPressed,
        contentPadding: opens ? ListItem.chevronPaddingOf(context) : null,
        leading: const SizedBox(width: listLeadingSlotWidth),
        title: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: mark == RailMark.end ? AppTextStyle.emphasis : null,
        ),
        subtitle: subtitle.isEmpty && labels.isEmpty
            ? null
            : DefaultTextStyle.merge(
                style: subtitleStyle.toTabular,
                child: RecordLabelLine(
                  text: subtitle,
                  labels: labels,
                  underTitle: true,
                ),
              ),
        trailing: trailing == null && !opens
            ? null
            : DefaultTextStyle.merge(
                style: subtitleStyle.toTabular,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 4,
                  children: [
                    ?trailing,
                    if (opens) const GlyphIcon(Glyphs.chevronForward),
                  ],
                ),
              ),
      ),
    );
  }
}

class _RailPainter extends CustomPainter {
  static const _radius = 5.0;
  static const _stroke = 1.7;
  static const _rail = 1.5;
  static const _gap = 3.0;

  final double x;

  /// A row centers its text, so the title's line centers above this.
  final double subtitleLine;
  final Color ring;
  final Color line;
  final Color? fill;
  final bool above;
  final bool below;
  final TextDirection textDirection;

  const _RailPainter({
    required this.x,
    required this.subtitleLine,
    required this.ring,
    required this.line,
    required this.fill,
    required this.above,
    required this.below,
    required this.textDirection,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final dx = textDirection == TextDirection.rtl ? size.width - x : x;
    final dy = (size.height - subtitleLine) / 2;
    final center = Offset(dx, dy);
    final fill = this.fill;
    if (fill != null) {
      canvas.drawCircle(center, _radius, Paint()..color = fill);
    } else {
      canvas.drawCircle(
        center,
        _radius - _stroke / 2,
        Paint()
          ..color = ring
          ..style = PaintingStyle.stroke
          ..strokeWidth = _stroke,
      );
    }
    final paint = Paint()..color = line;
    if (above) {
      canvas.drawRect(
        Rect.fromLTRB(dx - _rail / 2, 0, dx + _rail / 2, dy - _radius - _gap),
        paint,
      );
    }
    if (below) {
      canvas.drawRect(
        Rect.fromLTRB(
          dx - _rail / 2,
          dy + _radius + _gap,
          dx + _rail / 2,
          size.height,
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_RailPainter oldDelegate) =>
      x != oldDelegate.x ||
      subtitleLine != oldDelegate.subtitleLine ||
      ring != oldDelegate.ring ||
      line != oldDelegate.line ||
      fill != oldDelegate.fill ||
      above != oldDelegate.above ||
      below != oldDelegate.below ||
      textDirection != oldDelegate.textDirection;
}

/// A connection's download and upload, each on a card of its own with its
/// speed while open.
class TrackerTrafficSummary extends StatelessWidget {
  final TrackerInfo trackerInfo;

  const TrackerTrafficSummary({super.key, required this.trackerInfo});

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final active = trackerInfo.isActive;
    return Row(
      spacing: 8,
      children: [
        Expanded(
          child: _TrafficCell(
            glyph: AppGlyphs.arrowDown,
            label: appLocalizations.download,
            bytes: trackerInfo.download,
            speed: active ? trackerInfo.downloadSpeed ?? 0 : null,
          ),
        ),
        Expanded(
          child: _TrafficCell(
            glyph: AppGlyphs.arrowUp,
            label: appLocalizations.upload,
            bytes: trackerInfo.upload,
            speed: active ? trackerInfo.uploadSpeed ?? 0 : null,
          ),
        ),
      ],
    );
  }
}

class _TrafficCell extends StatelessWidget {
  final Glyph glyph;
  final String label;
  final int bytes;
  final int? speed;

  const _TrafficCell({
    required this.glyph,
    required this.label,
    required this.bytes,
    required this.speed,
  });

  @override
  Widget build(BuildContext context) {
    final speed = this.speed;
    return FigureCard(
      glyph: glyph,
      label: label,
      figure: bytes.traffic.show,
      below: [
        if (speed != null)
          Text(
            '${speed.traffic.show}/s',
            maxLines: 1,
            style: context.listCaptionStyle.toTabular,
          ),
      ],
    );
  }
}
