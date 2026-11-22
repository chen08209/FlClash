import 'dart:async';

import 'package:fl_clash/common/cache.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/ui/icons/icons.dart';
import 'package:fl_clash/ui/ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';

export 'package:fl_clash/plugins/app_icon.dart'
    show appIconBodies, appIconIdOf, hostAppIconBody;

const _maxCachedIconBytes = 16 << 20;

// The decode size is in dp and follows the pixel ratio an image resolves at,
// so the precache resolves at the view's ratio to share the widget's
// ImageCache entry.
const _iconDecodeExtent = 48;

ImageProvider _iconImage(Uint8List bytes) {
  return ResizeImage(
    MemoryImage(bytes),
    width: _iconDecodeExtent,
    height: _iconDecodeExtent,
    policy: ResizeImagePolicy.fit,
    useLogicalSize: true,
  );
}

class _IconBytesCache {
  _IconBytesCache(this.maxBytes);

  final int maxBytes;
  final _entries = <String, Uint8List?>{};
  var _bytes = 0;

  bool contains(String key) => _entries.containsKey(key);

  Uint8List? operator [](String key) {
    if (!_entries.containsKey(key)) {
      return null;
    }
    return _entries[key] = _entries.remove(key);
  }

  void operator []=(String key, Uint8List? value) {
    remove(key);
    final size = value?.lengthInBytes ?? 0;
    if (size > maxBytes) {
      return;
    }
    _entries[key] = value;
    _bytes += size;
    while (_bytes > maxBytes) {
      remove(_entries.keys.first);
    }
  }

  void remove(String key) {
    _bytes -= _entries.remove(key)?.lengthInBytes ?? 0;
  }
}

final _decodedIcons = _IconBytesCache(_maxCachedIconBytes);
final _remoteIcons = _IconBytesCache(_maxCachedIconBytes);

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

  /// Shown while [src] is empty, loading or unreadable.
  final Widget? fallback;

  const CommonTargetIcon({super.key, required this.src, this.fallback});

  Widget _defaultIcon() {
    return fallback ?? const _ImagePlaceholder();
  }

  Widget _buildIcon() {
    if (src.isEmpty) {
      return _defaultIcon();
    }

    final base64 = _decodeIcon(src);
    if (base64 != null) {
      return _BytesImage(
        bytes: base64,
        isSvg: src.isSvg,
        fallback: _defaultIcon(),
      );
    }

    return ImageCacheWidget(src: src, defaultWidget: _defaultIcon());
  }

  @override
  Widget build(BuildContext context) {
    return _buildIcon();
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    final size = IconTheme.of(context).size ?? 24;
    final colorScheme = context.colorScheme;
    return SizedBox.square(
      dimension: size,
      child: Center(
        child: GlyphIcon(
          AppGlyphs.photos,
          size: size * 0.7,
          color: Color.alphaBlend(
            colorScheme.onSurfaceVariant.opacity50,
            colorScheme.surface,
          ),
        ),
      ),
    );
  }
}

/// Stands for a proxy group without an icon: the first letter or digit of
/// its name, past any leading emoji the name already shows.
class GroupMonogram extends StatelessWidget {
  final String name;

  const GroupMonogram(this.name, {super.key});

  static final _letter = RegExp(r'[\p{L}\p{N}]', unicode: true);

  String get _mark {
    final letter = _letter.firstMatch(name)?.group(0);
    if (letter != null) {
      return letter.toUpperCase();
    }
    return name.characters.firstOrNull ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final iconTheme = IconTheme.of(context);
    final size = iconTheme.size ?? 24;
    final mark = _mark;
    if (mark.isEmpty) {
      return const _ImagePlaceholder();
    }
    return SizedBox.square(
      dimension: size,
      child: Center(
        child: EmojiText(
          mark,
          maxLines: 1,
          style: AppTextStyle.custom(
            context,
            size: size * 0.62,
            leading: size * 0.62,
            weight: FontWeight.w600,
          ).copyWith(color: iconTheme.color),
        ),
      ),
    );
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
    final size = IconTheme.of(context).size ?? 24;
    return isSvg
        ? SvgPicture.memory(
            bytes,
            width: size,
            height: size,
            fit: BoxFit.scaleDown,
            errorBuilder: (_, _, _) => _buildFallback(),
          )
        : Image(
            image: _iconImage(bytes),
            width: size,
            height: size,
            fit: BoxFit.scaleDown,
            gaplessPlayback: true,
            errorBuilder: (_, _, _) => _buildFallback(),
          );
  }
}

final _cacheManager = CacheManager(
  Config(
    DefaultCacheManager.key,
    fileService: HttpFileService()..concurrentFetches = maxConcurrentIconLoads,
  ),
);

Stream<Uint8List> _readCachedIcon(String src) {
  return _cacheManager
      .getFileStreamV2(src)
      .asyncMap((data) => data.file.readAsBytes());
}

var _readRemoteIcon = _readCachedIcon;

