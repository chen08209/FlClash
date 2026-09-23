import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/views/dashboard/widgets/widgets.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';

extension DashboardWidgetView on DashboardWidget {
  GridItem get widget => switch (this) {
    DashboardWidget.networkSpeed => const GridItem(
      key: ValueKey(DashboardWidget.networkSpeed),
      crossAxisCellCount: 8,
      child: NetworkSpeed(),
    ),
    DashboardWidget.outboundMode => const GridItem(
      key: ValueKey(DashboardWidget.outboundMode),
      crossAxisCellCount: 4,
      child: OutboundMode(),
    ),
    DashboardWidget.trafficUsage => const GridItem(
      key: ValueKey(DashboardWidget.trafficUsage),
      crossAxisCellCount: 4,
      child: TrafficUsage(),
    ),
    DashboardWidget.networkDetection => const GridItem(
      key: ValueKey(DashboardWidget.networkDetection),
      crossAxisCellCount: 4,
      child: NetworkDetection(),
    ),
    DashboardWidget.tunButton => const GridItem(
      key: ValueKey(DashboardWidget.tunButton),
      crossAxisCellCount: 4,
      child: TUNButton(),
    ),
    DashboardWidget.vpnButton => const GridItem(
      key: ValueKey(DashboardWidget.vpnButton),
      crossAxisCellCount: 4,
      child: VpnButton(),
    ),
    DashboardWidget.systemProxyButton => const GridItem(
      key: ValueKey(DashboardWidget.systemProxyButton),
      crossAxisCellCount: 4,
      child: SystemProxyButton(),
    ),
    DashboardWidget.intranetIp => const GridItem(
      key: ValueKey(DashboardWidget.intranetIp),
      crossAxisCellCount: 4,
      child: IntranetIP(),
    ),
    DashboardWidget.memoryInfo => const GridItem(
      key: ValueKey(DashboardWidget.memoryInfo),
      crossAxisCellCount: 4,
      child: MemoryInfo(),
    ),
    DashboardWidget.serviceStatus => const GridItem(
      key: ValueKey(DashboardWidget.serviceStatus),
      crossAxisCellCount: 8,
      child: ServiceStatusCard(),
    ),
    DashboardWidget.dnsQueries => const GridItem(
      key: ValueKey(DashboardWidget.dnsQueries),
      crossAxisCellCount: 4,
      child: DnsQueriesCard(),
    ),
    DashboardWidget.requests => const GridItem(
      key: ValueKey(DashboardWidget.requests),
      crossAxisCellCount: 4,
      child: RequestsCard(),
    ),
    DashboardWidget.connections => const GridItem(
      key: ValueKey(DashboardWidget.connections),
      crossAxisCellCount: 4,
      child: ConnectionsCard(),
    ),
  };
}

DashboardWidget dashboardWidgetOf(GridItem gridItem) {
  return (gridItem.key! as ValueKey<DashboardWidget>).value;
}
