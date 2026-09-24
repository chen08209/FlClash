import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:fl_clash/icons/glyph.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:material_ui/material_ui.dart';

abstract final class AppGlyphs {
  static const dashboard = Glyph([
    GlyphBox(3.5, 3.5, 10.5, 11.5, 2),
    GlyphBox(13.5, 3.5, 20.5, 9.5, 2),
    GlyphBox(3.5, 14.5, 10.5, 20.5, 2),
    GlyphBox(13.5, 12.5, 20.5, 20.5, 2),
  ]);

  static const proxies = Glyph([
    GlyphCircle(12, 12, 8.8),
    GlyphOval(8.2, 3.2, 15.8, 20.8, role: GlyphRole.detail),
    GlyphPolyline([
      GlyphVertex(3.2, 12),
      GlyphVertex(20.8, 12),
    ], role: GlyphRole.detail),
  ]);

  static const profiles = Glyph([
    GlyphPolyline([
      GlyphVertex(5, 3, 2.5),
      GlyphVertex(13.5, 3, 1),
      GlyphVertex(19, 8.5, 1),
      GlyphVertex(19, 21, 2.5),
      GlyphVertex(5, 21, 2.5),
    ], closed: true),
    GlyphPolyline([
      GlyphVertex(13.5, 3.2),
      GlyphVertex(13.5, 8.5, 1.5),
      GlyphVertex(18.8, 8.5),
    ], role: GlyphRole.detail),
    GlyphPolyline([
      GlyphVertex(8.5, 12.5),
      GlyphVertex(15.5, 12.5),
    ], role: GlyphRole.detail),
    GlyphPolyline([
      GlyphVertex(8.5, 16),
      GlyphVertex(13, 16),
    ], role: GlyphRole.detail),
  ]);

  static const requests = Glyph([
    GlyphCircle(12, 12, 8.8),
    GlyphPolyline([
      GlyphVertex(12, 7.2),
      GlyphVertex(12, 12, 0.6),
      GlyphVertex(15.2, 14),
    ], role: GlyphRole.detail),
  ]);

  static const clock = requests;

  static const history = Glyph([
    GlyphArc(12, 12, 9, math.pi * 1.25, math.pi * 1.65, role: GlyphRole.line),
    GlyphPolyline([
      GlyphVertex(5.6, 5.6),
      GlyphVertex(4.1, 7.1),
    ], role: GlyphRole.line),
    GlyphPolyline([
      GlyphVertex(4.1, 3.5),
      GlyphVertex(4.1, 7.1, 0.4),
      GlyphVertex(7.7, 7.1),
    ], role: GlyphRole.line),
    GlyphCircle(12.4, 12.4, 4.6),
    GlyphPolyline([
      GlyphVertex(12.4, 10.2),
      GlyphVertex(12.4, 12.4, 0.4),
      GlyphVertex(14, 13.4),
    ], role: GlyphRole.detail),
  ]);

  static const connections = Glyph([
    GlyphCircle(12, 5.2, 2.4),
    GlyphCircle(5.2, 17.6, 2.4),
    GlyphCircle(18.8, 17.6, 2.4),
    GlyphLink(Offset(12, 5.2), Offset(5.2, 17.6), 2.4),
    GlyphLink(Offset(12, 5.2), Offset(18.8, 17.6), 2.4),
    GlyphLink(Offset(5.2, 17.6), Offset(18.8, 17.6), 2.4),
  ]);

  static const dns = Glyph([
    GlyphBox(3.5, 3.5, 20.5, 10.5, 2.5),
    GlyphBox(3.5, 13.5, 20.5, 20.5, 2.5),
    GlyphCircle(7.2, 7, 1.1, role: GlyphRole.detail, solid: true),
    GlyphCircle(7.2, 17, 1.1, role: GlyphRole.detail, solid: true),
  ]);

  static const resources = Glyph([
    GlyphBox(3, 3.5, 21, 8.5, 1.8),
    GlyphBox(4.5, 10.8, 19.5, 20.5, 2.2),
    GlyphPolyline([
      GlyphVertex(10, 14.2),
      GlyphVertex(14, 14.2),
    ], role: GlyphRole.detail),
  ]);

  static const logs = Glyph([
    GlyphBox(3, 4.5, 21, 19.5, 3.5),
    GlyphPolyline([
      GlyphVertex(7.3, 9.3),
      GlyphVertex(9.9, 11.9, 0.4),
      GlyphVertex(7.3, 14.5),
    ], role: GlyphRole.detail),
    GlyphPolyline([
      GlyphVertex(12.2, 14.5),
      GlyphVertex(16.2, 14.5),
    ], role: GlyphRole.detail),
  ]);

  static const tools = Glyph([
    GlyphBox(3, 7, 21, 20, 2.8),
    GlyphPolyline([
      GlyphVertex(9, 7),
      GlyphVertex(9, 4.6, 1.4),
      GlyphVertex(15, 4.6, 1.4),
      GlyphVertex(15, 7),
    ], role: GlyphRole.line),
    GlyphPolyline([
      GlyphVertex(3.2, 12.6),
      GlyphVertex(9.6, 12.6),
    ], role: GlyphRole.detail),
    GlyphPolyline([
      GlyphVertex(14.4, 12.6),
      GlyphVertex(20.8, 12.6),
    ], role: GlyphRole.detail),
    GlyphBox(10.4, 11, 13.6, 14.4, 1, role: GlyphRole.detail),
  ]);

  static const target = Glyph([
    GlyphArc(
      12,
      12,
      8.8,
      math.pi * -0.93,
      math.pi * 0.86,
      role: GlyphRole.line,
    ),
    GlyphArc(12, 12, 8.8, math.pi * 0.07, math.pi * 0.86, role: GlyphRole.line),
    GlyphCircle(12, 12, 2),
  ]);

  static const arrowBack = Glyph([
    GlyphPolyline([
      GlyphVertex(5, 12),
      GlyphVertex(19, 12),
    ], role: GlyphRole.line),
    GlyphPolyline([
      GlyphVertex(11.5, 5.5),
      GlyphVertex(5, 12, 0.4),
      GlyphVertex(11.5, 18.5),
    ], role: GlyphRole.line),
  ], matchTextDirection: true);

  static const chevronBack = Glyph([
    GlyphPolyline([
      GlyphVertex(15.25, 5.5),
      GlyphVertex(8.75, 12, 0.4),
      GlyphVertex(15.25, 18.5),
    ], role: GlyphRole.line),
  ], matchTextDirection: true);

  static const chevronForward = Glyph([
    GlyphPolyline([
      GlyphVertex(8.75, 5.5),
      GlyphVertex(15.25, 12, 0.4),
      GlyphVertex(8.75, 18.5),
    ], role: GlyphRole.line),
  ], matchTextDirection: true);

  static const chevronDown = Glyph([
    GlyphPolyline([
      GlyphVertex(5.5, 8.75),
      GlyphVertex(12, 15.25, 0.4),
      GlyphVertex(18.5, 8.75),
    ], role: GlyphRole.line),
  ]);

  static const chevronUp = Glyph([
    GlyphPolyline([
      GlyphVertex(5.5, 15.25),
      GlyphVertex(12, 8.75, 0.4),
      GlyphVertex(18.5, 15.25),
    ], role: GlyphRole.line),
  ]);

  static const caretDown = Glyph([
    GlyphPolyline([
      GlyphVertex(5.2, 8, 1),
      GlyphVertex(18.8, 8, 1),
      GlyphVertex(12, 16, 1),
    ], closed: true),
  ]);

  static const arrowUp = Glyph([
    GlyphPolyline([
      GlyphVertex(12, 5),
      GlyphVertex(12, 19),
    ], role: GlyphRole.line),
    GlyphPolyline([
      GlyphVertex(5.5, 11.5),
      GlyphVertex(12, 5, 0.4),
      GlyphVertex(18.5, 11.5),
    ], role: GlyphRole.line),
  ]);

  static const arrowDown = Glyph([
    GlyphPolyline([
      GlyphVertex(12, 5),
      GlyphVertex(12, 19),
    ], role: GlyphRole.line),
    GlyphPolyline([
      GlyphVertex(5.5, 12.5),
      GlyphVertex(12, 19, 0.4),
      GlyphVertex(18.5, 12.5),
    ], role: GlyphRole.line),
  ]);

  static const scrollToTop = Glyph([
    GlyphPolyline([
      GlyphVertex(5, 4),
      GlyphVertex(19, 4),
    ], role: GlyphRole.line),
    GlyphPolyline([
      GlyphVertex(12, 8.6),
      GlyphVertex(12, 20),
    ], role: GlyphRole.line),
    GlyphPolyline([
      GlyphVertex(8.2, 12.4),
      GlyphVertex(12, 8.6, 0.4),
      GlyphVertex(15.8, 12.4),
    ], role: GlyphRole.line),
  ]);

  static const openExternal = Glyph([
    GlyphBox(3, 3, 21, 21, 3),
    GlyphPolyline([
      GlyphVertex(7.6, 16.4),
      GlyphVertex(16.4, 7.6),
    ], role: GlyphRole.detail),
    GlyphPolyline([
      GlyphVertex(11, 7.6),
      GlyphVertex(16.4, 7.6, 0.4),
      GlyphVertex(16.4, 13),
    ], role: GlyphRole.detail),
  ]);

  static const undo = Glyph([
    GlyphPolyline([
      GlyphVertex(5, 9),
      GlyphVertex(19, 9, 4.8),
      GlyphVertex(19, 18.6, 4.8),
      GlyphVertex(9, 18.6),
    ], role: GlyphRole.line),
    GlyphPolyline([
      GlyphVertex(8.8, 5.2),
      GlyphVertex(5, 9, 0.4),
      GlyphVertex(8.8, 12.8),
    ], role: GlyphRole.line),
  ], matchTextDirection: true);

  static const redo = Glyph([
    GlyphPolyline([
      GlyphVertex(19, 9),
      GlyphVertex(5, 9, 4.8),
      GlyphVertex(5, 18.6, 4.8),
      GlyphVertex(15, 18.6),
    ], role: GlyphRole.line),
    GlyphPolyline([
      GlyphVertex(15.2, 5.2),
      GlyphVertex(19, 9, 0.4),
      GlyphVertex(15.2, 12.8),
    ], role: GlyphRole.line),
  ], matchTextDirection: true);

