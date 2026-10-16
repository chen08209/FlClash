import 'package:collection/collection.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/ui/icons/icons.dart';
import 'package:fl_clash/ui/ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

const _recordTableMinWidth = 720.0;
const recordWideTableWidth = 1000.0;
const _recordTableMargin = 8.0;
const _recordCellInset = 8.0;
const _recordCellLineHeight = 20.0;
const _recordHeaderLineHeight = 16.0;
const _recordRowPadding = 8.0;

class RecordColumn<T> {
  final TableColumn layout;
  final Widget Function(BuildContext context, T item) cell;
  final Comparable<Object> Function(T item)? sortKey;
  final bool descendingFirst;

  const RecordColumn(
    this.layout, {
    required this.cell,
    this.sortKey,
    this.descendingFirst = false,
  });

  String get id => layout.id;
}

typedef RecordSort = ({String columnId, bool descending});

/// The first tap sorts the way the column reads best, the second flips it and
/// the third gives the list its own order back.
RecordSort? nextRecordSort<T>(RecordSort? sort, RecordColumn<T> column) {
  final first = column.descendingFirst;
  if (sort == null || sort.columnId != column.id) {
    return (columnId: column.id, descending: first);
  }
  if (sort.descending == first) {
    return (columnId: column.id, descending: !first);
  }
  return null;
}

class RecordSorter<T> {
  List<T>? _source;
  RecordSort? _sortedBy;
  List<T> _sorted = const [];

  /// [reverse] marks a list shown bottom up, its last item on top.
  List<T> sort(
    List<T> items,
    List<RecordColumn<T>> columns,
    RecordSort? sort, {
    bool reverse = false,
  }) {
    final sortKey = sort == null
        ? null
        : columns
              .firstWhereOrNull((column) => column.id == sort.columnId)
              ?.sortKey;
    if (sort == null || sortKey == null) {
      return items;
    }
    if (identical(_source, items) && _sortedBy == sort) {
      return _sorted;
    }
    final shown = reverse ? items.reversed.toList() : items;
    final keys = [for (final item in shown) sortKey(item)];
    final direction = sort.descending ? -1 : 1;
    // Sorting indexes keeps ties in their shown order; collection's
    // mergeSort is stable too but measured over ten times slower.
    final order = List.generate(shown.length, (index) => index)
      ..sort((a, b) {
        final compared = keys[a].compareTo(keys[b]);
        return compared != 0 ? direction * compared : a - b;
      });
    final sorted = [for (final index in order) shown[index]];
    _source = items;
    _sortedBy = sort;
    return _sorted = reverse ? sorted.reversed.toList() : sorted;
  }
}

/// Holds the widths a table's columns are dragged to and keeps them in the
/// app settings once a drag ends.
mixin TableColumnWidthsMixin<T extends ConsumerStatefulWidget>
    on ConsumerState<T> {
  String get tableId;

  late Map<String, double> columnWidths =
      ref.read(appSettingProvider).tableColumnWidths[tableId] ?? const {};

  void resizeColumn(
    List<TableColumn> columns,
    List<double> widths,
    int boundary,
    double delta,
  ) {
    setState(() {
      columnWidths = resizedTableColumns(
        columns,
        widths,
        columnWidths,
        boundary,
        delta,
      );
    });
  }

  void resetColumnWidths() {
    setState(() => columnWidths = const {});
    saveColumnWidths();
  }

  void saveColumnWidths() {
    final widths = columnWidths;
    ref
        .read(appSettingProvider.notifier)
        .update(
          (state) => state.copyWith(
            tableColumnWidths: {...state.tableColumnWidths, tableId: widths}
              ..removeWhere((_, widths) => widths.isEmpty),
          ),
        );
  }
}

class RecordTable<T> {
  final List<RecordColumn<T>> columns;
  final List<TableColumn> layouts;
  final List<double> widths;
  final double rowHeight;

  const RecordTable._({
    required this.columns,
    required this.layouts,
    required this.widths,
    required this.rowHeight,
  });

