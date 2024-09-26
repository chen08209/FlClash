import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/state.dart';
import 'package:flutter/material.dart';

class MediaManager extends StatelessWidget {
  final Widget child;

  const MediaManager({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    globalState.measure = Measure.of(context);
    return child;
  }
}
