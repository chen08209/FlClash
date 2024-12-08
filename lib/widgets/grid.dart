import 'package:fl_clash/common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:math' as math;

typedef WrapBuilder = Widget Function(Widget child);

class Grid extends MultiChildRenderObjectWidget {
  final double mainAxisSpacing;

  final double crossAxisSpacing;

  final double? mainAxisExtent;

  final int crossAxisCount;

  final AxisDirection axisDirection;

  final TextDirection textDirection;

  const Grid({
    super.key,
    this.mainAxisSpacing = 0,
    this.crossAxisSpacing = 0,
    int? crossAxisCount,
    AxisDirection? axisDirection,
    TextDirection? textDirection,
    this.mainAxisExtent,
    List<Widget>? children,
  })  : crossAxisCount = crossAxisCount ?? 1,
        axisDirection = axisDirection ?? AxisDirection.down,
        textDirection = textDirection ?? TextDirection.ltr,
        super(children: children ?? const []);

  const Grid.baseGap({
    Key? key,
    double mainAxisSpacing = 8.0,
    double crossAxisSpacing = 8.0,
    int? crossAxisCount,
    AxisDirection? axisDirection,
    TextDirection? textDirection,
    double? mainAxisExtent,
    List<Widget>? children,
  }) : this(
          key: key,
          mainAxisSpacing: mainAxisSpacing,
          crossAxisSpacing: crossAxisSpacing,
          crossAxisCount: crossAxisCount,
          axisDirection: axisDirection,
          textDirection: textDirection,
          mainAxisExtent: mainAxisExtent,
          children: children,
        );

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderGrid(
      textDirection: textDirection,
      crossAxisCount: crossAxisCount,
      mainAxisSpacing: mainAxisSpacing,
      crossAxisSpacing: crossAxisSpacing,
      axisDirection: axisDirection,
      mainAxisExtent: mainAxisExtent,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderGrid renderObject,
  ) {
    renderObject
      ..mainAxisSpacing = mainAxisSpacing
      ..mainAxisExtent = mainAxisExtent
      ..crossAxisSpacing = crossAxisSpacing
      ..textDirection = textDirection
      ..axisDirection = axisDirection
      ..crossAxisCount = crossAxisCount;
  }
}

class RenderGrid extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, GridParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, GridParentData> {
  RenderGrid({
    required double mainAxisSpacing,
    required double crossAxisSpacing,
    required int crossAxisCount,
    required AxisDirection axisDirection,
    required TextDirection textDirection,
    double? mainAxisExtent,
  })  : _crossAxisCount = crossAxisCount,
        _crossAxisSpacing = crossAxisSpacing,
        _mainAxisSpacing = mainAxisSpacing,
        _axisDirection = axisDirection,
        _textDirection = textDirection,
        _mainAxisExtent = mainAxisExtent;

  int _crossAxisCount;

  int get crossAxisCount => _crossAxisCount;

  set crossAxisCount(int value) {
    if (_crossAxisCount != value) {
      _crossAxisCount = value;
      markNeedsLayout();
    }
  }

  double? _mainAxisExtent;

  double? get mainAxisExtent => _mainAxisExtent;

  set mainAxisExtent(double? value) {
    if (_mainAxisExtent != value) {
      _mainAxisExtent = value;
      markNeedsLayout();
    }
  }

  double _mainAxisSpacing;

  double get mainAxisSpacing => _mainAxisSpacing;

  set mainAxisSpacing(double value) {
    if (_mainAxisSpacing != value) {
      _mainAxisSpacing = value;
      markNeedsLayout();
    }
  }

  double _crossAxisSpacing;

  double get crossAxisSpacing => _crossAxisSpacing;

  set crossAxisSpacing(double value) {
    if (_crossAxisSpacing != value) {
      _crossAxisSpacing = value;
      markNeedsLayout();
    }
  }

  AxisDirection _axisDirection;

  AxisDirection get axisDirection => _axisDirection;

  set axisDirection(AxisDirection value) {
    if (_axisDirection != value) {
      _axisDirection = value;
      markNeedsLayout();
    }
  }

