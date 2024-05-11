import 'package:flutter/material.dart';

import '../state.dart';

class TooltipText extends StatelessWidget {
  final Text text;

  const TooltipText({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, container) {
        final maxWidth = container.maxWidth;
        final size = globalState.appController.measure.computeTextSize(
          text,
        );
        if (maxWidth < size.width) {
          return Tooltip(
            preferBelow: false,
            message: text.data,
            child: text,
          );
        }
        return text;
      },
    );
  }
}
