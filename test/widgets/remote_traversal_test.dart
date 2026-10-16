import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

Widget _button(String label) {
  return SizedBox(
    width: 100,
    height: 48,
    child: TextButton(
      key: ValueKey(label),
      onPressed: () {},
      child: Text(label),
    ),
  );
}

Widget _at(double left, double top, String label) {
  return Positioned(left: left, top: top, child: _button(label));
}

// Mirrors the desktop home: a sidebar beside a page that sits in a navigator of
// its own, which [showPage] can build late.
Widget _buildApp({
  required bool remote,
  required Widget page,
  bool nested = true,
  GlobalKey<NavigatorState>? navigatorKey,
  ValueListenable<bool>? showPage,
}) {
  Widget buildPage() {
    final scoped = PageFocusScope(child: page);
    if (!nested) {
      return scoped;
    }
    return Navigator(
      pages: [MaterialPage(child: scoped)],
      onDidRemovePage: (_) {},
    );
  }

  return MaterialApp(
    navigatorKey: navigatorKey,
    builder: (context, child) =>
        RemoteFocusAdapter(enabled: remote, child: child!),
    home: Scaffold(
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 200,
            child: Column(
              children: [for (var i = 0; i < 4; i++) _button('side$i')],
            ),
          ),
          Expanded(
            child: FocusTraversalGroup(
              policy: PageTraversalPolicy(),
              child: showPage == null
                  ? buildPage()
                  : ValueListenableBuilder(
                      valueListenable: showPage,
                      builder: (context, show, _) =>
                          show ? buildPage() : const SizedBox.shrink(),
                    ),
            ),
          ),
        ],
      ),
    ),
  );
}

FocusNode _nodeOf(WidgetTester tester, String label) {
  return Focus.of(tester.element(find.text(label, skipOffstage: false)));
}

Future<void> _focus(WidgetTester tester, String label) async {
  _nodeOf(tester, label).requestFocus();
  await tester.pump();
}

Future<void> _press(WidgetTester tester, LogicalKeyboardKey key) async {
  await tester.sendKeyEvent(key);
  await tester.pumpAndSettle();
}

bool _hasFocus(WidgetTester tester, String label) {
  return _nodeOf(tester, label).hasPrimaryFocus;
}

void main() {
  testWidgets('a navigator built under a covered route leaves focus above', (
    tester,
  ) async {
    final navigatorKey = GlobalKey<NavigatorState>();
    final showPage = ValueNotifier(false);
    addTearDown(showPage.dispose);
    await tester.pumpWidget(
      _buildApp(
        remote: true,
        navigatorKey: navigatorKey,
        showPage: showPage,
        page: _button('page'),
      ),
    );
    navigatorKey.currentState!.push(
      MaterialPageRoute<void>(
        builder: (_) => Material(child: Center(child: _button('agree'))),
      ),
    );
    await tester.pumpAndSettle();
    expect(_hasFocus(tester, 'agree'), isTrue);

    showPage.value = true;
    await tester.pumpAndSettle();

    expect(_hasFocus(tester, 'agree'), isTrue);
  });

  testWidgets('left into the sidebar forgets the moves made before', (
    tester,
  ) async {
    await tester.pumpWidget(
      _buildApp(remote: false, page: Stack(children: [_at(100, 0, 'top')])),
    );
    await _focus(tester, 'side3');
    await _press(tester, LogicalKeyboardKey.arrowDown);
    expect(_hasFocus(tester, 'top'), isTrue);
    await _press(tester, LogicalKeyboardKey.arrowLeft);
    expect(_hasFocus(tester, 'side0'), isTrue);

    await _press(tester, LogicalKeyboardKey.arrowUp);

    expect(_hasFocus(tester, 'side0'), isTrue);
  });

  testWidgets('the sidebar stops at its ends and leaves the page unscrolled', (
    tester,
  ) async {
    await tester.pumpWidget(
      _buildApp(
        remote: true,
        nested: false,
        page: ListView(
          children: [
            const SizedBox(height: 250),
            _button('row'),
            const SizedBox(height: 2000),
          ],
        ),
      ),
    );
    await _focus(tester, 'side3');

    await _press(tester, LogicalKeyboardKey.arrowDown);

    expect(_hasFocus(tester, 'side3'), isTrue);
    final position = tester
        .state<ScrollableState>(find.byType(Scrollable))
        .position;
    expect(position.pixels, 0);

    await _focus(tester, 'side0');
    await _press(tester, LogicalKeyboardKey.arrowUp);

    expect(_hasFocus(tester, 'side0'), isTrue);
  });

  testWidgets('a row ends at its last control on a remote', (tester) async {
    await tester.pumpWidget(
      _buildApp(
        remote: true,
        page: Stack(
          children: [
            _at(0, 0, 'start'),
            _at(100, 0, 'end'),
            _at(300, 300, 'below'),
          ],
        ),
      ),
    );
    await _focus(tester, 'end');

    await _press(tester, LogicalKeyboardKey.arrowRight);

    expect(_hasFocus(tester, 'end'), isTrue);

    await _focus(tester, 'below');
    await _press(tester, LogicalKeyboardKey.arrowLeft);

    expect(_hasFocus(tester, 'side3'), isTrue);
  });

  testWidgets('a row end still jumps out of band on the desktop', (
    tester,
  ) async {
    await tester.pumpWidget(
      _buildApp(
        remote: false,
        page: Stack(children: [_at(100, 0, 'end'), _at(300, 300, 'below')]),
      ),
    );
    await _focus(tester, 'end');

    await _press(tester, LogicalKeyboardKey.arrowRight);

    expect(_hasFocus(tester, 'below'), isTrue);
  });

  testWidgets('right from the sidebar lands on a control on screen', (
    tester,
  ) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      _buildApp(
        remote: true,
        page: ListView(
          controller: controller,
          children: [
            const SizedBox(height: 100),
            _button('above'),
            const SizedBox(height: 512),
            _button('shown'),
            const SizedBox(height: 2000),
          ],
        ),
      ),
    );
    controller.jumpTo(160);
    await tester.pump();
    await _focus(tester, 'above');
    await _focus(tester, 'side3');

    await _press(tester, LogicalKeyboardKey.arrowRight);

    expect(_hasFocus(tester, 'shown'), isTrue);
    expect(controller.offset, 160);
  });
}
