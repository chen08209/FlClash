import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/plugins/tile.dart';
import 'package:flutter/material.dart';

class TileContainer extends StatefulWidget {
  final Widget child;

  const TileContainer({
    super.key,
    required this.child,
  });

  @override
  State<TileContainer> createState() => _TileContainerState();
}

class _TileContainerState extends State<TileContainer> with TileListener {


  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  @override
  void onStart() {
    context.appController.updateSystemProxy(true);
    super.onStart();
  }

  @override
  void onStop() {
    context.appController.updateSystemProxy(false);
    super.onStop();
  }

  @override
  void initState() {
    super.initState();
    tile?.addListener(this);
  }

  @override
  void dispose() {
    tile?.removeListener(this);
    super.dispose();
  }
}
