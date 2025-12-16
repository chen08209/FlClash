import 'package:fl_clash/widgets/inherited.dart';
import 'package:flutter/material.dart';

class ScrollOverBuilder extends StatefulWidget {
  final Widget Function(bool isOver) builder;

  const ScrollOverBuilder({super.key, required this.builder});

  @override
  State<ScrollOverBuilder> createState() => _ScrollOverBuilderState();
}

class _ScrollOverBuilderState extends State<ScrollOverBuilder> {
  final isOverNotifier = ValueNotifier<bool>(false);

  @override
  void dispose() {
    isOverNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollMetricsNotification>(
      onNotification: (scrollNotification) {
        isOverNotifier.value = scrollNotification.metrics.maxScrollExtent > 0;
        return true;
      },
      child: ValueListenableBuilder<bool>(
        valueListenable: isOverNotifier,
        builder: (_, isOver, _) {
          return widget.builder(isOver);
        },
      ),
    );
  }
}

class FloatingActionButtonExtendedBuilder extends StatelessWidget {
  final Widget Function(bool isExtend) builder;

  const FloatingActionButtonExtendedBuilder({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    final isExtended =
        CommonScaffoldFabExtendedProvider.of(context)?.isExtended ?? true;
    return builder(isExtended);
  }
}

typedef StateWidgetBuilder<T> = Widget Function(T state);

typedef StateAndChildWidgetBuilder<T> = Widget Function(T state, Widget? child);
