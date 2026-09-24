import 'package:code_forge/code_forge.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

ReplaceOperation _replace(int offset) => ReplaceOperation(
  offset: offset,
  deletedText: 'a',
  insertedText: 'b',
  selectionBefore: TextSelection.collapsed(offset: offset),
  selectionAfter: TextSelection.collapsed(offset: offset + 1),
);

void main() {
  test('a compound operation still groups once the history is full', () {
    final undo = UndoRedoController();
    addTearDown(undo.dispose);
    for (var i = 0; i < 2000; i++) {
      undo.recordEdit(_replace(i));
    }

    final group = undo.beginCompoundOperation();
    undo.recordEdit(_replace(0));
    undo.recordEdit(_replace(1));
    group.end();

    final stack = undo.undoStack;
    expect(
      stack.last,
      isA<CompoundOperation>().having(
        (operation) => operation.operations,
        'operations',
        hasLength(2),
      ),
    );
    expect(
      stack[stack.length - 2],
      isA<ReplaceOperation>().having(
        (operation) => operation.offset,
        'offset',
        1999,
      ),
    );
  });
}
