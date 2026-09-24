import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Represents a single edit operation that can be undone/redone.
/// Designed to work efficiently with rope data structures.
sealed class EditOperation {
  /// The cursor position before this edit
  final TextSelection selectionBefore;

  /// The cursor position after this edit
  final TextSelection selectionAfter;

  /// Timestamp when this edit was made
  final DateTime timestamp;

  EditOperation({
    required this.selectionBefore,
    required this.selectionAfter,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  /// Create the inverse operation for undo
  EditOperation inverse();

  /// Check if this operation can be merged with another (for grouping rapid edits)
  bool canMergeWith(EditOperation other);

  /// Merge this operation with another
  EditOperation mergeWith(EditOperation other);
}

/// An insertion operation
class InsertOperation extends EditOperation {
  /// Position where text was inserted
  final int offset;

  /// The text that was inserted
  final String text;

  /// [text]'s length in Unicode scalars, the unit [offset] counts in.
  final int length;

  InsertOperation({
    required this.offset,
    required this.text,
    int? length,
    required super.selectionBefore,
    required super.selectionAfter,
    super.timestamp,
  }) : length = length ?? text.runes.length;

  @override
  EditOperation inverse() {
    return DeleteOperation(
      offset: offset,
      text: text,
      length: length,
      selectionBefore: selectionAfter,
      selectionAfter: selectionBefore,
    );
  }

  @override
  bool canMergeWith(EditOperation other) {
    if (other is! InsertOperation) return false;

    final timeDiff = other.timestamp.difference(timestamp).inMilliseconds.abs();
    if (timeDiff > 500) return false;

    if (other.offset == offset + length) {
      if (text.contains('\n') || other.text.contains('\n')) return false;
      final thisEndsWithSpace = text.endsWith(' ') || text.endsWith('\t');
      final otherStartsWithSpace =
          other.text.startsWith(' ') || other.text.startsWith('\t');
      if (thisEndsWithSpace != otherStartsWithSpace &&
          text.isNotEmpty &&
          other.text.isNotEmpty) {
        return false;
      }
      return true;
    }
    return false;
  }

  @override
  EditOperation mergeWith(EditOperation other) {
    if (other is! InsertOperation) return this;
    return InsertOperation(
      offset: offset,
      text: text + other.text,
      length: length + other.length,
      selectionBefore: selectionBefore,
      selectionAfter: other.selectionAfter,
      timestamp: other.timestamp,
    );
  }
}

/// A deletion operation
class DeleteOperation extends EditOperation {
  /// Position where deletion started
  final int offset;

  /// The text that was deleted
  final String text;

  final int length;

  DeleteOperation({
    required this.offset,
    required this.text,
    int? length,
    required super.selectionBefore,
    required super.selectionAfter,
    super.timestamp,
  }) : length = length ?? text.runes.length;

  @override
  EditOperation inverse() {
    return InsertOperation(
      offset: offset,
      text: text,
      length: length,
      selectionBefore: selectionAfter,
      selectionAfter: selectionBefore,
    );
  }

  @override
  bool canMergeWith(EditOperation other) {
    if (other is! DeleteOperation) return false;

    final timeDiff = other.timestamp.difference(timestamp).inMilliseconds.abs();
    if (timeDiff > 500) return false;

    if (text.contains('\n') || other.text.contains('\n')) return false;

    if (other.offset == offset - other.length) {
      return true;
    }

    if (other.offset == offset) {
      return true;
    }
    return false;
  }

  @override
  EditOperation mergeWith(EditOperation other) {
    if (other is! DeleteOperation) return this;

    if (other.offset == offset - other.length) {
      return DeleteOperation(
        offset: other.offset,
        text: other.text + text,
        length: other.length + length,
        selectionBefore: selectionBefore,
        selectionAfter: other.selectionAfter,
        timestamp: other.timestamp,
      );
    }

    if (other.offset == offset) {
      return DeleteOperation(
        offset: offset,
        text: text + other.text,
        length: length + other.length,
        selectionBefore: selectionBefore,
        selectionAfter: other.selectionAfter,
        timestamp: other.timestamp,
      );
    }
    return this;
  }
}

/// A replacement operation (delete + insert at same position)
class ReplaceOperation extends EditOperation {
  /// Position where replacement started
  final int offset;

  /// The text that was deleted
  final String deletedText;

  /// The text that was inserted
  final String insertedText;

  final int deletedLength, insertedLength;

  ReplaceOperation({
    required this.offset,
    required this.deletedText,
    required this.insertedText,
    int? deletedLength,
    int? insertedLength,
    required super.selectionBefore,
    required super.selectionAfter,
    super.timestamp,
  }) : deletedLength = deletedLength ?? deletedText.runes.length,
       insertedLength = insertedLength ?? insertedText.runes.length;

  @override
  EditOperation inverse() {
    return ReplaceOperation(
      offset: offset,
      deletedText: insertedText,
      insertedText: deletedText,
      deletedLength: insertedLength,
      insertedLength: deletedLength,
      selectionBefore: selectionAfter,
      selectionAfter: selectionBefore,
    );
  }

  @override
  bool canMergeWith(EditOperation other) {
    return false;
  }

  @override
  EditOperation mergeWith(EditOperation other) => this;
}

/// Controller for managing undo/redo operations.
///
/// Usage:
/// ```dart
/// final undoController = UndoRedoController();
///
/// CodeForge(
///   controller: controller,
///   undoController: undoController,
/// )
///
/// // Undo last operation
/// undoController.undo();
///
/// // Redo last undone operation
/// undoController.redo();
/// ```
class UndoRedoController extends ChangeNotifier {
  final List<EditOperation> undoStack = [];
  final List<EditOperation> redoStack = [];

  static const _maxStackSize = 1000;

  /// How many entries fell off the bottom of [undoStack], so a compound
  /// operation begun before one did still finds where it started.
  int _dropped = 0;

  /// Callback to apply an edit operation to the text
  void Function(EditOperation operation)? _applyEdit;
  void Function()? _settleInput;

  /// Whether an undo/redo operation is currently in progress
  bool _isUndoRedoInProgress = false;

  /// When set, the next recorded edit will not be merged into the previous
  /// one. Used so that the first edit inside a compound operation never merges
  /// into an edit recorded before the compound began (which would let it
  /// escape the group).
  bool _suppressNextMerge = false;

  /// Whether undo is available
  bool get canUndo => undoStack.isNotEmpty;

  /// Whether redo is available
  bool get canRedo => redoStack.isNotEmpty;

  /// Check if an undo/redo operation is currently being applied
  bool get isUndoRedoInProgress => _isUndoRedoInProgress;

  /// Set the callback to apply edit operations; without one, [undo] and
  /// [redo] leave the history as it is.
  void setApplyEditCallback(
    void Function(EditOperation operation) callback, {
    void Function()? settleInput,
  }) {
    _applyEdit = callback;
    _settleInput = settleInput;
  }

  /// Clears [callback] unless another owner has set its own since.
  void releaseApplyEditCallback(
    void Function(EditOperation operation) callback,
  ) {
    if (!identical(_applyEdit, callback)) return;
    _applyEdit = null;
    _settleInput = null;
  }

  /// Record an edit operation. Called by the controller when text changes.
  void recordEdit(EditOperation operation) {
    if (_isUndoRedoInProgress) return;

    if (redoStack.isNotEmpty) {
      redoStack.clear();
    }

    if (undoStack.isNotEmpty && !_suppressNextMerge) {
      final last = undoStack.last;
      if (last.canMergeWith(operation)) {
        undoStack[undoStack.length - 1] = last.mergeWith(operation);
        _suppressNextMerge = false;
        notifyListeners();
        return;
      }
    }
    _suppressNextMerge = false;

    undoStack.add(operation);

    while (undoStack.length > _maxStackSize) {
      undoStack.removeAt(0);
      _dropped++;
    }

    notifyListeners();
  }

  /// Undo the last operation
  bool undo() {
    _settleInput?.call();
    if (!canUndo || _applyEdit == null) return false;

    final operation = undoStack.removeLast();
    final inverse = operation.inverse();

    _isUndoRedoInProgress = true;
    try {
      _applyEdit!(inverse);
      redoStack.add(operation);
    } finally {
      _isUndoRedoInProgress = false;
    }

    notifyListeners();
    return true;
  }

  /// Redo the last undone operation
  bool redo() {
    _settleInput?.call();
    if (!canRedo || _applyEdit == null) return false;

    final operation = redoStack.removeLast();

    _isUndoRedoInProgress = true;
    try {
      _applyEdit!(operation);
      undoStack.add(operation);
    } finally {
      _isUndoRedoInProgress = false;
    }

    notifyListeners();
    return true;
  }

  /// Clear all undo/redo history
  void clear() {
    undoStack.clear();
    redoStack.clear();
    notifyListeners();
  }

  /// Begin a compound operation that should be undone as a single unit.
  /// Call [CompoundOperationHandle.end] when done.
  CompoundOperationHandle beginCompoundOperation() {
    _suppressNextMerge = true;
    return CompoundOperationHandle._(this);
  }

  /// A handle over the latest entry, so that what is recorded until it ends
  /// is undone together with that entry.
  CompoundOperationHandle? resumeLast() {
    if (undoStack.isEmpty) return null;
    _suppressNextMerge = true;
    return CompoundOperationHandle._(this, undoStack.length - 1);
  }

  void _groupSince(int start) {
    final newOps = undoStack.sublist(start);
    if (newOps.isEmpty) return;

    undoStack.removeRange(start, undoStack.length);

    final compound = CompoundOperation(
      operations: newOps,
      selectionBefore: newOps.first.selectionBefore,
      selectionAfter: newOps.last.selectionAfter,
    );

    undoStack.add(compound);
    notifyListeners();
  }

  @override
  void dispose() {
    undoStack.clear();
    redoStack.clear();
    super.dispose();
  }
}

/// Handle for grouping multiple edits into a single undo operation.
class CompoundOperationHandle {
  final UndoRedoController _controller;
  final int _startStackSize;
  final int _startDropped;
  bool _isActive = true;

  CompoundOperationHandle._(this._controller, [int? start])
    : _startStackSize = start ?? _controller.undoStack.length,
      _startDropped = _controller._dropped;

  /// End the compound operation, combining all recorded edits into one.
  void end() {
    if (!_isActive) return;
    _isActive = false;

    final dropped = _controller._dropped - _startDropped;
    _controller._groupSince(
      (_startStackSize - dropped).clamp(0, _controller.undoStack.length),
    );
  }
}

/// A compound operation that groups multiple edits into one undo unit.
class CompoundOperation extends EditOperation {
  final List<EditOperation> operations;

  CompoundOperation({
    required this.operations,
    required super.selectionBefore,
    required super.selectionAfter,
  });

  @override
  EditOperation inverse() {
    return CompoundOperation(
      operations: operations.reversed.map((op) => op.inverse()).toList(),
      selectionBefore: selectionAfter,
      selectionAfter: selectionBefore,
    );
  }

  @override
  bool canMergeWith(EditOperation other) => false;

  @override
  EditOperation mergeWith(EditOperation other) => this;

  @override
  String toString() => 'Compound(${operations.length} operations)';
}
