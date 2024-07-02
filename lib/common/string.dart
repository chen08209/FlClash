extension StringExtension on String {
  bool get isUrl {
    return RegExp(
      r"^(http(s)?://)?(www\.)?[a-zA-Z0-9]+([\-.][a-zA-Z0-9]+)*\.[a-zA-Z]{2,5}(:[0-9]{1,5})?(/.*)?$",
      caseSensitive: false,
      multiLine: false,
    ).hasMatch(this);
  }
}
