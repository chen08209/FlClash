import 'package:fl_clash/ui/shape.dart';
import 'package:material_ui/material_ui.dart';

const tableColumnMinWidth = 48.0;
const _resizeHandleWidth = 12.0;

class TableColumn {
  const TableColumn(
    this.id,
    this.label, {
    this.width,
    this.flex = 0,
    this.end = false,
    this.resizable = true,
  }) : assert((width == null) != (flex == 0));

  final String id;
  final String label;
  final double? width;
  final double flex;
  final bool end;
  final bool resizable;
}

List<double> tableColumnWidths(
  List<TableColumn> columns,
  double width, [
  Map<String, double> overrides = const {},
]) {
  final sized = [
    for (final column in columns) overrides[column.id] ?? column.width,
  ];
  var fixed = 0.0;
  var flex = 0.0;
  var flexCount = 0;
  for (final (index, column) in columns.indexed) {
    final size = sized[index];
    if (size == null) {
      flex += column.flex;
      flexCount++;
    } else {
      fixed += size;
    }
  }
  final free = width - fixed;
  if (overrides.isEmpty ||
      (flexCount > 0 && free >= flexCount * tableColumnMinWidth)) {
    final share = free.clamp(0.0, double.infinity);
    return [
      for (final (index, column) in columns.indexed)
        sized[index] ?? share * column.flex / flex,
    ];
  }
  // The window has shrunk below the dragged widths, or they left no column to
  // take up the slack: everything scales to fit.
  final natural = [for (final size in sized) size ?? tableColumnMinWidth];
  final total = natural.fold<double>(0, (sum, size) => sum + size);
  return [for (final size in natural) size * width / total];
}

Map<String, double> resizedTableColumns(
  List<TableColumn> columns,
  List<double> widths,
  Map<String, double> overrides,
  int boundary,
  double delta,
) {
  final resized = [...widths];
  if (delta > 0) {
    var rest = delta;
    for (var index = boundary + 1; index < columns.length; index++) {
      if (rest <= 0) {
        break;
      }
      if (!columns[index].resizable) {
        continue;
      }
      final taken = rest.clamp(
        0.0,
        (resized[index] - tableColumnMinWidth).clamp(0.0, double.infinity),
      );
      resized[index] -= taken;
      rest -= taken;
    }
    resized[boundary] += delta - rest;
  } else {
    final given = (-delta).clamp(
      0.0,
      (resized[boundary] - tableColumnMinWidth).clamp(0.0, double.infinity),
    );
    resized[boundary] -= given;
    resized[boundary + 1] += given;
  }
  return {
    ...overrides,
    for (final (index, column) in columns.indexed)
      if (resized[index] != widths[index]) column.id: resized[index],
  };
}

class TableCells extends StatelessWidget {
  const TableCells({
    super.key,
    required this.columns,
    required this.widths,
    required this.height,
    required this.inset,
    required this.cells,
  });

  final List<TableColumn> columns;
  final List<double> widths;
  final double height;
  final double inset;
  final List<Widget> cells;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Row(
        children: [
          for (final (index, cell) in cells.indexed)
            SizedBox(
              width: widths[index],
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: inset),
                child: Align(
                  alignment: columns[index].end
                      ? AlignmentDirectional.centerEnd
                      : AlignmentDirectional.centerStart,
                  child: cell,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class TableColumnResizer extends StatelessWidget {
  const TableColumnResizer({
    super.key,
    required this.columns,
    required this.widths,
    required this.onResize,
    required this.onResizeEnd,
    required this.onReset,
    required this.child,
  });

  final List<TableColumn> columns;
  final List<double> widths;
  final void Function(int boundary, double delta) onResize;
  final VoidCallback onResizeEnd;
  final VoidCallback onReset;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final direction = Directionality.of(context) == TextDirection.rtl ? -1 : 1;
    final handles = <Widget>[];
    var edge = 0.0;
    for (var boundary = 0; boundary < columns.length - 1; boundary++) {
      edge += widths[boundary];
      if (!columns[boundary].resizable || !columns[boundary + 1].resizable) {
        continue;
      }
      handles.add(
        PositionedDirectional(
          start: edge - _resizeHandleWidth / 2,
          top: 0,
          bottom: 0,
          width: _resizeHandleWidth,
          child: _ResizeHandle(
            onDrag: (delta) => onResize(boundary, delta * direction),
            onDragEnd: onResizeEnd,
            onReset: onReset,
          ),
        ),
      );
    }
    return Stack(children: [child, ...handles]);
  }
}

class _ResizeHandle extends StatefulWidget {
  const _ResizeHandle({
    required this.onDrag,
    required this.onDragEnd,
    required this.onReset,
  });

  final ValueChanged<double> onDrag;
  final VoidCallback onDragEnd;
  final VoidCallback onReset;

  @override
  State<_ResizeHandle> createState() => _ResizeHandleState();
}

class _ResizeHandleState extends State<_ResizeHandle> {
  var _hovered = false;
  var _dragging = false;

  void _endDrag() {
    setState(() => _dragging = false);
    widget.onDragEnd();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.resizeColumn,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onHorizontalDragStart: (_) => setState(() => _dragging = true),
        onHorizontalDragUpdate: (details) => widget.onDrag(details.delta.dx),
        onHorizontalDragEnd: (_) => _endDrag(),
        onHorizontalDragCancel: _endDrag,
        onDoubleTap: widget.onReset,
        child: Center(
          child: Visibility.maintain(
            visible: _hovered || _dragging,
            child: SizedBox(
              width: 2,
              height: 16,
              child: DecoratedBox(
                decoration: ShapeDecoration(
                  color: Theme.of(context).colorScheme.outline,
                  shape: AppShape.full,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
