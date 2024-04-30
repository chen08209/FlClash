import 'dart:io';

import 'package:flutter/material.dart';

class Other {
  static Color? getDelayColor(int? delay) {
    if (delay == null) return null;
    if (delay < 0) return Colors.red;
    if (delay < 600) return Colors.green;
    return const Color(0xFFC57F0A);
  }

  static String getDateStringLast2(int value) {
    var valueRaw = "0$value";
    return valueRaw.substring(
      valueRaw.length - 2,
    );
  }

  static String getTimeDifference(DateTime dateTime) {
    var currentDateTime = DateTime.now();
    var difference = currentDateTime.difference(dateTime);
    var inHours = difference.inHours;
    var inMinutes = difference.inMinutes;
    var inSeconds = difference.inSeconds;

    return "${getDateStringLast2(inHours)}:${getDateStringLast2(inMinutes)}:${getDateStringLast2(inSeconds)}";
  }

  static String getTimeText(int? timeStamp) {
    if (timeStamp == null) {
      return '00:00:00';
    }
    final diff = timeStamp / 1000;
    final inHours = (diff / 3600).floor();
    final inMinutes = (diff / 60 % 60).floor();
    final inSeconds = (diff % 60).floor();

    return "${getDateStringLast2(inHours)}:${getDateStringLast2(inMinutes)}:${getDateStringLast2(inSeconds)}";
  }

  static Locale? getLocaleForString(String? localString) {
    if (localString == null) return null;
    var localSplit = localString.split("_");
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
          countryCode: localSplit[2]);
    }
    return null;
  }

  static int sortByChar(String a, String b) {
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
      return charA.compareTo(charB);
    }
  }

  static String getOverwriteLabel(String label) {
    final reg = RegExp(r'\((\d+)\)$');
    final matches = reg.allMatches(label);
    if (matches.isNotEmpty) {
      final match = matches.last;
      final number = int.parse(match[1] ?? '0') + 1;
      return label.replaceFirst(reg, '($number)', label.length - 3 - 1);
    } else {
      return "$label(1)";
    }
  }

  // static FutureOr<void> Function(T p) debounce<T>(void Function(T? p) func,
  //     {Duration? duration}) {
  //   Timer? timer;
  //   return ([T? p]) {
  //     if (timer != null) {
  //       timer?.cancel();
  //     }
  //     timer = Timer(duration ?? const Duration(milliseconds: 300), () {
  //       func(p);
  //     });
  //   };
  // }


  static String getTrayIconPath() {
    if (Platform.isWindows) {
      return "assets/images/app_icon.ico";
    } else {
      return "assets/images/launch_icon.png";
    }
  }

  static int compareVersions(String version1, String version2) {
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
}
