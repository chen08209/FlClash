import 'dart:math';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'card.dart';
import 'common.dart';

typedef GroupNameProxiesMap = Map<String, List<Proxy>>;

class ProxiesListFragment extends StatefulWidget {
  const ProxiesListFragment({super.key});

  @override
  State<ProxiesListFragment> createState() => _ProxiesListFragmentState();
}

class _ProxiesListFragmentState extends State<ProxiesListFragment> {
  final _controller = ScrollController();
  final _headerStateNotifier = ValueNotifier<ProxiesListHeaderSelectorState>(
    const ProxiesListHeaderSelectorState(
      offset: 0,
      currentIndex: 0,
    ),
  );
  List<double> _headerOffset = [];
  GroupNameProxiesMap _lastGroupNameProxiesMap = {};

  @override
  void initState() {
    super.initState();
    _controller.addListener(_adjustHeader);
  }

  _adjustHeader() {
    final offset = _controller.offset;
    final index = _headerOffset.findInterval(offset);
    final currentIndex = index;
    double headerOffset = 0.0;
    if (index + 1 <= _headerOffset.length - 1) {
      final endOffset = _headerOffset[index + 1];
      final startOffset = endOffset - listHeaderHeight - 8;
      if (offset > startOffset && offset < endOffset) {
        headerOffset = offset - startOffset;
      }
    }
    _headerStateNotifier.value = _headerStateNotifier.value.copyWith(
      currentIndex: currentIndex,
      offset: max(headerOffset, 0),
    );
  }

  double _getListItemHeight(Type type, ProxyCardType proxyCardType) {
    return switch (type) {
      const (SizedBox) => 8,
      const (ListHeader) => listHeaderHeight,
      Type() => getItemHeight(proxyCardType),
    };
  }

  @override
  void dispose() {
    super.dispose();
    _headerStateNotifier.dispose();
    _controller.removeListener(_adjustHeader);
    _controller.dispose();
  }

