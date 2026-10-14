import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/common/theme.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/manager/status_manager.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/providers/database.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/disclaimer.dart';
import 'package:fl_clash/views/tools.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/glyph_finders.dart';
import '../helpers/test_app.dart';
import '../helpers/test_profiles.dart';

Future<ProviderContainer> _pumpHost(
  WidgetTester tester, {
  Widget Function(Widget child)? homeBuilder,
  Size size = const Size(1000, 800),
  ProviderContainer? providerContainer,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final container = providerContainer ?? ProviderContainer();
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

void _expectReadOnlyDisclaimer() {
  final view = find.byType(DisclaimerView);
  for (final type in [
    TextField,
    TextFormField,
    EditableText,
    FilledButton,
    OutlinedButton,
  ]) {
    expect(
      find.descendant(of: view, matching: find.byType(type)),
      findsNothing,
    );
  }
  for (final label in [
    'Agree',
    'Exit',
    'Confirm',
    'Read to the end',
    'Restate the statement',
  ]) {
    expect(find.text(label), findsNothing);
  }
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

  for (final (label, size, nested) in const [
    ('desktop nested navigator', Size(1000, 800), true),
    ('mobile', Size(400, 800), false),
  ]) {
    testWidgets('tools disclaimer is read-only on $label', (tester) async {
      final tabNavigator = GlobalKey<NavigatorState>();
      final container = ProviderContainer(
        overrides: [profilesProvider.overrideWith(TestProfiles.new)],
      );
      final settingsChanges = <AppSettingProps>[];
      final settingsSubscription = container.listen(
        appSettingProvider,
        (_, next) => settingsChanges.add(next),
      );
      final settings = container.read(appSettingProvider);

      await _pumpHost(
        tester,
        size: size,
        providerContainer: container,
        homeBuilder: (_) => nested
            ? Navigator(
                key: tabNavigator,
                pages: const [MaterialPage(child: ToolsView())],
                onDidRemovePage: (_) {},
              )
            : const ToolsView(),
      );
      addTearDown(settingsSubscription.close);
      await tester.pumpAndSettle();

      final localizations = tester
          .element(find.byType(ToolsView))
          .appLocalizations;
      expect(find.byType(DisclaimerView), findsNothing);
      final entry = find.text(localizations.disclaimer);
      await tester.scrollUntilVisible(
        entry,
        500,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(entry);
      await tester.pumpAndSettle();

      final view = find.byType(DisclaimerView);
      expect(view, findsOneWidget);
      if (nested) {
        expect(
          find.descendant(of: find.byKey(tabNavigator), matching: view),
          findsOneWidget,
        );
        expect(tabNavigator.currentState!.canPop(), isTrue);
        expect(globalState.navigatorKey.currentState!.canPop(), isFalse);
      } else {
        expect(globalState.navigatorKey.currentState!.canPop(), isTrue);
      }
      _expectReadOnlyDisclaimer();
      final scrollable = find
          .descendant(of: view, matching: find.byType(Scrollable))
          .first;
      final position = tester.state<ScrollableState>(scrollable).position;
      expect(position.pixels, 0);
      expect(position.extentAfter, greaterThan(0));
      expect(find.text(localizations.disclaimerDesc), findsOneWidget);

      final dismiss = find.byTooltip(localizations.back);
      await tester.tap(dismiss);
      await tester.pumpAndSettle();
      expect(view, findsNothing);
      expect(find.byType(ToolsView), findsOneWidget);
      if (nested) {
        expect(tabNavigator.currentState!.canPop(), isFalse);
      }
      expect(globalState.navigatorKey.currentState!.canPop(), isFalse);
      expect(container.read(appSettingProvider), settings);
      expect(settingsChanges, isEmpty);

      await tester.tap(entry);
      await tester.pumpAndSettle();
      final reopenedPosition = tester
          .state<ScrollableState>(scrollable)
          .position;
      while (reopenedPosition.extentAfter > 0) {
        await tester.drag(scrollable, Offset(0, -size.height));
        await tester.pumpAndSettle();
      }
      expect(reopenedPosition.pixels, greaterThan(0));
      expect(reopenedPosition.extentAfter, 0);
      _expectReadOnlyDisclaimer();

      await tester.tap(dismiss);
      await tester.pumpAndSettle();
      expect(view, findsNothing);
      expect(find.byType(ToolsView), findsOneWidget);
      if (nested) {
        expect(tabNavigator.currentState!.canPop(), isFalse);
      }
      expect(globalState.navigatorKey.currentState!.canPop(), isFalse);
      expect(container.read(appSettingProvider), settings);
      expect(settingsChanges, isEmpty);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }

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