  TextDirection _textDirection;

  TextDirection get textDirection => _textDirection;

  set textDirection(TextDirection value) {
    if (_textDirection != value) {
      _textDirection = value;
      markNeedsLayout();
    }
  }

  Axis get mainAxis => axisDirectionToAxis(_axisDirection);

  @override
  void setupParentData(RenderObject child) {
    if (child.parentData is! GridParentData) {
      child.parentData = GridParentData();
    }
  }

  @override
  void performLayout() {
    final requestedSize = _computeSize(constraints: constraints);
    size = constraints.constrain(requestedSize);
    _hasOverflow = size != requestedSize;
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (_hasOverflow) {
      context.pushClipRect(
        needsCompositing,
        offset,
        Offset.zero & size,
        defaultPaint,
      );
    } else {
      defaultPaint(context, offset);
    }
  }

  GridParentData _getParentData(RenderBox child) {
    return child.parentData as GridParentData;
  }

  void _layoutChild(
    RenderBox child,
    BoxConstraints constraints, {
    bool parentUsesSize = false,
  }) {
    child.layout(constraints, parentUsesSize: parentUsesSize);
  }

  int _computeCrossAxisCellCount(
    GridParentData childParentData,
    int crossAxisCount,
  ) {
    return math.min(
      childParentData.crossAxisCellCount ?? 1,
      crossAxisCount,
    );
  }

  Size _computeSize({
    required BoxConstraints constraints,
  }) {
    final crossAxisExtent = mainAxis == Axis.vertical
        ? constraints.maxWidth
        : constraints.maxHeight;
    final stride = (crossAxisExtent + crossAxisSpacing) / crossAxisCount;
    final offsets = List.filled(crossAxisCount, 0.0);
    RenderBox? child = firstChild;
    while (child != null) {
      final childParentData = _getParentData(child);
      final crossAxisCellCount = _computeCrossAxisCellCount(
        childParentData,
        crossAxisCount,
      );
      final crossAxisExtent = stride * crossAxisCellCount - crossAxisSpacing;
      final shouldFitContent = childParentData.mainAxisCellCount == null;

      double mainAxisExtent = 0;

      if (shouldFitContent) {
        final childConstraints = mainAxis == Axis.vertical
            ? BoxConstraints.tightFor(width: crossAxisExtent)
            : BoxConstraints.tightFor(height: crossAxisExtent);
        _layoutChild(child, childConstraints, parentUsesSize: true);
        mainAxisExtent =
            mainAxis == Axis.vertical ? child.size.height : child.size.width;
      } else {
        final mainAxisCellCount = childParentData.mainAxisCellCount ?? 1;
        mainAxisExtent = (this.mainAxisExtent ?? stride) * mainAxisCellCount -
            mainAxisSpacing;
        childParentData.realMainAxisExtent = mainAxisExtent;
        final childSize = mainAxis == Axis.vertical
            ? Size(crossAxisExtent, mainAxisExtent)
            : Size(mainAxisExtent, crossAxisExtent);
        final childConstraints = BoxConstraints.tight(childSize);
        _layoutChild(child, childConstraints);
      }
      final origin = _getOrigin(offsets, crossAxisCellCount);
      final mainAxisOffset = origin.mainAxisOffset;
      final crossAxisOffset = origin.crossAxisIndex * stride;
      final offset = mainAxis == Axis.vertical
          ? Offset(crossAxisOffset, mainAxisOffset)
          : Offset(mainAxisOffset, crossAxisOffset);
      childParentData.offset = offset;

      final nextOffset = mainAxisOffset + mainAxisExtent + mainAxisSpacing;

      for (int i = 0; i < crossAxisCellCount; i++) {
        offsets[origin.crossAxisIndex + i] = nextOffset;
      }
      child = childAfter(child);
    }
    final mainAxisExtent = offsets.reduce(math.max) - mainAxisSpacing;

    if (axisDirectionIsReversed(axisDirection)) {
      child = firstChild;
      while (child != null) {
        final childParentData = _getParentData(child);
        final offset = childParentData.offset;
        final crossAxisOffset = offset.getCrossAxisOffset(mainAxis);
        final mainAxisOffset = mainAxisExtent -
            offset.getMainAxisOffset(mainAxis) -
            childParentData.realMainAxisExtent!;
        final newOffset = mainAxis == Axis.vertical
            ? Offset(crossAxisOffset, mainAxisOffset)
            : Offset(mainAxisOffset, crossAxisOffset);
        childParentData.offset = newOffset;
        child = childAfter(child);
      }
    }

    if (mainAxis == Axis.vertical && textDirection == TextDirection.rtl) {
      child = firstChild;
      while (child != null) {
        final childParentData = _getParentData(child);
        final crossAxisCellCount = crossAxisCount;
        final crossAxisCellExtent =
            stride * crossAxisCellCount - crossAxisSpacing;
        final offset = childParentData.offset;
        final crossAxisOffset =
            crossAxisExtent - offset.dx - crossAxisCellExtent;
        final mainAxisOffset = offset.dy;
        final newOffset = Offset(crossAxisOffset, mainAxisOffset);
        childParentData.offset = newOffset;
        child = childAfter(child);
      }
    }

    return mainAxis == Axis.vertical
        ? Size(crossAxisExtent, mainAxisExtent)
        : Size(mainAxisExtent, crossAxisExtent);
  }

