import 'dart:ui' as ui;

import 'package:code_forge/code_forge.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:re_highlight/styles/atom-one-light.dart';

import 'support.dart';

Future<Color> _pixelAt(WidgetTester tester, GlobalKey key, Offset at) async {
  final boundary =
      key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  final bytes = (await tester.runAsync(() async {
    final image = await boundary.toImage();
    final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    image.dispose();
    return data!;
  }))!;
  final index =
      (at.dy.toInt() * boundary.size.width.toInt() + at.dx.toInt()) * 4;
  return Color.fromARGB(
    bytes.getUint8(index + 3),
    bytes.getUint8(index),
    bytes.getUint8(index + 1),
    bytes.getUint8(index + 2),
  );
}

void main() {
  setUpAll(initEditorNative);

  testWidgets('a new theme repaints the gutter and selection in place', (
    tester,
  ) async {
    final controller = CodeForgeController()..text = 'a${' ' * 40}b\nc: 1';
    final boundary = GlobalKey();

    Future<void> pumpTheme(Color background, Color selection) => pumpEditor(
      tester,
      controller,
      editorTheme: {
        ...atomOneLightTheme,
        'root': TextStyle(color: Colors.black, backgroundColor: background),
      },
      selectionStyle: CodeSelectionStyle(selectionColor: selection),
      wrap: (editor) => RepaintBoundary(key: boundary, child: editor),
    );

    const rowY = editorTopPadding + editorLineHeight / 2;
    const gutter = Offset(4, rowY);
    const selected = Offset(200, rowY);
    await pumpTheme(Colors.white, const Color(0xFF00FF00));
    final state = tester.state(find.byType(CodeForge));
    controller.selectAll();
    await settle(tester, 2);
    expect(await _pixelAt(tester, boundary, gutter), Colors.white);
    expect(await _pixelAt(tester, boundary, selected), const Color(0xFF00FF00));

    await pumpTheme(Colors.black, const Color(0xFFFF0000));
    expect(tester.state(find.byType(CodeForge)), same(state));
    expect(await _pixelAt(tester, boundary, gutter), Colors.black);
    expect(await _pixelAt(tester, boundary, selected), const Color(0xFFFF0000));
  });
}
