import 'dart:io';
import 'dart:isolate';
import 'dart:math';
import 'dart:typed_data';

typedef _Range = ({BigInt start, BigInt end});

const _families = [32, 128];

/// The addresses of [include] that [exclude] leaves, as the fewest CIDR
/// blocks that cover them, IPv4 first. With [wholeWhenEmpty], a family
/// [include] names no block of counts as its whole address space. Entries that
/// do not parse are ignored.
List<String> subtractCidrs(
  Iterable<String> include,
  Iterable<String> exclude, {
  bool wholeWhenEmpty = false,
}) {
  final included = _parseAll(include);
  final excluded = _parseAll(exclude);
  return [
    for (final bits in _families)
      for (final range in _subtract(
        _merge(
          included[bits] ??
              [
                if (wholeWhenEmpty)
                  (start: BigInt.zero, end: (BigInt.one << bits) - BigInt.one),
              ],
        ),
        _merge(excluded[bits] ?? []),
      ))
        ..._toCidrs(bits, range),
  ];
}

Future<List<String>> subtractCidrsTask(
  List<String> include,
  List<String> exclude, {
  bool wholeWhenEmpty = false,
}) {
  return Isolate.run(
    () => subtractCidrs(include, exclude, wholeWhenEmpty: wholeWhenEmpty),
  );
}

final _decimal = RegExp(r'^(0|[1-9][0-9]{0,2})$');

/// As strict as Go's netip.ParsePrefix, since the core fails a whole config or
/// update on one CIDR that parser refuses.
bool isCidr(String value) {
  final slash = value.lastIndexOf('/');
  if (slash < 0) {
    return false;
  }
  final address = value.substring(0, slash);
  final prefix = value.substring(slash + 1);
  if (!_decimal.hasMatch(prefix) || address.contains('%')) {
    return false;
  }
  final int bits;
  if (address.contains(':')) {
    final parsed = InternetAddress.tryParse(address);
    if (parsed?.type != InternetAddressType.IPv6 || address.trim() != address) {
      return false;
    }
    bits = 128;
  } else {
    final octets = address.split('.');
    if (octets.length != 4 ||
        octets.any(
          (octet) => !_decimal.hasMatch(octet) || int.parse(octet) > 255,
        )) {
      return false;
    }
    bits = 32;
  }
  return int.parse(prefix) <= bits;
}

Map<int, List<_Range>> _parseAll(Iterable<String> cidrs) {
  final ranges = <int, List<_Range>>{};
  for (final cidr in cidrs) {
    final parsed = _parse(cidr);
    if (parsed != null) {
      ranges.putIfAbsent(parsed.bits, () => []).add(parsed.range);
    }
  }
  return ranges;
}

({int bits, _Range range})? _parse(String cidr) {
  final slash = cidr.indexOf('/');
  if (slash < 0) {
    return null;
  }
  final address = InternetAddress.tryParse(cidr.substring(0, slash).trim());
  final prefix = int.tryParse(cidr.substring(slash + 1).trim());
  if (address == null || prefix == null) {
    return null;
  }
  final raw = address.rawAddress;
  final bits = raw.length * 8;
  if (prefix < 0 || prefix > bits) {
    return null;
  }
  var value = BigInt.zero;
  for (final byte in raw) {
    value = (value << 8) | BigInt.from(byte);
  }
  final size = BigInt.one << (bits - prefix);
  final start = value ~/ size * size;
  return (bits: bits, range: (start: start, end: start + size - BigInt.one));
}

List<_Range> _merge(List<_Range> ranges) {
  final sorted = [...ranges]..sort((a, b) => a.start.compareTo(b.start));
  final merged = <_Range>[];
  for (final range in sorted) {
    if (merged.isNotEmpty && range.start <= merged.last.end + BigInt.one) {
      final last = merged.removeLast();
      merged.add((
        start: last.start,
        end: range.end > last.end ? range.end : last.end,
      ));
    } else {
      merged.add(range);
    }
  }
  return merged;
}

List<_Range> _subtract(List<_Range> included, List<_Range> excluded) {
  final result = <_Range>[];
  var next = 0;
  for (final range in included) {
    while (next < excluded.length && excluded[next].end < range.start) {
      next++;
    }
    var cursor = range.start;
    for (var index = next; index < excluded.length; index++) {
      final cut = excluded[index];
      if (cut.start > range.end) {
        break;
      }
      if (cut.start > cursor) {
        result.add((start: cursor, end: cut.start - BigInt.one));
      }
      cursor = cut.end + BigInt.one;
      if (cursor > range.end) {
        break;
      }
    }
    if (cursor <= range.end) {
      result.add((start: cursor, end: range.end));
    }
  }
  return result;
}

Iterable<String> _toCidrs(int bits, _Range range) sync* {
  var start = range.start;
  while (start <= range.end) {
    final aligned = start == BigInt.zero
        ? bits
        : (start & -start).bitLength - 1;
    final fits = (range.end - start + BigInt.one).bitLength - 1;
    final host = min(aligned, fits);
    yield '${_format(bits, start)}/${bits - host}';
    start += BigInt.one << host;
  }
}

String _format(int bits, BigInt value) {
  if (bits == 32) {
    final address = value.toInt();
    return '${address >> 24}.${(address >> 16) & 0xFF}.'
        '${(address >> 8) & 0xFF}.${address & 0xFF}';
  }
  final bytes = Uint8List(bits ~/ 8);
  for (var index = bytes.length - 1; index >= 0; index--) {
    bytes[index] = (value & BigInt.from(0xFF)).toInt();
    value >>= 8;
  }
  return InternetAddress.fromRawAddress(bytes).address;
}
