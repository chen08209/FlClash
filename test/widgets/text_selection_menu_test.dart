import 'package:fl_clash/ui/ui.dart';
import 'package:prism_ui/icons/icons.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/glyph_finders.dart';
import '../helpers/test_app.dart';
import '../helpers/host_scaffold.dart';

const _desktop = TargetPlatformVariant({
  TargetPlatform.macOS,
  TargetPlatform.windows,
  TargetPlatform.linux,
});

const _mobile = TargetPlatformVariant({
  TargetPlatform.android,
  TargetPlatform.iOS,
});

Future<TextEditingController> _pumpField(WidgetTester tester) async {
  final controller = TextEditingController(text: 'alpha beta');
  addTearDown(controller.dispose);
  await tester.pumpWidget(
    TestApp(
      child: HostScaffold(
        body: Center(
          child: SizedBox(width: 300, child: TextField(controller: controller)),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return controller;
}

Future<void> _rightClick(WidgetTester tester, Finder finder) async {
  await tester.tap(
    finder,
    buttons: kSecondaryButton,
    kind: PointerDeviceKind.mouse,
  );
  await tester.pumpAndSettle();
}

Future<void> _doubleTap(WidgetTester tester, Finder finder) async {
  await tester.tap(finder);
  await tester.pump(kDoubleTapMinTime);
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

bool _toolbarShown(WidgetTester tester) => tester
    .state<EditableTextState>(find.byType(EditableText))
    .selectionOverlay!
    .toolbarIsVisible;

void main() {
  testWidgets('a right click opens the popup menu', (tester) async {
    final controller = await _pumpField(tester);

    await _rightClick(tester, find.byType(TextField));

    expect(find.byType(PopupMenu), findsOneWidget);

    await tester.tap(find.text('Select all'));
    await tester.pumpAndSettle();

    expect(controller.selection.textInside(controller.text), 'alpha beta');
    expect(find.byType(PopupMenu), findsNothing);
  }, variant: _desktop);

  testWidgets('a touch selection opens the edit menu beside it', (
    tester,
  ) async {
    await _pumpField(tester);

    await _doubleTap(tester, find.byType(TextField));

    expect(find.byType(PopupMenu), findsNothing);
    expect(find.text('Copy'), findsOneWidget);

    final field = tester.getRect(find.byType(EditableText));
    final copy = tester.getRect(find.text('Copy'));
    expect(copy.height, lessThan(44));
    expect(copy.bottom, lessThan(field.top));
  }, variant: _mobile);

  testWidgets('labels that do not fit unfold from a chevron', (tester) async {
    tester.view.physicalSize = const Size(180, 600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await _pumpField(tester);
    await _doubleTap(tester, find.byType(TextField));

    expect(find.text('Select all'), findsNothing);

    await tester.tap(find.byGlyph(Glyphs.chevronForward));
    await tester.pumpAndSettle();

    expect(find.text('Select all'), findsOneWidget);
    expect(find.byGlyph(Glyphs.copy), findsOneWidget);
  }, variant: _mobile);

  testWidgets('select all on a phone keeps the menu for the new selection', (
    tester,
  ) async {
    final controller = await _pumpField(tester);
    await _doubleTap(tester, find.byType(TextField));

    await tester.tap(find.text('Select all'));
    await tester.pumpAndSettle();

    expect(controller.selection.textInside(controller.text), 'alpha beta');
    expect(find.text('Copy'), findsOneWidget);
    expect(find.text('Select all'), findsNothing);
    expect(_toolbarShown(tester), isTrue);
  }, variant: _mobile);

  testWidgets('a caret offers to select its word', (tester) async {
    final controller = await _pumpField(tester);
    await tester.tap(find.byType(TextField));
    await tester.pumpAndSettle();
    controller.selection = const TextSelection.collapsed(offset: 2);
    await tester.pump();
    tester.state<EditableTextState>(find.byType(EditableText)).showToolbar();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Select'));
    await tester.pumpAndSettle();

    expect(controller.selection.textInside(controller.text), 'alpha');
    expect(find.text('Copy'), findsOneWidget);
  }, variant: _mobile);

  testWidgets('closing the popup hides the field menu with it', (tester) async {
    await _pumpField(tester);
    await _rightClick(tester, find.byType(TextField));
    expect(_toolbarShown(tester), isTrue);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.byType(PopupMenu), findsNothing);
    expect(_toolbarShown(tester), isFalse);
  }, variant: _desktop);

  testWidgets('selectable text opens the popup menu', (tester) async {
    await tester.pumpWidget(
      const TestApp(
        child: HostScaffold(body: Center(child: SelectableText('alpha beta'))),
      ),
    );
    await tester.pumpAndSettle();

    await _rightClick(tester, find.text('alpha beta'));

    expect(find.byType(PopupMenu), findsOneWidget);
    expect(find.text('Paste'), findsNothing);
  }, variant: _desktop);
}
