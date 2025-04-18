import 'package:collection/collection.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/state.dart';
import 'package:flutter/material.dart';

class CommonScrollBar extends StatelessWidget {
  final ScrollController? controller;
  final Widget child;

  const CommonScrollBar({
    super.key,
    required this.child,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      controller: controller,
      thumbVisibility: true,
      trackVisibility: true,
      thickness: 8,
      radius: const Radius.circular(8),
      interactive: true,
      child: child,
    );
  }
}

class CommonAutoHiddenScrollBar extends StatelessWidget {
  final ScrollController? controller;
  final Widget child;

  const CommonAutoHiddenScrollBar({
    super.key,
    required this.child,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      controller: controller,
      thickness: 8,
      radius: const Radius.circular(8),
      interactive: true,
      child: child,
    );
  }
}

class ScrollToEndBox<T> extends StatefulWidget {
  final ScrollController controller;
  final List<T> dataSource;
  final Widget child;
  final CacheTag tag;

  const ScrollToEndBox({
    super.key,
    required this.child,
    required this.controller,
    required this.tag,
    required this.dataSource,
  });

  @override
  State<ScrollToEndBox<T>> createState() => _ScrollToEndBoxState<T>();
}

class _ScrollToEndBoxState<T> extends State<ScrollToEndBox<T>> {
  final equals = ListEquality<T>();

  _handleTryToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final double offset = globalState.cacheScrollPosition[widget.tag] ?? -1;
      if (offset < 0) {
        widget.controller.animateTo(
          duration: kThemeAnimationDuration,
          widget.controller.position.maxScrollExtent,
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void didUpdateWidget(ScrollToEndBox<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!equals.equals(oldWidget.dataSource, widget.dataSource)) {
      _handleTryToEnd();
    }
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<UserScrollNotification>(
      onNotification: (details) {
        globalState.cacheScrollPosition[widget.tag] =
            details.metrics.pixels == details.metrics.maxScrollExtent
                ? -1
                : details.metrics.pixels;
        return false;
      },
      child: widget.child,
    );
  }
}

class CacheItemExtentListView extends StatefulWidget {
  final NullableIndexedWidgetBuilder itemBuilder;
  final int itemCount;
  final String Function(int index) keyBuilder;
  final double Function(int index) itemExtentBuilder;
  final ScrollPhysics? physics;
  final bool shrinkWrap;
  final bool reverse;
  final ScrollController controller;
  final CacheTag tag;

  const CacheItemExtentListView({
    super.key,
    this.physics,
    this.reverse = false,
    this.shrinkWrap = false,
    required this.itemBuilder,
    required this.controller,
    required this.keyBuilder,
    required this.itemCount,
    required this.itemExtentBuilder,
    required this.tag,
  });

  @override
  State<CacheItemExtentListView> createState() =>
      CacheItemExtentListViewState();
}

class CacheItemExtentListViewState extends State<CacheItemExtentListView> {
  @override
  void initState() {
    super.initState();
    _updateCacheHeightMap();
  }

  _updateCacheHeightMap() {
    globalState.cacheHeightMap[widget.tag]?.updateMaxLength(widget.itemCount);
    globalState.cacheHeightMap[widget.tag] ??= FixedMap(widget.itemCount);
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemBuilder: widget.itemBuilder,
      itemCount: widget.itemCount,
      physics: widget.physics,
      reverse: widget.reverse,
      shrinkWrap: widget.shrinkWrap,
      controller: widget.controller,
      itemExtentBuilder: (index, __) {
        _updateCacheHeightMap();
        return globalState.cacheHeightMap[widget.tag]?.updateCacheValue(
          widget.keyBuilder(index),
          () => widget.itemExtentBuilder(index),
        );
      },
    );
  }
}

class CacheItemExtentSliverReorderableList extends StatefulWidget {
  final IndexedWidgetBuilder itemBuilder;
  final int itemCount;
  final String Function(int index) keyBuilder;
  final double Function(int index) itemExtentBuilder;
  final ReorderCallback onReorder;
  final ReorderItemProxyDecorator? proxyDecorator;
  final CacheTag tag;

  const CacheItemExtentSliverReorderableList({
    super.key,
    required this.itemBuilder,
    required this.keyBuilder,
    required this.itemCount,
    required this.itemExtentBuilder,
    required this.onReorder,
    this.proxyDecorator,
    required this.tag,
  });

  @override
  State<CacheItemExtentSliverReorderableList> createState() =>
      CacheItemExtentSliverReorderableListState();
}

class CacheItemExtentSliverReorderableListState
    extends State<CacheItemExtentSliverReorderableList> {
  @override
  void initState() {
    super.initState();
    globalState.cacheHeightMap[widget.tag]?.updateMaxLength(widget.itemCount);
    globalState.cacheHeightMap[widget.tag] ??= FixedMap(widget.itemCount);
  }

  @override
  Widget build(BuildContext context) {
    globalState.cacheHeightMap[widget.tag]?.updateMaxLength(widget.itemCount);
    return SliverReorderableList(
      itemBuilder: widget.itemBuilder,
      itemCount: widget.itemCount,
      itemExtentBuilder: (index, __) {
        return globalState.cacheHeightMap[widget.tag]?.updateCacheValue(
          widget.keyBuilder(index),
          () => widget.itemExtentBuilder(index),
        );
      },
      onReorder: widget.onReorder,
      proxyDecorator: widget.proxyDecorator,
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
