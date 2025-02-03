import 'package:fl_clash/manager/manager.dart';
import 'package:fl_clash/widgets/scaffold.dart';
import 'package:flutter/material.dart';

extension BuildContextExtension on BuildContext {
  CommonScaffoldState? get commonScaffoldState {
    return findAncestorStateOfType<CommonScaffoldState>();
  }

  showNotifier(String text) {
    return findAncestorStateOfType<MessageManagerState>()?.message(text);
  }

  Size get appSize {
    return MediaQuery.of(this).size;
  }

  double get viewWidth {
    return appSize.width;
  }

  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  TextTheme get textTheme => Theme.of(this).textTheme;

  T? findLastStateOfType<T extends State>() {
    T? state;

    visitor(Element element) {
      if(!element.mounted){
        return;
      }
      if(element is StatefulElement){
        if (element.state is T) {
          state = element.state as T;
        }
      }
      element.visitChildren(visitor);
    }

    visitor(this as Element);
    return state;
  }
}