  bool _hasOverflow = false;
}

class GridParentData extends ContainerBoxParentData<RenderBox> {
  int? crossAxisCellCount;
  num? mainAxisCellCount;
  double? realMainAxisExtent;

  @override
  String toString() =>
      'crossAxisCellCount=$crossAxisCellCount; mainAxisCellCount=$mainAxisCellCount;';
}

class GridItem extends ParentDataWidget<GridParentData> {
  final int crossAxisCellCount;
  final num? mainAxisCellCount;

  const GridItem({
    super.key,
    required super.child,
    this.mainAxisCellCount,
    this.crossAxisCellCount = 1,
  });

  @override
  void applyParentData(RenderObject renderObject) {
    final parentData = renderObject.parentData;
    if (parentData is GridParentData) {
      bool needsLayout = false;
      if (parentData.crossAxisCellCount != crossAxisCellCount) {
        parentData.crossAxisCellCount = crossAxisCellCount;
        needsLayout = true;
      }

      if (parentData.mainAxisCellCount != mainAxisCellCount) {
        parentData.mainAxisCellCount = mainAxisCellCount;
        needsLayout = true;
      }

      if (needsLayout) {
        final targetParent = renderObject.parent;
        if (targetParent is RenderGrid) {
          targetParent.markNeedsLayout();
        }
      }
    }
  }

  @override
  Type get debugTypicalAncestorWidgetClass => GridItem;

  GridItem wrap({
    required WrapBuilder builder,
  }) {
    return GridItem(
      mainAxisCellCount: mainAxisCellCount,
      crossAxisCellCount: crossAxisCellCount,
      child: builder(
        child,
      ),
    );
  }
}

class _Origin {
  final int crossAxisIndex;
  final double mainAxisOffset;

  const _Origin(this.crossAxisIndex, this.mainAxisOffset);
}

_Origin _getOrigin(List<double> offsets, int crossAxisCount) {
  final length = offsets.length;
  _Origin origin = const _Origin(0, double.infinity);
  for (int i = 0; i < length; i++) {
    final offset = offsets[i];
    if (offset.moreOrEqual(origin.mainAxisOffset)) {
      continue;
    }
    int start = 0;
    int span = 0;
    for (int j = 0;
        span < crossAxisCount &&
            j < length &&
            length - j >= crossAxisCount - span;
        j++) {
      if (offset.moreOrEqual(offsets[j])) {
        span++;
        if (span == crossAxisCount) {
          origin = _Origin(start, offset);
        }
      } else {
        start = j + 1;
        span = 0;
      }
    }
  }
  return origin;
}
