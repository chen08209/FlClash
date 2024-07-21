import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:fl_clash/common/app_localizations.dart';
import 'package:fl_clash/common/constant.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:flutter/material.dart';
import 'package:zxing2/qrcode.dart';
import 'package:image/image.dart' as img;

class Other {
  Color? getDelayColor(int? delay) {
    if (delay == null) return null;
    if (delay < 0) return Colors.red;
    if (delay < 600) return Colors.green;
    return const Color(0xFFC57F0A);
  }

  String getDateStringLast2(int value) {
    var valueRaw = "0$value";
    return valueRaw.substring(
      valueRaw.length - 2,
    );
  }

  String getTimeDifference(DateTime dateTime) {
    var currentDateTime = DateTime.now();
    var difference = currentDateTime.difference(dateTime);
    var inHours = difference.inHours;
    var inMinutes = difference.inMinutes;
    var inSeconds = difference.inSeconds;

    return "${getDateStringLast2(inHours)}:${getDateStringLast2(inMinutes)}:${getDateStringLast2(inSeconds)}";
  }

  String getTimeText(int? timeStamp) {
    if (timeStamp == null) {
      return '00:00:00';
    }
    final diff = timeStamp / 1000;
    final inHours = (diff / 3600).floor();
    if (inHours > 99) {
      return "99:59:59";
    }
    final inMinutes = (diff / 60 % 60).floor();
    final inSeconds = (diff % 60).floor();

    return "${getDateStringLast2(inHours)}:${getDateStringLast2(inMinutes)}:${getDateStringLast2(inSeconds)}";
  }

  Locale? getLocaleForString(String? localString) {
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
      return charA.compareTo(charB);
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
      return "$label(1)";
    }
  }

  String getTrayIconPath() {
    if (Platform.isWindows) {
      return "assets/images/icon.ico";
    } else {
      return "assets/images/icon_monochrome.png";
    }
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

  Future<String?> parseQRCode(Uint8List? bytes) {
    return Isolate.run<String?>(() {
      if (bytes == null) return null;
      img.Image? image = img.decodeImage(bytes);
      LuminanceSource source = RGBLuminanceSource(
        image!.width,
        image.height,
        image
            .convert(numChannels: 4)
            .getBytes(order: img.ChannelOrder.abgr)
            .buffer
            .asInt32List(),
      );
      final bitmap = BinaryBitmap(GlobalHistogramBinarizer(source));
      final reader = QRCodeReader();
      try {
        final result = reader.decode(bitmap);
        return result.text;
      } catch (_) {
        return null;
      }
    });
  }

  String? getFileNameForDisposition(String? disposition) {
    if (disposition == null) return null;
    final parseValue = HeaderValue.parse(disposition);
    final parameters = parseValue.parameters;
    final key = parameters.keys
        .firstWhere((key) => key.startsWith("filename"), orElse: () => '');
    if (key.isEmpty) return null;
    if (key == "filename*") {
      return Uri.decodeComponent((parameters[key] ?? "").split("'").last);
    } else {
      return parameters[key];
    }
  }

  double getViewWidth() {
    final view = WidgetsBinding.instance.platformDispatcher.views.first;
    final size = view.physicalSize / view.devicePixelRatio;
    return size.width;
  }

  List<String> parseReleaseBody(String? body) {
    if (body == null) return [];
    const pattern = r'- (.+?)\. \[.+?\]';
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

  int getColumns(ViewMode viewMode, int currentColumns) {
    final targetColumnsArray = viewModeColumnsMap[viewMode]!;
    if (targetColumnsArray.contains(currentColumns)) {
      return currentColumns;
    }
    return targetColumnsArray.first;
  }

  String getColumnsTextForInt(int number){
    return switch(number){
      1 => appLocalizations.oneColumn,
      2 => appLocalizations.twoColumns,
      3 => appLocalizations.threeColumns,
      4 => appLocalizations.fourColumns,
      int() => throw UnimplementedError(),
    };
  }
}

final other = Other();
