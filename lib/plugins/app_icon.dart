import 'dart:async';
import 'dart:io';
import 'dart:ui' show PlatformDispatcher;

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/models/models.dart';
import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:rust_api/rust_api.dart' show appIconFile;

String appIconIdOf(Metadata metadata) =>
    metadata.processPath.isNotEmpty ? metadata.processPath : metadata.process;

/// The share of its square a square icon from [AppIconSource] visibly fills,
/// measured on what each platform renders: macOS draws every app on Apple's
/// grid, 824 of 1024; GNOME's square icons leave 16 of 256 clear on each
/// side; Windows and Android icons reach the edges.
const appIconBodies = (macOS: 0.805, android: 1.0, windows: 1.0, linux: 0.875);

double get hostAppIconBody => system.isMacOS
    ? appIconBodies.macOS
    : system.isAndroid
    ? appIconBodies.android
    : system.isWindows
    ? appIconBodies.windows
    : appIconBodies.linux;

/// The empty id is the platform's generic app icon, which also stands in for
/// an app whose own icon cannot be had.
abstract class AppIconSource {
  final Map<String, ImageProvider?> _icons = {};
  final Map<String, Future<ImageProvider?>> _iconTasks = {};
  final TaskPool _iconPool = TaskPool(maxConcurrentIconLoads);
  final Map<String, ImageProvider?> _ownIcons = {};
  final Map<String, Future<ImageProvider?>> _ownIconTasks = {};

  @protected
  Future<String?> loadIconFile(String id);

  ImageProvider? getCachedPackageIcon(String id) => _icons[id];

  Future<ImageProvider?> getPackageIcon(String id) {
    if (_icons.containsKey(id)) {
      return Future.value(_icons[id]);
    }
    return _iconTasks[id] ??= _loadIcon(id);
  }

  ({ImageProvider? icon})? getCachedOwnPackageIcon(String id) {
    if (!_ownIcons.containsKey(id)) {
      return null;
    }
    return (icon: _ownIcons[id]);
  }

  /// Null for an app known to have no icon of its own.
  Future<ImageProvider?> getOwnPackageIcon(String id) {
    if (_ownIcons.containsKey(id)) {
      return Future.value(_ownIcons[id]);
    }
    return _ownIconTasks[id] ??= _loadOwnIcon(id);
  }

  Future<ImageProvider?> _loadOwnIcon(String id) async {
    ImageProvider? own;
    if (id.isNotEmpty) {
      final (icon, fallback) = await (
        getPackageIcon(id),
        getPackageIcon(''),
      ).wait;
      own = icon == fallback ? null : icon;
    }
    _ownIcons[id] = own;
    unawaited(_ownIconTasks.remove(id));
    return own;
  }

  Future<ImageProvider?> _loadIcon(String id) async {
    var icon = await _requestIcon(id);
    if (icon == null && id.isNotEmpty) {
      icon = await getPackageIcon('');
    }
    _icons[id] = icon;
    unawaited(_iconTasks.remove(id));
    return icon;
  }

  Future<ImageProvider?> _requestIcon(String id) async {
    try {
      final path = await _iconPool.run(() => loadIconFile(id));
      if (path == null || path.isEmpty) {
        return null;
      }
      return FileImage(File(path));
    } catch (error) {
      commonPrint.log('app icon $id: ${compactError(error)}');
      return null;
    }
  }

  @visibleForTesting
  void clearPackageIconCache() {
    _icons.clear();
    _iconTasks.clear();
    _ownIcons.clear();
    _ownIconTasks.clear();
  }
}

class DesktopAppIconSource extends AppIconSource {
  DesktopAppIconSource({
    Future<String?> Function(String path, int size, String cacheDir)? render,
    Future<String>? cacheDir,
  }) : _render = render ?? _renderNative,
       _cacheDir =
           cacheDir ??
           appPath.cacheDir.future.then((dir) => join(dir.path, 'app_icons'));

  final Future<String?> Function(String path, int size, String cacheDir)
  _render;
  final Future<String> _cacheDir;

  static Future<String?> _renderNative(
    String path,
    int size,
    String cacheDir,
  ) => appIconFile(processPath: path, size: size, cacheDir: cacheDir);

  @override
  Future<String?> loadIconFile(String id) async =>
      _render(id, _iconPixels(), await _cacheDir);
}

/// Rendered for the densest screen so the image is never scaled up.
int _iconPixels() {
  final ratio = PlatformDispatcher.instance.views.fold(
    1.0,
    (ratio, view) =>
        view.devicePixelRatio > ratio ? view.devicePixelRatio : ratio,
  );
  return (appIconExtent * ratio).ceil();
}
