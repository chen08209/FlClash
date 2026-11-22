import 'dart:async';

import 'package:rust_api/tray.dart';

class FakeTrayHost implements TrayHost {
  final List<TrayContent> shown = [];
  final List<String> titles = [];
  int hideCount = 0;
  int openMenuCount = 0;
  String? showFailure;

  final StreamController<TraySignal> _signals =
      StreamController<TraySignal>.broadcast(sync: true);

  TrayContent? get lastShown => shown.isEmpty ? null : shown.last;

  int get callCount => shown.length + titles.length + hideCount + openMenuCount;

  void clear() {
    shown.clear();
    titles.clear();
    hideCount = 0;
    openMenuCount = 0;
  }

  void emit(TraySignalKind kind, [int itemId = 0]) {
    _signals.add(TraySignal(kind: kind, itemId: itemId));
  }

  @override
  Stream<TraySignal> signals() => _signals.stream;

  @override
  void show(TrayContent content) {
    shown.add(content);
    if (showFailure case final reason?) {
      throw TrayException(reason);
    }
  }

  @override
  bool setTitle(String title) {
    titles.add(title);
    return true;
  }

  @override
  void hide() {
    hideCount++;
  }

  @override
  bool openMenu() {
    openMenuCount++;
    return true;
  }
}
