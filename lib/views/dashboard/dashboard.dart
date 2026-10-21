import 'dart:math' as math;

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/core/core.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/ui/icons/icons.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'edit.dart';
import 'layout.dart';
import 'style.dart';
import 'widget_registry.dart';
import 'widgets/core_status_button.dart';
import 'widgets/widgets.dart';

const _maxColumnWidth = 440.0;

class DashboardView extends ConsumerStatefulWidget {
  const DashboardView({super.key, this.platform});

  /// The host's platform when null.
  final SupportPlatform? platform;

  @override
  ConsumerState<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends ConsumerState<DashboardView> {
  var _editing = false;
  final _cardKeys = <DashboardWidget, GlobalKey>{};

  void _setEditing(bool editing) {
    setState(() => _editing = editing);
  }

  GlobalKey _cardKeyOf(DashboardWidget widget) =>
      _cardKeys.putIfAbsent(widget, GlobalKey.new);

  @override
  Widget build(BuildContext context) {
    final platform = widget.platform ?? SupportPlatform.currentPlatform;
    final scale = math.max(1.0, MediaQuery.textScalerOf(context).scale(1));
    final editing = _editing;
    final gap = cardSpacingOf(context, ref.watch(viewModeProvider));
    final appLocalizations = context.appLocalizations;
    return CommonScaffold(
      backgroundColor: DashboardColors.of(context).page,
      title: editing
          ? appLocalizations.editDashboard
          : appLocalizations.dashboard,
      backAction: editing ? () => _setEditing(false) : null,
      actions: [if (!editing && coreLib == null) const CoreStatusButton()],
      confirmationAction: editing
          ? IconButtonData(
              glyph: AppGlyphs.check,
              tooltip: appLocalizations.done,
              onPressed: () => _setEditing(false),
            )
          : null,
      iconActions: [
        if (!editing)
          IconButtonData(
            glyph: AppGlyphs.edit,
            tooltip: appLocalizations.editDashboard,
            onPressed: () => _setEditing(true),
          ),
      ],
      // The providers learn a resize a frame late, too late for the cards.
      body: LayoutBuilder(
        builder: (context, constraints) {
          final room = constraints.biggest / scale;
          final layout = DashboardDensity.of(room);
          return DashboardDensityScope(
            density: editing ? DashboardDensity.mobile : layout,
            scale: scale,
            child: layout.isDesktop && !editing
                ? _DesktopDashboard(
                    platform: platform,
                    columns: dashboardColumnsOf(room.width),
                    gap: gap,
                  )
                : _MobileDashboard(
                    platform: platform,
                    gap: gap,
                    editing: editing,
                    cardKeyOf: _cardKeyOf,
                    onDone: () => _setEditing(false),
                  ),
          );
        },
      ),
    );
  }
}

/// Four columns fill the window, the tables taking what the rows above them
/// leave. A window too short for the tables, and every two column one, gets
/// the summary cards instead, so no list scrolls inside a page that scrolls.
class _DesktopDashboard extends ConsumerWidget {
  const _DesktopDashboard({
    required this.platform,
    required this.columns,
    required this.gap,
  });

