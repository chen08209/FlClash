import 'package:flutter/material.dart';

class ActivateBox extends StatelessWidget {
  final Widget child;
  final bool active;

  const ActivateBox({
    super.key,
    required this.child,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !active,
      child: child,
    );
  }
}
