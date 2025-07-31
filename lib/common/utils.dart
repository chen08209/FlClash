import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Utils {
  Color? getDelayColor(int? delay) {
    if (delay == null) return null;
    if (delay < 0) return Colors.red;
    if (delay < 600) return Colors.green;
    return const Color(0xFFC57F0A);
  }

  String get id {
    final timestamp = DateTime.now().microsecondsSinceEpoch;
    final random = Random();
    final randomStr = String.fromCharCodes(
      List.generate(8, (_) => random.nextInt(26) + 97),
    );
    return '$timestamp$randomStr';
  }

  String getDateStringLast2(int value) {
    var valueRaw = '0$value';
    return valueRaw.substring(valueRaw.length - 2);
  }

  String generateRandomString({int minLength = 10, int maxLength = 100}) {
    const latinChars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();

    int length = minLength + random.nextInt(maxLength - minLength + 1);

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

  String get uuidV4 {
    final Random random = Random();
    final bytes = List.generate(16, (_) => random.nextInt(256));

    bytes[6] = (bytes[6] & 0x0F) | 0x40;
    bytes[8] = (bytes[8] & 0x3F) | 0x80;

    final hex = bytes
        .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
        .join();

    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20, 32)}';
  }

  String getTimeDifference(DateTime dateTime) {
    var currentDateTime = DateTime.now();
    var difference = currentDateTime.difference(dateTime);
    var inHours = difference.inHours;
    var inMinutes = difference.inMinutes;
    var inSeconds = difference.inSeconds;

    return '${getDateStringLast2(inHours)}:${getDateStringLast2(inMinutes)}:${getDateStringLast2(inSeconds)}';
  }

  String getTimeText(int? timeStamp) {
    if (timeStamp == null) {
      return '00:00:00';
    }
    final diff = timeStamp / 1000;
    final inHours = (diff / 3600).floor();
    if (inHours > 99) {
      return '99:59:59';
    }
    final inMinutes = (diff / 60 % 60).floor();
    final inSeconds = (diff % 60).floor();

    return '${getDateStringLast2(inHours)}:${getDateStringLast2(inMinutes)}:${getDateStringLast2(inSeconds)}';
  }

  Locale? getLocaleForString(String? localString) {
    if (localString == null) return null;
    var localSplit = localString.split('_');
    if (localSplit.length == 1) {
      return Locale(localSplit[0]);
    }
    if (localSplit.length == 2) {
      return Locale(localSplit[0], localSplit[1]);
    }
    if (localSplit.length == 3) {
      return Locale.fromSubtags(
        languageCode: localSplit[0],
        scriptCode: localSplit[1],
        countryCode: localSplit[2],
      );
    }
    return null;
  }

  int sortByChar(String a, String b) {
    if (a.isEmpty && b.isEmpty) {
      return 0;
    }
    if (a.isEmpty) {
      return -1;
    }
    if (b.isEmpty) {
      return 1;
    }
    final charA = a[0];
    final charB = b[0];

    if (charA == charB) {
      return sortByChar(a.substring(1), b.substring(1));
    } else {
      return charA.compareToLower(charB);
    }
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

  String getTrayIconPath({required Brightness brightness}) {
    if (system.isMacOS) {
      return 'assets/images/icon_white.png';
    }
    final suffix = system.isWindows ? 'ico' : 'png';
    return 'assets/images/icon.$suffix';
    // return switch (brightness) {
    //   Brightness.dark => "assets/images/icon_white.$suffix",
    //   Brightness.light => "assets/images/icon_black.$suffix",
    // };
  }

  int compareVersions(String version1, String version2) {
    List<String> v1 = version1.split('+')[0].split('.');
    List<String> v2 = version2.split('+')[0].split('.');
    int major1 = int.parse(v1[0]);
    int major2 = int.parse(v2[0]);
    if (major1 != major2) {
      return major1.compareTo(major2);
    }
    int minor1 = v1.length > 1 ? int.parse(v1[1]) : 0;
    int minor2 = v2.length > 1 ? int.parse(v2[1]) : 0;
    if (minor1 != minor2) {
      return minor1.compareTo(minor2);
    }
    int patch1 = v1.length > 2 ? int.parse(v1[2]) : 0;
    int patch2 = v2.length > 2 ? int.parse(v2[2]) : 0;
    if (patch1 != patch2) {
      return patch1.compareTo(patch2);
    }
    int build1 = version1.contains('+') ? int.parse(version1.split('+')[1]) : 0;
    int build2 = version2.contains('+') ? int.parse(version2.split('+')[1]) : 0;
    return build1.compareTo(build2);
  }

  // String getPinyin(String value) {
  //   return value.isNotEmpty
  //       ? PinyinHelper.getFirstWordPinyin(value.substring(0, 1))
  //       : '';
  // }

  String? getFileNameForDisposition(String? disposition) {
    if (disposition == null) return null;
    final parseValue = HeaderValue.parse(disposition);
    final parameters = parseValue.parameters;
    final fileNamePointKey = parameters.keys.firstWhere(
      (key) => key == 'filename*',
      orElse: () => '',
    );
    if (fileNamePointKey.isNotEmpty) {
      final res = parameters[fileNamePointKey]?.split("''") ?? [];
      if (res.length >= 2) {
        return Uri.decodeComponent(res[1]);
      }
    }
    final fileNameKey = parameters.keys.firstWhere(
      (key) => key == 'filename',
      orElse: () => '',
    );
    if (fileNameKey.isEmpty) return null;
    return parameters[fileNameKey];
  }

  FlutterView getScreen() {
    return WidgetsBinding.instance.platformDispatcher.views.first;
  }

  List<String> parseReleaseBody(String? body) {
    if (body == null) return [];
    const pattern = r'- \s*(.*)';
    final regex = RegExp(pattern);
    return regex
        .allMatches(body)
        .map((match) => match.group(1) ?? '')
        .where((item) => item.isNotEmpty)
        .toList();
  }

  ViewMode getViewMode(double viewWidth) {
    if (viewWidth <= maxMobileWidth) return ViewMode.mobile;
    if (viewWidth <= maxLaptopWidth) return ViewMode.laptop;
    return ViewMode.desktop;
  }

  int getProxiesColumns(double viewWidth, ProxiesLayout proxiesLayout) {
    final columns = max((viewWidth / 250).ceil(), 2);
    return switch (proxiesLayout) {
      ProxiesLayout.tight => columns + 1,
      ProxiesLayout.standard => columns,
      ProxiesLayout.loose => columns - 1,
    };
  }

  int getProfilesColumns(double viewWidth) {
    return max((viewWidth / 280).floor(), 1);
  }

  final _indexPrimary = [50, 100, 200, 300, 400, 500, 600, 700, 800, 850, 900];

  MaterialColor _createPrimarySwatch(Color color) {
    final Map<int, Color> swatch = <int, Color>{};
    final int a = color.alpha8bit;
    final int r = color.red8bit;
    final int g = color.green8bit;
    final int b = color.blue8bit;
    for (final int strength in _indexPrimary) {
      final double ds = 0.5 - strength / 1000;
      swatch[strength] = Color.fromARGB(
        a,
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
      );
    }
    swatch[50] = swatch[50]!.lighten(18);
    swatch[100] = swatch[100]!.lighten(16);
    swatch[200] = swatch[200]!.lighten(14);
    swatch[300] = swatch[300]!.lighten(10);
    swatch[400] = swatch[400]!.lighten(6);
    swatch[700] = swatch[700]!.darken(2);
    swatch[800] = swatch[800]!.darken(3);
    swatch[900] = swatch[900]!.darken(4);
    return MaterialColor(color.value32bit, swatch);
  }

  List<Color> getMaterialColorShades(Color color) {
    final swatch = _createPrimarySwatch(color);
    return <Color>[
      if (swatch[50] != null) swatch[50]!,
      if (swatch[100] != null) swatch[100]!,
      if (swatch[200] != null) swatch[200]!,
      if (swatch[300] != null) swatch[300]!,
      if (swatch[400] != null) swatch[400]!,
      if (swatch[500] != null) swatch[500]!,
      if (swatch[600] != null) swatch[600]!,
      if (swatch[700] != null) swatch[700]!,
      if (swatch[800] != null) swatch[800]!,
      if (swatch[850] != null) swatch[850]!,
      if (swatch[900] != null) swatch[900]!,
    ];
  }

  String getBackupFileName() {
    return '${appName}_backup_${DateTime.now().show}.zip';
  }

  String get logFile {
    return '${appName}_${DateTime.now().show}.log';
  }

  Future<String?> getLocalIpAddress() async {
    List<NetworkInterface> interfaces =
        await NetworkInterface.list(includeLoopback: false)
          ..sort((a, b) {
            if (a.isWifi && !b.isWifi) return -1;
            if (!a.isWifi && b.isWifi) return 1;
            if (a.includesIPv4 && !b.includesIPv4) return -1;
            if (!a.includesIPv4 && b.includesIPv4) return 1;
            return 0;
          });
    for (final interface in interfaces) {
      final addresses = interface.addresses;
      if (addresses.isEmpty) {
        continue;
      }
      addresses.sort((a, b) {
        if (a.isIPv4 && !b.isIPv4) return -1;
        if (!a.isIPv4 && b.isIPv4) return 1;
        return 0;
      });
      return addresses.first.address;
    }
    return '';
  }

  SingleActivator controlSingleActivator(LogicalKeyboardKey trigger) {
    final control = system.isMacOS ? false : true;
    return SingleActivator(trigger, control: control, meta: !control);
  }

  FutureOr<T> handleWatch<T>(Function function) async {
    if (kDebugMode) {
      final stopwatch = Stopwatch()..start();
      final res = await function();
      stopwatch.stop();
      commonPrint.log('耗时：${stopwatch.elapsedMilliseconds} ms');
      return res;
    }
    return await function();
  }
}

final utils = Utils();
