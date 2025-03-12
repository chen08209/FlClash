import 'package:fl_clash/models/models.dart';
import 'package:flutter/material.dart';
import 'package:riverpod/riverpod.dart';
import 'context.dart';

mixin AutoDisposeNotifierMixin<T> on AutoDisposeNotifier<T> {
  set value(T value) {
    state = value;
  }

  @override
  bool updateShouldNotify(previous, next) {
    final res = super.updateShouldNotify(previous, next);
    if (res) {
      onUpdate(next);
    }
    return res;
  }

  onUpdate(T value) {}
}

mixin PageMixin<T extends StatefulWidget> on State<T> {
  void onPageShow() {
    initPageState();
  }

  initPageState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final commonScaffoldState = context.commonScaffoldState;
      commonScaffoldState?.actions = actions;
      commonScaffoldState?.floatingActionButton = floatingActionButton;
      commonScaffoldState?.onKeywordsUpdate = onKeywordsUpdate;
      commonScaffoldState?.updateSearchState(
        (_) => onSearch != null
            ? AppBarSearchState(
                onSearch: onSearch!,
              )
            : null,
      );
    });
  }

  void onPageHidden() {}

  List<Widget> get actions => [];

  Widget? get floatingActionButton => null;

  Function(String)? get onSearch => null;

  Function(List<String>)? get onKeywordsUpdate => null;
}
