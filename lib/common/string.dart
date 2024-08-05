extension StringExtension on String {
  bool get isUrl {
    return RegExp(r'^(http|https|ftp)://').hasMatch(this);
  }

  int compareToLower(String other) {
    return toLowerCase().compareTo(
      other.toLowerCase(),
    );
  }
}
