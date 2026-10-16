import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/ui/icons/icons.dart';
import 'package:fl_clash/views/dashboard/layout.dart';
import 'package:fl_clash/views/dashboard/style.dart';
import 'package:fl_clash/views/proxies/proxies.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_new_shapes/material_new_shapes.dart';
import 'package:material_ui/material_ui.dart';

import 'card.dart';
import 'connections_table.dart';
import 'current_outbound.dart';

const _stackedIcons = 4;

/// The inset of a block's corner, so the icon tile inside it is concentric.
const _blockInset = 10.0;

/// The proxies page stays mounted under the dashboard and filters by the same
/// query, so the sheet searches on its own and hands the page's query back.
Future<void> showProxiesSheet(BuildContext context, {String? groupName}) async {
  final container = ProviderScope.containerOf(context, listen: false);
  if (groupName != null) {
    container
        .read(proxiesActionProvider.notifier)
        .updateCurrentGroupName(groupName);
  }
  final query = queryProvider(QueryTag.proxies);
  final pageQuery = container.read(query);
  container.read(query.notifier).value = '';
  await showSheet<void>(
    context: context,
    builder: (_) => const ProxiesView(picker: true),
  );
  container.read(query.notifier).value = pageQuery;
}

/// Drawn in the proportions of the proxies page's group header, always
/// filled: the icon style chosen there is that page's own, and the dashboard
/// would look bare without icons.
class _GroupIcon extends StatelessWidget {
  const _GroupIcon({
    required this.group,
    required this.size,
    required this.radius,
    this.ring,
  });

  final Group group;
  final double size;
  final double radius;
  final Color? ring;

  static const _inset = 0.15;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final ring = this.ring;
    final inset = size * _inset;
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(inset),
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: DashboardColors.of(context).tone2,
        shape: AppShape.all(radius).copyWith(
          side: ring == null
              ? BorderSide.none
              : BorderSide(
                  color: ring,
                  width: 3,
                  strokeAlign: BorderSide.strokeAlignOutside,
                ),
        ),
      ),
      child: Center(
        child: IconTheme.merge(
          data: IconThemeData(
            size: size - inset * 2,
            color: colorScheme.onSurfaceVariant,
          ),
          child: CommonTargetIcon(
            src: group.icon,
            fallback: GroupMonogram(group.name),
          ),
        ),
      ),
    );
  }
}

class _GroupDelay extends ConsumerWidget {
  const _GroupDelay({required this.group});

  final Group group;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final delay = ref.watch(
      delayProvider(proxyName: group.name, testUrl: group.testUrl),
    );
    if (delay == null) {
      return const SizedBox.shrink();
    }
    final colorScheme = context.colorScheme;
    return Text(
      delay > 0
          ? '$delay ms'
          : delayFailureText(delay, context.appLocalizations),
      maxLines: 1,
      style: AppTextStyle.caption1
          .of(context, emphasized: true)
          .toTabular
          .copyWith(color: colorScheme.delayColor(delay > 0 ? delay : -1)),
    );
  }
}

class _SelectedName extends ConsumerWidget {
  const _SelectedName({required this.group});

  final Group group;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name = ref.watch(selectedProxyNameProvider(group.name)) ?? '';
    final base = DashboardText.rowTitle(context);
    return EmojiText(
      name.isEmpty ? '—' : name,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: isBuiltinOutbound(name)
          ? base.copyWith(color: context.colorScheme.onSurfaceVariant)
          : base,
    );
  }
}

class _TimeoutChip extends ConsumerWidget {
  const _TimeoutChip({required this.groups});

  final List<Group> groups;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var timedOut = 0;
    for (final group in groups) {
      final delay = ref.watch(
        delayProvider(proxyName: group.name, testUrl: group.testUrl),
      );
      if (delay != null && delay < 0) {
        timedOut++;
      }
    }
    if (timedOut == 0) {
      return const SizedBox.shrink();
    }
    return DashboardChip(
      label: context.appLocalizations.groupTimeoutCount(timedOut),
      tone: DashboardChipTone.warn,
    );
  }
}

(String, String?) _emptyTextsOf(
  BuildContext context, {
  required bool connected,
}) {
  final appLocalizations = context.appLocalizations;
  return connected
      ? (appLocalizations.nullTip(appLocalizations.proxyGroup), null)
      : (
          appLocalizations.memoryCoreNotRunning,
          appLocalizations.proxyGroupsAfterStart,
        );
}

class _GroupsEmpty extends ConsumerWidget {
  const _GroupsEmpty({this.fit = false});

  /// Scales down into whatever height the card has left.
  final bool fit;

