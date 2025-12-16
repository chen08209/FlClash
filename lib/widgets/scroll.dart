import 'dart:async';

import 'package:collection/collection.dart';
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
