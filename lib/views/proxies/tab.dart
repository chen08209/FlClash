import 'dart:async';
import 'dart:math';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/common/free_nodes.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/clash_config.dart';
import 'package:fl_clash/models/common.dart';
import 'package:fl_clash/models/profile.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'card.dart';
import 'common.dart';
import 'free_nodes_group_menu.dart';

typedef ProxyGroupViewKeyMap =
    Map<String, GlobalObjectKey<_ProxyGroupViewState>>;

const _proxyGroupLongPressDelay = Duration(milliseconds: 360);
const _proxyGroupMoveTolerance = kTouchSlop * 6;
const _proxyGroupHardDragMoveTolerance = kTouchSlop * 12;

@visibleForTesting
bool shouldUseScrollableProxyGroupTabs({
  required int groupCount,
  required double maxWidth,
}) {
  if (groupCount <= 0) return false;
  if (!maxWidth.isFinite || maxWidth <= 0) return groupCount > 3;
  const horizontalPadding = 32.0;
  final requiredWidth =
      groupCount * _ProxyGroupTabLabel.minInteractiveWidth + horizontalPadding;
  return requiredWidth > maxWidth;
}

@visibleForTesting
bool shouldCancelProxyGroupTabLongPressOnScrollNotification(
  ScrollNotification notification,
) {
  return false;
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

class ProxiesTabView extends ConsumerStatefulWidget {
  const ProxiesTabView({super.key});

  static Map<String, PageStorageKey> pageListStoreMap = {};

  @override
  ConsumerState<ProxiesTabView> createState() => ProxiesTabViewState();
}

class ProxiesTabViewState extends ConsumerState<ProxiesTabView>
    with TickerProviderStateMixin {
  TabController? _tabController;
  ProxyGroupViewKeyMap _keyMap = {};
  DateTime? _lastGroupMenuOpenAt;
  String? _lastGroupMenuOpenName;
  Future<void>? _delayTestOperation;

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
    final currentGroupName = getCurrentGroupName();
    _keyMap[currentGroupName]?.currentState?.scrollToSelected();
  }

  Future<void> delayTestCurrentGroup() async {
    final runningOperation = _delayTestOperation;
    if (runningOperation != null) {
      await runningOperation;
      return;
    }

    final state = ref.read(proxiesTabStateProvider);
    final groups = _visibleGroups(
      state.groups,
      ref.read(currentProfileProvider),
    );
    final group = resolveCurrentDelayTestGroup(
      groups: groups,
      activeIndex: _tabController?.index,
      selectedGroupName: state.currentGroupName,
    );
    if (group == null || group.all.isEmpty) return;

    final operation = delayTest(
      List<Proxy>.unmodifiable(group.all),
      group.testUrl,
    );
    _delayTestOperation = operation;
    try {
      await operation;
    } finally {
      if (identical(_delayTestOperation, operation)) {
        _delayTestOperation = null;
      }
    }
  }

  Widget _buildMoreButton({
    required String currentGroupName,
    required bool canOpenCurrentGroupMenu,
  }) {
    return Consumer(
      builder: (_, ref, _) {
        final isMobileView = ref.watch(isMobileViewProvider);
        final icon = canOpenCurrentGroupMenu
            ? Icons.more_vert
            : isMobileView
            ? Icons.expand_more
            : Icons.chevron_right;
        final opensFreeNodesSwitch =
            _shouldOpenFreeNodesDateSwitchFromMoreButton(currentGroupName);
        final onTap = opensFreeNodesSwitch
            ? _showFreeNodesDateSwitchMenu
            : _showMoreMenu;
        final onLongPress = canOpenCurrentGroupMenu
            ? () => _openFreeNodesActionMenuNow(currentGroupName)
            : onTap;
        return Tooltip(
          message: context.appLocalizations.proxyGroup,
          child: Semantics(
            button: true,
            onTap: onTap,
            onLongPress: onLongPress,
            child: InkResponse(
              key: const ValueKey('proxy-group-category-action-button'),
              onTap: onTap,
              onLongPress: onLongPress,
              radius: 24,
              containedInkWell: true,
              child: Center(child: Icon(icon)),
            ),
          ),
        );
      },
    );
  }

  bool _shouldOpenFreeNodesDateSwitchFromMoreButton(String groupName) {
    return isActionableFreeNodesGroupName(groupName);
  }

  void _showFreeNodesDateSwitchMenu() {
    showSheet(
      context: context,
      props: const SheetProps(isScrollControlled: false),
      builder: (_) {
        return AdaptiveSheetScaffold(
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Consumer(
              builder: (_, ref, _) {
                final state = ref.watch(proxiesTabStateProvider);
                final groups = freeNodesDateSwitchGroups(
                  ref.watch(groupsProvider),
                );
                final groupNames = groups.map((group) => group.name).toList();
                final normalizedCurrentGroupName =
                    state.currentGroupName == null
                    ? null
                    : normalizeFreeNodesGroupName(state.currentGroupName!);
                final currentGroupName =
                    groupNames.contains(normalizedCurrentGroupName)
                    ? normalizedCurrentGroupName
                    : null;
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 8,
                  children: [
                    for (final groupName in groupNames)
                      SizedBox(
                        width: double.infinity,
                        child: SettingTextCard(
                          groupName,
                          onPressed: () {
                            final index = groupNames.indexWhere(
                              (item) => item == groupName,
                            );
                            if (index == -1) return;
                            final tabState = ref.read(proxiesTabStateProvider);
                            final visibleGroups = _visibleGroups(
                              tabState.groups,
                              ref.read(currentProfileProvider),
                            );
                            final visibleIndex = visibleGroups.indexWhere(
                              (group) => group.name == groupName,
                            );
                            if (visibleIndex >= 0) {
                              _tabController?.animateTo(visibleIndex);
                            }
                            updateCurrentGroupName(groupName);
                            Navigator.of(context).pop();
                          },
                          isSelected: groupName == currentGroupName,
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
          title: '切换日期或优选节点',
        );
      },
    );
  }

  void _showMoreMenu() {
    final parentContext = context;
    showSheet(
      context: context,
      props: const SheetProps(isScrollControlled: false),
      builder: (_) {
        return AdaptiveSheetScaffold(
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Consumer(
              builder: (_, ref, _) {
                final state = ref.watch(proxiesTabStateProvider);
                final groups = _visibleGroups(
                  state.groups,
                  ref.watch(currentProfileProvider),
                );
                final groupNames = groups.map((group) => group.name).toList();
                final currentGroupName = _visibleCurrentGroupName(
                  groups,
                  state.currentGroupName,
                );
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 8,
                  children: [
                    for (final groupName in groupNames)
                      SizedBox(
                        width: double.infinity,
                        child: SettingTextCard(
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
                          onLongPress: () {
                            Navigator.of(context).pop();
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (!mounted) return;
                              showFreeNodesGroupMenu(parentContext, groupName);
                            });
                          },
                          isSelected: groupName == currentGroupName,
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
          title: context.appLocalizations.proxyGroup,
        );
      },
    );
  }

  List<Group> _visibleGroups(List<Group> groups, Profile? profile) {
    return shouldFilterVisibleFreeNodesGroups(groups: groups, profile: profile)
        ? normalizeVisibleFreeNodesGroups(
            groups,
            selectedGroupName: getCurrentGroupName(),
          )
        : groups;
  }

  String? _visibleCurrentGroupName(List<Group> groups, String? groupName) {
    if (groups.isEmpty) return groupName;
    final normalizedGroupName = groupName == null
        ? null
        : normalizeFreeNodesGroupName(groupName);
    final hasCurrent = groups.any((group) => group.name == normalizedGroupName);
    return hasCurrent ? normalizedGroupName : groups.first.name;
  }

  bool _canOpenCurrentGroupMenu(
    String? groupName,
    List<Group> groups,
    Profile? profile,
  ) {
    if (groupName == null || groupName.trim().isEmpty) return false;
    if (isActionableFreeNodesGroupName(groupName)) return true;
    if (!shouldFilterVisibleFreeNodesGroups(groups: groups, profile: profile)) {
      return false;
    }
    final normalizedGroupName = normalizeFreeNodesGroupName(groupName);
    return groups.any(
      (group) => normalizeFreeNodesGroupName(group.name) == normalizedGroupName,
    );
  }

  void _tabControllerListener([int? index]) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      int? groupIndex = index;
      if (groupIndex == -1) {
        return;
      }
      if (groupIndex == null) {
        final currentIndex = _tabController?.index;
        groupIndex = currentIndex;
      }
      final tabState = ref.read(proxiesTabStateProvider);
      final currentGroups = _visibleGroups(
        tabState.groups,
        ref.read(currentProfileProvider),
      );
      if (groupIndex == null || groupIndex >= currentGroups.length) {
        return;
      }
      final currentGroup = currentGroups[groupIndex];
      updateCurrentGroupName(currentGroup.name);
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

  void _openFreeNodesGroupMenuNow(String groupName) {
    if (!mounted) return;
    final normalizedGroupName = normalizeFreeNodesGroupName(groupName);
    if (normalizedGroupName == freeNodesGroupName) {
      _showFreeNodesDateSwitchMenu();
      return;
    }
    _openFreeNodesActionMenuNow(normalizedGroupName);
  }

  void _openFreeNodesActionMenuNow(String groupName) {
    if (!mounted) return;
    final normalizedGroupName = normalizeFreeNodesGroupName(groupName);
    final now = DateTime.now();
    final lastOpenAt = _lastGroupMenuOpenAt;
    if (_lastGroupMenuOpenName == normalizedGroupName &&
        lastOpenAt != null &&
        now.difference(lastOpenAt) < const Duration(milliseconds: 700)) {
      return;
    }
    _lastGroupMenuOpenName = normalizedGroupName;
    _lastGroupMenuOpenAt = now;
    unawaited(showFreeNodesGroupMenu(context, normalizedGroupName));
  }

  void _selectGroup(int index, String groupName) {
    _tabController?.animateTo(index);
    updateCurrentGroupName(groupName);
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    ref.watch(themeSettingProvider.select((state) => state.textScale));
    final state = ref.watch(proxiesTabStateProvider.select((state) => state));
    final currentProfile = ref.watch(currentProfileProvider);
    final groups = _visibleGroups(state.groups, currentProfile);
    final currentGroupName = _visibleCurrentGroupName(
      groups,
      state.currentGroupName,
    );
    if (groups.isEmpty || _tabController == null) {
      return NullStatus(
        illustration: const ProxyEmptyIllustration(),
        label: appLocalizations.nullTip(appLocalizations.proxies),
      );
    }
    final currentIndex = groups.indexWhere(
      (group) => group.name == currentGroupName,
    );
    if (_tabController?.length != groups.length) {
      _updateTabController(groups.length, currentIndex);
    }
    _keyMap = {};
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final useScrollableTabs = shouldUseScrollableProxyGroupTabs(
              groupCount: groups.length,
              maxWidth: constraints.maxWidth,
            );
            return _ProxyGroupTabBar(
              groups: groups,
              selectedGroupName:
                  currentGroupName ?? getCurrentGroupName() ?? '',
              useScrollableTabs: useScrollableTabs,
              moreButton: _buildMoreButton(
                currentGroupName:
                    currentGroupName ?? getCurrentGroupName() ?? '',
                canOpenCurrentGroupMenu: _canOpenCurrentGroupMenu(
                  currentGroupName,
                  groups,
                  currentProfile,
                ),
              ),
              onTap: _selectGroup,
              onLongPress: _openFreeNodesGroupMenuNow,
            );
          },
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              for (final group in groups)
                ProxyGroupView(
                  key: _keyMap.updateCacheValue(
                    group.name,
                    () => GlobalObjectKey<_ProxyGroupViewState>(group.name),
                  ),
                  group: group,
                  columns: state.columns,
                  cardType: state.proxyCardType,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProxyGroupTabBar extends StatefulWidget {
  const _ProxyGroupTabBar({
    required this.groups,
    required this.selectedGroupName,
    required this.useScrollableTabs,
    required this.moreButton,
    required this.onTap,
    required this.onLongPress,
  });

  final List<Group> groups;
  final String selectedGroupName;
  final bool useScrollableTabs;
  final Widget moreButton;
  final void Function(int index, String groupName) onTap;
  final ValueChanged<String> onLongPress;

  @override
  State<_ProxyGroupTabBar> createState() => _ProxyGroupTabBarState();
}

class _ProxyGroupTabBarState extends State<_ProxyGroupTabBar> {
  int _longPressCancelGeneration = 0;

  void _cancelPendingLongPresses() {
    if (!mounted) return;
    setState(() {
      _longPressCancelGeneration++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final tabs = [
      for (var index = 0; index < widget.groups.length; index++)
        ProxyGroupTab(
          groupName: widget.groups[index].name,
          fillWidth: !widget.useScrollableTabs,
          isSelected: widget.groups[index].name == widget.selectedGroupName,
          onTap: () => widget.onTap(index, widget.groups[index].name),
          onLongPress: () => widget.onLongPress(widget.groups[index].name),
          longPressCancelGeneration: _longPressCancelGeneration,
          cancelOnEarlyHorizontalDrag: true,
        ),
    ];

    final tabContent = widget.useScrollableTabs
        ? NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (shouldCancelProxyGroupTabLongPressOnScrollNotification(
                notification,
              )) {
                _cancelPendingLongPresses();
              }
              return false;
            },
            child: SingleChildScrollView(
              key: const ValueKey('proxy-group-tab-bar-scroll-view'),
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(left: 16),
              child: Row(children: tabs),
            ),
          )
        : Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [for (final tab in tabs) Expanded(child: tab)],
            ),
          );

    return SizedBox(
      key: const ValueKey('proxy-group-tab-bar'),
      width: double.infinity,
      height: 48,
      child: Row(
        children: [
          Expanded(child: tabContent),
          SizedBox(width: 48, height: 48, child: widget.moreButton),
        ],
      ),
    );
  }
}

@visibleForTesting
class ProxyGroupTab extends StatelessWidget implements PreferredSizeWidget {
  const ProxyGroupTab({
    super.key,
    required this.groupName,
    required this.onLongPress,
    this.fillWidth = false,
    this.isSelected = false,
    this.onTap,
    this.onPointerDown,
    this.useInternalLongPressTimer = true,
    this.longPressCancelGeneration = 0,
    this.cancelOnEarlyHorizontalDrag = false,
  });

  final String groupName;
  final VoidCallback onLongPress;
  final bool fillWidth;
  final bool isSelected;
  final VoidCallback? onTap;
  final ValueChanged<PointerDownEvent>? onPointerDown;
  final bool useInternalLongPressTimer;
  final int longPressCancelGeneration;
  final bool cancelOnEarlyHorizontalDrag;

  @override
  Size get preferredSize => const Size.fromHeight(48);

  @override
  Widget build(BuildContext context) {
    final label = _ProxyGroupTabLabel(
      groupName: groupName,
      fillWidth: fillWidth,
      isSelected: isSelected,
    );
    if (!useInternalLongPressTimer) {
      return KeyedSubtree(
        key: ValueKey('proxy-group-tab-$groupName'),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onLongPress: onLongPress,
          onSecondaryTap: onLongPress,
          child: Semantics(
            button: true,
            onTap: onTap,
            onLongPress: onLongPress,
            child: label,
          ),
        ),
      );
    }
    return _ProxyGroupLongPressRegion(
      key: ValueKey('proxy-group-tab-$groupName'),
      onLongPress: onLongPress,
      onTap: onTap,
      onPointerDown: onPointerDown,
      cancelGeneration: longPressCancelGeneration,
      cancelOnEarlyHorizontalDrag: cancelOnEarlyHorizontalDrag,
      child: label,
    );
  }
}

@visibleForTesting
class ProxyGroupTabLabel extends StatelessWidget {
  const ProxyGroupTabLabel({
    super.key,
    required this.groupName,
    required this.onLongPress,
    this.fillWidth = false,
    this.isSelected = false,
    this.onTap,
    this.onPointerDown,
  });

  final String groupName;
  final VoidCallback onLongPress;
  final bool fillWidth;
  final bool isSelected;
  final VoidCallback? onTap;
  final ValueChanged<PointerDownEvent>? onPointerDown;

  @override
  Widget build(BuildContext context) {
    return ProxyGroupTab(
      groupName: groupName,
      fillWidth: fillWidth,
      isSelected: isSelected,
      onTap: onTap,
      onLongPress: onLongPress,
      onPointerDown: onPointerDown,
    );
  }
}

class _ProxyGroupLongPressRegion extends StatefulWidget {
  const _ProxyGroupLongPressRegion({
    super.key,
    required this.onLongPress,
    required this.child,
    this.onTap,
    this.onPointerDown,
    this.cancelGeneration = 0,
    this.cancelOnEarlyHorizontalDrag = false,
  });

  final VoidCallback onLongPress;
  final VoidCallback? onTap;
  final ValueChanged<PointerDownEvent>? onPointerDown;
  final int cancelGeneration;
  final bool cancelOnEarlyHorizontalDrag;
  final Widget child;

  @override
  State<_ProxyGroupLongPressRegion> createState() =>
      _ProxyGroupLongPressRegionState();
}

class _ProxyGroupLongPressRegionState
    extends State<_ProxyGroupLongPressRegion> {
  Timer? _longPressTimer;
  Timer? _earlyDragCancelTimer;
  Offset? _pointerDownPosition;
  bool _canCancelAsEarlyDrag = false;
  bool _longPressTriggered = false;
  bool _longPressOpened = false;

  @override
  void dispose() {
    _cancelLongPressTimer();
    super.dispose();
  }

  @override
  void didUpdateWidget(_ProxyGroupLongPressRegion oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.cancelGeneration != widget.cancelGeneration) {
      _cancelLongPressTimer();
    }
  }

  void _startLongPressTimer(PointerDownEvent event) {
    _cancelLongPressTimer();
    _longPressTriggered = false;
    _longPressOpened = false;
    _canCancelAsEarlyDrag = true;
    _pointerDownPosition = event.position;
    if ((event.buttons & kSecondaryMouseButton) != 0) {
      _openLongPressMenu();
      return;
    }
    _earlyDragCancelTimer = Timer(const Duration(milliseconds: 220), () {
      _canCancelAsEarlyDrag = false;
      _earlyDragCancelTimer = null;
    });
    _longPressTimer = Timer(_proxyGroupLongPressDelay, () {
      _openLongPressMenu();
    });
  }

  void _cancelLongPressTimer() {
    _longPressTimer?.cancel();
    _earlyDragCancelTimer?.cancel();
    _longPressTimer = null;
    _earlyDragCancelTimer = null;
    _canCancelAsEarlyDrag = false;
    _pointerDownPosition = null;
  }

  void _openLongPressMenu() {
    if (_longPressOpened || !mounted) return;
    _longPressOpened = true;
    _longPressTriggered = true;
    _longPressTimer?.cancel();
    _earlyDragCancelTimer?.cancel();
    _longPressTimer = null;
    _earlyDragCancelTimer = null;
    _canCancelAsEarlyDrag = false;
    widget.onLongPress();
  }

  void _openReadyLongPressMenu() {
    if (!_longPressTriggered || !mounted) return;
    _openLongPressMenu();
  }

  void _handleTap() {
    if (_longPressOpened || _longPressTriggered) {
      _longPressOpened = false;
      _longPressTriggered = false;
      return;
    }
    widget.onTap?.call();
  }

  void _handlePointerMove(PointerMoveEvent event) {
    final pointerDownPosition = _pointerDownPosition;
    if (pointerDownPosition == null || _longPressTriggered) return;
    final distance = (event.position - pointerDownPosition).distance;
    if (distance <= _proxyGroupMoveTolerance) return;
    if (widget.cancelOnEarlyHorizontalDrag && _canCancelAsEarlyDrag) {
      _cancelLongPressTimer();
      return;
    }
    if (distance >= _proxyGroupHardDragMoveTolerance) {
      _cancelLongPressTimer();
    }
  }

  void _handlePointerCancel(PointerCancelEvent event) {
    if (_longPressTriggered) {
      _openReadyLongPressMenu();
      return;
    }
    // Keep the timer alive after a parent gesture cancels this pointer. On
    // Android tablets a horizontal scroll ancestor can cancel the child before
    // the long-press timeout, while the user's finger is still held in place.
    if (_longPressTimer == null) return;
  }

  void _finishPointer() {
    if (_longPressOpened) {
      _cancelLongPressTimer();
      _longPressTriggered = false;
      return;
    }
    _openReadyLongPressMenu();
    if (!_longPressTriggered) {
      _cancelLongPressTimer();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: (event) {
        widget.onPointerDown?.call(event);
        _startLongPressTimer(event);
      },
      onPointerMove: _handlePointerMove,
      onPointerCancel: _handlePointerCancel,
      onPointerUp: (_) => _finishPointer(),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap == null ? null : _handleTap,
        onSecondaryTap: _openLongPressMenu,
        child: Semantics(
          button: true,
          onTap: widget.onTap,
          onLongPress: widget.onLongPress,
          child: widget.child,
        ),
      ),
    );
  }
}

class _ProxyGroupTabLabel extends StatelessWidget {
  const _ProxyGroupTabLabel({
    required this.groupName,
    this.fillWidth = false,
    this.isSelected = false,
  });

  final String groupName;
  final bool fillWidth;
  final bool isSelected;
  static const double minInteractiveWidth = 112;

  @override
  Widget build(BuildContext context) {
    final labelStyle = DefaultTextStyle.of(context).style.merge(
      TextStyle(
        color: isSelected ? context.colorScheme.primary : null,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
      ),
    );
    final label = AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOut,
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            width: 2,
            color: isSelected
                ? context.colorScheme.primary
                : Colors.transparent,
          ),
        ),
      ),
      child: EmojiText(
        groupName,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: labelStyle,
      ),
    );
    return fillWidth
        ? SizedBox(width: double.infinity, height: 48, child: label)
        : ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: 48,
              minWidth: _ProxyGroupTabLabel.minInteractiveWidth,
            ),
            child: label,
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

  List<Proxy> currentProxies = [];
  String? testUrl;

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
              proxies: currentProxies,
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
    testUrl = group.testUrl;
    currentProxies = proxies;
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
        itemCount: currentProxies.length,
        itemBuilder: (_, index) {
          final proxy = currentProxies[index];
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
  final Future<void> Function() onClick;

  const DelayTestButton({super.key, required this.onClick});

  @override
  State<DelayTestButton> createState() => _DelayTestButtonState();
}

class _DelayTestButtonState extends State<DelayTestButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isRunning = false;

  Future<void> _healthcheck() async {
    if (_isRunning || _controller.isAnimating) {
      return;
    }
    _isRunning = true;
    _controller.forward();
    try {
      await widget.onClick();
    } catch (error) {
      commonPrint.log(
        'Proxy delay test failed: $error',
        logLevel: LogLevel.error,
      );
    } finally {
      _isRunning = false;
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
