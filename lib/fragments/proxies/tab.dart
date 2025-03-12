import 'dart:math';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/models/common.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'card.dart';
import 'common.dart';

List<Proxy> currentTabProxies = [];
String? currentTabTestUrl;

typedef GroupNameKeyMap = Map<String, GlobalObjectKey<ProxyGroupViewState>>;

class ProxiesTabFragment extends ConsumerStatefulWidget {
  const ProxiesTabFragment({super.key});

  @override
  ConsumerState<ProxiesTabFragment> createState() => ProxiesTabFragmentState();
}

class ProxiesTabFragmentState extends ConsumerState<ProxiesTabFragment>
    with TickerProviderStateMixin {
  TabController? _tabController;
  final _hasMoreButtonNotifier = ValueNotifier<bool>(false);
  GroupNameKeyMap _keyMap = {};

  @override
  void initState() {
    super.initState();
    _handleTabListen();
  }

  @override
  void dispose() {
    _destroyTabController();
    super.dispose();
  }

  scrollToGroupSelected() {
    final currentGroupName = globalState.appController.getCurrentGroupName();
    _keyMap[currentGroupName]?.currentState?.scrollToSelected();
  }

  _buildMoreButton() {
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

  _showMoreMenu() {
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
                final state = ref.watch(proxiesSelectorStateProvider);
                return SizedBox(
                  width: double.infinity,
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    runSpacing: 8,
                    spacing: 8,
                    children: [
                      for (final groupName in state.groupNames)
                        SettingTextCard(
                          groupName,
                          onPressed: () {
                            final index = state.groupNames.indexWhere(
                              (item) => item == groupName,
                            );
                            if (index == -1) return;
                            _tabController?.animateTo(index);
                            globalState.appController
                                .updateCurrentGroupName(groupName);
                            Navigator.of(context).pop();
                          },
                          isSelected: groupName == state.currentGroupName,
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

  _tabControllerListener([int? index]) {
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
    currentTabProxies = currentGroup.all;
    currentTabTestUrl = currentGroup.testUrl;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      globalState.appController.updateCurrentGroupName(
        currentGroup.name,
      );
    });
  }

  _destroyTabController() {
    _tabController?.removeListener(_tabControllerListener);
    _tabController?.dispose();
    _tabController = null;
  }

  _updateTabController(int length, int index) {
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

  _handleTabListen() {
    ref.listenManual(
      proxiesSelectorStateProvider,
      (prev, next) {
        if (prev == next) {
          return;
        }
        if (prev?.groupNames.length != next.groupNames.length) {
          _destroyTabController();
          final index = next.groupNames.indexWhere(
            (item) => item == next.currentGroupName,
          );
          _updateTabController(next.groupNames.length, index);
        }
      },
      fireImmediately: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(groupNamesStateProvider);
    final groupNames = state.groupNames;
    if (groupNames.isEmpty) {
      return NullStatus(
        label: appLocalizations.nullProxies,
      );
    }
    final GroupNameKeyMap keyMap = {};
    final children = groupNames.map((groupName) {
      keyMap[groupName] = GlobalObjectKey(groupName);
      return KeepScope(
        child: ProxyGroupView(
          key: keyMap[groupName],
          groupName: groupName,
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
            return true;
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
                      for (final groupName in groupNames)
                        Tab(
                          text: groupName,
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
  final String groupName;

  const ProxyGroupView({
    super.key,
    required this.groupName,
  });

  @override
  ConsumerState<ProxyGroupView> createState() => ProxyGroupViewState();
}

class ProxyGroupViewState extends ConsumerState<ProxyGroupView> {
  final _controller = ScrollController();

  String get groupName => widget.groupName;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  scrollToSelected() {
    if (_controller.position.maxScrollExtent == 0) {
      return;
    }

    final sortedProxies = globalState.appController.getSortProxies(
      currentTabProxies,
      currentTabTestUrl,
    );
    _controller.animateTo(
      min(
        16 +
            getScrollToSelectedOffset(
              groupName: groupName,
              proxies: sortedProxies,
            ),
        _controller.position.maxScrollExtent,
      ),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeIn,
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(proxyGroupSelectorStateProvider(groupName));
    final proxies = state.proxies;
    final columns = state.columns;
    final proxyCardType = state.proxyCardType;
    final sortedProxies = globalState.appController.getSortProxies(
      proxies,
      state.testUrl,
    );
    return Align(
      alignment: Alignment.topCenter,
      child: CommonAutoHiddenScrollBar(
        controller: _controller,
        child: GridView.builder(
          controller: _controller,
          padding: const EdgeInsets.only(
            top: 16,
            left: 16,
            right: 16,
            bottom: 96,
          ),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            mainAxisExtent: getItemHeight(proxyCardType),
          ),
          itemCount: sortedProxies.length,
          itemBuilder: (_, index) {
            final proxy = sortedProxies[index];
            return ProxyCard(
              testUrl: state.testUrl,
              groupType: state.groupType,
              type: proxyCardType,
              key: ValueKey('$groupName.${proxy.name}'),
              proxy: proxy,
              groupName: groupName,
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

  _healthcheck() async {
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