  static const _maxWidth = 260.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = context.colorScheme;
    final (title, subtitle) = _emptyTextsOf(
      context,
      connected: ref.watch(coreStatusProvider) == CoreStatus.connected,
    );
    final content = ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: _maxWidth),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 6,
        children: [
          ShapeBadge(
            shape: MaterialShapes.cookie9Sided,
            color: DashboardColors.of(context).tone,
            size: 64,
            child: GlyphIcon(
              AppGlyphs.layers,
              size: 26,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTextStyle.subheadline.of(context, emphasized: true),
          ),
          if (subtitle != null)
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: AppTextStyle.footnote
                  .of(context)
                  .copyWith(color: colorScheme.onSurfaceVariant),
            ),
        ],
      ),
    );
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: fit ? FittedBox(fit: BoxFit.scaleDown, child: content) : content,
      ),
    );
  }
}

class ProxyGroupsCard extends ConsumerWidget {
  const ProxyGroupsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final density = DashboardDensityScope.of(context);
    if (!density.isDesktop) {
      return const ProxyGroupsSummaryCard();
    }
    final compact = density.isCompact;
    final scale = DashboardDensityScope.scaleOf(context);
    final groups = ref.watch(visibleGroupsStateProvider).value;
    final padding = dashboardCardPadding(density);
    final tileHeight = (compact ? 52 : 60) * scale;
    final tileGap = compact ? 6.0 : 8.0;
    return DashboardCard(
      semanticLabel: context.appLocalizations.proxyGroup,
      padding: padding.copyWith(bottom: 0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final tiles = _GroupTiles(
            groups: groups,
            columns: _GroupTiles.columnsFor(
              constraints.maxWidth,
              scale: scale,
              gap: tileGap,
            ),
            height: tileHeight,
            gap: tileGap,
            iconSize: _figureMetricsOf(density).icon,
            bottom: padding.bottom,
          );
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _GroupsHeader(groups: groups, count: true),
              if (groups.isEmpty)
                const Expanded(child: _GroupsEmpty(fit: true))
              else ...[
                SizedBox(
                  height:
                      connectionsTableTop(density, scale) -
                      padding.top -
                      DashboardCardHeader.height * scale,
                ),
                Expanded(child: tiles),
              ],
            ],
          );
        },
      ),
    );
  }
}

typedef _FigureMetrics = ({AppTextStyle style, double icon});

_FigureMetrics _figureMetricsOf(DashboardDensity density) => density.isCompact
    ? (style: AppTextStyle.largeTitle, icon: 34)
    : (style: AppTextStyle.display, icon: 40);

class _GroupsHeader extends StatelessWidget {
  const _GroupsHeader({required this.groups, this.count = false});

  final List<Group> groups;
  final bool count;

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final mobile = !DashboardDensityScope.of(context).isDesktop;
    return DashboardCardHeader(
      glyph: AppGlyphs.layers,
      title: appLocalizations.proxyGroup,
      chevron: mobile && groups.isNotEmpty,
      leading: [
        if (count && groups.isNotEmpty)
          Tooltip(
            message: appLocalizations.groupCount(groups.length),
            child: DashboardChip(label: '${groups.length}'),
          ),
        _TimeoutChip(groups: groups),
      ],
      trailing: [
        if (!mobile)
          Transform.translate(
            offset: const Offset(8, 0),
            child: DashboardIconButton(
              glyph: AppGlyphs.chevronForward,
              tooltip: appLocalizations.proxyGroup,
              onPressed: groups.isEmpty
                  ? null
                  : () => showProxiesSheet(context),
            ),
          ),
      ],
    );
  }
}

class _GroupsFigure extends StatelessWidget {
  const _GroupsFigure({required this.groups, required this.metrics});

  final List<Group> groups;
  final _FigureMetrics metrics;

  @override
  Widget build(BuildContext context) {
    final count = Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: '${groups.length}',
            style: DashboardText.figure(context, metrics.style),
          ),
          TextSpan(
            text: ' ${context.appLocalizations.groupCountUnit}',
            style: DashboardText.unit(context),
          ),
        ],
      ),
      maxLines: 1,
    );
    return DashboardCappedRow(
      start: count,
      end: _IconStack(
        groups: groups,
        size: metrics.icon,
        ring: DashboardColors.of(context).card,
      ),
    );
  }
}

class _IconStack extends StatelessWidget {
  const _IconStack({
    required this.groups,
    required this.size,
    required this.ring,
  });

  final List<Group> groups;
  final double size;
  final Color ring;

  static const _overlap = 8.0;

