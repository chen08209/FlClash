import 'dart:math';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/common/service_probe.dart';
import 'package:fl_clash/features/features.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/outbound_ip.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/providers/routed_probe.dart';
import 'package:fl_clash/providers/service_status.dart';
import 'package:fl_clash/ui/icons/icons.dart';
import 'package:fl_clash/views/dashboard/probe_start_hold.dart';
import 'package:fl_clash/views/dashboard/layout.dart';
import 'package:fl_clash/views/dashboard/style.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:material_ui/material_ui.dart';

import 'card.dart';

String _statusLabel(BuildContext context, ServiceProbeStatus status) {
  final localizations = context.appLocalizations;
  return switch (status) {
    ServiceProbeStatus.available => localizations.serviceAvailable,
    ServiceProbeStatus.restricted => localizations.serviceRestricted,
    ServiceProbeStatus.unavailable => localizations.serviceUnavailable,
    ServiceProbeStatus.disallowedIsp => localizations.serviceDisallowedIsp,
    ServiceProbeStatus.blocked => localizations.serviceBlocked,
    ServiceProbeStatus.unsupportedRegion =>
      localizations.serviceUnsupportedRegion,
    ServiceProbeStatus.originalsOnly => localizations.serviceOriginalsOnly,
    ServiceProbeStatus.comingSoon => localizations.serviceComingSoon,
    ServiceProbeStatus.timeout => localizations.timeout,
    ServiceProbeStatus.failed => localizations.serviceFailed,
  };
}

typedef _StatusColors = ({Color color, Color container, Color onContainer});

_StatusColors _statusColors(BuildContext context, ServiceProbeStatus status) {
  final colorScheme = context.colorScheme;
  return switch (status) {
    ServiceProbeStatus.available => (
      color: colorScheme.success,
      container: colorScheme.successContainer,
      onContainer: colorScheme.onSuccessContainer,
    ),
    ServiceProbeStatus.restricted ||
    ServiceProbeStatus.disallowedIsp ||
    ServiceProbeStatus.blocked ||
    ServiceProbeStatus.unsupportedRegion ||
    ServiceProbeStatus.originalsOnly ||
    ServiceProbeStatus.comingSoon => (
      color: colorScheme.warning,
      container: colorScheme.warningContainer,
      onContainer: colorScheme.onWarningContainer,
    ),
    ServiceProbeStatus.unavailable ||
    ServiceProbeStatus.timeout ||
    ServiceProbeStatus.failed => (
      color: colorScheme.error,
      container: colorScheme.errorContainer,
      onContainer: colorScheme.onErrorContainer,
    ),
  };
}

Color _statusColor(BuildContext context, ServiceProbeStatus status) =>
    _statusColors(context, status).color;

_StatusColors _idleColors(BuildContext context) => (
  color: context.colorScheme.onSurfaceVariant,
  container: context.raisedSurfaceLevel.colorOf(context.colorScheme),
  onContainer: context.colorScheme.onSurfaceVariant,
);

(String, _StatusColors) _statusOf(
  BuildContext context,
  ServiceCheck? check,
  ProbePhase phase,
) {
  final localizations = context.appLocalizations;
  if (phase == ProbePhase.probing) {
    return (localizations.loading, _idleColors(context));
  }
  if (check != null) {
    return (
      _statusLabel(context, check.status),
      _statusColors(context, check.status),
    );
  }
  if (phase == ProbePhase.failed) {
    return (
      _statusLabel(context, ServiceProbeStatus.failed),
      _statusColors(context, ServiceProbeStatus.failed),
    );
  }
  return (localizations.servicePending, _idleColors(context));
}

// The Core checks this many services at a time (serviceCheckConcurrency), so
// a route change re-checks the whole card in one wave.
const _shownServiceCount = 4;

/// A service as the card shows it: a failure held through a start reads as
/// still checking, without the result it replaced.
class _ServiceView {
  _ServiceView(this.target, ProbeEntry<ServiceCheck> entry, this.phase)
    : check = phase == entry.phase ? entry.value : null;

  final ServiceTarget target;
  final ProbePhase phase;
  final ServiceCheck? check;

  bool get loading => phase == ProbePhase.probing && check == null;

  bool get abnormal => switch (check) {
    final check? => check.status != ServiceProbeStatus.available,
    null => phase == ProbePhase.failed,
  };

