import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/models/common.dart';
import 'package:fl_clash/models/state.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

typedef ListEditorItemBuilder<T> =
    Widget Function(
      BuildContext context,
      WidgetRef ref,
      T item,
      int index,
      bool isEditing,
      bool isSelected,
      VoidCallback onToggleSelected,
    );

class ListEditorPage<T, K> extends ConsumerStatefulWidget {
  final String title;
  final List<T>? Function(WidgetRef ref) itemsOf;
  final ListEditorItemBuilder<T> itemBuilder;
  final void Function(int oldIndex, int newIndex) onReorder;
  final VoidCallback onAdd;
  final VoidCallback? onQuickEdit;
  final List<CommonPopupMenuItem> addMenuItems;
  final String emptyLabel;
  final double? itemExtent;
  final bool selectionEnabled;
  final K Function(T item) idOf;
  final void Function(Set<K> ids)? onDelete;
  final Iterable<String?> Function(T item)? searchFieldsOf;
  final List<CommonPopupMenuItem> Function(T item)? menuItemsOf;

  const ListEditorPage({
    super.key,
    required this.title,
    required this.itemsOf,
    required this.itemBuilder,
    required this.onReorder,
    required this.onAdd,
    this.onQuickEdit,
    this.addMenuItems = const [],
    required this.emptyLabel,
    this.itemExtent,
    this.selectionEnabled = false,
    required this.idOf,
    this.onDelete,
    this.searchFieldsOf,
    this.menuItemsOf,
  });

  @override
  ConsumerState<ListEditorPage<T, K>> createState() =>
      _ListEditorPageState<T, K>();
}

class _ListEditorPageState<T, K> extends ConsumerState<ListEditorPage<T, K>> {
  late final ScrollController _scrollController;
  var _query = SearchQuery('');
  final _searchTexts = Expando<String>();
  var _selected = <K>{};

  @override
  void initState() {
    super.initState();
    _scrollController = sheetScrollController(context);
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
    Set<K> ids, {
    required Set<K> kept,
  }) async {
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
      _selected = kept;
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
    final menuItems = selected.isEmpty ? widget.menuItemsOf?.call(item) : null;
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
    if (widget.menuItemsOf == null) {
      return reorderable
          ? ReorderableDelayedDragStartListener(
              key: ValueKey(id),
              index: index,
              child: child,
            )
          : KeyedSubtree(key: ValueKey(id), child: child);
    }
    final row = ContextMenuRegion(menuItems: menuItems, child: child);
    if (!reorderable) {
      return KeyedSubtree(key: ValueKey(id), child: row);
    }
    return SortableItem(key: ValueKey(id), index: index, child: row);
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final loadedItems = widget.itemsOf(ref);
    final items = _visibleItems(loadedItems ?? const []);
    final isSearching = widget.searchFieldsOf != null && _query.isNotEmpty;
    final selected = _liveSelection(loadedItems);
    final visibleSelected = isSearching ? _liveSelection(items) : selected;
    final isSelecting = selected.isNotEmpty;
    final onDelete = widget.onDelete;
    final selectionActions = [
      if (onDelete != null)
        IconButtonData(
          glyph: AppGlyphs.delete,
          onPressed: visibleSelected.isEmpty
              ? null
              : () => _handleDelete(
                  onDelete,
                  visibleSelected,
                  kept: selected.difference(visibleSelected),
                ),
          tooltip: appLocalizations.delete,
        ),
      IconButtonData(
        glyph: AppGlyphs.selectAll,
        onPressed: () => _handleSelectAll(items),
        tooltip: appLocalizations.selectAll,
      ),
    ];
    return CommonScaffold(
      canSort:
          widget.menuItemsOf != null &&
          !isSelecting &&
          (loadedItems?.length ?? 0) > 1,
      title: widget.title,
      searchState: widget.searchFieldsOf != null
          ? AppBarSearchState(onSearch: _handleSearch)
          : null,
      actions: [
        if (!isSelecting)
          ListEditorAddAction(
            onAdd: widget.onAdd,
            onQuickEdit: widget.onQuickEdit,
            menuItems: widget.addMenuItems,
          ),
      ],
      selectionActions: isSelecting ? selectionActions : const [],
      body: NullStatusSwitcher(
        isLoading: loadedItems == null,
        isEmpty: items.isEmpty,
        isSearching: isSearching,
        nullStatus: NullStatus(label: widget.emptyLabel),
        child: Builder(
          builder: (context) {
            final rowAt = _rowsOf(
              context,
              items,
              selected,
              reorderable: !isSearching,
            );
            return CommonScrollBar(
              controller: _scrollController,
              child: _ArrivalScroll(
                builder: (cacheExtent) => isSearching
                    ? _buildSearchResults(context, items, rowAt, cacheExtent)
                    : _buildReorderableList(context, items, rowAt, cacheExtent),
              ),
            );
          },
        ),
      ),
    );
  }

