import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/models/models.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'generated/app.g.dart';

@riverpod
class Logs extends _$Logs {
  @override
  FixedList<Log> build() {
    return FixedList<Log>(1000);
  }

  addLog(Log value) {
    state = state..add(value);
  }
}

@riverpod
class Requests extends _$Requests {
  @override
  FixedList<Connection> build() {
    return FixedList<Connection>(1000);
  }

  addRequest(Connection value) {
    state = state..add(value);
  }
}

@riverpod
class Providers extends _$Providers {
  @override
  List<ExternalProvider> build() {
    return [];
  }

  update(List<ExternalProvider> value) {
    state = value;
  }
}

@riverpod
class Packages extends _$Packages {
  @override
  List<Package> build() {
    return [];
  }

  update(List<Package> value) {
    state = value;
  }
}

@riverpod
class AppBrightness extends _$AppBrightness {
  @override
  Brightness? build() {
    return null;
  }

  update(Brightness? value) {
    state = value;
  }
}

@riverpod
class Traffics extends _$Traffics {
  @override
  FixedList<Traffic> build() {
    return FixedList<Traffic>(30);
  }

  addTraffic(Traffic value) {
    state = state..add(value);
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
class CheckIpNum extends _$CheckIpNum {
  @override
  int build() {
    return 0;
  }

  add() => state++;
}

@riverpod
class Version extends _$Version {
  @override
  int build() {
    return 0;
  }

  update(int value) {
    state = value;
  }
}

@riverpod
class Groups extends _$Groups {
  @override
  List<Group> build() {
    return [];
  }

  update(List<Group> value) {
    state = value;
  }
}

@riverpod
class SelectedDataSource extends _$SelectedDataSource {
  @override
  Map<String, String> build() {
    return {};
  }

  update(Map<String, String> value) {
    state = value;
  }
}

@riverpod
class DelayDataSource extends _$DelayDataSource {
  @override
  DelayMap build() {
    return {};
  }

  update(DelayMap value) {
    state = value;
  }
}
