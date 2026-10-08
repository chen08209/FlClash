import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:super_sliver_list/super_sliver_list.dart';

class SelectionSection<T> {
  final String? label;
  final List<T> items;
  final String? Function(BuildContext context, T item)? subtitleBuilder;

  const SelectionSection({
    this.label,
    required this.items,
    this.subtitleBuilder,
  });
}

class SelectionSheet<T> extends ConsumerStatefulWidget {
  final String title;
  final List<SelectionSection<T>> sections;
  final String Function(T item) labelBuilder;
  final Widget Function(T item, Widget title)? titleBuilder;
  final T? Function(WidgetRef ref) selectedOf;
  final ValueChanged<T> onSelected;
  final String? emptyLabel;
  final NullStatus? loadingStatus;

  /// A picked item collapses out instead of the sheet closing, which it does
  /// once the last item is picked.
  final bool removeOnSelect;

  const SelectionSheet({
    super.key,
    required this.title,
    required this.sections,
    required this.labelBuilder,
    this.titleBuilder,
    required this.selectedOf,
    required this.onSelected,
    this.emptyLabel,
    this.loadingStatus,
    this.removeOnSelect = false,
  });

  @override
  ConsumerState<SelectionSheet<T>> createState() => _SelectionSheetState<T>();
}

class _SelectionSheetState<T> extends ConsumerState<SelectionSheet<T>>
    with TickerProviderStateMixin {
  late final _transitions = EntryTransitions<T>(
    vsync: this,
    onLeft: _handleLeft,
  );
  final _removed = <T>{};
  late final ScrollController _controller;
  final _revealController = ListController();
  final _selectedKey = GlobalKey();
  var _revealRequested = false;
  var _query = SearchQuery('');

  @override
  void initState() {
    super.initState();
    _controller = sheetScrollController(context);
  }

  @override
  void dispose() {
    _transitions.dispose();
    _controller.dispose();
    _revealController.dispose();
    super.dispose();
  }

  void _handleSearch(String query) {
    setState(() {
      _query = SearchQuery(query);
    });
  }

  void _handleSelected(T item) {
    widget.onSelected(item);
    if (!widget.removeOnSelect) {
      return;
    }
    final isLast = widget.sections.every(
      (section) => section.items.every(
        (other) =>
            other == item ||
            _removed.contains(other) ||
            _transitions.isLeaving(other),
      ),
    );
    if (isLast) {
      Navigator.of(context).pop();
      return;
    }
    setState(() {
      _transitions.leave(item, context.motionDuration(commonDuration));
    });
  }

  void _handleLeft(T item) {
    if (!mounted) {
      return;
    }
    setState(() {
      _removed.add(item);
    });
  }

  List<SelectionSection<T>> _matchingSections(BuildContext context) {
    final sections = _query.isEmpty && _removed.isEmpty
        ? widget.sections
        : [
            for (final section in widget.sections)
              SelectionSection(
                label: section.label,
                items: section.items
                    .where((item) => !_removed.contains(item))
                    .whereMatches(
                      _query,
                      (item) => [
                        widget.labelBuilder(item),
                        section.subtitleBuilder?.call(context, item),
                      ],
                    )
                    .toList(),
                subtitleBuilder: section.subtitleBuilder,
              ),
          ];
    return sections.where((section) => section.items.isNotEmpty).toList();
  }

  int _countOf(List<SelectionSection<T>> sections) =>
      sections.fold(0, (value, section) => value + section.items.length);

  ({int section, int index})? _locate(
    List<SelectionSection<T>> sections,
    T? selected,
  ) {
    if (selected == null) {
      return null;
    }
    for (final (sectionIndex, section) in sections.indexed) {
      final index = section.items.indexOf(selected);
      if (index != -1) {
        return (section: sectionIndex, index: index);
      }
    }
    return null;
  }

  void _revealSelected(int index) {
    if (!mounted || !_controller.hasClients) {
      return;
    }
    final itemContext = _selectedKey.currentContext;
    if (itemContext != null && itemContext.mounted) {
      _alignSelected(itemContext);
      return;
    }
    if (!_revealController.isAttached) {
      return;
    }
    _revealController.jumpToItem(
      index: index,
      scrollController: _controller,
      alignment: 0.5,
    );
    final position = _controller.position;
    if (position.pixels > position.maxScrollExtent) {
      _controller.jumpTo(position.maxScrollExtent);
    }
  }

  void _alignSelected(BuildContext itemContext) {
    final box = itemContext.findRenderObject();
    if (box is! RenderBox || !box.hasSize) {
      return;
    }
    final position = _controller.position;
    final viewport = RenderAbstractViewport.of(box);
    final atTop = viewport.getOffsetToReveal(box, 0).offset;
    final atBottom = viewport.getOffsetToReveal(box, 1).offset;
    if (position.pixels >= atBottom && position.pixels <= atTop) {
      return;
    }
    _controller.jumpTo(
      viewport
          .getOffsetToReveal(box, 0.5)
          .offset
          .clamp(position.minScrollExtent, position.maxScrollExtent),
    );
  }

  /// A section's header leaves with the last of its items to start leaving.
  Animation<double>? _headerAnimationOf(SelectionSection<T> section) {
    if (!section.items.every(_transitions.isLeaving)) {
      return null;
    }
    final last = _transitions.leaving.lastWhere(section.items.contains);
    return _transitions.animationOf(last);
  }

  Widget _buildHeader(SelectionSection<T> section) {
    final header = Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: ListHeader(title: section.label!, padding: baseInfoEdgeInsets),
    );
    if (!widget.removeOnSelect) {
      return header;
    }
    final animation = _headerAnimationOf(section);
    return EntryTransition(
      animation: animation,
      leaving: animation != null,
      child: header,
    );
  }

  Widget _buildItem(
    BuildContext context,
    SelectionSection<T> section,
    T item,
    int index, {
    required bool isSelected,
    required bool isRevealTarget,
  }) {
    final position = widget.removeOnSelect
        ? _transitions.positionOf(item)
        : ItemPosition.get(index, section.items.length);
    final subtitle = section.subtitleBuilder?.call(context, item);
    final title = TooltipText(
      text: Text(
        widget.labelBuilder(item),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
    final row = ItemPositionProvider(
      key: isRevealTarget ? _selectedKey : null,
      position: position,
      child: DecorationListItem(
        onPressed: () => _handleSelected(item),
        subtitle: subtitle != null ? TooltipLabel(subtitle) : null,
        title: widget.titleBuilder?.call(item, title) ?? title,
        isSelected: isSelected,
        trailing: isSelected ? const GlyphIcon(AppGlyphs.check) : null,
      ),
    );
    if (!widget.removeOnSelect) {
      return row;
    }
    return EntryTransition(
      animation: _transitions.animationOf(item),
      leaving: _transitions.isLeaving(item),
      child: row,
    );
  }

  @override
  Widget build(BuildContext context) {
    final sections = _matchingSections(context);
    if (widget.removeOnSelect) {
      for (final section in sections) {
        _transitions.place(section.items);
      }
    }
    final count = _countOf(sections);
    final selected = widget.selectedOf(ref);
    final location = _locate(sections, selected);
    final loadingStatus = widget.loadingStatus;
    if (!_revealRequested && location != null && loadingStatus == null) {
      _revealRequested = true;
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _revealSelected(location.index),
      );
    }
    final searchable =
        _query.isNotEmpty ||
        _countOf(widget.sections) >= sheetSearchMinItemCount;
    return CommonScaffold(
      title: widget.title,
      searchState: searchable
          ? AppBarSearchState(onSearch: _handleSearch)
          : null,
      body: Builder(
        builder: (context) => NullStatusSwitcher(
          isEmpty:
              loadingStatus != null ||
              count == 0 && (widget.emptyLabel != null || _query.isNotEmpty),
          isSearching: loadingStatus == null && _query.isNotEmpty,
          holdsArrival: loadingStatus != null,
          nullStatus:
              loadingStatus ?? NullStatus(label: widget.emptyLabel ?? ''),
          child: CustomScrollView(
            controller: _controller,
            slivers: [
              SliverToBoxAdapter(
                child: SizedBox(height: context.contentTopPadding),
              ),
              for (final (sectionIndex, section) in sections.indexed) ...[
                if (section.label != null)
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverToBoxAdapter(child: _buildHeader(section)),
                  ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SuperSliverList.builder(
                    listController: sectionIndex == location?.section
                        ? _revealController
                        : null,
                    itemCount: section.items.length,
                    itemBuilder: (context, index) {
                      final item = section.items[index];
                      return _buildItem(
                        context,
                        section,
                        item,
                        index,
                        isSelected: item == selected,
                        isRevealTarget:
                            sectionIndex == location?.section &&
                            index == location?.index,
                      );
                    },
                  ),
                ),
              ],
              SliverToBoxAdapter(
                child: SizedBox(height: 20 + BottomInsetScope.of(context)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
