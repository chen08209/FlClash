import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/ui/icons/icons.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/widgets.dart';
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
  final List<PopupMenuItem> addMenuItems;
  final String emptyLabel;
  final double? itemExtent;
  final K Function(T item) idOf;
  final void Function(Set<K> ids)? onDelete;
  final Iterable<String?> Function(T item)? searchFieldsOf;
  final List<PopupMenuItem> Function(T item)? menuItemsOf;

  /// Read-only sliver sections after the items, made for the search on; null
  /// while they are still on their way. With no item shown, the first section
  /// heads the list and drops the gap above it.
  final List<Widget>? Function(
    WidgetRef ref,
    SearchQuery query, {
    required bool atTop,
  })?
  sectionsOf;

  /// Heads the items on a page with [sectionsOf] from its first frame, unless the
  /// sections come back empty, so sections arriving only add to the list.
  final String? itemsTitle;

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
    required this.idOf,
    this.onDelete,
    this.searchFieldsOf,
    this.menuItemsOf,
    this.sectionsOf,
    this.itemsTitle,
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
    if (_selected.isEmpty || items == null) {
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
      destructive: true,
      confirmText: context.appLocalizations.delete,
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
    final position = ItemPosition.get(index, total);
    final isEditing = selected.isNotEmpty;
    final isSelected = selected.contains(id);
    return MemoBuilder(
      key: ValueKey(id),
      inputs: [
        widget,
        item,
        index,
        position,
        isEditing,
        isSelected,
        reorderable,
      ],
      builder: (_) {
        final child = ItemPositionProvider(
          position: position,
          child: widget.itemBuilder(
            context,
            ref,
            item,
            index,
            isEditing,
            isSelected,
            () => _handleToggleSelected(item),
          ),
        );
        if (widget.menuItemsOf == null) {
          return reorderable
              ? ReorderDragStartListener(index: index, child: child)
              : child;
        }
        final row = ContextMenuRegion(
          menuItems: isEditing ? null : widget.menuItemsOf!(item),
          child: child,
        );
        return reorderable ? SortableItem(index: index, child: row) : row;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final loadedItems = widget.itemsOf(ref);
    final items = _visibleItems(loadedItems ?? const []);
    final isSearching = widget.searchFieldsOf != null && _query.isNotEmpty;
    final sectionsOf = widget.sectionsOf;
    final builtSections = sectionsOf == null
        ? const <Widget>[]
        : sectionsOf(ref, _query, atTop: items.isEmpty);
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
    return Scaffold(
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
      body: _SectionsGate(
        deferred: sectionsOf != null,
        read: builtSections != null,
        builder: (showsSections) {
          final sectionsOrNull = showsSections ? builtSections : null;
          final sections = sectionsOrNull ?? const <Widget>[];
          return NullStatusSwitcher(
            isLoading:
                loadedItems == null || sectionsOrNull == null && items.isEmpty,
            isEmpty: items.isEmpty && sections.isEmpty,
            isSearching: isSearching,
            nullStatus: NullStatus(
              label: widget.emptyLabel,
              illustration: NullStatusIllustration.data,
            ),
            child: _RowsAfterPush(
              child: Builder(
                builder: (context) {
                  final rowAt = _rowsOf(
                    context,
                    items,
                    selected,
                    reorderable: !isSearching,
                  );
                  return Scrollbar(
                    controller: _scrollController,
                    child: ArrivalCacheExtentBuilder(
                      builder: (cacheExtent) => sectionsOf != null
                          ? _buildSections(
                              context,
                              items,
                              rowAt,
                              cacheExtent,
                              sectionsOrNull,
                              reorderable: !isSearching,
                            )
                          : isSearching
                          ? _buildSearchResults(
                              context,
                              items,
                              rowAt,
                              cacheExtent,
                            )
                          : _buildReorderableList(
                              context,
                              items,
                              rowAt,
                              cacheExtent,
                            ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  EdgeInsets _listPadding(BuildContext context) => EdgeInsets.fromLTRB(
    16,
    context.contentTopPadding,
    16,
    24 + context.bottomInset,
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
    return PrismReorderableListView(
      controller: _scrollController,
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

  Widget _buildSections(
    BuildContext context,
    List<T> items,
    Widget Function(int index) rowAt,
    ScrollCacheExtent? cacheExtent,
    List<Widget>? sections, {
    required bool reorderable,
  }) {
    final itemsTitle = widget.itemsTitle;
    return CustomScrollView(
      controller: _scrollController,
      scrollCacheExtent: cacheExtent,
      slivers: [
        SliverPadding(
          padding: _listPadding(context),
          sliver: SliverMainAxisGroup(
            slivers: [
              if (itemsTitle != null &&
                  items.isNotEmpty &&
                  sections?.isEmpty != true)
                SliverToBoxAdapter(
                  child: ListHeader(title: itemsTitle, atTop: true),
                ),
              if (reorderable)
                SliverPrismReorderableList(
                  itemBuilder: (_, index) => rowAt(index),
                  itemExtent: widget.itemExtent,
                  itemCount: items.length,
                  proxyDecorator: (child, index, animation) =>
                      commonProxyDecorator(rowAt(index), index, animation),
                  onReorderItem: widget.onReorder,
                )
              else
                SliverPrismList(
                  itemBuilder: (_, index) => rowAt(index),
                  itemExtent: widget.itemExtent,
                  itemCount: items.length,
                ),
              ...?sections,
            ],
          ),
        ),
      ],
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
    return PrismListView(
      controller: _scrollController,
      padding: _listPadding(context),
      scrollCacheExtent: cacheExtent,
      itemBuilder: (_, index) => rowAt(index),
      itemExtent: widget.itemExtent,
      itemCount: items.length,
    );
  }
}

class ListEditorAddAction extends StatelessWidget {
  final VoidCallback onAdd;
  final VoidCallback? onQuickEdit;
  final List<PopupMenuItem> menuItems;

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
    return PopupAnchor(
      targetBuilder: (open) => AppBarActionButton(
        data: IconButtonData(
          glyph: AppGlyphs.addCircle,
          onPressed: open,
          tooltip: appLocalizations.add,
        ),
      ),
      popupBuilder: (_) => PopupMenu(
        items: [
          PopupMenuItem(
            glyph: AppGlyphs.add,
            label: appLocalizations.add,
            onPressed: onAdd,
          ),
          ...menuItems,
          if (onQuickEdit != null)
            PopupMenuItem(
              glyph: AppGlyphs.compose,
              label: appLocalizations.quickEdit,
              onPressed: onQuickEdit,
            ),
        ],
      ),
    );
  }
}

/// Lays out [child] a held frame after the rest of a page its route pushes.
/// Only this element depends on the route, so the page does not rebuild when
/// another page covers or uncovers it.
class _RowsAfterPush extends StatefulWidget {
  const _RowsAfterPush({required this.child});

  final Widget child;

  @override
  State<_RowsAfterPush> createState() => _RowsAfterPushState();
}

class _RowsAfterPushState extends State<_RowsAfterPush> {
  var _ready = true;
  var _checked = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_checked) {
      return;
    }
    _checked = true;
    final animation = ModalRoute.of(context)?.animation;
    if (animation == null ||
        animation.status != AnimationStatus.forward ||
        animation.value > 0) {
      return;
    }
    _ready = false;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() => _ready = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) => ArrivalHold(
    ready: _ready,
    child: _ready ? widget.child : const SizedBox.shrink(),
  );
}

/// Shows the sections a page reads, holding its push until they are read and
/// keeping ones read after the push went until the route has settled, so a
/// whole screen of rows does not land in a moving frame. Only this element
/// depends on the route, and it keeps what it built while the route alone
/// changes.
class _SectionsGate extends StatefulWidget {
  const _SectionsGate({
    required this.deferred,
    required this.read,
    required this.builder,
  });

  final bool deferred;
  final bool read;
  final Widget Function(bool showsSections) builder;

  @override
  State<_SectionsGate> createState() => _SectionsGateState();
}

class _SectionsGateState extends State<_SectionsGate>
    with RouteMotionHoldMixin<_SectionsGate> {
  late var _shows = !widget.deferred;
  var _requested = false;
  Widget? _built;

  @override
  void didUpdateWidget(_SectionsGate oldWidget) {
    super.didUpdateWidget(oldWidget);
    _built = null;
  }

  void _request() {
    if (_requested) {
      return;
    }
    _requested = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        showFirstContent(
          () => setState(() {
            _shows = true;
            _built = null;
          }),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.read && !_shows) {
      _request();
    }
    return _built ??= ArrivalHold(ready: _shows, child: widget.builder(_shows));
  }
}
