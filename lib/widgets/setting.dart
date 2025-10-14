import 'package:fl_clash/common/common.dart';
import 'package:flutter/material.dart';

import 'card.dart';

class SettingInfoCard extends StatelessWidget {
  final Info info;
  final bool? isSelected;
  final VoidCallback onPressed;

  const SettingInfoCard(
    this.info, {
    super.key,
    this.isSelected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return CommonCard(
      isSelected: isSelected,
      onPressed: onPressed,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Flexible(child: Icon(info.iconData)),
            const SizedBox(width: 8),
            Flexible(
              child: Text(info.label, style: context.textTheme.bodyMedium),
            ),
          ],
        ),
      ),
    );
  }
}

class SettingTextCard extends StatelessWidget {
  final String text;
  final bool? isSelected;
  final VoidCallback onPressed;

  const SettingTextCard(
    this.text, {
    super.key,
    this.isSelected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return CommonCard(
      onPressed: onPressed,
      isSelected: isSelected,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Text(text, style: context.textTheme.bodyMedium),
      ),
    );
  }
}
