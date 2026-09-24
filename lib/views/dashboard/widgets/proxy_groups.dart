import 'dart:math';

import 'package:animations/animations.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/dashboard/widget_metrics.dart';
import 'package:fl_clash/views/proxies/card.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'row_card.dart';

const _chevronSize = 16.0;
const _minGroupNameCharacters = 2;
const _summaryGap = 8.0;
const _layoutSlack = 1;
const _headerInkInset = EdgeInsets.symmetric(horizontal: 6, vertical: 2);

class ProxyGroupsCard extends ConsumerStatefulWidget {
  const ProxyGroupsCard({super.key});

  @override
  ConsumerState<ProxyGroupsCard> createState() => _ProxyGroupsCardState();
}

class _ProxyGroupsCardState extends ConsumerState<ProxyGroupsCard> {
  String? _groupName;
  bool _reverse = false;

  void _show(String? groupName) {
    setState(() {
      _reverse = groupName == null;
      _groupName = groupName;
    });
  }

  @override
  Widget build(BuildContext context) {
    final groups = ref.watch(visibleGroupsStateProvider).value;
    final group = _groupName == null ? null : groups.getGroup(_groupName!);
    return RowCardFrame(
      child: PageTransitionSwitcher(
        reverse: _reverse,
        duration: context.motionDuration(commonDuration),
        transitionBuilder: (child, animation, secondaryAnimation) {
          return SharedAxisTransition(
            animation: animation,
            secondaryAnimation: secondaryAnimation,
            transitionType: SharedAxisTransitionType.horizontal,
            fillColor: Colors.transparent,
            child: child,
          );
        },
        child: group == null
            ? _GroupsPane(
                key: const ValueKey('proxy-groups'),
                groups: groups,
                onSelect: (group) => _show(group.name),
              )
            : _ProxiesPane(
                key: ValueKey(group.name),
                group: group,
                onBack: () => _show(null),
              ),
      ),
    );
  }
}

class _GroupsPane extends StatelessWidget {
  const _GroupsPane({super.key, required this.groups, required this.onSelect});

