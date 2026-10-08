import 'dart:async';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:material_ui/material_ui.dart';

import 'inherited.dart';
import 'list.dart';

/// Each entry runs on a controller of its own, so a change made while another
/// entry still moves leaves that one running.
class EntryTransitions<K> {
  final TickerProvider vsync;

  /// Runs once [K] has collapsed, outside the frame that finished it, so the
  /// owner may drop the entry with setState even while being built.
  final ValueChanged<K> onLeft;

  final _controllers = <K, AnimationController>{};
  final _leaving = <K>{};
  final _positions = <K, ItemPosition>{};

  EntryTransitions({required this.vsync, required this.onLeft});

  Animation<double>? animationOf(K key) => _controllers[key];

  bool isLeaving(K key) => _leaving.contains(key);

  Iterable<K> get leaving => _leaving;

  /// Moves [entries] to [next], keeping the ones it drops while they leave.
  List<T> sync<T>(
    List<T> entries,
    List<T> next,
    K Function(T item) keyOf,
    Duration duration,
  ) {
    final keys = {for (final item in next) keyOf(item)};
    final shown = {
      for (final entry in entries)
        if (!isLeaving(keyOf(entry))) keyOf(entry),
    };
    for (final key in shown) {
      if (!keys.contains(key)) {
        leave(key, duration);
      }
    }
    for (final key in keys) {
      if (!shown.contains(key)) {
        enter(key, duration);
      }
    }
    return keepLeaving(entries, next, keyOf);
  }

  /// Places the staying [keys] in one run of rounded rows, ahead of
  /// [trailing] rows that close it; a leaving key keeps the place it had.
  void place(Iterable<K> keys, {int trailing = 0}) {
    final staying = keys.where((key) => !isLeaving(key)).toList();
    final count = staying.length + trailing;
    for (final (index, key) in staying.indexed) {
      _positions[key] = ItemPosition.get(index, count);
    }
  }

  ItemPosition positionOf(K key) => _positions[key] ?? ItemPosition.middle;

  void enter(K key, Duration duration) {
    _leaving.remove(key);
    (_controllers[key] ??= _create(key, 0))
      ..duration = duration
      ..forward();
  }

  void leave(K key, Duration duration) {
    if (!_leaving.add(key)) {
      return;
    }
    (_controllers[key] ??= _create(key, 1))
      ..duration = duration
      ..reverse();
  }

  AnimationController _create(K key, double value) {
    final controller = AnimationController(vsync: vsync, value: value);
    controller.addStatusListener((status) {
      if (!status.isDismissed || !_leaving.remove(key)) {
        return;
      }
      _controllers.remove(key);
      scheduleMicrotask(() {
        controller.dispose();
        _positions.remove(key);
        onLeft(key);
      });
    });
    return controller;
  }

  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    _controllers.clear();
  }
}

List<T> keepLeaving<T>(
  List<T> previous,
  List<T> next,
  Object? Function(T item) keyOf,
) {
  final keys = {for (final item in next) keyOf(item)};
  final before = <Object?, List<T>>{};
  var pending = <T>[];
  for (final item in previous) {
    final key = keyOf(item);
    if (!keys.contains(key)) {
      pending.add(item);
    } else if (pending.isNotEmpty) {
      before[key] = pending;
      pending = [];
    }
  }
  return [
    for (final item in next) ...[...?before[keyOf(item)], item],
    ...pending,
  ];
}

class EntryTransition extends StatelessWidget {
  static final _fade = CurveTween(curve: const Interval(0.5, 1));
  static final _size = CurveTween(curve: Curves.easeInOutCubic);

  final Animation<double>? animation;
  final bool leaving;
  final Widget child;

  const EntryTransition({
    super.key,
    required this.animation,
    this.leaving = false,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final animation = this.animation ?? kAlwaysCompleteAnimation;
    return IgnorePointer(
      ignoring: leaving,
      child: SizeTransition(
        sizeFactor: animation.drive(_size),
        alignment: Alignment.topCenter,
        child: FadeTransition(opacity: animation.drive(_fade), child: child),
      ),
    );
  }
}

/// With [grouped], a child collapsing out keeps its place in the run of
/// rounded rows while the others close up around it.
class AnimatedEntries extends StatefulWidget {
  final List<Widget> children;
  final bool grouped;

  const AnimatedEntries({
    super.key,
    required this.children,
    this.grouped = false,
  });

  @override
  State<AnimatedEntries> createState() => _AnimatedEntriesState();
}

class _AnimatedEntriesState extends State<AnimatedEntries>
    with TickerProviderStateMixin {
  late final _transitions = EntryTransitions<Key?>(
    vsync: this,
    onLeft: _handleLeft,
  );
  late var _entries = widget.children;

  @override
  void didUpdateWidget(covariant AnimatedEntries oldWidget) {
    super.didUpdateWidget(oldWidget);
    _entries = _transitions.sync(
      _entries,
      widget.children,
      (child) => child.key,
      context.motionDuration(commonDuration),
    );
  }

  @override
  void dispose() {
    _transitions.dispose();
    super.dispose();
  }

  void _handleLeft(Key? key) {
    if (!mounted || widget.children.any((child) => child.key == key)) {
      return;
    }
    setState(() {
      _entries = [
        for (final entry in _entries)
          if (entry.key != key) entry,
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.grouped) {
      _transitions.place(_entries.map((entry) => entry.key));
    }
    return Column(
      children: [
        for (final entry in _entries)
          EntryTransition(
            key: entry.key,
            animation: _transitions.animationOf(entry.key),
            leaving: _transitions.isLeaving(entry.key),
            child: widget.grouped
                ? ItemPositionProvider(
                    position: _transitions.positionOf(entry.key),
                    child: entry,
                  )
                : entry,
          ),
      ],
    );
  }
}

Widget generateAnimatedSection({
  String? title,
  required List<Widget> items,
  String? footer,
}) {
  return Column(
    children: [
      if (items.isNotEmpty && title != null) ListHeader(title: title),
      AnimatedEntries(grouped: true, children: items),
      if (items.isNotEmpty && footer != null) ListFooter(text: footer),
    ],
  );
}
