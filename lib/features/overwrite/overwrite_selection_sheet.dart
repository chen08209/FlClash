import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:super_sliver_list/super_sliver_list.dart';

class OverwriteSelectionSection<T> {
  final String? label;
  final List<T> items;
  final String? Function(BuildContext context, T item)? subtitleBuilder;

  const OverwriteSelectionSection({
    this.label,
    required this.items,
    this.subtitleBuilder,
  });
}

class OverwriteSelectionSheet<T> extends ConsumerStatefulWidget {
  final String title;
  final List<OverwriteSelectionSection<T>> sections;
  final String Function(T item) labelBuilder;
  final T? Function(WidgetRef ref) selectedOf;
  final ValueChanged<T> onSelected;
  final double? bottomHeightFactor;
  final String? emptyLabel;

  const OverwriteSelectionSheet({
    super.key,
    required this.title,
    required this.sections,
    required this.labelBuilder,
    required this.selectedOf,
    required this.onSelected,
    this.bottomHeightFactor = 0.70,
    this.emptyLabel,
  });

  @override
  ConsumerState<OverwriteSelectionSheet<T>> createState() =>
      _OverwriteSelectionSheetState<T>();
}

class _OverwriteSelectionSheetState<T>
    extends ConsumerState<OverwriteSelectionSheet<T>> {
  final _controller = ScrollController();
  final _revealController = ListController();
  final _selectedKey = GlobalKey();
  var _revealRequested = false;
  var _query = SearchQuery('');

  @override
  void dispose() {
    _controller.dispose();
    _revealController.dispose();
    super.dispose();
  }

  void _handleSearch(String query) {
    setState(() {
      _query = SearchQuery(query);
    });
  }

  List<OverwriteSelectionSection<T>> _matchingSections(BuildContext context) {
    if (_query.isEmpty) {
      return widget.sections;
    }
    return [
      for (final section in widget.sections)
        OverwriteSelectionSection(
          label: section.label,
          items: section.items
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
    ].where((section) => section.items.isNotEmpty).toList();
  }

  int _countOf(List<OverwriteSelectionSection<T>> sections) =>
      sections.fold(0, (value, section) => value + section.items.length);

  ({int section, int index})? _locate(
    List<OverwriteSelectionSection<T>> sections,
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

  Widget _buildItem(
    BuildContext context,
    OverwriteSelectionSection<T> section,
    T item,
    int index, {
    required bool isSelected,
    required bool isRevealTarget,
  }) {
    final position = ItemPosition.get(index, section.items.length);
    final subtitle = section.subtitleBuilder?.call(context, item);
    return ItemPositionProvider(
      key: isRevealTarget ? _selectedKey : null,
      position: position,
      child: DecorationListItem(
        onPressed: () => widget.onSelected(item),
        subtitle: subtitle != null ? TooltipLabel(subtitle) : null,
        title: TooltipText(
          text: Text(
            widget.labelBuilder(item),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        isSelected: isSelected,
        trailing: isSelected ? const GlyphIcon(AppGlyphs.check) : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = ref.sheetHeight(context, (widget.bottomHeightFactor ?? 1));
    final sections = _matchingSections(context);
    final count = _countOf(sections);
    final selected = widget.selectedOf(ref);
    final location = _locate(sections, selected);
    if (!_revealRequested && location != null) {
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
      body: SizedBox(
        height: height,
        child: Builder(
          builder: (context) => NullStatusSwitcher(
            isEmpty:
                count == 0 && (widget.emptyLabel != null || _query.isNotEmpty),
            isSearching: _query.isNotEmpty,
            nullStatus: NullStatus(label: widget.emptyLabel ?? ''),
            child: CustomScrollView(
              controller: _controller,
              slivers: [
                SliverToBoxAdapter(
                  child: SizedBox(height: context.contentTopPadding),
                ),
                for (final (sectionIndex, section) in sections.indexed) ...[
                  if (section.label != null) ...[
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverToBoxAdapter(
                        child: InfoHeader(info: Info(label: section.label!)),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 4)),
                  ],
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
      ),
    );
  }
}
