import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as path;

import '../rust/api/tray.dart';
import 'tray_capabilities.dart';
import 'tray_codec.dart';
import 'tray_event.dart';
import 'tray_menu.dart';
import 'tray_spec.dart';

final class TrayException implements Exception {
  const TrayException(this.reason);

  final String reason;

  @override
  String toString() => 'TrayException: $reason';
}

abstract interface class TrayHost {
  Stream<TraySignal> signals();

  /// Throws [TrayException] when the status item could not be shown.
  void show(TrayContent content);

  bool setTitle(String title);

  void hide();

  bool openMenu();
}

final class _RustTrayHost implements TrayHost {
  const _RustTrayHost();

  @override
  Stream<TraySignal> signals() => traySignals();

  @override
  void show(TrayContent content) {
    try {
      showTray(content: content);
    } on String catch (reason) {
      throw TrayException(reason);
    }
  }

  @override
  bool setTitle(String title) => setTrayTitle(title: title);

  @override
  void hide() => hideTray();

  @override
  bool openMenu() => openTrayMenu();
}

final class Tray {
  Tray._();

  static final Tray instance = Tray._();

  final StreamController<TrayEvent> _events =
      StreamController<TrayEvent>.broadcast();

  TrayHost _host = const _RustTrayHost();
  StreamSubscription<TraySignal>? _signals;
  Map<int, TrayMenuItem> _itemsById = const {};
  Future<void> _queue = Future<void>.value();
  String? _signature;
  String _title = '';
  String _requestedTitle = '';
  bool _isVisible = false;

  Stream<TrayEvent> get events {
    _listen();
    return _events.stream;
  }

  TrayCapabilities get capabilities =>
      TrayCapabilities.of(defaultTargetPlatform);

  bool get isVisible => _isVisible;

  Future<void> show(TraySpec spec) {
    return _serialize(() => _show(spec));
  }

  Future<void> setTitle(String title) {
    _requestedTitle = title;
    return _serialize(() async => _setTitle(_requestedTitle));
  }

  Future<void> hide() {
    return _serialize(() async => _hide());
  }

  Future<void> openMenu() {
    return _serialize(() async => _openMenu());
  }

  @visibleForTesting
  void resetForTesting(TrayHost host) {
    _signals?.cancel();
    _signals = null;
    _host = host;
    _itemsById = const {};
    _queue = Future<void>.value();
    _signature = null;
    _title = '';
    _requestedTitle = '';
    _isVisible = false;
  }

  Future<T> _serialize<T>(Future<T> Function() action) {
    final completer = Completer<T>();
    _queue = _queue.then((_) async {
      try {
        completer.complete(await action());
      } catch (error, stackTrace) {
        completer.completeError(error, stackTrace);
      }
    });
    return completer.future;
  }

  Future<void> _show(TraySpec spec) async {
    if (!capabilities.supported) {
      return;
    }
    final encoded = TrayCodec.encode(spec);
    if (_isVisible && encoded.signature == _signature) {
      _itemsById = encoded.itemsById;
      return;
    }
    _listen();
    final image = await _resolveImage(spec.icon);
    try {
      _host.show(
        TrayContent(
          id: _stableId,
          image: image,
          toolTip: spec.toolTip,
          title: _title,
          menu: encoded.menu,
        ),
      );
    } on Object {
      _signature = null;
      rethrow;
    }
    _itemsById = encoded.itemsById;
    _signature = encoded.signature;
    _isVisible = true;
  }

  void _setTitle(String title) {
    if (!capabilities.title) {
      return;
    }
    final isUnchanged = _title == title;
    _title = title;
    if (isUnchanged || !_isVisible) {
      return;
    }
    _host.setTitle(title);
  }

  void _hide() {
    _itemsById = const {};
    _signature = null;
    _title = '';
    if (!_isVisible) {
      return;
    }
    _isVisible = false;
    _host.hide();
  }

  void _openMenu() {
    if (!capabilities.menuControl || !_isVisible) {
      return;
    }
    _host.openMenu();
  }

  void _listen() {
    _signals ??= _host.signals().listen(_onSignal);
  }

  void _onSignal(TraySignal signal) {
    switch (signal.kind) {
      case TraySignalKind.iconActivated:
        _events.add(const TrayIconActivated());
      case TraySignalKind.menuRequested:
        _events.add(const TrayMenuRequested());
      case TraySignalKind.itemSelected:
        final item = _itemsById[signal.itemId];
        if (item == null) {
          return;
        }
        switch (item) {
          case TrayMenuAction(:final onSelected):
            onSelected?.call();
          case TrayMenuCheckbox(:final onSelected):
            onSelected?.call();
          case TrayMenuSubmenu():
          case TrayMenuSeparator():
            return;
        }
        _events.add(TrayMenuItemSelected(item));
    }
  }

  /// Scales probed in Flutter's `2.0x/` variant layout. macOS takes every one
  /// found as a representation of one image, Linux the largest on disk, and
  /// Windows loads the asset as-is, so it names a multi-size `.ico`.
  static const variantScales = [1.0, 2.0, 3.0, 4.0];

  @visibleForTesting
  static bool Function(String filePath) fileExists = (filePath) =>
      File(filePath).existsSync();

  @visibleForTesting
  static String variantAsset(String asset, double scale) {
    if (scale == 1.0) {
      return asset;
    }
    final directory = path.posix.dirname(asset);
    return path.posix.joinAll([
      if (directory != '.') directory,
      '${scale.toStringAsFixed(1)}x',
      path.posix.basename(asset),
    ]);
  }

  Future<TrayImage> _resolveImage(TrayIcon icon) async {
    final isMacOS = defaultTargetPlatform == TargetPlatform.macOS;
    return TrayImage(
      path: switch (defaultTargetPlatform) {
        TargetPlatform.macOS => '',
        TargetPlatform.linux => _largestBundledVariant(icon.asset),
        _ => _bundledPath(icon.asset),
      },
      pngs: isMacOS ? await _loadVariants(icon.asset) : const [],
      template: icon.isTemplate,
      size: icon.size,
      placement: switch (icon.position) {
        TrayIconPosition.leading => TrayIconPlacement.leading,
        TrayIconPosition.trailing => TrayIconPlacement.trailing,
      },
    );
  }

  Future<List<Uint8List>> _loadVariants(String asset) async {
    final variants = <Uint8List>[];
    for (final scale in variantScales) {
      final ByteData data;
      try {
        data = await rootBundle.load(variantAsset(asset, scale));
      } on FlutterError {
        continue;
      }
      variants.add(
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
      );
    }
    return variants;
  }

  String _largestBundledVariant(String asset) {
    for (final scale in variantScales.reversed) {
      final candidate = _bundledPath(variantAsset(asset, scale));
      if (fileExists(candidate)) {
        return candidate;
      }
    }
    return _bundledPath(asset);
  }

  String _bundledPath(String asset) {
    return path.joinAll([
      path.dirname(Platform.resolvedExecutable),
      'data',
      'flutter_assets',
      asset,
    ]);
  }

  String get _stableId {
    return path.basenameWithoutExtension(Platform.resolvedExecutable);
  }
}
