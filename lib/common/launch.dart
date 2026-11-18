import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:rust_api/rust_api.dart' as rust_api;

import 'constant.dart';
import 'system.dart';

abstract interface class AutostartEntry {
  Future<bool> isEnabled();

  Future<bool> setEnabled(bool enabled);
}

class _SystemAutostartEntry implements AutostartEntry {
  const _SystemAutostartEntry();

  @override
  Future<bool> isEnabled() => rust_api.isAutostartEnabled(
    id: sideBySideName,
    executable: Platform.resolvedExecutable,
  );

  @override
  Future<bool> setEnabled(bool enabled) => rust_api.setAutostart(
    id: sideBySideName,
    displayName: packageDisplayName,
    executable: Platform.resolvedExecutable,
    enabled: enabled,
  );
}

class AutoLaunch {
  static AutoLaunch? _instance;

  AutoLaunch._internal();

  factory AutoLaunch() {
    _instance ??= AutoLaunch._internal();
    return _instance!;
  }

  @visibleForTesting
  static AutostartEntry entry = const _SystemAutostartEntry();

  Future<bool> get isEnable => entry.isEnabled();

  Future<bool> enable() => entry.setEnabled(true);

  Future<bool> disable() => entry.setEnabled(false);

  Future<void> _update = Future.value();

  /// The bridge runs each call on its own worker, so an update waits for the
  /// write of the one before it rather than reading the entry around it.
  Future<void> updateStatus(bool isAutoLaunch) {
    if (kDebugMode) {
      return Future.value();
    }
    final update = _update.then((_) => _apply(isAutoLaunch));
    _update = update.then<void>((_) {}, onError: (Object _) {});
    return update;
  }

  Future<void> _apply(bool isAutoLaunch) async {
    if (await isEnable == isAutoLaunch) return;
    await entry.setEnabled(isAutoLaunch);
  }
}

final autoLaunch = system.isDesktop && !safeModeBuild ? AutoLaunch() : null;
