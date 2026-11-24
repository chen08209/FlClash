import 'package:collection/collection.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/mitm.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/ui/icons/icons.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'detail_tabs.dart';
import 'mitm_exchanges.dart';
import 'tracker_detail_parts.dart';
import 'tracker_mitm_host.dart';
import 'tracker_texts.dart';
import 'tracker_timeline.dart';

final _proxyTypes = Expando<Map<String, String>>();

/// What a connection went through, from its app and rule to the node it left
/// by, each hop with what it is.
class TrackerPathSection extends ConsumerWidget {
  final TrackerInfo trackerInfo;
  final bool atTop;

  const TrackerPathSection({
    super.key,
    required this.trackerInfo,
    this.atTop = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final metadata = trackerInfo.metadata;
    final groups = ref.watch(groupsProvider);
    final types = _proxyTypes[groups] ??= {
      for (final group in groups)
        for (final proxy in group.all) proxy.name: proxy.type,
    };
    final hops = trackerInfo.chains.indexed.toList().reversed.toList();
    return generateSection(
      atTop: atTop,
      title: appLocalizations.connectionPath,
      items: [
        if (metadata.process.isNotEmpty || metadata.uid != 0)
          TrackerRailRow(
            first: true,
            title: metadata.process.isNotEmpty
                ? metadata.process
                : '${metadata.uid}',
            subtitle: appLocalizations.process,
            labels: [
              if (metadata.uid != 0)
                RecordLabel(label: appLocalizations.processUid(metadata.uid)),
            ],
          ),
        TrackerRailRow(
          first: metadata.process.isEmpty && metadata.uid == 0,
          last: hops.isEmpty,
          mark: hops.isEmpty ? RailMark.end : RailMark.step,
          title: trackerRuleLine(appLocalizations, trackerInfo),
          subtitle: appLocalizations.rule,
        ),
        for (final (step, (index, name)) in hops.indexed)
          if (groups.getGroup(name) case final group?)
            TrackerRailRow(
              last: step == hops.length - 1,
              mark: step == hops.length - 1 ? RailMark.end : RailMark.step,
              title: name,
              subtitle: appLocalizations.proxyGroup,
              labels: [RecordLabel(label: group.type.name)],
            )
          else
            _ProxyNodeHop(
              name: name,
              testUrl: groups
                  .getGroup(trackerInfo.chains.elementAtOrNull(index + 1) ?? '')
                  ?.testUrl,
              builder: (delay) => TrackerRailRow(
                last: step == hops.length - 1,
                mark: step == hops.length - 1 ? RailMark.end : RailMark.step,
                title: name,
                subtitle: appLocalizations.proxyNode,
                labels: [
                  if (types[name] case final type?) RecordLabel(label: type),
                ],
                trailing: delay == null
                    ? null
                    : Text(
                        '$delay ms',
                        style: TextStyle(
                          color: context.colorScheme.delayColor(delay),
                        ).toTabular,
                      ),
              ),
            ),
      ],
    );
  }
}

class _ProxyNodeHop extends ConsumerWidget {
  final String name;

  /// Its group's, as the proxies page tests it.
  final String? testUrl;
  final Widget Function(int? delay) builder;

  const _ProxyNodeHop({
    required this.name,
    required this.testUrl,
    required this.builder,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final delay = ref.watch(delayProvider(proxyName: name, testUrl: testUrl));
    return builder(delay != null && delay > 0 ? delay : null);
  }
}

const _infoColumnsMinWidth = 760.0;

class TrackerInfoDetailView extends ConsumerWidget {
  final TrackerInfo trackerInfo;
  final bool opensRequests;
  final Widget? header;

  const TrackerInfoDetailView({
    super.key,
    required this.trackerInfo,
    this.opensRequests = false,
    this.header,
  });

  List<Widget> _buildRows(
    List<(String, String)> entries, {
    bool copyable = false,
  }) {
    return [
      for (final (title, value) in entries)
        if (value.isNotEmpty)
          DetailRow.text(title: title, value: value, copyable: copyable),
    ];
  }

