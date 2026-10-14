import 'dart:math';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/dashboard/widget_metrics.dart';
import 'package:fl_clash/views/proxies/common.dart';
import 'package:fl_clash/views/proxies/tab.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'row_card.dart';

const _summaryGap = 8.0;

class ProxyGroupsCard extends ConsumerWidget {
  const ProxyGroupsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groups = ref.watch(visibleGroupsStateProvider).value;
    return RowCardFrame(
      child: _GroupsPane(
        groups: groups,
        onSelect: (group) => showSheet<void>(
          context: context,
          builder: (_) => _ProxyGroupSheet(groupName: group.name),
        ),
      ),
    );
  }
}

class _GroupsPane extends StatefulWidget {
  const _GroupsPane({required this.groups, required this.onSelect});

  final List<Group> groups;
  final void Function(Group group) onSelect;

  @override
  State<_GroupsPane> createState() => _GroupsPaneState();
}

class _GroupsPaneState extends State<_GroupsPane> {
  final _controller = RowSnapScrollController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final groups = widget.groups;
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
              rowExtent:
                  rowCardLineExtentOf(context) +
                  globalState.measure.labelSmallHeight *
                      DashboardWidgetMetrics.textScaleOf(context),
              builder: (_, rowHeight, spacing) {
                final itemExtent = rowHeight + spacing;
                _controller.itemExtent = itemExtent;
                return ListView.builder(
                  controller: _controller,
                  padding: EdgeInsets.zero,
                  physics: const RowSnapScrollPhysics(),
                  itemExtent: itemExtent,
                  itemCount: groups.length,
                  itemBuilder: (_, index) {
                    final group = groups[index];
                    return Padding(
                      padding: EdgeInsets.only(bottom: spacing),
                      child: RowCardPill(
                        onTap: () => widget.onSelect(group),
                        child: _GroupSummary(group: group),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}

class _ProxyGroupSheet extends ConsumerStatefulWidget {
  const _ProxyGroupSheet({required this.groupName});

  final String groupName;

  @override
  ConsumerState<_ProxyGroupSheet> createState() => _ProxyGroupSheetState();
}

class _ProxyGroupSheetState extends ConsumerState<_ProxyGroupSheet> {
  late final ScrollController _controller;
  var _revealedSelected = false;

  @override
  void initState() {
    super.initState();
    _controller = sheetScrollController(context);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _revealSelected(Group group, int columns, ProxyCardType cardType) {
    if (_revealedSelected) {
      return;
    }
    _revealedSelected = true;
    final offset = selectedRowOffset(
      proxies: group.all,
      selectedProxyName: ref.read(selectedProxyNameProvider(group.name)),
      columns: columns,
      rowExtent: getRowExtent(cardType),
    );
    if (offset == null || offset == 0) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_controller.hasClients) {
        _controller.jumpTo(min(offset, _controller.position.maxScrollExtent));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final groupName = widget.groupName;
    final group = ref.watch(
      visibleGroupsStateProvider.select(
        (state) => state.value.getGroup(groupName),
      ),
    );
    final isDelayTesting = ref.watch(
      delayTestingGroupsProvider.select((state) => state.contains(groupName)),
    );
    final (cardType, layout) = ref.watch(
      proxiesStyleSettingProvider.select(
        (state) => (state.cardType, state.layout),
      ),
    );
    final appLocalizations = context.appLocalizations;
    return CommonScaffold(
      title: groupName,
      iconActions: [
        IconButtonData(
          glyph: AppGlyphs.bolt,
          tooltip: appLocalizations.delayTest,
          isLoading: isDelayTesting,
          onPressed: () => ref
              .read(proxiesActionProvider.notifier)
              .delayTestPageGroup(groupName, matchSearch: false),
        ),
      ],
      body: group == null
          ? NullStatus(
              illustration: NullStatusIllustration.proxies,
              label: appLocalizations.nullTip(appLocalizations.proxyGroup),
            )
          : LayoutBuilder(
              builder: (context, constraints) {
                final columns = getProxiesColumns(
                  max(constraints.maxWidth - 32, 0),
                  layout,
                );
                _revealSelected(group, columns, cardType);
                return ProxyGroupView(
                  group: group,
                  controller: _controller,
                  columns: columns,
                  cardType: cardType,
                  shrinkWrap: true,
                  topPadding: context.contentTopPadding,
                );
              },
            ),
    );
  }
}

class _RowLabel extends StatelessWidget {
  const _RowLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return OverflowTooltipText(
      text: text,
      style: context.textTheme.bodyMedium?.copyWith(
        color: context.colorScheme.onSurface,
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
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          spacing: _summaryGap,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Expanded(child: _RowLabel(text: group.name)),
            _ProxyDelay(proxyName: group.name, testUrl: group.testUrl),
          ],
        ),
        if (proxyName.isNotEmpty)
          OverflowTooltipText(
            text: proxyName,
            style: context.textTheme.labelSmall?.toLight,
          ),
      ],
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
      delay > 0 ? '$delay' : delayFailureText(delay, context.appLocalizations),
      maxLines: 1,
      style: context.textTheme.labelSmall?.copyWith(
        color: context.colorScheme.delayColor(delay),
      ),
    );
  }
}
