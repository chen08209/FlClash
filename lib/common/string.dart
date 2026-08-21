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

String getOverwriteLabel(String label) {
  final reg = RegExp(r'\((\d+)\)$');
  final matches = reg.allMatches(label);
  if (matches.isNotEmpty) {
    final match = matches.last;
    final number = int.parse(match[1] ?? '0') + 1;
    return label.replaceFirst(reg, '($number)', label.length - 3 - 1);
  } else {
    return '$label(1)';
  }
}
