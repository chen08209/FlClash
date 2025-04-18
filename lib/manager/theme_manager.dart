import 'dart:math';
import 'package:fl_clash/common/constant.dart';
import 'package:fl_clash/common/measure.dart';
import 'package:fl_clash/common/theme.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ThemeManager extends ConsumerWidget {
  final Widget child;

  const ThemeManager({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context, ref) {
    final textScale = ref.read(
      themeSettingProvider.select((state) => state.textScale),
    );
    final double textScaleFactor = max(
      min(
        textScale.enable ? textScale.scale : defaultTextScaleFactor,
        maxTextScale,
      ),
      minTextScale,
    );

    globalState.measure = Measure.of(context, textScaleFactor);
    globalState.theme = CommonTheme.of(context, textScaleFactor);
    final padding = MediaQuery.of(context).padding;
    final height = MediaQuery.of(context).size.height;
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: TextScaler.linear(
          textScaleFactor,
        ),
        padding: padding.copyWith(
          top: padding.top > height * 0.3 ? 0.0 : padding.top,
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
