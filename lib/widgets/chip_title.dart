import 'dart:math';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/ui/ui.dart';
import 'package:material_ui/material_ui.dart';

class ExpireChip extends StatelessWidget {
  final DateTime expire;

  const ExpireChip({super.key, required this.expire});

  static const _padding = EdgeInsets.symmetric(horizontal: 8, vertical: 2);

  static double widthOf(BuildContext context, DateTime expire) =>
      chipLabelWidth(context, expire.show) + _padding.horizontal;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final color = expire.isBeforeNow ? colorScheme.error : colorScheme.primary;
    return Tooltip(
      message: context.appLocalizations.expireTime,
      child: DecoratedBox(
        decoration: ShapeDecoration(
          color: color.opacity15,
          shape: AppShape.full,
        ),
        child: Padding(
          padding: _padding,
          child: Text(
            expire.show,
            maxLines: 1,
            style: AppTextStyle.caption1
                .of(context, emphasized: true)
                .copyWith(color: color),
          ),
        ),
      ),
    );
  }
}

/// A title followed by an optional count chip and an expiry chip. The expiry
/// chip gives way before it would squeeze the title below half the row.
class ChipTitle extends StatelessWidget {
  final String title;
  final String? chip;
  final DateTime? expire;
  final TextStyle? style;

  const ChipTitle({
    super.key,
    required this.title,
    this.chip,
    this.expire,
    this.style,
  });

  static const _gap = 8.0;

  bool _fitsExpire(BuildContext context, double maxWidth, DateTime expire) {
    final chip = this.chip;
    final titleWidth = MeasureScope.of(context)
        .computeTextSize(
          Text(title, style: DefaultTextStyle.of(context).style.merge(style)),
        )
        .width;
    final chipsWidth =
        (chip == null ? 0 : TonalChip.widthOf(context, chip) + _gap) +
        ExpireChip.widthOf(context, expire) +
        _gap;
    return maxWidth - chipsWidth >= min(titleWidth, maxWidth / 2);
  }

  @override
  Widget build(BuildContext context) {
    final style = this.style;
    final chip = this.chip;
    final expire = this.expire;
    final text = Text(
      title,
      style: style,
      strutStyle: StrutStyle.fromTextStyle(
        DefaultTextStyle.of(context).style.merge(style),
        forceStrutHeight: true,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textWidthBasis: TextWidthBasis.longestLine,
    );
    if (chip == null && expire == null) {
      return text;
    }
    final colorScheme = context.colorScheme;
    Widget row({required bool showExpire}) => Row(
      spacing: _gap,
      children: [
        Flexible(child: text),
        if (chip != null)
          TonalChip(
            label: chip,
            color: context.raisedSurfaceLevel.colorOf(colorScheme),
            foregroundColor: colorScheme.onSurfaceVariant,
          ),
        if (showExpire && expire != null) ExpireChip(expire: expire),
      ],
    );
    if (expire == null) {
      return row(showExpire: false);
    }
    return LayoutBuilder(
      builder: (context, constraints) =>
          row(showExpire: _fitsExpire(context, constraints.maxWidth, expire)),
    );
  }
}
