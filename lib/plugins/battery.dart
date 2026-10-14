import 'package:fl_clash/common/common.dart';
import 'package:flutter/services.dart';

class BatteryOptimization {
  BatteryOptimization._();

  static final instance = BatteryOptimization._();

  static const _methodChannel = MethodChannel('$packageName/battery');
  static const _eventChannel = EventChannel(
    '$packageName/battery/optimization',
  );

  /// The current answer on listen, then one per change. On Xiaomi it follows
  /// the battery saver's "No restrictions" instead of the allowlist.
  late final Stream<bool> onChanged = _eventChannel
      .receiveBroadcastStream()
      .map((event) => event as bool);

  /// Completes once the user leaves the settings page; the answer itself
  /// arrives through [onChanged].
  Future<void> requestIgnore() {
    return _methodChannel.invokeMethod<void>('requestIgnoreOptimizations');
  }
}

final batteryOptimization = system.isAndroid
    ? BatteryOptimization.instance
    : null;
