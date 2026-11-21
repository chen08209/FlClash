import 'dart:async';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/ui/icons/icons.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'tracker_selection.dart';

import 'detail_tabs.dart';
import 'mitm_exchanges.dart';
import 'tracker_detail_parts.dart';
import 'tracker_info_table.dart';

String _endpointText(String ip, String port) {
  if (ip.isEmpty) {
    return '';
  }
  if (port.isEmpty) {
    return ip;
  }
  return ip.contains(':') ? '[$ip]:$port' : '$ip:$port';
}

void showTrackerInfoDetail(
  BuildContext context,
  TrackerInfo trackerInfo,
  String title, {
  bool opensRequests = false,
  TrackerMenuActions? actions,
}) {
  final menuActions = actions ?? TrackerMenuScope.of(context);
  // A connection cleared from the log keeps the state it was last seen in.
  var current = trackerInfo;
  showNestedSheet<void>(
    context,
    detents: const [0.9],
    builder: (context) => Consumer(
      builder: (context, ref, _) {
        current =
            ref.watch(requestsProvider.select((log) => log[trackerInfo.id])) ??
            current;
        return Scaffold(
          menuItems: trackerInfoMenuItems(
            context,
            current,
            actions: menuActions,
            inDetail: true,
          ),
          body: TrackerInfoDetailView(
            trackerInfo: current,
            opensRequests: opensRequests,
            header: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: TrackerInfoHeader(trackerInfo: current),
            ),
          ),
          title: title,
        );
      },
    ),
  );
}

/// What a page lets a connection's menu do to its list.
class TrackerMenuActions {
  final ValueChanged<TrackerInfo>? close;
  final ValueChanged<TrackerInfo>? onlyApp;
  final ValueChanged<TrackerInfo>? hideHost;

  const TrackerMenuActions({this.close, this.onlyApp, this.hideHost});
}

class TrackerMenuScope extends InheritedWidget {
  final TrackerMenuActions actions;

  const TrackerMenuScope({
    super.key,
    required this.actions,
    required super.child,
  });

  static TrackerMenuActions? of(BuildContext context) =>
      context.getInheritedWidgetOfExactType<TrackerMenuScope>()?.actions;

  @override
  bool updateShouldNotify(TrackerMenuScope oldWidget) => false;
}

/// What copying a connection gives: its host, or its address without one.
String trackerCopyText(TrackerInfo trackerInfo) {
  final metadata = trackerInfo.metadata;
  if (metadata.host.isNotEmpty) {
    return metadata.host;
  }
  return _endpointText(metadata.destinationIP, metadata.destinationPort);
}

List<PopupMenuItem> trackerInfoMenuItems(
  BuildContext context,
  TrackerInfo trackerInfo, {
  ValueChanged<TrackerInfo>? onClose,
  TrackerMenuActions? actions,
  bool inDetail = false,
}) {
  final appLocalizations = context.appLocalizations;
  final metadata = trackerInfo.metadata;
  final destination = _endpointText(
    metadata.destinationIP,
    metadata.destinationPort,
  );
  final menuActions = actions ?? TrackerMenuScope.of(context);
  final close = onClose ?? menuActions?.close;
  final onlyApp = menuActions?.onlyApp;
  final hideHost = menuActions?.hideHost;
  // The row that opened the menu can leave the list before its sheet opens.
  final formHost = Navigator.of(context).overlay!.context;
  Future<void> copy(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    dialogs.showBanner(currentAppLocalizations.copySuccess);
  }

  return [
    if (close != null && trackerInfo.isActive)
      PopupMenuItem(
        glyph: AppGlyphs.block,
        label: appLocalizations.closeConnection,
        danger: true,
        onPressed: () => close(trackerInfo),
      ),
    if (metadata.host.isNotEmpty)
      PopupMenuItem(
        glyph: AppGlyphs.copy,
        label: appLocalizations.copyHost,
        section: const PopupMenuSection(),
        onPressed: () => copy(trackerCopyText(trackerInfo)),
      ),
    if (metadata.host.isEmpty && destination.isNotEmpty)
      PopupMenuItem(
        glyph: AppGlyphs.copy,
        label: appLocalizations.copyDestination,
        section: const PopupMenuSection(),
        onPressed: () => copy(trackerCopyText(trackerInfo)),
      ),
    if (onlyApp != null && metadata.process.isNotEmpty)
      PopupMenuItem(
        glyph: AppGlyphs.filter,
        label: appLocalizations.onlyThisApp,
        section: const PopupMenuSection(),
        onPressed: () => onlyApp(trackerInfo),
      ),
    if (hideHost != null && trackerInfo.title.isNotEmpty)
      PopupMenuItem(
        glyph: AppGlyphs.eyeOff,
        label: appLocalizations.hideThisHost,
        section: onlyApp == null || metadata.process.isEmpty
            ? const PopupMenuSection()
            : null,
        onPressed: () => hideHost(trackerInfo),
      ),
    if (rsFeature && metadata.mitm && !inDetail)
      PopupMenuItem(
        glyph: AppGlyphs.eye,
        label: appLocalizations.viewHttp,
        section: const PopupMenuSection(),
        onPressed: () => showTrackerInfoDetail(
          formHost,
          trackerInfo,
          appLocalizations.details(appLocalizations.connection),
          opensRequests: true,
          actions: menuActions,
        ),
      ),
  ];
}

