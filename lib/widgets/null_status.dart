import 'package:flutter/material.dart';

import '../common/common.dart';

class NullStatus extends StatelessWidget {
  final String label;

  const NullStatus({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        label,
        style: Theme.of(context).textTheme.titleMedium?.toBold,
      ),
    );
  }
}
