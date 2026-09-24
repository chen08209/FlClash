import 'package:fl_clash/enum/enum.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'system.dart';

/// Mirrors `PRIMARY_MODIFIERS` in `plugins/rust_api/rust/src/hotkey/keys.rs`:
/// a global hotkey carrying none of these is refused by the OS layer.
const primaryHotKeyModifiers = {
  KeyboardModifier.control,
  KeyboardModifier.alt,
  KeyboardModifier.shift,
  KeyboardModifier.meta,
};

bool isValidHotKey(Set<KeyboardModifier> modifiers, int? key) {
  return key != null && modifiers.any(primaryHotKeyModifiers.contains);
}

bool isModifierKey(PhysicalKeyboardKey key) {
  return KeyboardModifier.values.any(
    (modifier) => modifier.physicalKeys.contains(key),
  );
}

final class ShortcutLabels {
  const ShortcutLabels({required this.isMacOS, required this.isWindows});

  ShortcutLabels.host()
    : this(isMacOS: system.isMacOS, isWindows: system.isWindows);

  final bool isMacOS;
  final bool isWindows;

  static const _modifierOrder = [
    KeyboardModifier.fn,
    KeyboardModifier.capsLock,
    KeyboardModifier.control,
    KeyboardModifier.alt,
    KeyboardModifier.shift,
    KeyboardModifier.meta,
  ];

  static final _macKeyLabels = {
    PhysicalKeyboardKey.enter: '↩',
    PhysicalKeyboardKey.numpadEnter: '⌤',
    PhysicalKeyboardKey.escape: '⎋',
    PhysicalKeyboardKey.backspace: '⌫',
    PhysicalKeyboardKey.delete: '⌦',
    PhysicalKeyboardKey.tab: '⇥',
    PhysicalKeyboardKey.capsLock: '⇪',
    PhysicalKeyboardKey.home: '↖',
    PhysicalKeyboardKey.end: '↘',
    PhysicalKeyboardKey.pageUp: '⇞',
    PhysicalKeyboardKey.pageDown: '⇟',
  };

  static final _keyLabels = {
    PhysicalKeyboardKey.enter: 'Enter',
    PhysicalKeyboardKey.numpadEnter: 'Enter',
    PhysicalKeyboardKey.escape: 'Esc',
    PhysicalKeyboardKey.backspace: 'Backspace',
    PhysicalKeyboardKey.delete: 'Del',
    PhysicalKeyboardKey.insert: 'Ins',
    PhysicalKeyboardKey.tab: 'Tab',
    PhysicalKeyboardKey.space: 'Space',
    PhysicalKeyboardKey.capsLock: 'Caps Lock',
    PhysicalKeyboardKey.home: 'Home',
    PhysicalKeyboardKey.end: 'End',
    PhysicalKeyboardKey.pageUp: 'PgUp',
    PhysicalKeyboardKey.pageDown: 'PgDn',
    PhysicalKeyboardKey.printScreen: 'PrtSc',
    PhysicalKeyboardKey.scrollLock: 'ScrLk',
    PhysicalKeyboardKey.pause: 'Pause',
    PhysicalKeyboardKey.numLock: 'NumLk',
    PhysicalKeyboardKey.contextMenu: 'Menu',
    PhysicalKeyboardKey.arrowUp: '↑',
    PhysicalKeyboardKey.arrowDown: '↓',
    PhysicalKeyboardKey.arrowLeft: '←',
    PhysicalKeyboardKey.arrowRight: '→',
    PhysicalKeyboardKey.minus: '-',
    PhysicalKeyboardKey.equal: '=',
    PhysicalKeyboardKey.bracketLeft: '[',
    PhysicalKeyboardKey.bracketRight: ']',
    PhysicalKeyboardKey.backslash: r'\',
    PhysicalKeyboardKey.semicolon: ';',
    PhysicalKeyboardKey.quote: "'",
    PhysicalKeyboardKey.backquote: '`',
    PhysicalKeyboardKey.comma: ',',
    PhysicalKeyboardKey.period: '.',
    PhysicalKeyboardKey.slash: '/',
    PhysicalKeyboardKey.numpadDivide: 'Num /',
    PhysicalKeyboardKey.numpadMultiply: 'Num *',
    PhysicalKeyboardKey.numpadSubtract: 'Num -',
    PhysicalKeyboardKey.numpadAdd: 'Num +',
    PhysicalKeyboardKey.numpadDecimal: 'Num .',
    PhysicalKeyboardKey.numpadEqual: 'Num =',
    PhysicalKeyboardKey.mediaPlayPause: 'Play/Pause',
    PhysicalKeyboardKey.mediaStop: 'Stop',
    PhysicalKeyboardKey.mediaTrackNext: 'Next Track',
    PhysicalKeyboardKey.mediaTrackPrevious: 'Previous Track',
    PhysicalKeyboardKey.audioVolumeMute: 'Mute',
    PhysicalKeyboardKey.audioVolumeUp: 'Volume Up',
    PhysicalKeyboardKey.audioVolumeDown: 'Volume Down',
  };

  String modifier(KeyboardModifier modifier) {
    if (isMacOS) {
      return switch (modifier) {
        KeyboardModifier.control => '⌃',
        KeyboardModifier.alt => '⌥',
        KeyboardModifier.shift => '⇧',
        KeyboardModifier.meta => '⌘',
        KeyboardModifier.capsLock => '⇪',
        KeyboardModifier.fn => 'fn',
      };
    }
    return switch (modifier) {
      KeyboardModifier.control => 'Ctrl',
      KeyboardModifier.alt => 'Alt',
      KeyboardModifier.shift => 'Shift',
      KeyboardModifier.meta => isWindows ? 'Win' : 'Super',
      KeyboardModifier.capsLock => 'Caps Lock',
      KeyboardModifier.fn => 'Fn',
    };
  }

  String key(int usbHidUsage) {
    final physicalKey = PhysicalKeyboardKey(usbHidUsage);
    final named =
        (isMacOS ? _macKeyLabels[physicalKey] : null) ??
        _keyLabels[physicalKey];
    if (named != null) {
      return named;
    }
    return switch (usbHidUsage) {
      >= 0x00070004 && <= 0x0007001d => String.fromCharCode(
        0x41 + usbHidUsage - 0x00070004,
      ),
      >= 0x0007001e && <= 0x00070026 => '${usbHidUsage - 0x0007001d}',
      0x00070027 => '0',
      >= 0x0007003a && <= 0x00070045 => 'F${usbHidUsage - 0x00070039}',
      >= 0x00070068 && <= 0x00070073 => 'F${usbHidUsage - 0x0007005b}',
      >= 0x00070059 && <= 0x00070061 => 'Num ${usbHidUsage - 0x00070058}',
      0x00070062 => 'Num 0',
      _ => physicalKey.debugName ?? '0x${usbHidUsage.toRadixString(16)}',
    };
  }

  List<String> modifierParts(Set<KeyboardModifier> modifiers) {
    return [
      for (final modifier in _modifierOrder)
        if (modifiers.contains(modifier)) this.modifier(modifier),
    ];
  }

  List<String> parts(Set<KeyboardModifier> modifiers, int key) {
    return [...modifierParts(modifiers), this.key(key)];
  }

  String text(Set<KeyboardModifier> modifiers, int key) {
    return parts(modifiers, key).join(isMacOS ? '' : '+');
  }
}

SingleActivator controlSingleActivator(LogicalKeyboardKey trigger) {
  final control = system.isMacOS ? false : true;
  return SingleActivator(trigger, control: control, meta: !control);
}
