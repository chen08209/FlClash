import 'package:fl_clash/icons/icons.dart';
import 'package:flutter_test/flutter_test.dart';

extension GlyphFinders on CommonFinders {
  Finder byGlyph(Glyph glyph) => byWidgetPredicate(
    (widget) => widget is GlyphIcon && widget.glyph == glyph,
    description: 'GlyphIcon($glyph)',
  );

  Finder widgetWithGlyph(Type widgetType, Glyph glyph) =>
      ancestor(of: byGlyph(glyph), matching: byType(widgetType));
}
