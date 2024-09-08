import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/models/config.dart';
import 'package:fl_clash/state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MediaManager extends StatelessWidget {
  final Widget child;

  const MediaManager({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Selector<Config, ScaleProps>(
      selector: (_, config) => config.scaleProps,
      builder: (_, props, child) {
        globalState.measure = Measure.of(context);
        return child!;
        // final textScaleFactor =
        //     WidgetsBinding.instance.platformDispatcher.textScaleFactor;
        // return MediaQuery(
        //   data: MediaQuery.of(context).copyWith(
        //     textScaler: props.custom
        //         ? TextScaler.linear(props.scale * textScaleFactor)
        //         : null,
        //   ),
        //   child: Builder(
        //     builder: (context) {
        //       globalState.measure = Measure.of(context);
        //       return child!;
        //     },
        //   ),
        // );
      },
      child: child,
    );
  }
}
