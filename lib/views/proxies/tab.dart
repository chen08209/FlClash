import 'dart:math';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/config.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/common.dart';
import 'card.dart';
import 'common.dart';

typedef ProxyGroupViewKeyMap
    = Map<String, GlobalObjectKey<_ProxyGroupViewState>>;

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
    ref.listenManual(
      proxiesTabControllerStateProvider,
      (prev, next) {
        if (prev == next) {
          return;
        }
        if (!stringListEquality.equals(prev?.a, next.a)) {
          _destroyTabController();
          final index = next.a.indexWhere(
            (item) => item == next.b,
          );
          _updateTabController(next.a.length, index);
        }
      },
      fireImmediately: true,
    );
  }

  @override
  void dispose() {
    _destroyTabController();
    super.dispose();
  }

  void scrollToGroupSelected() {
    final currentGroupName = globalState.appController.getCurrentGroupName();
    _keyMap[currentGroupName]?.currentState?.scrollToSelected();
  }

  Future<void> delayTestCurrentGroup() async {
    final currentGroupName = globalState.appController.getCurrentGroupName();
    final currentState = _keyMap[currentGroupName]?.currentState;
    await delayTest(
      currentState?.proxies ?? [],
      currentState?.testUrl,
    );
  }

  Widget _buildMoreButton() {
    return Consumer(
      builder: (_, ref, ___) {
        final isMobileView = ref.watch(isMobileViewProvider);
        return IconButton(
          onPressed: _showMoreMenu,
          icon: isMobileView
              ? const Icon(
                  Icons.expand_more,
                )
              : const Icon(
                  Icons.chevron_right,
                ),
        );
      },
    );
  }

  void _showMoreMenu() {
    showSheet(
      context: context,
      props: SheetProps(
        isScrollControlled: false,
      ),
      builder: (_, type) {
        return AdaptiveSheetScaffold(
          type: type,
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Consumer(
              builder: (_, ref, __) {
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
                            globalState.appController
                                .updateCurrentGroupName(groupName);
                            Navigator.of(context).pop();
                          },
                          isSelected: groupName == currentGroupName,
                        )
                    ],
                  ),
                );
              },
            ),
          ),
          title: appLocalizations.proxyGroup,
        );
      },
    );
  }

  void _tabControllerListener([int? index]) {
    int? groupIndex = index;
    if (groupIndex == -1) {
      return;
    }
    final appController = globalState.appController;
    if (groupIndex == null) {
      final currentIndex = _tabController?.index;
      groupIndex = currentIndex;
    }
    final currentGroups = appController.getCurrentGroups();
    if (groupIndex == null || groupIndex > currentGroups.length) {
      return;
    }
    final currentGroup = currentGroups[groupIndex];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      globalState.appController.updateCurrentGroupName(
        currentGroup.name,
      );
    });
  }

  void _destroyTabController() {
    _tabController?.removeListener(_tabControllerListener);
    _tabController?.dispose();
    _tabController = null;
  }

  void _updateTabController(int length, int index) {
    if (length == 0) {
      _destroyTabController();
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

  @override
  Widget build(BuildContext context) {
    ref.watch(themeSettingProvider.select((state) => state.textScale));
    final state = ref.watch(proxiesTabStateProvider);
    final groups = state.groups;
    if (groups.isEmpty) {
      return NullStatus(
        label: appLocalizations.nullTip(appLocalizations.proxies),
      );
    }
    final ProxyGroupViewKeyMap keyMap = {};
    final children = groups.map((group) {
      final key = GlobalObjectKey<_ProxyGroupViewState>(group.name);
      keyMap[group.name] = key;
      return KeepScope(
        keep: true,
        child: ProxyGroupView(
          key: key,
          group: group,
          columns: state.columns,
          cardType: state.proxyCardType,
          sortType: state.proxiesSortType,
        ),
      );
    }).toList();
    _keyMap = keyMap;
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        NotificationListener<ScrollMetricsNotification>(
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
                    overlayColor:
                        const WidgetStatePropertyAll(Colors.transparent),
                    tabs: [
                      for (final group in groups)
                        Tab(
                          text: group.name,
                        ),
                    ],
                  ),
                  if (value)
                    Positioned(
                      right: 0,
                      child: child!,
                    ),
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
                    stops: const [
                      0.0,
                      0.1
                    ]),
              ),
              child: _buildMoreButton(),
            ),
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: children,
          ),
        )
      ],
    );
  }
}

class ProxyGroupView extends ConsumerStatefulWidget {
  final Group group;
  final int columns;
  final ProxyCardType cardType;
  final ProxiesSortType sortType;

  const ProxyGroupView({
    super.key,
    required this.group,
    required this.columns,
    required this.cardType,
    required this.sortType,
  });

  @override
  ConsumerState<ProxyGroupView> createState() => _ProxyGroupViewState();
}

class _ProxyGroupViewState extends ConsumerState<ProxyGroupView> {
  late final ScrollController _controller;

  List<Proxy> proxies = [];
  String? testUrl;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
  }

  PageStorageKey _getPageStorageKey() {
    final profile = globalState.config.currentProfile;
    final key =
        '${profile?.id}_${ScrollPositionCacheKeys.proxiesTabList.name}_${widget.group.name}';
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
              proxies: proxies,
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
    final sortedProxies = globalState.appController.getSortProxies(
      proxies: proxies,
      sortType: widget.sortType,
      testUrl: group.testUrl,
    );
    this.proxies = sortedProxies;
    testUrl = group.testUrl;

    return Align(
      alignment: Alignment.topCenter,
      child: CommonScrollBar(
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
          itemCount: sortedProxies.length,
          itemBuilder: (_, index) {
            final proxy = sortedProxies[index];
            return ProxyCard(
              testUrl: group.testUrl,
              groupType: group.type,
              type: widget.cardType,
              proxy: proxy,
              groupName: group.name,
            );
          },
        ),
      ),
    );
  }
}

class DelayTestButton extends StatefulWidget {
  final Future Function() onClick;

  const DelayTestButton({
    super.key,
    required this.onClick,
  });

  @override
  State<DelayTestButton> createState() => _DelayTestButtonState();
}

class _DelayTestButtonState extends State<DelayTestButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  Future<void> _healthcheck() async {
    if (_controller.isAnimating) {
      return;
    }
    _controller.forward();
    await widget.onClick();
    if (mounted) {
      _controller.reverse();
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 200,
      ),
    );
    _scale = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(
          0,
          1,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller.view,
      builder: (_, child) {
        return SizedBox(
          width: 56,
          height: 56,
          child: Transform.scale(
            scale: _scale.value,
            child: child,
          ),
        );
      },
      child: FloatingActionButton(
        heroTag: null,
        onPressed: _healthcheck,
        child: const Icon(Icons.network_ping),
      ),
    );
  }
}
