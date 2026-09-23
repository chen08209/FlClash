import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/manager/hotkey_manager.dart';
import 'package:fl_clash/models/common.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rust_api/rust_api.dart';

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

  group('HotKeyActionExt', () {
    test('builds a spec keyed by the action index and the HID usage', () {
      final spec = HotKeyAction(
        action: HotAction.tun,
        key: PhysicalKeyboardKey.keyT.usbHidUsage,
        modifiers: {KeyboardModifier.control, KeyboardModifier.shift},
      ).toHotKeySpec();

      expect(spec?.id, HotAction.tun.index);
      expect(spec?.key, PhysicalKeyboardKey.keyT.usbHidUsage);
      expect(
        spec?.modifiers,
        unorderedEquals([HotKeyModifier.control, HotKeyModifier.shift]),
      );
    });

    test('skips an action without a key or without modifiers', () {
      expect(
        const HotKeyAction(
          action: HotAction.start,
          modifiers: {KeyboardModifier.control},
        ).toHotKeySpec(),
        isNull,
      );
      expect(
        HotKeyAction(
          action: HotAction.start,
          key: PhysicalKeyboardKey.keyS.usbHidUsage,
        ).toHotKeySpec(),
        isNull,
      );
    });
  });
}
