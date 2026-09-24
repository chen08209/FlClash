part of '../controller.dart';

/// Offered while the typed word is a prefix of [prefix]. [body] takes the
/// stops `$1`, `${1:default}` and `$0`, without nesting or mirrors; a tab is one
/// indent level, and each later line gains the indentation of the first.
class CodeForgeSnippet {
  final String prefix;
  final String body;
  final String? description;

  const CodeForgeSnippet({
    required this.prefix,
    required this.body,
    this.description,
  });
}

extension CodeForgeControllerSnippet on CodeForgeController {
  bool get isSnippetActive => _snippetStops != null;

  /// Replaces the selection, or the word before a collapsed caret.
  void insertSnippet(CodeForgeSnippet snippet) {
    if (readOnly) return;
    _flushBuffer();
    final current = selection;
    final end = current.end;
    final start = current.isCollapsed
        ? end - getCurrentWordPrefixAt(end).runes.length
        : current.start;
    final lineText = getLineText(getLineAtOffset(start));
    final expanded = _SnippetExpansion(
      snippet.body,
      RegExp(r'^[ \t]*').stringMatch(lineText)!,
      tabSpace,
    );
    replaceRange(start, end, expanded.text);
    _isTyping = false;
    final stops = [
      for (final stop in expanded.stops)
        TextRange(start: start + stop.start, end: start + stop.end),
    ];
    _snippetStops = stops.length > 1 ? stops : null;
    _snippetStopIndex = 0;
    _selectSnippetStop(stops.first);
  }

  /// False, ending the snippet, once the selection has left the current stop.
  bool nextSnippetStop() => _moveSnippetStop(1);

  bool previousSnippetStop() => _moveSnippetStop(-1);

  void endSnippet() => _snippetStops = null;

  bool _moveSnippetStop(int step) {
    final stops = _snippetStops;
    if (stops == null) return false;
    final active = stops[_snippetStopIndex];
    if (selection.start < active.start || selection.end > active.end) {
      _snippetStops = null;
      return false;
    }
    _snippetStopIndex = (_snippetStopIndex + step).clamp(0, stops.length - 1);
    if (_snippetStopIndex == stops.length - 1) _snippetStops = null;
    _selectSnippetStop(stops[_snippetStopIndex]);
    return true;
  }

  void _selectSnippetStop(TextRange stop) {
    selection = TextSelection(baseOffset: stop.start, extentOffset: stop.end);
  }

  /// An edit outside the current stop ends the snippet.
  void _trackSnippetEdit(int offset, int removed, int added) {
    final stops = _snippetStops;
    if (stops == null) return;
    final active = stops[_snippetStopIndex];
    if (offset < active.start || offset + removed > active.end) {
      _snippetStops = null;
      return;
    }
    final delta = added - removed;
    _snippetStops = [
      for (var i = 0; i < stops.length; i++)
        if (i == _snippetStopIndex)
          TextRange(start: active.start, end: active.end + delta)
        else if (stops[i].start >= active.end)
          TextRange(start: stops[i].start + delta, end: stops[i].end + delta)
        else
          stops[i],
    ];
  }
}

/// [stops] are scalar offsets in Tab order, the last where Tab leaves.
class _SnippetExpansion {
  _SnippetExpansion(this._body, this._indent, this._indentUnit) {
    _emitUntil(0);
    final numbers = _stops.keys.where((number) => number > 0).toList()..sort();
    stops = [
      for (final number in numbers) _stops[number]!,
      _stops[0] ?? TextRange.collapsed(_length),
    ];
  }

  final String _body, _indent, _indentUnit;
  final _out = StringBuffer();
  final _stops = <int, TextRange>{};
  var _length = 0;
  late final List<TextRange> stops;

  String get text => _out.toString();

  void _write(String text) {
    _out.write(text);
    _length += text.runes.length;
  }

  int _emitUntil(int from, {String? closer}) {
    var i = from;
    while (i < _body.length) {
      final char = _body[i];
      if (char == closer) return i;
      final stopEnd = char == r'$' ? _stopAt(i) : null;
      if (stopEnd != null) {
        i = stopEnd;
      } else if (char == r'\' &&
          i + 1 < _body.length &&
          r'$}\'.contains(_body[i + 1])) {
        _write(_body[i + 1]);
        i += 2;
      } else if (char == '\n') {
        _write('\n$_indent');
        i++;
      } else if (char == '\t') {
        _write(_indentUnit);
        i++;
      } else {
        final pair = char.codeUnitAt(0) & 0xFC00 == 0xD800;
        _write(_body.substring(i, pair ? i + 2 : i + 1));
        i += pair ? 2 : 1;
      }
    }
    return i;
  }

  int? _stopAt(int dollar) {
    final braced = dollar + 1 < _body.length && _body[dollar + 1] == '{';
    final digits = RegExp(r'\d+')
        .matchAsPrefix(_body, dollar + (braced ? 2 : 1));
    if (digits == null) return null;
    final number = int.parse(digits[0]!);
    final start = _length;
    int? end;
    if (!braced) {
      end = digits.end;
    } else if (digits.end < _body.length && _body[digits.end] == '}') {
      end = digits.end + 1;
    } else if (digits.end < _body.length && _body[digits.end] == ':') {
      end = _emitUntil(digits.end + 1, closer: '}') + 1;
    }
    if (end != null) {
      _stops.putIfAbsent(number, () => TextRange(start: start, end: _length));
    }
    return end;
  }
}