  Widget _buildOverview(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final failure = trackerInfo.failure;
    return WidthBuilder(
      builder: (context, width) {
        final columns = width >= _infoColumnsMinWidth;
        final route = [
          TrackerPathSection(trackerInfo: trackerInfo, atTop: failure == null),
          ListHeader(title: appLocalizations.traffic),
          TrackerTrafficSummary(trackerInfo: trackerInfo),
          if (rsFeature)
            MitmHostSection(metadata: trackerInfo.metadata, last: columns),
        ];
        final address = _buildAddress(
          context,
          atTop: columns && failure == null,
        );
        return ListView(
          padding: detailTabPaddingOf(context),
          children: [
            if (failure != null)
              generateSection(
                title: appLocalizations.connectionsFailed,
                atTop: true,
                items: [
                  DetailRow.stacked(
                    leading: GlyphIcon(
                      AppGlyphs.error,
                      color: context.colorScheme.error,
                    ),
                    title: failure.kind.label,
                    value: failure.message,
                    copyable: true,
                  ),
                ],
              ),
            if (columns)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: infoSectionSpacing,
                children: [
                  Expanded(child: Column(children: route)),
                  Expanded(child: address),
                ],
              )
            else ...[
              ...route,
              address,
            ],
          ],
        );
      },
    );
  }

  Widget _buildAddress(BuildContext context, {required bool atTop}) {
    final appLocalizations = context.appLocalizations;
    final metadata = trackerInfo.metadata;
    final endedAt = trackerInfo.endedAt;
    return generateSection(
      title: appLocalizations.address,
      atTop: atTop,
      items: [
        ..._buildRows(copyable: true, [
          (
            appLocalizations.source,
            trackerEndpointText(metadata.sourceIP, metadata.sourcePort),
          ),
          (
            appLocalizations.destination,
            trackerEndpointText(
              metadata.destinationIP,
              metadata.destinationPort,
            ),
          ),
          (appLocalizations.remoteDestination, metadata.remoteDestination),
        ]),
        ..._buildRows(copyable: true, [(appLocalizations.host, metadata.host)]),
        ..._buildRows([
          (
            appLocalizations.destinationGeoIP,
            metadata.destinationGeoIP.join(' '),
          ),
          (appLocalizations.destinationIPASN, metadata.destinationIPASN),
          (appLocalizations.networkType, metadata.network),
          (appLocalizations.dnsMode, metadata.dnsMode?.name ?? ''),
          (appLocalizations.specialProxy, metadata.specialProxy),
          (appLocalizations.specialRules, metadata.specialRules),
          (appLocalizations.creationTime, trackerInfo.start.showFull),
          (appLocalizations.closingTime, endedAt?.showFull ?? ''),
        ]),
      ],
    );
  }

  Widget _buildTimeline(BuildContext context, {required bool capturing}) {
    return ListView(
      padding: detailTabPaddingOf(context),
      children: [
        TrackerTimeline(
          trackerInfo: trackerInfo,
          onOpenRequests: capturing
              ? () => DetailTabs.select(context, 1)
              : null,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final capturing =
        rsFeature &&
        trackerInfo.metadata.mitm &&
        ref.watch(
          patchClashConfigProvider.select(
            (state) => state.mitm.enable && state.mitm.capture,
          ),
        );
    final exchanges = capturing
        ? ref.watch(
            mitmExchangesProvider(
              trackerInfo.id,
            ).select((value) => value.value?.exchanges.length ?? 0),
          )
        : 0;
    return ListTextScope(
      scale: ListTextScale.compact,
      child: DetailTabs(
        header: header,
        initialIndex: opensRequests && capturing ? 1 : 0,
        tabs: [
          (
            appLocalizations.timeline,
            (context) => _buildTimeline(context, capturing: capturing),
          ),
          if (capturing)
            (
              exchanges == 0
                  ? appLocalizations.httpRequests
                  : '${appLocalizations.httpRequests} $exchanges',
              (_) => MitmExchangesView(trackerInfo: trackerInfo),
            ),
          (appLocalizations.connectionInfo, _buildOverview),
        ],
      ),
    );
  }
}