  static const sync = Glyph([
    GlyphArc(12, 12, 7.07, math.pi * 1.1, math.pi * 0.65, role: GlyphRole.line),
    GlyphPolyline([
      GlyphVertex(17, 7),
      GlyphVertex(18.5, 8.5),
    ], role: GlyphRole.line),
    GlyphPolyline([
      GlyphVertex(18.5, 3.1),
      GlyphVertex(18.5, 8.5, 0.4),
      GlyphVertex(13.1, 8.5),
    ], role: GlyphRole.line),
    GlyphArc(12, 12, 7.07, math.pi * 0.1, math.pi * 0.65, role: GlyphRole.line),
    GlyphPolyline([
      GlyphVertex(7, 17),
      GlyphVertex(5.5, 15.5),
    ], role: GlyphRole.line),
    GlyphPolyline([
      GlyphVertex(5.5, 20.9),
      GlyphVertex(5.5, 15.5, 0.4),
      GlyphVertex(10.9, 15.5),
    ], role: GlyphRole.line),
  ]);

  static const refresh = Glyph([
    GlyphArc(12, 13, 7.07, math.pi * 0.1, math.pi * 1.57, role: GlyphRole.line),
    GlyphPolyline([
      GlyphVertex(18.5, 4.1),
      GlyphVertex(18.5, 9.5, 0.4),
      GlyphVertex(13.1, 9.5),
    ], closed: true),
  ]);

  static const reset = Glyph([
    GlyphArc(
      12,
      13.77,
      7.07,
      math.pi * 1.15,
      math.pi * -1.65,
      role: GlyphRole.line,
    ),
    GlyphPolyline([
      GlyphVertex(12, 6.7),
      GlyphVertex(9.9, 6.7),
    ], role: GlyphRole.line),
    GlyphPolyline([
      GlyphVertex(13.7, 10.5),
      GlyphVertex(9.9, 6.7, 0.4),
      GlyphVertex(13.7, 2.9),
    ], role: GlyphRole.line),
  ]);

  static const export = Glyph([
    GlyphPolyline([
      GlyphVertex(8.4, 10.5),
      GlyphVertex(5, 10.5, 1.5),
      GlyphVertex(5, 21, 2.8),
      GlyphVertex(19, 21, 2.8),
      GlyphVertex(19, 10.5, 1.5),
      GlyphVertex(15.6, 10.5),
    ], role: GlyphRole.line),
    GlyphPolyline([
      GlyphVertex(12, 15.6),
      GlyphVertex(12, 3),
    ], role: GlyphRole.line),
    GlyphPolyline([
      GlyphVertex(8.2, 6.8),
      GlyphVertex(12, 3, 0.4),
      GlyphVertex(15.8, 6.8),
    ], role: GlyphRole.line),
  ]);

  static const upload = Glyph([
    GlyphPolyline([
      GlyphVertex(4.5, 16.4),
      GlyphVertex(4.5, 20, 2.2),
      GlyphVertex(19.5, 20, 2.2),
      GlyphVertex(19.5, 16.4),
    ], role: GlyphRole.line),
    GlyphPolyline([
      GlyphVertex(12, 15.4),
      GlyphVertex(12, 3.5),
    ], role: GlyphRole.line),
    GlyphPolyline([
      GlyphVertex(8.2, 7.3),
      GlyphVertex(12, 3.5, 0.4),
      GlyphVertex(15.8, 7.3),
    ], role: GlyphRole.line),
  ]);

  static const add = Glyph([
    GlyphPolyline([
      GlyphVertex(12, 5),
      GlyphVertex(12, 19),
    ], role: GlyphRole.line),
    GlyphPolyline([
      GlyphVertex(5, 12),
      GlyphVertex(19, 12),
    ], role: GlyphRole.line),
  ]);

  static const addCircle = Glyph([
    GlyphCircle(12, 12, 8.8),
    GlyphPolyline([
      GlyphVertex(12, 7.8),
      GlyphVertex(12, 16.2),
    ], role: GlyphRole.detail),
    GlyphPolyline([
      GlyphVertex(7.8, 12),
      GlyphVertex(16.2, 12),
    ], role: GlyphRole.detail),
  ]);

  static const remove = Glyph([
    GlyphPolyline([
      GlyphVertex(5, 12),
      GlyphVertex(19, 12),
    ], role: GlyphRole.line),
  ]);

  static const close = Glyph([
    GlyphPolyline([
      GlyphVertex(6, 6),
      GlyphVertex(18, 18),
    ], role: GlyphRole.line),
    GlyphPolyline([
      GlyphVertex(18, 6),
      GlyphVertex(6, 18),
    ], role: GlyphRole.line),
  ]);

  static const check = Glyph([
    GlyphPolyline([
      GlyphVertex(4.8, 12.5),
      GlyphVertex(9.6, 17.3),
      GlyphVertex(19.4, 6.7),
    ], role: GlyphRole.line),
  ]);

  static const checkDouble = Glyph([
    GlyphPolyline([
      GlyphVertex(2.9, 12.5),
      GlyphVertex(6.7, 16.3),
      GlyphVertex(14.45, 7.9),
    ], role: GlyphRole.line),
    GlyphPolyline([
      GlyphVertex(11.8, 16.3),
      GlyphVertex(13.2, 17.7),
      GlyphVertex(20.95, 9.3),
    ], role: GlyphRole.line),
  ]);

  static const checkCircle = Glyph([
    GlyphCircle(12, 12, 8.8),
    GlyphPolyline([
      GlyphVertex(7.59, 12.3),
      GlyphVertex(10.49, 15.2),
      GlyphVertex(16.41, 8.79),
    ], role: GlyphRole.detail),
  ]);

  static const block = Glyph([
    GlyphCircle(12, 12, 8.8, role: GlyphRole.line),
    GlyphPolyline([
      GlyphVertex(5.78, 5.78),
      GlyphVertex(18.22, 18.22),
    ], role: GlyphRole.line),
  ]);

  static const info = Glyph([
    GlyphCircle(12, 12, 8.8),
    GlyphCircle(12, 7.5, 1.4, role: GlyphRole.detail, solid: true),
    GlyphPolyline([
      GlyphVertex(12, 11.8),
      GlyphVertex(12, 16.7),
    ], role: GlyphRole.detail),
  ]);

  static const warning = Glyph([
    GlyphPolyline([
      GlyphVertex(12, 1.6, 3),
      GlyphVertex(21.9, 20.3, 2.5),
      GlyphVertex(2.1, 20.3, 2.5),
    ], closed: true),
    GlyphPolyline([
      GlyphVertex(12, 9),
      GlyphVertex(12, 12.1),
    ], role: GlyphRole.detail),
    GlyphCircle(12, 16.2, 1.4, role: GlyphRole.detail, solid: true),
  ]);

  static const error = Glyph([
    GlyphCircle(12, 12, 8.8),
    GlyphPolyline([
      GlyphVertex(12, 7.3),
      GlyphVertex(12, 12.2),
    ], role: GlyphRole.detail),
    GlyphCircle(12, 16.5, 1.4, role: GlyphRole.detail, solid: true),
  ]);

  static const more = Glyph([
    GlyphCircle(12, 5.5, 1.4, role: GlyphRole.line, solid: true),
    GlyphCircle(12, 12, 1.4, role: GlyphRole.line, solid: true),
    GlyphCircle(12, 18.5, 1.4, role: GlyphRole.line, solid: true),
  ]);

  static const moreCircle = Glyph([
    GlyphCircle(12, 12, 8.8),
    GlyphCircle(7.4, 12, 1.4, role: GlyphRole.detail, solid: true),
    GlyphCircle(12, 12, 1.4, role: GlyphRole.detail, solid: true),
    GlyphCircle(16.6, 12, 1.4, role: GlyphRole.detail, solid: true),
  ]);

  static const dragHandle = Glyph([
    GlyphPolyline([
      GlyphVertex(4, 7),
      GlyphVertex(20, 7),
    ], role: GlyphRole.line),
    GlyphPolyline([
      GlyphVertex(4, 12),
      GlyphVertex(20, 12),
    ], role: GlyphRole.line),
    GlyphPolyline([
      GlyphVertex(4, 17),
      GlyphVertex(20, 17),
    ], role: GlyphRole.line),
  ]);

  static const sort = Glyph([
    GlyphPolyline([
      GlyphVertex(4, 7),
      GlyphVertex(20, 7),
    ], role: GlyphRole.line),
    GlyphPolyline([
      GlyphVertex(4, 12),
      GlyphVertex(15, 12),
    ], role: GlyphRole.line),
    GlyphPolyline([
      GlyphVertex(4, 17),
      GlyphVertex(10, 17),
    ], role: GlyphRole.line),
  ], matchTextDirection: true);

  static const sortAlpha = Glyph([
    GlyphPolyline([
      GlyphVertex(3.2, 10),
      GlyphVertex(7.2, 3.2, 1),
      GlyphVertex(11.2, 10),
    ], role: GlyphRole.line),
    GlyphPolyline([
      GlyphVertex(4.49, 7.8),
      GlyphVertex(9.91, 7.8),
    ], role: GlyphRole.line),
    GlyphPolyline([
      GlyphVertex(3.6, 13.8),
      GlyphVertex(10.8, 13.8, 0.6),
      GlyphVertex(3.6, 20.8, 0.6),
      GlyphVertex(10.8, 20.8),
    ], role: GlyphRole.line),
    GlyphPolyline([
      GlyphVertex(17.8, 3.4),
      GlyphVertex(17.8, 20.6),
    ], role: GlyphRole.line),
    GlyphPolyline([
      GlyphVertex(14.8, 17.6),
      GlyphVertex(17.8, 20.6, 0.4),
      GlyphVertex(20.8, 17.6),
    ], role: GlyphRole.line),
  ]);

  static const textShort = Glyph([
    GlyphPolyline([
      GlyphVertex(4, 9),
      GlyphVertex(20, 9),
    ], role: GlyphRole.line),
    GlyphPolyline([
      GlyphVertex(4, 15),
      GlyphVertex(13, 15),
    ], role: GlyphRole.line),
  ], matchTextDirection: true);

