import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class CommonSafeArea extends StatelessWidget {
  const CommonSafeArea({
    super.key,
    this.left = true,
    this.top = true,
    this.right = true,
    this.bottom = true,
    this.minimum = EdgeInsets.zero,
    this.maintainBottomViewPadding = false,
    required this.child,
  });

  final bool left;

  final bool top;

  final bool right;

  final bool bottom;

  final EdgeInsets minimum;

  final bool maintainBottomViewPadding;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMediaQuery(context));
    EdgeInsets padding = MediaQuery.paddingOf(context);
    final height = MediaQuery.of(context).size.height;
    if (maintainBottomViewPadding) {
      padding = padding.copyWith(
        bottom: MediaQuery.viewPaddingOf(context).bottom,
      );
    }
    final double realPaddingTop = padding.top > height * 0.5 ? 0 : padding.top;
    return Padding(
      padding: EdgeInsets.only(
        left: math.max(left ? padding.left : 0.0, minimum.left),
        top: math.max(top ? realPaddingTop : 0.0, minimum.top),
        right: math.max(right ? padding.right : 0.0, minimum.right),
        bottom: math.max(bottom ? padding.bottom : 0.0, minimum.bottom),
      ),
      child: MediaQuery.removePadding(
        context: context,
        removeLeft: left,
        removeTop: top,
        removeRight: right,
        removeBottom: bottom,
        child: child,
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
        .add(FlagProperty('left', value: left, ifTrue: 'avoid left padding'));
    properties
        .add(FlagProperty('top', value: top, ifTrue: 'avoid top padding'));
    properties.add(
        FlagProperty('right', value: right, ifTrue: 'avoid right padding'));
    properties.add(
        FlagProperty('bottom', value: bottom, ifTrue: 'avoid bottom padding'));
  }
}
