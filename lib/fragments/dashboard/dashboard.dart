import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/fragments/dashboard/intranet_ip.dart';
import 'package:fl_clash/models/models.dart';
import 'package:flutter/material.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:provider/provider.dart';

import 'network_detection.dart';
import 'outbound_mode.dart';
import 'start_button.dart';
import 'network_speed.dart';
import 'traffic_usage.dart';

class DashboardFragment extends StatefulWidget {
  const DashboardFragment({super.key});

  @override
  State<DashboardFragment> createState() => _DashboardFragmentState();
}

class _DashboardFragmentState extends State<DashboardFragment> {
  @override
  Widget build(BuildContext context) {
    return FloatLayout(
      floatingWidget: const FloatWrapper(
        child: StartButton(),
      ),
      child: Align(
        alignment: Alignment.topCenter,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Selector<AppState, ViewMode>(
            selector: (_, appState) => appState.viewMode,
            builder: (_, viewMode, ___) {
              final isDesktop = viewMode == ViewMode.desktop;
              return Grid(
                crossAxisCount: 12,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  GridItem(
                    crossAxisCellCount: isDesktop ? 8 : 12,
                    child: const NetworkSpeed(),
                  ),
                  GridItem(
                    crossAxisCellCount: isDesktop ? 4 : 6,
                    child: const OutboundMode(),
                  ),
                  GridItem(
                    crossAxisCellCount: isDesktop ? 4 : 6,
                    child: const NetworkDetection(),
                  ),
                  GridItem(
                    crossAxisCellCount: isDesktop ? 4 : 6,
                    child: const TrafficUsage(),
                  ),
                  GridItem(
                    crossAxisCellCount: isDesktop ? 4 : 6,
                    child: const IntranetIP(),
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