  static const wrap = Glyph([
    GlyphPolyline([
      GlyphVertex(4, 6),
      GlyphVertex(20, 6),
    ], role: GlyphRole.line),
    GlyphPolyline([
      GlyphVertex(4, 12),
      GlyphVertex(20, 12, 3),
      GlyphVertex(20, 18, 3),
      GlyphVertex(11, 18),
    ], role: GlyphRole.line),
    GlyphPolyline([
      GlyphVertex(13.8, 15.2),
      GlyphVertex(11, 18, 0.4),
      GlyphVertex(13.8, 20.8),
    ], role: GlyphRole.line),
    GlyphPolyline([
      GlyphVertex(4, 18),
      GlyphVertex(6.5, 18),
    ], role: GlyphRole.line),
  ], matchTextDirection: true);

  static const listAdd = Glyph([
    GlyphPolyline([
      GlyphVertex(4, 4.4),
      GlyphVertex(20, 4.4),
    ], role: GlyphRole.line),
    GlyphPolyline([
      GlyphVertex(4, 9.2),
      GlyphVertex(20, 9.2),
    ], role: GlyphRole.line),
    GlyphPolyline([
      GlyphVertex(4, 14),
      GlyphVertex(10, 14),
    ], role: GlyphRole.line),
    GlyphPolyline([
      GlyphVertex(17, 13.4),
      GlyphVertex(17, 20.2),
    ], role: GlyphRole.line),
    GlyphPolyline([
      GlyphVertex(13.6, 16.8),
      GlyphVertex(20.4, 16.8),
    ], role: GlyphRole.line),
  ], matchTextDirection: true);

  static const edit = Glyph([
    GlyphPolyline([
      GlyphVertex(4, 20, 1),
      GlyphVertex(8.75, 18.75, 1),
      GlyphVertex(20.25, 7.25, 1.5),
      GlyphVertex(16.75, 3.75, 1.5),
      GlyphVertex(5.25, 15.25, 1),
    ], closed: true),
    GlyphPolyline([
      GlyphVertex(13.25, 7.25),
      GlyphVertex(16.75, 10.75),
    ], role: GlyphRole.detail),
  ]);

  static const compose = Glyph([
    GlyphPolyline([
      GlyphVertex(9.4, 6.2),
      GlyphVertex(4, 6.2, 2.5),
      GlyphVertex(4, 20.2, 2.5),
      GlyphVertex(18, 20.2, 2.5),
      GlyphVertex(18, 14.8),
    ], role: GlyphRole.line),
    GlyphPolyline([
      GlyphVertex(9, 15.2, 1),
      GlyphVertex(13.75, 13.95, 1),
      GlyphVertex(20.75, 6.95, 1.5),
      GlyphVertex(17.25, 3.45, 1.5),
      GlyphVertex(10.25, 10.45, 1),
    ], closed: true),
    GlyphPolyline([
      GlyphVertex(13.75, 6.95),
      GlyphVertex(17.25, 10.45),
    ], role: GlyphRole.detail),
  ]);

  static const delete = Glyph([
    GlyphPolyline([
      GlyphVertex(5.8, 6.8),
      GlyphVertex(18.2, 6.8),
      GlyphVertex(17.2, 21, 2.5),
      GlyphVertex(6.8, 21, 2.5),
    ], closed: true),
    GlyphPolyline([
      GlyphVertex(10, 10.5),
      GlyphVertex(10, 17.5),
    ], role: GlyphRole.detail),
    GlyphPolyline([
      GlyphVertex(14, 10.5),
      GlyphVertex(14, 17.5),
    ], role: GlyphRole.detail),
    GlyphPolyline([
      GlyphVertex(3.8, 6.8),
      GlyphVertex(20.2, 6.8),
    ], role: GlyphRole.line),
    GlyphPolyline([
      GlyphVertex(9, 6.8),
      GlyphVertex(9, 3.2, 1.4),
      GlyphVertex(15, 3.2, 1.4),
      GlyphVertex(15, 6.8),
    ], role: GlyphRole.line),
  ]);

  static const clearAll = Glyph([
    GlyphPolyline([
      GlyphVertex(4.24, 8.6),
      GlyphVertex(13.16, 8.6),
      GlyphVertex(12.44, 18.8, 1.8),
      GlyphVertex(4.96, 18.8, 1.8),
    ], closed: true),
    GlyphPolyline([
      GlyphVertex(8.7, 12),
      GlyphVertex(8.7, 15.3),
    ], role: GlyphRole.detail),
    GlyphPolyline([
      GlyphVertex(3, 8.6),
      GlyphVertex(14.4, 8.6),
    ], role: GlyphRole.line),
    GlyphPolyline([
      GlyphVertex(6.2, 8.6),
      GlyphVertex(6.2, 5, 1.4),
      GlyphVertex(11.2, 5, 1.4),
      GlyphVertex(11.2, 8.6),
    ], role: GlyphRole.line),
    GlyphPolyline([
      GlyphVertex(17, 11.2),
      GlyphVertex(21, 11.2),
    ], role: GlyphRole.line),
    GlyphPolyline([
      GlyphVertex(17, 14.9),
      GlyphVertex(20.4, 14.9),
    ], role: GlyphRole.line),
    GlyphPolyline([
      GlyphVertex(17, 18.6),
      GlyphVertex(19.8, 18.6),
    ], role: GlyphRole.line),
  ]);

  static const copy = Glyph([
    GlyphBox(8.5, 7.5, 20.5, 21, 2.5),
    GlyphPolyline([
      GlyphVertex(4, 16.5),
      GlyphVertex(4, 3, 2.5),
      GlyphVertex(16, 3),
    ], role: GlyphRole.line),
  ]);

  static const cut = Glyph([
    GlyphCircle(7, 17.5, 3),
    GlyphCircle(17, 17.5, 3),
    GlyphPolyline([
      GlyphVertex(9.64, 13.73),
      GlyphVertex(16.8, 3.5),
    ], role: GlyphRole.line),
    GlyphPolyline([
      GlyphVertex(14.36, 13.73),
      GlyphVertex(7.2, 3.5),
    ], role: GlyphRole.line),
  ]);

  static const paste = Glyph([
    GlyphPolyline([
      GlyphVertex(4.5, 5.2, 2.5),
      GlyphVertex(8.5, 5.2),
      GlyphVertex(8.5, 2.9, 1),
      GlyphVertex(15.5, 2.9, 1),
      GlyphVertex(15.5, 5.2),
      GlyphVertex(19.5, 5.2, 2.5),
      GlyphVertex(19.5, 21, 2.5),
      GlyphVertex(4.5, 21, 2.5),
    ], closed: true),
    GlyphPolyline([
      GlyphVertex(8.5, 5.2),
      GlyphVertex(8.5, 7.3, 1),
      GlyphVertex(15.5, 7.3, 1),
      GlyphVertex(15.5, 5.2),
    ], role: GlyphRole.detail),
  ]);

  static const selectAll = Glyph([
    GlyphPolyline([
      GlyphVertex(3.5, 7),
      GlyphVertex(3.5, 3.5, 2.5),
      GlyphVertex(7, 3.5),
    ], role: GlyphRole.line),
    GlyphPolyline([
      GlyphVertex(20.5, 7),
      GlyphVertex(20.5, 3.5, 2.5),
      GlyphVertex(17, 3.5),
    ], role: GlyphRole.line),
    GlyphPolyline([
      GlyphVertex(20.5, 17),
      GlyphVertex(20.5, 20.5, 2.5),
      GlyphVertex(17, 20.5),
    ], role: GlyphRole.line),
    GlyphPolyline([
      GlyphVertex(3.5, 17),
      GlyphVertex(3.5, 20.5, 2.5),
      GlyphVertex(7, 20.5),
    ], role: GlyphRole.line),
    GlyphPolyline([
      GlyphVertex(10.6, 3.5),
      GlyphVertex(13.4, 3.5),
    ], role: GlyphRole.line),
    GlyphPolyline([
      GlyphVertex(20.5, 10.6),
      GlyphVertex(20.5, 13.4),
    ], role: GlyphRole.line),
    GlyphPolyline([
      GlyphVertex(13.4, 20.5),
      GlyphVertex(10.6, 20.5),
    ], role: GlyphRole.line),
    GlyphPolyline([
      GlyphVertex(3.5, 13.4),
      GlyphVertex(3.5, 10.6),
    ], role: GlyphRole.line),
    GlyphPolyline([
      GlyphVertex(8, 12.3),
      GlyphVertex(10.8, 15.1, 0.4),
      GlyphVertex(16, 9.2),
    ], role: GlyphRole.line),
  ]);

  static const deselect = Glyph([
    GlyphPolyline([
      GlyphVertex(3.5, 7),
      GlyphVertex(3.5, 3.5, 2.5),
      GlyphVertex(7, 3.5),
    ], role: GlyphRole.line),
    GlyphPolyline([
      GlyphVertex(20.5, 7),
      GlyphVertex(20.5, 3.5, 2.5),
      GlyphVertex(17, 3.5),
    ], role: GlyphRole.line),
    GlyphPolyline([
      GlyphVertex(20.5, 17),
      GlyphVertex(20.5, 20.5, 2.5),
      GlyphVertex(17, 20.5),
    ], role: GlyphRole.line),
    GlyphPolyline([
      GlyphVertex(3.5, 17),
      GlyphVertex(3.5, 20.5, 2.5),
      GlyphVertex(7, 20.5),
    ], role: GlyphRole.line),
    GlyphPolyline([
      GlyphVertex(10.6, 3.5),
      GlyphVertex(13.4, 3.5),
    ], role: GlyphRole.line),
    GlyphPolyline([
      GlyphVertex(20.5, 10.6),
      GlyphVertex(20.5, 13.4),
    ], role: GlyphRole.line),
    GlyphPolyline([
      GlyphVertex(13.4, 20.5),
      GlyphVertex(10.6, 20.5),
    ], role: GlyphRole.line),
    GlyphPolyline([
      GlyphVertex(3.5, 13.4),
      GlyphVertex(3.5, 10.6),
    ], role: GlyphRole.line),
    GlyphPolyline([
      GlyphVertex(8, 8),
      GlyphVertex(16, 16),
    ], role: GlyphRole.line),
  ]);

  static const search = Glyph([
    GlyphCircle(10.3, 10.3, 6.9, role: GlyphRole.line),
    GlyphPolyline([
      GlyphVertex(15.18, 15.18),
      GlyphVertex(20.6, 20.6),
    ], role: GlyphRole.line),
  ]);

