class Snowflake {
  static Snowflake? _instance;

  Snowflake._internal();

  factory Snowflake() {
    _instance ??= Snowflake._internal();
    return _instance!;
  }

  static const int twepoch = 1704067200000;

  static const int workerIdBits = 10;
  static const int sequenceBits = 12;

  static const int maxWorkerId = -1 ^ (-1 << workerIdBits);
  static const int sequenceMask = -1 ^ (-1 << sequenceBits);

  static const int workerIdShift = sequenceBits;
  static const int timestampLeftShift = sequenceBits + workerIdBits;

  final int workerId = 1;
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
      _sequence = (_sequence + 1) & sequenceMask;
      if (_sequence == 0) {
        timestamp = _getNextMillis(_lastTimestamp);
      }
    } else {
      _sequence = 0;
    }

    _lastTimestamp = timestamp;

    return ((timestamp - twepoch) << timestampLeftShift) |
        (workerId << workerIdShift) |
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
