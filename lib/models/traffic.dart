import 'dart:math';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

class Traffic {
  int id;
  TrafficValue up;
  TrafficValue down;

  Traffic({num? up, num? down})
      : id = DateTime.now().millisecondsSinceEpoch,
        up = TrafficValue(value: up),
        down = TrafficValue(value: down);

  num get speed => up.value + down.value;

  factory Traffic.fromMap(Map<String, dynamic> map) {
    return Traffic(
      up: map['up'],
      down: map['down'],
    );
  }

  @override
  String toString() {
    return '$up↑ $down↓';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Traffic &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          up == other.up &&
          down == other.down;

  @override
  int get hashCode => id.hashCode ^ up.hashCode ^ down.hashCode;
}

@immutable
class TrafficValueShow {
  final String value;
  final TrafficUnit unit;

  const TrafficValueShow({
    required this.value,
    required this.unit,
  });
}

@immutable
class TrafficValue {
  final num _value;

  const TrafficValue({num? value}) : _value = value ?? 0;

  num get value => _value;

  String get show => "$showValue $showUnit";

  String get showValue => trafficValueShow.value;

  String get showUnit => trafficValueShow.unit.name;

  TrafficValueShow get trafficValueShow {
    if (_value > pow(1024, 4)) {
      return TrafficValueShow(
        value: (_value / pow(1024, 4)).fixed(),
        unit: TrafficUnit.TB,
      );
    }
    if (_value > pow(1024, 3)) {
      return TrafficValueShow(
        value: (_value / pow(1024, 3)).fixed(),
        unit: TrafficUnit.GB,
      );
    }
    if (_value > pow(1024, 2)) {
      return TrafficValueShow(
          value: (_value / pow(1024, 2)).fixed(), unit: TrafficUnit.MB);
    }
    if (_value > pow(1024, 1)) {
      return TrafficValueShow(
        value: (_value / pow(1024, 1)).fixed(),
        unit: TrafficUnit.KB,
      );
    }
    return TrafficValueShow(
      value: _value.fixed(),
      unit: TrafficUnit.B,
    );
  }

  @override
  String toString() {
    return "$showValue$showUnit";
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TrafficValue &&
          runtimeType == other.runtimeType &&
          _value == other._value;

  @override
  int get hashCode => _value.hashCode;
}
