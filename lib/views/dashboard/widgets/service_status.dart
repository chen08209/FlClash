import 'dart:math';
import 'dart:ui';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/common/service_probe.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/features/features.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/outbound_ip.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/providers/routed_probe.dart';
import 'package:fl_clash/providers/service_status.dart';
import 'package:fl_clash/views/dashboard/probe_start_hold.dart';
import 'package:fl_clash/views/dashboard/widget_metrics.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:material_ui/material_ui.dart';

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

Color _statusColor(BuildContext context, ServiceProbeStatus status) {
  return switch (status) {
    ServiceProbeStatus.available => context.colorScheme.success,
    ServiceProbeStatus.restricted ||
    ServiceProbeStatus.disallowedIsp ||
    ServiceProbeStatus.blocked ||
    ServiceProbeStatus.unsupportedRegion ||
    ServiceProbeStatus.originalsOnly ||
    ServiceProbeStatus.comingSoon => context.colorScheme.warning,
    ServiceProbeStatus.unavailable ||
    ServiceProbeStatus.timeout ||
    ServiceProbeStatus.failed => context.colorScheme.error,
  };
}

(String, Color) _statusOf(
  BuildContext context,
  ServiceCheck? check,
  ProbePhase phase,
) {
  final localizations = context.appLocalizations;
  if (phase == ProbePhase.probing) {
    return (localizations.loading, context.colorScheme.onSurfaceVariant);
  }
  if (check != null) {
    return (
      _statusLabel(context, check.status),
      _statusColor(context, check.status),
    );
  }
  if (phase == ProbePhase.failed) {
    return (
      _statusLabel(context, ServiceProbeStatus.failed),
      _statusColor(context, ServiceProbeStatus.failed),
    );
  }
  return (localizations.servicePending, context.colorScheme.onSurfaceVariant);
}

class ServiceStatusCard extends ConsumerStatefulWidget {
  const ServiceStatusCard({super.key});

