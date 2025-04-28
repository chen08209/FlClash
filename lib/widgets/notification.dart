import 'package:fl_clash/models/config.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TextScaleNotification extends StatelessWidget {
  final Widget child;
  final Function(TextScale textScale) onNotification;

  const TextScaleNotification({
    super.key,
    required this.child,
    required this.onNotification,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (_, ref, child) {
        ref.listen(
          themeSettingProvider.select((state) => state.textScale),
          (prev, next) {
            if (prev != next) {
              onNotification(next);
            }
          },
        );
        return child!;
      },
      child: child,
    );
  }
}
