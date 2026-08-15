import 'package:fl_clash/common/system.dart';
import 'package:flutter/material.dart';

class FloatLayout extends StatelessWidget {
  final Widget floatingWidget;
  final Widget child;
  final bool? isTV;

  const FloatLayout({
    super.key,
    required this.floatingWidget,
    this.isTV,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (isTV ?? system.isTV) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          floatingWidget,
          Expanded(child: Center(child: child)),
        ],
      );
    }
    return Stack(
      fit: StackFit.loose,
      children: [
        Center(child: child),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(child: floatingWidget),
        ),
      ],
    );
  }
}

class FloatWrapper extends StatelessWidget {
  final Widget child;

  const FloatWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(kFloatingActionButtonMargin),
      child: child,
    );
  }
}
