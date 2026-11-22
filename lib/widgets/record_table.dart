import 'package:collection/collection.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/ui/icons/icons.dart';
import 'package:fl_clash/ui/ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  List<T> sort(List<T> items, List<RecordColumn<T>> columns, RecordSort? sort) {
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
    final keys = [for (final item in items) sortKey(item)];
    final direction = sort.descending ? -1 : 1;
    // Sorting indexes keeps ties in their shown order; collection's
    // mergeSort is stable too but measured over ten times slower.
    final order = List.generate(items.length, (index) => index)
      ..sort((a, b) {
        final compared = keys[a].compareTo(keys[b]);
        return compared != 0 ? direction * compared : a - b;
      });
    _source = items;
    _sortedBy = sort;
    return _sorted = [for (final index in order) items[index]];
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
    return PressSurface(
      fill: Colors.transparent,
      shape: AppShape.all(AppCorner.none),
      childFills: true,
      onPressed: onTap,
      child: SizedBox.expand(child: content),
    );
  }
}