  (String, Color) statusOf(BuildContext context) => switch (check) {
    ServiceCheck(status: ServiceProbeStatus.available, :final delay) => (
      delay != null
          ? '$delay ms'
          : _statusLabel(context, ServiceProbeStatus.available),
      context.colorScheme.onSurfaceVariant,
    ),
    final ServiceCheck check => (
      _statusLabel(context, check.status),
      _statusColor(context, check.status),
    ),
    null => switch (_statusOf(context, null, phase)) {
      (final label, final colors) => (label, colors.color),
    },
  };

  Color? dotOf(BuildContext context) => switch (check) {
    final check? => _statusColor(context, check.status),
    null when phase == ProbePhase.failed => context.colorScheme.error,
    null => null,
  };
}

class ServiceStatusCard extends ConsumerStatefulWidget {
  const ServiceStatusCard({super.key});

  @override
  ConsumerState<ServiceStatusCard> createState() => _ServiceStatusCardState();
}

class _ServiceStatusCardState extends ConsumerState<ServiceStatusCard>
    with ProbeStartHold<ServiceStatusCard> {
  late final ServiceStatus _services;
  Set<ServiceTarget> _shown = const {};
  Set<ServiceTarget> _watched = const {};
  var _syncScheduled = false;

  @override
  void initState() {
    super.initState();
    _services = ref.read(serviceStatusProvider.notifier);
  }

  @override
  void dispose() {
    for (final target in _watched) {
      _services.unwatch(target);
    }
    super.dispose();
  }

  void _watchShown(Set<ServiceTarget> shown) {
    if (setEquals(shown, _shown)) return;
    _shown = shown;
    if (_syncScheduled) return;
    _syncScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncScheduled = false;
      if (!mounted) return;
      final shown = _shown;
      for (final target in shown.difference(_watched)) {
        _services.watch(target);
      }
      for (final target in _watched.difference(shown)) {
        _services.unwatch(target);
      }
      _watched = shown;
    });
  }

  Future<void> _openSheet() => showServiceStatusSheet(context);

  @override
  Widget build(BuildContext context) {
    final density = DashboardDensityScope.of(context);
    final mobile = !density.isDesktop;
    final appLocalizations = context.appLocalizations;
    final shown = ref
        .watch(enabledServiceTargetsProvider)
        .take(_shownServiceCount)
        .toList();
    _watchShown(shown.toSet());
    final state = ref.watch(serviceStatusProvider);
    final services = [
      for (final target in shown)
        _ServiceView(
          target,
          state.entryOf(target),
          shownPhase(state.entryOf(target)),
        ),
    ];
    final problems = services.where((service) => service.abnormal).length;
    final verdict = problems > 0
        ? DashboardChip(
            label: appLocalizations.serviceAbnormalCount(problems),
            tone: DashboardChipTone.warn,
          )
        : services.every((service) => service.check != null)
        ? DashboardChip(
            label: appLocalizations.serviceAllAvailable,
            tone: DashboardChipTone.ok,
          )
        : null;
    final scale = DashboardDensityScope.scaleOf(context);
    final grid = _ServiceGrid(
      services: services,
      fill: !mobile,
      cellHeight:
          (mobile
              ? 50
              : density.isCompact
              ? 40
              : 46) *
          scale,
      gap: density.isCompact ? 6 : 8,
    );
    return DashboardCard(
      semanticLabel: appLocalizations.serviceStatus,
      onTap: mobile ? _openSheet : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: mobile ? MainAxisSize.min : MainAxisSize.max,
        children: [
          DashboardCardHeader(
            glyph: AppGlyphs.verified,
            title: appLocalizations.serviceStatus,
            chevron: mobile,
            trailing: [
              ?verdict,
              if (!mobile)
                Transform.translate(
                  offset: const Offset(8, 0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _CheckAllButton(
                        loading: shown.any(state.isLoading),
                        onPressed: () => _services.refresh(shown),
                      ),
                      DashboardIconButton(
                        glyph: AppGlyphs.chevronForward,
                        tooltip: appLocalizations.serviceStatus,
                        onPressed: _openSheet,
                      ),
                    ],
                  ),
                ),
            ],
          ),
          if (mobile) const SizedBox(height: 12) else const Spacer(),
          grid,
        ],
      ),
    );
  }
}

