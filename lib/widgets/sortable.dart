import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/models/common.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import 'focus.dart';

/// The sort mode a [CommonScaffold] keeps for its body, or a section keeps
/// for its own rows.
class SortModeScope extends InheritedWidget {
  const SortModeScope({super.key, required this.sorting, required super.child});

  final bool sorting;

  static SortModeScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<SortModeScope>();

  @override
  bool updateShouldNotify(SortModeScope oldWidget) =>
      sorting != oldWidget.sorting;
}

typedef SortableItemData = ({int index, bool sorting});

/// While the [SortModeScope] above sorts, [DecorationListItem] and
/// [ContextMenuRegion] below give up their taps and menus, and the trailing
/// turns into a [SortHandle].
class SortableItem extends StatelessWidget {
  const SortableItem({super.key, required this.index, required this.child});

  final int index;
  final Widget child;

  static SortableItemData? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_SortableItemScope>()?.data;

  static bool isSorting(BuildContext context) =>
      maybeOf(context)?.sorting ?? false;

  @override
  Widget build(BuildContext context) {
    return _SortableItemScope(
      data: (
        index: index,
        sorting: SortModeScope.maybeOf(context)?.sorting ?? false,
      ),
      child: child,
    );
  }
}

class _SortableItemScope extends InheritedWidget {
  const _SortableItemScope({required this.data, required super.child});

  final SortableItemData data;

  @override
  bool updateShouldNotify(_SortableItemScope oldWidget) =>
      data != oldWidget.data;
}

/// Marks a row whose tap opens a page, sized like the handle that replaces it
/// in sort mode so the two share a center.
class DisclosureIndicator extends StatelessWidget {
  const DisclosureIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox.square(
      dimension: kMinInteractiveDimension,
      child: Center(child: GlyphIcon(AppGlyphs.chevronForward)),
    );
  }
}

/// The trailing button of a row whose tap does something else, held to the
/// [DisclosureIndicator]'s box since a desktop's compact density would shrink
/// a bare [IconButton] and pull its glyph off the column.
class DetailButton extends StatelessWidget {
  const DetailButton({
    super.key,
    required this.glyph,
    required this.tooltip,
    required this.onPressed,
  });

  final Glyph glyph;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: kMinInteractiveDimension,
      child: Center(
        child: IconButton(
          tooltip: tooltip,
          onPressed: onPressed,
          icon: GlyphIcon(glyph),
        ),
      ),
    );
  }
}

/// Drags on press; with focus, a select key lifts the row and the up and down
/// keys move it, so a remote or a keyboard can sort without a pointer.
class SortHandle extends StatefulWidget {
  const SortHandle({
    super.key,
    required this.index,
    this.dimension = kMinInteractiveDimension,
  });

  final int index;
  final double dimension;

  @override
  State<SortHandle> createState() => _SortHandleState();
}

class _SortHandleState extends State<SortHandle> {
  var _focused = false;
  var _lifted = false;

