import 'dart:async';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/pages/home.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/widgets/inherited.dart';
import 'package:fl_clash/widgets/open_container.dart';
import 'package:fl_clash/widgets/paged_sheet.dart';
import 'package:fl_clash/widgets/pop_scope.dart';
import 'package:fl_clash/widgets/sheet.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

Matcher _slid(double fraction) => moreOrLessEquals(800 * fraction);

ThemeData _theme({bool predictiveBack = true}) {
  return ThemeData().withInterfaceStyle(
    InterfaceStyleTheme(predictiveBack: predictiveBack),
  );
}

Widget _page(String label) {
  return Scaffold(
    key: ValueKey(label),
    body: Center(child: Text(label)),
  );
}

Future<Object?> _backGesture(
  WidgetTester tester,
  String method, [
  Object? arguments,
]) async {
  const channel = SystemChannels.backGesture;
  Object? reply;
  await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
    channel.name,
    channel.codec.encodeMethodCall(MethodCall(method, arguments)),
    (data) => reply = data == null ? null : channel.codec.decodeEnvelope(data),
  );
  await tester.pump();
  return reply;
}

Map<String, Object?> _event(double progress, {bool button = false}) {
  return {
    'touchOffset': button ? null : [4.0, 300.0],
    'progress': progress,
    'swipeEdge': SwipeEdge.left.index,
  };
}

Future<bool> _start(WidgetTester tester, {bool button = false}) async {
  final claimed = await _backGesture(
    tester,
    'startBackGesture',
    _event(0, button: button),
  );
  return claimed == true;
}

Future<void> _update(WidgetTester tester, double progress) {
  return _backGesture(tester, 'updateBackGestureProgress', _event(progress));
}

Future<void> _commit(WidgetTester tester) async {
  await _backGesture(tester, 'commitBackGesture');
  await tester.pumpAndSettle();
}

Future<void> _cancel(WidgetTester tester) async {
  await _backGesture(tester, 'cancelBackGesture');
  await tester.pumpAndSettle();
}

double _left(WidgetTester tester, String label) {
  return tester.getTopLeft(find.byKey(ValueKey(label))).dx;
}

double _opacity(WidgetTester tester, String label) {
  var opacity = 1.0;
  for (
    RenderObject? node = tester.renderObject(find.byKey(ValueKey(label)));
    node != null;
    node = node.parent
  ) {
    if (node is RenderAnimatedOpacity) {
      opacity *= node.opacity.value;
    } else if (node is RenderOpacity) {
      opacity *= node.opacity;
    }
  }
  return opacity;
}

class _PopCounter extends NavigatorObserver {
  int pops = 0;

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) => pops++;
}

Future<NavigatorState> _pumpRoutes(
  WidgetTester tester,
  List<Route<void> Function()> routes, {
  bool predictiveBack = true,
  List<NavigatorObserver> observers = const [],
  TransitionBuilder? builder,
}) async {
  final navigatorKey = GlobalKey<NavigatorState>();
  await tester.pumpWidget(
    MaterialApp(
      navigatorKey: navigatorKey,
      navigatorObservers: observers,
      theme: _theme(predictiveBack: predictiveBack),
      builder: builder,
      home: _page('home'),
    ),
  );
  for (final route in routes) {
    unawaited(navigatorKey.currentState!.push(route()));
    await tester.pumpAndSettle();
  }
  return navigatorKey.currentState!;
}

Route<void> Function() _commonRoute(String label, [Widget? page]) {
  return () => CommonRoute<void>(builder: (_) => page ?? _page(label));
}

class _CloseCounter extends SystemAction {
  int closes = 0;

  @override
  Future<void> handleClose([bool exit = true]) async => closes++;
}