@visibleForTesting
set readRemoteIcon(Stream<Uint8List> Function(String src)? value) {
  _readRemoteIcon = value ?? _readCachedIcon;
}

Stream<Uint8List> _loadRemoteIcon(String src) {
  return _readRemoteIcon(src).map((bytes) {
    final current = _remoteIcons[src];
    final next = current != null && listEquals(current, bytes)
        ? current
        : bytes;
    return _remoteIcons[src] = next;
  });
}

Future<void> _decodeAhead(Uint8List bytes) {
  final completer = Completer<void>();
  final view = WidgetsBinding.instance.platformDispatcher.implicitView;
  final stream = _iconImage(
    bytes,
  ).resolve(ImageConfiguration(devicePixelRatio: view?.devicePixelRatio));
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
  var _loadEnded = false;

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
      _loadEnded = false;
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
      onDone: () {
        if (mounted && _bytesNotifier.value == null) {
          setState(() => _loadEnded = true);
        }
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
      builder: (context, bytes, _) {
        if (bytes == null) {
          return _loadEnded || widget.src.isEmpty
              ? widget.defaultWidget
              : SizedBox.square(dimension: IconTheme.of(context).size ?? 24);
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

class PackageIcon extends ConsumerStatefulWidget {
  final String packageName;
  final double size;

  const PackageIcon({super.key, required this.packageName, required this.size});

  @override
  ConsumerState<PackageIcon> createState() => _PackageIconState();
}

class _PackageIconState extends ConsumerState<PackageIcon>
    with _PackageIconLoader<PackageIcon> {
  @override
  String packageNameOf(PackageIcon widget) => widget.packageName;

  @override
  (ImageProvider?, Future<ImageProvider?>?) lookUp(String packageName) {
    final source = ref.read(packageIconSourceProvider);
    return (
      source?.getCachedPackageIcon(packageName),
      source?.getPackageIcon(packageName),
    );
  }

  @override
  Widget build(BuildContext context) {
    final icon = this.icon;
    if (icon == null) {
      return SizedBox(width: widget.size, height: widget.size);
    }
    return packageIconImage(icon, widget.size);
  }
}

/// Shows a package's cached icon at once and the one [lookUp] loads once it
/// lands, unless the widget has moved to another package by then.
mixin _PackageIconLoader<T extends StatefulWidget> on State<T> {
  ImageProvider? icon;
  var _generation = 0;

  String packageNameOf(T widget);

  (ImageProvider?, Future<ImageProvider?>?) lookUp(String packageName);

  @override
  void initState() {
    super.initState();
    _resolve();
  }

  @override
  void didUpdateWidget(covariant T oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (packageNameOf(oldWidget) != packageNameOf(widget)) {
      _resolve();
    }
  }

  void _resolve() {
    final generation = ++_generation;
    final (cached, load) = lookUp(packageNameOf(widget));
    icon = cached;
    load?.then((loaded) {
      if (mounted && generation == _generation) {
        onLoaded(loaded);
      }
    });
  }

  void onLoaded(ImageProvider? loaded) {
    if (loaded != null && loaded != icon) {
      setState(() {
        icon = loaded;
      });
    }
  }
}

Widget packageIconImage(ImageProvider icon, double size) =>
    Image(image: icon, gaplessPlayback: true, width: size, height: size);

/// Shows the icon of [packageName], an id from `appIconIdOf`. Null only where
/// the app is unknown or known to have no icon; else holds the icon room.
class OwnPackageIcon extends ConsumerStatefulWidget {
  final String packageName;
  final double size;
  final Widget Function(BuildContext context, Widget? icon) builder;

  const OwnPackageIcon({
    super.key,
    required this.packageName,
    required this.size,
    required this.builder,
  });

  @override
  ConsumerState<OwnPackageIcon> createState() => _OwnPackageIconState();
}

class _OwnPackageIconState extends ConsumerState<OwnPackageIcon>
    with _PackageIconLoader<OwnPackageIcon> {
  var _holdsRoom = false;

  @override
  String packageNameOf(OwnPackageIcon widget) => widget.packageName;

  @override
  (ImageProvider?, Future<ImageProvider?>?) lookUp(String packageName) {
    final source = packageName.isEmpty
        ? null
        : ref.read(packageIconSourceProvider);
    final cached = source?.getCachedOwnPackageIcon(packageName);
    final load = cached == null ? source?.getOwnPackageIcon(packageName) : null;
    _holdsRoom = load != null;
    return (cached?.icon, load);
  }

  @override
  void onLoaded(ImageProvider? loaded) {
    if (loaded != null) {
      super.onLoaded(loaded);
      return;
    }
    setState(() => _holdsRoom = false);
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size;
    final icon = this.icon;
    return widget.builder(
      context,
      icon != null
          ? packageIconImage(icon, size)
          : _holdsRoom
          ? SizedBox.square(dimension: size)
          : null,
    );
  }
}
