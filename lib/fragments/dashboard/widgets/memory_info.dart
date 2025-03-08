import 'dart:async';
import 'dart:io';

import 'package:fl_clash/clash/clash.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/models/common.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';

final _memoryInfoStateNotifier = ValueNotifier<TrafficValue>(
  TrafficValue(value: 0),
);

class MemoryInfo extends StatefulWidget {
  const MemoryInfo({super.key});

  @override
  State<MemoryInfo> createState() => _MemoryInfoState();
}

class _MemoryInfoState extends State<MemoryInfo> {
  Timer? timer;

  @override
  void initState() {
    super.initState();
    _updateMemory();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  _updateMemory() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final rss = ProcessInfo.currentRss;
      _memoryInfoStateNotifier.value = TrafficValue(
        value: clashLib != null ? rss : await clashCore.getMemory() + rss,
      );
      timer = Timer(Duration(seconds: 5), () async {
        _updateMemory();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final darkenLighter = context.colorScheme.secondaryContainer
        .blendDarken(context, factor: 0.1)
        .toLighter;
    final darken = context.colorScheme.secondaryContainer
        .blendDarken(context, factor: 0.1);
    return SizedBox(
      height: getWidgetHeight(2),
      child: CommonCard(
        info: Info(
          iconData: Icons.memory,
          label: appLocalizations.memoryInfo,
        ),
        onPressed: () {
          clashCore.requestGc();
        },
        child: Column(
          children: [
            ValueListenableBuilder(
              valueListenable: _memoryInfoStateNotifier,
              builder: (_, trafficValue, __) {
                return Padding(
                  padding: baseInfoEdgeInsets.copyWith(
                    bottom: 0,
                    top: 12,
                  ),
                  child: Row(
                    children: [
                      Text(
                        trafficValue.showValue,
                        style: context.textTheme.titleLarge?.toLight,
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      Text(
                        trafficValue.showUnit,
                        style: context.textTheme.titleLarge?.toLight,
                      )
                    ],
                  ),
                );
              },
            ),
            Flexible(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: WaveView(
                      waveAmplitude: 12.0,
                      waveFrequency: 0.35,
                      waveColor: darkenLighter,
                    ),
                  ),
                  Positioned.fill(
                    child: WaveView(
                      waveAmplitude: 12.0,
                      waveFrequency: 0.9,
                      waveColor: darken,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
