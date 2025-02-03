import 'package:flutter/material.dart';
import 'context.dart';

mixin ViewMixin<T extends StatefulWidget> on State<T> {
  List<Widget> get actions => [];

  Widget? get floatingActionButton => null;

  initViewState() {
    final commonScaffoldState = context.commonScaffoldState;
    commonScaffoldState?.actions = actions;
    commonScaffoldState?.floatingActionButton = floatingActionButton;
    commonScaffoldState?.onSearch = onSearch;
    commonScaffoldState?.onKeywordsUpdate = onKeywordsUpdate;
  }

  Function(String)? get onSearch => null;

  Function(List<String>)? get onKeywordsUpdate => null;
}
