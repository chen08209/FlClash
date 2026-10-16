import 'dart:math' as math;

import 'package:fl_clash/ui/context.dart';
import 'package:fl_clash/ui/icons/icons.dart';
import 'package:fl_clash/ui/item_position.dart';
import 'package:fl_clash/ui/shape.dart';
import 'package:fl_clash/ui/surface.dart';
import 'package:fl_clash/ui/typography.dart';
import 'package:material_ui/material_ui.dart';

import 'inherited.dart';

/// A titled section whose header folds its entries away. The entries unfold
/// with the section, and the ones nearest the middle of what fits on screen
/// fade in first.
class SliverCollapsibleSection extends StatefulWidget {
  final String label;
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final bool collapsible;
  final bool initiallyExpanded;

  const SliverCollapsibleSection({
    super.key,
    required this.label,
    required this.itemCount,
    required this.itemBuilder,
    this.collapsible = true,
    this.initiallyExpanded = true,
  });

  @override
  State<SliverCollapsibleSection> createState() =>
      _SliverCollapsibleSectionState();
}

class _SliverCollapsibleSectionState extends State<SliverCollapsibleSection>
    with SingleTickerProviderStateMixin {
  // Only orders the fade; a wrong guess shifts which entry leads it, not what
  // ends up shown.
  static const _estimatedEntryExtent = 64.0;

  late var _expanded = widget.initiallyExpanded;
  late final _controller = AnimationController(
    vsync: this,
    duration: UnfoldEntryTransition.duration,
    value: _isOpen(widget.collapsible) ? 1 : 0,
  );
  late final _size = UnfoldEntryTransition.curveOf(_controller);
  late final _turns = Tween<double>(begin: -0.25, end: 0).animate(_size);
  late final _headerActions = <Type, Action<Intent>>{
    ActivateIntent: CallbackAction<ActivateIntent>(
      onInvoke: (_) => _handleToggle(),
    ),
  };
  var _headerFocused = false;

  @override
  void initState() {
    super.initState();
    _controller.addStatusListener((_) => setState(() {}));
  }

  bool _isOpen(bool collapsible) => _expanded || !collapsible;

  void _animate() {
    _isOpen(widget.collapsible) ? _controller.forward() : _controller.reverse();
  }

  void _handleToggle() {
    setState(() {
      _expanded = !_expanded;
    });
    _animate();
  }

  @override
  void didUpdateWidget(SliverCollapsibleSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_isOpen(oldWidget.collapsible) != _isOpen(widget.collapsible)) {
      _animate();
    }
  }

  @override
  void dispose() {
    _size.dispose();
    _controller.dispose();
    super.dispose();
  }

  double _visibleCountOf(int count) {
    final fitting = MediaQuery.sizeOf(context).height / _estimatedEntryExtent;
    return math.min(count.toDouble(), fitting);
  }

  Widget _buildEntry(BuildContext context, int index) => ItemPositionProvider(
    position: ItemPosition.get(index, widget.itemCount),
    child: widget.itemBuilder(context, index),
  );

  Widget _buildHeader() {
    final colorScheme = context.colorScheme;
    final collapsible = widget.collapsible;
    final focused = collapsible && _headerFocused;
    return FocusableActionDetector(
      enabled: collapsible,
      actions: _headerActions,
      mouseCursor: collapsible ? SystemMouseCursors.click : MouseCursor.defer,
      onShowFocusHighlight: (value) => setState(() => _headerFocused = value),
      child: Semantics(
        button: collapsible,
        expanded: collapsible ? _expanded : null,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: collapsible ? _handleToggle : null,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 12, 8, 0),
            child: DecoratedBox(
              decoration: ShapeDecoration(
                shape: AppShape.md.copyWith(
                  side: focused ? focusRingSide(colorScheme) : BorderSide.none,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  spacing: 8,
                  children: [
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(text: widget.label),
                            TextSpan(
                              text: ' (${widget.itemCount})',
                              style: TextStyle(
                                color: colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyle.headline.of(context),
                      ),
                    ),
                    RotationTransition(
                      turns: _turns,
                      child: GlyphIcon(
                        AppGlyphs.chevronDown,
                        size: 20,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// An entry is at least [kMinInteractiveDimension] tall, so these fill the
  /// screen whatever lies past them.
  int _unfoldingCount(int count) {
    final fitting =
        MediaQuery.sizeOf(context).height ~/ kMinInteractiveDimension + 1;
    return math.min(count, fitting);
  }

  @override
  Widget build(BuildContext context) {
    final count = widget.itemCount;
    final visible = _visibleCountOf(count);
    final unfolding = _unfoldingCount(count);
    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(child: _buildHeader()),
        if (_controller.isCompleted)
          SliverList.builder(itemCount: count, itemBuilder: _buildEntry)
        else if (!_controller.isDismissed)
          SliverToBoxAdapter(
            child: SizeTransition(
              sizeFactor: _size,
              alignment: Alignment.topCenter,
              child: Column(
                children: [
                  for (var index = 0; index < unfolding; index++)
                    UnfoldEntryTransition(
                      animation: _size,
                      index: index,
                      visibleCount: visible,
                      child: _buildEntry(context, index),
                    ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// An entry unfolding from under its list's header; the entries nearest the
/// middle of the [visibleCount] that fit on screen fade in first.
class UnfoldEntryTransition extends StatelessWidget {
  static const duration = Duration(milliseconds: 240);
  static const _fade = 0.5;

  final Animation<double> animation;
  final int index;
  final double visibleCount;
  final Widget child;

  const UnfoldEntryTransition({
    super.key,
    required this.animation,
    required this.index,
    required this.visibleCount,
    required this.child,
  });

  static CurvedAnimation curveOf(AnimationController controller) =>
      CurvedAnimation(
        parent: controller,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );

  @override
  Widget build(BuildContext context) {
    final half = visibleCount / 2;
    final distance = (half - index - 0.5).abs() / half;
    final start = math.min(1.0, distance) * (1 - _fade);
    return SlideTransition(
      position: animation.drive(
        Tween(begin: Offset(0, -index - 0.5), end: Offset.zero),
      ),
      child: FadeTransition(
        opacity: animation.drive(
          CurveTween(curve: Interval(start, start + _fade)),
        ),
        child: child,
      ),
    );
  }
}
