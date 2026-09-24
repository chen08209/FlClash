import 'dart:typed_data';

/// Where each model line sits vertically, in fixed-height rows.
///
/// An unmeasured line holds an estimate until painting measures it, so the
/// scroll extent can shift while scrolling through a wrapped document.
class ViewLineLayout {
  ViewLineLayout({required this.rowHeight});

  double rowHeight;

  Float64List _rows = Float64List(0);
  Uint8List _flags = Uint8List(0);
  Float64List _tree = Float64List(1);
  bool _treeDirty = false;
  int _lineCount = 0;
  double _estimatedRows = 1;

  static const int _hidden = 1;
  static const int _measured = 2;

  int get lineCount => _lineCount;

  double get estimatedRows => _estimatedRows;

  bool get hasHiddenLines => _hiddenCount > 0;
  int _hiddenCount = 0;

  void reset(int lineCount) {
    _lineCount = lineCount;
    _rows = Float64List(lineCount)..fillRange(0, lineCount, _estimatedRows);
    _flags = Uint8List(lineCount);
    _hiddenCount = 0;
    _treeDirty = true;
  }

  void setEstimate(double rows) {
    if (rows <= 0 || rows == _estimatedRows) return;
    _estimatedRows = rows;
    for (var i = 0; i < _lineCount; i++) {
      if (_flags[i] & _measured == 0) _rows[i] = rows;
    }
    _treeDirty = true;
  }

  bool isMeasured(int line) => _flags[line] & _measured != 0;

  bool isHidden(int line) => _flags[line] & _hidden != 0;

  double rowsOf(int line) => _rows[line];

  bool setRows(int line, int rows) {
    _flags[line] |= _measured;
    final delta = rows - _rows[line];
    if (delta == 0) return false;
    _rows[line] = rows.toDouble();
    if (_flags[line] & _hidden == 0) _add(line, delta);
    return true;
  }

  void invalidate(int line) {
    if (line < 0 || line >= _lineCount) return;
    _flags[line] &= ~_measured;
    final delta = _estimatedRows - _rows[line];
    if (delta == 0) return;
    _rows[line] = _estimatedRows;
    if (_flags[line] & _hidden == 0) _add(line, delta);
  }

  void invalidateAll() {
    for (var i = 0; i < _lineCount; i++) {
      _flags[i] &= ~_measured;
    }
    _rows.fillRange(0, _lineCount, _estimatedRows);
    _treeDirty = true;
  }

  void splice(int start, int removed, int inserted) {
    final newCount = _lineCount - removed + inserted;
    for (var i = start; i < start + removed; i++) {
      if (_flags[i] & _hidden != 0) _hiddenCount--;
    }
    final rows = Float64List(newCount);
    final flags = Uint8List(newCount);
    rows.setRange(0, start, _rows);
    flags.setRange(0, start, _flags);
    rows.fillRange(start, start + inserted, _estimatedRows);
    rows.setRange(start + inserted, newCount, _rows, start + removed);
    flags.setRange(start + inserted, newCount, _flags, start + removed);
    _rows = rows;
    _flags = flags;
    _lineCount = newCount;
    _treeDirty = true;
  }

  void setHiddenRanges(Iterable<({int start, int end})> ranges) {
    if (_hiddenCount == 0 && ranges.isEmpty) return;
    for (var i = 0; i < _lineCount; i++) {
      _flags[i] &= ~_hidden;
    }
    _hiddenCount = 0;
    for (final range in ranges) {
      final end = range.end < _lineCount ? range.end : _lineCount;
      for (var i = range.start < 0 ? 0 : range.start; i < end; i++) {
        if (_flags[i] & _hidden == 0) {
          _flags[i] |= _hidden;
          _hiddenCount++;
        }
      }
    }
    _treeDirty = true;
  }

  double lineHeight(int line) =>
      _flags[line] & _hidden != 0 ? 0 : _rows[line] * rowHeight;

  double lineTop(int line) => _prefix(_clampBoundary(line)) * rowHeight;

  double get totalHeight => _prefix(_lineCount) * rowHeight;

  int lineAt(double y) => _lineAtRow(y / rowHeight);

  int nextVisible(int line) {
    final clamped = _clampLine(line);
    if (_lineCount == 0 || _flags[clamped] & _hidden == 0) return clamped;
    return _lineAtRow(_prefix(clamped) + 0.5);
  }

  int _clampBoundary(int line) =>
      line < 0 ? 0 : (line > _lineCount ? _lineCount : line);

  int _clampLine(int line) =>
      line < 0 ? 0 : (line >= _lineCount ? _lineCount - 1 : line);

  int _lineAtRow(double row) {
    if (_lineCount == 0) return 0;
    _ensureTree();
    final total = _prefix(_lineCount);
    // A visible line spans at least one row, so half a row is a safe margin
    // against the rounding of summed row counts.
    var remaining = row >= total ? total - 0.5 : (row < 0 ? 0.0 : row);
    final tree = _tree;
    var index = 0;
    var step = 1;
    while (step * 2 <= _lineCount) {
      step *= 2;
    }
    for (; step > 0; step >>= 1) {
      final next = index + step;
      if (next <= _lineCount && tree[next] <= remaining) {
        index = next;
        remaining -= tree[next];
      }
    }
    return index < _lineCount ? index : _lineCount - 1;
  }

  double _prefix(int line) {
    _ensureTree();
    var sum = 0.0;
    for (var i = line; i > 0; i -= i & -i) {
      sum += _tree[i];
    }
    return sum;
  }

  void _add(int line, double delta) {
    if (_treeDirty) return;
    for (var i = line + 1; i <= _lineCount; i += i & -i) {
      _tree[i] += delta;
    }
  }

  void _ensureTree() {
    if (!_treeDirty) return;
    final tree = Float64List(_lineCount + 1);
    for (var i = 0; i < _lineCount; i++) {
      if (_flags[i] & _hidden == 0) tree[i + 1] += _rows[i];
    }
    for (var i = 1; i <= _lineCount; i++) {
      final parent = i + (i & -i);
      if (parent <= _lineCount) tree[parent] += tree[i];
    }
    _tree = tree;
    _treeDirty = false;
  }
}
