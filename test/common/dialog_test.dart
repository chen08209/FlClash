import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/common/theme.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/manager/status_manager.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/disclaimer.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/glyph_finders.dart';
import '../helpers/test_app.dart';

Future<ProviderContainer> _pumpHost(
  WidgetTester tester, {
  Widget Function(Widget child)? homeBuilder,
  Size size = const Size(1000, 800),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final container = ProviderContainer();
  addTearDown(container.dispose);
  globalState.container = container;
  container.read(viewSizeProvider.notifier).update((_) => size);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: TestApp(
        homeBuilder: homeBuilder ?? (child) => child,
        child: const Scaffold(body: SizedBox.shrink()),
      ),
    ),
  );
  await tester.pump();
  return container;
}

FilledButton _disclaimerAgreeButton(WidgetTester tester) {
  return tester.widget<FilledButton>(
    find.descendant(
      of: find.byType(DisclaimerView),
      matching: find.byType(FilledButton),
    ),
  );
}

Future<void> _scrollDisclaimerTo(WidgetTester tester, Offset offset) async {
  await tester.drag(
    find
        .descendant(
          of: find.byType(DisclaimerView),
          matching: find.byType(Scrollable),
        )
        .first,
    offset,
  );
  await tester.pumpAndSettle();
}

String _noServiceStatement(WidgetTester tester) {
  return tester
      .element(find.byType(DisclaimerView))
      .appLocalizations
      .disclaimerNoServiceStatement;
}

TextButton _restateConfirmButton(WidgetTester tester) {
  return tester.widget<TextButton>(find.widgetWithText(TextButton, 'Confirm'));
}

Future<void> _agreeAndRestate(WidgetTester tester) async {
  await tester.tap(find.text('Agree'));
  await tester.pumpAndSettle();
  await tester.enterText(find.byType(TextField), _noServiceStatement(tester));
  await tester.pump();
  await tester.tap(find.text('Confirm'));
  await tester.pumpAndSettle();
}

