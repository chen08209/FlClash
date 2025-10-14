import 'dart:math';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/providers/state.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'card.dart';
import 'common.dart';

typedef GroupNameProxiesMap = Map<String, List<Proxy>>;

class ProxiesListView extends StatefulWidget {
  const ProxiesListView({super.key});

  @override
  State<ProxiesListView> createState() => _ProxiesListViewState();
}

class _ProxiesListViewState extends State<ProxiesListView> {
  final _controller = ScrollController();
  final _headerStateNotifier = ValueNotifier<ProxiesListHeaderSelectorState?>(
    null,
  );
  List<double> _headerOffset = [];
  double containerHeight = 0;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_adjustHeader);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _adjustHeader();
    });
  }

  ProxiesListHeaderSelectorState _getProxiesListHeaderSelectorState(
    double initOffset,
  ) {
    final index = _headerOffset.findInterval(initOffset);
    final currentIndex = index;
    double headerOffset = 0.0;
    if (index + 1 <= _headerOffset.length - 1) {
      final endOffset = _headerOffset[index + 1];
      final startOffset = endOffset - listHeaderHeight - 8;
      if (initOffset > startOffset && initOffset < endOffset) {
        headerOffset = initOffset - startOffset;
      }
    }
    return ProxiesListHeaderSelectorState(
      offset: max(headerOffset, 0),
      currentIndex: currentIndex,
    );
  }

  void _adjustHeader() {
    _headerStateNotifier.value = _getProxiesListHeaderSelectorState(
      !_controller.hasClients ? 0 : _controller.offset,
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
    _headerStateNotifier.dispose();
    _controller.removeListener(_adjustHeader);
    _controller.dispose();
    super.dispose();
  }

  void _handleChange(Set<String> currentUnfoldSet, String groupName) {
    _autoScrollToGroup(groupName);
    final tempUnfoldSet = Set<String>.from(currentUnfoldSet);
    if (tempUnfoldSet.contains(groupName)) {
      tempUnfoldSet.remove(groupName);
    } else {
      tempUnfoldSet.add(groupName);
    }
    globalState.appController.updateCurrentUnfoldSet(tempUnfoldSet);
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

  List<Widget> _buildItems(
    WidgetRef ref, {
    required List<Group> groups,
    required int columns,
    required Set<String> currentUnfoldSet,
    required ProxyCardType cardType,
  }) {
    final items = <Widget>[];
    for (final group in groups) {
      final groupName = group.name;
      final isExpand = currentUnfoldSet.contains(groupName);
      items.addAll([
        ListHeader(
          onScrollToSelected: _scrollToGroupSelected,
          isExpand: isExpand,
          group: group,
          onChange: (String groupName) {
            _handleChange(currentUnfoldSet, groupName);
          },
        ),
        const SizedBox(height: 8),
      ]);
      if (isExpand) {
        final proxies = group.all;
        final chunks = proxies.chunks(columns);
        final rows = chunks
            .map<Widget>((proxies) {
              final children = proxies
                  .map<Widget>(
                    (proxy) => Flexible(
                      child: SizedBox(
                        height: getItemHeight(cardType),
                        child: ProxyCard(
                          testUrl: group.testUrl,
                          type: cardType,
                          groupType: group.type,
                          key: ValueKey('$groupName.${proxy.name}'),
                          proxy: proxy,
                          groupName: groupName,
                        ),
                      ),
                    ),
                  )
                  .fill(
                    columns,
                    filler: (_) => const Flexible(child: SizedBox()),
                  )
                  .separated(const SizedBox(width: 8));

              return Row(children: children.toList());
            })
            .separated(const SizedBox(height: 8));
        items.addAll([...rows, const SizedBox(height: 8)]);
      }
    }
    return items;
  }

  Widget _buildHeader(
    WidgetRef ref, {
    required Group group,
    required Set<String> currentUnfoldSet,
  }) {
    final groupName = group.name;
    final isExpand = currentUnfoldSet.contains(groupName);
    return SizedBox(
      height: listHeaderHeight,
      child: ListHeader(
        enterAnimated: false,
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

  double _getGroupOffset(String groupName) {
    if (_controller.position.maxScrollExtent == 0) {
      return 0;
    }
    final currentGroups = globalState.appController.getCurrentGroups();
    final findIndex = currentGroups.indexWhere(
      (item) => item.name == groupName,
    );
    final index = findIndex != -1 ? findIndex : 0;
    return _headerOffset[index];
  }

  void _scrollToMakeVisibleWithPadding({
    required double containerHeight,
    required double pixels,
    required double start,
    required double end,
    double padding = 24,
  }) {
    final visibleStart = pixels;
    final visibleEnd = pixels + containerHeight;

    final isElementVisible = start >= visibleStart && end <= visibleEnd;
    if (isElementVisible) {
      return;
    }

    double targetScrollOffset;

    if (end <= visibleStart) {
      targetScrollOffset = start;
    } else if (start >= visibleEnd) {
      targetScrollOffset = end - containerHeight + padding;
    } else {
      final visibleTopPart = end - visibleStart;
      final visibleBottomPart = visibleEnd - start;
      if (visibleTopPart.abs() >= visibleBottomPart.abs()) {
        targetScrollOffset = end - containerHeight + padding;
      } else {
        targetScrollOffset = start;
      }
    }

    targetScrollOffset = targetScrollOffset.clamp(
      _controller.position.minScrollExtent,
      _controller.position.maxScrollExtent,
    );

    _controller.jumpTo(targetScrollOffset);
  }

  void _autoScrollToGroup(String groupName) {
    final pixels = _controller.position.pixels;
    final offset = _getGroupOffset(groupName);
    _scrollToMakeVisibleWithPadding(
      containerHeight: containerHeight,
      pixels: pixels,
      start: offset,
      end: offset + listHeaderHeight,
    );
  }

  void _scrollToGroupSelected(String groupName) {
    final currentInitOffset = _getGroupOffset(groupName);
    final currentGroups = globalState.appController.getCurrentGroups();
    final proxies = currentGroups.getGroup(groupName)?.all;
    _jumpTo(
      currentInitOffset +
          8 +
          getScrollToSelectedOffset(
            groupName: groupName,
            proxies: proxies ?? [],
          ),
    );
  }

  void _jumpTo(double offset) {
    if (mounted && _controller.hasClients) {
      _controller.animateTo(
        offset.clamp(
          _controller.position.minScrollExtent,
          _controller.position.maxScrollExtent,
        ),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (_, ref, _) {
        final state = ref.watch(proxiesListStateProvider);
        ref.watch(themeSettingProvider.select((state) => state.textScale));
        if (state.groups.isEmpty) {
          return NullStatus(
            illustration: ProxyEmptyIllustration(),
            label: appLocalizations.nullTip(appLocalizations.proxies),
          );
        }
        final items = _buildItems(
          ref,
          groups: state.groups,
          currentUnfoldSet: state.currentUnfoldSet,
          columns: state.columns,
          cardType: state.proxyCardType,
        );
        final itemsOffset = _getItemHeightList(items, state.proxyCardType);
        return CommonScrollBar(
          controller: _controller,
          thumbVisibility: true,
          trackVisibility: true,
          child: Stack(
            children: [
              Positioned.fill(
                child: ScrollConfiguration(
                  behavior: HiddenBarScrollBehavior(),
                  child: ListView.builder(
                    key: proxiesListStoreKey,
                    padding: const EdgeInsets.all(16),
                    controller: _controller,
                    itemExtentBuilder: (index, _) {
                      return itemsOffset[index];
                    },
                    itemCount: items.length,
                    itemBuilder: (_, index) {
                      return items[index];
                    },
                  ),
                ),
              ),
              LayoutBuilder(
                builder: (_, container) {
                  containerHeight = container.maxHeight;
                  return ValueListenableBuilder(
                    valueListenable: _headerStateNotifier,
                    builder: (_, headerState, _) {
                      if (headerState == null) {
                        return SizedBox();
                      }
                      final index =
                          headerState.currentIndex > state.groups.length - 1
                          ? 0
                          : headerState.currentIndex;
                      if (index < 0 || state.groups.isEmpty) {
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
                                ref,
                                group: state.groups[index],
                                currentUnfoldSet: state.currentUnfoldSet,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
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

  final bool enterAnimated;

  const ListHeader({
    super.key,
    this.enterAnimated = true,
    required this.group,
    required this.onChange,
    required this.onScrollToSelected,
    required this.isExpand,
  });

  @override
  State<ListHeader> createState() => _ListHeaderState();
}

class _ListHeaderState extends State<ListHeader> {
  var isLock = false;

  String get icon => widget.group.icon;

  String get groupName => widget.group.name;

  String get groupType => widget.group.type.name;

  bool get isExpand => widget.isExpand;

  Future<void> _delayTest() async {
    if (isLock) return;
    isLock = true;
    await delayTest(widget.group.all, widget.group.testUrl);
    isLock = false;
  }

  void _handleChange(String groupName) {
    widget.onChange(groupName);
  }

  Widget _buildIcon() {
    return Consumer(
      builder: (_, ref, child) {
        final iconStyle = ref.watch(
          proxiesStyleSettingProvider.select((state) => state.iconStyle),
        );
        return switch (iconStyle) {
          ProxiesIconStyle.standard => LayoutBuilder(
            builder: (_, constraints) {
              return Container(
                margin: const EdgeInsets.only(right: 16),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                    height: constraints.maxHeight,
                    width: constraints.maxWidth,
                    alignment: Alignment.center,
                    padding: EdgeInsets.all(6.ap),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: context.colorScheme.secondaryContainer,
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: CommonTargetIcon(
                      src: icon,
                      size: constraints.maxHeight - 12.ap,
                    ),
                  ),
                ),
              );
            },
          ),
          ProxiesIconStyle.icon => Container(
            margin: const EdgeInsets.only(right: 16),
            child: LayoutBuilder(
              builder: (_, constraints) {
                return CommonTargetIcon(
                  src: icon,
                  size: constraints.maxHeight - 8,
                );
              },
            ),
          ),
          ProxiesIconStyle.none => Container(),
        };
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return CommonCard(
      enterAnimated: widget.enterAnimated,
      key: widget.key,
      radius: 18.ap,
      type: CommonCardType.filled,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                        EmojiText(
                          groupName,
                          style: context.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
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
                                child: Consumer(
                                  builder: (_, ref, _) {
                                    final proxyName = ref
                                        .watch(
                                          getSelectedProxyNameProvider(
                                            groupName,
                                          ),
                                        )
                                        .getSafeValue('');
                                    return Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        if (proxyName.isNotEmpty) ...[
                                          Flexible(
                                            flex: 1,
                                            child: EmojiText(
                                              overflow: TextOverflow.ellipsis,
                                              ' · $proxyName',
                                              style: context
                                                  .textTheme
                                                  .labelMedium
                                                  ?.toLight,
                                            ),
                                          ),
                                        ],
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 4),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                if (isExpand) ...[
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.all(2),
                    onPressed: () {
                      widget.onScrollToSelected(groupName);
                    },
                    style: ButtonStyle(
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    iconSize: 19,
                    icon: const Icon(Icons.adjust),
                  ),
                  const SizedBox(width: 2),
                  IconButton(
                    iconSize: 20,
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.all(2),
                    onPressed: _delayTest,
                    style: ButtonStyle(
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    icon: const Icon(Icons.network_ping),
                  ),
                  const SizedBox(width: 6),
                ] else
                  SizedBox(width: 6),
                IconButton.filledTonal(
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.all(2),
                  iconSize: 24,
                  style: ButtonStyle(
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  onPressed: () {
                    _handleChange(groupName);
                  },
                  icon: CommonExpandIcon(expand: isExpand),
                ),
              ],
            ),
          ],
        ),
      ),
      onPressed: () {
        _handleChange(groupName);
      },
    );
  }
}