  @override
  void didUpdateWidget(SortHandle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.index == widget.index || !_focused) {
      return;
    }
    final policy = widget.index > oldWidget.index
        ? ScrollPositionAlignmentPolicy.keepVisibleAtEnd
        : ScrollPositionAlignmentPolicy.keepVisibleAtStart;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Scrollable.ensureVisible(
          context,
          alignmentPolicy: policy,
          duration: context.motionDuration(kThemeAnimationDuration),
        );
      }
    });
  }

  void _handleFocusChange(bool focused) {
    setState(() {
      _focused = focused;
      _lifted = _lifted && focused;
    });
  }

  KeyEventResult _handleKey(FocusNode _, KeyEvent event) {
    final key = event.logicalKey;
    if (remoteSelectKeys.contains(key) || key == LogicalKeyboardKey.space) {
      if (event is KeyDownEvent) {
        setState(() {
          _lifted = !_lifted;
        });
      }
      return KeyEventResult.handled;
    }
    if (!_lifted || event is KeyUpEvent) {
      return KeyEventResult.ignored;
    }
    if (key == LogicalKeyboardKey.escape) {
      setState(() {
        _lifted = false;
      });
      return KeyEventResult.handled;
    }
    final offset = switch (key) {
      LogicalKeyboardKey.arrowUp => -1,
      LogicalKeyboardKey.arrowDown => 1,
      LogicalKeyboardKey.arrowLeft || LogicalKeyboardKey.arrowRight => 0,
      _ => null,
    };
    if (offset == null) {
      return KeyEventResult.ignored;
    }
    final list = SliverReorderableList.maybeOf(context)?.widget;
    final target = widget.index + offset;
    if (offset != 0 && list != null && target >= 0 && target < list.itemCount) {
      list.onReorderItem?.call(widget.index, target);
    }
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final dimension = widget.dimension;
    return Semantics(
      button: true,
      label: context.appLocalizations.sort,
      child: Focus(
        onFocusChange: _handleFocusChange,
        onKeyEvent: _handleKey,
        child: MouseRegion(
          cursor: SystemMouseCursors.grab,
          child: ReorderableDragStartListener(
            index: widget.index,
            child: ColoredBox(
              color: Colors.transparent,
              child: SizedBox.square(
                dimension: dimension,
                child: Center(
                  child: AnimatedContainer(
                    duration: context.motionDuration(kThemeAnimationDuration),
                    width: dimension - 8,
                    height: dimension - 8,
                    decoration: ShapeDecoration(
                      shape: AppShape.circle,
                      color: _lifted
                          ? colorScheme.secondaryContainer
                          : _focused
                          ? colorScheme.onSurface.withValues(alpha: 0.12)
                          : colorScheme.secondaryContainer.withValues(alpha: 0),
                    ),
                    child: Center(
                      child: GlyphIcon(
                        AppGlyphs.dragHandle,
                        color: _lifted
                            ? colorScheme.onSecondaryContainer
                            : null,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

const _enterDuration = Duration(milliseconds: 650);
const _exitDuration = Duration(milliseconds: 420);
const _handleTravel = 1.0;

final _handleSpring = SpringCurve(
  SpringDescription.withDurationAndBounce(
    duration: const Duration(milliseconds: 350),
    bounce: 0.55,
  ),
  seconds: 0.65,
);

/// The handle springs in from the row's trailing edge, where the card clips
/// it, while the trailing it replaces shrinks away and the title gives up the
/// width; leaving, the handle slides back out before the trailing pops back.
/// Only a change of width relayouts the row: the motion itself is painted,
/// since a rebuild here would relayout the row from its [LayoutBuilder] and a
/// fade would put it on a layer of its own.
class SortableTrailing extends StatefulWidget {
  const SortableTrailing({super.key, required this.item, this.child});

  final SortableItemData item;
  final Widget? child;

  @override
  State<SortableTrailing> createState() => _SortableTrailingState();
}

class _SortableTrailingState extends State<SortableTrailing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    value: widget.item.sorting ? 1 : 0,
  )..addStatusListener(_handleStatus);

  @override
  void didUpdateWidget(SortableTrailing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.sorting == widget.item.sorting) {
      return;
    }
    final sorting = widget.item.sorting;
    _controller.animateTo(
      sorting ? 1 : 0,
      duration: context.motionDuration(
        sorting ? _enterDuration : _exitDuration,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleStatus(AnimationStatus status) {
    if (!status.isAnimating) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final sorting = widget.item.sorting;
    return RepaintBoundary(
      child: _SortableSlot(
        animation: _controller,
        sorting: sorting,
        children: [
          ExcludeSemantics(
            excluding: sorting,
            child: ExcludeFocus(
              excluding: sorting,
              child: widget.child ?? const SizedBox.shrink(),
            ),
          ),
          if (sorting || _controller.isAnimating)
            SortHandle(index: widget.item.index),
        ],
      ),
    );
  }
}

class _SortableSlot extends MultiChildRenderObjectWidget {
  const _SortableSlot({
    required this.animation,
    required this.sorting,
    super.children,
  });

  final Animation<double> animation;
  final bool sorting;

  @override
  _RenderSortableSlot createRenderObject(BuildContext context) =>
      _RenderSortableSlot(
        animation: animation,
        sorting: sorting,
        textDirection: Directionality.of(context),
      );

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderSortableSlot renderObject,
  ) {
    renderObject
      ..animation = animation
      ..sorting = sorting
      ..textDirection = Directionality.of(context);
  }
}

class _SlotParentData extends ContainerBoxParentData<RenderBox> {}

class _RenderSortableSlot extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _SlotParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _SlotParentData> {
  _RenderSortableSlot({
    required Animation<double> animation,
    required bool sorting,
    required TextDirection textDirection,
  }) : _animation = animation,
       _sorting = sorting,
       _textDirection = textDirection;

  Animation<double> _animation;
  bool _sorting;
  TextDirection _textDirection;
  double? _laidOutWidthProgress;
  final _trailingLayer = LayerHandle<TransformLayer>();
  final _handleLayer = LayerHandle<TransformLayer>();

  set animation(Animation<double> value) {
    if (identical(value, _animation)) {
      return;
    }
    if (attached) {
      _animation.removeListener(_handleTick);
      value.addListener(_handleTick);
    }
    _animation = value;
    markNeedsLayout();
  }

  set sorting(bool value) {
    if (value == _sorting) {
      return;
    }
    _sorting = value;
    markNeedsLayout();
  }

  set textDirection(TextDirection value) {
    if (value == _textDirection) {
      return;
    }
    _textDirection = value;
    markNeedsLayout();
  }

  RenderBox get _trailing => firstChild!;

  RenderBox? get _handle => childAfter(firstChild!);

  double get _widthProgress {
    final value = _animation.value;
    return _sorting
        ? const Interval(0, 0.5, curve: Curves.easeOutCubic).transform(value)
        : 1 -
              const Interval(
                0.2,
                0.8,
                curve: Curves.easeInOutCubic,
              ).transform(1 - value);
  }

  double get _handleProgress {
    final value = _animation.value;
    return _sorting
        ? _handleSpring.transform(value)
        : const Interval(0.55, 1, curve: Curves.easeOut).transform(value);
  }

  double get _trailingScale {
    final value = _animation.value;
    return _sorting
        ? 1 - const Interval(0, 0.2, curve: Curves.easeIn).transform(value)
        : const Interval(
            0.4,
            1,
            curve: Curves.easeOutBack,
          ).transform(1 - value);
  }

  void _handleTick() {
    final resizing =
        _laidOutWidthProgress != null &&
        _laidOutWidthProgress != _widthProgress;
    if (resizing) {
      markNeedsLayout();
    } else {
      markNeedsPaint();
    }
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _SlotParentData) {
      child.parentData = _SlotParentData();
    }
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _animation.addListener(_handleTick);
  }

  @override
  void detach() {
    _animation.removeListener(_handleTick);
    super.detach();
  }

  @override
  void dispose() {
    _trailingLayer.layer = null;
    _handleLayer.layer = null;
    super.dispose();
  }

  double _lerpWidth(double trailing, double? handle) =>
      handle == null ? trailing : lerpDouble(trailing, handle, _widthProgress)!;

  @override
  double computeMinIntrinsicWidth(double height) => _lerpWidth(
    _trailing.getMinIntrinsicWidth(height),
    _handle?.getMinIntrinsicWidth(height),
  );

  @override
  double computeMaxIntrinsicWidth(double height) => _lerpWidth(
    _trailing.getMaxIntrinsicWidth(height),
    _handle?.getMaxIntrinsicWidth(height),
  );

  @override
  double computeMinIntrinsicHeight(double width) => math.max(
    _trailing.getMinIntrinsicHeight(width),
    _handle?.getMinIntrinsicHeight(width) ?? 0,
  );

  @override
  double computeMaxIntrinsicHeight(double width) => math.max(
    _trailing.getMaxIntrinsicHeight(width),
    _handle?.getMaxIntrinsicHeight(width) ?? 0,
  );

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    final loose = constraints.loosen();
    final trailing = _trailing.getDryLayout(loose);
    final handle = _handle?.getDryLayout(loose);
    return constraints.constrain(
      Size(
        _lerpWidth(trailing.width, handle?.width),
        math.max(trailing.height, handle?.height ?? 0),
      ),
    );
  }

  @override
  void performLayout() {
    final loose = constraints.loosen();
    final trailing = _trailing..layout(loose, parentUsesSize: true);
    final handle = _handle?..layout(loose, parentUsesSize: true);
    final resizes = handle != null && handle.size.width != trailing.size.width;
    _laidOutWidthProgress = resizes ? _widthProgress : null;
    size = constraints.constrain(
      Size(
        _lerpWidth(trailing.size.width, handle?.size.width),
        math.max(trailing.size.height, handle?.size.height ?? 0),
      ),
    );
    for (final child in [trailing, ?handle]) {
      (child.parentData! as _SlotParentData).offset = Offset(
        _textDirection == TextDirection.rtl ? 0 : size.width - child.size.width,
        (size.height - child.size.height) / 2,
      );
    }
  }

  Matrix4 _transformOf(RenderBox child) {
    final offset = (child.parentData! as _SlotParentData).offset;
    if (child != _trailing) {
      final direction = _textDirection == TextDirection.rtl ? -1 : 1;
      return Matrix4.translationValues(
        offset.dx +
            direction *
                _handleTravel *
                (1 - _handleProgress) *
                child.size.width,
        offset.dy,
        0,
      );
    }
    final scale = _trailingScale;
    return Matrix4.diagonal3Values(scale, scale, 1)..setTranslationRaw(
      offset.dx + child.size.width / 2 * (1 - scale),
      offset.dy + child.size.height / 2 * (1 - scale),
      0,
    );
  }

  TransformLayer? _paintChild(
    PaintingContext context,
    Offset offset,
    RenderBox child,
    TransformLayer? oldLayer,
  ) => context.pushTransform(
    needsCompositing,
    offset,
    _transformOf(child),
    (context, offset) => context.paintChild(child, offset),
    oldLayer: oldLayer,
  );

  @override
  void paint(PaintingContext context, Offset offset) {
    _trailingLayer.layer = _trailingScale <= 0
        ? null
        : _paintChild(context, offset, _trailing, _trailingLayer.layer);
    final handle = _handle;
    _handleLayer.layer = handle == null
        ? null
        : _paintChild(context, offset, handle, _handleLayer.layer);
  }

  bool _hitTestChild(
    BoxHitTestResult result,
    Offset position,
    RenderBox child,
  ) => result.addWithPaintTransform(
    transform: _transformOf(child),
    position: position,
    hitTest: (result, position) => child.hitTest(result, position: position),
  );

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    final handle = _handle;
    if (handle != null && _hitTestChild(result, position, handle)) {
      return true;
    }
    return !_sorting &&
        _trailingScale > 0 &&
        _hitTestChild(result, position, _trailing);
  }

  @override
  void applyPaintTransform(RenderBox child, Matrix4 transform) {
    transform.multiply(_transformOf(child));
  }
}

IconButtonData sortModeAction(
  BuildContext context, {
  required bool sorting,
  required VoidCallback? onPressed,
}) {
  final appLocalizations = context.appLocalizations;
  return IconButtonData(
    glyph: AppGlyphs.sort,
    onPressed: onPressed,
    tooltip: appLocalizations.sort,
    isSelected: sorting,
  );
}