  @override
  ConsumerState<ServiceStatusCard> createState() => _ServiceStatusCardState();
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

class _ServiceStatusCardState extends ConsumerState<ServiceStatusCard>
    with
        ProbeStartHold<ServiceStatusCard>,
        _NodeAddressWatch<ServiceStatusCard> {
  static const _gap = 12.0;
  // The badge sits the same distance from the start, top and bottom edges. At
  // this inset a concentric radius would square it off, so it takes the card's
  // own proportion of radius to height instead.
  static const _badgeInsetShare = 0.7;

  late final PageController _controller;
  late final ServiceStatus _services;
  ServiceTarget? _shown;
  bool _scrolling = false;

  static ServiceTarget _savedIn(List<ServiceTarget> targets, String? id) {
    final saved = id == null ? null : ServiceTarget.byId(id);
    return saved != null && targets.contains(saved) ? saved : targets.first;
  }

  ServiceTarget _targetIn(List<ServiceTarget> targets) =>
      _savedIn(targets, ref.read(appSettingProvider).currentService);

  void _select(ServiceTarget target) {
    ref
        .read(appSettingProvider.notifier)
        .update((state) => state.copyWith(currentService: target.id));
  }

  @override
  void initState() {
    super.initState();
    _services = ref.read(serviceStatusProvider.notifier);
    final targets = ref.read(enabledServiceTargetsProvider);
    _controller = PageController(
      initialPage: targets.indexOf(_targetIn(targets)),
    );
  }

  @override
  void dispose() {
    _show(null);
    _controller.dispose();
    super.dispose();
  }

  void _show(ServiceTarget? target) {
    final previous = _shown;
    if (target == previous) return;
    _shown = target;
    if (target != null) _services.watch(target);
    if (previous != null) _services.unwatch(previous);
  }

  void _onTargetChanged(List<ServiceTarget> targets, int index) {
    final target = targets[index];
    if (target == _targetIn(targets)) return;
    _select(target);
  }

  /// A swipe or an animated jump passes through the services in between; only
  /// the one the pager settles on is worth a check.
  bool _onPagerScroll(ScrollNotification notification) {
    if (notification.depth != 0) return false;
    if (notification is ScrollStartNotification) {
      _scrolling = true;
    } else if (notification is ScrollEndNotification) {
      _show(_targetIn(ref.read(enabledServiceTargetsProvider)));
      if (mounted) setState(() => _scrolling = false);
    }
    return false;
  }

  void _onTargetsChanged(
    List<ServiceTarget>? previous,
    List<ServiceTarget> next,
  ) {
    final current = _targetIn(previous ?? next);
    final kept = next.contains(current);
    final index = kept
        ? next.indexOf(current)
        : (previous?.indexOf(current) ?? 0).clamp(0, next.length - 1);
    _select(next[index]);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_controller.hasClients) return;
      if (_controller.page?.round() != index) _controller.jumpToPage(index);
    });
  }

  Future<void> _openSheet() async {
    final picked = await showServiceStatusSheet(context);
    if (picked == null || !mounted) return;
    final targets = ref.read(enabledServiceTargetsProvider);
    final index = targets.indexOf(picked);
    if (index < 0 || picked == _targetIn(targets)) return;
    await _controller.animateToPage(
      index,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
    );
  }

  /// Only a service the pager has settled on is checked, so one still being
  /// swiped past shows a result only if it is already current.
  bool _isLoading(ProbePhase phase, {required bool settled}) =>
      phase == ProbePhase.probing ||
      ((_scrolling || !settled) && phase != ProbePhase.fresh);

  Widget _buildPage(
    ServiceTarget target, {
    required bool settled,
    required double badgeSize,
    required double badgeRadius,
  }) {
    return Consumer(
      builder: (context, ref, _) {
        final entry = ref.watch(
          serviceStatusProvider.select((state) => state.entryOf(target)),
        );
        final phase = settled ? shownPhase(entry) : entry.phase;
        final loading = _isLoading(phase, settled: settled);
        final check = entry.value;
        final node = check?.node;
        final ipEntry = node != null
            ? ref.watch(
                outboundIpProbeProvider.select((state) => state.entryOf(node)),
              )
            : null;
        final outboundIp = ipEntry?.value;
        final ipPending =
            ipEntry != null &&
            (settled ? shownPhase(ipEntry) : ipEntry.phase) !=
                ProbePhase.failed &&
            outboundIp == null;
        final (label, color) = _statusOf(context, check, phase);
        return _ServicePage(
          target: target,
          badgeSize: badgeSize,
          badgeRadius: badgeRadius,
          label: label,
          color: color,
          loading: loading,
          region: check?.region,
          node: node,
          outboundIp: loading ? null : outboundIp,
          ipPending: !loading && ipPending,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(enabledServiceTargetsProvider, _onTargetsChanged);
    final targets = ref.watch(enabledServiceTargetsProvider);
    final target = _savedIn(
      targets,
      ref.watch(appSettingProvider.select((state) => state.currentService)),
    );
    if (!_scrolling) _show(target);
    final entry = ref.watch(
      serviceStatusProvider.select((state) => state.entryOf(target)),
    );
    final check = entry.value;
    final loading = _isLoading(shownPhase(entry), settled: true);
    _showNode(check?.node);

    final inset = DashboardWidgetMetrics.insetOf(context);
    final height = DashboardWidgetMetrics.heightOf(context, 1);
    final badgeInset =
        DashboardWidgetMetrics.radiusOf(context) * _badgeInsetShare;
    final badgeSize = height - badgeInset * 2;
    final badgeRadius =
        badgeSize * DashboardWidgetMetrics.radiusOf(context) / height;
    final index = targets.indexOf(target);
    return SizedBox(
      height: height,
      child: CommonCard(
        radius: DashboardWidgetMetrics.radiusOf(context),
        onPressed: _openSheet,
        child: Row(
          children: [
            Expanded(
              child: _EdgeFade(
                start: badgeInset,
                end: _gap,
                child: NotificationListener<ScrollNotification>(
                  onNotification: _onPagerScroll,
                  child: _ServicePager(
                    controller: _controller,
                    targets: targets,
                    index: index,
                    onChanged: (index) => _onTargetChanged(targets, index),
                    itemBuilder: (context, item) => Padding(
                      padding: EdgeInsetsDirectional.only(
                        start: badgeInset,
                        end: _gap,
                      ),
                      child: _buildPage(
                        item,
                        settled: item == target,
                        badgeSize: badgeSize,
                        badgeRadius: badgeRadius,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsetsDirectional.only(end: inset),
              child: _ServiceAside(
                loading: loading,
                delay: check?.delay,
                controller: _controller,
                count: targets.length,
                index: index,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ServicePage extends StatelessWidget {
  const _ServicePage({
    required this.target,
    required this.badgeSize,
    required this.badgeRadius,
    required this.label,
    required this.color,
    required this.loading,
    required this.region,
    required this.node,
    required this.outboundIp,
    required this.ipPending,
  });

  final ServiceTarget target;
  final double badgeSize;
  final double badgeRadius;
  final String label;
  final Color color;
  final bool loading;
  final String? region;
  final String? node;
  final IpInfo? outboundIp;
  final bool ipPending;

  @override
  Widget build(BuildContext context) {
    final secondary = context.textTheme.bodySmall?.copyWith(
      color: context.colorScheme.onSurfaceVariant,
    );
    return Row(
      spacing: 12,
      children: [
        _ServiceBadge(
          target: target,
          size: badgeSize,
          radius: badgeRadius,
          dot: loading ? context.colorScheme.outlineVariant : color,
        ),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 2,
            children: [
              _ServiceTitle(
                name: target.label,
                style: context.textTheme.titleMedium,
                status: Semantics(
                  liveRegion: true,
                  label: loading ? label : null,
                  child: loading
                      ? SkeletonText(
                          width: 48,
                          style: context.textTheme.labelMedium,
                        )
                      : _StatusPill(label: label, color: color),
                ),
              ),
              if (loading)
                SkeletonText(width: 96, style: secondary)
              else
                _OutboundIpLine(
                  ip: outboundIp,
                  region: region,
                  pending: ipPending,
                  fallback: node,
                  style: secondary,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ServiceTitle extends StatelessWidget {
  const _ServiceTitle({required this.name, required this.status, this.style});

  static const _statusShare = 0.6;

  final String name;
  final Widget status;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      // A Flexible status would cap the name at its own share even when the
      // status is short, so the status takes what it needs up to a limit.
      builder: (context, constraints) => Row(
        spacing: 8,
        children: [
          Flexible(
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: style,
            ),
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
  const _StatusPill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: ShapeDecoration(
        color: color.withValues(alpha: 0.14),
        shape: AppShape.full,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.textTheme.labelMedium?.copyWith(color: color),
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
        style: style?.copyWith(color: context.colorScheme.outline),
      ),
    );
  }
}

class _ServiceAside extends StatelessWidget {
  const _ServiceAside({
    required this.loading,
    required this.delay,
    required this.controller,
    required this.count,
    required this.index,
  });

  final bool loading;
  final int? delay;
  final PageController controller;
  final int count;
  final int index;

  /// The pager beside this column must keep its width: a resize mid-swipe
  /// cancels the page animation and lets it settle on the wrong service.
  double _widthOf(BuildContext context, TextSpan widest) {
    final painter = TextPainter(
      text: widest,
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
      maxLines: 1,
    )..layout();
    final width = painter.width;
    painter.dispose();
    return max(width, _PageDots.widthOf(count));
  }

  @override
  Widget build(BuildContext context) {
    final delay = this.delay;
    final numeric = context.textTheme.titleMedium
        ?.adjustSize(2)
        .toSoftBold
        .copyWith(fontFeatures: const [FontFeature.tabularFigures()]);
    final unit = context.textTheme.labelSmall?.copyWith(
      color: context.colorScheme.onSurfaceVariant,
    );
    TextSpan span(String value) => TextSpan(
      text: value,
      style: numeric,
      children: [TextSpan(text: ' ms', style: unit)],
    );
    return SizedBox(
      width: _widthOf(context, span('0000')),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        spacing: 8,
        children: [
          if (loading)
            SkeletonText(width: 36, style: numeric)
          else if (delay != null)
            Text.rich(span('$delay'), maxLines: 1),
          if (count > 1)
            _PageDots(controller: controller, count: count, index: index),
        ],
      ),
    );
  }
}

class _PageDots extends StatelessWidget {
  const _PageDots({
    required this.controller,
    required this.count,
    required this.index,
  });

  static const _window = 7;
  static const _size = 4.0;
  static const _edgeSize = 2.5;
  static const _activeWidth = 12.0;
  static const _spacing = 3.0;

  static double widthOf(int count) {
    if (count < 2) return 0;
    final shown = min(count, _window);
    return (shown - 1) * (_size + _spacing) + _activeWidth;
  }

  final PageController controller;
  final int count;
  final int index;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return ExcludeSemantics(
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          final page =
              controller.hasClients && controller.position.hasContentDimensions
              ? controller.page ?? index.toDouble()
              : index.toDouble();
          final shown = min(count, _window);
          final first = (page.round() - _window ~/ 2).clamp(0, count - shown);
          final last = first + shown - 1;
          return SizedBox(
            height: _size,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: _spacing,
              children: [
                for (var i = first; i <= last; i++)
                  _dot(
                    colorScheme,
                    active: (1 - (page - i).abs()).clamp(0.0, 1.0),
                    edge:
                        (i == first && first > 0) ||
                        (i == last && last < count - 1),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _dot(
    ColorScheme colorScheme, {
    required double active,
    required bool edge,
  }) {
    final size = edge ? _edgeSize : _size;
    return SizedBox(
      width: lerpDouble(size, _activeWidth, active),
      height: size,
      child: DecoratedBox(
        decoration: ShapeDecoration(
          color: Color.lerp(
            colorScheme.outlineVariant,
            colorScheme.primary,
            active,
          ),
          shape: AppShape.full,
        ),
      ),
    );
  }
}

class _EdgeFade extends StatelessWidget {
  const _EdgeFade({
    required this.start,
    required this.end,
    required this.child,
  });

  final double start;
  final double end;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final textDirection = Directionality.of(context);
    return ShaderMask(
      blendMode: BlendMode.dstIn,
      shaderCallback: (bounds) => LinearGradient(
        begin: AlignmentDirectional.centerStart,
        end: AlignmentDirectional.centerEnd,
        colors: const [
          Colors.transparent,
          Colors.black,
          Colors.black,
          Colors.transparent,
        ],
        stops: [
          0,
          (start / bounds.width).clamp(0.0, 0.5),
          (1 - end / bounds.width).clamp(0.5, 1.0),
          1,
        ],
      ).createShader(bounds, textDirection: textDirection),
      child: child,
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
  });

  static const _glyphShare = 0.56;

  final ServiceTarget target;
  final double size;
  final double? radius;
  final Color? dot;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return CustomPaint(
      size: Size.square(size),
      painter: _BadgePainter(
        color: enabled
            ? colorScheme.secondaryContainer
            : colorScheme.surfaceContainerHighest,
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
            colorFilter: ColorFilter.mode(
              enabled ? colorScheme.onSecondaryContainer : colorScheme.outline,
              BlendMode.srcIn,
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
    canvas
      ..saveLayer(bounds, Paint())
      ..drawRSuperellipse(tile, Paint()..color = color)
      ..drawCircle(
        center,
        dotRadius + ring,
        Paint()..blendMode = BlendMode.clear,
      )
      ..restore()
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

Future<ServiceTarget?> showServiceStatusSheet(BuildContext context) {
  return showSheet<ServiceTarget>(
    context: context,
    props: nestedPagedSheetProps,
    builder: (_) =>
        NestedPagedSheet(builder: (_) => const ServiceStatusSheet()),
  );
}

/// Lists every enabled service at once, so the card's pager never has to be
/// swiped through to find one. Tapping a row hands it back to the card.
/// The rows read the cache and are only checked on request.
class ServiceStatusSheet extends ConsumerWidget {
  const ServiceStatusSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final targets = ref.watch(enabledServiceTargetsProvider);
    final state = ref.watch(serviceStatusProvider);
    final saved = ServiceTarget.byId(
      ref.watch(appSettingProvider.select((state) => state.currentService)) ??
          '',
    );
    final current = targets.contains(saved) ? saved : targets.first;
    final services = ref.read(serviceStatusProvider.notifier);
    final localizations = context.appLocalizations;
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: ref.sheetHeight(context, 0.7)),
      child: CommonScaffold(
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
                      selected: target == current,
                      onTap: () => context.safeNestedPop(target),
                      onCheck: () => services.refresh([target]),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
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
        onChanged: locked ? null : (value) => toggle(target, value),
      );
    }

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: ref.sheetHeight(context, 0.8)),
      child: CommonScaffold(
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
    required this.onChanged,
  });

  final ServiceTarget target;
  final int index;
  final ItemPosition position;
  final bool enabled;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final onChanged = this.onChanged;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ItemPositionProvider(
        position: position,
        child: DecorationListItem(
          minVerticalPadding: _rowBadgeInset,
          contentPadding: const EdgeInsets.only(left: _rowBadgeInset, right: 0),
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
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Switch(value: enabled, onChanged: onChanged),
              ReorderableDelayedDragStartListener(
                index: index,
                child: Container(
                  color: Colors.transparent,
                  padding: const EdgeInsets.all(12),
                  child: const GlyphIcon(AppGlyphs.dragHandle),
                ),
              ),
            ],
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
    required this.selected,
    required this.onTap,
    required this.onCheck,
  });

  final ServiceTarget target;
  final ProbeEntry<ServiceCheck> entry;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onCheck;

  @override
  ConsumerState<_ServiceRow> createState() => _ServiceRowState();
}

class _ServiceRowState extends ConsumerState<_ServiceRow>
    with _NodeAddressWatch<_ServiceRow> {
  @override
  Widget build(BuildContext context) {
    final localizations = context.appLocalizations;
    final secondary = context.textTheme.bodySmall?.copyWith(
      color: context.colorScheme.onSurfaceVariant,
    );
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
    final (label, color) = _statusOf(context, check, entry.phase);
    return DecorationListItem(
      isSelected: widget.selected,
      minVerticalPadding: _rowBadgeInset,
      contentPadding: const EdgeInsets.only(left: _rowBadgeInset, right: 4),
      onPressed: widget.onTap,
      leading: _ServiceBadge(
        target: target,
        size: _rowBadgeSize,
        radius: _rowBadgeRadius,
        dot: loading
            ? context.colorScheme.outlineVariant
            : check != null || entry.phase == ProbePhase.failed
            ? color
            : null,
      ),
      title: _ServiceTitle(
        name: target.label,
        status: _StatusPill(label: label, color: color),
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
            style: numeric?.copyWith(
              color: context.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        if (checkedAt != null)
          Text(
            checkedAt.showTime.trim(),
            style: numeric?.copyWith(color: context.colorScheme.outline),
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

class _ServicePager extends StatefulWidget {
  const _ServicePager({
    required this.controller,
    required this.targets,
    required this.index,
    required this.onChanged,
    required this.itemBuilder,
  });

  final PageController controller;
  final List<ServiceTarget> targets;
  final int index;
  final ValueChanged<int> onChanged;
  final Widget Function(BuildContext context, ServiceTarget target) itemBuilder;

  @override
  State<_ServicePager> createState() => _ServicePagerState();
}

class _ServicePagerState extends State<_ServicePager> {
  bool _moving = false;

  Future<void> _select(int index) async {
    if (_moving || !widget.controller.hasClients) return;
    final next = index.clamp(0, widget.targets.length - 1);
    if (next == widget.index) return;
    _moving = true;
    try {
      await widget.controller.animateToPage(
        next,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
      );
    } finally {
      _moving = false;
    }
  }

  void _onPointerSignal(PointerSignalEvent event) {
    if (event is! PointerScrollEvent) return;
    final delta = event.scrollDelta.dx.abs() > event.scrollDelta.dy.abs()
        ? event.scrollDelta.dx
        : event.scrollDelta.dy;
    if (delta == 0) return;
    GestureBinding.instance.pointerSignalResolver.register(event, (_) {
      _select(widget.index + (delta > 0 ? 1 : -1));
    });
  }

  @override
  Widget build(BuildContext context) {
    final index = widget.index;
    final targets = widget.targets;
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.arrowLeft): () =>
            _select(index - 1),
        const SingleActivator(LogicalKeyboardKey.arrowRight): () =>
            _select(index + 1),
      },
      child: Focus(
        child: Semantics(
          label: context.appLocalizations.serviceStatus,
          value: targets[index].label,
          increasedValue: index < targets.length - 1
              ? targets[index + 1].label
              : null,
          decreasedValue: index > 0 ? targets[index - 1].label : null,
          onIncrease: index < targets.length - 1
              ? () => _select(index + 1)
              : null,
          onDecrease: index > 0 ? () => _select(index - 1) : null,
          child: Listener(
            onPointerSignal: _onPointerSignal,
            child: ScrollConfiguration(
              behavior: ScrollConfiguration.of(context).copyWith(
                dragDevices: PointerDeviceKind.values.toSet(),
                scrollbars: false,
              ),
              child: PageView.builder(
                controller: widget.controller,
                itemCount: targets.length,
                onPageChanged: widget.onChanged,
                itemBuilder: (context, itemIndex) =>
                    widget.itemBuilder(context, targets[itemIndex]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
