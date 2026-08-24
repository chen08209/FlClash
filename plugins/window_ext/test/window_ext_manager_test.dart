import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:window_ext/window_ext.dart';

const MethodChannel _channel = MethodChannel('window_ext');
const StandardMethodCodec _codec = StandardMethodCodec();

Future<void> _emit(String method) {
  return TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .handlePlatformMessage(
    _channel.name,
    _codec.encodeMethodCall(MethodCall(method)),
    (_) {},
  );
}

class _RemoveOnEventListener with WindowExtListener {
  int taskbarCreatedCount = 0;

  @override
  void onTaskbarCreated() {
    taskbarCreatedCount++;
    windowExtManager.removeListener(this);
  }
}

class _CountingListener with WindowExtListener {
  int taskbarCreatedCount = 0;

  @override
  void onTaskbarCreated() {
    taskbarCreatedCount++;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('a listener removing itself still reaches the later ones', () async {
    final remover = _RemoveOnEventListener();
    final counter = _CountingListener();
    windowExtManager.addListener(remover);
    windowExtManager.addListener(counter);
    addTearDown(() {
      windowExtManager.removeListener(remover);
      windowExtManager.removeListener(counter);
    });

    await _emit('taskbarCreated');

    expect(remover.taskbarCreatedCount, 1);
    expect(counter.taskbarCreatedCount, 1);
  });
}
