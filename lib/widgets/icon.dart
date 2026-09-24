import 'dart:async';
import 'dart:io';

import 'package:fl_clash/common/cache.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/database/database.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/plugins/app.dart';
import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_svg/svg.dart';

const _maxCachedIcons = 64;

class _IconBytesCache {
  _IconBytesCache(this.capacity);

  final int capacity;
  final _entries = <String, Uint8List?>{};

  bool contains(String key) => _entries.containsKey(key);

  Uint8List? operator [](String key) {
    if (!_entries.containsKey(key)) {
      return null;
    }
    return _entries[key] = _entries.remove(key);
  }

  void operator []=(String key, Uint8List? value) {
    _entries.remove(key);
    if (_entries.length >= capacity) {
      _entries.remove(_entries.keys.first);
    }
    _entries[key] = value;
  }

  void remove(String key) => _entries.remove(key);
}

final _decodedIcons = _IconBytesCache(_maxCachedIcons);
final _remoteIcons = _IconBytesCache(_maxCachedIcons);

Uint8List? _decodeIcon(String src) {
  if (!src.contains('base64,')) {
    return null;
  }
  if (_decodedIcons.contains(src)) {
    return _decodedIcons[src];
  }
  return _decodedIcons[src] = src.getBase64;
}

class CommonTargetIcon extends StatelessWidget {
  final String src;

  const CommonTargetIcon({super.key, required this.src});

  Widget _defaultIcon() {
    return const GlyphIcon(AppGlyphs.target);
  }

  Widget _buildIcon() {
    if (src.isEmpty) {
      return _defaultIcon();
    }

    final base64 = _decodeIcon(src);
    if (base64 != null) {
      return _BytesImage(bytes: base64, isSvg: false, fallback: _defaultIcon());
    }

    return ImageCacheWidget(src: src, defaultWidget: _defaultIcon());
  }

  @override
  Widget build(BuildContext context) {
    return _buildIcon();
  }
}

class _BytesImage extends StatelessWidget {
  const _BytesImage({
    required this.bytes,
    required this.isSvg,
    required this.fallback,
    this.onError,
  });

  final Uint8List bytes;
  final bool isSvg;
  final Widget fallback;
  final VoidCallback? onError;

  Widget _buildFallback() {
    onError?.call();
    return fallback;
  }

  @override
  Widget build(BuildContext context) {
    return isSvg
        ? SvgPicture.memory(bytes, errorBuilder: (_, _, _) => _buildFallback())
        : Image.memory(
            bytes,
            gaplessPlayback: true,
            errorBuilder: (_, _, _) => _buildFallback(),
          );
  }
}

final _cacheMange = DefaultCacheManager();

Stream<Uint8List> _loadRemoteIcon(String src) {
  return _cacheMange
      .getFileStreamV2(
        src,
        onRemoteNewLoaded: () {
          commonPrint.log('The icon has been recorded: $src');
          database.iconRecordsDao.putIfAbsent(src);
        },
      )
      .asyncMap((data) => data.file.readAsBytes())
      .map((bytes) {
        final current = _remoteIcons[src];
        final next = current != null && listEquals(current, bytes)
            ? current
            : bytes;
        return _remoteIcons[src] = next;
      });
}

Future<void> _decodeAhead(Uint8List bytes) {
  final completer = Completer<void>();
  final stream = MemoryImage(bytes).resolve(ImageConfiguration.empty);
  late final ImageStreamListener listener;
  void finish() {
    stream.removeListener(listener);
    completer.complete();
  }

  listener = ImageStreamListener(
    (_, _) => finish(),
    onError: (_, _) => finish(),
  );
  stream.addListener(listener);
  return completer.future;
}

Future<void> precacheTargetIcons(Iterable<String> srcs) async {
  final pending = srcs
      .toSet()
      .where(
        (src) =>
            src.isNotEmpty &&
            !src.contains('base64,') &&
            !_remoteIcons.contains(src),
      )
      .map((src) async {
        try {
          await for (final bytes in _loadRemoteIcon(src)) {
            if (!src.isSvg) {
              await _decodeAhead(bytes);
            }
          }
        } catch (error) {
          commonPrint.log('Failed to precache icon $src: $error');
        }
      });
  await Future.wait(pending);
}

