extension NumExtension on num {
  String fixed({digit = 2}) {
    return toStringAsFixed(truncateToDouble() == this ? 0 : digit);
  }
}
