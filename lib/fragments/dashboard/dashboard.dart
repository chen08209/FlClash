import 'package:flutter/material.dart';
import 'package:flutter_adaptive_scaffold/flutter_adaptive_scaffold.dart';
import 'package:fl_clash/widgets/widgets.dart';

import 'network_detection.dart';
import 'core_info.dart';
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
  _buildGrid(bool isDesktop) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Grid(
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
            child: const CoreInfo(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (_, container) {
      if (container.maxWidth < 200) return Container();
      return FloatLayout(
        floatingWidget: const FloatWrapper(
          child: StartButton(),
        ),
        child: Align(
          alignment: Alignment.topCenter,
          child: SlotLayout(
            config: {
              Breakpoints.small: SlotLayout.from(
                key: const Key('dashboard_small'),
                builder: (_) => _buildGrid(false),
              ),
              Breakpoints.mediumAndUp: SlotLayout.from(
                key: const Key('dashboard_mediumAndUp'),
                builder: (_) => _buildGrid(true),
              ),
            },
          ),
        ),
      );
    });
  }
}