class ImageCacheWidget extends StatefulWidget {
  final String src;
  final Widget defaultWidget;

  const ImageCacheWidget({
    super.key,
    required this.src,
    required this.defaultWidget,
  });

  @override
  State<ImageCacheWidget> createState() => _ImageCacheWidgetState();
}

class _ImageCacheWidgetState extends State<ImageCacheWidget> {
  late final ValueNotifier<Uint8List?> _bytesNotifier;
  StreamSubscription? _streamSubscription;

  @override
  void initState() {
    super.initState();
    _bytesNotifier = ValueNotifier(_remoteIcons[widget.src]);
    _getImageFormCache();
  }

  @override
  void didUpdateWidget(covariant ImageCacheWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.src != widget.src) {
      _bytesNotifier.value = _remoteIcons[widget.src];
      _getImageFormCache();
    }
  }

  void _getImageFormCache() {
    final src = widget.src;
    _streamSubscription?.cancel();
    _streamSubscription = null;
    if (src.isEmpty) {
      return;
    }
    _streamSubscription = _loadRemoteIcon(src).listen(
      (bytes) {
        if (mounted) {
          _bytesNotifier.value = bytes;
        }
      },
      onError: (Object error) {
        commonPrint.log('Failed to read icon $src: $error');
      },
    );
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    _bytesNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Uint8List?>(
      valueListenable: _bytesNotifier,
      builder: (_, bytes, _) {
        if (bytes == null) {
          return widget.defaultWidget;
        }
        return _BytesImage(
          bytes: bytes,
          isSvg: widget.src.isSvg,
          fallback: widget.defaultWidget,
          onError: () => _remoteIcons.remove(widget.src),
        );
      },
    );
  }
}

class PackageIcon extends StatefulWidget {
  final String packageName;
  final double size;
  final Widget? placeholder;

  const PackageIcon({
    super.key,
    required this.packageName,
    required this.size,
    this.placeholder,
  });

  @override
  State<PackageIcon> createState() => _PackageIconState();
}

class _PackageIconState extends State<PackageIcon> {
  ImageProvider? _icon;
  int _generation = 0;

  @override
  void initState() {
    super.initState();
    _loadIcon();
  }

  @override
  void didUpdateWidget(covariant PackageIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.packageName != widget.packageName) {
      _loadIcon();
    }
  }

  void _loadIcon() {
    final generation = ++_generation;
    final packageName = widget.packageName;
    final currentApp = app;
    if (currentApp == null) {
      _icon = null;
      return;
    }
    if (currentApp.hasPackageIcon(packageName)) {
      _icon = currentApp.getCachedPackageIcon(packageName);
      return;
    }
    _icon = null;
    currentApp.getPackageIcon(packageName).then((icon) {
      if (!mounted || generation != _generation || icon == null) {
        return;
      }
      setState(() {
        _icon = icon;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final icon = _icon;
    if (icon == null) {
      return widget.placeholder ??
          SizedBox(width: widget.size, height: widget.size);
    }
    return Image(
      image: icon,
      gaplessPlayback: true,
      width: widget.size,
      height: widget.size,
    );
  }
}

class CommonImage extends StatelessWidget {
  final File data;
  final bool isSvg;
  final Widget Function(
    BuildContext context,
    Object error,
    StackTrace? stackTrace,
  )?
  errorBuilder;

  const CommonImage({
    super.key,
    required this.data,
    this.errorBuilder,
    this.isSvg = false,
  });

  @override
  Widget build(BuildContext context) {
    return isSvg
        ? SvgPicture.file(data, errorBuilder: errorBuilder)
        : Image.file(data, gaplessPlayback: true, errorBuilder: errorBuilder);
  }
}
