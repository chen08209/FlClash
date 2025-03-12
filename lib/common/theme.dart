import 'package:fl_clash/common/common.dart';
import 'package:flutter/material.dart';

class CommonTheme {
  final BuildContext context;
  final Map<String, Color> _colorMap;

  CommonTheme.of(this.context) : _colorMap = {};

  Color get darkenSecondaryContainer {
    return _colorMap.getCacheValue(
      "darkenSecondaryContainer",
      context.colorScheme.secondaryContainer.blendDarken(context, factor: 0.1),
    );
  }

  Color get darkenSecondaryContainerLighter {
    return _colorMap.getCacheValue(
      "darkenSecondaryContainerLighter",
      context.colorScheme.secondaryContainer
          .blendDarken(context, factor: 0.1)
          .opacity60,
    );
  }

  Color get darken2SecondaryContainer {
    return _colorMap.getCacheValue(
      "darken2SecondaryContainer",
      context.colorScheme.secondaryContainer.blendDarken(context, factor: 0.2),
    );
  }

  Color get darken3PrimaryContainer {
    return _colorMap.getCacheValue(
      "darken3PrimaryContainer",
      context.colorScheme.primaryContainer.blendDarken(context, factor: 0.3),
    );
  }
}
