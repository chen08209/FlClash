import 'dart:math';

class Snowflake {
  static Snowflake? _instance;

  Snowflake._internal();

  factory Snowflake() {
    _instance ??= Snowflake._internal();
    return _instance!;
  }

  static const int _twepoch = 1704067200000;

  static const int _workerIdBits = 10;
  static const int _sequenceBits = 12;

  static const int _sequenceMask = -1 ^ (-1 << _sequenceBits);

  static const int _workerIdShift = _sequenceBits;
  static const int _timestampLeftShift = _sequenceBits + _workerIdBits;

  static int buildId(int? id) {
    if (id != null) {
      return id;
    }
    return snowflake.id;
  }

  final int _workerId = 1;
  int _lastTimestamp = -1;
  int _sequence = 0;

  int get id {
    int timestamp = DateTime.now().millisecondsSinceEpoch;
    if (timestamp < _lastTimestamp) {
      throw ArgumentError(
        'Clock moved backwards. Refusing to generate id for ${_lastTimestamp - timestamp} milliseconds',
      );
    }
    if (timestamp == _lastTimestamp) {
      _sequence = (_sequence + 1) & _sequenceMask;
      if (_sequence == 0) {
        timestamp = _getNextMillis(_lastTimestamp);
      }
    } else {
      _sequence = 0;
    }

    _lastTimestamp = timestamp;

    return ((timestamp - _twepoch) << _timestampLeftShift) |
        (_workerId << _workerIdShift) |
        _sequence;
  }

  int _getNextMillis(int lastTimestamp) {
    int timestamp = DateTime.now().millisecondsSinceEpoch;
    while (timestamp <= lastTimestamp) {
      timestamp = DateTime.now().millisecondsSinceEpoch;
    }
    return timestamp;
  }
}

final snowflake = Snowflake();

String get uniqueId {
  final timestamp = DateTime.now().microsecondsSinceEpoch;
  final random = Random();
  final randomStr = String.fromCharCodes(
    List.generate(8, (_) => random.nextInt(26) + 97),
  );
  return '$timestamp$randomStr';
}

String get uuidV4 {
  final Random random = Random();
  final bytes = List.generate(16, (_) => random.nextInt(256));

  bytes[6] = (bytes[6] & 0x0F) | 0x40;
  bytes[8] = (bytes[8] & 0x3F) | 0x80;

  final hex = bytes
      .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
      .join();

  return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20, 32)}';
}