  List<Widget> cellsOf(BuildContext context, T item) => [
    for (final column in columns) column.cell(context, item),
  ];

  /// For a list separated by zero-height dividers, which sit at odd indexes.
  double estimateExtent(int? index, double crossAxisExtent) {
    return index != null && index.isEven ? rowHeight : 0;
  }
}

/// Builds a record list as a table once it is wide enough, with the column
/// header held above the rows, sorting them by the column tapped and resizing
/// columns by their edges.
class RecordTableFrame<T> extends ConsumerStatefulWidget {
  final String tableId;
  final List<T> items;

  /// Whether the list shows [items] bottom up, its last item on top.
  final bool reverse;
  final List<RecordColumn<T>> Function(double width) columnsOf;
  final Widget Function(
    BuildContext context,
    RecordTable<T>? table,
    List<T> items,
  )
  builder;

  const RecordTableFrame({
    super.key,
    required this.tableId,
    required this.items,
    this.reverse = false,
    required this.columnsOf,
    required this.builder,
  });

  @override
  ConsumerState<RecordTableFrame<T>> createState() =>
      _RecordTableFrameState<T>();
}

class _RecordTableFrameState<T> extends ConsumerState<RecordTableFrame<T>>
    with TableColumnWidthsMixin<RecordTableFrame<T>> {
  final _sorter = RecordSorter<T>();
  RecordSort? _sort;

  @override
  String get tableId => widget.tableId;

  RecordTable<T>? _tableOf(BuildContext context, double width) {
    if (width < _recordTableMinWidth) {
      return null;
    }
    final columns = widget.columnsOf(width);
    final layouts = [for (final column in columns) column.layout];
    return RecordTable._(
      columns: columns,
      layouts: layouts,
      widths: tableColumnWidths(
        layouts,
        width - _recordTableMargin * 2,
        columnWidths,
      ),
      rowHeight:
          MediaQuery.textScalerOf(context).scale(_recordCellLineHeight) +
          _recordRowPadding * 2,
    );
  }

  @override
  Widget build(BuildContext context) {
    return WidthBuilder(
      builder: (context, width) {
        final table = _tableOf(context, width);
        if (table == null) {
          return widget.builder(context, null, widget.items);
        }
        final items = _sorter.sort(
          widget.items,
          table.columns,
          _sort,
          reverse: widget.reverse,
        );
        return Padding(
          padding: EdgeInsets.only(top: context.contentTopPadding),
          child: MediaQuery.removePadding(
            context: context,
            removeTop: true,
            child: FloatingBarScope(
              inset: 0,
              child: TopInsetScope(
                inset: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _RecordTableHeader(
                      table: table,
                      sort: _sort,
                      onSort: (column) =>
                          setState(() => _sort = nextRecordSort(_sort, column)),
                      onResize: (boundary, delta) => resizeColumn(
                        table.layouts,
                        table.widths,
                        boundary,
                        delta,
                      ),
                      onResizeEnd: saveColumnWidths,
                      onReset: resetColumnWidths,
                    ),
                    Expanded(
                      child: Builder(
                        builder: (context) =>
                            widget.builder(context, table, items),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _RecordTableHeader<T> extends StatelessWidget {
  final RecordTable<T> table;
  final RecordSort? sort;
  final ValueChanged<RecordColumn<T>> onSort;
  final void Function(int boundary, double delta) onResize;
  final VoidCallback onResizeEnd;
  final VoidCallback onReset;

  const _RecordTableHeader({
    required this.table,
    required this.sort,
    required this.onSort,
    required this.onResize,
    required this.onResizeEnd,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final height =
        MediaQuery.textScalerOf(context).scale(_recordHeaderLineHeight) +
        _recordRowPadding * 2;
    final labelStyle = AppTextStyle.caption1.of(context, emphasized: true);
    final style = labelStyle.copyWith(
      color: colorScheme.onSurfaceVariant,
      height: _recordHeaderLineHeight / labelStyle.fontSize!,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: _recordTableMargin),
      child: Material(
        color: context.raisedSurfaceLevel.colorOf(colorScheme),
        shape: AppShape.all(AppCorner.fit(height)),
        clipBehavior: Clip.antiAlias,
        child: TableColumnResizer(
          columns: table.layouts,
          widths: table.widths,
          onResize: onResize,
          onResizeEnd: onResizeEnd,
          onReset: onReset,
          child: TableCells(
            columns: table.layouts,
            widths: table.widths,
            height: height,
            inset: 0,
            cells: [
              for (final column in table.columns)
                RecordHeaderCell(
                  label: column.layout.label,
                  end: column.layout.end,
                  style: style,
                  inset: _recordCellInset,
                  descending: sort?.columnId == column.id
                      ? sort?.descending
                      : null,
                  onTap: column.sortKey == null ? null : () => onSort(column),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The width a fixed column takes to show [label] whole in its header.
double recordHeaderWidth(BuildContext context, String label) =>
    MeasureScope.of(context)
        .computeTextSize(
          Text(
            label,
            style: AppTextStyle.caption1.of(context, emphasized: true),
          ),
        )
        .width
        .ceilToDouble() +
    _recordCellInset * 2;

class RecordHeaderCell extends StatelessWidget {
  final String label;
  final bool end;
  final TextStyle style;
  final double inset;

  /// Null unless the rows are sorted by this column.
  final bool? descending;
  final VoidCallback? onTap;

  const RecordHeaderCell({
    super.key,
    required this.label,
    required this.end,
    required this.style,
    required this.inset,
    required this.descending,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final descending = this.descending;
    final color = descending == null
        ? style.color
        : context.colorScheme.onSurface;
    final content = Padding(
      padding: EdgeInsets.symmetric(horizontal: inset),
      child: Row(
        mainAxisAlignment: end
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        spacing: 2,
        children: [
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: style.copyWith(color: color),
            ),
          ),
          if (descending != null)
            GlyphIcon(
              descending ? AppGlyphs.arrowDown : AppGlyphs.arrowUp,
              size: 12,
              color: color,
            ),
        ],
      ),
    );
    final onTap = this.onTap;
    if (onTap == null) {
      return content;
    }
    return InkWell(
      onTap: onTap,
      child: SizedBox.expand(child: content),
    );
  }
}

class RecordTableRow extends StatelessWidget {
  final RecordTable<Object?> table;
  final List<Widget> cells;
  final bool striped;
  final VoidCallback? onTap;

  const RecordTableRow({
    super.key,
    required this.table,
    required this.cells,
    required this.striped,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final style = AppTextStyle.subheadline.of(context);
    final shape = AppShape.all(AppCorner.fit(table.rowHeight));
    final level = striped ? context.raisedSurfaceLevel : context.surfaceLevel;
    final fill = striped ? level.colorOf(colorScheme) : null;
    Widget row = Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        customBorder: shape,
        child: DefaultTextStyle(
          style: style.copyWith(
            color: colorScheme.onSurface,
            height: _recordCellLineHeight / style.fontSize!,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          child: TableCells(
            columns: table.layouts,
            widths: table.widths,
            height: table.rowHeight,
            inset: _recordCellInset,
            cells: cells,
          ),
        ),
      ),
    );
    if (fill != null) {
      row = DecoratedBox(
        decoration: ShapeDecoration(color: fill, shape: shape),
        child: row,
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: _recordTableMargin),
      child: SurfaceScope(level: level, child: row),
    );
  }
}

class RecordCellText extends StatelessWidget {
  final String text;
  final bool muted;

  const RecordCellText(this.text, {super.key, this.muted = false});

  @override
  Widget build(BuildContext context) {
    return Text(
      text.isEmpty ? '—' : text,
      style: muted
          ? TextStyle(color: context.colorScheme.onSurfaceVariant)
          : null,
    );
  }
}
