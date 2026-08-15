import 'dart:async';
import 'dart:io';

import 'package:fl_clash/common/cache.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/database/database.dart';
import 'package:fl_clash/plugins/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_svg/svg.dart';

class CommonTargetIcon extends StatelessWidget {
  final String src;

  const CommonTargetIcon({super.key, required this.src});

  Widget _defaultIcon() {
    return const Icon(IconsExt.target);
  }

  Widget _buildIcon() {
    if (src.isEmpty) {
      return _defaultIcon();
    }

    final base64 = src.getBase64;
    if (base64 != null) {
      return Image.memory(
        base64,
        gaplessPlayback: true,
        errorBuilder: (_, error, _) {
          return _defaultIcon();
        },
      );
    }

    return ImageCacheWidget(src: src, defaultWidget: _defaultIcon());
  }

  @override
  Widget build(BuildContext context) {
    return _buildIcon();
  }
}

final _cacheMange = DefaultCacheManager();

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
  final ValueNotifier<File?> _imageNotifier = ValueNotifier(null);
  StreamSubscription? _streamSubscription;

  @override
  void initState() {
    super.initState();
    _getImageFormCache();
  }

  @override
  void didUpdateWidget(covariant ImageCacheWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.src != widget.src) {
      _getImageFormCache();
    }
  }

  void _getImageFormCache() {
    _imageNotifier.value = null;
    final src = widget.src;
    if (src.isEmpty) {
      return;
    }
    _streamSubscription?.cancel();
    _streamSubscription = _cacheMange
        .getFileStreamV2(
          src,
          onRemoteNewLoaded: () {
            commonPrint.log('The icon has been recorded: $src');
            database.iconRecordsDao.putIfAbsent(src);
          },
        )
        .listen((data) {
          if (mounted) {
            _imageNotifier.value = data.file;
          }
        });
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    _imageNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<File?>(
      valueListenable: _imageNotifier,
      builder: (_, data, _) {
        if (data == null) {
          return widget.defaultWidget;
        }
        return CommonImage(
          data: data,
          isSvg: widget.src.isSvg,
          errorBuilder: (_, _, _) {
            return widget.defaultWidget;
          },
        );
      },
    );
  }
}

class PackageIcon extends StatefulWidget {
  final String packageName;
  final double size;

  const PackageIcon({super.key, required this.packageName, required this.size});

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
    if (currentApp == null || packageName.isEmpty) {
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
      return SizedBox(width: widget.size, height: widget.size);
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
        : Image.file(data, errorBuilder: errorBuilder);
  }
}