class _ServiceGrid extends StatelessWidget {
  const _ServiceGrid({
    required this.services,
    required this.fill,
    required this.cellHeight,
    required this.gap,
  });

  static const _columns = 2;

  final List<_ServiceView> services;

  /// Keeps the two rows four services take on a card of fixed height, the
  /// cells of a single row growing into tiles.
  final bool fill;
  final double cellHeight;
  final double gap;

  @override
  Widget build(BuildContext context) {
    if (fill && services.length <= _columns) {
      return SizedBox(
        height: cellHeight * 2 + gap,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: gap,
          children: [
            for (final service in services)
              Expanded(
                child: _ServiceCell(
                  service: service,
                  height: cellHeight,
                  tile: true,
                ),
              ),
          ],
        ),
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: gap,
      children: [
        for (var start = 0; start < services.length; start += _columns)
          Row(
            spacing: gap,
            children: [
              for (final service in services.skip(start).take(_columns))
                Expanded(
                  child: _ServiceCell(service: service, height: cellHeight),
                ),
            ],
          ),
      ],
    );
  }
}

class _ServiceCell extends StatelessWidget {
  const _ServiceCell({
    required this.service,
    required this.height,
    this.tile = false,
  });

  static const _inset = 7.0;

  // Lines the text up with the 12 a cell keeps clear at its end.
  static const _tileText = EdgeInsetsDirectional.fromSTEB(5, 0, 5, 3);

  final _ServiceView service;
  final double height;

  final bool tile;

  @override
  Widget build(BuildContext context) {
    final (label, color) = service.statusOf(context);
    final status = AppTextStyle.caption1
        .of(context, emphasized: true)
        .toTabular
        .copyWith(color: color);
    final badge = _ServiceBadge(
      target: service.target,
      size: height - _inset * 2,
      radius: DashboardCorner.tab - _inset,
      color: DashboardColors.of(context).card,
      ink: context.colorScheme.onSurfaceVariant,
      dot: service.dotOf(context),
    );
    final text = ExcludeSemantics(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            service.target.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyle.footnote.of(context, emphasized: true),
          ),
          if (service.loading)
            SkeletonText(width: 44, style: status)
          else
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: status,
            ),
        ],
      ),
    );
    return Semantics(
      label: service.target.label,
      value: label,
      liveRegion: true,
      child: tile
          ? DashboardBlock(
              radius: DashboardCorner.tab,
              padding: const EdgeInsets.all(_inset),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  badge,
                  Padding(padding: _tileText, child: text),
                ],
              ),
            )
          : SizedBox(
              height: height,
              child: DashboardBlock(
                radius: DashboardCorner.tab,
                padding: const EdgeInsetsDirectional.fromSTEB(_inset, 0, 12, 0),
                child: Row(
                  spacing: 8,
                  children: [
                    badge,
                    Expanded(child: text),
                  ],
                ),
              ),
            ),
    );
  }
}

class _CheckAllButton extends StatelessWidget {
  const _CheckAllButton({required this.loading, required this.onPressed});

  final bool loading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const SizedBox.square(
        dimension: 32,
        child: Center(child: CommonCircleLoading(size: 18)),
      );
    }
    return DashboardIconButton(
      glyph: AppGlyphs.bolt,
      tooltip: context.appLocalizations.serviceCheckAll,
      onPressed: onPressed,
    );
  }
}

mixin _NodeAddressWatch<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  late final OutboundIpProbe _ips;
  String? _node;

  @override
  void initState() {
    super.initState();
    _ips = ref.read(outboundIpProbeProvider.notifier);
  }

  @override
  void dispose() {
    _showNode(null);
    super.dispose();
  }

  void _showNode(String? node) {
    final previous = _node;
    if (node == previous) return;
    _node = node;
    if (node != null) _ips.watch(node);
    if (previous != null) _ips.unwatch(previous);
  }
}

class _ServiceTitle extends StatelessWidget {
  const _ServiceTitle({required this.name, required this.status});

  static const _statusShare = 0.6;

  final String name;
  final Widget status;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      // A Flexible status would cap the name at its own share even when the
      // status is short, so the status takes what it needs up to a limit.
      builder: (context, constraints) => Row(
        spacing: 8,
        children: [
          Flexible(
            child: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: constraints.maxWidth * _statusShare,
            ),
            child: status,
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, required this.colors});

