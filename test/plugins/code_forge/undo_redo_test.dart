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
  test('operations carry their lengths in scalars through merge and undo', () {
    const caret = TextSelection.collapsed(offset: 0);
    final at = DateTime(2026);
    final typed = InsertOperation(
      offset: 0,
      text: 'a\u{1F600}',
      selectionBefore: caret,
      selectionAfter: caret,
      timestamp: at,
    );
    final next = InsertOperation(
      offset: 2,
      text: 'b',
      selectionBefore: caret,
      selectionAfter: caret,
      timestamp: at,
    );
    expect(typed.length, 2);
    expect(typed.canMergeWith(next), isTrue);

    final merged = typed.mergeWith(next) as InsertOperation;
    expect(merged.length, 3);
    expect((merged.inverse() as DeleteOperation).length, 3);

    final replaced =
        ReplaceOperation(
              offset: 0,
              deletedText: '\u{1F600}',
              insertedText: 'ab',
              selectionBefore: caret,
              selectionAfter: caret,
            ).inverse()
            as ReplaceOperation;
    expect((replaced.deletedLength, replaced.insertedLength), (2, 1));
  });

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
