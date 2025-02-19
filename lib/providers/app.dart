import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/models/models.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'generated/app.g.dart';

@riverpod
class Logs extends _$Logs {
  @override
  FixedList<Log> build() {
    return FixedList<Log>(1000);
  }

  addLog(Log log) {
    state = state..add(log);
  }
}

@riverpod
class Traffics extends _$Traffics {
  @override
  FixedList<Traffic> build() {
    return FixedList<Traffic>(30);
  }

  addTraffic(Traffic traffic) {
    state = state..add(traffic);
  }
}

@riverpod
class TotalTraffic extends _$TotalTraffic {
  @override
  Traffic build() {
    return Traffic();
  }

  update(Traffic newTraffic) {
    state = newTraffic;
  }
}

@riverpod
class LocalIp extends _$LocalIp {
  @override
  String? build() {
    return "";
  }

  update(String? value) {
    state = value;
  }
}

@riverpod
class RunTime extends _$RunTime {
  @override
  int? build() {
    return null;
  }

  update(int? value) {
    state = value;
  }
}

@riverpod
class ViewWidth extends _$ViewWidth {
  @override
  double build() {
    return other.getScreenSize().width;
  }

  update(double value) {
    state = value;
  }
}

@riverpod
class Init extends _$Init {
  @override
  bool build() {
    return false;
  }

  update(bool value) {
    state = value;
  }
}

@riverpod
class PageLabel extends _$PageLabel {
  @override
  String build() {
    return "dashboard";
  }

  update(String value) {
    state = value;
  }
}

@riverpod
class AppSchemes extends _$AppSchemes {
  @override
  ColorSchemes? build() {
    return null;
  }

  update(ColorSchemes? value) {
    state = value;
  }
}

@riverpod
class SortNum extends _$SortNum {
  @override
  int build() {
    return 0;
  }

  add() => state++;
}

@riverpod
class Groups extends _$Groups {
  @override
  List<Group> build() {
    return [];
  }

  update(List<Group> groups) {
    state = groups;
  }
}
