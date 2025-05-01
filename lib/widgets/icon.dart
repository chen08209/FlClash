import 'package:fl_clash/common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_svg/svg.dart';

class CommonTargetIcon extends StatelessWidget {
  final String src;
  final double size;

  const CommonTargetIcon({
    super.key,
    required this.src,
    required this.size,
  });

  Widget _defaultIcon() {
    return Icon(
      IconsExt.target,
      size: size,
    );
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
        errorBuilder: (_, error, ___) {
          return _defaultIcon();
        },
      );
    }
    return FutureBuilder(
      future: DefaultCacheManager().getSingleFile(src),
      builder: (_, snapshot) {
        final data = snapshot.data;
        if (data == null) {
          return SizedBox();
        }
        return src.isSvg
            ? SvgPicture.file(
                data,
                errorBuilder: (_, __, ___) => _defaultIcon(),
              )
            : Image.file(
                data,
                errorBuilder: (_, __, ___) => _defaultIcon(),
              );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: _buildIcon(),
    );
  }
}
