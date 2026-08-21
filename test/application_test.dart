import 'package:fl_clash/application.dart';
import 'package:fl_clash/manager/hotkey_manager.dart';
import 'package:fl_clash/manager/manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _leaf = SizedBox.shrink();

Widget? _childOf(Widget widget) {
  return switch (widget) {
    AppEnvManager(:final child) => child,
    StatusManager(:final child) => child,
    ThemeManager(:final child) => child,
    WindowManager(:final child) => child,
    TrayManager(:final child) => child,
    HotKeyManager(:final child) => child,
    ProxyManager(:final child) => child,
    AndroidManager(:final child) => child,
    TileManager(:final child) => child,
    AppStateManager(:final child) => child,
    CoreManager(:final child) => child,
    ConnectivityManager(:final child) => child,
    WindowHeaderContainer(:final child) => child,
    VpnManager(:final child) => child,
    _ => null,
  };
}

List<Type> _chainFrom(Widget root) {
  final types = <Type>[];
  Widget? current = root;
  while (current != null && current is! SizedBox) {
    types.add(current.runtimeType);
    current = _childOf(current);
  }
  return types;
}

Widget? _innermostChildOf(Widget root) {
  Widget? current = root;
  Widget? previous;
  while (current != null && current is! SizedBox) {
    previous = current;
    current = _childOf(current);
  }
  return current ?? previous;
}

Widget _stack({required bool isDesktop}) {
  return buildManagerStack(
    isDesktop: isDesktop,
    onConnectivityChanged: (_) async {},
    child: _leaf,
  );
}

void main() {
  test('the desktop manager stack nests in ownership order', () {
    expect(_chainFrom(_stack(isDesktop: true)), [
      AppEnvManager,
      StatusManager,
      ThemeManager,
      WindowManager,
      TrayManager,
      HotKeyManager,
      ProxyManager,
      AppStateManager,
      CoreManager,
      ConnectivityManager,
      WindowHeaderContainer,
    ]);
  });

  test('the mobile manager stack nests in ownership order', () {
    expect(_chainFrom(_stack(isDesktop: false)), [
      AppEnvManager,
      StatusManager,
      ThemeManager,
      AndroidManager,
      TileManager,
      AppStateManager,
      CoreManager,
      ConnectivityManager,
      VpnManager,
    ]);
  });

  test('desktop-only managers never appear on mobile', () {
    final mobile = _chainFrom(_stack(isDesktop: false));

    expect(
      mobile,
      isNot(
        anyOf(
          contains(WindowManager),
          contains(TrayManager),
          contains(HotKeyManager),
          contains(ProxyManager),
          contains(WindowHeaderContainer),
        ),
      ),
    );
  });

  test('mobile-only managers never appear on desktop', () {
    final desktop = _chainFrom(_stack(isDesktop: true));

    expect(
      desktop,
      isNot(
        anyOf(
          contains(AndroidManager),
          contains(TileManager),
          contains(VpnManager),
        ),
      ),
    );
  });

  test('Core is mounted before the connectivity callback can fire', () {
    for (final isDesktop in [true, false]) {
      final chain = _chainFrom(_stack(isDesktop: isDesktop));

      expect(
        chain.indexOf(CoreManager),
        lessThan(chain.indexOf(ConnectivityManager)),
        reason: 'connectivity changes read Core-backed state',
      );
    }
  });

  test('the app content stays the innermost child', () {
    for (final isDesktop in [true, false]) {
      expect(
        _innermostChildOf(_stack(isDesktop: isDesktop)),
        same(_leaf),
        reason: 'every manager must wrap the app content, not replace it',
      );
    }
  });
}
