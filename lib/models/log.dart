// ignore_for_file: invalid_annotation_target

import 'package:fl_clash/enum/enum.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated/log.g.dart';

part 'generated/log.freezed.dart';

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

@freezed
class LogsAndKeywords with _$LogsAndKeywords {
  const factory LogsAndKeywords({
    @Default([]) List<Log> logs,
    @Default([]) List<String> keywords,
  }) = _LogsAndKeywords;

  factory LogsAndKeywords.fromJson(Map<String, Object?> json) =>
      _$LogsAndKeywordsFromJson(json);
}

extension LogsAndKeywordsExt on LogsAndKeywords {
  List<Log> get filteredLogs => logs
      .where(
        (log) => {log.logLevel.name}.containsAll(keywords),
      )
      .toList();
}
