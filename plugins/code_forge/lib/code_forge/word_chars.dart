// Sorted for isWordChar's early exit, and all in the BMP so one code unit decides.
const _wordRanges = [
  (0x30, 0x39),
  (0x41, 0x5A),
  (0x5F, 0x5F),
  (0x61, 0x7A),
  (0x0590, 0x05FF),
  (0x0600, 0x06FF),
  (0x08A0, 0x08FF),
  (0x3040, 0x309F),
  (0x30A0, 0x30FF),
  (0x3400, 0x4DBF),
  (0x4E00, 0x9FFF),
  (0xAC00, 0xD7AF),
  (0xF900, 0xFAFF),
];

bool isWordChar(int codeUnit) {
  for (final (from, to) in _wordRanges) {
    if (codeUnit < from) return false;
    if (codeUnit <= to) return true;
  }
  return false;
}

bool isWordStartChar(int codeUnit) =>
    isWordChar(codeUnit) && (codeUnit < 0x30 || codeUnit > 0x39);

String _hex(int codeUnit) => '\\u${codeUnit.toRadixString(16).padLeft(4, '0')}';

final String wordCharClass = [
  for (final (from, to) in _wordRanges) '${_hex(from)}-${_hex(to)}',
].join();