  static const findReplace = Glyph([
    GlyphArc(
      9.9,
      9.9,
      6.3,
      math.pi * 1.1,
      math.pi * 0.65,
      role: GlyphRole.line,
    ),
    GlyphPolyline([
      GlyphVertex(14.35, 5.45),
      GlyphVertex(15.34, 6.44),
    ], role: GlyphRole.line),
    GlyphPolyline([
      GlyphVertex(15.34, 3.04),
      GlyphVertex(15.34, 6.44, 0.4),
      GlyphVertex(11.94, 6.44),
    ], role: GlyphRole.line),
    GlyphArc(
      9.9,
      9.9,
      6.3,
      math.pi * 0.1,
      math.pi * 0.65,
      role: GlyphRole.line,
    ),
    GlyphPolyline([
      GlyphVertex(5.45, 14.35),
      GlyphVertex(4.46, 13.36),
    ], role: GlyphRole.line),
    GlyphPolyline([
      GlyphVertex(4.46, 16.76),
      GlyphVertex(4.46, 13.36, 0.4),
      GlyphVertex(7.86, 13.36),
    ], role: GlyphRole.line),
    GlyphPolyline([
      GlyphVertex(14.35, 14.35),
      GlyphVertex(20.3, 20.3),
    ], role: GlyphRole.line),
  ]);

  static const save = Glyph([
    GlyphPolyline([
      GlyphVertex(4.5, 4.5, 2.2),
      GlyphVertex(15.5, 4.5, 1),
      GlyphVertex(19.5, 8.5, 1),
      GlyphVertex(19.5, 19.5, 2.2),
      GlyphVertex(4.5, 19.5, 2.2),
    ], closed: true),
    GlyphPolyline([
      GlyphVertex(8, 4.5),
      GlyphVertex(8, 8.8, 1),
      GlyphVertex(13.3, 8.8, 1),
      GlyphVertex(13.3, 4.5),
    ], role: GlyphRole.detail),
    GlyphPolyline([
      GlyphVertex(7.6, 19.5),
      GlyphVertex(7.6, 13.8, 1.3),
      GlyphVertex(16.4, 13.8, 1.3),
      GlyphVertex(16.4, 19.5),
    ], role: GlyphRole.detail),
  ]);

  static const importFile = Glyph([
    GlyphPolyline([
      GlyphVertex(5, 3, 2.5),
      GlyphVertex(13.5, 3, 1),
      GlyphVertex(19, 8.5, 1),
      GlyphVertex(19, 21, 2.5),
      GlyphVertex(5, 21, 2.5),
    ], closed: true),
    GlyphPolyline([
      GlyphVertex(13.5, 3.2),
      GlyphVertex(13.5, 8.5, 1.5),
      GlyphVertex(18.8, 8.5),
    ], role: GlyphRole.detail),
    GlyphPolyline([
      GlyphVertex(12, 17.6),
      GlyphVertex(12, 11.4),
    ], role: GlyphRole.detail),
    GlyphPolyline([
      GlyphVertex(9, 14.4),
      GlyphVertex(12, 11.4, 0.4),
      GlyphVertex(15, 14.4),
    ], role: GlyphRole.detail),
  ]);

  static const cloudDownload = Glyph([
    GlyphPath(
      'M7 19.4A4.2 4.2 0 0 1 5.06 11.47A6 6 0 1 1 16.95 9.83A4.8 4.8 0 0 1 16.4 19.4Z',
    ),
    GlyphPolyline([
      GlyphVertex(12, 8.4),
      GlyphVertex(12, 16),
    ], role: GlyphRole.detail),
    GlyphPolyline([
      GlyphVertex(9, 13),
      GlyphVertex(12, 16, 0.4),
      GlyphVertex(15, 13),
    ], role: GlyphRole.detail),
  ]);

  static const cloudSync = Glyph([
    GlyphPath(
      'M7 19.4A4.2 4.2 0 0 1 5.06 11.47A6 6 0 1 1 16.95 9.83A4.8 4.8 0 0 1 16.4 19.4Z',
    ),
    GlyphArc(
      11,
      13.2,
      3,
      math.pi * 0.1944,
      math.pi * 1.5,
      role: GlyphRole.detail,
    ),
    GlyphPolyline([
      GlyphVertex(12.72, 10.74),
      GlyphVertex(13.46, 11.26),
    ], role: GlyphRole.detail),
    GlyphPolyline([
      GlyphVertex(13.01, 8.7),
      GlyphVertex(13.46, 11.26, 0.4),
      GlyphVertex(10.9, 11.71),
    ], role: GlyphRole.detail),
  ]);

  static const link = Glyph([
    GlyphPath(
      'M11.01 8.46L14.55 4.93A3.2 3.2 0 0 1 19.07 9.45L15.54 12.99',
      role: GlyphRole.line,
    ),
    GlyphPath(
      'M12.99 15.54L9.45 19.07A3.2 3.2 0 0 1 4.93 14.55L8.46 11.01',
      role: GlyphRole.line,
    ),
    GlyphPolyline([
      GlyphVertex(9.17, 14.83),
      GlyphVertex(14.83, 9.17),
    ], role: GlyphRole.line),
  ]);

  static const send = Glyph([
    GlyphPolyline([
      GlyphVertex(3.2, 10.8, 1),
      GlyphVertex(20.6, 3.4, 1),
      GlyphVertex(13.2, 20.8, 1),
      GlyphVertex(10.6, 13.4, 0.6),
    ], closed: true),
    GlyphPolyline([
      GlyphVertex(10.6, 13.4),
      GlyphVertex(15.2, 8.8),
    ], role: GlyphRole.detail),
  ]);

  static const rules = Glyph([
    GlyphBox(3, 4, 21, 20, 3),
    GlyphCircle(7, 8, 1.1, role: GlyphRole.detail, solid: true),
    GlyphPolyline([
      GlyphVertex(10.8, 8),
      GlyphVertex(17.2, 8),
    ], role: GlyphRole.detail),
    GlyphCircle(7, 12, 1.1, role: GlyphRole.detail, solid: true),
    GlyphPolyline([
      GlyphVertex(10.8, 12),
      GlyphVertex(17.2, 12),
    ], role: GlyphRole.detail),
    GlyphCircle(7, 16, 1.1, role: GlyphRole.detail, solid: true),
    GlyphPolyline([
      GlyphVertex(10.8, 16),
      GlyphVertex(17.2, 16),
    ], role: GlyphRole.detail),
  ], matchTextDirection: true);

  static const code = Glyph([
    GlyphPolyline([
      GlyphVertex(7.5, 7.5),
      GlyphVertex(3, 12, 0.5),
      GlyphVertex(7.5, 16.5),
    ], role: GlyphRole.line),
    GlyphPolyline([
      GlyphVertex(16.5, 7.5),
      GlyphVertex(21, 12, 0.5),
      GlyphVertex(16.5, 16.5),
    ], role: GlyphRole.line),
    GlyphPolyline([
      GlyphVertex(13.8, 5),
      GlyphVertex(10.2, 19),
    ], role: GlyphRole.line),
  ]);

  static const settings = Glyph([
    GlyphPolyline([
      GlyphVertex(9.87, 5.44, 0.6),
      GlyphVertex(10.09, 3, 0.9),
      GlyphVertex(13.91, 3, 0.9),
      GlyphVertex(14.13, 5.44, 0.6),
      GlyphVertex(16.62, 6.87, 0.6),
      GlyphVertex(18.84, 5.84, 0.9),
      GlyphVertex(20.75, 9.16, 0.9),
      GlyphVertex(18.75, 10.57, 0.6),
      GlyphVertex(18.75, 13.43, 0.6),
      GlyphVertex(20.75, 14.84, 0.9),
      GlyphVertex(18.84, 18.16, 0.9),
      GlyphVertex(16.62, 17.13, 0.6),
      GlyphVertex(14.13, 18.56, 0.6),
      GlyphVertex(13.91, 21, 0.9),
      GlyphVertex(10.09, 21, 0.9),
      GlyphVertex(9.87, 18.56, 0.6),
      GlyphVertex(7.38, 17.13, 0.6),
      GlyphVertex(5.16, 18.16, 0.9),
      GlyphVertex(3.25, 14.84, 0.9),
      GlyphVertex(5.25, 13.43, 0.6),
      GlyphVertex(5.25, 10.57, 0.6),
      GlyphVertex(3.25, 9.16, 0.9),
      GlyphVertex(5.16, 5.84, 0.9),
      GlyphVertex(7.38, 6.87, 0.6),
    ], closed: true),
    GlyphCircle(12, 12, 3, role: GlyphRole.detail),
  ]);

  static const sliders = Glyph([
    GlyphPolyline([
      GlyphVertex(3.2, 5.5),
      GlyphVertex(10.4, 5.5),
    ], role: GlyphRole.line),
    GlyphPolyline([
      GlyphVertex(18.6, 5.5),
      GlyphVertex(20.8, 5.5),
    ], role: GlyphRole.line),
    GlyphCircle(14.5, 5.5, 2.5),
    GlyphPolyline([
      GlyphVertex(3.2, 12),
      GlyphVertex(4.4, 12),
    ], role: GlyphRole.line),
    GlyphPolyline([
      GlyphVertex(12.6, 12),
      GlyphVertex(20.8, 12),
    ], role: GlyphRole.line),
    GlyphCircle(8.5, 12, 2.5),
    GlyphPolyline([
      GlyphVertex(3.2, 18.5),
      GlyphVertex(11.4, 18.5),
    ], role: GlyphRole.line),
    GlyphPolyline([
      GlyphVertex(19.6, 18.5),
      GlyphVertex(20.8, 18.5),
    ], role: GlyphRole.line),
    GlyphCircle(15.5, 18.5, 2.5),
  ]);

  static const wrench = Glyph([
    GlyphPath(
      'M3.58 17.59L10.1 11.07A1.2 1.2 0 0 0 10.41 9.89'
      'A5.4 5.4 0 0 1 16.36 3.05A0.9 0.9 0 0 1 16.87 4.58L14.04 7.41'
      'A1.8 1.8 0 0 0 16.59 9.96L19.42 7.13A0.9 0.9 0 0 1 20.95 7.64'
      'A5.4 5.4 0 0 1 14.11 13.59A1.2 1.2 0 0 0 12.93 13.9L6.41 20.42'
      'A2 2 0 0 1 3.58 17.59Z',
    ),
  ]);

  static const toggle = Glyph([
    GlyphBox(2.9, 6.5, 21.1, 17.5, 5.5),
    GlyphCircle(8.4, 12, 2.8, role: GlyphRole.detail, solid: true),
  ]);

