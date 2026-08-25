// fork dart-sdk/lib/_http/crypto.dart

// Constants.
import 'dart:math';

const _MASK_8 = 0xff;
const _MASK_32 = 0xffffffff;
const _BITS_PER_BYTE = 8;
const _BYTES_PER_WORD = 4;

abstract class _HashBase {
  // Hasher state.
  final int _chunkSizeInWords;
  final bool _bigEndianWords;
  int _lengthInBytes = 0;
  List<int> _pendingData;
  List<int> _currentChunk;
  List<int> _h;
  bool _digestCalled = false;

  _HashBase(this._chunkSizeInWords, int digestSizeInWords, this._bigEndianWords)
      : _pendingData = [],
        _currentChunk = List.filled(_chunkSizeInWords, 0),
        _h = List.filled(digestSizeInWords, 0);

  // Update the hasher with more data.
  add(List<int> data) {
    if (_digestCalled) {
      throw new StateError(
          'Hash update method called after digest was retrieved');
    }
    _lengthInBytes += data.length;
    _pendingData.addAll(data);
    _iterate();
  }

  // Finish the hash computation and return the digest string.
  List<int> close() {
    if (_digestCalled) {
      return _resultAsBytes();
    }
    _digestCalled = true;
    _finalizeData();
    _iterate();
    assert(_pendingData.length == 0);
    return _resultAsBytes();
  }

  // Returns the block size of the hash in bytes.
  int get blockSize {
    return _chunkSizeInWords * _BYTES_PER_WORD;
  }

  // Create a fresh instance of this Hash.
  newInstance();

  // One round of the hash computation.
  _updateHash(List<int> m);

  // Helper methods.
  _add32(x, y) => (x + y) & _MASK_32;
  _roundUp(val, n) => (val + n - 1) & -n;

  // Rotate left limiting to unsigned 32-bit values.
  int _rotl32(int val, int shift) {
    var mod_shift = shift & 31;
    return ((val << mod_shift) & _MASK_32) |
        ((val & _MASK_32) >> (32 - mod_shift));
  }

  // Compute the final result as a list of bytes from the hash words.
  List<int> _resultAsBytes() {
    var result = <int>[];
    for (var i = 0; i < _h.length; i++) {
      result.addAll(_wordToBytes(_h[i]));
    }
    return result;
  }

  // Converts a list of bytes to a chunk of 32-bit words.
  _bytesToChunk(List<int> data, int dataIndex) {
    assert((data.length - dataIndex) >= (_chunkSizeInWords * _BYTES_PER_WORD));

    for (var wordIndex = 0; wordIndex < _chunkSizeInWords; wordIndex++) {
      var w3 = _bigEndianWords ? data[dataIndex] : data[dataIndex + 3];
      var w2 = _bigEndianWords ? data[dataIndex + 1] : data[dataIndex + 2];
      var w1 = _bigEndianWords ? data[dataIndex + 2] : data[dataIndex + 1];
      var w0 = _bigEndianWords ? data[dataIndex + 3] : data[dataIndex];
      dataIndex += 4;
      var word = (w3 & 0xff) << 24;
      word |= (w2 & _MASK_8) << 16;
      word |= (w1 & _MASK_8) << 8;
      word |= (w0 & _MASK_8);
      _currentChunk[wordIndex] = word;
    }
  }

  // Convert a 32-bit word to four bytes.
  List<int> _wordToBytes(int word) {
    List<int> bytes = new List.filled(_BYTES_PER_WORD, 0);
    bytes[0] = (word >> (_bigEndianWords ? 24 : 0)) & _MASK_8;
    bytes[1] = (word >> (_bigEndianWords ? 16 : 8)) & _MASK_8;
    bytes[2] = (word >> (_bigEndianWords ? 8 : 16)) & _MASK_8;
    bytes[3] = (word >> (_bigEndianWords ? 0 : 24)) & _MASK_8;
    return bytes;
  }

  // Iterate through data updating the hash computation for each
  // chunk.
  _iterate() {
    var len = _pendingData.length;
    var chunkSizeInBytes = _chunkSizeInWords * _BYTES_PER_WORD;
    if (len >= chunkSizeInBytes) {
      var index = 0;
      for (; (len - index) >= chunkSizeInBytes; index += chunkSizeInBytes) {
        _bytesToChunk(_pendingData, index);
        _updateHash(_currentChunk);
      }
      _pendingData = _pendingData.sublist(index, len);
    }
  }