  final SupportPlatform platform;
  final int columns;
  final double gap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final density = DashboardDensityScope.of(context);
    final compact = density.isCompact;
    final scale = DashboardDensityScope.scaleOf(context);
    final base = EdgeInsetsDirectional.fromSTEB(
      16,
      MediaQuery.paddingOf(context).top,
      24,
      24 + MediaQuery.paddingOf(context).bottom,
    );
    final topHeight = (compact ? 176 : 208) * scale;
    final wifiHeight = wifiModeCardHeight(
      ref.watch(wifiModeSettingProvider.select((state) => state.rules.length)),
      scale,
    );
    final controlHeight = (compact ? 56 : 64) * scale;
    final middleHeight = (compact ? 152 : 176) * scale;
    final tablesHeight = connectionsTableMinHeight(density, scale);
    final summaryHeight = (compact ? 112 : 120) * scale;
    return LayoutBuilder(
      builder: (context, constraints) {
        final room =
            constraints.maxWidth - base.horizontal - gap * (columns - 1);
        final column = math.min(room / columns, _maxColumnWidth * scale);
        final inset = (room - column * columns) / 2;
        final padding = base.copyWith(
          start: base.start + inset,
          end: base.end + inset,
        );
        final saved = ref.watch(
          dashboardStateProvider.select((state) => state.dashboardWidgets),
        );
        final shown = {
          for (final card in saved)
            if (card.platforms.contains(platform)) card,
        };
        final width = column * columns + gap * (columns - 1);
        Widget? row(
          List<(DashboardWidget, int, Widget)> cards, {
          bool alignColumns = true,
        }) {
          final visible = cards
              .where((card) => shown.contains(card.$1))
              .toList();
          if (visible.isEmpty) return null;
          final slots = visible.fold(0, (sum, card) => sum + card.$2);
          final unit =
              (width - gap * ((alignColumns ? slots : visible.length) - 1)) /
              slots;
          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: gap,
            children: [
              for (final (_, span, card) in visible)
                SizedBox(
                  width: unit * span + (alignColumns ? gap * (span - 1) : 0),
                  child: RepaintBoundary(child: card),
                ),
            ],
          );
        }

        final rows = <Widget>[];
        var rowsHeight = padding.vertical;
        void addRow(double height, List<(DashboardWidget, int, Widget)> cards) {
          final content = row(cards);
          if (content == null) return;
          rows.add(SizedBox(height: height, child: content));
          rowsHeight += height + gap;
        }

        const current = (
          DashboardWidget.currentOutbound,
          2,
          CurrentOutboundCard(),
        );
        const speed = [
          (
            DashboardWidget.networkSpeed,
            1,
            SpeedCard(direction: TrafficDirection.upload),
          ),
          (
            DashboardWidget.networkSpeed,
            1,
            SpeedCard(direction: TrafficDirection.download),
          ),
        ];
        const mode = (DashboardWidget.outboundMode, 2, OutboundModeBar());
        const switches = [
          (
            DashboardWidget.systemProxy,
            1,
            NetworkTakeoverTile(TakeoverSwitch.systemProxy),
          ),
          (DashboardWidget.tun, 1, NetworkTakeoverTile(TakeoverSwitch.tun)),
          (DashboardWidget.vpnButton, 2, VpnTile()),
        ];
        const details = [
          (DashboardWidget.intranetIp, 1, IntranetIpCard()),
          (DashboardWidget.profiles, 1, ProfilesCard()),
        ];
        final service = [
          (
            DashboardWidget.serviceStatus,
            shown.contains(DashboardWidget.memoryInfo) ? 1 : 2,
            const ServiceStatusCard(),
          ),
          (DashboardWidget.memoryInfo, 1, const MemoryInfo()),
        ];
        if (columns == 2) {
          addRow(topHeight, [current]);
          addRow(topHeight, speed);
          addRow(controlHeight, [mode]);
          addRow(controlHeight, switches);
        } else {
          addRow(topHeight, [current, ...speed]);
          addRow(controlHeight, [mode, ...switches]);
        }
        addRow(wifiHeight, const [
          (DashboardWidget.wifiMode, 1, WifiModeCard()),
        ]);
        if (columns == 2) {
          addRow(middleHeight, details);
          addRow(middleHeight, service);
        } else {
          addRow(middleHeight, [...details, ...service]);
        }

        final tablesFit =
            columns == 4 && constraints.maxHeight >= rowsHeight + tablesHeight;
        final footer = tablesFit
            ? row(const [
                (DashboardWidget.connectionStats, 3, ConnectionsTableCard()),
                (DashboardWidget.proxyGroups, 2, ProxyGroupsCard()),
              ], alignColumns: false)
            : row(const [
                (DashboardWidget.connectionStats, 1, ConnectionStatsCard()),
                (DashboardWidget.proxyGroups, 1, ProxyGroupsSummaryCard()),
              ]);
        final fills =
            columns == 4 &&
            footer != null &&
            constraints.maxHeight >= rowsHeight + summaryHeight;
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: fills ? constraints.maxHeight : null,
            child: Padding(
              padding: padding,
              child: Column(
                spacing: gap,
                children: [
                  ...rows,
                  if (footer != null)
                    if (fills)
                      Expanded(child: footer)
                    else
                      SizedBox(height: summaryHeight, child: footer),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _MobileDashboard extends ConsumerWidget {
  const _MobileDashboard({
    required this.platform,
    required this.gap,
    required this.editing,
    required this.cardKeyOf,
    required this.onDone,
  });

  final SupportPlatform platform;
  final double gap;
  final bool editing;
  final GlobalKey Function(DashboardWidget widget) cardKeyOf;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final saved = ref.watch(
      dashboardStateProvider.select((state) => state.dashboardWidgets),
    );
    final top = MediaQuery.paddingOf(context).top + 4;
    final bottom = 16 + BottomInsetScope.of(context);
    return CustomScrollView(
      // A viewport per card lays them all out and holds the scroll end still.
      scrollCacheExtent: editing
          ? ScrollCacheExtent.viewport(DashboardWidget.values.length.toDouble())
          : null,
      slivers: [
        SliverLayoutBuilder(
          builder: (context, constraints) {
            final side = dashboardMobileSideOf(constraints.crossAxisExtent);
            final widgets = [
              for (final widget in saved)
                if (widget.platforms.contains(platform)) widget,
            ];
            if (editing) {
              return DashboardEditor(
                platform: platform,
                widgets: widgets,
                cardKeyOf: cardKeyOf,
                padding: EdgeInsets.fromLTRB(side, top, side, bottom),
                gap: gap,
                onDone: onDone,
              );
            }
            return SliverPadding(
              padding: EdgeInsets.fromLTRB(side, top, side, bottom),
              // A lazy list estimates the cards it has not laid out from the
              // ones it has; cards this uneven move the scroll end as it goes.
              sliver: SliverToBoxAdapter(
                child: Column(
                  spacing: gap,
                  children: [
                    for (final widget in widgets)
                      RepaintBoundary(
                        key: cardKeyOf(widget),
                        child: widget.card,
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
