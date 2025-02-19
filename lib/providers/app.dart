import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/models/models.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'generated/app.g.dart';


@riverpod
class Logs extends _$Logs {
  @override
  FixedList<Log> build() {
    return FixedList<Log>(100);
  }

  addTodo(Log log) {
    state.add(log);
  }
}


