import 'dart:async';

import 'package:collection/collection.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/state.dart';
import 'package:flutter/material.dart';

class CommonScrollBar extends StatelessWidget {
  final ScrollController? controller;
  final Widget child;
  final bool trackVisibility;
  final bool thumbVisibility;

  const CommonScrollBar({
    super.key,
    required this.child,
    required this.controller,
    this.trackVisibility = false,
    this.thumbVisibility = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      controller: controller,
      thumbVisibility: thumbVisibility,
      trackVisibility: trackVisibility,
      thickness: 6,
      radius: const Radius.circular(6),
      interactive: true,
      child: child,
    );
  }
}

class ScrollToEndBox<T> extends StatefulWidget {
  final ScrollController controller;
  final List<T> dataSource;
  final Widget child;
  final bool enable;
  final VoidCallback? onCancelToEnd;

  const ScrollToEndBox({
    super.key,
    required this.child,
    required this.controller,
    required this.dataSource,
    this.onCancelToEnd,
    this.enable = true,
  });

  @override
  State<ScrollToEndBox<T>> createState() => _ScrollToEndBoxState<T>();
}

class _ScrollToEndBoxState<T> extends State<ScrollToEndBox<T>> {
  final equals = ListEquality<T>();
  bool _isFastToEnd = false;

  @override
  void initState() {
    super.initState();
  }

  Future<bool> _handleTryToEnd() {
    final completer = Completer<bool>();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (mounted &&
          widget.controller.hasClients &&
          widget.controller.position.pixels !=
              widget.controller.position.maxScrollExtent) {
        await widget.controller.animateTo(
          duration: kThemeAnimationDuration,
          widget.controller.position.maxScrollExtent,
          curve: Curves.easeOut,
        );
      }
      completer.complete(true);
    });
    return completer.future;
  }

  @override
  void didUpdateWidget(ScrollToEndBox<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.enable == true && oldWidget.enable != true) {
      _handleFastToEnd();
      return;
    }
    if (widget.enable &&
        !equals.equals(oldWidget.dataSource, widget.dataSource)) {
      _handleTryToEnd();
    }
  }

  Future<void> _handleFastToEnd() async {
    _isFastToEnd = true;
    await _handleTryToEnd();
    _isFastToEnd = false;
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<UserScrollNotification>(
      onNotification: (details) {
        if (_isFastToEnd) {
          return false;
        }
        if (widget.onCancelToEnd != null) {
          widget.onCancelToEnd!();
        }
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

  void _updateCacheHeightMap() {
    globalState.computeHeightMapCache[widget.tag]?.updateMaxLength(
      widget.itemCount,
    );
    globalState.computeHeightMapCache[widget.tag] ??= FixedMap(
      widget.itemCount,
    );
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
      itemExtentBuilder: (index, _) {
        _updateCacheHeightMap();
        return globalState.computeHeightMapCache[widget.tag]?.updateCacheValue(
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
    globalState.computeHeightMapCache[widget.tag]?.updateMaxLength(
      widget.itemCount,
    );
    globalState.computeHeightMapCache[widget.tag] ??= FixedMap(
      widget.itemCount,
    );
  }

  @override
  Widget build(BuildContext context) {
    globalState.computeHeightMapCache[widget.tag]?.updateMaxLength(
      widget.itemCount,
    );
    return SliverReorderableList(
      itemBuilder: widget.itemBuilder,
      itemCount: widget.itemCount,
      itemExtentBuilder: (index, _) {
        return globalState.computeHeightMapCache[widget.tag]?.updateCacheValue(
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
