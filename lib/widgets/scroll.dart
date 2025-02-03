import 'package:flutter/material.dart';

class CommonScrollBar extends StatelessWidget {
  final ScrollController controller;
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
