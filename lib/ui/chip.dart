import 'package:fl_clash/ui/button.dart';
import 'package:fl_clash/ui/card.dart';
import 'package:fl_clash/ui/context.dart';
import 'package:fl_clash/ui/icons/icons.dart';
import 'package:fl_clash/ui/measure.dart';
import 'package:fl_clash/ui/shape.dart';
import 'package:fl_clash/ui/surface.dart';
import 'package:fl_clash/ui/typography.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/rendering.dart';

class CommonChip extends StatelessWidget {
  final String label;
  final VoidCallback? onDeleted;

  const CommonChip({super.key, required this.label, this.onDeleted});

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final deletable = onDeleted != null;
    return SizedBox(
      height: TonalButtonSize.section.button,
      child: CommonCard(
        shape: AppShape.full,
        inert: !deletable,
        padding: EdgeInsets.only(left: 16, right: deletable ? 12 : 16),
        onPressed: onDeleted,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 6,
          children: [
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyle.subheadline
                    .of(context, emphasized: true)
                    .copyWith(color: colorScheme.onSurface),
              ),
            ),
            if (deletable)
              GlyphIcon(
                AppGlyphs.close,
                size: 16,
                color: colorScheme.onSurfaceVariant,
              ),
          ],
        ),
      ),
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
      chipLabelWidth(context, label) + _padding.horizontal;

  @override
  Widget build(BuildContext context) {
    final style = AppTextStyle.caption1
        .of(context, emphasized: true)
        .copyWith(color: foregroundColor);
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

double chipLabelWidth(BuildContext context, String label) =>
    MeasureScope.of(context)
        .computeTextSize(
          Text(
            label,
            style: AppTextStyle.caption1.of(context, emphasized: true),
          ),
        )
        .width;

class MetaChip extends StatelessWidget {
  final String label;

  const MetaChip({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return DecoratedBox(
      decoration: ShapeDecoration(
        color: context.raisedSurfaceLevel.colorOf(colorScheme),
        shape: AppShape.sm,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyle.caption2
              .of(context, emphasized: true)
              .copyWith(color: colorScheme.onSurfaceVariant),
        ),
      ),
    );
  }
}
