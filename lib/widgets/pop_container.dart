import 'dart:io';


import 'package:fl_clash/state.dart';
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
        onPopInvoked: (_) async {
          final canPop = Navigator.canPop(context);
          if (canPop) {
            Navigator.pop(context);
          } else {
            await globalState.appController.handleBackOrExit();
          }
        },
        child: widget.child,
      );
    }
    return widget.child;
  }
}