  static const pin = Glyph([
    GlyphPolyline([
      GlyphVertex(15.42, 3.5, 1.5),
      GlyphVertex(20.5, 8.58, 1.5),
      GlyphVertex(15.73, 13.35, 1.4),
      GlyphVertex(14.94, 19.55, 1),
      GlyphVertex(4.45, 9.06, 1),
      GlyphVertex(10.65, 8.27, 1.4),
    ], closed: true),
    GlyphPolyline([
      GlyphVertex(9.7, 14.3),
      GlyphVertex(3.5, 20.5),
    ], role: GlyphRole.line),
  ]);

  static const eye = Glyph([
    GlyphPath(
      'M3.01 11.32A10.08 10.08 0 0 1 20.99 11.32A1.5 1.5 0 0 1 20.99 12.68'
      'A10.08 10.08 0 0 1 3.01 12.68A1.5 1.5 0 0 1 3.01 11.32Z',
    ),
    GlyphCircle(12, 12, 2.8, role: GlyphRole.detail),
  ]);

  static const eyeOff = Glyph([
    GlyphPath(
      'M10.95 5.86A10.08 10.08 0 0 1 20.99 11.32A1.5 1.5 0 0 1 20.99 12.68'
      'A10.08 10.08 0 0 1 19.71 14.62',
      role: GlyphRole.line,
    ),
    GlyphPath(
      'M16.92 16.92A10.08 10.08 0 0 1 3.01 12.68A1.5 1.5 0 0 1 3.01 11.32'
      'A10.08 10.08 0 0 1 7.08 7.08',
      role: GlyphRole.line,
    ),
    GlyphArc(12, 12, 2.8, math.pi * 0.25, math.pi, role: GlyphRole.line),
    GlyphPolyline([
      GlyphVertex(4, 4),
      GlyphVertex(20, 20),
    ], role: GlyphRole.line),
  ]);

  static const lock = Glyph([
    GlyphBox(5, 10.5, 19, 20.8, 2.5),
    GlyphPath('M8.5 10.5V7A3.5 3.5 0 0 1 15.5 7V10.5', role: GlyphRole.line),
    GlyphPolyline([
      GlyphVertex(12, 14.4),
      GlyphVertex(12, 17),
    ], role: GlyphRole.detail),
  ]);

  static const lockOpen = Glyph([
    GlyphBox(5, 10.5, 19, 20.8, 2.5),
    GlyphPath('M8.5 10.5V7A3.5 3.5 0 0 1 15.5 7', role: GlyphRole.line),
    GlyphPolyline([
      GlyphVertex(12, 14.4),
      GlyphVertex(12, 17),
    ], role: GlyphRole.detail),
  ]);

  static const key = Glyph([
    GlyphCircle(9.27, 7.99, 5),
    GlyphCircle(9.27, 7.99, 1.4, role: GlyphRole.detail, solid: true),
    GlyphPolyline([
      GlyphVertex(12.8, 11.53),
      GlyphVertex(19.73, 18.46, 0.8),
      GlyphVertex(17.19, 21.01),
    ], role: GlyphRole.line),
    GlyphPolyline([
      GlyphVertex(17.19, 15.91),
      GlyphVertex(15.07, 18.04),
    ], role: GlyphRole.line),
  ]);

  static const password = Glyph([
    GlyphBox(2.9, 6, 21.1, 18, 3),
    GlyphCircle(7.4, 12, 1.4, role: GlyphRole.detail, solid: true),
    GlyphCircle(12, 12, 1.4, role: GlyphRole.detail, solid: true),
    GlyphCircle(16.6, 12, 1.4, role: GlyphRole.detail, solid: true),
  ]);

  static const account = Glyph([
    GlyphCircle(12, 12, 8.8),
    GlyphCircle(12, 9.4, 2.8, role: GlyphRole.detail),
    GlyphArc(
      12,
      22.6,
      7,
      math.pi * -0.8087,
      math.pi * 0.6173,
      role: GlyphRole.detail,
    ),
  ]);

  static const sparkle = Glyph([
    GlyphPolyline([
      GlyphVertex(10, 6.4, 0.9),
      GlyphVertex(11.48, 12.32, 3),
      GlyphVertex(17.4, 13.8, 0.9),
      GlyphVertex(11.48, 15.28, 3),
      GlyphVertex(10, 21.2, 0.9),
      GlyphVertex(8.52, 15.28, 3),
      GlyphVertex(2.6, 13.8, 0.9),
      GlyphVertex(8.52, 12.32, 3),
    ], closed: true),
    GlyphPolyline([
      GlyphVertex(17.8, 2.9, 0.6),
      GlyphVertex(18.58, 5.42, 1.2),
      GlyphVertex(21.1, 6.2, 0.6),
      GlyphVertex(18.58, 6.98, 1.2),
      GlyphVertex(17.8, 9.5, 0.6),
      GlyphVertex(17.02, 6.98, 1.2),
      GlyphVertex(14.5, 6.2, 0.6),
      GlyphVertex(17.02, 5.42, 1.2),
    ], closed: true),
  ]);

  static const bolt = Glyph([
    GlyphPolyline([
      GlyphVertex(14.5, 2.8, 1),
      GlyphVertex(5, 13.7, 1),
      GlyphVertex(11.2, 13.7, 0.6),
      GlyphVertex(9.5, 21.2, 1),
      GlyphVertex(19, 10.3, 1),
      GlyphVertex(12.8, 10.3, 0.6),
    ], closed: true),
  ]);

  static const locate = Glyph([
    GlyphCircle(12, 12, 6.2),
    GlyphCircle(12, 12, 1.8, role: GlyphRole.detail, solid: true),
    GlyphPolyline([
      GlyphVertex(12, 2.9),
      GlyphVertex(12, 5.8),
    ], role: GlyphRole.line),
    GlyphPolyline([
      GlyphVertex(12, 18.2),
      GlyphVertex(12, 21.1),
    ], role: GlyphRole.line),
    GlyphPolyline([
      GlyphVertex(2.9, 12),
      GlyphVertex(5.8, 12),
    ], role: GlyphRole.line),
    GlyphPolyline([
      GlyphVertex(18.2, 12),
      GlyphVertex(21.1, 12),
    ], role: GlyphRole.line),
  ]);

  static const star = Glyph([
    GlyphPolyline([
      GlyphVertex(12, 3.2, 1.2),
      GlyphVertex(14.41, 9.48, 0.6),
      GlyphVertex(21.13, 9.83, 1.2),
      GlyphVertex(15.9, 14.07, 0.6),
      GlyphVertex(17.64, 20.57, 1.2),
      GlyphVertex(12, 16.9, 0.6),
      GlyphVertex(6.36, 20.57, 1.2),
      GlyphVertex(8.1, 14.07, 0.6),
      GlyphVertex(2.87, 9.83, 1.2),
      GlyphVertex(9.59, 9.48, 0.6),
    ], closed: true),
  ]);

  static const puzzle = Glyph([
    GlyphPath(
      'M3 10A2.2 2.2 0 0 1 5.2 7.8H7.94A2.6 2.6 0 1 1 11.26 7.8H14'
      'A2.2 2.2 0 0 1 16.2 10V12.74A2.6 2.6 0 1 1 16.2 16.06V18.8'
      'A2.2 2.2 0 0 1 14 21H5.2A2.2 2.2 0 0 1 3 18.8V17.58'
      'A0.8 0.8 0 0 1 4.08 16.83A2.6 2.6 0 1 0 4.08 11.97'
      'A0.8 0.8 0 0 1 3 11.22Z',
    ),
  ]);

  static const customize = Glyph([
    GlyphBox(3.5, 3.5, 10.5, 10.5, 2),
    GlyphBox(3.5, 13.5, 10.5, 20.5, 2),
    GlyphBox(13.5, 13.5, 20.5, 20.5, 2),
    GlyphPolyline([
      GlyphVertex(17, 4),
      GlyphVertex(17, 10),
    ], role: GlyphRole.line),
    GlyphPolyline([
      GlyphVertex(14, 7),
      GlyphVertex(20, 7),
    ], role: GlyphRole.line),
  ]);

  static const layers = Glyph([
    GlyphPolyline([
      GlyphVertex(12, 3, 1.5),
      GlyphVertex(20.8, 7.6, 1.2),
      GlyphVertex(12, 12.2, 1.5),
      GlyphVertex(3.2, 7.6, 1.2),
    ], closed: true),
    GlyphPolyline([
      GlyphVertex(3.2, 12),
      GlyphVertex(12, 16.6, 1.5),
      GlyphVertex(20.8, 12),
    ], role: GlyphRole.line),
    GlyphPolyline([
      GlyphVertex(3.2, 16.4),
      GlyphVertex(12, 21, 1.5),
      GlyphVertex(20.8, 16.4),
    ], role: GlyphRole.line),
  ]);

  static const sun = Glyph([
    GlyphCircle(12, 12, 4),
    GlyphPolyline([
      GlyphVertex(12, 2.9),
      GlyphVertex(12, 4.4),
    ], role: GlyphRole.line),
    GlyphPolyline([
      GlyphVertex(12, 19.6),
      GlyphVertex(12, 21.1),
    ], role: GlyphRole.line),
    GlyphPolyline([
      GlyphVertex(2.9, 12),
      GlyphVertex(4.4, 12),
    ], role: GlyphRole.line),
    GlyphPolyline([
      GlyphVertex(19.6, 12),
      GlyphVertex(21.1, 12),
    ], role: GlyphRole.line),
    GlyphPolyline([
      GlyphVertex(5.57, 5.57),
      GlyphVertex(6.63, 6.63),
    ], role: GlyphRole.line),
    GlyphPolyline([
      GlyphVertex(18.43, 5.57),
      GlyphVertex(17.37, 6.63),
    ], role: GlyphRole.line),
    GlyphPolyline([
      GlyphVertex(5.57, 18.43),
      GlyphVertex(6.63, 17.37),
    ], role: GlyphRole.line),
    GlyphPolyline([
      GlyphVertex(18.43, 18.43),
      GlyphVertex(17.37, 17.37),
    ], role: GlyphRole.line),
  ]);

  static const moon = Glyph([
    GlyphPath(
      'M9.4 3.59A8.8 8.8 0 1 0 20.41 14.6A0.8 0.8 0 0 0 19.32 13.63A6.8 6.8 0 0 1 10.37 4.68A0.8 0.8 0 0 0 9.4 3.59Z',
    ),
  ]);

