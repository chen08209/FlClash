import 'package:fl_clash/enum/enum.dart';
import 'package:json_annotation/json_annotation.dart';

part 'generated/log.g.dart';

@JsonSerializable()
class Log {
  @JsonKey(name: "LogLevel")
  LogLevel logLevel;
  @JsonKey(name: "Payload")
  String? payload;
  DateTime _dateTime;

  Log({
    required this.logLevel,
    this.payload,
  }) : _dateTime = DateTime.now();

  DateTime get dateTime => _dateTime;

  factory Log.fromJson(Map<String, dynamic> json) {
    return _$LogFromJson(json);
  }

  Map<String, dynamic> toJson() {
    return _$LogToJson(this);
  }

  @override
  String toString() {
    return 'Log{logLevel: $logLevel, payload: $payload, dateTime: $dateTime}';
  }
}
