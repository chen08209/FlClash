import 'dart:async';
import 'dart:math';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'card.dart';
import 'common.dart';

typedef GroupNameProxiesMap = Map<String, List<Proxy>>;

const _enterStaggerLimit = 8;
const _enterStaggerStep = Duration(milliseconds: 20);
const _enterSlideBase = 32.0;
const _enterSlideStep = 8.0;
final _enterWindow = commonDuration + _enterStaggerStep * _enterStaggerLimit;

class ProxiesListView extends ConsumerStatefulWidget {
  const ProxiesListView({super.key});

  @override
  ConsumerState<ProxiesListView> createState() => _ProxiesListViewState();
}

class _ProxiesListViewState extends ConsumerState<ProxiesListView> {
  final _controller = ScrollController();
  GroupOffsets _groupOffsets = GroupOffsets.empty;
  double containerHeight = 0;
  String? _enterGroupName;
  Timer? _enterTimer;

  @override
  void dispose() {
    _stopEnterAnimated();
    _controller.dispose();
    super.dispose();
  }

  void _startEnterAnimated(String groupName) {
    _enterTimer?.cancel();
    _enterGroupName = groupName;
    _enterTimer = Timer(_enterWindow, _stopEnterAnimated);
  }

  void _stopEnterAnimated() {
    _enterTimer?.cancel();
    _enterTimer = null;
    _enterGroupName = null;
  }

  void _handleChange(Set<String> currentUnfoldSet, String groupName) {
    _autoScrollToGroup(groupName);
    final tempUnfoldSet = Set<String>.from(currentUnfoldSet);
    if (tempUnfoldSet.contains(groupName)) {
      tempUnfoldSet.remove(groupName);
      _stopEnterAnimated();
    } else {
      tempUnfoldSet.add(groupName);
      _startEnterAnimated(groupName);
    }
    ref
        .read(proxiesActionProvider.notifier)
        .updateCurrentUnfoldSet(tempUnfoldSet);
  }

  GroupOffsets _getGroupOffsets({
    required List<Group> groups,
    required int columns,
    required Set<String> currentUnfoldSet,
    required ProxyCardType cardType,
  }) {
    final offsets = <double>[];
    final rowExtent = getItemHeight(cardType) + 8;
    var currentOffset = 0.0;
    for (final group in groups) {
      offsets.add(currentOffset);
      currentOffset += listHeaderHeight + 8;
      if (currentUnfoldSet.contains(group.name)) {
        final rowCount = (group.all.length + columns - 1) ~/ columns;
        currentOffset += rowCount * rowExtent;
      }
    }
    return GroupOffsets(groups, offsets);
  }

