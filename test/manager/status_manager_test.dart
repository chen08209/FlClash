import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/manager/status_manager.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/widgets/sheet_header.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/glyph_finders.dart';
import '../helpers/test_app.dart';

Future<StatusManagerState> _pumpStatusManager(
  WidgetTester tester, {
  bool isMobileView = true,
  InterfaceStyleTheme interfaceStyle = const InterfaceStyleTheme(),
  TextScale textScale = const TextScale(),
}) async {
  await tester.pumpWidget(
    TestApp(
      wrapInProviderScope: true,
      overrides: [
        isMobileViewProvider.overrideWithValue(isMobileView),
        themeSettingProvider.overrideWithBuild(
          (_, _) => ThemeProps(textScale: textScale),
        ),
      ],
      homeBuilder: (child) => Theme(
        data: ThemeData().withInterfaceStyle(interfaceStyle),
        child: child,
      ),
      child: const StatusManager(child: SizedBox()),
    ),
  );
  return tester.state<StatusManagerState>(find.byType(StatusManager));
}

Finder _rowOf(String text) {
  return find
      .ancestor(
        of: find.text(text),
        matching: find.byWidgetPredicate(
          (widget) => widget is Align && widget.heightFactor != null,
        ),
      )
      .first;
}

double _revealOf(WidgetTester tester, String text) {
  return tester.widget<Align>(_rowOf(text)).heightFactor!;
}

double _opacityOf(WidgetTester tester, String text) {
  return tester
      .widget<FadeTransition>(
        find
            .descendant(of: _rowOf(text), matching: find.byType(FadeTransition))
            .first,
      )
      .opacity
      .value;
}

Offset _offsetOf(WidgetTester tester, String text) {
  final translation = tester
      .widget<Transform>(
        find
            .descendant(of: _rowOf(text), matching: find.byType(Transform))
            .first,
      )
      .transform
      .getTranslation();
  return Offset(translation.x, translation.y);
}

Finder _cardOf(String text) {
  return find
      .ancestor(of: find.text(text), matching: find.byType(Material))
      .first;
}

