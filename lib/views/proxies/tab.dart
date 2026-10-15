import 'dart:async';
import 'dart:math';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/common.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/ui/icons/icons.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'card.dart';
import 'common.dart';

class ProxiesTabView extends ConsumerStatefulWidget {
  const ProxiesTabView({super.key});

  static Map<String, PageStorageKey> pageListStoreMap = {};

  @override
  ConsumerState<ProxiesTabView> createState() => ProxiesTabViewState();
}

class ProxiesTabViewState extends ConsumerState<ProxiesTabView>
    with TickerProviderStateMixin {
  TabController? _tabController;
  final Map<String, ScrollController> _scrollControllers = {};
  int _columns = 1;

  @override
  void initState() {
    super.initState();
    ref.listenManual(proxiesTabControllerStateProvider, (prev, next) {
      if (prev == next) {
        return;
      }
      if (!stringListEquality.equals(prev?.groupNames, next.groupNames)) {
        final groupNames = next.groupNames;
        final currentGroupName = next.currentGroupName;
        final index = groupNames.indexWhere((item) => item == currentGroupName);
        _updateTabController(groupNames.length, index);
      }
    }, fireImmediately: true);
  }

  @override
  void dispose() {
    _destroyTabController();
    for (final controller in _scrollControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  ScrollController _scrollControllerOf(String groupName) {
    return _scrollControllers.putIfAbsent(
      groupName,
      () => sheetScrollController(context),
    );
  }

  // The page of a dropped group still holds its controller until this frame
  // unmounts it.
  void _pruneScrollControllers(List<Group> groups) {
    final names = {for (final group in groups) group.name};
    final dropped = [
      for (final entry in _scrollControllers.entries)
        if (!names.contains(entry.key)) entry,
    ];
    for (final entry in dropped) {
      _scrollControllers.remove(entry.key);
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => entry.value.dispose(),
      );
    }
  }

  void scrollToGroupSelected() {
    final group = currentGroup;
    final controller = _scrollControllers[group?.name];
    if (group == null || controller == null) {
      return;
    }
    final cardType = ref.read(proxiesTabStateProvider).proxyCardType;
    final rowOffset = selectedRowOffset(
      proxies: group.all,
      selectedProxyName: ref.read(selectedProxyNameProvider(group.name)),
      columns: _columns,
      rowExtent: getRowExtent(cardType),
    );
    if (rowOffset == null) {
      return;
    }
    animateScrollTo(controller, rowOffset);
  }

  Future<void> delayTestCurrentGroup() async {
    final group = currentGroup;
    if (group == null) {
      return;
    }
    await ref
        .read(proxiesActionProvider.notifier)
        .delayTestPageGroup(group.name);
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

  void _tabControllerListener([int? index]) {
    final group = _getGroup(index ?? _tabController?.index);
    if (group == null) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      ref
          .read(proxiesActionProvider.notifier)
          .updateCurrentGroupName(group.name);
    });
  }

  void _destroyTabController() {
    _tabController?.removeListener(_tabControllerListener);
    _tabController?.dispose();
    _tabController = null;
  }

  // An empty group list keeps the previous controller: the outgoing tab bar
  // still drives it while the empty state animates in.
  void _updateTabController(int length, int index) {
    if (length == 0) {
      return;
    }
    _destroyTabController();
    final realIndex = index == -1 ? 0 : index;
    final controller = TabController(
      length: length,
      initialIndex: realIndex,
      vsync: this,
    );
    _tabController = controller;
    _tabControllerListener(realIndex);
    controller.addListener(_tabControllerListener);
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    ref.watch(themeSettingProvider.select((state) => state.textScale));
    final groups = ref.watch(
      proxiesTabStateProvider.select((state) => state.groups),
    );
    final cardType = ref.watch(
      proxiesTabStateProvider.select((state) => state.proxyCardType),
    );
    final proxiesLayout = ref.watch(
      proxiesStyleSettingProvider.select((state) => state.layout),
    );
    final isSearching = ref.watch(
      queryProvider(
        QueryTag.proxies,
      ).select((query) => SearchQuery(query).isNotEmpty),
    );
    _pruneScrollControllers(groups);
    final controller = _tabController;
    return NullStatusSwitcher(
      isEmpty: groups.isEmpty || controller == null,
      isSearching: isSearching,
      nullStatus: NullStatus(
        illustration: NullStatusIllustration.proxies,
        label: appLocalizations.nullTip(appLocalizations.proxies),
      ),
      child: controller == null
          ? const SizedBox.shrink()
          : AppBarClearance(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 4, bottom: 16),
                    child: _GroupTabs(controller: controller, groups: groups),
                  ),
                  Expanded(
                    child: WidthBuilder(
                      builder: (_, width) {
                        final columns = getProxiesColumns(
                          max(width - 32, 0),
                          proxiesLayout,
                        );
                        _columns = columns;
                        return TabBarView(
                          controller: controller,
                          children: [
                            for (final group in groups)
                              ProxyGroupView(
                                key: ValueKey(group.name),
                                controller: _scrollControllerOf(group.name),
                                group: group,
                                columns: columns,
                                cardType: cardType,
                              ),
                          ],
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

class _GroupTabs extends StatefulWidget {
  const _GroupTabs({required this.controller, required this.groups});

  final TabController controller;
  final List<Group> groups;

  @override
  State<_GroupTabs> createState() => _GroupTabsState();
}

class _GroupTabsState extends State<_GroupTabs> {
  static const _fadeExtent = 24.0;

  final _hasMore = ValueNotifier(false);
  final _fade = ValueNotifier(0.0);
  final Map<String, GlobalKey> _tabKeys = {};
  late final _selected = ValueNotifier(widget.controller.index);

  @override
  void initState() {
    super.initState();
    _follow(widget.controller);
  }

  @override
  void didUpdateWidget(_GroupTabs oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.animation?.removeListener(_handleAnimation);
      _follow(widget.controller);
    }
  }

  @override
  void dispose() {
    widget.controller.animation?.removeListener(_handleAnimation);
    _hasMore.dispose();
    _fade.dispose();
    _selected.dispose();
    super.dispose();
  }

  void _follow(TabController controller) {
    _selected.value = controller.index;
    controller.animation!.addListener(_handleAnimation);
    WidgetsBinding.instance.addPostFrameCallback((_) => _reveal(jump: true));
  }

  // A tap animates across every tab between; only a swipe's passes count.
  void _handleAnimation() {
    final controller = widget.controller;
    final index = controller.indexIsChanging
        ? controller.index
        : controller.animation!.value.round();
    if (index == _selected.value) {
      return;
    }
    _selected.value = index;
    _reveal();
  }

  // The strip owns no controller: a sheet's would hand its drags to the sheet.
  void _reveal({bool jump = false}) {
    if (!mounted) {
      return;
    }
    final name = widget.groups.elementAtOrNull(_selected.value)?.name;
    final tab = _tabKeys[name]?.currentContext;
    final position = tab == null ? null : Scrollable.maybeOf(tab)?.position;
    if (tab == null || position == null) {
      return;
    }
    position.ensureVisible(
      tab.findRenderObject()!,
      alignment: 0.5,
      duration: jump ? Duration.zero : commonDuration,
      curve: Curves.easeOutCubic,
    );
  }

  void _select(int index) {
    widget.controller.animateTo(index);
  }

  bool _handleMetrics(ScrollMetrics metrics) {
    _fade.value = (metrics.extentAfter / _fadeExtent).clamp(0.0, 1.0);
    final hasMore = metrics.maxScrollExtent > 0;
    if (hasMore != _hasMore.value) {
      _hasMore.value = hasMore;
      // The more button narrows the tabs it overflows.
      WidgetsBinding.instance.addPostFrameCallback((_) => _reveal(jump: true));
    }
    return false;
  }

  Shader _buildEdgeFade(Rect bounds, double fade) {
    return LinearGradient(
      begin: AlignmentDirectional.centerStart,
      end: AlignmentDirectional.centerEnd,
      colors: [
        Colors.black,
        Colors.black.withValues(alpha: 1 - fade),
      ],
      stops: [max(0.0, 1 - _fadeExtent / bounds.width), 1],
    ).createShader(bounds, textDirection: Directionality.of(context));
  }

  Widget _buildMoreButton() {
    return TonalButtonTheme(
      size: TonalButtonSize.section,
      child: ElasticPress(
        child: CommonPopupBox(
          targetBuilder: (open) => IconButton(
            tooltip: context.appLocalizations.proxyGroup,
            onPressed: open,
            icon: const GlyphIcon(AppGlyphs.chevronDown),
          ),
          popupBuilder: (_) => CommonPopupMenu(
            maxVisibleItems: 7,
            items: [
              for (final (index, group) in widget.groups.indexed)
                CommonPopupMenuItem(
                  label: group.name,
                  checked: index == widget.controller.index,
                  onPressed: () => _select(index),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final names = {for (final group in widget.groups) group.name};
    _tabKeys.removeWhere((name, _) => !names.contains(name));
    final tabs = Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 8,
      children: [
        for (final (index, group) in widget.groups.indexed)
          _GroupTab(
            key: _tabKeys.putIfAbsent(group.name, GlobalKey.new),
            name: group.name,
            index: index,
            selected: _selected,
            onPressed: () => _select(index),
          ),
      ],
    );
    return SizedBox(
      height: TonalButtonSize.section.button,
      child: ValueListenableBuilder(
        valueListenable: _hasMore,
        builder: (_, hasMore, moreButton) {
          return Row(
            children: [
              Expanded(
                child: NotificationListener<ScrollMetricsNotification>(
                  onNotification: (notification) =>
                      _handleMetrics(notification.metrics),
                  child: NotificationListener<ScrollUpdateNotification>(
                    onNotification: (notification) =>
                        _handleMetrics(notification.metrics),
                    child: ValueListenableBuilder(
                      valueListenable: _fade,
                      builder: (_, fade, child) => ShaderMask(
                        blendMode: BlendMode.dstIn,
                        shaderCallback: (bounds) =>
                            _buildEdgeFade(bounds, fade),
                        child: child,
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsetsDirectional.only(
                          start: 16,
                          end: hasMore ? 0 : 16,
                        ),
                        child: tabs,
                      ),
                    ),
                  ),
                ),
              ),
              if (hasMore)
                Padding(
                  padding: const EdgeInsetsDirectional.only(start: 8, end: 16),
                  child: moreButton,
                ),
            ],
          );
        },
        child: _buildMoreButton(),
      ),
    );
  }
}

/// Rebuilds only when it gains or loses the selection, so a swipe across
/// hundreds of groups rebuilds two tabs per step instead of the strip.
class _GroupTab extends StatefulWidget {
  const _GroupTab({
    super.key,
    required this.name,
    required this.index,
    required this.selected,
    required this.onPressed,
  });

  final String name;
  final int index;
  final ValueListenable<int> selected;
  final VoidCallback onPressed;

  @override
  State<_GroupTab> createState() => _GroupTabState();
}

class _GroupTabState extends State<_GroupTab> {
  late bool _isSelected;

  @override
  void initState() {
    super.initState();
    _isSelected = widget.selected.value == widget.index;
    widget.selected.addListener(_handleSelected);
  }

  @override
  void didUpdateWidget(_GroupTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selected != widget.selected) {
      oldWidget.selected.removeListener(_handleSelected);
      widget.selected.addListener(_handleSelected);
    }
    _isSelected = widget.selected.value == widget.index;
  }

  @override
  void dispose() {
    widget.selected.removeListener(_handleSelected);
    super.dispose();
  }

  void _handleSelected() {
    final isSelected = widget.selected.value == widget.index;
    if (isSelected != _isSelected) {
      setState(() => _isSelected = isSelected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final selected = _isSelected;
    final name = widget.name;
    final onPressed = widget.onPressed;
    final colorScheme = context.colorScheme;
    return CommonCard(
      isSelected: selected,
      fillsSelection: true,
      shape: AppShape.full,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      onPressed: onPressed,
      child: AnimatedDefaultTextStyle(
        duration: midDuration,
        style: AppTextStyle.subheadline
            .of(context, emphasized: true)
            .copyWith(
              color: selected
                  ? colorScheme.onPrimary
                  : colorScheme.onSurfaceVariant,
            ),
        child: EmojiText(name, maxLines: 1),
      ),
    );
  }
}

class ProxyGroupView extends ConsumerWidget {
  final Group group;
  final ScrollController controller;
  final int columns;
  final ProxyCardType cardType;

  const ProxyGroupView({
    super.key,
    required this.group,
    required this.controller,
    required this.columns,
    required this.cardType,
  });

  PageStorageKey _getPageStorageKey(WidgetRef ref) {
    final profile = ref.read(currentProfileProvider);
    final key =
        '${profile?.id}_${ScrollPositionCacheKey.proxiesTabList.name}_${group.name}';
    return ProxiesTabView.pageListStoreMap.updateCacheValue(
      key,
      () => PageStorageKey(key),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final proxies = group.all;
    return CommonScrollBar(
      controller: controller,
      thumbVisibility: true,
      child: GridView.builder(
        key: _getPageStorageKey(ref),
        controller: controller,
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          bottom: 16 + BottomInsetScope.of(context),
        ),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          mainAxisSpacing: proxyGridSpacing,
          crossAxisSpacing: 8,
          mainAxisExtent: getItemHeight(cardType),
        ),
        itemCount: proxies.length,
        addAutomaticKeepAlives: false,
        itemBuilder: (_, index) {
          final proxy = proxies[index];
          return ProxyCard(
            testUrl: group.testUrl,
            groupType: group.type,
            type: cardType,
            proxy: proxy,
            groupName: group.name,
          );
        },
      ),
    );
  }
}
