import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';

import 'dart:math';

extension StringExtension on String {
  bool get isUrl {
    final uri = Uri.tryParse(this);
    return uri != null &&
        (uri.scheme == 'http' ||
            uri.scheme == 'https' ||
            uri.scheme == 'ftp') &&
        uri.host.isNotEmpty;
  }

  dynamic get splitByMultipleSeparators {
    final parts = split(
      RegExp(r'[, ;]+'),
    ).where((part) => part.isNotEmpty).toList();

    return parts.length > 1 ? parts : this;
  }

  int compareToLower(String other) {
    return toLowerCase().compareTo(other.toLowerCase());
  }

  String get countryFlagEmoji {
    final code = toUpperCase();
    if (!RegExp(r'^[A-Z]{2}$').hasMatch(code)) {
      return this;
    }
    const regionalIndicatorA = 0x1F1E6;
    return String.fromCharCodes([
      code.codeUnitAt(0) - 0x41 + regionalIndicatorA,
      code.codeUnitAt(1) - 0x41 + regionalIndicatorA,
    ]);
  }

  String safeSubstring(int start, [int? end]) {
    if (isEmpty) return '';
    final safeStart = start.clamp(0, length);
    if (end == null) {
      return substring(safeStart);
    }
    final safeEnd = end.clamp(safeStart, length);
    return substring(safeStart, safeEnd);
  }

  List<int> get encodeUtf16LeWithBom {
    final byteData = ByteData(length * 2);
    final bom = [0xFF, 0xFE];
    for (int i = 0; i < length; i++) {
      final int charCode = codeUnitAt(i);
      byteData.setUint16(i * 2, charCode, Endian.little);
    }
    return bom + byteData.buffer.asUint8List();
  }

  Uint8List? get getBase64 {
    final regExp = RegExp(r'base64,(.*)');
    final match = regExp.firstMatch(this);
    final realValue = match?.group(1) ?? '';
    if (realValue.isEmpty) {
      return null;
    }
    try {
      return base64.decode(realValue);
    } catch (e) {
      commonPrint.log(
        'invalid base64 data ${e.toString()}',
        logLevel: LogLevel.debug,
      );
      return null;
    }
  }

  bool get isSvg {
    return endsWith('.svg');
  }

  bool get isRegex {
    try {
      RegExp(this);
      return true;
    } catch (e) {
      commonPrint.log(e.toString());
      return false;
    }
  }

  String toMd5() {
    final bytes = utf8.encode(this);
    return md5.convert(bytes).toString();
  }

  Future<T> decodeJson<T>() async {
    const thresholdLimit = 51200;
    if (length < thresholdLimit) {
      return json.decode(this);
    } else {
      return decodeJSONTask<T>(this);
    }
  }

  String? get value {
    if (isEmpty) {
      return null;
    }
    return this;
  }

  String take(int maxLength) {
    return length <= maxLength ? this : substring(0, maxLength);
  }

  String get fileStem {
    final dot = lastIndexOf('.');
    return dot > 0 ? substring(0, dot) : this;
  }

  String get urlFileName {
    final segments = Uri.tryParse(this)?.pathSegments ?? const [];
    return segments.lastWhere(
      (segment) => segment.isNotEmpty,
      orElse: () => '',
    );
  }
}

final _labelCounter = RegExp(r'\((\d{1,9})\)$');

String uniqueLabelFor(
  String name, {
  required String fallback,
  required bool Function(String label) taken,
}) {
  const maxLength = TextInputLimits.name;
  final label = name.trim().takeFirstValid([fallback]).take(maxLength).trim();
  if (!taken(label)) {
    return label;
  }
  final counter = _labelCounter.firstMatch(label);
  final stem = counter == null ? label : label.substring(0, counter.start);
  for (var index = int.parse(counter?[1] ?? '0') + 1; ; index++) {
    final suffix = '($index)';
    final candidate = stem.take(maxLength - suffix.length) + suffix;
    if (!taken(candidate)) {
      return candidate;
    }
  }
}

extension StringNullExt on String? {
  String takeFirstValid(List<String?> others, {String defaultValue = ''}) {
    if (this != null && this!.trim().isNotEmpty) return this!.trim();

    for (final s in others) {
      if (s != null && s.trim().isNotEmpty) {
        return s.trim();
      }
    }
    return defaultValue;
  }
}

String generateRandomString({int minLength = 10, int maxLength = 100}) {
  const latinChars =
      'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  final random = Random();

  final int length = minLength + random.nextInt(maxLength - minLength + 1);

  String result = '';
  for (int i = 0; i < length; i++) {
    if (random.nextBool()) {
      result += String.fromCharCode(
        0x4E00 + random.nextInt(0x9FA5 - 0x4E00 + 1),
      );
    } else {
      result += latinChars[random.nextInt(latinChars.length)];
    }
  }

  return result;
}

String generateRandomSecret(int length) {
  const chars =
      'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  final random = Random.secure();
  return String.fromCharCodes(
    Iterable.generate(
      length,
      (_) => chars.codeUnitAt(random.nextInt(chars.length)),
    ),
  );
}
