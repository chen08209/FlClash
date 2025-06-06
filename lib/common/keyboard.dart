import 'package:flutter/services.dart';
import 'package:uni_platform/uni_platform.dart';

import 'system.dart';

final Map<PhysicalKeyboardKey, String> _knownKeyLabels =
    <PhysicalKeyboardKey, String>{
  PhysicalKeyboardKey.keyA: 'A',
  PhysicalKeyboardKey.keyB: 'B',
  PhysicalKeyboardKey.keyC: 'C',
  PhysicalKeyboardKey.keyD: 'D',
  PhysicalKeyboardKey.keyE: 'E',
  PhysicalKeyboardKey.keyF: 'F',
  PhysicalKeyboardKey.keyG: 'G',
  PhysicalKeyboardKey.keyH: 'H',
  PhysicalKeyboardKey.keyI: 'I',
  PhysicalKeyboardKey.keyJ: 'J',
  PhysicalKeyboardKey.keyK: 'K',
  PhysicalKeyboardKey.keyL: 'L',
  PhysicalKeyboardKey.keyM: 'M',
  PhysicalKeyboardKey.keyN: 'N',
  PhysicalKeyboardKey.keyO: 'O',
  PhysicalKeyboardKey.keyP: 'P',
  PhysicalKeyboardKey.keyQ: 'Q',
  PhysicalKeyboardKey.keyR: 'R',
  PhysicalKeyboardKey.keyS: 'S',
  PhysicalKeyboardKey.keyT: 'T',
  PhysicalKeyboardKey.keyU: 'U',
  PhysicalKeyboardKey.keyV: 'V',
  PhysicalKeyboardKey.keyW: 'W',
  PhysicalKeyboardKey.keyX: 'X',
  PhysicalKeyboardKey.keyY: 'Y',
  PhysicalKeyboardKey.keyZ: 'Z',
  PhysicalKeyboardKey.digit1: '1',
  PhysicalKeyboardKey.digit2: '2',
  PhysicalKeyboardKey.digit3: '3',
  PhysicalKeyboardKey.digit4: '4',
  PhysicalKeyboardKey.digit5: '5',
  PhysicalKeyboardKey.digit6: '6',
  PhysicalKeyboardKey.digit7: '7',
  PhysicalKeyboardKey.digit8: '8',
  PhysicalKeyboardKey.digit9: '9',
  PhysicalKeyboardKey.digit0: '0',
  PhysicalKeyboardKey.enter: 'ENTER',
  PhysicalKeyboardKey.escape: 'ESCAPE',
  PhysicalKeyboardKey.backspace: 'BACKSPACE',
  PhysicalKeyboardKey.tab: 'TAB',
  PhysicalKeyboardKey.space: 'SPACE',
  PhysicalKeyboardKey.minus: '-',
  PhysicalKeyboardKey.equal: '=',
  PhysicalKeyboardKey.bracketLeft: '[',
  PhysicalKeyboardKey.bracketRight: ']',
  PhysicalKeyboardKey.backslash: '\\',
  PhysicalKeyboardKey.semicolon: ';',
  PhysicalKeyboardKey.quote: '"',
  PhysicalKeyboardKey.backquote: '`',
  PhysicalKeyboardKey.comma: ',',
  PhysicalKeyboardKey.period: '.',
  PhysicalKeyboardKey.slash: '/',
  PhysicalKeyboardKey.capsLock: 'CAPSLOCK',
  PhysicalKeyboardKey.f1: 'F1',
  PhysicalKeyboardKey.f2: 'F2',
  PhysicalKeyboardKey.f3: 'F3',
  PhysicalKeyboardKey.f4: 'F4',
  PhysicalKeyboardKey.f5: 'F5',
  PhysicalKeyboardKey.f6: 'F6',
  PhysicalKeyboardKey.f7: 'F7',
  PhysicalKeyboardKey.f8: 'F8',
  PhysicalKeyboardKey.f9: 'F9',
  PhysicalKeyboardKey.f10: 'F10',
  PhysicalKeyboardKey.f11: 'F11',
  PhysicalKeyboardKey.f12: 'F12',
  PhysicalKeyboardKey.home: 'HOME',
  PhysicalKeyboardKey.pageUp: 'PAGEUP',
  PhysicalKeyboardKey.delete: 'DELETE',
  PhysicalKeyboardKey.end: 'END',
  PhysicalKeyboardKey.pageDown: 'PAGEDOWN',
  PhysicalKeyboardKey.arrowRight: '→',
  PhysicalKeyboardKey.arrowLeft: '←',
  PhysicalKeyboardKey.arrowDown: '↓',
  PhysicalKeyboardKey.arrowUp: '↑',
  PhysicalKeyboardKey.controlLeft: 'CTRL',
  PhysicalKeyboardKey.shiftLeft: 'SHIFT',
  PhysicalKeyboardKey.altLeft: 'ALT',
  PhysicalKeyboardKey.metaLeft: system.isMacOS ? '⌘' : 'WIN',
  PhysicalKeyboardKey.controlRight: 'CTRL',
  PhysicalKeyboardKey.shiftRight: 'SHIFT',
  PhysicalKeyboardKey.altRight: 'ALT',
  PhysicalKeyboardKey.metaRight: system.isMacOS ? '⌘' : 'WIN',
  PhysicalKeyboardKey.fn: 'FN',
};

extension KeyboardKeyExt on KeyboardKey {
  String get label {
    PhysicalKeyboardKey? physicalKey;
    if (this is LogicalKeyboardKey) {
      physicalKey = (this as LogicalKeyboardKey).physicalKey;
    } else if (this is PhysicalKeyboardKey) {
      physicalKey = this as PhysicalKeyboardKey;
    }
    return _knownKeyLabels[physicalKey] ?? physicalKey?.debugName ?? 'Unknown';
  }
}
