import 'dart:io';


import 'package:fl_clash/common/common.dart';
import 'package:flutter/widgets.dart';

class PopContainer extends StatefulWidget {
  final Widget child;

  const PopContainer({super.key, required this.child});

  @override
  State<PopContainer> createState() => _PopContainerState();
}

class _PopContainerState extends State<PopContainer> {
  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid) {
      return PopScope(
        canPop: false,
        onPopInvoked: (didPop) async {
          final canPop = Navigator.canPop(context);
          if (canPop) {
            Navigator.pop(context);
          } else {
            await context.appController.handleBackOrExit();
          }
        },
        child: widget.child,
      );
    }
    return widget.child;
  }
}