void main() {
  group('a predictive back gesture', () {
    testWidgets('slides the page with its progress and pops it once', (
      tester,
    ) async {
      final pops = _PopCounter();
      final navigator = await _pumpRoutes(
        tester,
        [_commonRoute('page')],
        observers: [pops],
      );
      pops.pops = 0;

      expect(await _start(tester), isTrue);
      await _update(tester, 0.25);
      expect(_left(tester, 'page'), _slid(0.25));
      expect(navigator.userGestureInProgress, isTrue);
      await _update(tester, 0.5);
      expect(_left(tester, 'page'), _slid(0.5));

      await _commit(tester);
      expect(find.text('page'), findsNothing);
      expect(find.text('home'), findsOneWidget);
      expect(pops.pops, 1);
      expect(navigator.userGestureInProgress, isFalse);
    });

    testWidgets('settles the page back when cancelled', (tester) async {
      final navigator = await _pumpRoutes(tester, [_commonRoute('page')]);

      expect(await _start(tester), isTrue);
      await _update(tester, 0.6);
      expect(_left(tester, 'page'), _slid(0.6));

      await _cancel(tester);
      expect(_left(tester, 'page'), 0);
      expect(find.text('page'), findsOneWidget);
      expect(navigator.userGestureInProgress, isFalse);
    });

    testWidgets('keeps the page it uncovers whole, not mid-exit', (
      tester,
    ) async {
      await _pumpRoutes(tester, [_commonRoute('first'), _commonRoute('top')]);

      expect(await _start(tester), isTrue);
      await _update(tester, 0.3);
      expect(_opacity(tester, 'first'), 1);
      expect(_left(tester, 'first'), 0);
      expect(_left(tester, 'top'), _slid(0.3));

      await _commit(tester);
      expect(find.text('top'), findsNothing);
      expect(_opacity(tester, 'first'), 1);
    });

    testWidgets('slides toward the reading end in right-to-left text', (
      tester,
    ) async {
      await _pumpRoutes(
        tester,
        [_commonRoute('page')],
        builder: (_, child) =>
            Directionality(textDirection: TextDirection.rtl, child: child!),
      );

      expect(await _start(tester), isTrue);
      await _update(tester, 0.25);
      expect(_left(tester, 'page'), _slid(-0.25));
      await _cancel(tester);
    });

    testWidgets('is left to the framework when predictive back is off', (
      tester,
    ) async {
      final pops = _PopCounter();
      await _pumpRoutes(
        tester,
        [_commonRoute('page')],
        predictiveBack: false,
        observers: [pops],
      );
      pops.pops = 0;

      expect(await _start(tester), isFalse);
      await _update(tester, 0.5);
      expect(_left(tester, 'page'), 0);

      await _commit(tester);
      expect(find.text('page'), findsNothing);
      expect(pops.pops, 1);
    });

    testWidgets('leaves a back button press to the framework', (tester) async {
      await _pumpRoutes(tester, [_commonRoute('page')]);

      expect(await _start(tester, button: true), isFalse);
      await _commit(tester);
      expect(find.text('page'), findsNothing);
    });

    testWidgets('leaves a page that vetoes popping to the framework', (
      tester,
    ) async {
      await _pumpRoutes(tester, [
        _commonRoute('page', PopScope(canPop: false, child: _page('page'))),
      ]);

      expect(await _start(tester), isFalse);
      await _commit(tester);
      expect(find.text('page'), findsOneWidget);
    });

    testWidgets('leaves a page with an open back layer to the framework', (
      tester,
    ) async {
      var layerOpen = true;
      await _pumpRoutes(tester, [
        _commonRoute(
          'page',
          StatefulBuilder(
            builder: (context, setState) => layerOpen
                ? BackLayerScope(
                    onBack: () => setState(() => layerOpen = false),
                    child: _page('page'),
                  )
                : _page('page'),
          ),
        ),
      ]);

      expect(await _start(tester), isFalse);
      await _commit(tester);
      expect(layerOpen, isFalse);
      expect(find.text('page'), findsOneWidget);

      expect(await _start(tester), isTrue);
      await _commit(tester);
      expect(find.text('page'), findsNothing);
    });

    testWidgets('drives desktop routes the same way', (tester) async {
      await _pumpRoutes(tester, [
        () => CommonDesktopRoute<void>(builder: (_) => _page('page')),
      ]);

      expect(await _start(tester), isTrue);
      await _update(tester, 0.5);
      expect(_left(tester, 'page'), _slid(0.5));
      await _commit(tester);
      expect(find.text('page'), findsNothing);
    });

    testWidgets('slides an open container back to its tile', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: _theme(),
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 160,
                height: 80,
                child: OpenContainer<void>(
                  closedBuilder: (_, open) =>
                      TextButton(onPressed: open, child: const Text('tile')),
                  openBuilder: (_, _) => _page('opened'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('tile'));
      await tester.pumpAndSettle();

      expect(await _start(tester), isTrue);
      await _update(tester, 0.5);
      expect(_left(tester, 'opened'), _slid(0.5));
      expect(find.text('tile'), findsOneWidget);

      await _commit(tester);
      expect(find.text('opened'), findsNothing);
      expect(find.text('tile'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('steps a paged sheet back one page', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: _theme(),
          home: SheetProvider(
            type: SheetType.bottomSheet,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                width: double.infinity,
                child: PagedSheet(
                  child: Navigator(
                    onGenerateInitialRoutes: (_, _) => [
                      PagedSheetRoute<void>(
                        builder: (context) => SizedBox(
                          key: const ValueKey('first'),
                          height: 300,
                          child: TextButton(
                            onPressed: () => Navigator.of(context).push(
                              PagedSheetRoute<void>(
                                builder: (_) => const SizedBox(
                                  key: ValueKey('second'),
                                  height: 300,
                                  child: Center(child: Text('second')),
                                ),
                              ),
                            ),
                            child: const Text('first'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('first'));
      await tester.pumpAndSettle();

      expect(await _start(tester), isTrue);
      await _update(tester, 0.4);
      expect(_left(tester, 'second'), _slid(0.4));
      expect(_opacity(tester, 'first'), 1);
      expect(_left(tester, 'first'), 0);

      await _commit(tester);
      expect(find.text('second'), findsNothing);
      expect(find.text('first'), findsOneWidget);

      expect(await _start(tester), isFalse);
    });

    testWidgets('leaves pages inside a sheet alone under a dialog', (
      tester,
    ) async {
      final rootKey = GlobalKey<NavigatorState>();
      final sheetKey = GlobalKey<NavigatorState>();
      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: rootKey,
          theme: _theme(),
          home: Navigator(
            key: sheetKey,
            onGenerateInitialRoutes: (_, _) => [
              CommonRoute<void>(builder: (_) => _page('sheet first')),
            ],
          ),
        ),
      );
      unawaited(sheetKey.currentState!.push(_commonRoute('sheet top')()));
      await tester.pumpAndSettle();
      unawaited(
        showDialog<void>(
          context: rootKey.currentContext!,
          builder: (_) => const AlertDialog(content: Text('dialog')),
        ),
      );
      await tester.pumpAndSettle();

      expect(await _start(tester), isFalse);
      await _commit(tester);
      expect(find.text('dialog'), findsNothing);
      expect(find.text('sheet top'), findsOneWidget);

      expect(await _start(tester), isTrue);
      await _commit(tester);
      expect(find.text('sheet top'), findsNothing);
      expect(find.text('sheet first'), findsOneWidget);
    });

    testWidgets('leaves an inactive page alone', (tester) async {
      final activeKey = GlobalKey<NavigatorState>();
      final inactiveKey = GlobalKey<NavigatorState>();
      final inactive = ValueNotifier(false);
      addTearDown(inactive.dispose);
      Widget pageNavigator(Key key, String label) {
        return Navigator(
          key: key,
          onGenerateInitialRoutes: (_, _) => [
            CommonRoute<void>(builder: (_) => _page('$label root')),
          ],
        );
      }

      await tester.pumpWidget(
        MaterialApp(
          theme: _theme(),
          home: Row(
            children: [
              Expanded(child: pageNavigator(activeKey, 'active')),
              Expanded(
                child: ValueListenableBuilder(
                  valueListenable: inactive,
                  builder: (_, value, child) =>
                      TickerMode(enabled: !value, child: child!),
                  child: pageNavigator(inactiveKey, 'inactive'),
                ),
              ),
            ],
          ),
        ),
      );
      unawaited(activeKey.currentState!.push(_commonRoute('active top')()));
      unawaited(inactiveKey.currentState!.push(_commonRoute('inactive top')()));
      await tester.pumpAndSettle();
      inactive.value = true;
      await tester.pump();
      final inactiveLeft = _left(tester, 'inactive top');

      expect(await _start(tester), isTrue);
      await _update(tester, 0.5);
      expect(_left(tester, 'inactive top'), inactiveLeft);
      expect(inactiveKey.currentState!.userGestureInProgress, isFalse);
      expect(activeKey.currentState!.userGestureInProgress, isTrue);

      await _commit(tester);
      expect(find.text('active top'), findsNothing);
      expect(find.text('inactive top'), findsOneWidget);
    });
  });

  group('back at the home root', () {
    late List<bool> frameworkHandlesBack;

    setUp(() => frameworkHandlesBack = []);

    Future<ProviderContainer> pumpHome(
      WidgetTester tester, {
      bool predictiveBack = true,
      int sdk = 34,
      double width = 400,
      bool minimizeOnExit = true,
      Widget home = const SizedBox(),
    }) async {
      const lifecycle = SystemChannels.lifecycle;
      await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
        lifecycle.name,
        lifecycle.codec.encodeMessage(AppLifecycleState.resumed.toString()),
        (_) {},
      );
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          if (call.method == 'SystemNavigator.setFrameworkHandlesBack') {
            frameworkHandlesBack.add(call.arguments as bool);
          }
          return null;
        },
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          null,
        ),
      );
      final container = ProviderContainer(
        overrides: [
          versionProvider.overrideWithBuild((_, _) => sdk),
          systemActionProvider.overrideWith(_CloseCounter.new),
        ],
      );
      addTearDown(container.dispose);
      container.listen(appSettingProvider, (_, _) {});
      container.read(viewSizeProvider.notifier).value = Size(width, 800);
      container
          .read(appSettingProvider.notifier)
          .update((state) => state.copyWith(minimizeOnExit: minimizeOnExit));
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: _theme(predictiveBack: predictiveBack),
            home: HomeBackScopeContainer(child: home),
          ),
        ),
      );
      await tester.pump();
      return container;
    }

    Future<void> openAndCloseLayer(
      WidgetTester tester, {
      required bool leavePage,
      bool predictiveBack = true,
      bool minimizeOnExit = true,
    }) async {
      var layerOpen = false;
      var pageActive = true;
      late StateSetter setHome;
      await pumpHome(
        tester,
        predictiveBack: predictiveBack,
        minimizeOnExit: minimizeOnExit,
        home: StatefulBuilder(
          builder: (context, setState) {
            setHome = setState;
            return PageActivityScope(
              isActive: pageActive,
              child: layerOpen
                  ? BackLayerScope(
                      onBack: () => setState(() => layerOpen = false),
                      child: const SizedBox(),
                    )
                  : const SizedBox(),
            );
          },
        ),
      );
      setHome(() => layerOpen = true);
      await tester.pumpAndSettle();
      expect(frameworkHandlesBack.last, isTrue);

      setHome(() {
        if (leavePage) {
          pageActive = false;
        } else {
          layerOpen = false;
        }
      });
      await tester.pumpAndSettle();
      expect(layerOpen, isFalse);
    }

    testWidgets('goes to Android while nothing is above the home page', (
      tester,
    ) async {
      await pumpHome(tester, home: _page('home'));
      expect(frameworkHandlesBack.last, isFalse);

      unawaited(
        Navigator.of(
          tester.element(find.text('home')),
        ).push(_commonRoute('page')()),
      );
      await tester.pumpAndSettle();
      expect(frameworkHandlesBack.last, isTrue);

      expect(await _start(tester), isTrue);
      await _commit(tester);
      expect(find.text('page'), findsNothing);
      expect(frameworkHandlesBack.last, isFalse);
    });

    testWidgets('stays in the app while a back layer is open on home', (
      tester,
    ) async {
      var layerOpen = false;
      late StateSetter setLayer;
      await pumpHome(
        tester,
        home: StatefulBuilder(
          builder: (context, setState) {
            setLayer = setState;
            return layerOpen
                ? BackLayerScope(
                    onBack: () => setState(() => layerOpen = false),
                    child: const SizedBox(),
                  )
                : const SizedBox();
          },
        ),
      );
      expect(frameworkHandlesBack.last, isFalse);

      setLayer(() => layerOpen = true);
      await tester.pumpAndSettle();
      expect(frameworkHandlesBack.last, isTrue);

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(layerOpen, isFalse);
      expect(frameworkHandlesBack.last, isFalse);

      setLayer(() => layerOpen = true);
      await tester.pumpAndSettle();
      expect(frameworkHandlesBack.last, isTrue);
      setLayer(() => layerOpen = false);
      await tester.pumpAndSettle();
      expect(frameworkHandlesBack.last, isFalse);
    });

    for (final (name, predictiveBack, sdk, width, minimizeOnExit) in [
      ('when predictive back is off', false, 34, 400.0, true),
      ('below Android 13', true, 32, 400.0, true),
      (
        'in a wide layout, which keeps a navigator per page',
        true,
        34,
        1200.0,
        true,
      ),
      ('without minimize on exit', true, 34, 400.0, false),
    ]) {
      testWidgets('stays with the app $name', (tester) async {
        final container = await pumpHome(
          tester,
          predictiveBack: predictiveBack,
          sdk: sdk,
          width: width,
          minimizeOnExit: minimizeOnExit,
        );
        expect(frameworkHandlesBack, isNotEmpty);
        expect(frameworkHandlesBack, everyElement(isTrue));

        await tester.binding.handlePopRoute();
        await tester.pump();
        final systemAction =
            container.read(systemActionProvider.notifier) as _CloseCounter;
        expect(systemAction.closes, 1);
      });
    }

    for (final leavePage in [false, true]) {
      final closing = leavePage ? 'leaving its page' : 'removing it';

      testWidgets('goes to Android after closing a back layer by $closing', (
        tester,
      ) async {
        await openAndCloseLayer(tester, leavePage: leavePage);
        expect(frameworkHandlesBack.last, isFalse);
      });

      for (final (name, predictiveBack, minimizeOnExit) in [
        ('when predictive back is off', false, true),
        ('without minimize on exit', true, false),
      ]) {
        testWidgets('keeps back in the app while closing a back layer by '
            '$closing $name', (tester) async {
          await openAndCloseLayer(
            tester,
            leavePage: leavePage,
            predictiveBack: predictiveBack,
            minimizeOnExit: minimizeOnExit,
          );
          expect(frameworkHandlesBack, everyElement(isTrue));
        });
      }
    }
  });
}