/// The real manager stack mounts [StatusManager] above the app navigator, so
/// [Dialogs.showNotifier] can reach it from `navigatorKey.currentContext`.
Future<void> _pumpStatusManagerHost(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1000, 800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final container = ProviderContainer();
  addTearDown(container.dispose);
  globalState.container = container;
  container
      .read(viewSizeProvider.notifier)
      .update((_) => const Size(1000, 800));

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        navigatorKey: globalState.navigatorKey,
        localizationsDelegates: const [AppLocalizations.delegate],
        supportedLocales: AppLocalizations.delegate.supportedLocales,
        builder: (context, child) {
          globalState.measure = Measure.of(context, 1);
          globalState.theme = CommonTheme.of(context, 1);
          return StatusManager(child: child!);
        },
        home: const Scaffold(body: SizedBox.shrink()),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  testWidgets('showMessage resolves true when confirmed', (tester) async {
    await _pumpHost(tester);

    final result = dialogs.showMessage(message: const TextSpan(text: 'body'));
    await tester.pumpAndSettle();

    expect(find.text('body'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);

    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();

    expect(await result, isTrue);
    expect(tester.takeException(), null);
  });

  testWidgets('showMessage resolves false when cancelled', (tester) async {
    await _pumpHost(tester);

    final result = dialogs.showMessage(message: const TextSpan(text: 'body'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(await result, isFalse);
  });

  testWidgets('showMessage hides the cancel action when not cancelable', (
    tester,
  ) async {
    await _pumpHost(tester);

    final result = dialogs.showMessage(
      message: const TextSpan(text: 'body'),
      cancelable: false,
    );
    await tester.pumpAndSettle();

    expect(find.text('Cancel'), findsNothing);
    expect(find.text('Confirm'), findsOneWidget);

    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();
    expect(await result, isTrue);
  });

  testWidgets('showMessage honours custom title and action labels', (
    tester,
  ) async {
    await _pumpHost(tester);

    final result = dialogs.showMessage(
      message: const TextSpan(text: 'body'),
      title: 'Custom title',
      confirmText: 'Go',
      cancelText: 'Back',
    );
    await tester.pumpAndSettle();

    expect(find.text('Custom title'), findsOneWidget);
    expect(find.text('Go'), findsOneWidget);
    expect(find.text('Back'), findsOneWidget);

    await tester.tap(find.text('Back'));
    await tester.pumpAndSettle();
    expect(await result, isFalse);
  });

  testWidgets('showCommonDialog returns the value the child pops', (
    tester,
  ) async {
    await _pumpHost(tester);

    final result = dialogs.showCommonDialog<String>(
      child: Builder(
        builder: (context) => TextButton(
          onPressed: () => Navigator.of(context).pop('picked'),
          child: const Text('pick'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('pick'));
    await tester.pumpAndSettle();

    expect(await result, 'picked');
  });

  testWidgets('a dialog stacked on a dialog brings its own scrim', (
    tester,
  ) async {
    await _pumpHost(tester);

    final result = dialogs.showCommonDialog<void>(
      child: Builder(
        builder: (context) => TextButton(
          onPressed: () {
            dialogs.showCommonDialog<void>(
              context: context,
              child: const Text('inner'),
            );
          },
          child: const Text('open inner'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final outer = tester.element(find.text('open inner'));
    final scrim = outer.colorScheme.scrim.withValues(alpha: 0.32);
    expect(ModalRoute.of(outer)!.barrierColor, scrim);

    await tester.tap(find.text('open inner'));
    await tester.pumpAndSettle();
    final inner = tester.element(find.text('inner'));
    expect(ModalRoute.of(inner)!.barrierColor, scrim);
    expect(find.byType(BackdropFilter), findsNothing);

    Navigator.of(inner).pop();
    await tester.pumpAndSettle();
    Navigator.of(outer).pop();
    await tester.pumpAndSettle();
    await result;
  });

  testWidgets('showFailureDetails groups failures under their reason', (
    tester,
  ) async {
    await _pumpHost(tester);

    const longMessage =
        'failed to update provider because the Go core returned a very long '
        'error message that cannot fit on a single line';
    final result = dialogs.showFailureDetails(const [
      UpdatingMessage(label: 'profile-a', message: 'updated'),
      UpdatingMessage(label: 'profile-b', message: longMessage),
      UpdatingMessage(label: 'profile-c', message: longMessage),
    ]);
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsNothing);
    expect(find.text('Error details'), findsOneWidget);
    expect(find.text('profile-a'), findsOneWidget);
    expect(find.text('profile-b'), findsOneWidget);
    expect(find.text('profile-c'), findsOneWidget);
    final messageText = tester.widget<Text>(find.text(longMessage));
    expect(messageText.maxLines, isNull);
    expect(
      tester.getTopLeft(find.text('profile-c')).dy,
      lessThan(tester.getTopLeft(find.text(longMessage)).dy),
    );
    expect(find.byGlyph(AppGlyphs.error), findsNothing);

    Navigator.of(tester.element(find.text('profile-a'))).pop();
    await tester.pumpAndSettle();
    await result;
    expect(find.text('profile-a'), findsNothing);
  });

  testWidgets(
    'requestDisclaimerConsent maps agree, exit, and back to a boolean',
    (tester) async {
      await _pumpHost(tester);

      final agreed = requestDisclaimerConsent();
      await tester.pumpAndSettle();
      expect(find.text('Data collection and privacy'), findsOneWidget);
      await _scrollDisclaimerTo(tester, const Offset(0, -100000));
      await _agreeAndRestate(tester);
      expect(await agreed, isTrue);

      final declined = requestDisclaimerConsent();
      await tester.pumpAndSettle();
      await tester.tap(find.text('Exit'));
      await tester.pumpAndSettle();
      expect(await declined, isFalse);

      final dismissed = requestDisclaimerConsent();
      await tester.pumpAndSettle();
      rootNavigatorKey.currentState!.pop();
      await tester.pumpAndSettle();
      expect(await dismissed, isFalse);
    },
  );

  testWidgets('disclaimer agree unlocks only once the terms reach the end', (
    tester,
  ) async {
    await _pumpHost(tester);

    final agreed = requestDisclaimerConsent();
    await tester.pumpAndSettle();
    expect(find.text('Read to the end'), findsOneWidget);
    expect(_disclaimerAgreeButton(tester).onPressed, isNull);

    await _scrollDisclaimerTo(tester, const Offset(0, -300));
    expect(_disclaimerAgreeButton(tester).onPressed, isNull);

    await _scrollDisclaimerTo(tester, const Offset(0, -100000));
    await _scrollDisclaimerTo(tester, const Offset(0, 100000));
    expect(_disclaimerAgreeButton(tester).onPressed, isNotNull);
    expect(find.text('Read to the end'), findsNothing);

    await _agreeAndRestate(tester);
    expect(await agreed, isTrue);
  });

  testWidgets('disclaimer consent on mobile labels the locked button', (
    tester,
  ) async {
    await _pumpHost(tester, size: const Size(400, 800));

    final agreed = requestDisclaimerConsent();
    await tester.pumpAndSettle();
    expect(find.text('Agree'), findsNothing);
    expect(
      find.descendant(
        of: find.byType(FilledButton),
        matching: find.text('Read to the end'),
      ),
      findsOneWidget,
    );

    await _scrollDisclaimerTo(tester, const Offset(0, -100000));
    await _agreeAndRestate(tester);
    expect(await agreed, isTrue);
  });

  testWidgets(
    'disclaimer consent on desktop keeps the title clear of the window corner',
    (tester) async {
      await _pumpHost(tester);

      final agreed = requestDisclaimerConsent();
      await tester.pumpAndSettle();

      final view = find.byType(DisclaimerView);
      expect(
        find.descendant(of: view, matching: find.byType(AppBar)),
        findsNothing,
        reason:
            'the macOS traffic lights sit over the top-left corner, where an '
            'app bar puts its back button, and backing out declines anyway',
      );
      expect(
        tester
            .getTopLeft(
              find.descendant(of: view, matching: find.text('Disclaimer')),
            )
            .dy,
        greaterThanOrEqualTo(macOSTrafficLightsArea.height),
      );
      expect(
        find.descendant(
          of: find.byType(FilledButton),
          matching: find.text('Agree'),
        ),
        findsOneWidget,
      );

      await tester.tap(find.text('Exit'));
      await tester.pumpAndSettle();
      expect(await agreed, isFalse);
    },
  );

  testWidgets('disclaimer agree is unlocked when the terms fit on screen', (
    tester,
  ) async {
    await _pumpHost(tester);
    tester.view.physicalSize = const Size(1000, 20000);

    final agreed = requestDisclaimerConsent();
    await tester.pumpAndSettle();
    expect(_disclaimerAgreeButton(tester).onPressed, isNotNull);

    await _agreeAndRestate(tester);
    expect(await agreed, isTrue);
  });

  testWidgets('disclaimer agree waits for the statement to be restated', (
    tester,
  ) async {
    await _pumpHost(tester);

    final agreed = requestDisclaimerConsent();
    await tester.pumpAndSettle();
    await _scrollDisclaimerTo(tester, const Offset(0, -100000));
    await tester.tap(find.text('Agree'));
    await tester.pumpAndSettle();
    expect(find.text('Restate the statement'), findsOneWidget);
    expect(_restateConfirmButton(tester).onPressed, isNull);

    final field = find.byType(TextField);
    await tester.enterText(field, 'The Software itself');
    await tester.pump();
    expect(find.text('Does not match the statement'), findsNothing);
    expect(_restateConfirmButton(tester).onPressed, isNull);

    await tester.enterText(field, 'The Software itself provides');
    await tester.pump();
    expect(find.text('Does not match the statement'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Restate the statement'), findsNothing);
    expect(find.byType(DisclaimerView), findsOneWidget);

    await tester.tap(find.text('Agree'));
    await tester.pumpAndSettle();
    expect(tester.widget<TextField>(field).controller!.text, isEmpty);
    await tester.enterText(field, '${_noServiceStatement(tester)}\n');
    await tester.pump();
    expect(_restateConfirmButton(tester).onPressed, isNotNull);
    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();
    expect(await agreed, isTrue);
  });

  testWidgets('restating keeps the statement selectable without a shortcut', (
    tester,
  ) async {
    await _pumpHost(tester);

    final agreed = requestDisclaimerConsent();
    await tester.pumpAndSettle();
    await _scrollDisclaimerTo(tester, const Offset(0, -100000));
    await tester.tap(find.text('Agree'));
    await tester.pumpAndSettle();

    final statement = _noServiceStatement(tester);
    expect(
      find.byWidgetPredicate(
        (widget) => widget is SelectableText && widget.data == statement,
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.byType(IconButton),
      ),
      findsNothing,
    );
    final field = find.byType(TextField);
    expect(tester.widget<TextField>(field).controller!.text, isEmpty);

    await tester.showKeyboard(field);
    tester.testTextInput.updateEditingValue(
      const TextEditingValue(
        text: 'The Softwarexy',
        composing: TextRange(start: 12, end: 14),
      ),
    );
    await tester.pump();
    expect(find.text('Does not match the statement'), findsNothing);

    tester.testTextInput.updateEditingValue(
      const TextEditingValue(text: 'The Softwarexy'),
    );
    await tester.pump();
    expect(find.text('Does not match the statement'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Exit'));
    await tester.pumpAndSettle();
    expect(await agreed, isFalse);
  });

  testWidgets('DisclaimerView without consent shows no agree or exit', (
    tester,
  ) async {
    await _pumpHost(tester, homeBuilder: (_) => const DisclaimerView());

    expect(find.text('Disclaimer'), findsWidgets);
    expect(find.text('Agree'), findsNothing);
    expect(find.text('Exit'), findsNothing);
  });

  testWidgets('showNotifier delivers text through the StatusManager host', (
    tester,
  ) async {
    await _pumpStatusManagerHost(tester);

    dialogs.showNotifier('something happened');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('something happened'), findsOneWidget);
    expect(tester.takeException(), null);
  });

  testWidgets('showNotifier drops empty text before reaching the host', (
    tester,
  ) async {
    await _pumpStatusManagerHost(tester);

    dialogs.showNotifier('');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text(''), findsNothing);
    expect(tester.takeException(), null);
  });

  testWidgets('showNotifier is inert without a StatusManager ancestor', (
    tester,
  ) async {
    await _pumpHost(tester);

    dialogs.showNotifier('no host listening');
    await tester.pumpAndSettle();

    expect(find.text('no host listening'), findsNothing);
    expect(tester.takeException(), null);
  });
}
