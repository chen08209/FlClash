/// Removes the rsFeature checks from Dart source as the rs line takes them.
/// The forms it reads are listed under rsFeature in `.agents/rules.md`; any
/// other use throws a [StripException].
library;

import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';

const flagName = 'rsFeature';

class StripException implements Exception {
  const StripException(this.path, this.line, this.message);

  final String path;
  final int line;
  final String message;

  @override
  String toString() => '$path:$line: $message';
}

bool mentionsFlag(String source) => RegExp('\\b$flagName\\b').hasMatch(source);

String stripRsFeature(String source, {String path = '<source>'}) {
  var result = source;
  while (true) {
    final edits = _editsOf(result, path);
    if (edits.isEmpty) {
      return result;
    }
    final outermost = <_Edit>[];
    for (final edit in edits..sort((a, b) => a.offset.compareTo(b.offset))) {
      if (outermost.isEmpty || edit.offset >= outermost.last.end) {
        outermost.add(edit);
      }
    }
    for (final edit in outermost.reversed) {
      result = result.replaceRange(edit.offset, edit.end, edit.replacement);
    }
  }
}

class _Edit {
  const _Edit(this.offset, this.end, this.replacement);

  final int offset;
  final int end;
  final String replacement;
}

List<_Edit> _editsOf(String source, String path) {
  final unit = parseString(
    content: source,
    featureSet: FeatureSet.latestLanguageVersion(),
    path: path,
    throwIfDiagnostics: false,
  ).unit;
  final references = <SimpleIdentifier>[];
  unit.accept(_References(references));
  return [
    for (final reference in references)
      _editOf(reference, source, (node) {
        final line = unit.lineInfo.getLocation(node.offset).lineNumber;
        return StripException(path, line, '$flagName in an unsupported form');
      }),
  ];
}

class _References extends RecursiveAstVisitor<void> {
  _References(this.references);

  final List<SimpleIdentifier> references;

  @override
  void visitSimpleIdentifier(SimpleIdentifier node) {
    if (node.name == flagName) {
      references.add(node);
    }
  }
}

_Edit _editOf(
  SimpleIdentifier reference,
  String source,
  StripException Function(AstNode) fail,
) {
  final parent = reference.parent;
  String text(AstNode node) => source.substring(node.offset, node.end);
  switch (parent) {
    case IfElement(
          expression: final condition,
          caseClause: null,
          :final thenElement,
          elseElement: null,
        )
        when identical(condition, reference):
      return _Edit(parent.offset, parent.end, text(thenElement));
    case BinaryExpression(
          :final leftOperand,
          :final operator,
          :final rightOperand,
        )
        when identical(leftOperand, reference) &&
            operator.type == TokenType.AMPERSAND_AMPERSAND:
      final enclosing = parent.parent;
      if (enclosing is ParenthesizedExpression && _bindsTightly(rightOperand)) {
        return _Edit(enclosing.offset, enclosing.end, text(rightOperand));
      }
      return _Edit(parent.offset, parent.end, text(rightOperand));
    case IfStatement(
          expression: final condition,
          caseClause: null,
          :final thenStatement,
          elseStatement: null,
        )
        when identical(condition, reference):
      final kept = thenStatement is Block
          ? source
                .substring(
                  thenStatement.leftBracket.end,
                  thenStatement.rightBracket.offset,
                )
                .trim()
          : text(thenStatement);
      return _Edit(parent.offset, parent.end, kept);
  }
  throw fail(reference);
}

bool _bindsTightly(Expression expression) => switch (expression) {
  Identifier() ||
  PropertyAccess() ||
  MethodInvocation() ||
  FunctionExpressionInvocation() ||
  IndexExpression() ||
  ParenthesizedExpression() ||
  Literal() => true,
  _ => false,
};
