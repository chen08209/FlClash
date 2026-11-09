import 'package:flutter/services.dart';

class DynamicColorPlugin {
  static const _channel = OptionalMethodChannel(
    'io.material.plugins/dynamic_color',
  );

  // Native answers the primary palette's tones from 0 by tens to 90, then 95, 99, 100.
  static const _primaryTones = 13;
  static const _tone40 = 4;
  static const _tone80 = 8;

  static Future<({Color light, Color dark})?> getSystemSeeds() async {
    final raw = await _channel.invokeMethod<List<dynamic>>('getCorePalette');
    if (raw == null || raw.length < _primaryTones) {
      return null;
    }
    return (
      light: Color(raw[_tone40] as int),
      dark: Color(raw[_tone80] as int),
    );
  }

  static Future<Color?> getAccentColor() async {
    final result = await _channel.invokeMethod<int>('getAccentColor');
    return result == null ? null : Color(result);
  }
}
