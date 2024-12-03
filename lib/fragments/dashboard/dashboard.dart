import 'dart:math';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/fragments/dashboard/intranet_ip.dart';
import 'package:fl_clash/fragments/dashboard/status_button.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'network_detection.dart';
import 'network_speed.dart';
import 'outbound_mode.dart';
import 'start_button.dart';
import 'traffic_usage.dart';

class DashboardFragment extends StatefulWidget {
  const DashboardFragment({super.key});

  @override
  State<DashboardFragment> createState() => _DashboardFragmentState();
}

class _DashboardFragmentState extends State<DashboardFragment> {
  _initFab(bool isCurrent) {
    if (!isCurrent) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final commonScaffoldState =
          context.findAncestorStateOfType<CommonScaffoldState>();
      commonScaffoldState?.floatingActionButton = const StartButton();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ActiveBuilder(
      label: "dashboard",
      builder: (isCurrent, child) {
        _initFab(isCurrent);
        return child!;
      },
      child: Align(
        alignment: Alignment.topCenter,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16).copyWith(
            bottom: 88,
          ),
          child: Selector<AppState, double>(
            selector: (_, appState) => appState.viewWidth,
            builder: (_, viewWidth, ___) {
              final columns = max(4 * ((viewWidth / 350).ceil()), 8);
              final int switchCount = (4 / columns) * viewWidth < 200 ? 8 : 4;
              return Grid(
                crossAxisCount: columns,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  const GridItem(
                    crossAxisCellCount: 8,
                    child: NetworkSpeed(),
                  ),
                  // if (Platform.isAndroid)
                  //   GridItem(
                  //     crossAxisCellCount: switchCount,
                  //     child: const VPNSwitch(),
                  //   ),
                  if (system.isDesktop) ...[
                    GridItem(
                      crossAxisCellCount: switchCount,
                      child: const TUNButton(),
                    ),
                    GridItem(
                      crossAxisCellCount: switchCount,
                      child: const SystemProxyButton(),
                    ),
                  ],
                  const GridItem(
                    crossAxisCellCount: 4,
                    child: OutboundMode(),
                  ),
                  const GridItem(
                    crossAxisCellCount: 4,
                    child: NetworkDetection(),
                  ),
                  const GridItem(
                    crossAxisCellCount: 4,
                    child: TrafficUsage(),
                  ),
                  const GridItem(
                    crossAxisCellCount: 4,
                    child: IntranetIP(),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
