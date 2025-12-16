class GlobalHandler {
  static GlobalHandler? _instance;

  GlobalHandler._internal();

  factory GlobalHandler() {
    _instance ??= GlobalHandler._internal();
    return _instance!;
  }
}

final globalHandle = GlobalHandler();
