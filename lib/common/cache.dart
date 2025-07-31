import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class LocalImageResponse extends HttpGetResponse {
  LocalImageResponse(super.response);

  final DateTime _receivedTime = DateTime.now();

  @override
  DateTime get validTill {
    final minValidTill = _receivedTime.add(const Duration(days: 7));
    if (super.validTill.isBefore(minValidTill)) {
      return minValidTill;
    }
    return super.validTill;
  }
}
