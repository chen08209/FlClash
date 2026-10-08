import 'dart:convert';
import 'dart:typed_data';

import 'package:fl_clash/enum/enum.dart';

import 'print.dart';

T decodeOrRestoreDefault<T>(
  String label,
  T Function() decode,
  T Function() restoreDefault,
) {
  try {
    return decode();
  } catch (error) {
    _logDiscarded(
      'Discarded damaged $label and restored defaults: ${compactError(error)}',
    );
    return restoreDefault();
  }
}

/// Decodes [json], or on failure keeps each value [decode] still accepts, so a
/// value this version cannot read falls back to its own default instead of
/// discarding its whole section.
T decodeSalvaging<T>(
  String label,
  Map<String, Object?> json,
  T Function(Map<String, Object?> json) decode,
) {
  try {
    return decode(json);
  } catch (error) {
    bool accepts(Object? candidate) {
      try {
        decode(candidate as Map<String, Object?>);
        return true;
      } catch (_) {
        return false;
      }
    }

    final dropped = <String>[];
    final salvaged = _probing(
      () => _salvageEntries(json, accepts, dropped, ''),
    );
    _logDiscarded(
      'Discarded damaged $label values ${dropped.join(', ')}: '
      '${compactError(error)}',
    );
    return _probing(() => decode(salvaged));
  }
}

typedef _Accepts = bool Function(Object? candidate);

const _dropped = Object();

// Salvaging decodes once per value, and a nested repair would log on each.
var _probeDepth = 0;

R _probing<R>(R Function() run) {
  _probeDepth++;
  try {
    return run();
  } finally {
    _probeDepth--;
  }
}

void _logDiscarded(String message) {
  if (_probeDepth > 0) {
    return;
  }
  commonPrint.log(message, logLevel: LogLevel.warning);
}

Object? _salvage(
  Object? value,
  _Accepts accepts,
  List<String> dropped,
  String path,
) {
  if (accepts(value)) {
    return value;
  }
  final nestedDropped = <String>[];
  final salvaged = switch (value) {
    Map<String, Object?>() => _salvageEntries(
      value,
      accepts,
      nestedDropped,
      path,
    ),
    List<Object?>() => _salvageItems(value, accepts, nestedDropped, path),
    _ => null,
  };
  // Left empty, a list would read as one the user cleared; its default is
  // the closer guess.
  if (salvaged case Map(isNotEmpty: true) || List(isNotEmpty: true)
      when accepts(salvaged)) {
    dropped.addAll(nestedDropped);
    return salvaged;
  }
  dropped.add(path);
  return _dropped;
}

Map<String, Object?> _salvageEntries(
  Map<String, Object?> json,
  _Accepts accepts,
  List<String> dropped,
  String path,
) {
  final kept = <String, Object?>{};
  for (final MapEntry(:key, :value) in json.entries) {
    final salvaged = _salvage(
      value,
      (candidate) => accepts({...kept, key: candidate}),
      dropped,
      path.isEmpty ? key : '$path.$key',
    );
    if (!identical(salvaged, _dropped)) {
      kept[key] = salvaged;
    }
  }
  return kept;
}

List<Object?> _salvageItems(
  List<Object?> items,
  _Accepts accepts,
  List<String> dropped,
  String path,
) {
  final kept = <Object?>[];
  for (final (index, item) in items.indexed) {
    final salvaged = _salvage(
      item,
      (candidate) => accepts([...kept, candidate]),
      dropped,
      '$path[$index]',
    );
    if (!identical(salvaged, _dropped)) {
      kept.add(salvaged);
    }
  }
  return kept;
}

class Uint8ListToListIntConverter extends Converter<Uint8List, List<int>> {
  @override
  List<int> convert(Uint8List input) {
    return input.toList();
  }

  @override
  Sink<Uint8List> startChunkedConversion(Sink<List<int>> sink) {
    return _Uint8ListToListIntConverterSink(sink);
  }
}

class _Uint8ListToListIntConverterSink implements Sink<Uint8List> {
  const _Uint8ListToListIntConverterSink(this._target);

  final Sink<List<int>> _target;

  @override
  void add(Uint8List data) {
    _target.add(data.toList());
  }

  @override
  void close() {
    _target.close();
  }
}

final uint8ListToListIntConverter = Uint8ListToListIntConverter();
