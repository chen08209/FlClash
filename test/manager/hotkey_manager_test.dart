import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/manager/hotkey_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hotkey_manager/hotkey_manager.dart';

void main() {
  group('KeyboardModifierExt', () {
    test('maps keyboard modifiers to hotkey modifiers', () {
      expect(KeyboardModifier.alt.toHotKeyModifier(), HotKeyModifier.alt);
      expect(
        KeyboardModifier.capsLock.toHotKeyModifier(),
        HotKeyModifier.capsLock,
      );
      expect(
        KeyboardModifier.control.toHotKeyModifier(),
        HotKeyModifier.control,
      );
      expect(KeyboardModifier.fn.toHotKeyModifier(), HotKeyModifier.fn);
      expect(KeyboardModifier.meta.toHotKeyModifier(), HotKeyModifier.meta);
      expect(KeyboardModifier.shift.toHotKeyModifier(), HotKeyModifier.shift);
    });

    test('covers every keyboard modifier', () {
      for (final modifier in KeyboardModifier.values) {
        expect(modifier.toHotKeyModifier(), isA<HotKeyModifier>());
      }
    });
  });
}
