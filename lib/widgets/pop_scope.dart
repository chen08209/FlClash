import 'dart:async';
import 'package:flutter/widgets.dart';

class CommonPopScope extends StatelessWidget {
  final Widget child;
  final FutureOr<bool> Function()? onPop;

  const CommonPopScope({
    super.key,
    required this.child,
    this.onPop,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: onPop == null ? true : false,
      onPopInvokedWithResult: onPop == null
          ? null
          : (didPop, __) async {
              if (didPop) {
                return;
              }
              final res = await onPop!();
              if (!context.mounted) {
                return;
              }
              if (!res) {
                return;
              }
              Navigator.of(context).pop();
            },
      child: child,
    );
  }
}