  static const themeAuto = Glyph([
    GlyphCircle(12, 12, 8.8),
    GlyphPath(
      'M12 3.2A8.8 8.8 0 0 0 12 20.8Z',
      role: GlyphRole.detail,
      solid: true,
    ),
  ]);

  static const pureBlack = Glyph([
    GlyphBox(3, 3.5, 21, 16.5, 2.5),
    GlyphPath(
      'M7 6H17A1.5 1.5 0 0 1 18.5 7.5V12.5A1.5 1.5 0 0 1 17 14H7A1.5 1.5 0 0 1 5.5 12.5V7.5A1.5 1.5 0 0 1 7 6Z',
      role: GlyphRole.detail,
      solid: true,
    ),
    GlyphPolyline([
      GlyphVertex(12, 16.5),
      GlyphVertex(12, 20.4),
    ], role: GlyphRole.line),
    GlyphPolyline([
      GlyphVertex(8, 20.4),
      GlyphVertex(16, 20.4),
    ], role: GlyphRole.line),
  ]);

  static const palette = Glyph([
    GlyphPath(
      'M20.59 13.9A8.8 8.8 0 1 0 13.9 20.59A1.2 1.2 0 0 0 14.83 19.28A4 4 0 0 1 19.28 14.83A1.2 1.2 0 0 0 20.59 13.9Z',
    ),
    GlyphCircle(7.54, 13.89, 1.4, role: GlyphRole.detail, solid: true),
    GlyphCircle(7.96, 9.32, 1.4, role: GlyphRole.detail, solid: true),
    GlyphCircle(12, 7.15, 1.4, role: GlyphRole.detail, solid: true),
    GlyphCircle(16.04, 9.32, 1.4, role: GlyphRole.detail, solid: true),
  ]);

  static const paintbrush = Glyph([
    GlyphPolyline([
      GlyphVertex(9.1, 10.51, 1.2),
      GlyphVertex(13.49, 14.9, 1.2),
      GlyphVertex(9.95, 18.43, 3.6),
      GlyphVertex(4.08, 20.2, 1),
      GlyphVertex(5.57, 14.05, 3.6),
    ], closed: true),
    GlyphPolyline([
      GlyphVertex(12.64, 8.96, 0.6),
      GlyphVertex(15.04, 11.36, 0.6),
      GlyphVertex(21.4, 5, 1.7),
      GlyphVertex(19, 2.6, 1.7),
    ], closed: true),
  ]);

  static const eyedropper = Glyph([
    GlyphPolyline([
      GlyphVertex(4.79, 19.21, 0.9),
      GlyphVertex(8.46, 18.08, 1.2),
      GlyphVertex(14.4, 12.14, 0.5),
      GlyphVertex(16.24, 13.98, 1),
      GlyphVertex(18.79, 11.43, 1),
      GlyphVertex(17.73, 10.37, 0.5),
      GlyphVertex(21.4, 6.7, 2.9),
      GlyphVertex(17.3, 2.6, 2.9),
      GlyphVertex(13.63, 6.27, 0.5),
      GlyphVertex(12.57, 5.21, 1),
      GlyphVertex(10.02, 7.76, 1),
      GlyphVertex(11.86, 9.6, 0.5),
      GlyphVertex(5.92, 15.54, 1.2),
    ], closed: true),
  ]);

  static const motion = Glyph([
    GlyphCircle(15.6, 12, 5.3),
    GlyphPolyline([
      GlyphVertex(4.4, 8),
      GlyphVertex(7.6, 8),
    ], role: GlyphRole.line),
    GlyphPolyline([
      GlyphVertex(2.9, 12),
      GlyphVertex(6.5, 12),
    ], role: GlyphRole.line),
    GlyphPolyline([
      GlyphVertex(4.4, 16),
      GlyphVertex(7.6, 16),
    ], role: GlyphRole.line),
  ]);

  static const blur = Glyph([
    GlyphCircle(9.4, 9.4, 1.6, role: GlyphRole.line, solid: true),
    GlyphCircle(14.6, 9.4, 1.6, role: GlyphRole.line, solid: true),
    GlyphCircle(9.4, 14.6, 1.6, role: GlyphRole.line, solid: true),
    GlyphCircle(14.6, 14.6, 1.6, role: GlyphRole.line, solid: true),
    GlyphCircle(9.4, 4.2, 1.1, role: GlyphRole.line, solid: true),
    GlyphCircle(14.6, 4.2, 1.1, role: GlyphRole.line, solid: true),
    GlyphCircle(4.2, 9.4, 1.1, role: GlyphRole.line, solid: true),
    GlyphCircle(19.8, 9.4, 1.1, role: GlyphRole.line, solid: true),
    GlyphCircle(4.2, 14.6, 1.1, role: GlyphRole.line, solid: true),
    GlyphCircle(19.8, 14.6, 1.1, role: GlyphRole.line, solid: true),
    GlyphCircle(9.4, 19.8, 1.1, role: GlyphRole.line, solid: true),
    GlyphCircle(14.6, 19.8, 1.1, role: GlyphRole.line, solid: true),
  ]);

  static const textSize = Glyph([
    GlyphPolyline([
      GlyphVertex(3.2, 4.4),
      GlyphVertex(14, 4.4),
    ], role: GlyphRole.line),
    GlyphPolyline([
      GlyphVertex(8.6, 4.4),
      GlyphVertex(8.6, 19.6),
    ], role: GlyphRole.line),
    GlyphPolyline([
      GlyphVertex(14.8, 10.8),
      GlyphVertex(21, 10.8),
    ], role: GlyphRole.line),
    GlyphPolyline([
      GlyphVertex(17.9, 10.8),
      GlyphVertex(17.9, 19.6),
    ], role: GlyphRole.line),
  ]);

  static const language = Glyph([
    GlyphPolyline([
      GlyphVertex(3.2, 3.9, 3),
      GlyphVertex(20.8, 3.9, 3),
      GlyphVertex(20.8, 17.5, 3),
      GlyphVertex(10, 17.5, 0.8),
      GlyphVertex(6.2, 21, 0.6),
      GlyphVertex(6.2, 17.5, 0.6),
      GlyphVertex(3.2, 17.5, 3),
    ], closed: true),
    GlyphPolyline([
      GlyphVertex(8.6, 14.1),
      GlyphVertex(12, 7.3, 0.4),
      GlyphVertex(15.4, 14.1),
    ], role: GlyphRole.detail),
    GlyphPolyline([
      GlyphVertex(9.85, 11.6),
      GlyphVertex(14.15, 11.6),
    ], role: GlyphRole.detail),
  ]);

  static const keyboard = Glyph([
    GlyphBox(3, 4.6, 21, 19.4, 2.8),
    GlyphCircle(6.75, 8.3, 1.1, role: GlyphRole.detail, solid: true),
    GlyphCircle(10.25, 8.3, 1.1, role: GlyphRole.detail, solid: true),
    GlyphCircle(13.75, 8.3, 1.1, role: GlyphRole.detail, solid: true),
    GlyphCircle(17.25, 8.3, 1.1, role: GlyphRole.detail, solid: true),
    GlyphCircle(6.75, 11.9, 1.1, role: GlyphRole.detail, solid: true),
    GlyphCircle(10.25, 11.9, 1.1, role: GlyphRole.detail, solid: true),
    GlyphCircle(13.75, 11.9, 1.1, role: GlyphRole.detail, solid: true),
    GlyphCircle(17.25, 11.9, 1.1, role: GlyphRole.detail, solid: true),
    GlyphPolyline([
      GlyphVertex(8.6, 15.6),
      GlyphVertex(15.4, 15.6),
    ], role: GlyphRole.detail),
  ]);

  static const photos = Glyph([
    GlyphBox(3, 6.4, 17.6, 21, 2.6),
    GlyphPolyline([
      GlyphVertex(6.4, 3),
      GlyphVertex(21, 3, 2.6),
      GlyphVertex(21, 17.6),
    ], role: GlyphRole.line),
    GlyphPolyline([
      GlyphVertex(3, 17.2),
      GlyphVertex(7.8, 12.4, 0.8),
      GlyphVertex(12.2, 16.8, 0.8),
      GlyphVertex(14, 15, 0.8),
      GlyphVertex(17.6, 18.6),
    ], role: GlyphRole.detail),
    GlyphCircle(13.4, 10.6, 1.4, role: GlyphRole.detail, solid: true),
  ]);

  static const camera = Glyph([
    GlyphPolyline([
      GlyphVertex(3, 7.5, 2.6),
      GlyphVertex(8.2, 7.5, 0.6),
      GlyphVertex(9.6, 5, 0.8),
      GlyphVertex(14.4, 5, 0.8),
      GlyphVertex(15.8, 7.5, 0.6),
      GlyphVertex(21, 7.5, 2.6),
      GlyphVertex(21, 19.5, 2.6),
      GlyphVertex(3, 19.5, 2.6),
    ], closed: true),
    GlyphCircle(12, 13.4, 3.4, role: GlyphRole.detail),
  ]);

  static const qrCode = Glyph([
    GlyphBox(3, 3, 10.2, 10.2, 2.2),
    GlyphBox(13.8, 3, 21, 10.2, 2.2),
    GlyphBox(3, 13.8, 10.2, 21, 2.2),
    GlyphPath(
      'M6.1 5.5H7.1A0.6 0.6 0 0 1 7.7 6.1V7.1A0.6 0.6 0 0 1 7.1 7.7H6.1A0.6 0.6 0 0 1 5.5 7.1V6.1A0.6 0.6 0 0 1 6.1 5.5Z',
      role: GlyphRole.detail,
      solid: true,
    ),
    GlyphPath(
      'M16.9 5.5H17.9A0.6 0.6 0 0 1 18.5 6.1V7.1A0.6 0.6 0 0 1 17.9 7.7H16.9A0.6 0.6 0 0 1 16.3 7.1V6.1A0.6 0.6 0 0 1 16.9 5.5Z',
      role: GlyphRole.detail,
      solid: true,
    ),
    GlyphPath(
      'M6.1 16.3H7.1A0.6 0.6 0 0 1 7.7 16.9V17.9A0.6 0.6 0 0 1 7.1 18.5H6.1A0.6 0.6 0 0 1 5.5 17.9V16.9A0.6 0.6 0 0 1 6.1 16.3Z',
      role: GlyphRole.detail,
      solid: true,
    ),
    GlyphPath(
      'M14.5 13.8H15.5A0.7 0.7 0 0 1 16.2 14.5V15.5A0.7 0.7 0 0 1 15.5 16.2H14.5A0.7 0.7 0 0 1 13.8 15.5V14.5A0.7 0.7 0 0 1 14.5 13.8Z',
      role: GlyphRole.line,
      solid: true,
    ),
    GlyphPath(
      'M19.3 13.8H20.3A0.7 0.7 0 0 1 21 14.5V15.5A0.7 0.7 0 0 1 20.3 16.2H19.3A0.7 0.7 0 0 1 18.6 15.5V14.5A0.7 0.7 0 0 1 19.3 13.8Z',
      role: GlyphRole.line,
      solid: true,
    ),
    GlyphPath(
      'M19.3 18.6H20.3A0.7 0.7 0 0 1 21 19.3V20.3A0.7 0.7 0 0 1 20.3 21H19.3A0.7 0.7 0 0 1 18.6 20.3V19.3A0.7 0.7 0 0 1 19.3 18.6Z',
      role: GlyphRole.line,
      solid: true,
    ),
  ]);

