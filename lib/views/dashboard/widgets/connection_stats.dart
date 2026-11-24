import 'dart:async';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/views/dashboard/layout.dart';
import 'package:fl_clash/views/dashboard/style.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'card.dart';
import 'connections_table.dart';
import 'traffic_beat.dart';

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
        ConnectionsPolling<ConnectionStatsCard>,
        TrafficBeatMixin<ConnectionStatsCard> {
  static const _inset = 8.0;

  late var _connections = connectionCount.value;
  late var _requests = ref.read(requestCountProvider);
  late var _dns = ref.read(dnsQueryCountProvider);
  Timer? _throttle;

  @override
  bool get pollsConnections => false;

  @override
  void initState() {
    super.initState();
    connectionCount.addListener(_connectionsMoved);
    ref.listenManual(requestCountProvider, (_, _) => _eventsCounted());
    ref.listenManual(dnsQueryCountProvider, (_, _) => _eventsCounted());
  }

  void _connectionsMoved() => showOnBeat(_showCounts);

  // Requests and queries move per event, too often to redraw for each.
  void _eventsCounted() {
    if (ref.read(runTimeProvider) != null) {
      showOnBeat(_showCounts);
    } else {
      _throttle ??= Timer(renderThrottleDuration, _showCounts);
    }
  }

  void _showCounts() {
    _throttle?.cancel();
    _throttle = null;
    if (!mounted) {
      return;
    }
    setState(() {
      _connections = connectionCount.value;
      _requests = ref.read(requestCountProvider);
      _dns = ref.read(dnsQueryCountProvider);
    });
  }

  @override
  void dispose() {
    _throttle?.cancel();
    super.dispose();
  }

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
            count: _Count(_connections),
          ),
          _Stat(
            feed: DashboardFeed.requests,
            shape: shape,
            count: _Count(_requests),
          ),
          _Stat(feed: DashboardFeed.dns, shape: shape, count: _Count(_dns)),
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
      child: PressSurface(
        fill: Colors.transparent,
        shape: shape,
        padding: const EdgeInsets.symmetric(vertical: 10),
        childFills: true,
        onPressed: () => openDashboardFeed(context, feed),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 2,
          children: [
            count,
            Text(
              feed.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: DashboardText.label(context),
            ),
          ],
        ),
      ),
    );
  }
}
