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

// class ProxiesActionsBuilder extends StatelessWidget {
//   final Widget? child;
//   final Widget Function(
//     ProxiesActionsState state,
//     Widget? child,
//   ) builder;
//
//   const ProxiesActionsBuilder({
//     super.key,
//     required this.child,
//     required this.builder,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Selector<AppState, ProxiesActionsState>(
//       selector: (_, appState) => ProxiesActionsState(
//         isCurrent: appState.currentLabel == "proxies",
//         hasProvider: appState.providers.isNotEmpty,
//       ),
//       builder: (_, state, child) => builder(state, child),
//       child: child,
//     );
//   }
// }

// class ActiveBuilder extends StatelessWidget {
//   final String label;
//   final StateAndChildWidgetBuilder<bool> builder;
//   final Widget? child;
//
//   const ActiveBuilder({
//     super.key,
//     required this.label,
//     required this.builder,
//     required this.child,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Selector<AppState, bool>(
//       selector: (_, appState) => appState.currentLabel == label,
//       builder: (_, state, child) {
//         return builder(
//           state,
//           child,
//         );
//       },
//       child: child,
//     );
//   }
// }

typedef StateWidgetBuilder<T> = Widget Function(T state);

typedef StateAndChildWidgetBuilder<T> = Widget Function(T state, Widget? child);
