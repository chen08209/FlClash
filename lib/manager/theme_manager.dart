import 'dart:math';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/common/theme.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/state.dart';

class ThemeManager extends ConsumerWidget {
  final Widget child;

  const ThemeManager({super.key, required this.child});

  Widget _buildSystemUi(Widget child) {
    if (!system.isAndroid) {
      return child;
    }
    return AnnotatedRegion<SystemUiMode>(
      sized: false,
      value: SystemUiMode.edgeToEdge,
      child: Consumer(
        builder: (context, ref, _) {
          final brightness = ref.watch(currentBrightnessProvider);
          final iconBrightness = brightness == Brightness.light
              ? Brightness.dark
              : Brightness.light;
          globalState.appState = globalState.appState.copyWith(
            systemUiOverlayStyle: SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: iconBrightness,
              systemNavigationBarIconBrightness: iconBrightness,
              systemNavigationBarColor: context.colorScheme.surface,
              systemNavigationBarDividerColor: Colors.transparent,
            ),
          );
          return AnnotatedRegion<SystemUiOverlayStyle>(
            value: globalState.appState.systemUiOverlayStyle,
            sized: false,
            child: child,
          );
        },
      ),
    );
  }

  // _buildScrollbar(Widget child) {
  //   return Consumer(
  //     builder: (_, ref, child) {
  //       final isMobileView = ref.read(isMobileViewProvider);
  //       if (isMobileView) {
  //         return ScrollConfiguration(
  //           behavior: HiddenBarScrollBehavior(),
  //           child: child!,
  //         );
  //       }
  //       return child!;
  //     },
  //     child: child,
  //   );
  // }

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
        textScaler: TextScaler.linear(textScaleFactor),
        padding: padding.copyWith(
          top: padding.top > height * 0.3 ? 20.0 : padding.top,
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          floatingActionButtonTheme: Theme.of(context).floatingActionButtonTheme
              .copyWith(
                shape: const RoundedSuperellipseBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16.0)),
                ),
              ),
        ),
        child: LayoutBuilder(
          builder: (_, container) {
            globalState.appController.updateViewSize(
              Size(container.maxWidth, container.maxHeight),
            );
            return _buildSystemUi(child);
          },
        ),
      ),
    );
  }
}