void main() {
  testWidgets('clears the Miuix large title at any app text scale', (
    tester,
  ) async {
    Future<double> topOf(
      InterfaceStyleTheme interfaceStyle, {
      TextScale textScale = const TextScale(),
    }) async {
      final state = await _pumpStatusManager(
        tester,
        interfaceStyle: interfaceStyle,
        textScale: textScale,
      );
      state.message('hello');
      await tester.pumpAndSettle();
      final top = tester.getTopLeft(_cardOf('hello')).dy;
      await tester.pumpWidget(const SizedBox.shrink());
      return top;
    }

    const miuix = InterfaceStyleTheme(style: InterfaceStyle.miuix);
    const large = TextScale(enable: true, scale: 1.4);
    final material = await topOf(const InterfaceStyleTheme());

    expect(
      await topOf(miuix) - material,
      LargeTitleHeader.expandedHeightFor(TextScaler.noScaling) -
          pageToolbarHeight,
    );
    expect(
      await topOf(miuix, textScale: large) - material,
      LargeTitleHeader.expandedHeightFor(const TextScaler.linear(1.4)) -
          pageToolbarHeight,
    );
    expect(
      await topOf(const InterfaceStyleTheme(), textScale: large),
      material,
    );
  });

  testWidgets('shows a message until its duration expires', (tester) async {
    final state = await _pumpStatusManager(tester);
    state.message('hello');
    await tester.pump();

    expect(find.text('hello'), findsOneWidget);

    await tester.pump(const Duration(seconds: 4));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('hello'), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('stacks messages up to the visible limit', (tester) async {
    final state = await _pumpStatusManager(tester, isMobileView: false);
    state.message('first');
    state.message('second');
    state.message('third');
    state.message('fourth');
    state.message('fifth');
    await tester.pump();

    expect(find.text('first'), findsOneWidget);
    expect(find.text('second'), findsOneWidget);
    expect(find.text('third'), findsOneWidget);
    expect(find.text('fourth'), findsOneWidget);
    expect(find.text('fifth'), findsNothing);

    await tester.pump(const Duration(seconds: 4));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('first'), findsNothing);
    expect(find.text('fifth'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('stacks the newest message above the older ones', (tester) async {
    final state = await _pumpStatusManager(tester, isMobileView: false);
    state.message('older');
    state.message('newer');
    await tester.pumpAndSettle();

    expect(
      tester.getTopLeft(find.text('newer')).dy,
      lessThan(tester.getTopLeft(find.text('older')).dy),
    );

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('keeps the mobile stack smaller than the desktop stack', (
    tester,
  ) async {
    final state = await _pumpStatusManager(tester);
    state.message('first');
    state.message('second');
    state.message('third');
    await tester.pump();

    expect(find.text('first'), findsOneWidget);
    expect(find.text('second'), findsOneWidget);
    expect(find.text('third'), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('a new message animates in instead of appearing at once', (
    tester,
  ) async {
    final state = await _pumpStatusManager(tester);
    state.message('animated');
    await tester.pump();

    expect(_revealOf(tester, 'animated'), 0);
    expect(_opacityOf(tester, 'animated'), 0);

    await tester.pump(const Duration(milliseconds: 60));
    final midReveal = _revealOf(tester, 'animated');
    expect(midReveal, greaterThan(0));
    expect(midReveal, lessThan(1));

    await tester.pump(const Duration(milliseconds: 400));
    expect(_revealOf(tester, 'animated'), 1);
    expect(_opacityOf(tester, 'animated'), 1);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('a new message fades in while the stack is still making room', (
    tester,
  ) async {
    final state = await _pumpStatusManager(tester);
    state.message('animated');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 60));

    expect(_opacityOf(tester, 'animated'), greaterThan(0));
    expect(_revealOf(tester, 'animated'), lessThan(1));

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('a new message drops in from above', (tester) async {
    final state = await _pumpStatusManager(tester);
    state.message('animated');
    await tester.pump();

    expect(_offsetOf(tester, 'animated').dy, lessThan(0));
    expect(_offsetOf(tester, 'animated').dx, 0);

    await tester.pump(const Duration(milliseconds: 60));
    expect(_offsetOf(tester, 'animated').dy, lessThan(0));

    await tester.pump(const Duration(milliseconds: 400));
    expect(_offsetOf(tester, 'animated'), Offset.zero);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('an expiring message animates out before it is removed', (
    tester,
  ) async {
    final state = await _pumpStatusManager(tester);
    state.message('leaving');
    await tester.pumpAndSettle();

    await tester.pump(const Duration(seconds: 3));
    await tester.pump(const Duration(milliseconds: 200));
    final reveal = _revealOf(tester, 'leaving');
    expect(reveal, greaterThan(0));
    expect(reveal, lessThan(1));

    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('leaving'), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('merges a repeat instead of queueing it again', (tester) async {
    final state = await _pumpStatusManager(tester);
    state.message('same');
    state.message('same');
    await tester.pump();

    expect(find.text('same'), findsOneWidget);

    await tester.pump(const Duration(seconds: 4));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('same'), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('a merged repeat restarts the visible duration', (tester) async {
    final state = await _pumpStatusManager(tester);
    state.message('same');
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));

    state.message('same');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1500));
    expect(find.text('same'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('an error preempts a low priority message when full', (
    tester,
  ) async {
    final state = await _pumpStatusManager(tester, isMobileView: false);
    state.message('info one');
    state.message('info two');
    state.message('info three');
    state.message('info four');
    state.message('boom', level: MessageLevel.error);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('info one'), findsNothing);
    expect(find.text('info two'), findsOneWidget);
    expect(find.text('info three'), findsOneWidget);
    expect(find.text('info four'), findsOneWidget);
    expect(find.text('boom'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('an error jumps ahead of the messages waiting in the queue', (
    tester,
  ) async {
    final state = await _pumpStatusManager(tester);
    state.message('info one');
    state.message('info two');
    state.message('info three');
    state.message('boom', level: MessageLevel.error);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('boom'), findsOneWidget);
    expect(find.text('info one'), findsNothing);
    expect(find.text('info two'), findsOneWidget);
    expect(find.text('info three'), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('an error carries a level icon and outlives an info message', (
    tester,
  ) async {
    final state = await _pumpStatusManager(tester);
    state.message('boom', level: MessageLevel.error);
    await tester.pump();

    expect(find.byGlyph(AppGlyphs.error), findsOneWidget);

    await tester.pump(const Duration(seconds: 4));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('boom'), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('boom'), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('an info message carries no level icon', (tester) async {
    final state = await _pumpStatusManager(tester);
    state.message('plain');
    await tester.pump();

    expect(find.text('plain'), findsOneWidget);
    expect(find.byType(GlyphIcon), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('a message with an action stays long enough to press it', (
    tester,
  ) async {
    final state = await _pumpStatusManager(tester);
    state.message(
      'restart needed',
      actionState: MessageActionState(actionText: 'restart', action: () {}),
    );
    await tester.pump();

    await tester.pump(const Duration(seconds: 4));
    expect(find.text('restart needed'), findsOneWidget);

    await tester.pump(const Duration(seconds: 3));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('restart needed'), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('runs the action and dismisses the message when tapped', (
    tester,
  ) async {
    var ran = false;
    final state = await _pumpStatusManager(tester);
    state.message(
      'restart needed',
      actionState: MessageActionState(
        actionText: 'restart',
        action: () => ran = true,
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    await tester.tap(find.text('restart'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(ran, isTrue);
    expect(find.text('restart needed'), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('a swipe collapses the row faster than a timed exit', (
    tester,
  ) async {
    final state = await _pumpStatusManager(tester);
    state.message('swipe me');
    await tester.pumpAndSettle();

    await tester.drag(_cardOf('swipe me'), const Offset(600, 0));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 220));
    expect(find.text('swipe me'), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('a drag holds the auto dismiss until it is released', (
    tester,
  ) async {
    final state = await _pumpStatusManager(tester);
    state.message('held while the finger stays down on the card');
    await tester.pumpAndSettle();

    final gesture = await tester.startGesture(
      tester.getCenter(_cardOf('held while the finger stays down on the card')),
    );
    for (var step = 0; step < 4; step++) {
      await gesture.moveBy(const Offset(10, 0));
      await tester.pump(const Duration(milliseconds: 50));
    }
    await tester.pump(const Duration(seconds: 4));
    expect(
      find.text('held while the finger stays down on the card'),
      findsOneWidget,
    );

    await gesture.up();
    await tester.pumpAndSettle();
    expect(
      find.text('held while the finger stays down on the card'),
      findsOneWidget,
    );

    await tester.pump(const Duration(seconds: 3));
    await tester.pump(const Duration(milliseconds: 500));
    expect(
      find.text('held while the finger stays down on the card'),
      findsNothing,
    );

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('a drag freezes the messages above the one being held', (
    tester,
  ) async {
    final state = await _pumpStatusManager(tester);
    state.message('the older message sitting underneath the held one');
    state.message('the newer message that would expire first');
    await tester.pumpAndSettle();

    final held = _cardOf('the older message sitting underneath the held one');
    final gesture = await tester.startGesture(tester.getCenter(held));
    for (var step = 0; step < 4; step++) {
      await gesture.moveBy(const Offset(10, 0));
      await tester.pump(const Duration(milliseconds: 50));
    }
    await tester.pump(const Duration(seconds: 4));

    expect(
      find.text('the newer message that would expire first'),
      findsOneWidget,
    );
    expect(
      find.text('the older message sitting underneath the held one'),
      findsOneWidget,
    );

    await gesture.up();
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 3));
    await tester.pump(const Duration(milliseconds: 500));
    expect(
      find.text('the newer message that would expire first'),
      findsNothing,
    );

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('a message that arrives during a drag waits for the release', (
    tester,
  ) async {
    final state = await _pumpStatusManager(tester, isMobileView: false);
    state.message('the message being held down by a finger');
    await tester.pumpAndSettle();

    final gesture = await tester.startGesture(
      tester.getCenter(_cardOf('the message being held down by a finger')),
    );
    for (var step = 0; step < 4; step++) {
      await gesture.moveBy(const Offset(10, 0));
      await tester.pump(const Duration(milliseconds: 50));
    }

    state.message('arrived mid drag');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('arrived mid drag'), findsNothing);

    await gesture.up();
    await tester.pumpAndSettle();
    expect(find.text('arrived mid drag'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('a swiped message leaves in the direction of the swipe', (
    tester,
  ) async {
    for (final direction in [-1.0, 1.0]) {
      final state = await _pumpStatusManager(tester);
      state.message('swipe me');
      await tester.pumpAndSettle();
      final restingLeft = tester.getTopLeft(find.text('swipe me')).dx;

      await tester.drag(_cardOf('swipe me'), Offset(300 * direction, 0));
      await tester.pump();
      final releasedAt = tester.getTopLeft(find.text('swipe me')).dx;
      expect((releasedAt - restingLeft).sign, direction);

      while (find.text('swipe me').evaluate().isNotEmpty) {
        final left = tester.getTopLeft(find.text('swipe me')).dx;
        expect((left - releasedAt) * direction, greaterThanOrEqualTo(0));
        await tester.pump(const Duration(milliseconds: 40));
      }

      await tester.pumpWidget(const SizedBox.shrink());
    }
  });

  testWidgets('a short drag springs back and keeps the message', (
    tester,
  ) async {
    final state = await _pumpStatusManager(tester);
    state.message('swipe me');
    await tester.pumpAndSettle();
    final restingLeft = tester.getTopLeft(find.text('swipe me')).dx;

    final gesture = await tester.startGesture(
      tester.getCenter(_cardOf('swipe me')),
    );
    for (var step = 0; step < 4; step++) {
      await gesture.moveBy(const Offset(-10, 0));
      await tester.pump(const Duration(milliseconds: 50));
    }
    expect(tester.getTopLeft(find.text('swipe me')).dx, lessThan(restingLeft));
    await tester.pump(const Duration(milliseconds: 500));
    await gesture.up();
    await tester.pumpAndSettle();

    expect(tester.getTopLeft(find.text('swipe me')).dx, restingLeft);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('swipe dismiss removes the message', (tester) async {
    final state = await _pumpStatusManager(tester);
    state.message('swipe me');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    await tester.drag(_cardOf('swipe me'), const Offset(600, 0));
    await tester.pumpAndSettle();

    expect(find.text('swipe me'), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
