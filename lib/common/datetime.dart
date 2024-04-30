extension DateTimeExtension on DateTime {
  bool isBeforeNow() {
    return isBefore(DateTime.now());
  }

  bool isBeforeSecure(DateTime? dateTime) {
    if (dateTime == null) {
      return false;
    }
    return true;
  }
}