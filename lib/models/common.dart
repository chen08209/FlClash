import 'package:fl_clash/enum/enum.dart';

class Result<T> {
  String? message;
  ResultType type;
  T? data;

  Result({
    this.message,
    required this.type,
    this.data,
  });

  Result.success({
    this.data,
  })  : type = ResultType.success,
        message = null;

  Result.error({
    this.message,
  })  : type = ResultType.error,
        data = null;

  @override
  String toString() {
    return 'Result{message: $message, type: $type, data: $data}';
  }
}