  _handleChange(Set<String> currentUnfoldSet, String groupName) {
    final tempUnfoldSet = Set<String>.from(currentUnfoldSet);
    if (tempUnfoldSet.contains(groupName)) {
      tempUnfoldSet.remove(groupName);
    } else {
      tempUnfoldSet.add(groupName);
    }
    globalState.appController.config.updateCurrentUnfoldSet(
      tempUnfoldSet,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _adjustHeader();
    });
  }

  List<double> _getItemHeightList(
    List<Widget> items,
    ProxyCardType proxyCardType,
  ) {
    final itemHeightList = <double>[];
    List<double> headerOffset = [];
    double currentHeight = 0;
    for (final item in items) {
      if (item.runtimeType == ListHeader) {
        headerOffset.add(currentHeight);
      }
      final itemHeight = _getListItemHeight(item.runtimeType, proxyCardType);
      itemHeightList.add(itemHeight);
      currentHeight = currentHeight + itemHeight;
    }
    _headerOffset = headerOffset;
    return itemHeightList;
  }

  List<Widget> _buildItems({
    required List<String> groupNames,
    required int columns,
    required Set<String> currentUnfoldSet,
    required ProxyCardType type,
  }) {
    final items = <Widget>[];
    final GroupNameProxiesMap groupNameProxiesMap = {};
    for (final groupName in groupNames) {
      final group =
          globalState.appController.appState.getGroupWithName(groupName)!;
      final isExpand = currentUnfoldSet.contains(groupName);
      items.addAll([
        ListHeader(
          onScrollToSelected: _scrollToGroupSelected,
          key: Key(groupName),
          isExpand: isExpand,
          group: group,
          onChange: (String groupName) {
            _handleChange(currentUnfoldSet, groupName);
          },
        ),
        const SizedBox(
          height: 8,
        ),
      ]);
      if (isExpand) {
        final sortedProxies = globalState.appController.getSortProxies(
          group.all,
        );
        groupNameProxiesMap[groupName] = sortedProxies;
        final chunks = sortedProxies.chunks(columns);
        final rows = chunks.map<Widget>((proxies) {
          final children = proxies
              .map<Widget>(
                (proxy) => Flexible(
                  child: ProxyCard(
                    type: type,
                    groupType: group.type,
                    key: ValueKey('$groupName.${proxy.name}'),
                    proxy: proxy,
                    groupName: groupName,
                  ),
                ),
              )
              .fill(
                columns,
                filler: (_) => const Flexible(
                  child: SizedBox(),
                ),
              )
              .separated(
                const SizedBox(
                  width: 8,
                ),
              );

          return Row(
            children: children.toList(),
          );
        }).separated(
          const SizedBox(
            height: 8,
          ),
        );
        items.addAll(
          [
            ...rows,
            const SizedBox(
              height: 8,
            ),
          ],
        );
      }
    }
    _lastGroupNameProxiesMap = groupNameProxiesMap;
    return items;
  }

  _buildHeader({
    required String groupName,
    required Set<String> currentUnfoldSet,
  }) {
    final group =
        globalState.appController.appState.getGroupWithName(groupName)!;
    final isExpand = currentUnfoldSet.contains(groupName);
    return SizedBox(
      height: listHeaderHeight,
      child: ListHeader(
        onScrollToSelected: _scrollToGroupSelected,
        key: Key(groupName),
        isExpand: isExpand,
        group: group,
        onChange: (String groupName) {
          _handleChange(currentUnfoldSet, groupName);
        },
      ),
    );
  }

  _scrollToGroupSelected(String groupName) {
    if (_controller.position.maxScrollExtent == 0) {
      return;
    }
    final appController = globalState.appController;
    final currentGroups = appController.appState.currentGroups;
    final groupNames = currentGroups.map((e) => e.name).toList();
    final findIndex = groupNames.indexWhere((item) => item == groupName);
    final index = findIndex != -1 ? findIndex : 0;
    final currentInitOffset = _headerOffset[index];
    final proxies = _lastGroupNameProxiesMap[groupName];
    _controller.animateTo(
      min(
        currentInitOffset +
            8 +
            getScrollToSelectedOffset(
              groupName: groupName,
              proxies: proxies ?? [],
            ),
        _controller.position.maxScrollExtent,
      ),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeIn,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Selector2<AppState, Config, ProxiesListSelectorState>(
      selector: (_, appState, config) {
        final currentGroups = appState.currentGroups;
        final groupNames = currentGroups.map((e) => e.name).toList();
        return ProxiesListSelectorState(
          groupNames: groupNames,
          currentUnfoldSet: config.currentUnfoldSet,
          proxyCardType: config.proxiesStyle.cardType,
          proxiesSortType: config.proxiesStyle.sortType,
          columns: other.getProxiesColumns(
            appState.viewWidth,
            config.proxiesStyle.layout,
          ),
          sortNum: appState.sortNum,
        );
      },
      shouldRebuild: (prev, next) {
        if (!stringListEquality.equals(prev.groupNames, next.groupNames)) {
          _headerStateNotifier.value = const ProxiesListHeaderSelectorState(
            offset: 0,
            currentIndex: 0,
          );
        }
        return prev != next;
      },
      builder: (_, state, __) {
        final items = _buildItems(
          groupNames: state.groupNames,
          currentUnfoldSet: state.currentUnfoldSet,
          columns: state.columns,
          type: state.proxyCardType,
        );
        final itemsOffset = _getItemHeightList(items, state.proxyCardType);
        return Scrollbar(
          controller: _controller,
          thumbVisibility: true,
          trackVisibility: true,
          thickness: 8,
          radius: const Radius.circular(8),
          interactive: true,
          child: Stack(
            children: [
              Positioned.fill(
                child: ScrollConfiguration(
                  behavior: HiddenBarScrollBehavior(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    controller: _controller,
                    itemExtentBuilder: (index, __) {
                      return itemsOffset[index];
                    },
                    itemCount: items.length,
                    itemBuilder: (_, index) {
                      return items[index];
                    },
                  ),
                ),
              ),
              LayoutBuilder(builder: (_, container) {
                return ValueListenableBuilder(
                  valueListenable: _headerStateNotifier,
                  builder: (_, headerState, ___) {
                    final index =
                        headerState.currentIndex > state.groupNames.length - 1
                            ? 0
                            : headerState.currentIndex;
                    if (index < 0) {
                      return Container();
                    }
                    return Stack(
                      children: [
                        Positioned(
                          top: -headerState.offset,
                          child: Container(
                            width: container.maxWidth,
                            color: context.colorScheme.surface,
                            padding: const EdgeInsets.only(
                              top: 16,
                              left: 16,
                              right: 16,
                              bottom: 8,
                            ),
                            child: _buildHeader(
                              groupName: state.groupNames[index],
                              currentUnfoldSet: state.currentUnfoldSet,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }
}

class ListHeader extends StatefulWidget {
  final Group group;

  final Function(String groupName) onChange;
  final Function(String groupName) onScrollToSelected;
  final bool isExpand;

  const ListHeader({
    super.key,
    required this.group,
    required this.onChange,
    required this.onScrollToSelected,
    required this.isExpand,
  });

  @override
  State<ListHeader> createState() => _ListHeaderState();
}

class _ListHeaderState extends State<ListHeader>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _iconTurns;
  var isLock = false;

  String get icon => widget.group.icon;

  String get groupName => widget.group.name;

  String get groupType => widget.group.type.name;

  bool get isExpand => widget.isExpand;

  _delayTest(List<Proxy> proxies) async {
    if (isLock) return;
    isLock = true;
    await delayTest(proxies);
    isLock = false;
  }

  _handleChange(String groupName) {
    widget.onChange(groupName);
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _iconTurns = _animationController.drive(
      Tween<double>(begin: 0.0, end: 0.5),
    );
    if (isExpand) {
      _animationController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(ListHeader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isExpand != widget.isExpand) {
      if (isExpand) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  Widget _buildIcon() {
    return Selector<Config, ProxiesIconStyle>(
      selector: (_, config) => config.proxiesStyle.iconStyle,
      builder: (_, iconStyle, child) {
        return Selector<Config, String>(
          selector: (_, config) {
            final iconMapEntryList =
                config.proxiesStyle.iconMap.entries.toList();
            final index = iconMapEntryList.indexWhere((item) {
              try {
                return RegExp(item.key).hasMatch(groupName);
              } catch (_) {
                return false;
              }
            });
            if (index != -1) {
              return iconMapEntryList[index].value;
            }
            return icon;
          },
          builder: (_, icon, __) {
            return switch (iconStyle) {
              ProxiesIconStyle.standard => Container(
                  height: 48,
                  width: 48,
                  margin: const EdgeInsets.only(
                    right: 16,
                  ),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: context.colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: CommonIcon(
                    src: icon,
                    size: 32,
                  ),
                ),
              ProxiesIconStyle.icon => Container(
                  margin: const EdgeInsets.only(
                    right: 16,
                  ),
                  child: CommonIcon(
                    src: icon,
                    size: 42,
                  ),
                ),
              ProxiesIconStyle.none => Container(),
            };
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return CommonCard(
      key: widget.key,
      radius: 18,
      type: CommonCardType.filled,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Row(
                children: [
                  _buildIcon(),
                  Flexible(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          groupName,
                          style: context.textTheme.titleMedium,
                        ),
                        const SizedBox(
                          height: 4,
                        ),
                        Flexible(
                          flex: 1,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                groupType,
                                style: context.textTheme.labelMedium?.toLight,
                              ),
                              Flexible(
                                flex: 1,
                                child: currentSelectedProxyNameBuilder(
                                  groupName: groupName,
                                  builder: (currentGroupName) {
                                    return Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        if (currentGroupName.isNotEmpty) ...[
                                          Flexible(
                                            flex: 1,
                                            child: EmojiText(
                                              overflow: TextOverflow.ellipsis,
                                              " · $currentGroupName",
                                              style: context.textTheme
                                                  .labelMedium?.toLight,
                                            ),
                                          ),
                                        ]
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          width: 4,
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            Row(
              children: [
                if (isExpand) ...[
                  IconButton(
                    onPressed: () {
                      widget.onScrollToSelected(groupName);
                    },
                    icon: const Icon(
                      Icons.adjust,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      _delayTest(widget.group.all);
                    },
                    icon: const Icon(
                      Icons.network_ping,
                    ),
                  ),
                  const SizedBox(
                    width: 4,
                  ),
                ],
                AnimatedBuilder(
                  animation: _animationController.view,
                  builder: (_, __) {
                    return IconButton.filledTonal(
                      onPressed: () {
                        _handleChange(groupName);
                      },
                      icon: RotationTransition(
                        turns: _iconTurns,
                        child: const Icon(
                          Icons.expand_more,
                        ),
                      ),
                    );
                  },
                )
              ],
            )
          ],
        ),
      ),
      onPressed: () {
        _handleChange(groupName);
      },
    );
  }
}