  Widget _buildProxyRow({
    required Group group,
    required List<Proxy> proxies,
    required int rowIndex,
    required int columns,
    required ProxyCardType cardType,
  }) {
    final groupName = group.name;
    final enterAnimated = _enterGroupName == groupName;
    final children = proxies.indexed
        .map<Widget>((entry) {
          final (columnIndex, proxy) = entry;
          final card = SizedBox(
            height: getItemHeight(cardType),
            child: ProxyCard(
              testUrl: group.testUrl,
              type: cardType,
              groupType: group.type,
              key: ValueKey('$groupName.${proxy.name}'),
              proxy: proxy,
              groupName: groupName,
            ),
          );
          if (!enterAnimated) {
            return Flexible(child: card);
          }
          final stagger = min(
            rowIndex * columns + columnIndex,
            _enterStaggerLimit,
          );
          return Flexible(
            child: FadeSlideEnterBox(
              delay: _enterStaggerStep * stagger,
              distance: _enterSlideBase + _enterSlideStep * stagger,
              child: card,
            ),
          );
        })
        .fill(columns, filler: (_) => const Flexible(child: SizedBox()))
        .separated(const SizedBox(width: 8));
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
      child: Row(children: children.toList()),
    );
  }

  Widget _buildGroup(
    BuildContext context, {
    required Group group,
    required Set<String> currentUnfoldSet,
    required int columns,
    required ProxyCardType cardType,
  }) {
    final groupName = group.name;
    final isExpand = currentUnfoldSet.contains(groupName);
    final rows = isExpand
        ? group.all.chunks(columns).toList()
        : const <List<Proxy>>[];
    return SliverMainAxisGroup(
      slivers: [
        PinnedHeaderSliver(
          child: ColoredBox(
            color: context.colorScheme.surface,
            child: Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
              child: SizedBox(
                height: listHeaderHeight,
                child: ListHeader(
                  enterAnimated: false,
                  onScrollToSelected: (groupName) {
                    _scrollToGroupSelected(groupName, columns);
                  },
                  key: ValueKey(groupName),
                  isExpand: isExpand,
                  group: group,
                  onChange: (groupName) {
                    _handleChange(currentUnfoldSet, groupName);
                  },
                ),
              ),
            ),
          ),
        ),
        if (isExpand)
          SliverFixedExtentList(
            itemExtent: getItemHeight(cardType) + 8,
            delegate: SliverChildBuilderDelegate(
              (_, index) => _buildProxyRow(
                group: group,
                proxies: rows[index],
                rowIndex: index,
                columns: columns,
                cardType: cardType,
              ),
              childCount: rows.length,
            ),
          ),
      ],
    );
  }

  double _getGroupOffset(String groupName) {
    if (!_controller.hasClients ||
        _controller.position.maxScrollExtent == 0 ||
        _groupOffsets.isEmpty) {
      return 0;
    }
    return _groupOffsets.offsetOf(groupName);
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

  void _scrollToGroupSelected(String groupName, int columns) {
    final currentInitOffset = _getGroupOffset(groupName);
    final proxies = _groupOffsets.groupOf(groupName)?.all;
    _jumpTo(
      currentInitOffset +
          8 +
          getScrollToSelectedOffset(
            ref: ref,
            groupName: groupName,
            proxies: proxies ?? [],
            columns: columns,
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
    final appLocalizations = context.appLocalizations;
    return Consumer(
      builder: (_, ref, _) {
        final state = ref.watch(proxiesListStateProvider);
        ref.watch(themeSettingProvider.select((state) => state.textScale));
        final proxiesLayout = ref.watch(
          proxiesStyleSettingProvider.select((state) => state.layout),
        );
        if (state.groups.isEmpty) {
          return NullStatus(
            illustration: const ProxyEmptyIllustration(),
            label: appLocalizations.nullTip(appLocalizations.proxies),
          );
        }
        return LayoutBuilder(
          builder: (_, constraints) {
            final columns = getProxiesColumns(
              max(constraints.maxWidth - 32, 0),
              proxiesLayout,
            );
            _groupOffsets = _getGroupOffsets(
              groups: state.groups,
              currentUnfoldSet: state.currentUnfoldSet,
              columns: columns,
              cardType: state.proxyCardType,
            );
            containerHeight = max(constraints.maxHeight - 16, 0);
            return CommonScrollBar(
              controller: _controller,
              thumbVisibility: true,
              trackVisibility: true,
              child: Padding(
                padding: const EdgeInsets.only(top: 16),
                child: ScrollConfiguration(
                  behavior: HiddenBarScrollBehavior(),
                  child: CustomScrollView(
                    key: proxiesListStoreKey,
                    controller: _controller,
                    slivers: [
                      for (final group in state.groups)
                        _buildGroup(
                          context,
                          group: group,
                          currentUnfoldSet: state.currentUnfoldSet,
                          columns: columns,
                          cardType: state.proxyCardType,
                        ),
                      SliverToBoxAdapter(
                        child: SizedBox(
                          height: 16 + BottomInsetScope.of(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class ListHeader extends ConsumerStatefulWidget {
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
  ConsumerState<ListHeader> createState() => _ListHeaderState();
}

class _ListHeaderState extends ConsumerState<ListHeader> {
  var isLock = false;

  String get icon => widget.group.icon;

  String get groupName => widget.group.name;

  String get groupType => widget.group.type.name;

  bool get isExpand => widget.isExpand;

  Future<void> _delayTest() async {
    if (isLock) return;
    isLock = true;
    try {
      await ref
          .read(proxiesActionProvider.notifier)
          .delayTest(widget.group.all, widget.group.testUrl);
    } finally {
      isLock = false;
    }
  }

  void _handleChange(String groupName) {
    widget.onChange(groupName);
  }

  @override
  Widget build(BuildContext context) {
    return CommonCard(
      enterActionsOnRight: true,
      enterAnimated: widget.enterAnimated,
      key: widget.key,
      radius: AppCorner.xl.ap,
      type: CommonCardType.filled,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Row(
                children: [
                  _GroupIcon(src: icon),
                  Flexible(child: _GroupSummary(groupName: groupName)),
                ],
              ),
            ),
            _GroupActions(
              isExpand: isExpand,
              groupType: groupType,
              onScrollToSelected: () {
                widget.onScrollToSelected(groupName);
              },
              onDelayTest: _delayTest,
              onToggle: () {
                _handleChange(groupName);
              },
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

class _GroupIcon extends ConsumerWidget {
  const _GroupIcon({required this.src});

  final String src;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final iconStyle = ref.watch(
      proxiesStyleSettingProvider.select((state) => state.iconStyle),
    );
    return switch (iconStyle) {
      ProxiesIconStyle.standard => LayoutBuilder(
        builder: (_, constraints) {
          return Container(
            margin: const EdgeInsets.only(right: 12),
            child: AspectRatio(
              aspectRatio: 1,
              child: Container(
                height: constraints.maxHeight,
                width: constraints.maxWidth,
                alignment: Alignment.center,
                padding: EdgeInsets.all(6.ap),
                decoration: ShapeDecoration(
                  color: context.colorScheme.secondaryContainer,
                  shape: AppShape.md,
                ),
                clipBehavior: Clip.antiAlias,
                child: IconTheme.merge(
                  data: IconThemeData(size: constraints.maxHeight - 12.ap),
                  child: CommonTargetIcon(src: src),
                ),
              ),
            ),
          );
        },
      ),
      ProxiesIconStyle.icon => Container(
        margin: const EdgeInsets.only(right: 8),
        child: LayoutBuilder(
          builder: (_, constraints) {
            return IconTheme.merge(
              data: IconThemeData(size: constraints.maxHeight - 8.ap),
              child: CommonTargetIcon(src: src),
            );
          },
        ),
      ),
      ProxiesIconStyle.none => Container(),
    };
  }
}

class _GroupSummary extends StatelessWidget {
  const _GroupSummary({required this.groupName});

  final String groupName;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        EmojiText(groupName, style: context.textTheme.titleMedium),
        const SizedBox(height: 4),
        Flexible(flex: 1, child: _SelectedProxyName(groupName: groupName)),
      ],
    );
  }
}

class _SelectedProxyName extends ConsumerWidget {
  const _SelectedProxyName({required this.groupName});

  final String groupName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final proxyName = ref
        .watch(selectedProxyNameProvider(groupName))
        .takeFirstValid([]);
    if (proxyName.isEmpty) {
      return const SizedBox.shrink();
    }
    return EmojiText(
      proxyName,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: context.textTheme.labelSmall?.toLight,
    );
  }
}

class _GroupActions extends StatelessWidget {
  const _GroupActions({
    required this.isExpand,
    required this.groupType,
    required this.onScrollToSelected,
    required this.onDelayTest,
    required this.onToggle,
  });

  static const _shrinkWrap = ButtonStyle(
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
  );

  final bool isExpand;
  final String groupType;
  final VoidCallback onScrollToSelected;
  final VoidCallback onDelayTest;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (isExpand) ...[
          IconButton(
            tooltip: context.appLocalizations.scrollToSelected,
            visualDensity: VisualDensity.compact,
            padding: const EdgeInsets.all(2),
            onPressed: onScrollToSelected,
            style: _shrinkWrap,
            iconSize: 19,
            icon: const Icon(Icons.adjust),
          ),
          const SizedBox(width: 2),
          IconButton(
            tooltip: context.appLocalizations.delayTest,
            iconSize: 20,
            visualDensity: VisualDensity.compact,
            padding: const EdgeInsets.all(2),
            onPressed: onDelayTest,
            style: _shrinkWrap,
            icon: const Icon(Icons.network_ping),
          ),
          const SizedBox(width: 6),
        ] else ...[
          Text(groupType, style: context.textTheme.labelMedium?.toLight),
          const SizedBox(width: 6),
        ],
        IconButton.filledTonal(
          tooltip: isExpand
              ? context.appLocalizations.showLess
              : context.appLocalizations.showMore,
          visualDensity: VisualDensity.compact,
          padding: const EdgeInsets.all(2),
          iconSize: 24,
          style: _shrinkWrap,
          onPressed: onToggle,
          icon: CommonExpandIcon(expand: isExpand),
        ),
      ],
    );
  }
}
