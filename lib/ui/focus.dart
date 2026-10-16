import 'dart:async';
import 'dart:math' as math;

import 'package:fl_clash/ui/context.dart';
import 'package:fl_clash/ui/metrics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

part 'focus_arrow_keys.dart';
part 'focus_keyboard.dart';
part 'focus_landing.dart';
part 'focus_moved_by_key.dart';
part 'focus_traversal.dart';

class PageFocusScope extends StatefulWidget {
  final Widget child;

  const PageFocusScope({super.key, required this.child});

  @override
  State<PageFocusScope> createState() => _PageFocusScopeState();
}

class _PageFocusScopeState extends State<PageFocusScope> {
  final FocusScopeNode _node = FocusScopeNode()
    ..traversalEdgeBehavior = TraversalEdgeBehavior.parentScope
    ..directionalTraversalEdgeBehavior = TraversalEdgeBehavior.parentScope;

  @override
  void dispose() {
    _node.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FocusScope.withExternalFocusNode(
      focusScopeNode: _node,
      child: widget.child,
    );
  }
}

final remoteSelectKeys = {
  LogicalKeyboardKey.select,
  LogicalKeyboardKey.enter,
  LogicalKeyboardKey.numpadEnter,
  LogicalKeyboardKey.gameButtonA,
};

class RemoteFocusAdapter extends StatefulWidget {
  final bool enabled;

  /// Whether a keyboard is up that covers the screen without insetting it.
  final ValueListenable<bool>? floatingKeyboard;
  final Widget child;

  const RemoteFocusAdapter({
    super.key,
    required this.enabled,
    this.floatingKeyboard,
    required this.child,
  });

  static bool isEnabledOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_RemoteScope>()?.enabled ??
      false;

  @override
  State<RemoteFocusAdapter> createState() => _RemoteFocusAdapterState();
}

class _RemoteFocusAdapterState extends State<RemoteFocusAdapter> {
  final _policy = _RemoteTraversalPolicy();

  @override
  void initState() {
    super.initState();
    FocusMovedByKey.instance._attach();
  }

  @override
  void dispose() {
    FocusMovedByKey.instance._detach();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _RemoteScope(
      enabled: widget.enabled,
      child: widget.enabled
          ? _RemoteFocusLanding(
              child: _RemoteArrowKeys(
                // Keys bubble outward; the keyboard must hear those arrows take.
                child: _RemoteKeyboard(
                  floatingKeyboard: widget.floatingKeyboard,
                  child: FocusTraversalGroup(
                    policy: _policy,
                    child: widget.child,
                  ),
                ),
              ),
            )
          : widget.child,
    );
  }
}

class _RemoteScope extends InheritedWidget {
  const _RemoteScope({required this.enabled, required super.child});

  final bool enabled;

  @override
  bool updateShouldNotify(_RemoteScope oldWidget) =>
      enabled != oldWidget.enabled;
}
