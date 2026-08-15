import 'dart:math';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/common/free_nodes.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/common.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'card.dart';
import 'common.dart';
import 'free_nodes_group_menu.dart';

@visibleForTesting
bool shouldUseTwoRowFreeNodesGroupTabs({
  required bool isFreeNodesProfile,
  required int groupCount,
}) {
  return isFreeNodesProfile && groupCount > 1;
}

@visibleForTesting
Group? resolveCurrentDelayTestGroup({
  required List<Group> groups,
  required int? activeIndex,
  required String? selectedGroupName,
}) {
  if (activeIndex != null && activeIndex >= 0 && activeIndex < groups.length) {
    return groups[activeIndex];
  }
  if (selectedGroupName == null || selectedGroupName.trim().isEmpty) {
    return null;
  }
  for (final group in groups) {
    if (group.name == selectedGroupName) return group;
  }
  return null;
}

typedef ProxyGroupViewKeyMap =
    Map<String, GlobalObjectKey<_ProxyGroupViewState>>;

class ProxiesTabView extends ConsumerStatefulWidget {
  const ProxiesTabView({super.key});

  static Map<String, PageStorageKey> pageListStoreMap = {};

  @override
  ConsumerState<ProxiesTabView> createState() => ProxiesTabViewState();
}

class ProxiesTabViewState extends ConsumerState<ProxiesTabView>
    with TickerProviderStateMixin {
  TabController? _tabController;
  final _hasMoreButtonNotifier = ValueNotifier<bool>(false);
  ProxyGroupViewKeyMap _keyMap = {};

  @override
  void initState() {
    super.initState();
    ref.listenManual(proxiesTabControllerStateProvider, (prev, next) {
      if (prev == next) {
        return;
      }
      if (!stringListEquality.equals(prev?.a, next.a)) {
        _destroyTabController();
        final groupNames = next.a;
        final currentGroupName = next.b;
        final index = groupNames.indexWhere((item) => item == currentGroupName);
        _updateTabController(groupNames.length, index);
      }
    }, fireImmediately: true);
  }

  @override
  void dispose() {
    _destroyTabController();
    super.dispose();
  }

  void scrollToGroupSelected() {
    final group = currentGroup;
    if (group == null) {
      return;
    }
    _keyMap[group.name]?.currentState?.scrollToSelected();
  }

  Future<void> delayTestCurrentGroup() async {
    final group = currentGroup;
    if (group == null) {
      return;
    }
    await delayTest(group.all, group.testUrl);
  }

  Group? get currentGroup {
    return _getGroup(_tabController?.index);
  }

  Group? _getGroup(int? index) {
    final groups = ref.read(proxiesTabStateProvider).groups;
    if (index == null || index < 0 || index >= groups.length) {
      return null;
    }
    return groups[index];
  }

  Widget _buildMoreButton() {
    return Consumer(
      builder: (_, ref, _) {
        final isMobileView = ref.watch(isMobileViewProvider);
        return IconButton(
          onPressed: _showMoreMenu,
          icon: isMobileView
              ? const Icon(Icons.expand_more)
              : const Icon(Icons.chevron_right),
        );
      },
    );
  }

  void _showMoreMenu() {
    showSheet(
      context: context,
      props: const SheetProps(isScrollControlled: false),
      builder: (_) {
        return AdaptiveSheetScaffold(
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Consumer(
              builder: (_, ref, _) {
                final state = ref.watch(proxiesTabControllerStateProvider);
                final groupNames = state.a;
                final currentGroupName = state.b;
                return SizedBox(
                  width: double.infinity,
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    runSpacing: 8,
                    spacing: 8,
                    children: [
                      for (final groupName in groupNames)
                        SettingTextCard(
                          groupName,
                          onPressed: () {
                            final index = groupNames.indexWhere(
                              (item) => item == groupName,
                            );
                            if (index == -1) return;
                            _tabController?.animateTo(index);
                            updateCurrentGroupName(groupName);
                            Navigator.of(context).pop();
                          },
                          isSelected: groupName == currentGroupName,
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
          title: context.appLocalizations.proxyGroup,
        );
      },
    );
  }

  void _tabControllerListener([int? index]) {
    final group = _getGroup(index ?? _tabController?.index);
    if (group == null) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      updateCurrentGroupName(group.name);
    });
  }

  void _destroyTabController() {
    _tabController?.removeListener(_tabControllerListener);
    _tabController?.dispose();
    _tabController = null;
  }

  void _updateTabController(int length, int index) {
    _destroyTabController();
    if (length == 0) {
      return;
    }
    final realIndex = index == -1 ? 0 : index;
    _tabController ??= TabController(
      length: length,
      initialIndex: realIndex,
      vsync: this,
    );
    _tabControllerListener(realIndex);
    _tabController?.addListener(_tabControllerListener);
  }

  Widget _buildGroupTabLabel(String groupName, {required bool selected}) {
    final colorScheme = context.colorScheme;
    return Material(
      color: selected
          ? colorScheme.secondaryContainer
          : colorScheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(10),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          final groups = ref.read(proxiesTabStateProvider).groups;
          final index = groups.indexWhere((group) => group.name == groupName);
          if (index < 0) return;
          _tabController?.animateTo(index);
          updateCurrentGroupName(groupName);
        },
        onLongPress: canShowFreeNodesGroupMenu(groupName)
            ? () => showFreeNodesGroupMenu(context, groupName)
            : null,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 112, maxWidth: 188),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Center(
              child: EmojiText(
                groupName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: DefaultTextStyle.of(context).style.copyWith(
                  color: selected
                      ? colorScheme.onSecondaryContainer
                      : colorScheme.onSurfaceVariant,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTwoRowFreeNodesTabs(
    List<Group> groups,
    String? currentGroupName,
  ) {
    final pairCount = (groups.length / 2).ceil();
    return SizedBox(
      height: 88,
      child: Stack(
        alignment: AlignmentDirectional.centerStart,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 16, right: 64),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var pairIndex = 0; pairIndex < pairCount; pairIndex++)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildGroupTabLabel(
                          groups[pairIndex * 2].name,
                          selected:
                              groups[pairIndex * 2].name == currentGroupName,
                        ),
                        const SizedBox(height: 6),
                        if (pairIndex * 2 + 1 < groups.length)
                          _buildGroupTabLabel(
                            groups[pairIndex * 2 + 1].name,
                            selected:
                                groups[pairIndex * 2 + 1].name ==
                                currentGroupName,
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          Positioned(
            right: 0,
            top: 20,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    context.colorScheme.surface.opacity10,
                    context.colorScheme.surface,
                  ],
                  stops: const [0.0, 0.22],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 12),
                child: _buildMoreButton(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSingleRowTabs(List<Group> groups) {
    return NotificationListener<ScrollMetricsNotification>(
      onNotification: (scrollNotification) {
        _hasMoreButtonNotifier.value =
            scrollNotification.metrics.maxScrollExtent > 0;
        return false;
      },
      child: ValueListenableBuilder(
        valueListenable: _hasMoreButtonNotifier,
        builder: (_, value, child) {
          return Stack(
            alignment: AlignmentDirectional.centerStart,
            children: [
              TabBar(
                controller: _tabController,
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16 + (value ? 16 : 0),
                ),
                dividerColor: Colors.transparent,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                tabs: [
                  for (final group in groups)
                    Tab(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onLongPress: canShowFreeNodesGroupMenu(group.name)
                            ? () => showFreeNodesGroupMenu(context, group.name)
                            : null,
                        child: Builder(
                          builder: (context) {
                            return EmojiText(
                              group.name,
                              style: DefaultTextStyle.of(context).style,
                            );
                          },
                        ),
                      ),
                    ),
                ],
              ),
              if (value) Positioned(right: 0, child: child!),
            ],
          );
        },
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                context.colorScheme.surface.opacity10,
                context.colorScheme.surface,
              ],
              stops: const [0.0, 0.1],
            ),
          ),
          child: _buildMoreButton(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    ref.watch(themeSettingProvider.select((state) => state.textScale));
    final state = ref.watch(proxiesTabStateProvider.select((state) => state));
    final proxiesLayout = ref.watch(
      proxiesStyleSettingProvider.select((state) => state.layout),
    );
    final groups = state.groups;
    final isFreeNodesProfile = ref.watch(
      currentProfileProvider.select(
        (profile) => profile?.isFreeNodesProfile ?? false,
      ),
    );
    if (groups.isEmpty || _tabController == null) {
      return NullStatus(
        illustration: const ProxyEmptyIllustration(),
        label: appLocalizations.nullTip(appLocalizations.proxies),
      );
    }
    _keyMap = {};
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (shouldUseTwoRowFreeNodesGroupTabs(
          isFreeNodesProfile: isFreeNodesProfile,
          groupCount: groups.length,
        ))
          _buildTwoRowFreeNodesTabs(groups, state.currentGroupName)
        else
          _buildSingleRowTabs(groups),
        Expanded(
          child: LayoutBuilder(
            builder: (_, constraints) {
              final columns = utils.getProxiesColumns(
                max(constraints.maxWidth - 32, 0),
                proxiesLayout,
              );
              return TabBarView(
                controller: _tabController,
                children: [
                  for (final group in groups)
                    ProxyGroupView(
                      key: _keyMap.updateCacheValue(
                        group.name,
                        () => GlobalObjectKey<_ProxyGroupViewState>(group.name),
                      ),
                      group: group,
                      columns: columns,
                      cardType: state.proxyCardType,
                    ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class ProxyGroupView extends ConsumerStatefulWidget {
  final Group group;
  final int columns;
  final ProxyCardType cardType;

  const ProxyGroupView({
    super.key,
    required this.group,
    required this.columns,
    required this.cardType,
  });

  @override
  ConsumerState<ProxyGroupView> createState() => _ProxyGroupViewState();
}

class _ProxyGroupViewState extends ConsumerState<ProxyGroupView> {
  late final ScrollController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
  }

  PageStorageKey _getPageStorageKey() {
    final profile = globalState.container.read(currentProfileProvider);
    final key =
        '${profile?.id}_${ScrollPositionCacheKey.proxiesTabList.name}_${widget.group.name}';
    return ProxiesTabView.pageListStoreMap.updateCacheValue(
      key,
      () => PageStorageKey(key),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void scrollToSelected() {
    if (_controller.position.maxScrollExtent == 0) {
      return;
    }
    _controller.animateTo(
      min(
        16 +
            getScrollToSelectedOffset(
              groupName: widget.group.name,
              proxies: widget.group.all,
              columns: widget.columns,
            ),
        _controller.position.maxScrollExtent,
      ),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeIn,
    );
  }

  @override
  Widget build(BuildContext context) {
    final group = widget.group;
    final proxies = group.all;
    return CommonScrollBar(
      controller: _controller,
      child: GridView.builder(
        key: _getPageStorageKey(),
        controller: _controller,
        padding: const EdgeInsets.only(
          top: 16,
          left: 16,
          right: 16,
          bottom: 96,
        ),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: widget.columns,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          mainAxisExtent: getItemHeight(widget.cardType),
        ),
        itemCount: proxies.length,
        itemBuilder: (_, index) {
          final proxy = proxies[index];
          return ProxyCard(
            testUrl: group.testUrl,
            groupType: group.type,
            type: widget.cardType,
            proxy: proxy,
            groupName: group.name,
          );
        },
      ),
    );
  }
}

class DelayTestButton extends StatefulWidget {
  final Future Function() onClick;

  const DelayTestButton({super.key, required this.onClick});

  @override
  State<DelayTestButton> createState() => _DelayTestButtonState();
}

class _DelayTestButtonState extends State<DelayTestButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  Future<void> _healthcheck() async {
    if (_controller.isAnimating) {
      return;
    }
    _controller.forward();
    try {
      await widget.onClick();
    } catch (error) {
      commonPrint.log(
        'Delay test action failed: $error',
        logLevel: LogLevel.warning,
      );
    } finally {
      if (mounted) {
        _controller.reverse();
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _animation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutBack),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return AnimatedBuilder(
      animation: _controller.view,
      builder: (_, child) {
        return FadeTransition(
          opacity: _animation,
          child: ScaleTransition(scale: _animation, child: child),
        );
      },
      child: CommonFloatingActionButton(
        onPressed: _healthcheck,
        label: appLocalizations.delayTest,
        icon: const Icon(Icons.network_ping),
      ),
    );
  }
}
