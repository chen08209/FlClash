import 'dart:typed_data';

final class IcoEntry {
  const IcoEntry({required this.size, required this.png});

  final int size;
  final Uint8List png;
}

const _headerSize = 6;
const _directoryEntrySize = 16;

/// Every size the Windows shell requests, so no glyph is resampled from a far neighbour.
const icoSizes = [16, 20, 24, 32, 40, 48, 64, 96, 128, 256];

/// The tray only ever asks for `SM_CXSMICON` (16..32) plus a 2x headroom.
const trayIcoSizes = [16, 20, 24, 32, 40, 48, 64];

Uint8List buildIco(List<IcoEntry> entries) {
  if (entries.isEmpty) {
    throw ArgumentError.value(entries, 'entries', 'must not be empty');
  }
  final sorted = [...entries]..sort((a, b) => a.size.compareTo(b.size));
  final directory = BytesBuilder(copy: false)
    ..add(_uint16(0))
    ..add(_uint16(1))
    ..add(_uint16(sorted.length));
  final images = BytesBuilder(copy: false);
  var offset = _headerSize + _directoryEntrySize * sorted.length;
  for (final entry in sorted) {
    if (entry.size < 1 || entry.size > 256) {
      throw ArgumentError.value(entry.size, 'size', 'must be 1..256');
    }
    final dimension = entry.size == 256 ? 0 : entry.size;
    directory
      ..add([dimension, dimension, 0, 0])
      ..add(_uint16(1))
      ..add(_uint16(32))
      ..add(_uint32(entry.png.length))
      ..add(_uint32(offset));
    images.add(entry.png);
    offset += entry.png.length;
  }
  return Uint8List.fromList([...directory.toBytes(), ...images.toBytes()]);
}

Uint8List _uint16(int value) {
  return (ByteData(2)..setUint16(0, value, Endian.little)).buffer.asUint8List();
}

Uint8List _uint32(int value) {
  return (ByteData(4)..setUint32(0, value, Endian.little)).buffer.asUint8List();
}
