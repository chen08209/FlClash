import 'package:flutter/material.dart';

class FloatLayout extends StatelessWidget {
  final Widget floatingWidget;

  final Widget child;

  const FloatLayout({
    super.key,
    required this.floatingWidget,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.loose,
      children: [
        Center(
          child: child,
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            child: floatingWidget,
          ),
        ),
      ],
    );
  }
}

class FloatWrapper extends StatelessWidget {
  final Widget child;

  const FloatWrapper({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(kFloatingActionButtonMargin),
      child: child,
    );
  }
}
