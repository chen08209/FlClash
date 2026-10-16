import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/views/dashboard/layout.dart';
import 'package:fl_clash/views/dashboard/style.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'card.dart';
import 'connections_table.dart';

/// The counts of the three feeds, each opening its list, for the phone and
/// for a desktop page too short for the table.
class ConnectionStatsCard extends ConsumerStatefulWidget {
  const ConnectionStatsCard({super.key});

  @override
  ConsumerState<ConnectionStatsCard> createState() =>
      _ConnectionStatsCardState();
}

class _ConnectionStatsCardState extends ConsumerState<ConnectionStatsCard>
    with
        WidgetsBindingObserver,
        ActivePollingMixin<ConnectionStatsCard>,
        RouteMotionHoldMixin<ConnectionStatsCard>,
        ConnectionsPolling<ConnectionStatsCard> {
  static const _inset = 8.0;

  @override
  bool get pollsConnections => false;

  @override
  Widget build(BuildContext context) {
    final shape = AppShape.all(
      dashboardCardRadius(DashboardDensityScope.of(context)) - _inset,
    );
    return DashboardCard(
      semanticLabel: context.appLocalizations.connectionStats,
      padding: const EdgeInsets.all(_inset),
      child: Row(
        children: [
          _Stat(
            feed: DashboardFeed.connections,
            shape: shape,
            count: ValueListenableBuilder(
              valueListenable: connectionCount,
              builder: (context, count, _) => _Count(count),
            ),
          ),
          _Stat(
            feed: DashboardFeed.requests,
            shape: shape,
            count: ThrottledCount(
              provider: requestCountProvider,
              builder: (_, count) => _Count(count),
            ),
          ),
          _Stat(
            feed: DashboardFeed.dns,
            shape: shape,
            count: ThrottledCount(
              provider: dnsQueryCountProvider,
              builder: (_, count) => _Count(count),
            ),
          ),
        ],
      ),
    );
  }
}

class _Count extends StatelessWidget {
  const _Count(this.count);

  final int count;

  @override
  Widget build(BuildContext context) {
    return Text(
      dashboardCount(count),
      maxLines: 1,
      style: DashboardText.figure(
        context,
        AppTextStyle.title2,
      ).copyWith(letterSpacing: 0),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.feed, required this.shape, required this.count});

  final DashboardFeed feed;
  final OutlinedBorder shape;
  final Widget count;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Semantics(
        button: true,
        label: feed.page.label,
        child: FocusRing(
          shape: shape,
          child: InkWell(
            customBorder: shape,
            hoverColor: DashboardColors.of(context).tone,
            onTap: () => openDashboardFeed(context, feed),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 2,
                children: [
                  count,
                  Text(
                    feed.page.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: DashboardText.label(context),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
