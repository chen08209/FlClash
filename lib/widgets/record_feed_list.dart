import 'package:flutter/widgets.dart';
import 'package:prism_ui/prism_ui.dart';

/// A list of records that a feed keeps adding to and trims at its cap. Its rows
/// follow their keys and keep their stripes as the head is trimmed, so a refresh
/// builds only the rows it added, and it builds none ahead while it arrives.
class RecordFeedList<T> extends StatefulWidget {
  final List<T> items;
  final Key Function(T item) keyOf;

  /// [latest] reads the item's current version, for a row kept across versions.
  final Widget Function(T item, bool striped, ValueGetter<T> latest)
  itemBuilder;
  final ScrollController? controller;
  final ScrollPhysics? physics;
  final EdgeInsetsGeometry? padding;
  final bool reverse;
  final bool shrinkWrap;
  final double gap;
  final double estimatedItemExtent;

  const RecordFeedList({
    super.key,
    required this.items,
    required this.keyOf,
    required this.itemBuilder,
    required this.estimatedItemExtent,
    this.controller,
    this.physics,
    this.padding,
    this.reverse = false,
    this.shrinkWrap = false,
    this.gap = 0,
  });

  @override
  State<RecordFeedList<T>> createState() => _RecordFeedListState<T>();
}

class _RecordFeedListState<T> extends State<RecordFeedList<T>>
    with ArrivalCacheExtentMixin<RecordFeedList<T>> {
  Map<Key, int>? _indexes;
  var _built = <Key, int>{};
  var _builtBefore = const <Key, int>{};
  var _trimmed = 0;
  var _stripeShift = 0;

  /// Indexes the whole feed only for a change other than a trim at the head.
  int? _indexOf(Key key) {
    final items = widget.items;
    bool isAt(int? index) =>
        index != null &&
        index >= 0 &&
        index < items.length &&
        widget.keyOf(items[index]) == key;
    final built = _built[key];
    if (isAt(built)) {
      return built;
    }
    final before = _builtBefore[key];
    if (before != null) {
      final shifted = before - _trimmed;
      if (shifted < 0) {
        return null;
      }
      if (isAt(shifted)) {
        return shifted;
      }
    }
    return (_indexes ??= {
      for (final (index, item) in items.indexed) widget.keyOf(item): index,
    })[key];
  }

  @override
  void didUpdateWidget(RecordFeedList<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (identical(oldWidget.items, widget.items)) {
      return;
    }
    _indexes = null;
    _builtBefore = _built;
    _built = {};
    _trimmed = 0;
    final items = widget.items;
    if (items.isEmpty) {
      _stripeShift = 0;
      return;
    }
    final first = widget.keyOf(items.first);
    final trimmed = oldWidget.items.indexWhere(
      (item) => widget.keyOf(item) == first,
    );
    if (trimmed < 0) {
      _stripeShift = 0;
      return;
    }
    _trimmed = trimmed;
    _stripeShift += trimmed;
  }

  @override
  Widget build(BuildContext context) {
    return PrismListView(
      reverse: widget.reverse,
      shrinkWrap: widget.shrinkWrap,
      physics: widget.physics,
      controller: widget.controller,
      padding: widget.padding,
      scrollCacheExtent: arrivalCacheExtent,
      itemCount: widget.items.length,
      gap: widget.gap,
      estimatedItemExtent: widget.estimatedItemExtent,
      findChildIndexCallback: _indexOf,
      itemBuilder: (_, index) {
        final item = widget.items[index];
        final key = widget.keyOf(item);
        _built[key] = index;
        return KeyedSubtree(
          key: key,
          child: widget.itemBuilder(item, (index + _stripeShift).isOdd, () {
            final latest = _indexOf(key);
            return latest == null ? item : widget.items[latest];
          }),
        );
      },
    );
  }
}