  static const torch = Glyph([
    GlyphPolyline([
      GlyphVertex(2.24, 17.66, 1.8),
      GlyphVertex(6.34, 21.76, 1.8),
      GlyphVertex(12.92, 15.18, 1.2),
      GlyphVertex(15.61, 14.76, 0.8),
      GlyphVertex(16.74, 13.63, 1.2),
      GlyphVertex(10.37, 7.26, 1.2),
      GlyphVertex(9.24, 8.39, 0.8),
      GlyphVertex(8.82, 11.08, 1.2),
    ], closed: true),
    GlyphCircle(8.68, 15.32, 1.1, role: GlyphRole.detail, solid: true),
    GlyphPolyline([
      GlyphVertex(13.27, 5.64),
      GlyphVertex(15.25, 3.66),
    ], role: GlyphRole.line),
    GlyphPolyline([
      GlyphVertex(15.82, 8.18),
      GlyphVertex(17.8, 6.2),
    ], role: GlyphRole.line),
    GlyphPolyline([
      GlyphVertex(18.36, 10.73),
      GlyphVertex(20.34, 8.75),
    ], role: GlyphRole.line),
  ]);

  static const torchOff = Glyph([
    GlyphPolyline([
      GlyphVertex(2.24, 17.66, 1.8),
      GlyphVertex(6.34, 21.76, 1.8),
      GlyphVertex(12.92, 15.18, 1.2),
      GlyphVertex(15.61, 14.76, 0.8),
      GlyphVertex(16.74, 13.63, 1.2),
      GlyphVertex(10.37, 7.26, 1.2),
      GlyphVertex(9.24, 8.39, 0.8),
      GlyphVertex(8.82, 11.08, 1.2),
    ], closed: true),
    GlyphCircle(8.68, 15.32, 1.1, role: GlyphRole.detail, solid: true),
  ]);

  static const torchAuto = Glyph([
    GlyphPolyline([
      GlyphVertex(2.24, 17.66, 1.8),
      GlyphVertex(6.34, 21.76, 1.8),
      GlyphVertex(12.92, 15.18, 1.2),
      GlyphVertex(15.61, 14.76, 0.8),
      GlyphVertex(16.74, 13.63, 1.2),
      GlyphVertex(10.37, 7.26, 1.2),
      GlyphVertex(9.24, 8.39, 0.8),
      GlyphVertex(8.82, 11.08, 1.2),
    ], closed: true),
    GlyphCircle(8.68, 15.32, 1.1, role: GlyphRole.detail, solid: true),
    GlyphPolyline([
      GlyphVertex(16.3, 8),
      GlyphVertex(18.7, 2.9, 0.4),
      GlyphVertex(21.1, 8),
    ], role: GlyphRole.line),
    GlyphPolyline([
      GlyphVertex(17.1, 6.3),
      GlyphVertex(20.3, 6.3),
    ], role: GlyphRole.line),
  ]);

  static const vpn = Glyph([
    GlyphPolyline([
      GlyphVertex(12, 2.9, 1.5),
      GlyphVertex(19.6, 5.5, 2),
      GlyphVertex(19.6, 12.5, 5),
      GlyphVertex(12, 21.1, 2.5),
      GlyphVertex(4.4, 12.5, 5),
      GlyphVertex(4.4, 5.5, 2),
    ], closed: true),
    GlyphCircle(12, 10.2, 1.6, role: GlyphRole.detail, solid: true),
    GlyphPolyline([
      GlyphVertex(12, 11),
      GlyphVertex(12, 14.6),
    ], role: GlyphRole.detail),
  ]);

  static const shuffle = Glyph([
    GlyphPolyline([
      GlyphVertex(3, 7),
      GlyphVertex(7, 7, 2),
      GlyphVertex(15, 17, 2),
      GlyphVertex(20.5, 17),
    ], role: GlyphRole.line),
    GlyphPath('M3 17H5Q7 17 8.25 15.44L8.69 14.88', role: GlyphRole.line),
    GlyphPath('M13.31 9.12L13.75 8.56Q15 7 17 7H20.5', role: GlyphRole.line),
    GlyphPolyline([
      GlyphVertex(17.5, 4),
      GlyphVertex(20.5, 7, 0.4),
      GlyphVertex(17.5, 10),
    ], role: GlyphRole.line),
    GlyphPolyline([
      GlyphVertex(17.5, 14),
      GlyphVertex(20.5, 17, 0.4),
      GlyphVertex(17.5, 20),
    ], role: GlyphRole.line),
  ]);

  static const split = Glyph([
    GlyphPolyline([
      GlyphVertex(4.5, 4),
      GlyphVertex(12, 11.5, 2.5),
      GlyphVertex(12, 20.5),
    ], role: GlyphRole.line),
    GlyphPolyline([
      GlyphVertex(19.5, 4),
      GlyphVertex(12, 11.5, 2.5),
      GlyphVertex(12, 20.5),
    ], role: GlyphRole.line),
    GlyphPolyline([
      GlyphVertex(4.5, 9.5),
      GlyphVertex(4.5, 4, 0.5),
      GlyphVertex(10, 4),
    ], role: GlyphRole.line),
    GlyphPolyline([
      GlyphVertex(14, 4),
      GlyphVertex(19.5, 4, 0.5),
      GlyphVertex(19.5, 9.5),
    ], role: GlyphRole.line),
  ]);

  static const speed = Glyph([
    GlyphPath(
      'M6.759 19.057 Q5.259 19.057 4.396 17.83 A8.8 8.8 0 1 1 19.604 17.83 '
      'Q18.741 19.057 17.241 19.057 Z',
    ),
    GlyphCircle(12, 13.4, 1.4, role: GlyphRole.detail, solid: true),
    GlyphPolyline([
      GlyphVertex(12, 13.4),
      GlyphVertex(15.47, 9.26),
    ], role: GlyphRole.detail),
  ]);

  static const dataUsage = Glyph([
    GlyphPath(
      'M10 14 H15.8 Q17 14 16.897 15.194 '
      'A7 7 0 1 1 8.806 7.103 Q10 7 10 8.2 Z',
    ),
    GlyphPath(
      'M13.6 9.4 V4.6 Q13.6 3.4 14.794 3.503 '
      'A7 7 0 0 1 20.497 9.206 Q20.6 10.4 19.4 10.4 '
      'H14.6 Q13.6 10.4 13.6 9.4 Z',
    ),
  ]);

  static const memory = Glyph([
    GlyphBox(3.5, 7.2, 20.5, 16.8, 2.5),
    GlyphPolyline([
      GlyphVertex(8, 7.2),
      GlyphVertex(8, 3.8),
    ], role: GlyphRole.line),
    GlyphPolyline([
      GlyphVertex(12, 7.2),
      GlyphVertex(12, 3.8),
    ], role: GlyphRole.line),
    GlyphPolyline([
      GlyphVertex(16, 7.2),
      GlyphVertex(16, 3.8),
    ], role: GlyphRole.line),
    GlyphPolyline([
      GlyphVertex(8, 16.8),
      GlyphVertex(8, 20.2),
    ], role: GlyphRole.line),
    GlyphPolyline([
      GlyphVertex(12, 16.8),
      GlyphVertex(12, 20.2),
    ], role: GlyphRole.line),
    GlyphPolyline([
      GlyphVertex(16, 16.8),
      GlyphVertex(16, 20.2),
    ], role: GlyphRole.line),
  ]);

  static const cpu = Glyph([
    GlyphBox(5.5, 5.5, 18.5, 18.5, 2.2),
    GlyphBox(9.2, 9.2, 14.8, 14.8, 1.2, role: GlyphRole.detail),
    GlyphPolyline([
      GlyphVertex(8.4, 5.5),
      GlyphVertex(8.4, 2.9),
    ], role: GlyphRole.line),
    GlyphPolyline([
      GlyphVertex(12, 5.5),
      GlyphVertex(12, 2.9),
    ], role: GlyphRole.line),
    GlyphPolyline([
      GlyphVertex(15.6, 5.5),
      GlyphVertex(15.6, 2.9),
    ], role: GlyphRole.line),
    GlyphPolyline([
      GlyphVertex(8.4, 18.5),
      GlyphVertex(8.4, 21.1),
    ], role: GlyphRole.line),
    GlyphPolyline([
      GlyphVertex(12, 18.5),
      GlyphVertex(12, 21.1),
    ], role: GlyphRole.line),
    GlyphPolyline([
      GlyphVertex(15.6, 18.5),
      GlyphVertex(15.6, 21.1),
    ], role: GlyphRole.line),
    GlyphPolyline([
      GlyphVertex(5.5, 8.4),
      GlyphVertex(2.9, 8.4),
    ], role: GlyphRole.line),
    GlyphPolyline([
      GlyphVertex(5.5, 12),
      GlyphVertex(2.9, 12),
    ], role: GlyphRole.line),
    GlyphPolyline([
      GlyphVertex(5.5, 15.6),
      GlyphVertex(2.9, 15.6),
    ], role: GlyphRole.line),
    GlyphPolyline([
      GlyphVertex(18.5, 8.4),
      GlyphVertex(21.1, 8.4),
    ], role: GlyphRole.line),
    GlyphPolyline([
      GlyphVertex(18.5, 12),
      GlyphVertex(21.1, 12),
    ], role: GlyphRole.line),
    GlyphPolyline([
      GlyphVertex(18.5, 15.6),
      GlyphVertex(21.1, 15.6),
    ], role: GlyphRole.line),
  ]);

