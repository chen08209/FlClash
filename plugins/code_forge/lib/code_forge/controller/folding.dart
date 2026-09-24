part of '../controller.dart';

extension CodeForgeControllerFolding on CodeForgeController {
  void _rebuildFoldSortedCache() {
    _folded = [
      for (final fold in _foldings.values)
        if (fold != null && fold.isFolded)
          (start: fold.startIndex, end: fold.endIndex),
    ]..sort((a, b) => a.start.compareTo(b.start));
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
  void toggleFold(int lineNumber) => _mountedView.toggleFold(lineNumber);

  CodeForgeView get _mountedView =>
      _view ?? (throw StateError('No editor is mounted on this controller'));

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
    final view = _mountedView;
    if (line < 0 || line >= lineCount) {
      throw RangeError.range(line, 0, lineCount - 1, 'line');
    }
    view.scrollToLine(line);
  }

  /// Check whether the corresponding [lineIndex] is inside a folded code block or not.
  bool isLineInFoldedRegion(int lineIndex) => _foldHiding(lineIndex) != null;

  /// if the corresponding line is in a foldable region, this function returns the first line in that foldable block.
  int? getFoldStartForLine(int lineIndex) => _foldHiding(lineIndex)?.start;

  ({int start, int end})? _foldHiding(int lineIndex) {
    final folded = _folded;
    int lo = 0, hi = folded.length - 1;
    while (lo <= hi) {
      final mid = (lo + hi) >> 1;
      if (folded[mid].start < lineIndex) {
        lo = mid + 1;
      } else {
        hi = mid - 1;
      }
    }
    for (int i = hi; i >= 0; i--) {
      final fold = folded[i];
      if (fold.end >= lineIndex) return fold;
      if (lineIndex - fold.start > 100000) break;
    }
    return null;
  }
}

/// Lines [startIndex] + 1 to [endIndex] hide while [isFolded].
class FoldRange {
  final int startIndex;
  final int endIndex;
  bool isFolded = false;

  /// The nested folds that folding this one opened, to refold when it unfolds.
  List<FoldRange> originallyFoldedChildren = [];

  FoldRange(this.startIndex, this.endIndex);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FoldRange &&
        other.startIndex == startIndex &&
        other.endIndex == endIndex;
  }

  @override
  int get hashCode => startIndex.hashCode ^ endIndex.hashCode;
}
