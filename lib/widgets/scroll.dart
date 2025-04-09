import 'package:collection/collection.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/common/list.dart';
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
  final Key cacheKey;

  const ScrollToEndBox({
    super.key,
    required this.child,
    required this.controller,
    required this.cacheKey,
    required this.dataSource,
  });

  @override
  State<ScrollToEndBox<T>> createState() => _ScrollToEndBoxState<T>();
}

class _ScrollToEndBoxState<T> extends State<ScrollToEndBox<T>> {
  final equals = ListEquality<T>();

  _handleTryToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final double offset =
          globalState.cacheScrollPosition[widget.cacheKey] ?? -1;
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
  void initState() {
    super.initState();
    globalState.cacheScrollPosition[widget.cacheKey] = -1;
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
    return NotificationListener<ScrollNotification>(
      onNotification: (details) {
        double offset =
            details.metrics.pixels == details.metrics.maxScrollExtent
                ? -1
                : details.metrics.pixels;
        globalState.cacheScrollPosition[widget.cacheKey] = offset;
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
  });

  @override
  State<CacheItemExtentListView> createState() =>
      CacheItemExtentListViewState();
}

class CacheItemExtentListViewState extends State<CacheItemExtentListView> {
  late final FixedMap<String, double> _cacheHeightMap;

  @override
  void initState() {
    super.initState();
    _cacheHeightMap = FixedMap(widget.itemCount);
  }

  clearCache() {
    _cacheHeightMap.clear();
  }

  @override
  Widget build(BuildContext context) {
    _cacheHeightMap.updateMaxSize(widget.itemCount);
    return ListView.builder(
      itemBuilder: widget.itemBuilder,
      itemCount: widget.itemCount,
      physics: widget.physics,
      reverse: widget.reverse,
      shrinkWrap: widget.shrinkWrap,
      controller: widget.controller,
      itemExtentBuilder: (index, __) {
        final key = widget.keyBuilder(index);
        if (_cacheHeightMap.containsKey(key)) {
          return _cacheHeightMap.get(key);
        }
        return _cacheHeightMap.put(key, widget.itemExtentBuilder(index));
      },
    );
  }

  @override
  void dispose() {
    _cacheHeightMap.clear();
    super.dispose();
  }
}

class CacheItemExtentSliverReorderableList extends StatefulWidget {
  final IndexedWidgetBuilder itemBuilder;
  final int itemCount;
  final String Function(int index) keyBuilder;
  final double Function(int index) itemExtentBuilder;
  final ReorderCallback onReorder;
  final ReorderItemProxyDecorator? proxyDecorator;

  const CacheItemExtentSliverReorderableList({
    super.key,
    required this.itemBuilder,
    required this.keyBuilder,
    required this.itemCount,
    required this.itemExtentBuilder,
    required this.onReorder,
    this.proxyDecorator,
  });

  @override
  State<CacheItemExtentSliverReorderableList> createState() =>
      CacheItemExtentSliverReorderableListState();
}

class CacheItemExtentSliverReorderableListState
    extends State<CacheItemExtentSliverReorderableList> {
  late final FixedMap<String, double> _cacheHeightMap;

  @override
  void initState() {
    super.initState();
    _cacheHeightMap = FixedMap(widget.itemCount);
  }

  clearCache() {
    _cacheHeightMap.clear();
  }

  @override
  Widget build(BuildContext context) {
    _cacheHeightMap.updateMaxSize(widget.itemCount);
    return SliverReorderableList(
      itemBuilder: widget.itemBuilder,
      itemCount: widget.itemCount,
      itemExtentBuilder: (index, __) {
        final key = widget.keyBuilder(index);
        if (_cacheHeightMap.containsKey(key)) {
          return _cacheHeightMap.get(key);
        }
        return _cacheHeightMap.put(key, widget.itemExtentBuilder(index));
      },
      onReorder: widget.onReorder,
      proxyDecorator: widget.proxyDecorator,
    );
  }

  @override
  void dispose() {
    _cacheHeightMap.clear();
    super.dispose();
  }
}
