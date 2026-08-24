import 'package:flutter/cupertino.dart';

import 'context.dart';

extension DateTimeExtension on DateTime {
  bool get isBeforeNow {
    return isBefore(DateTime.now());
  }

  bool isBeforeSecure(DateTime? dateTime) {
    if (dateTime == null) {
      return false;
    }
    return true;
  }

  String getLastUpdateTimeDesc(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final currentDateTime = DateTime.now();
    final difference = currentDateTime.difference(this);
    final days = difference.inDays;
    if (days >= 365) {
      final years = (days / 365).floor();
      return appLocalizations.yearsAgo(years);
    }
    if (days >= 30) {
      final months = (days / 30).floor();
      return appLocalizations.monthsAgo(months);
    }
    if (days >= 1) {
      return appLocalizations.daysAgo(days);
    }
    final hours = difference.inHours;
    if (hours >= 1) {
      return appLocalizations.hoursAgo(hours);
    }
    final minutes = difference.inMinutes;
    if (minutes >= 1) {
      return appLocalizations.minutesAgo(minutes);
    }
    return appLocalizations.justNow;
  }

  String get show {
    return toString().substring(0, 10);
  }

  String get showFull {
    return toString().substring(0, 19);
  }

  String get showTime {
    return toString().substring(10, 19);
  }
}

String getDateStringLast2(int value) {
  final valueRaw = '0$value';
  return valueRaw.substring(valueRaw.length - 2);
}

String getTimeText(int? timeStamp) {
  if (timeStamp == null) {
    return '00:00:00';
  }
  final diff = timeStamp / 1000;
  final inHours = (diff / 3600).floor();
  if (inHours > 999) {
    return '999:59:59';
  }
  final inMinutes = (diff / 60 % 60).floor();
  final inSeconds = (diff % 60).floor();
  final hoursText = inHours.toString().padLeft(2, '0');

  return '$hoursText:${getDateStringLast2(inMinutes)}:${getDateStringLast2(inSeconds)}';
}
