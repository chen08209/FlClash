import 'package:fl_clash/application.dart';
import 'package:fl_clash/controller.dart';
import 'package:fl_clash/widgets/scaffold.dart';
import 'package:flutter/material.dart';

extension BuildContextExtension on BuildContext {
  AppController get appController {
    final appController =
        findAncestorStateOfType<ApplicationState>()?.appController;
    assert(appController != null, "only use application environment");
    return appController!;
  }

  CommonScaffoldState? get commonScaffoldState {
    return findAncestorStateOfType<CommonScaffoldState>();
  }

  double get width {
    return MediaQuery.of(this).size.width;
  }

  bool get isMobile => width < 600;

  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  TextTheme get textTheme => Theme.of(this).textTheme;
}