  final String label;
  final _StatusColors colors;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: ShapeDecoration(
        color: colors.container,
        shape: AppShape.full,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyle.caption1
              .of(context, emphasized: true)
              .copyWith(color: colors.onContainer),
        ),
      ),
    );
  }
}

/// Node names tend to carry their own flag emoji, so a service shows where
/// its traffic leaves from as a flag and the address instead, and falls
/// back to the node only when the address could not be looked up.
class _OutboundIpLine extends StatelessWidget {
  const _OutboundIpLine({
    required this.ip,
    required this.region,
    required this.pending,
    required this.fallback,
    required this.style,
  });

  final IpInfo? ip;
  final String? region;
  final bool pending;
  final String? fallback;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final ip = this.ip;
    final fallback = this.fallback;
    final flag = ip?.countryCode ?? region;
    if (flag == null && ip == null && !pending && fallback == null) {
      return _NoValue(style: style);
    }
    final line = Row(
      spacing: 4,
      children: [
        if (flag != null)
          Text(
            flag.countryFlagEmoji,
            style: style?.copyWith(fontFamily: FontFamily.twEmoji.value),
          ),
        if (ip != null)
          Flexible(
            child: IpQualityText(ip: ip.ip, style: style),
          )
        else if (pending)
          Flexible(child: SkeletonText(width: 88, style: style))
        else if (fallback != null)
          Flexible(
            child: Text(
              fallback,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: style,
            ),
          ),
      ],
    );
    if (ip == null) return line;
    return Tooltip(
      message: context.appLocalizations.outboundIp,
      child: InkWell(
        onTap: () => showIpQualitySheet(context, ip: ip.ip),
        customBorder: AppShape.xs,
        hoverColor: Colors.transparent,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: line,
      ),
    );
  }
}

class _NoValue extends StatelessWidget {
  const _NoValue({this.style});

  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Text(
        '—',
        style: style?.copyWith(color: context.colorScheme.onSurfaceVariant),
      ),
    );
  }
}

/// The status dot sits in a notch cleared from the tile rather than on a ring
/// painted in the surface colour, which differs between the card and the rows.
class _ServiceBadge extends StatelessWidget {
  const _ServiceBadge({
    required this.target,
    required this.size,
    this.radius,
    this.dot,
    this.enabled = true,
    this.color,
    this.ink,
  });

  static const _glyphShare = 0.56;

  final ServiceTarget target;
  final double size;
  final double? radius;
  final Color? dot;
  final bool enabled;
  final Color? color;
  final Color? ink;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return CustomPaint(
      size: Size.square(size),
      painter: _BadgePainter(
        color: color ?? context.raisedSurfaceLevel.colorOf(colorScheme),
        radius: radius ?? AppCorner.fit(size),
        dot: dot,
        dotRadius: max(size / 10, 4),
        ring: max(size / 16, 2),
      ),
      child: SizedBox.square(
        dimension: size,
        child: Center(
          child: SvgPicture.asset(
            'assets/images/services/${target.icon}.svg',
            width: size * _glyphShare,
            height: size * _glyphShare,
            excludeFromSemantics: true,
            theme: SvgTheme(
              currentColor:
                  ink ??
                  (enabled
                      ? colorScheme.onSurfaceVariant
                      : colorScheme.onSurfaceVariant.opacity38),
            ),
          ),
        ),
      ),
    );
  }
}

class _BadgePainter extends CustomPainter {
  const _BadgePainter({
    required this.color,
    required this.radius,
    required this.dot,
    required this.dotRadius,
    required this.ring,
  });

  final Color color;
  final double radius;
  final Color? dot;
  final double dotRadius;
  final double ring;

  @override
  void paint(Canvas canvas, Size size) {
    final bounds = Offset.zero & size;
    final tile = RSuperellipse.fromRectAndRadius(
      bounds,
      Radius.circular(radius),
    );
    final dot = this.dot;
    if (dot == null) {
      canvas.drawRSuperellipse(tile, Paint()..color = color);
      return;
    }
    final center = size.bottomRight(Offset(-dotRadius, -dotRadius));
    final gap = Path()
      ..addOval(Rect.fromCircle(center: center, radius: dotRadius + ring));
    canvas
      ..drawPath(
        Path.combine(
          PathOperation.difference,
          Path()..addRSuperellipse(tile),
          gap,
        ),
        Paint()..color = color,
      )
      ..drawCircle(center, dotRadius, Paint()..color = dot);
  }

