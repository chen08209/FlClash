import 'package:fl_clash/common/app_localizations.dart';

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

  String get lastUpdateTimeDesc {
    final currentDateTime = DateTime.now();
    final difference = currentDateTime.difference(this);
    final days = difference.inDays;
    if (days >= 365) {
      return '${(days / 365).floor()} ${appLocalizations.years}${appLocalizations.ago}';
    }
    if (days >= 30) {
      return '${(days / 30).floor()} ${appLocalizations.months}${appLocalizations.ago}';
    }
    if (days >= 1) {
      return '$days ${appLocalizations.days}${appLocalizations.ago}';
    }
    final hours = difference.inHours;
    if (hours >= 1) {
      return '$hours ${appLocalizations.hours}${appLocalizations.ago}';
    }
    final minutes = difference.inMinutes;
    if (minutes >= 1) {
      return '$minutes ${appLocalizations.minutes}${appLocalizations.ago}';
    }
    return appLocalizations.just;
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
