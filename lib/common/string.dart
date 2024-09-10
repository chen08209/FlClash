extension StringExtension on String {
  bool get isUrl {
    return RegExp(r'^(http|https|ftp)://').hasMatch(this);
  }

  int compareToLower(String other) {
    return toLowerCase().compareTo(
      other.toLowerCase(),
    );
  }

  bool isValidFileName() {
    if (trim().isEmpty) {
      return false;
    }

    if (length > 255) {
      return false;
    }

    final invalidChars = RegExp(r'[<>:"/\\|?*\x00-\x1F]');
    if (invalidChars.hasMatch(this)) {
      return false;
    }

    if (startsWith('.') || endsWith('.')) {
      return false;
    }

    // Windows reserved names
    final reservedNames = [
      'CON', 'PRN', 'AUX', 'NUL',
      'COM1', 'COM2', 'COM3', 'COM4', 'COM5', 'COM6', 'COM7', 'COM8', 'COM9',
      'LPT1', 'LPT2', 'LPT3', 'LPT4', 'LPT5', 'LPT6', 'LPT7', 'LPT8', 'LPT9'
    ];
    if (reservedNames.contains(toUpperCase())) {
      return false;
    }

    return true;
  }
}
