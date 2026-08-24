import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/common/theme.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/manager/status_manager.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';

Future<ProviderContainer> _pumpHost(
  WidgetTester tester, {
  Widget Function(Widget child)? homeBuilder,
}) async {
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
      child: TestApp(
        homeBuilder: homeBuilder ?? (child) => child,
        child: const Scaffold(body: SizedBox.shrink()),
      ),
    ),
  );
  await tester.pump();
  return container;
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

  testWidgets('showAllUpdatingMessagesDialog lists every message', (
    tester,
  ) async {
    await _pumpHost(tester);

    const longMessage =
        'failed to update provider because the Go core returned a very long '
        'error message that cannot fit on a single line';
    final result = dialogs.showAllUpdatingMessagesDialog(const [
      UpdatingMessage(label: 'profile-a', message: 'updated'),
      UpdatingMessage(label: 'profile-b', message: longMessage),
    ]);
    await tester.pumpAndSettle();

    expect(find.text('profile-a'), findsOneWidget);
    expect(find.text('profile-b'), findsOneWidget);
    final messageText = tester.widget<Text>(find.text(longMessage));
    expect(messageText.maxLines, 2);
    expect(messageText.overflow, TextOverflow.ellipsis);
    expect(find.byIcon(Icons.error_outline), findsNothing);
    expect(
      find.ancestor(
        of: find.text(longMessage),
        matching: find.byType(TooltipText),
      ),
      findsOneWidget,
    );

    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();
    expect(await result, isTrue);
  });

  testWidgets('showDisclaimer maps agree and exit to a boolean', (
    tester,
  ) async {
    await _pumpHost(tester);

    final agreed = dialogs.showDisclaimer();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Agree'));
    await tester.pumpAndSettle();
    expect(await agreed, isTrue);

    final declined = dialogs.showDisclaimer();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Exit'));
    await tester.pumpAndSettle();
    expect(await declined, isFalse);
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
