import 'dart:math';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/state.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/rendering.dart';

class CommonChip extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final VoidCallback? onDeleted;

  const CommonChip({
    super.key,
    required this.label,
    this.onPressed,
    this.onDeleted,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final foregroundColor = colorScheme.onSurfaceVariant;
    final content = Padding(
      padding: EdgeInsets.only(
        left: 8,
        right: onDeleted != null ? 6 : 8,
        top: 3,
        bottom: 3,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 4,
        children: [
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.labelMedium?.copyWith(
                color: foregroundColor,
              ),
            ),
          ),
          if (onDeleted != null)
            InkWell(
              onTap: onDeleted,
              customBorder: AppShape.circle,
              focusColor: colorScheme.primary.opacity30,
              child: GlyphIcon(
                AppGlyphs.close,
                size: 14,
                color: foregroundColor,
              ),
            ),
        ],
      ),
    );
    return Material(
      color: colorScheme.surfaceContainerHighest,
      shape: AppShape.sm.copyWith(
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: onPressed == null
          ? content
          : InkWell(onTap: onPressed, child: content),
    );
  }
}

class TonalChip extends StatelessWidget {
  final String label;
  final Color color;
  final Color foregroundColor;
  final VoidCallback? onPressed;

  const TonalChip({
    super.key,
    required this.label,
    required this.color,
    required this.foregroundColor,
    this.onPressed,
  });

  static const _padding = EdgeInsets.symmetric(horizontal: 6, vertical: 1);

  static double widthOf(BuildContext context, String label) =>
      _labelWidth(context, label) + _padding.horizontal;

  @override
  Widget build(BuildContext context) {
    final style = context.textTheme.labelMedium!.copyWith(
      color: foregroundColor,
    );
    final content = Padding(
      padding: _padding,
      child: _CapCentered(
        fontSize: style.fontSize!,
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: style,
        ),
      ),
    );
    return Material(
      color: color,
      shape: AppShape.sm,
      clipBehavior: Clip.antiAlias,
      child: onPressed == null
          ? content
          : InkWell(onTap: onPressed, child: content),
    );
  }
}

/// A font's ascent outweighs its descent, so a centered line box sits low.
class _CapCentered extends SingleChildRenderObjectWidget {
  static const _capHeightPerEm = 0.7;

  final double fontSize;

  const _CapCentered({required this.fontSize, required super.child});

  double _capHeight(BuildContext context) =>
      MediaQuery.textScalerOf(context).scale(fontSize) * _capHeightPerEm;

  @override
  _RenderCapCentered createRenderObject(BuildContext context) =>
      _RenderCapCentered(_capHeight(context));

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderCapCentered renderObject,
  ) {
    renderObject.capHeight = _capHeight(context);
  }
}

class _RenderCapCentered extends RenderShiftedBox {
  _RenderCapCentered(this._capHeight) : super(null);

  double _capHeight;

  set capHeight(double value) {
    if (_capHeight == value) {
      return;
    }
    _capHeight = value;
    markNeedsLayout();
  }

  double _shift(Size size, double alphabeticBaseline) =>
      (size.height + _capHeight) / 2 - alphabeticBaseline;

  @override
  Size computeDryLayout(covariant BoxConstraints constraints) =>
      child?.getDryLayout(constraints) ?? constraints.smallest;

  @override
  double? computeDryBaseline(
    covariant BoxConstraints constraints,
    TextBaseline baseline,
  ) {
    final child = this.child;
    if (child == null) {
      return null;
    }
    final alphabetic = child.getDryBaseline(
      constraints,
      TextBaseline.alphabetic,
    );
    final result = child.getDryBaseline(constraints, baseline);
    if (alphabetic == null || result == null) {
      return null;
    }
    return result + _shift(child.getDryLayout(constraints), alphabetic);
  }

  @override
  void performLayout() {
    final child = this.child;
    if (child == null) {
      size = constraints.smallest;
      return;
    }
    child.layout(constraints, parentUsesSize: true);
    size = child.size;
    final baseline = child.getDistanceToBaseline(TextBaseline.alphabetic)!;
    (child.parentData! as BoxParentData).offset = Offset(
      0,
      _shift(size, baseline),
    );
  }
}

double _labelWidth(BuildContext context, String label) => globalState.measure
    .computeTextSize(Text(label, style: context.textTheme.labelMedium))
    .width;

class ExpireChip extends StatelessWidget {
  final DateTime expire;

  const ExpireChip({super.key, required this.expire});

  static const _padding = EdgeInsets.symmetric(horizontal: 8, vertical: 2);

  static double widthOf(BuildContext context, DateTime expire) =>
      _labelWidth(context, expire.show) + _padding.horizontal;

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
            style: context.textTheme.labelMedium?.copyWith(color: color),
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
    final titleWidth = globalState.measure
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
            color: colorScheme.secondaryContainer,
            foregroundColor: colorScheme.onSecondaryContainer,
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

class MetaChip extends StatelessWidget {
  final String label;

  const MetaChip({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return DecoratedBox(
      decoration: ShapeDecoration(
        color: colorScheme.surfaceContainerHighest,
        shape: AppShape.sm.copyWith(
          side: BorderSide(color: colorScheme.outlineVariant),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
