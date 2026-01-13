import 'dart:math';

class Indexing {
  static const String digits =
      '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';

  static const String integerZero = 'a0';
  static const String smallestInteger = 'A00000000000000000000000000';

  static Indexing? _instance;

  Indexing._internal();

  factory Indexing() {
    _instance ??= Indexing._internal();
    return _instance!;
  }

  int _getIntegerLength(String head) {
    if (head.compareTo('a') >= 0 && head.compareTo('z') <= 0) {
      return head.codeUnitAt(0) - 'a'.codeUnitAt(0) + 2;
    } else if (head.compareTo('A') >= 0 && head.compareTo('Z') <= 0) {
      return 'Z'.codeUnitAt(0) - head.codeUnitAt(0) + 2;
    } else {
      throw Exception('Invalid order key head: $head');
    }
  }

  bool _validateInteger(String integer) {
    if (integer.length != _getIntegerLength(integer[0])) {
      throw Exception('Invalid integer part of order key: $integer');
    }
    return true;
  }

  String? _incrementInteger(String x) {
    _validateInteger(x);
    String head = x[0];
    List<String> digs = x.substring(1).split('');

    bool carry = true;

    for (int i = digs.length - 1; carry && i >= 0; i--) {
      int d = digits.indexOf(digs[i]) + 1;
      if (d == digits.length) {
        digs[i] = '0';
      } else {
        digs[i] = digits[d];
        carry = false;
      }
    }

    if (carry) {
      if (head == 'Z') {
        return 'a0';
      }
      if (head == 'z') {
        return null;
      }
      String h = String.fromCharCode(head.codeUnitAt(0) + 1);
      if (h.compareTo('a') > 0) {
        digs.add('0');
      } else {
        digs.removeLast();
      }
      return h + digs.join('');
    } else {
      return head + digs.join('');
    }
  }

  String? _decrementInteger(String x) {
    _validateInteger(x);
    String head = x[0];
    List<String> digs = x.substring(1).split('');

    bool borrow = true;

    for (int i = digs.length - 1; borrow && i >= 0; i--) {
      int d = digits.indexOf(digs[i]) - 1;
      if (d == -1) {
        digs[i] = digits[digits.length - 1];
      } else {
        digs[i] = digits[d];
        borrow = false;
      }
    }

    if (borrow) {
      if (head == 'a') {
        return 'Z${digits[digits.length - 1]}';
      }
      if (head == 'A') {
        return null;
      }
      String h = String.fromCharCode(head.codeUnitAt(0) - 1);
      if (h.compareTo('Z') < 0) {
        digs.add(digits[digits.length - 1]);
      } else {
        digs.removeLast();
      }
      return h + digs.join('');
    } else {
      return head + digs.join('');
    }
  }

  String _midpoint(String a, String? b) {
    if (b != null && a.compareTo(b) >= 0) {
      throw Exception(
        'Second order key must be greater than the first: $a, $b',
      );
    }

    if (a.isNotEmpty && a[a.length - 1] == '0' ||
        (b != null && b.isNotEmpty && b[b.length - 1] == '0')) {
      throw Exception('Trailing zeros are not allowed: $a, $b');
    }

    if (b != null) {
      int n = 0;
      while ((n < a.length ? a[n] : '0') == b[n]) {
        n++;
      }

      if (n > 0) {
        return b.substring(0, n) +
            _midpoint(
              a.substring(min(n, a.length)),
              b.substring(min(n, b.length)),
            );
      }
    }

    int digitA = (a.isNotEmpty) ? digits.indexOf(a[0]) : 0;
    int digitB = (b != null && b.isNotEmpty)
        ? digits.indexOf(b[0])
        : digits.length;

    if (digitB - digitA > 1) {
      int midDigit = (digitA + digitB + 1) ~/ 2;
      return digits[midDigit];
    } else {
      if (b != null && b.length > 1) {
        return b.substring(0, 1);
      } else {
        return digits[digitA] +
            _midpoint(a.isNotEmpty ? a.substring(1) : '', null);
      }
    }
  }

  String _getIntegerPart(String key) {
    int integerPartLength = _getIntegerLength(key[0]);
    if (integerPartLength > key.length) {
      throw Exception('Invalid order key: $key');
    }
    return key.substring(0, integerPartLength);
  }

  bool _validateOrderKey(String key) {
    if (key == smallestInteger) {
      throw Exception('Invalid order key: $key');
    }

    String i = _getIntegerPart(key);
    String f = key.substring(i.length);
    if (f.isNotEmpty && f[f.length - 1] == '0') {
      throw Exception('Invalid order key: $key');
    }
    return true;
  }

  String? generateKeyBetween(String? a, String? b) {
    if (a != null) {
      _validateOrderKey(a);
    }

    if (b != null) {
      _validateOrderKey(b);
    }

    if (a != null && b != null && a.compareTo(b) >= 0) {
      throw Exception(
        'Second order key must be greater than the first: $a, $b',
      );
    }

    if (a == null && b == null) {
      return integerZero;
    }

    if (a == null) {
      b = b!;
      String ib = _getIntegerPart(b);
      String fb = b.substring(ib.length);
      if (ib == smallestInteger) {
        return ib + _midpoint('', fb);
      }
      return ib.compareTo(b) < 0 ? ib : _decrementInteger(ib);
    }

    if (b == null) {
      String ia = _getIntegerPart(a);
      String fa = a.substring(ia.length);
      String? i = _incrementInteger(ia);
      return i ?? ia + _midpoint(fa, null);
    }

    String ia = _getIntegerPart(a);
    String fa = a.substring(ia.length);
    String ib = _getIntegerPart(b);
    String fb = b.substring(ib.length);

    if (ia == ib) {
      return ia + _midpoint(fa, fb);
    }

    String? i = _incrementInteger(ia);
    return (i == null || i.compareTo(b) < 0) ? i : ia + _midpoint(fa, null);
  }

  List<String?> generateNKeysBetween(String? a, String? b, int n) {
    if (n <= 0) {
      return [];
    }
    if (n == 1) {
      return [generateKeyBetween(a, b)];
    }

    if (b == null) {
      String? c = generateKeyBetween(a, b);
      List<String?> result = [c];
      for (int i = 1; i < n; i++) {
        c = generateKeyBetween(c, b);
        result.add(c);
      }
      return result;
    }

    if (a == null) {
      String? c = generateKeyBetween(a, b);
      List<String?> result = [c];
      for (int i = 1; i < n; i++) {
        c = generateKeyBetween(a, c);
        result.add(c);
      }
      return result.reversed.toList();
    }

    int mid = n ~/ 2;
    String? c = generateKeyBetween(a, b);
    return generateNKeysBetween(a, c, mid)
        .followedBy([c])
        .followedBy(generateNKeysBetween(c, b, n - mid - 1))
        .toList();
  }
}

final indexing = Indexing();
