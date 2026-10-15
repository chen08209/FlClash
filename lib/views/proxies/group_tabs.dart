import 'dart:math';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/models/common.dart';
import 'package:fl_clash/ui/icons/icons.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:material_ui/material_ui.dart';

const _stripInset = 16.0;
const _tabSpacing = 8.0;
const _tabPadding = 16.0;

/// The group chips over the proxies tab view. Only the chips in view are
/// built: each chip's width comes from its label, so the strip can scroll to
/// one it has not built.
class GroupTabs extends StatefulWidget {
  const GroupTabs({super.key, required this.controller, required this.groups});

  final TabController controller;
  final List<Group> groups;

  @override
  State<GroupTabs> createState() => _GroupTabsState();
}

class _GroupTabsState extends State<GroupTabs> {
  static const _fadeExtent = 24.0;

  // A sheet's controller would hand the strip's drags to the sheet.
  final _scrollController = ScrollController();
  final _hasMore = ValueNotifier(false);
  final _fade = ValueNotifier(0.0);
  late final _selected = ValueNotifier(widget.controller.index);
  _TabExtents? _extents;

  @override
  void initState() {
    super.initState();
    _follow(widget.controller);
  }

  @override
  void didUpdateWidget(GroupTabs oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.animation?.removeListener(_handleAnimation);
      _follow(widget.controller);
    }
  }

  @override
  void dispose() {
    widget.controller.animation?.removeListener(_handleAnimation);
    _scrollController.dispose();
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

  void _reveal({bool jump = false}) {
    final extents = _extents;
    if (!mounted || extents == null || !_scrollController.hasClients) {
      return;
    }
    final position = _scrollController.position;
    final index = _selected.value;
    if (!position.hasContentDimensions ||
        index < 0 ||
        index >= extents.widths.length) {
      return;
    }
    final center =
        _stripInset + extents.starts[index] + extents.widths[index] / 2;
    final target = (center - position.viewportDimension / 2).clamp(
      position.minScrollExtent,
      position.maxScrollExtent,
    );
    if (jump) {
      position.jumpTo(target);
    } else {
      position.animateTo(
        target,
        duration: commonDuration,
        curve: Curves.easeOutCubic,
      );
    }
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

  Widget _buildTabs(_TabExtents extents, bool hasMore) {
    final groups = widget.groups;
    final last = groups.length - 1;
    return ListView.custom(
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      padding: EdgeInsetsDirectional.only(
        start: _stripInset,
        end: hasMore ? 0 : _stripInset,
      ),
      itemExtentBuilder: (index, _) => index < extents.widths.length
          ? extents.widths[index] + (index < last ? _tabSpacing : 0)
          : null,
      childrenDelegate: _TabsDelegate(
        (_, index) => Padding(
          padding: EdgeInsetsDirectional.only(
            end: index < last ? _tabSpacing : 0,
          ),
          child: _GroupTab(
            name: groups[index].name,
            index: index,
            selected: _selected,
            onPressed: () => _select(index),
          ),
        ),
        childCount: groups.length,
        extent: extents.total,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final extents = _extents = _TabExtents.of(context, widget.groups, _extents);
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
                      child: _buildTabs(extents, hasMore),
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

/// The width each chip lays its label out at, worked out the way a
/// [CommonCard]'s button sizes itself.
class _TabExtents {
  _TabExtents._(this._key, this.widths) : starts = _startsOf(widths);

  final Object _key;
  final List<double> widths;
  final List<double> starts;

  double get total => widths.isEmpty ? 0 : starts.last + widths.last;

  static List<double> _startsOf(List<double> widths) {
    final starts = <double>[];
    var start = 0.0;
    for (final width in widths) {
      starts.add(start);
      start += width + _tabSpacing;
    }
    return starts;
  }

  static _TabExtents of(
    BuildContext context,
    List<Group> groups,
    _TabExtents? previous,
  ) {
    final style = AppTextStyle.subheadline.of(context, emphasized: true);
    final buttonStyle = FilledButtonTheme.of(context).style;
    final defaults = const FilledButton(
      onPressed: null,
      child: null,
    ).defaultStyleOf(context);
    final minimumSize = (buttonStyle?.minimumSize ?? defaults.minimumSize)!
        .resolve(const {})!;
    final density = (buttonStyle?.visualDensity ?? defaults.visualDensity)!;
    final adjustment = density.baseSizeAdjustment.dx;
    final minWidth = max(0.0, minimumSize.width + adjustment);
    final padding = 2 * (_tabPadding + max(0.0, adjustment));
    final names = [for (final group in groups) group.name];
    final key = (
      _NamesKey(names),
      style,
      MediaQuery.boldTextOf(context),
      MediaQuery.textScalerOf(context),
      Directionality.of(context),
      Localizations.maybeLocaleOf(context),
      minWidth,
      padding,
    );
    if (previous != null && previous._key == key) {
      return previous;
    }
    return _TabExtents._(key, [
      for (final name in names)
        max(
          minWidth,
          EmojiText.widthOf(context, name, style).ceilToDouble() + padding,
        ),
    ]);
  }
}

/// Reports the strip's whole extent, which a list of varied extents would
/// otherwise extrapolate from the chips it has built.
class _TabsDelegate extends SliverChildBuilderDelegate {
  _TabsDelegate(
    super.builder, {
    required super.childCount,
    required this.extent,
  }) : super(addAutomaticKeepAlives: false);

  final double extent;

  @override
  double? estimateMaxScrollOffset(
    int firstIndex,
    int lastIndex,
    double leadingScrollOffset,
    double trailingScrollOffset,
  ) => extent;
}

class _NamesKey {
  const _NamesKey(this.names);

  final List<String> names;

  @override
  bool operator ==(Object other) =>
      other is _NamesKey && stringListEquality.equals(names, other.names);

  @override
  int get hashCode => stringListEquality.hash(names);
}

/// Rebuilds only when it gains or loses the selection, so a swipe across
/// hundreds of groups rebuilds two tabs per step instead of the strip.
class _GroupTab extends StatefulWidget {
  const _GroupTab({
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
    final colorScheme = context.colorScheme;
    return CommonCard(
      isSelected: selected,
      fillsSelection: true,
      shape: AppShape.full,
      padding: const EdgeInsets.symmetric(horizontal: _tabPadding),
      onPressed: widget.onPressed,
      child: AnimatedDefaultTextStyle(
        duration: midDuration,
        style: AppTextStyle.subheadline
            .of(context, emphasized: true)
            .copyWith(
              color: selected
                  ? colorScheme.onPrimary
                  : colorScheme.onSurfaceVariant,
            ),
        child: EmojiText(widget.name, maxLines: 1),
      ),
    );
  }
}