  @override
  bool shouldRepaint(_BadgePainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.radius != radius ||
      oldDelegate.dot != dot ||
      oldDelegate.dotRadius != dotRadius ||
      oldDelegate.ring != ring;
}

Future<void> showServiceStatusSheet(BuildContext context) {
  return showSheet<void>(
    context: context,
    props: nestedPagedSheetProps,
    builder: (_) =>
        NestedPagedSheet(builder: (_) => const ServiceStatusSheet()),
  );
}

/// Every enabled service, read from the cache and checked only on request.
class ServiceStatusSheet extends ConsumerWidget {
  const ServiceStatusSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final targets = ref.watch(enabledServiceTargetsProvider);
    final state = ref.watch(serviceStatusProvider);
    final services = ref.read(serviceStatusProvider.notifier);
    final localizations = context.appLocalizations;
    return CommonScaffold(
      title: localizations.serviceStatus,
      iconActions: [
        IconButtonData(
          glyph: AppGlyphs.bolt,
          tooltip: localizations.serviceCheckAll,
          isLoading: targets.any(state.isLoading),
          onPressed: () => services.refresh(targets),
        ),
        IconButtonData(
          glyph: AppGlyphs.sliders,
          tooltip: localizations.serviceManage,
          onPressed: () => Navigator.of(
            context,
          ).push(PagedSheetRoute(builder: (_) => const ServiceManageView())),
        ),
      ],
      body: CustomScrollView(
        shrinkWrap: true,
        slivers: [
          SliverToBoxAdapter(
            child: SizedBox(height: context.contentTopPadding),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            sliver: SliverList.builder(
              itemCount: targets.length,
              itemBuilder: (context, index) {
                final target = targets[index];
                return ItemPositionProvider(
                  position: ItemPosition.get(index, targets.length),
                  child: _ServiceRow(
                    target: target,
                    entry: state.entryOf(target),
                    onCheck: () => services.refresh([target]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ServiceManageView extends ConsumerWidget {
  const ServiceManageView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final targets = ref.watch(serviceTargetsProvider);
    final enabled = ref.watch(enabledServiceTargetsProvider);
    final settings = ref.read(appSettingProvider.notifier);

    void reorder(int oldIndex, int newIndex) {
      settings.update(
        (state) => state.copyWith(
          serviceOrder: [
            for (final target in targets.copyAndReorder(oldIndex, newIndex))
              target.id,
          ],
        ),
      );
    }

    void toggle(ServiceTarget target, bool value) {
      settings.update((state) {
        final disabled = {...state.disabledServices};
        if (value) {
          disabled.remove(target.id);
        } else {
          disabled.add(target.id);
        }
        return state.copyWith(disabledServices: disabled.toList());
      });
    }

    final shown = enabled.take(_shownServiceCount).toSet();

    Widget itemAt(int index) {
      final target = targets[index];
      final isEnabled = enabled.contains(target);
      final locked = isEnabled && enabled.length == 1;
      return _ServiceManageItem(
        key: ValueKey(target),
        target: target,
        index: index,
        position: ItemPosition.get(index, targets.length),
        enabled: isEnabled,
        shown: shown.contains(target),
        onChanged: locked ? null : (value) => toggle(target, value),
      );
    }

    return CommonScaffold(
      title: context.appLocalizations.serviceManage,
      body: CustomScrollView(
        shrinkWrap: true,
        slivers: [
          SliverToBoxAdapter(
            child: SizedBox(height: context.contentTopPadding),
          ),
          SliverReorderableList(
            itemBuilder: (_, index) => itemAt(index),
            itemCount: targets.length,
            proxyDecorator: (child, index, animation) =>
                commonProxyDecorator(itemAt(index), index, animation),
            onReorderItem: reorder,
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
        ],
      ),
    );
  }
}

const _rowBadgeSize = 40.0;
const _rowBadgeInset = 12.0;
// Concentric with the corners DecorationListItem gives the ends of a run.
const _rowBadgeRadius = AppCorner.xl - _rowBadgeInset;

class _ServiceManageItem extends StatelessWidget {
  const _ServiceManageItem({
    super.key,
    required this.target,
    required this.index,
    required this.position,
    required this.enabled,
    required this.shown,
    required this.onChanged,
  });

  final ServiceTarget target;
  final int index;
  final ItemPosition position;
  final bool enabled;
  final bool shown;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final onChanged = this.onChanged;
    return ReorderableDelayedDragStartListener(
      index: index,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ItemPositionProvider(
          position: position,
          child: DecorationListItem(
            minVerticalPadding: _rowBadgeInset,
            contentPadding: const EdgeInsets.only(
              left: _rowBadgeInset,
              right: 16,
            ),
            onPressed: onChanged == null ? null : () => onChanged(!enabled),
            leading: _ServiceBadge(
              target: target,
              size: _rowBadgeSize,
              radius: _rowBadgeRadius,
              enabled: enabled,
            ),
            title: Text(
              target.label,
              style: enabled
                  ? null
                  : TextStyle(color: context.colorScheme.onSurfaceVariant),
            ),
            subtitle: shown
                ? Text(context.appLocalizations.serviceShownOnDashboard)
                : null,
            trailing: Switch(value: enabled, onChanged: onChanged),
          ),
        ),
      ),
    );
  }
}

class _ServiceRow extends ConsumerStatefulWidget {
  const _ServiceRow({
    required this.target,
    required this.entry,
    required this.onCheck,
  });

  final ServiceTarget target;
  final ProbeEntry<ServiceCheck> entry;
  final VoidCallback onCheck;

  @override
  ConsumerState<_ServiceRow> createState() => _ServiceRowState();
}

class _ServiceRowState extends ConsumerState<_ServiceRow>
    with _NodeAddressWatch<_ServiceRow> {
  @override
  Widget build(BuildContext context) {
    final localizations = context.appLocalizations;
    final secondary = AppTextStyle.footnote
        .of(context)
        .copyWith(color: context.colorScheme.onSurfaceVariant);
    final target = widget.target;
    final entry = widget.entry;
    final check = entry.value;
    final loading = entry.isLoading;
    final node = check?.node;
    _showNode(node);
    final ipEntry = node != null
        ? ref.watch(
            outboundIpProbeProvider.select((state) => state.entryOf(node)),
          )
        : null;
    final outboundIp = ipEntry?.value;
    final (label, colors) = _statusOf(context, check, entry.phase);
    return DecorationListItem(
      minVerticalPadding: _rowBadgeInset,
      contentPadding: const EdgeInsets.only(left: _rowBadgeInset, right: 4),
      onPressed: loading ? null : widget.onCheck,
      leading: _ServiceBadge(
        target: target,
        size: _rowBadgeSize,
        radius: _rowBadgeRadius,
        dot: loading
            ? context.colorScheme.onSurfaceVariant
            : check != null || entry.phase == ProbePhase.failed
            ? colors.color
            : null,
      ),
      title: _ServiceTitle(
        name: target.label,
        status: _StatusPill(label: label, colors: colors),
      ),
      // A one-line tile is shorter than a two-line one, so the line is always
      // there and a check does not resize the row.
      subtitle: loading
          ? SkeletonText(width: 96, style: secondary)
          : _OutboundIpLine(
              ip: outboundIp,
              region: check?.region,
              pending:
                  ipEntry != null &&
                  ipEntry.phase != ProbePhase.failed &&
                  outboundIp == null,
              fallback: node,
              style: secondary,
            ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 4,
        children: [
          _ServiceRowTrailing(check: check, style: secondary),
          IconButton(
            tooltip: localizations.serviceCheck,
            onPressed: loading ? null : widget.onCheck,
            icon: const GlyphIcon(AppGlyphs.refresh),
          ),
        ],
      ),
    );
  }
}

class _ServiceRowTrailing extends StatelessWidget {
  const _ServiceRowTrailing({required this.check, this.style});

  final ServiceCheck? check;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final delay = check?.delay;
    final checkedAt = check?.checkedAt;
    if (delay == null && checkedAt == null) {
      return const SizedBox.shrink();
    }
    final numeric = style?.copyWith(
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    final column = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (delay != null)
          Text(
            '$delay ms',
            style: AppTextStyle.footnote
                .of(context, emphasized: true)
                .toTabular
                .copyWith(color: context.colorScheme.onSurface),
          ),
        if (checkedAt != null)
          Text(
            checkedAt.showTime.trim(),
            style: numeric?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
      ],
    );
    if (checkedAt == null) return column;
    return Tooltip(
      message: context.appLocalizations.serviceCheckedAt(checkedAt.showFull),
      child: column,
    );
  }
}
