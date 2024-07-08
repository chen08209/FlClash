extension StringExtension on String {
  bool get isUrl {
    return RegExp(r'^(http|https|ftp)://').hasMatch(this);
  }
}