  EdgeInsets _listPadding(BuildContext context) => EdgeInsets.fromLTRB(
    16,
    context.contentTopPadding,
    16,
    24 + BottomInsetScope.of(context),
  );

  /// Reuses each row it builds, so the list settling on its own rebuilds none.
  Widget Function(int index) _rowsOf(
    BuildContext context,
    List<T> items,
    Set<K> selected, {
    required bool reorderable,
  }) {
    final rows = <int, Widget>{};
    return (index) => rows[index] ??= _buildItem(
      context,
      items[index],
      index,
      items.length,
      selected,
      reorderable: reorderable,
    );
  }

  Widget _buildReorderableList(
    BuildContext context,
    List<T> items,
    Widget Function(int index) rowAt,
    ScrollCacheExtent? cacheExtent,
  ) {
    return ReorderableListView.builder(
      scrollController: _scrollController,
      buildDefaultDragHandles: false,
      padding: _listPadding(context),
      scrollCacheExtent: cacheExtent,
      itemBuilder: (_, index) => rowAt(index),
      itemExtent: widget.itemExtent,
      itemCount: items.length,
      proxyDecorator: (child, index, animation) =>
          commonProxyDecorator(rowAt(index), index, animation),
      onReorderItem: widget.onReorder,
    );
  }

  // Indices here are positions among the matches, which onReorder cannot
  // map back onto the full list, so a filtered list is not reorderable.
  Widget _buildSearchResults(
    BuildContext context,
    List<T> items,
    Widget Function(int index) rowAt,
    ScrollCacheExtent? cacheExtent,
  ) {
    return ListView.builder(
      controller: _scrollController,
      padding: _listPadding(context),
      scrollCacheExtent: cacheExtent,
      itemBuilder: (_, index) => rowAt(index),
      itemExtent: widget.itemExtent,
      itemCount: items.length,
    );
  }
}

class _ArrivalScroll extends StatefulWidget {
  const _ArrivalScroll({required this.builder});

  final Widget Function(ScrollCacheExtent? cacheExtent) builder;

  @override
  State<_ArrivalScroll> createState() => _ArrivalScrollState();
}

class _ArrivalScrollState extends State<_ArrivalScroll>
    with RouteSettledMixin<_ArrivalScroll> {
  @override
  void didSettleRoute() => setState(() {});

  @override
  Widget build(BuildContext context) =>
      widget.builder(arrivalScrollCacheExtent(routeSettled));
}

class ListEditorAddAction extends StatelessWidget {
  final VoidCallback onAdd;
  final VoidCallback? onQuickEdit;
  final List<CommonPopupMenuItem> menuItems;

  const ListEditorAddAction({
    super.key,
    required this.onAdd,
    this.onQuickEdit,
    this.menuItems = const [],
  });

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final onQuickEdit = this.onQuickEdit;
    if (onQuickEdit == null && menuItems.isEmpty) {
      return AppBarActionButton(
        data: IconButtonData(
          glyph: AppGlyphs.addCircle,
          onPressed: onAdd,
          tooltip: appLocalizations.add,
        ),
      );
    }
    return CommonPopupBox(
      targetBuilder: (open) => AppBarActionButton(
        data: IconButtonData(
          glyph: AppGlyphs.addCircle,
          onPressed: () =>
              open(offset: Offset(0, context.isMobileView ? 0 : 20)),
          tooltip: appLocalizations.add,
        ),
      ),
      popupBuilder: (_) => CommonPopupMenu(
        items: [
          CommonPopupMenuItem(
            glyph: AppGlyphs.add,
            label: appLocalizations.add,
            onPressed: onAdd,
          ),
          ...menuItems,
          if (onQuickEdit != null)
            CommonPopupMenuItem(
              glyph: AppGlyphs.compose,
              label: appLocalizations.quickEdit,
              onPressed: onQuickEdit,
            ),
        ],
      ),
    );
  }
}
