import 'dart:io';

import 'package:fl_clash/common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class CommonTargetIcon extends StatelessWidget {
  final String src;
  final double size;

  const CommonTargetIcon({super.key, required this.src, required this.size});

  Widget _defaultIcon() {
    return Icon(IconsExt.target, size: size);
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
    return SizedBox(width: size, height: size, child: _buildIcon());
  }
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
  late Future<File> _imageFuture;

  @override
  void initState() {
    super.initState();
    _imageFuture = LocalImageCacheManager().getSingleFile(widget.src);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<File>(
      future: _imageFuture,
      builder: (context, snapshot) {
        final data = snapshot.data;
        if (data == null) {
          return SizedBox();
        }
        return widget.src.isSvg
            ? SvgPicture.file(
                data,
                errorBuilder: (_, _, _) => widget.defaultWidget,
              )
            : Image.file(data, errorBuilder: (_, _, _) => widget.defaultWidget);
      },
    );
  }
}
