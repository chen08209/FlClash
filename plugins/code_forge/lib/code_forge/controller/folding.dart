part of '../controller.dart';

extension CodeForgeControllerFolding on CodeForgeController {
  void _rebuildFoldSortedCache() {
    final starts = <int>[];
    final ends = <int>[];
    for (final fold in _foldings.values) {
      if (fold != null && fold.isFolded) {
        starts.add(fold.startIndex);
        ends.add(fold.endIndex);
      }
    }

    if (starts.length > 1) {
      final indices = List.generate(starts.length, (i) => i);
      indices.sort((a, b) => starts[a].compareTo(starts[b]));
      _foldedStartsSorted = [for (final i in indices) starts[i]];
      _foldedEndsSorted = [for (final i in indices) ends[i]];
    } else {
      _foldedStartsSorted = starts;
      _foldedEndsSorted = ends;
    }
  }

  /// Set by the render object.
  void setFoldCallback(void Function(int lineNumber)? toggleFold) {
    _toggleFoldCallback = toggleFold;
  }

  /// Toggles the fold state at the specified line number.
  ///
  /// [lineNumber] is zero-indexed (0 for the first line). A line that starts
  /// no fold region is ignored.
  ///
  /// Throws [StateError] if no editor is mounted on this controller.
  ///
  /// Example:
  /// ```dart
  /// controller.toggleFold(5); // Toggle fold at line 6
  /// ```
  void toggleFold(int lineNumber) {
    if (_toggleFoldCallback == null) {
      throw StateError('Folding is not enabled or editor is not initialized');
    }
    _toggleFoldCallback!(lineNumber);
  }

  /// Sets the scroll callback - called by the render object.
  void setScrollCallback(void Function(int line)? scrollToLine) {
    _scrollToLineCallback = scrollToLine;
  }

  /// Drops [scrollToLine] and [toggleFold] where they are still the current
  /// callbacks; an editor rebuilt on this controller may have replaced them
  /// before the old one is disposed.
  void releaseCallbacks(
    void Function(int line) scrollToLine,
    void Function(int lineNumber) toggleFold,
  ) {
    if (identical(_scrollToLineCallback, scrollToLine)) {
      _scrollToLineCallback = null;
    }
    if (identical(_toggleFoldCallback, toggleFold)) _toggleFoldCallback = null;
  }

  /// Scrolls the editor view to make the specified line visible.
  ///
  /// [line] is zero-indexed (0 for the first line). The editor will scroll
  /// vertically to bring the specified line into view, centering it if possible.
  ///
  /// If the line is within a folded region, the fold will be expanded first
  /// to make the line visible.
  ///
  /// Throws [StateError] if the editor has not been initialized.
  /// Throws [RangeError] if [line] is out of bounds.
  ///
  /// Example:
  /// ```dart
  /// // Scroll to line 50 (1-indexed line 51)
  /// controller.scrollToLine(50);
  ///
  /// // Scroll to the first line
  /// controller.scrollToLine(0);
  /// ```
  void scrollToLine(int line) {
    if (_scrollToLineCallback == null) {
      throw StateError('Editor is not initialized');
    }
    if (line < 0 || line >= lineCount) {
      throw RangeError.range(line, 0, lineCount - 1, 'line');
    }
    _scrollToLineCallback!(line);
  }

  /// Check whether the corresponding [lineIndex] is inside a folded code block or not.
  bool isLineInFoldedRegion(int lineIndex) {
    final starts = _foldedStartsSorted;
    final ends = _foldedEndsSorted;
    if (starts.isEmpty) return false;

    int lo = 0, hi = starts.length - 1;
    while (lo <= hi) {
      final mid = (lo + hi) >> 1;
      if (starts[mid] < lineIndex) {
        lo = mid + 1;
      } else {
        hi = mid - 1;
      }
    }

    for (int i = hi; i >= 0; i--) {
      if (starts[i] >= lineIndex) continue;
      if (ends[i] >= lineIndex) return true;
      if (lineIndex - starts[i] > 100000) break;
    }
    return false;
  }

  /// if the corresponding line is in a foldable region, this function returns the first line in that foldable block.
  int? getFoldStartForLine(int lineIndex) {
    final starts = _foldedStartsSorted;
    final ends = _foldedEndsSorted;
    if (starts.isEmpty) return null;
    int lo = 0, hi = starts.length - 1;
    while (lo <= hi) {
      final mid = (lo + hi) >> 1;
      if (starts[mid] < lineIndex) {
        lo = mid + 1;
      } else {
        hi = mid - 1;
      }
    }
    for (int i = hi; i >= 0; i--) {
      if (starts[i] >= lineIndex) continue;
      if (ends[i] >= lineIndex) return starts[i];
      if (lineIndex - starts[i] > 100000) break;
    }
    return null;
  }

  /// Get the [FoldRange] information if the corresponding line is included in a foldable block.
  FoldRange? getFoldRangeAtCurrentLine(int lineIndex) {
    return foldings[lineIndex];
  }
}
