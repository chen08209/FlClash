import 'package:flutter/material.dart';

class CommonChip extends StatelessWidget {
  final String label;

  const CommonChip({
    super.key,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Chip(
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      padding: const EdgeInsets.symmetric(
        vertical: 0,
        horizontal: 4,
      ),
      side: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.2)),
      labelStyle: Theme.of(context).textTheme.bodyMedium,
      label: Text(label),
    );
  }
}
