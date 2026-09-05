import 'dart:typed_data';

import 'package:test/test.dart';

import '../../tool/src/icons/ico.dart';

Uint8List _png(int fill, int length) =>
    Uint8List.fromList(List.filled(length, fill));

int _u16(Uint8List bytes, int offset) =>
    bytes[offset] | (bytes[offset + 1] << 8);

int _u32(Uint8List bytes, int offset) =>
    _u16(bytes, offset) | (_u16(bytes, offset + 2) << 16);

void main() {
  test('writes one directory entry per size, sorted, with correct offsets', () {
    final ico = buildIco([
      IcoEntry(size: 256, png: _png(3, 7)),
      IcoEntry(size: 16, png: _png(1, 5)),
      IcoEntry(size: 32, png: _png(2, 6)),
    ]);

    expect(_u16(ico, 0), 0);
    expect(_u16(ico, 2), 1);
    expect(_u16(ico, 4), 3);

    const firstImage = 6 + 16 * 3;
    expect([ico[6], ico[7]], [16, 16]);
    expect(_u32(ico, 6 + 8), 5);
    expect(_u32(ico, 6 + 12), firstImage);
    expect([ico[22], ico[23]], [32, 32]);
    expect(_u32(ico, 22 + 12), firstImage + 5);
    expect([ico[38], ico[39]], [0, 0]);
    expect(_u32(ico, 38 + 12), firstImage + 11);
    expect(ico.sublist(firstImage, firstImage + 5), everyElement(1));
    expect(ico.sublist(firstImage + 11), everyElement(3));
  });

  test('rejects sizes outside the ICO range and empty input', () {
    expect(() => buildIco([]), throwsArgumentError);
    expect(
      () => buildIco([IcoEntry(size: 512, png: _png(0, 1))]),
      throwsArgumentError,
    );
  });

  test('tray sizes stop at the 2x small-icon ceiling', () {
    expect(trayIcoSizes.last, 64);
    expect(icoSizes, containsAll(trayIcoSizes));
    expect(icoSizes.last, 256);
  });
}