  static const devices = Glyph([
    GlyphPolyline([
      GlyphVertex(11.4, 14.5),
      GlyphVertex(4, 14.5, 2),
      GlyphVertex(4, 4, 2),
      GlyphVertex(18.8, 4, 2),
      GlyphVertex(18.8, 6.4),
    ], role: GlyphRole.line),
    GlyphPolyline([
      GlyphVertex(2.9, 18.2),
      GlyphVertex(11.4, 18.2),
    ], role: GlyphRole.line),
    GlyphBox(15, 10, 20.8, 20.5, 2),
  ]);

  static const broom = Glyph([
    GlyphPolyline([
      GlyphVertex(20.1, 3.9),
      GlyphVertex(13.6, 10.4),
    ], role: GlyphRole.line),
    GlyphPolyline([
      GlyphVertex(15.44, 12.24, 1),
      GlyphVertex(11.76, 8.56, 1),
      GlyphVertex(9.78, 10.54),
      GlyphVertex(13.46, 14.22),
    ], closed: true),
    GlyphPolyline([
      GlyphVertex(14.02, 14.78, 1),
      GlyphVertex(9.22, 9.98, 1),
      GlyphVertex(3.28, 13.09, 1.5),
      GlyphVertex(10.91, 20.72, 1.5),
    ], closed: true),
  ]);

  static const wifi = Glyph([
    GlyphPath('M3.32 9.56 A13.5 13.5 0 0 1 20.68 9.56', role: GlyphRole.line),
    GlyphPath('M6.54 13.39 A8.5 8.5 0 0 1 17.46 13.39', role: GlyphRole.line),
    GlyphCircle(12, 18.6, 1.7, role: GlyphRole.line, solid: true),
  ]);

  static const wifiOff = Glyph([
    GlyphPath('M3.32 9.56 A13.5 13.5 0 0 1 6.15 7.73', role: GlyphRole.line),
    GlyphPath('M10.75 6.46 A13.5 13.5 0 0 1 20.68 9.56', role: GlyphRole.line),
    GlyphPath('M6.54 13.39 A8.5 8.5 0 0 1 10.56 11.52', role: GlyphRole.line),
    GlyphPath('M15.27 12.05 A8.5 8.5 0 0 1 17.46 13.39', role: GlyphRole.line),
    GlyphCircle(12, 18.6, 1.7, role: GlyphRole.line, solid: true),
    GlyphPolyline([
      GlyphVertex(4.5, 3),
      GlyphVertex(20.5, 19),
    ], role: GlyphRole.line),
  ]);

  static const networkCheck = Glyph([
    GlyphPath('M3.32 8.56 A13.5 13.5 0 0 1 20.68 8.56', role: GlyphRole.line),
    GlyphPath('M6.54 12.39 A8.5 8.5 0 0 1 17.46 12.39', role: GlyphRole.line),
    GlyphPolyline([
      GlyphVertex(8.6, 16.8),
      GlyphVertex(11, 19.2, 0.5),
      GlyphVertex(15.2, 15),
    ], role: GlyphRole.line),
  ]);

  static const gavel = Glyph([
    GlyphPolyline([
      GlyphVertex(14.93, 7.15, 1.5),
      GlyphVertex(11.25, 3.47, 1.5),
      GlyphVertex(3.47, 11.25, 1.5),
      GlyphVertex(7.15, 14.93, 1.5),
    ], closed: true),
    GlyphPolyline([
      GlyphVertex(11.04, 11.04),
      GlyphVertex(19.8, 19.8),
    ], role: GlyphRole.line),
    GlyphPolyline([
      GlyphVertex(3.2, 20.5),
      GlyphVertex(11.5, 20.5),
    ], role: GlyphRole.line),
  ]);

  static const appsList = Glyph([
    GlyphBox(3.5, 3.3, 6.9, 6.7, 1),
    GlyphBox(3.5, 10.3, 6.9, 13.7, 1),
    GlyphBox(3.5, 17.3, 6.9, 20.7, 1),
    GlyphPolyline([
      GlyphVertex(10.5, 5),
      GlyphVertex(20.5, 5),
    ], role: GlyphRole.line),
    GlyphPolyline([
      GlyphVertex(10.5, 12),
      GlyphVertex(20.5, 12),
    ], role: GlyphRole.line),
    GlyphPolyline([
      GlyphVertex(10.5, 19),
      GlyphVertex(20.5, 19),
    ], role: GlyphRole.line),
  ]);

  static const layoutList = Glyph([
    GlyphBox(3.5, 3.3, 20.5, 6.7, 1.4),
    GlyphBox(3.5, 10.3, 20.5, 13.7, 1.4),
    GlyphBox(3.5, 17.3, 20.5, 20.7, 1.4),
  ]);

  static const layoutTabs = Glyph([
    GlyphBox(3, 3.4, 11, 6.6, 1.2),
    GlyphPolyline([
      GlyphVertex(14.6, 5),
      GlyphVertex(20.2, 5),
    ], role: GlyphRole.line),
    GlyphBox(3, 10.2, 21, 20.6, 2.5),
  ]);

  static const columnsThree = Glyph([
    GlyphBox(3.5, 3.5, 6.9, 20.5, 1),
    GlyphBox(10.3, 3.5, 13.7, 20.5, 1),
    GlyphBox(17.1, 3.5, 20.5, 20.5, 1),
  ]);

  static const columnsTwo = Glyph([
    GlyphBox(3.5, 3.5, 10, 20.5, 1.6),
    GlyphBox(14, 3.5, 20.5, 20.5, 1.6),
  ]);

  static const columnsOne = Glyph([GlyphBox(5, 4.5, 19, 19.5, 2)]);

  static const cardLarge = Glyph([
    GlyphBox(3.5, 3.6, 20.5, 20.4, 3.2),
    GlyphPolyline([
      GlyphVertex(7, 9),
      GlyphVertex(17, 9),
    ], role: GlyphRole.detail),
    GlyphPolyline([
      GlyphVertex(7, 15),
      GlyphVertex(13.5, 15),
    ], role: GlyphRole.detail),
  ], matchTextDirection: true);

  static const cardMedium = Glyph([
    GlyphBox(3.5, 6.4, 20.5, 17.6, 2.8),
    GlyphPolyline([
      GlyphVertex(7, 12),
      GlyphVertex(17, 12),
    ], role: GlyphRole.detail),
  ], matchTextDirection: true);

  static const cardSmall = Glyph([GlyphBox(3.5, 9, 20.5, 15, 2.2)]);

  static const iconTile = Glyph([
    GlyphBox(3, 3, 21, 21, 5),
    GlyphPolyline([
      GlyphVertex(5.6, 16.8),
      GlyphVertex(9.6, 12.8, 0.8),
      GlyphVertex(12.8, 16, 0.8),
      GlyphVertex(14.6, 14.2, 0.8),
      GlyphVertex(18.4, 18),
    ], role: GlyphRole.detail),
    GlyphCircle(15.2, 8.8, 1.5, role: GlyphRole.detail, solid: true),
  ]);

  static const iconPlain = Glyph([
    GlyphPolyline([
      GlyphVertex(3, 17.6),
      GlyphVertex(9.6, 11, 1.2),
      GlyphVertex(14.2, 15.6, 1.2),
      GlyphVertex(16.6, 13.2, 1.2),
      GlyphVertex(21, 17.6),
    ]),
    GlyphCircle(16.4, 7.4, 2.2, solid: true),
  ]);

  static Glyph sidebar(double progress) {
    final divider = lerpDouble(8.5, 11.5, progress)!;
    return Glyph([
      const GlyphBox(3, 4.5, 21, 19.5, 3.5),
      GlyphPolyline([
        GlyphVertex(divider, 4.5),
        GlyphVertex(divider, 19.5),
      ], role: GlyphRole.detail),
      for (final y in const [8.5, 11.0, 13.5])
        GlyphPolyline([
          GlyphVertex(5.5, y),
          GlyphVertex(divider - 2.5, y),
        ], role: GlyphRole.detail),
    ], matchTextDirection: true);
  }

  /// Play at 0, pause at 1; past either end it keeps turning, so it bounces.
  static Glyph playPause(double progress) {
    final fold = progress.clamp(0.0, 1.0);
    final turn = math.pi / 2 * progress;
    if (fold == 0) {
      return Glyph([
        GlyphPolyline([
          for (final corner in _playCorners) _turnedVertex(corner, turn),
        ], closed: true),
      ]);
    }
    return Glyph([
      for (final (half, bar) in _playHalves)
        GlyphPolyline([
          for (var i = 0; i < bar.length; i++)
            _turnedVertex(Offset.lerp(half[i], bar[i], fold)!, turn),
        ], closed: true),
    ]);
  }

  static const _playCorners = [
    Offset(8.3, 5.6),
    Offset(18.8, 12),
    Offset(8.3, 18.4),
  ];
  static const _playHalves = [
    (
      [Offset(8.3, 5.6), Offset(18.8, 12), Offset(18.8, 12), Offset(8.3, 12)],
      [
        Offset(5.9, 6.9),
        Offset(18.1, 6.9),
        Offset(18.1, 9.1),
        Offset(5.9, 9.1),
      ],
    ),
    (
      [Offset(8.3, 12), Offset(18.8, 12), Offset(18.8, 12), Offset(8.3, 18.4)],
      [
        Offset(5.9, 14.9),
        Offset(18.1, 14.9),
        Offset(18.1, 17.1),
        Offset(5.9, 17.1),
      ],
    ),
  ];

  static GlyphVertex _turnedVertex(Offset corner, double angle) {
    final offset = corner - const Offset(12, 12);
    return GlyphVertex(
      12 + offset.dx * math.cos(angle) - offset.dy * math.sin(angle),
      12 + offset.dx * math.sin(angle) + offset.dy * math.cos(angle),
      1.2,
    );
  }

  static Glyph backFor(TargetPlatform platform) {
    if (kIsWeb) {
      return arrowBack;
    }
    return switch (platform) {
      TargetPlatform.iOS || TargetPlatform.macOS => chevronBack,
      _ => arrowBack,
    };
  }
}
