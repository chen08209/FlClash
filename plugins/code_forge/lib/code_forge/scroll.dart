import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

/// A custom two-dimensional viewport for the code editor.
///
/// This viewport is used internally by [CodeForge] to enable both vertical
/// and horizontal scrolling within the editor. It delegates to a
/// [Render2DCodeField] for layout.
class CustomViewport extends TwoDimensionalViewport {
  final bool lineWrap;

  /// Creates a [CustomViewport] with the required scroll offsets and axes.
  const CustomViewport({
    super.key,
    required super.verticalOffset,
    required super.verticalAxisDirection,
    required super.horizontalOffset,
    required super.horizontalAxisDirection,
    required TwoDimensionalChildBuilderDelegate super.delegate,
    required super.mainAxis,
    required this.lineWrap,
  });

  @override
  RenderTwoDimensionalViewport createRenderObject(BuildContext context) {
    return Render2DCodeField(
      horizontalOffset: horizontalOffset,
      horizontalAxisDirection: horizontalAxisDirection,
      verticalOffset: verticalOffset,
      verticalAxisDirection: verticalAxisDirection,
      delegate: delegate,
      mainAxis: mainAxis,
      childManager: context as TwoDimensionalChildManager,
      lineWrap: lineWrap,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant RenderTwoDimensionalViewport renderObject,
  ) {
    (renderObject as Render2DCodeField).lineWrap = lineWrap;
    renderObject
      ..horizontalOffset = horizontalOffset
      ..horizontalAxisDirection = horizontalAxisDirection
      ..verticalOffset = verticalOffset
      ..verticalAxisDirection = verticalAxisDirection
      ..delegate = delegate
      ..mainAxis = mainAxis;
  }
}

/// The render object for the code editor's two-dimensional viewport.
///
/// This class handles the layout of the code editor content and manages
/// the content dimensions for both vertical and horizontal scrolling.
class Render2DCodeField extends RenderTwoDimensionalViewport {
  bool lineWrap;

  /// Creates a [Render2DCodeField] with the required scroll configuration.
  Render2DCodeField({
    required super.horizontalOffset,
    required super.horizontalAxisDirection,
    required super.verticalOffset,
    required super.verticalAxisDirection,
    required super.delegate,
    required super.mainAxis,
    required super.childManager,
    required this.lineWrap,
  });

  @override
  void layoutChildSequence() {
    final child = buildOrObtainChildFor(
      const ChildVicinity(xIndex: 0, yIndex: 0),
    );

    if (child != null) {
      child.layout(
        BoxConstraints(
          minHeight: viewportDimension.height,
          minWidth: viewportDimension.width,
          maxWidth: lineWrap ? viewportDimension.width : double.infinity,
          maxHeight: double.infinity,
        ),
        parentUsesSize: true,
      );
      parentDataOf(child).layoutOffset = Offset.zero;

      verticalOffset.applyContentDimensions(
        0.0,
        math.max(0.0, child.size.height - viewportDimension.height),
      );
      horizontalOffset.applyContentDimensions(
        0.0,
        math.max(0.0, child.size.width - viewportDimension.width),
      );
    }
  }
}
