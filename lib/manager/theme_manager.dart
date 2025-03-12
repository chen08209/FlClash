import 'package:fl_clash/common/constant.dart';
import 'package:fl_clash/common/measure.dart';
import 'package:fl_clash/common/theme.dart';
import 'package:fl_clash/state.dart';
import 'package:flutter/material.dart';

class ThemeManager extends StatelessWidget {
  final Widget child;

  const ThemeManager({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    globalState.measure = Measure.of(context);
    globalState.theme = CommonTheme.of(context);
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: TextScaler.linear(
          textScaleFactor,
        ),
      ),
      child: LayoutBuilder(
        builder: (_, container) {
          globalState.appController.updateViewSize(
            Size(
              container.maxWidth,
              container.maxHeight,
            ),
          );
          return child;
        },
      ),
    );
  }
}
