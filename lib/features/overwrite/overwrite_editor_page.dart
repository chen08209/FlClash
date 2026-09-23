import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/models/common.dart';
import 'package:fl_clash/models/state.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

typedef OverwriteItemBuilder<T> =
    Widget Function(
      BuildContext context,
      WidgetRef ref,
      T item,
      int index,
      bool isEditing,
      bool isSelected,
      VoidCallback onToggleSelected,
    );

class OverwriteEditorPage<T, K> extends ConsumerStatefulWidget {
  final String title;
  final List<T>? Function(WidgetRef ref) itemsOf;
  final OverwriteItemBuilder<T> itemBuilder;
  final void Function(int oldIndex, int newIndex) onReorder;
  final VoidCallback onAdd;
  final String emptyLabel;
  final double? itemExtent;
  final bool selectionEnabled;
  final bool dragFromRow;
  final K Function(T item) idOf;
  final void Function(Set<K> ids)? onDelete;
  final Iterable<String?> Function(T item)? searchFieldsOf;

  const OverwriteEditorPage({
    super.key,
    required this.title,
    required this.itemsOf,
    required this.itemBuilder,
    required this.onReorder,
    required this.onAdd,
    required this.emptyLabel,
    this.itemExtent,
    this.selectionEnabled = false,
    this.dragFromRow = false,
    required this.idOf,
    this.onDelete,
    this.searchFieldsOf,
  });

  @override
  ConsumerState<OverwriteEditorPage<T, K>> createState() =>
      _OverwriteEditorPageState<T, K>();
}

class _OverwriteEditorPageState<T, K>
    extends ConsumerState<OverwriteEditorPage<T, K>> {
  late final ScrollController _scrollController;
  var _query = SearchQuery('');
  final _searchTexts = Expando<String>();
  var _selected = <K>{};

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Set<K> _liveSelection(List<T>? items) {
    if (!widget.selectionEnabled || _selected.isEmpty || items == null) {
      return const {};
    }
    return items.map(widget.idOf).where(_selected.contains).toSet();
  }

  List<T> _visibleItems(List<T> items) {
    final searchFieldsOf = widget.searchFieldsOf;
    if (searchFieldsOf == null) {
      return items;
    }
    return items
        .whereMatches(_query, searchFieldsOf, texts: _searchTexts)
        .toList();
  }

  void _handleSearch(String query) {
    setState(() {
      _query = SearchQuery(query);
    });
  }

  void _handleToggleSelected(T item) {
    if (!widget.selectionEnabled) {
      return;
    }
    setState(() {
      _selected = {..._selected}..addOrRemove(widget.idOf(item));
    });
  }

  void _handleSelectAll(List<T> visibleItems) {
    final ids = visibleItems.map(widget.idOf).toSet();
    setState(() {
      _selected = _selected.containsAll(ids) ? {} : ids;
    });
  }

  Future<void> _handleDelete(
    void Function(Set<K> ids) onDelete,
    Set<K> ids,
  ) async {
    final res = await dialogs.showMessage(
      message: TextSpan(
        text: context.appLocalizations.deleteMultipTip(widget.title),
      ),
    );
    if (res != true || !mounted) {
      return;
    }
    onDelete(ids);
    setState(() {
      _selected = {};
    });
  }

  Widget _buildItem(
    BuildContext context,
    T item,
    int index,
    int total,
    Set<K> selected, {
    required bool reorderable,
  }) {
    final id = widget.idOf(item);
    final child = ItemPositionProvider(
      position: ItemPosition.get(index, total),
      child: widget.itemBuilder(
        context,
        ref,
        item,
        index,
        selected.isNotEmpty,
        selected.contains(id),
        () => _handleToggleSelected(item),
      ),
    );
    if (reorderable && widget.dragFromRow) {
      return ReorderableDelayedDragStartListener(
        key: ValueKey(id),
        index: index,
        child: child,
      );
    }
    return KeyedSubtree(key: ValueKey(id), child: child);
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final loadedItems = widget.itemsOf(ref);
    final items = _visibleItems(loadedItems ?? const []);
    final isSearching = widget.searchFieldsOf != null && _query.isNotEmpty;
    final selected = _liveSelection(loadedItems);
    final isSelecting = selected.isNotEmpty;
    final onDelete = widget.onDelete;
    final selectionActions = [
      if (onDelete != null)
        IconButtonData(
          glyph: AppGlyphs.delete,
          onPressed: () => _handleDelete(onDelete, _liveSelection(items)),
          tooltip: appLocalizations.delete,
        ),
      IconButtonData(
        glyph: AppGlyphs.selectAll,
        onPressed: () => _handleSelectAll(items),
        tooltip: appLocalizations.selectAll,
      ),
    ];
    return CommonScaffold(
      title: widget.title,
      searchState: widget.searchFieldsOf != null
          ? AppBarSearchState(onSearch: _handleSearch)
          : null,
      actions: [
        if (!isSelecting)
          FilledButton.tonal(
            onPressed: widget.onAdd,
            child: Text(appLocalizations.add),
          ),
      ],
      selectionActions: isSelecting ? selectionActions : const [],
      body: NullStatusSwitcher(
        isLoading: loadedItems == null,
        isEmpty: items.isEmpty,
        isSearching: isSearching,
        nullStatus: NullStatus(label: widget.emptyLabel),
        child: CommonScrollBar(
          controller: _scrollController,
          child: isSearching
              ? _buildSearchResults(context, items, selected)
              : _buildReorderableList(context, items, selected),
        ),
      ),
    );
  }

  EdgeInsets _listPadding(BuildContext context) =>
      EdgeInsets.fromLTRB(16, context.appBarInset + 12, 16, 24);

  Widget _buildReorderableList(
    BuildContext context,
    List<T> items,
    Set<K> selected,
  ) {
    Widget itemAt(int index) => _buildItem(
      context,
      items[index],
      index,
      items.length,
      selected,
      reorderable: true,
    );
    return ReorderableListView.builder(
      scrollController: _scrollController,
      buildDefaultDragHandles: false,
      padding: _listPadding(context),
      itemBuilder: (_, index) => itemAt(index),
      itemExtent: widget.itemExtent,
      itemCount: items.length,
      proxyDecorator: (child, index, animation) =>
          commonProxyDecorator(itemAt(index), index, animation),
      onReorderItem: widget.onReorder,
    );
  }

  // Indices here are positions among the matches, which onReorder cannot
  // map back onto the full list, so a filtered list is not reorderable.
  Widget _buildSearchResults(
    BuildContext context,
    List<T> items,
    Set<K> selected,
  ) {
    return ListView.builder(
      controller: _scrollController,
      padding: _listPadding(context),
      itemBuilder: (_, index) => _buildItem(
        context,
        items[index],
        index,
        items.length,
        selected,
        reorderable: false,
      ),
      itemExtent: widget.itemExtent,
      itemCount: items.length,
    );
  }
}