String trackerLifetimeText(TrackerInfo trackerInfo, DateTime now) {
  final closedAt = trackerInfo.closedAt;
  if (closedAt != null) {
    return trackerDurationText(closedAt.difference(trackerInfo.start));
  }
  final elapsed = max(0, now.difference(trackerInfo.start).inSeconds);
  String twoDigits(int value) => value.toString().padLeft(2, '0');
  final seconds = twoDigits(elapsed % 60);
  if (elapsed < 3600) {
    return '${elapsed ~/ 60}:$seconds';
  }
  return '${elapsed ~/ 3600}:${twoDigits(elapsed ~/ 60 % 60)}:$seconds';
}

/// Ticks each second for the open rows of the list under it, and only while
/// one of them is built, its page shows and the app is in the foreground.
class TrackerClock extends StatefulWidget {
  final Widget child;

  const TrackerClock({super.key, required this.child});

  static Listenable? of(BuildContext context) =>
      context.getInheritedWidgetOfExactType<_TrackerClockScope>()?.clock;

  @override
  State<TrackerClock> createState() => _TrackerClockState();
}

class _TrackerClockState extends State<TrackerClock>
    with WidgetsBindingObserver {
  final _clock = _SecondClock();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final state = WidgetsBinding.instance.lifecycleState;
    _clock.resumed = state == null || state == AppLifecycleState.resumed;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _clock.shown = TickerMode.valuesOf(context).enabled;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _clock.resumed = state == AppLifecycleState.resumed;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _clock.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      _TrackerClockScope(clock: _clock, child: widget.child);
}

class _TrackerClockScope extends InheritedWidget {
  final _SecondClock clock;

  const _TrackerClockScope({required this.clock, required super.child});

  @override
  bool updateShouldNotify(_TrackerClockScope oldWidget) => false;
}

class _SecondClock extends ChangeNotifier {
  Timer? _timer;
  var _shown = true;
  var _resumed = true;

  set shown(bool value) => _set(() => _shown = value);

  set resumed(bool value) => _set(() => _resumed = value);

  void _set(VoidCallback change) {
    final was = _timer != null;
    change();
    _update();
    if (!was && _timer != null) {
      notifyListeners();
    }
  }

  @override
  void addListener(VoidCallback listener) {
    super.addListener(listener);
    _update();
  }

  @override
  void removeListener(VoidCallback listener) {
    super.removeListener(listener);
    _update();
  }

