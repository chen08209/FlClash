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

class _ServiceStatusCardState extends ConsumerState<ServiceStatusCard>
    with ProbeStartHold<ServiceStatusCard> {
  static const _gap = 12.0;
  static const _nodeMinWidth = 260.0;

  late final PageController _controller;
  late final ServiceStatus _services;
  late final OutboundIpProbe _ips;
  ServiceTarget? _shown;
  String? _node;
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
    _ips = ref.read(outboundIpProbeProvider.notifier);
    final targets = ref.read(enabledServiceTargetsProvider);
    _controller = PageController(
      initialPage: targets.indexOf(_targetIn(targets)),
      viewportFraction: 0.4,
    );
  }

  @override
  void dispose() {
    _show(null);
    _showNode(null);
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

  void _showNode(String? node) {
    final previous = _node;
    if (node == previous) return;
    _node = node;
    if (node != null) _ips.watch(node);
    if (previous != null) _ips.unwatch(previous);
  }

  void _onTargetChanged(List<ServiceTarget> targets, int index) {
    final target = targets[index];
    if (target == _targetIn(targets)) return;
    _select(target);
  }

  /// A swipe or an animated jump passes through the services in between; only
  /// the one the picker settles on is worth a check.
  bool _onPickerScroll(ScrollNotification notification) {
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
    final phase = shownPhase(entry);
    final loading =
        phase == ProbePhase.probing ||
        (_scrolling && phase != ProbePhase.fresh);
    final node = check?.node;
    _showNode(node);
    final ipEntry = node == null
        ? null
        : ref.watch(
            outboundIpProbeProvider.select((state) => state.entryOf(node)),
          );
    final outboundIp = ipEntry?.value;
    final ipPending =
        ipEntry != null &&
        shownPhase(ipEntry) != ProbePhase.failed &&
        outboundIp == null;

    final (label, color) = _statusOf(context, check, phase);
    final inset = DashboardWidgetMetrics.insetOf(context);
    return SizedBox(
      height: DashboardWidgetMetrics.heightOf(context, 1),
      child: CommonCard(
        radius: DashboardWidgetMetrics.radiusOf(context),
        onPressed: _openSheet,
        child: Padding(
          padding: EdgeInsetsDirectional.only(start: inset - 8, end: inset),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final pickerWidth = (constraints.maxWidth * 0.3).clamp(
                80.0,
                112.0,
              );
              final showNode =
                  constraints.maxWidth - pickerWidth - _gap >= _nodeMinWidth;
              return Row(
                children: [
                  SizedBox(
                    width: pickerWidth,
                    child: NotificationListener<ScrollNotification>(
                      onNotification: _onPickerScroll,
                      child: _ServicePicker(
                        controller: _controller,
                        targets: targets,
                        index: targets.indexOf(target),
                        onChanged: (index) => _onTargetChanged(targets, index),
                      ),
                    ),
                  ),
                  const SizedBox(width: _gap),
                  Expanded(
                    child: _ServiceSummary(
                      name: target.label,
                      label: label,
                      color: color,
                      loading: loading,
                      delay: check?.delay,
                      outboundIp: loading ? null : outboundIp,
                      ipPending: loading || ipPending,
                      node: showNode ? node : null,
                      nodePending: showNode && loading,
                    ),
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

class _ServiceSummary extends StatelessWidget {
  const _ServiceSummary({
    required this.name,
    required this.label,
    required this.color,
    required this.loading,
    required this.delay,
    required this.outboundIp,
    required this.ipPending,
    required this.node,
    required this.nodePending,
  });

  final String name;
  final String label;
  final Color color;
  final bool loading;
  final int? delay;
  final IpInfo? outboundIp;
  final bool ipPending;
  final String? node;
  final bool nodePending;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final title = context.textTheme.titleSmall?.toSoftBold;
    final secondary = context.textTheme.bodySmall?.copyWith(
      color: colorScheme.onSurfaceVariant,
    );
    final numeric = context.textTheme.titleMedium?.toSoftBold.copyWith(
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    final outboundIp = this.outboundIp;
    final node = this.node;
    final delay = this.delay;
    return Row(
      spacing: 12,
      children: [
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 4,
            children: [
              Row(
                spacing: 8,
                children: [
                  Flexible(
                    child: Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: title,
                    ),
                  ),
                  Flexible(
                    child: Semantics(
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
                ],
              ),
              Row(
                spacing: 6,
                children: [
                  Flexible(
                    child: AnimatedSwitcher(
                      duration: context.motionDuration(commonDuration),
                      layoutBuilder: (current, previous) => Stack(
                        alignment: AlignmentDirectional.centerStart,
                        children: [...previous, ?current],
                      ),
                      child: outboundIp != null
                          ? _OutboundIp(ipInfo: outboundIp, style: secondary)
                          : ipPending
                          ? SkeletonText(width: 96, style: secondary)
                          : Text('—', style: secondary),
                    ),
                  ),
                  if (nodePending)
                    SkeletonText(width: 56, style: secondary)
                  else if (node != null) ...[
                    Text('·', style: secondary),
                    Flexible(
                      child: Text(
                        node,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: secondary,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
        if (loading)
          SkeletonText(width: 32, style: numeric)
        else if (delay != null)
          Text.rich(
            TextSpan(
              text: '$delay',
              children: [
                TextSpan(
                  text: ' ms',
                  style: context.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            style: numeric,
          ),
      ],
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

Future<ServiceTarget?> showServiceStatusSheet(BuildContext context) {
  return showSheet<ServiceTarget>(
    context: context,
    props: nestedPagedSheetProps,
    builder: (_) =>
        NestedPagedSheet(builder: (_) => const ServiceStatusSheet()),
  );
}

/// Lists every enabled service at once, so the card's picker never has to be
/// scrolled through to find one. Tapping a row hands it back to the card.
/// The rows read the cache and are only checked on request.
class ServiceStatusSheet extends ConsumerWidget {
  const ServiceStatusSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final targets = ref.watch(enabledServiceTargetsProvider);
    final state = ref.watch(serviceStatusProvider);
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
            isLoading: targets.every(state.isLoading),
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
          minVerticalPadding: 8,
          contentPadding: const EdgeInsets.only(left: 16, right: 0),
          onPressed: onChanged == null ? null : () => onChanged(!enabled),
          leading: SizedBox.square(
            dimension: 28,
            child: SvgPicture.asset(
              'assets/images/services/${target.icon}.svg',
              semanticsLabel: target.label,
              colorFilter: ColorFilter.mode(
                context.colorScheme.onSurfaceVariant,
                BlendMode.srcIn,
              ),
            ),
          ),
          title: Text(target.label),
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

class _ServiceRow extends StatelessWidget {
  const _ServiceRow({
    required this.target,
    required this.entry,
    required this.onTap,
    required this.onCheck,
  });

  final ServiceTarget target;
  final ProbeEntry<ServiceCheck> entry;
  final VoidCallback onTap;
  final VoidCallback onCheck;

  @override
  Widget build(BuildContext context) {
    final localizations = context.appLocalizations;
    final secondary = context.textTheme.bodySmall?.copyWith(
      color: context.colorScheme.onSurfaceVariant,
    );
    final check = entry.value;
    final loading = entry.isLoading;
    final (label, color) = _statusOf(context, check, entry.phase);
    return DecorationListItem(
      minVerticalPadding: 8,
      contentPadding: const EdgeInsets.only(left: 16, right: 4),
      onPressed: onTap,
      leading: SizedBox.square(
        dimension: 28,
        child: SvgPicture.asset(
          'assets/images/services/${target.icon}.svg',
          semanticsLabel: target.label,
          colorFilter: ColorFilter.mode(
            context.colorScheme.onSurfaceVariant,
            BlendMode.srcIn,
          ),
        ),
      ),
      title: Text(target.label),
      subtitle: Row(
        spacing: 6,
        children: [
          if (loading)
            const SizedBox.square(
              dimension: 10,
              child: CircularProgressIndicator(strokeWidth: 1.5),
            ),
          if (check?.region case final region?)
            Text(
              region.countryFlagEmoji,
              style: secondary?.copyWith(fontFamily: FontFamily.twEmoji.value),
            ),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: secondary?.copyWith(color: color),
            ),
          ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 4,
        children: [
          _ServiceRowTrailing(check: check, style: secondary),
          IconButton(
            tooltip: localizations.serviceCheck,
            onPressed: loading ? null : onCheck,
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
        if (delay != null) Text('$delay ms', style: numeric),
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

class _OutboundIp extends StatelessWidget {
  const _OutboundIp({required this.ipInfo, this.style});

  final IpInfo ipInfo;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 4,
      children: [
        Text(
          ipInfo.countryCode.countryFlagEmoji,
          style: style?.copyWith(fontFamily: FontFamily.twEmoji.value),
        ),
        Flexible(
          child: IpQualityText(ip: ipInfo.ip, openDetails: true, style: style),
        ),
      ],
    );
  }
}

class _ServicePicker extends StatefulWidget {
  const _ServicePicker({
    required this.controller,
    required this.targets,
    required this.index,
    required this.onChanged,
  });

  final PageController controller;
  final List<ServiceTarget> targets;
  final int index;
  final ValueChanged<int> onChanged;

  @override
  State<_ServicePicker> createState() => _ServicePickerState();
}

class _ServicePickerState extends State<_ServicePicker> {
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
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 44,
                  height: 48,
                  decoration: ShapeDecoration(
                    color: context.colorScheme.secondaryContainer,
                    shape: AppShape.md,
                  ),
                ),
                ShaderMask(
                  blendMode: BlendMode.dstIn,
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [
                      Colors.transparent,
                      Colors.black,
                      Colors.black,
                      Colors.transparent,
                    ],
                    stops: [0, 0.2, 0.8, 1],
                  ).createShader(bounds),
                  child: ScrollConfiguration(
                    behavior: ScrollConfiguration.of(context).copyWith(
                      dragDevices: PointerDeviceKind.values.toSet(),
                      scrollbars: false,
                    ),
                    child: PageView.builder(
                      controller: widget.controller,
                      itemCount: targets.length,
                      onPageChanged: widget.onChanged,
                      itemBuilder: (context, itemIndex) {
                        final target = targets[itemIndex];
                        return AnimatedBuilder(
                          animation: widget.controller,
                          builder: (context, child) {
                            final page =
                                widget.controller.hasClients &&
                                    widget
                                        .controller
                                        .position
                                        .hasContentDimensions
                                ? widget.controller.page ?? index.toDouble()
                                : index.toDouble();
                            final distance = (page - itemIndex).abs().clamp(
                              0.0,
                              1.0,
                            );
                            return Transform.scale(
                              scale: 1 - distance * 0.3,
                              child: Opacity(
                                opacity: 1 - distance * 0.55,
                                child: child,
                              ),
                            );
                          },
                          child: Center(
                            child: Tooltip(
                              message: target.label,
                              child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () => _select(itemIndex),
                                child: SizedBox.square(
                                  dimension: 44,
                                  child: Center(
                                    child: SvgPicture.asset(
                                      'assets/images/services/${target.icon}.svg',
                                      width: 28,
                                      height: 28,
                                      semanticsLabel: target.label,
                                      colorFilter: ColorFilter.mode(
                                        context
                                            .colorScheme
                                            .onSecondaryContainer,
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
