import 'package:flutter/material.dart';

class DisabledMask extends StatefulWidget {
  final Widget child;
  final bool status;

  const DisabledMask({
    super.key,
    required this.child,
    this.status = true,
  });

  @override
  State<DisabledMask> createState() => _DisabledMaskState();
}

class _DisabledMaskState extends State<DisabledMask> {
  GlobalKey childKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final child = Container(
      key: childKey,
      child: widget.child,
    );
    if (!widget.status) {
      return child;
    }
    return ColorFiltered(
      colorFilter: const ColorFilter.matrix(<double>[
        0.2126,
        0.7152,
        0.0722,
        0,
        30,
        0.2126,
        0.7152,
        0.0722,
        0,
        30,
        0.2126,
        0.7152,
        0.0722,
        0,
        30,
        0,
        0,
        0,
        1,
        0,
      ]),
      child: child,
    );
  }
}