  final List<Group> groups;
  final void Function(Group group) onSelect;

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return RowCardPane(
      header: InfoHeader(
        padding: DashboardWidgetMetrics.paddingOf(context).copyWith(bottom: 0),
        info: Info(
          label: appLocalizations.proxyGroup,
          glyph: AppGlyphs.proxies,
        ),
      ),
      body: groups.isEmpty
          ? RowCardEmpty(
              illustration: NullStatusIllustration.proxies,
              label: appLocalizations.nullTip(appLocalizations.proxyGroup),
            )
          : RowCardSlots(
              rowExtent: rowCardLineExtentOf(context),
              builder: (_, rowHeight, spacing) => ListView.builder(
                padding: EdgeInsets.zero,
                itemExtent: rowHeight + spacing,
                itemCount: groups.length,
                itemBuilder: (_, index) {
                  final group = groups[index];
                  return Padding(
                    padding: EdgeInsets.only(bottom: spacing),
                    child: RowCardPill(
                      onTap: () => onSelect(group),
                      child: Row(
                        spacing: _summaryGap,
                        children: [
                          Expanded(child: _GroupSummary(group: group)),
                          GlyphIcon(
                            AppGlyphs.chevronForward,
                            size: _chevronSize,
                            color: context.colorScheme.onSurfaceVariant,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}

class _ProxiesPane extends ConsumerStatefulWidget {
  const _ProxiesPane({super.key, required this.group, required this.onBack});

  final Group group;
  final VoidCallback onBack;

  @override
  ConsumerState<_ProxiesPane> createState() => _ProxiesPaneState();
}

class _ProxiesPaneState extends ConsumerState<_ProxiesPane> {
  final _controller = ScrollController();
  var _revealedSelected = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _revealSelected(double itemExtent) {
    if (_revealedSelected) {
      return;
    }
    _revealedSelected = true;
    final selected = ref.read(selectedProxyNameProvider(widget.group.name));
    final index = widget.group.all.indexWhere(
      (proxy) => proxy.name == selected,
    );
    if (index <= 0) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_controller.hasClients) {
        return;
      }
      _controller.jumpTo(
        min(index * itemExtent, _controller.position.maxScrollExtent),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final group = widget.group;
    final selected = ref.watch(selectedProxyNameProvider(group.name));
    final colorScheme = context.colorScheme;
    final headerPadding = DashboardWidgetMetrics.paddingOf(
      context,
    ).copyWith(bottom: 0);
    return RowCardPane(
      headerOverhang: _headerInkInset.bottom,
      header: Padding(
        padding: headerPadding.copyWith(
          left: headerPadding.left - _headerInkInset.left,
          top: headerPadding.top - _headerInkInset.top,
          right: headerPadding.right - _headerInkInset.right,
        ),
        child: Align(
          alignment: AlignmentDirectional.centerStart,
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              customBorder: AppShape.full,
              onTap: widget.onBack,
              child: Semantics(
                button: true,
                label: context.appLocalizations.back,
                child: InfoHeader(
                  padding: _headerInkInset,
                  info: Info(label: group.name, glyph: AppGlyphs.chevronBack),
                ),
              ),
            ),
          ),
        ),
      ),
      body: RowCardSlots(
        rowExtent: rowCardLineExtentOf(context),
        builder: (_, rowHeight, spacing) {
          final itemExtent = rowHeight + spacing;
          _revealSelected(itemExtent);
          return ListView.builder(
            controller: _controller,
            padding: EdgeInsets.zero,
            itemExtent: itemExtent,
            itemCount: group.all.length,
            itemBuilder: (_, index) {
              final proxy = group.all[index];
              final isSelected = proxy.name == selected;
              return Padding(
                padding: EdgeInsets.only(bottom: spacing),
                child: RowCardPill(
                  color: isSelected ? colorScheme.secondaryContainer : null,
                  onTap: () => selectGroupProxy(
                    ref,
                    groupName: group.name,
                    groupType: group.type,
                    proxyName: proxy.name,
                  ),
                  child: Row(
                    spacing: _summaryGap,
                    children: [
                      Expanded(
                        child: _RowLabel(
                          text: proxy.name,
                          color: isSelected
                              ? colorScheme.onSecondaryContainer
                              : null,
                        ),
                      ),
                      _ProxyDelay(
                        proxyName: proxy.name,
                        testUrl: group.testUrl,
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _RowLabel extends StatelessWidget {
  const _RowLabel({required this.text, this.color});

  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return OverflowTooltipText(
      text: text,
      style: context.textTheme.bodyMedium?.copyWith(
        color: color ?? context.colorScheme.onSurface,
      ),
    );
  }
}

class _GroupSummary extends ConsumerWidget {
  const _GroupSummary({required this.group});

  final Group group;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final proxyName = ref
        .watch(selectedProxyNameProvider(group.name))
        .takeFirstValid([]);
    final nameStyle = context.textTheme.bodyMedium;
    final proxyStyle = context.textTheme.labelSmall?.toLight;
    return LayoutBuilder(
      builder: (_, constraints) {
        final measure = globalState.measure;
        double widthOf(String text) =>
            measure.computeTextSize(Text(text, style: nameStyle)).width;
        final characters = group.name.characters;
        final nameMinWidth = characters.length > _minGroupNameCharacters
            ? min(
                widthOf(group.name),
                widthOf('${characters.take(_minGroupNameCharacters)}…'),
              )
            : widthOf(group.name);
        final proxyMaxWidth = max(
          constraints.maxWidth -
              _summaryGap -
              nameMinWidth.ceil() -
              _layoutSlack,
          0.0,
        );
        return Row(
          spacing: _summaryGap,
          children: [
            Expanded(child: _RowLabel(text: group.name)),
            if (proxyName.isNotEmpty)
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: proxyMaxWidth),
                child: OverflowTooltipText(text: proxyName, style: proxyStyle),
              ),
          ],
        );
      },
    );
  }
}

class _ProxyDelay extends ConsumerWidget {
  const _ProxyDelay({required this.proxyName, required this.testUrl});

  final String proxyName;
  final String? testUrl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final delay = ref.watch(
      delayProvider(proxyName: proxyName, testUrl: testUrl),
    );
    if (delay == null) {
      return const SizedBox.shrink();
    }
    return Text(
      delay > 0 ? '$delay' : 'Timeout',
      maxLines: 1,
      style: context.textTheme.labelSmall?.copyWith(
        color: context.colorScheme.delayColor(delay),
      ),
    );
  }
}
