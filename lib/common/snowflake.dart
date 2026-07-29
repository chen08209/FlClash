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

  static DateTime? dateTimeFromId(int id) {
    final timestampPart = id >> _timestampLeftShift;
    if (timestampPart <= 0) return null;
    return DateTime.fromMillisecondsSinceEpoch(timestampPart + _twepoch);
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