  @override
  Widget build(BuildContext context) {
    final shown = groups.take(_stackedIcons).toList();
    final rest = groups.length - shown.length;
    final count = shown.length + (rest > 0 ? 1 : 0);
    return SizedBox(
      width: count * size - (count - 1) * _overlap,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (final (index, group) in shown.indexed)
            PositionedDirectional(
              start: index * (size - _overlap),
              child: _GroupIcon(
                group: group,
                size: size,
                radius: DashboardCorner.badge,
                ring: ring,
              ),
            ),
          if (rest > 0)
            PositionedDirectional(
              start: shown.length * (size - _overlap),
              child: Container(
                width: size,
                height: size,
                decoration: ShapeDecoration(
                  color: DashboardColors.of(context).tone,
                  shape: AppShape.all(DashboardCorner.badge).copyWith(
                    side: BorderSide(
                      color: ring,
                      width: 3,
                      strokeAlign: BorderSide.strokeAlignOutside,
                    ),
                  ),
                ),
                child: Center(
                  child: Text(
                    '+$rest',
                    style: AppTextStyle.caption1
                        .of(context, emphasized: true)
                        .toTabular
                        .copyWith(color: context.colorScheme.onSurfaceVariant),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _GroupTiles extends StatelessWidget {
  const _GroupTiles({
    required this.groups,
    required this.columns,
    required this.height,
    required this.gap,
    required this.iconSize,
    required this.bottom,
  });

  final List<Group> groups;
  final int columns;
  final double height;
  final double gap;
  final double iconSize;
  final double bottom;

  static const _minTileWidth = 172.0;

  static int columnsFor(
    double width, {
    required double scale,
    required double gap,
  }) => width >= _minTileWidth * scale * 2 + gap ? 2 : 1;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final rows = (groups.length / columns).ceil();
        final overflows =
            rows * height + (rows - 1) * gap + bottom > constraints.maxHeight;
        final grid = GridView.builder(
          padding: EdgeInsets.only(bottom: bottom),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisSpacing: gap,
            crossAxisSpacing: gap,
            mainAxisExtent: height,
          ),
          itemCount: groups.length,
          itemBuilder: (context, index) => _GroupTile(
            group: groups[index],
            iconSize: iconSize,
            onTap: () =>
                showProxiesSheet(context, groupName: groups[index].name),
          ),
        );
        return overflows ? DashboardFadeOut(child: grid) : grid;
      },
    );
  }
}

class _GroupTile extends StatelessWidget {
  const _GroupTile({
    required this.group,
    required this.iconSize,
    required this.onTap,
  });

  final Group group;
  final double iconSize;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return DashboardBlock(
      radius: DashboardCorner.block,
      padding: const EdgeInsetsDirectional.fromSTEB(_blockInset, 0, 14, 0),
      onTap: onTap,
      semanticLabel: group.name,
      child: Row(
        spacing: 12,
        children: [
          _GroupIcon(
            group: group,
            size: iconSize,
            radius: DashboardCorner.block - _blockInset,
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  spacing: 8,
                  children: [
                    Expanded(
                      child: EmojiText(
                        group.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyle.caption1
                            .of(context)
                            .copyWith(
                              color: context.colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ),
                    _GroupDelay(group: group),
                  ],
                ),
                _SelectedName(group: group),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The group count, for the phone and a desktop page too short for tiles.
class ProxyGroupsSummaryCard extends ConsumerWidget {
  const ProxyGroupsSummaryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final groups = ref.watch(visibleGroupsStateProvider).value;
    final density = DashboardDensityScope.of(context);
    final figure = _GroupsFigure(
      groups: groups,
      metrics: _figureMetricsOf(density),
    );
    if (density.isDesktop) {
      return DashboardCard(
        semanticLabel: appLocalizations.proxyGroup,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _GroupsHeader(groups: groups),
            const Spacer(),
            if (groups.isEmpty) const _GroupsEmptySummary() else figure,
            const Spacer(),
          ],
        ),
      );
    }
    return DashboardCard(
      semanticLabel: appLocalizations.proxyGroup,
      onTap: groups.isEmpty ? null : () => showProxiesSheet(context),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _GroupsHeader(groups: groups),
          const SizedBox(height: 12),
          if (groups.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: _GroupsEmpty(),
            )
          else
            figure,
        ],
      ),
    );
  }
}

/// The empty state of the desktop summary, whose fixed height leaves no room
/// for the illustration.
class _GroupsEmptySummary extends ConsumerWidget {
  const _GroupsEmptySummary();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final (title, subtitle) = _emptyTextsOf(
      context,
      connected: ref.watch(coreStatusProvider) == CoreStatus.connected,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: DashboardText.rowTitle(context),
        ),
        if (subtitle != null)
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: DashboardText.label(context),
          ),
      ],
    );
  }
}