  // Finalize the data. Add a 1 bit to the end of the message. Expand with
  // 0 bits and add the length of the message.
  _finalizeData() {
    _pendingData.add(0x80);
    var contentsLength = _lengthInBytes + 9;
    var chunkSizeInBytes = _chunkSizeInWords * _BYTES_PER_WORD;
    var finalizedLength = _roundUp(contentsLength, chunkSizeInBytes);
    var zeroPadding = finalizedLength - contentsLength;
    for (var i = 0; i < zeroPadding; i++) {
      _pendingData.add(0);
    }
    var lengthInBits = _lengthInBytes * _BITS_PER_BYTE;
    assert(lengthInBits < pow(2, 32));
    if (_bigEndianWords) {
      _pendingData.addAll(_wordToBytes(0));
      _pendingData.addAll(_wordToBytes(lengthInBits & _MASK_32));
    } else {
      _pendingData.addAll(_wordToBytes(lengthInBits & _MASK_32));
      _pendingData.addAll(_wordToBytes(0));
    }
  }
}

// The MD5 hasher is used to compute an MD5 message digest.
class MD5 extends _HashBase {
  MD5() : super(16, 4, false) {
    _h[0] = 0x67452301;
    _h[1] = 0xefcdab89;
    _h[2] = 0x98badcfe;
    _h[3] = 0x10325476;
  }

  // Returns a new instance of this Hash.
  MD5 newInstance() {
    return new MD5();
  }

  static const _k = const [
    0xd76aa478, 0xe8c7b756, 0x242070db, 0xc1bdceee, 0xf57c0faf, 0x4787c62a, //
    0xa8304613, 0xfd469501, 0x698098d8, 0x8b44f7af, 0xffff5bb1, 0x895cd7be, //
    0x6b901122, 0xfd987193, 0xa679438e, 0x49b40821, 0xf61e2562, 0xc040b340, //
    0x265e5a51, 0xe9b6c7aa, 0xd62f105d, 0x02441453, 0xd8a1e681, 0xe7d3fbc8, //
    0x21e1cde6, 0xc33707d6, 0xf4d50d87, 0x455a14ed, 0xa9e3e905, 0xfcefa3f8, //
    0x676f02d9, 0x8d2a4c8a, 0xfffa3942, 0x8771f681, 0x6d9d6122, 0xfde5380c, //
    0xa4beea44, 0x4bdecfa9, 0xf6bb4b60, 0xbebfbc70, 0x289b7ec6, 0xeaa127fa, //
    0xd4ef3085, 0x04881d05, 0xd9d4d039, 0xe6db99e5, 0x1fa27cf8, 0xc4ac5665, //
    0xf4292244, 0x432aff97, 0xab9423a7, 0xfc93a039, 0x655b59c3, 0x8f0ccc92, //
    0xffeff47d, 0x85845dd1, 0x6fa87e4f, 0xfe2ce6e0, 0xa3014314, 0x4e0811a1, //
    0xf7537e82, 0xbd3af235, 0x2ad7d2bb, 0xeb86d391
  ];

  static const _r = const [
    7, 12, 17, 22, 7, 12, 17, 22, 7, 12, 17, 22, 7, 12, 17, 22, 5, 9, 14, //
    20, 5, 9, 14, 20, 5, 9, 14, 20, 5, 9, 14, 20, 4, 11, 16, 23, 4, 11, //
    16, 23, 4, 11, 16, 23, 4, 11, 16, 23, 6, 10, 15, 21, 6, 10, 15, 21, 6, //
    10, 15, 21, 6, 10, 15, 21
  ];

  // Compute one iteration of the MD5 algorithm with a chunk of
  // 16 32-bit pieces.
  void _updateHash(List<int> m) {
    assert(m.length == 16);

    var a = _h[0];
    var b = _h[1];
    var c = _h[2];
    var d = _h[3];

    var t0;
    var t1;

    for (var i = 0; i < 64; i++) {
      if (i < 16) {
        t0 = (b & c) | ((~b & _MASK_32) & d);
        t1 = i;
      } else if (i < 32) {
        t0 = (d & b) | ((~d & _MASK_32) & c);
        t1 = ((5 * i) + 1) % 16;
      } else if (i < 48) {
        t0 = b ^ c ^ d;
        t1 = ((3 * i) + 5) % 16;
      } else {
        t0 = c ^ (b | (~d & _MASK_32));
        t1 = (7 * i) % 16;
      }

      var temp = d;
      d = c;
      c = b;
      b = _add32(
          b, _rotl32(_add32(_add32(a, t0), _add32(_k[i], m[t1])), _r[i]));
      a = temp;
    }

    _h[0] = _add32(a, _h[0]);
    _h[1] = _add32(b, _h[1]);
    _h[2] = _add32(c, _h[2]);
    _h[3] = _add32(d, _h[3]);
  }
}
