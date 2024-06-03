import 'package:flutter/material.dart';

class KeepContainer extends StatefulWidget {
  final Widget child;
  final bool keep;

  const KeepContainer({
    super.key,
    required this.child,
    this.keep = true,
  });

  @override
  State<KeepContainer> createState() => _KeepContainerState();
}

class _KeepContainerState extends State<KeepContainer>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }

  @override
  bool get wantKeepAlive => widget.keep;
}