  void _update() {
    if (hasListeners && _shown && _resumed) {
      _timer ??= Timer.periodic(
        const Duration(seconds: 1),
        (_) => notifyListeners(),
      );
    } else {
      _timer?.cancel();
      _timer = null;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

class TrackerLifetime extends StatelessWidget {
  final TrackerInfo trackerInfo;
  final Widget Function(String lifetime) builder;

  const TrackerLifetime({
    super.key,
    required this.trackerInfo,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    final clock = trackerInfo.isActive ? TrackerClock.of(context) : null;
    if (clock == null) {
      return builder(trackerLifetimeText(trackerInfo, DateTime.now()));
    }
    return ListenableBuilder(
      listenable: clock,
      builder: (_, _) =>
          builder(trackerLifetimeText(trackerInfo, DateTime.now())),
    );
  }
}

/// How many failed dials to the same target each merged row stands for.
class TrackerRepeats extends InheritedWidget {
  final Map<String, int> counts;

  const TrackerRepeats({super.key, required this.counts, required super.child});

  static int of(BuildContext context, String id) =>
      context
          .dependOnInheritedWidgetOfExactType<TrackerRepeats>()
          ?.counts[id] ??
      1;

  @override
  bool updateShouldNotify(TrackerRepeats oldWidget) =>
      !const MapEquality<String, int>().equals(counts, oldWidget.counts);
}

List<Widget> trackerLabels(BuildContext context, TrackerInfo trackerInfo) {
  final repeats = TrackerRepeats.of(context, trackerInfo.id);
  return [
    if (trackerInfo.failure case final failure?)
      RecordLabel(label: failure.kind.label, tone: RecordTone.error),
    if (repeats > 1) RecordLabel(label: '×$repeats'),
    if (rsFeature && trackerInfo.metadata.mitm)
      const RecordLabel(label: 'MITM'),
  ];
}

String trackerSpeedText(TrackerInfo trackerInfo) {
  final speed =
      (trackerInfo.uploadSpeed ?? 0) + (trackerInfo.downloadSpeed ?? 0);
  return '${speed.traffic.show}/s';
}

class TrackerInfoItem extends StatelessWidget {
  final TrackerInfo trackerInfo;
  final ValueChanged<TrackerInfo>? onClose;
  final String detailTitle;

  /// What the detail opens on, where a memoized row outlives its traffic.
  final ValueGetter<TrackerInfo>? latest;

  const TrackerInfoItem({
    super.key,
    required this.trackerInfo,
    this.onClose,
    required this.detailTitle,
    this.latest,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final metadata = trackerInfo.metadata;
    final secondary = colorScheme.onSurfaceVariant;
    final about = [
      metadata.process,
      trackerInfo.chains.firstOrNull ?? '',
    ].where((text) => text.isNotEmpty).join(' · ');
    final total = (trackerInfo.upload + trackerInfo.download).traffic.show;
    const numbers = [FontFeature.tabularFigures()];
    return ContextMenuRegion(
      menuBuilder: (context) =>
          trackerInfoMenuItems(context, trackerInfo, onClose: onClose),
      child: DecorationListItem(
        leading: TrackerAppWell(trackerInfo: trackerInfo),
        title: Text(
          metadata.host.isNotEmpty
              ? metadata.host
              : _endpointText(metadata.destinationIP, metadata.destinationPort),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyle.subheadline.of(context),
        ),
        subtitle: Row(
          spacing: 4,
          children: [
            Flexible(
              child: TrackerLifetime(
                trackerInfo: trackerInfo,
                builder: (lifetime) => Text(
                  about.isEmpty ? lifetime : '$about · $lifetime',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle.caption1
                      .of(context)
                      .copyWith(color: secondary, fontFeatures: numbers),
                ),
              ),
            ),
            ...trackerLabels(context, trackerInfo),
          ],
        ),
        trailing: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          spacing: 2,
          children: [
            Text(
              trackerInfo.isActive ? trackerSpeedText(trackerInfo) : total,
              style: AppTextStyle.footnote
                  .of(context, emphasized: trackerInfo.isActive)
                  .copyWith(fontFeatures: numbers),
            ),
            if (trackerInfo.isActive)
              Text(
                total,
                style: AppTextStyle.caption2
                    .of(context)
                    .copyWith(color: secondary, fontFeatures: numbers),
              ),
          ],
        ),
        onPressed: () => openTrackerInfo(
          context,
          latest?.call() ?? trackerInfo,
          detailTitle,
        ),
      ),
    );
  }
}

class TrackerAppWell extends StatelessWidget {
  final TrackerInfo trackerInfo;
  final double size;
  final bool showsState;

  const TrackerAppWell({
    super.key,
    required this.trackerInfo,
    this.size = 36,
    this.showsState = true,
  });

  Widget _buildWell(BuildContext context, Widget? icon) {
    final colorScheme = context.colorScheme;
    final process = trackerInfo.metadata.process;
    final initial = (process.isNotEmpty ? process : trackerInfo.title)
        .characters
        .firstOrNull
        ?.toUpperCase();
    return DecoratedBox(
      decoration: ShapeDecoration(
        color: SurfaceLevel.inset.colorOf(colorScheme),
        shape: AppShape.all(AppCorner.fit(size)),
      ),
      child: SizedBox.square(
        dimension: size,
        child: Center(
          child:
              icon ??
              Text(
                initial ?? '',
                style:
                    (size < 24
                            ? AppTextStyle.caption2
                            : AppTextStyle.subheadline)
                        .of(context, emphasized: true)
                        .copyWith(color: colorScheme.onSurfaceVariant),
              ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final process = trackerInfo.metadata.process;
    final well = process.isEmpty
        ? _buildWell(context, null)
        : OwnPackageIcon(
            packageName: process,
            size: size * 2 / 3,
            builder: _buildWell,
          );
    if (!showsState || !trackerInfo.isActive) {
      return well;
    }
    final colorScheme = context.colorScheme;
    final small = size < 24;
    final dot = small ? 6.0 : 10.0;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        well,
        PositionedDirectional(
          end: small ? -1 : -2,
          bottom: small ? -1 : -2,
          child: Container(
            width: dot,
            height: dot,
            decoration: ShapeDecoration(
              color: colorScheme.success,
              shape: CircleBorder(
                side: BorderSide(
                  color: context.raisedSurfaceLevel.colorOf(colorScheme),
                  width: small ? 1 : 2,
                  strokeAlign: BorderSide.strokeAlignOutside,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Adds the host of a connection to the hostnames or excludes it, so that the
/// list can be filled from what the apps really connect to.
class _MitmHostSection extends ConsumerWidget {
  final Metadata metadata;

  const _MitmHostSection({required this.metadata});

  Future<void> _confirm(
    BuildContext context,
    WidgetRef ref, {
    required String title,
    required String tip,
    required Mitm Function(Mitm) update,
  }) async {
    final res = await dialogs.showMessage(
      title: title,
      message: TextSpan(text: tip),
    );
    if (res != true) {
      return;
    }
    ref
        .read(patchClashConfigProvider.notifier)
        .update((state) => state.copyWith(mitm: update(state.mitm)));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final host = metadata.host;
    final (enable, hostname) = ref.watch(
      patchClashConfigProvider.select(
        (state) => (state.mitm.enable, state.mitm.hostname),
      ),
    );
    if (!enable || host.isEmpty || metadata.network.toLowerCase() != 'tcp') {
      return const SizedBox.shrink();
    }
    final appLocalizations = context.appLocalizations;
    final decrypted = metadata.mitm || metadata.mitmRefused;
    final excludes =
        !hostname.contains('-$host') && (decrypted || hostname.contains(host));
    final title = excludes
        ? appLocalizations.mitmExcludeHost
        : appLocalizations.mitmDecryptHost;
    return generateSection(
      title: appLocalizations.mitm,
      items: [
        ListItem(
          title: Text(title),
          onTap: () => _confirm(
            context,
            ref,
            title: title,
            tip: excludes
                ? appLocalizations.mitmExcludeHostTip(host)
                : appLocalizations.mitmDecryptHostTip(host),
            update: (mitm) =>
                excludes ? mitm.excludingHost(host) : mitm.decryptingHost(host),
          ),
        ),
      ],
      footer: metadata.mitmRefused
          ? appLocalizations.mitmClientRefusedCertificate
          : null,
    );
  }
}

final _proxyTypes = Expando<Map<String, String>>();

/// What a connection went through, from its app and rule to the node it left
/// by, each hop with what it is.
class TrackerPathSection extends ConsumerWidget {
  final TrackerInfo trackerInfo;
  final bool compact;

  const TrackerPathSection({
    super.key,
    required this.trackerInfo,
    this.compact = false,
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
    return TrackerDetailSection(
      title: appLocalizations.connectionPath,
      compact: compact,
      padding: compact
          ? const EdgeInsets.symmetric(horizontal: 14, vertical: 12)
          : const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (metadata.process.isNotEmpty || metadata.uid != 0)
            TrackerPathStep(
              compact: compact,
              title: metadata.process.isNotEmpty
                  ? metadata.process
                  : '${metadata.uid}',
              subtitle: [
                appLocalizations.process,
                if (metadata.uid != 0)
                  appLocalizations.processUid(metadata.uid),
              ].join(' · '),
            ),
          TrackerPathStep(
            compact: compact,
            monospace: true,
            last: hops.isEmpty,
            title: trackerInfo.ruleText,
            subtitle: appLocalizations.rule,
          ),
          for (final (step, (index, name)) in hops.indexed)
            if (groups.getGroup(name) case final group?)
              TrackerPathStep(
                compact: compact,
                last: step == hops.length - 1,
                title: name,
                subtitle: '${appLocalizations.proxyGroup} · ${group.type.name}',
              )
            else
              _ProxyNodeHop(
                name: name,
                type: types[name],
                testUrl: groups
                    .getGroup(
                      trackerInfo.chains.elementAtOrNull(index + 1) ?? '',
                    )
                    ?.testUrl,
                builder: (subtitle, delay) => TrackerPathStep(
                  compact: compact,
                  last: step == hops.length - 1,
                  title: name,
                  subtitle: subtitle,
                  trailing: delay == null ? null : '$delay ms',
                  trailingColor: context.colorScheme.delayColor(delay),
                ),
              ),
        ],
      ),
    );
  }
}

class _ProxyNodeHop extends ConsumerWidget {
  final String name;
  final String? type;

  /// Its group's, as the proxies page tests it.
  final String? testUrl;
  final Widget Function(String subtitle, int? delay) builder;

  const _ProxyNodeHop({
    required this.name,
    required this.type,
    required this.testUrl,
    required this.builder,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final delay = ref.watch(delayProvider(proxyName: name, testUrl: testUrl));
    return builder(
      [context.appLocalizations.proxyNode, ?type].join(' · '),
      delay != null && delay > 0 ? delay : null,
    );
  }
}

class TrackerInfoDetailView extends ConsumerWidget {
  final TrackerInfo trackerInfo;
  final bool opensRequests;
  final Widget? header;

  /// Sets the detail a size smaller, for one read beside a table.
  final bool compact;

  const TrackerInfoDetailView({
    super.key,
    required this.trackerInfo,
    this.opensRequests = false,
    this.header,
    this.compact = false,
  });

  Widget _buildOverview(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final colorScheme = context.colorScheme;
    final metadata = trackerInfo.metadata;
    final closedAt = trackerInfo.closedAt;
    final active = trackerInfo.isActive;
    List<Widget> rows(List<(String, String)> entries, {bool mono = false}) => [
      for (final (title, value) in entries)
        if (value.isNotEmpty)
          TrackerDetailRow(
            title: title,
            value: value,
            monospace: mono,
            compact: compact,
          ),
    ];
    final groupPadding = compact
        ? const EdgeInsets.symmetric(vertical: 4)
        : EdgeInsets.zero;
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16).copyWith(
        bottom: 20 + context.bottomInset,
        top: context.contentTopPadding,
      ),
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 14,
          children: [
            ?header,
            if (trackerInfo.failure case final failure?)
              TrackerDetailSection(
                title: appLocalizations.connectionsFailed,
                compact: compact,
                padding: groupPadding,
                child: TrackerDetailRow(
                  title: failure.kind.label,
                  value: failure.message,
                  compact: compact,
                ),
              ),
            TrackerPathSection(trackerInfo: trackerInfo, compact: compact),
            TrackerDetailSection(
              title: appLocalizations.traffic,
              compact: compact,
              padding: compact
                  ? const EdgeInsets.symmetric(horizontal: 14, vertical: 12)
                  : const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 12,
                children: [
                  Expanded(
                    child: TrackerTrafficColumn(
                      label: appLocalizations.download,
                      mark: colorScheme.primary,
                      total: trackerInfo.download,
                      speed: active ? trackerInfo.downloadSpeed ?? 0 : null,
                      compact: compact,
                    ),
                  ),
                  Expanded(
                    child: TrackerTrafficColumn(
                      label: appLocalizations.upload,
                      mark: colorScheme.primary.withValues(alpha: 0.45),
                      total: trackerInfo.upload,
                      speed: active ? trackerInfo.uploadSpeed ?? 0 : null,
                      compact: compact,
                    ),
                  ),
                ],
              ),
            ),
            TrackerDetailSection(
              title: appLocalizations.address,
              compact: compact,
              padding: groupPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ...rows(mono: true, [
                    (
                      appLocalizations.source,
                      _endpointText(metadata.sourceIP, metadata.sourcePort),
                    ),
                    (
                      appLocalizations.destination,
                      _endpointText(
                        metadata.destinationIP,
                        metadata.destinationPort,
                      ),
                    ),
                    (
                      appLocalizations.remoteDestination,
                      metadata.remoteDestination,
                    ),
                  ]),
                  ...rows([
                    (appLocalizations.host, metadata.host),
                    (
                      appLocalizations.destinationGeoIP,
                      metadata.destinationGeoIP.join(' '),
                    ),
                    (
                      appLocalizations.destinationIPASN,
                      metadata.destinationIPASN,
                    ),
                    (appLocalizations.networkType, metadata.network),
                    (appLocalizations.dnsMode, metadata.dnsMode?.name ?? ''),
                    (appLocalizations.specialProxy, metadata.specialProxy),
                    (appLocalizations.specialRules, metadata.specialRules),
                    (appLocalizations.creationTime, trackerInfo.start.showFull),
                    (appLocalizations.closingTime, closedAt?.showFull ?? ''),
                  ]),
                ],
              ),
            ),
            if (rsFeature) _MitmHostSection(metadata: metadata),
          ],
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
    return DetailTabs(
      initialIndex: opensRequests && capturing ? 1 : 0,
      tabs: [
        (appLocalizations.overview, _buildOverview),
        if (capturing)
          (
            appLocalizations.httpRequests,
            (_) => MitmExchangesView(trackerInfo: trackerInfo),
          ),
      ],
    );
  }
}
