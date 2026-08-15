import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/manager/hotkey_manager.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/pages/home.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('desktop escape runs the back flow and exits search', (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
    final container = ProviderContainer();
    addTearDown(container.dispose);
    globalState.container = container;

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          navigatorKey: globalState.navigatorKey,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.delegate.supportedLocales,
          home: HotKeyManager(
            child: CommonScaffold(
              title: 'Logs',
              searchState: AppBarSearchState(onSearch: (_) {}),
              body: Center(
                child: TextButton(
                  onPressed: () {},
                  child: const Text('focus target'),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.search));
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsOneWidget);

    // Move focus off the text field: EditableText's own shortcuts swallow
    // escape on some platforms, so the escape binding applies outside the
    // text input. (tap does not focus widgets inside a scope in tests.)
    Focus.of(tester.element(find.text('focus target'))).requestFocus();
    await tester.pump();
    expect(
      FocusManager.instance.primaryFocus?.context
          ?.findAncestorWidgetOfExactType<TextField>(),
      isNull,
    );

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();

    expect(
      find.byType(TextField),
      findsNothing,
      reason: 'escape must exit search through the back flow',
    );
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('TV back exits search on the desktop nested route', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    var query = '';
    var closeCount = 0;
    final container = ProviderContainer(
      overrides: [
        navigationItemsStateProvider.overrideWithValue(
          NavigationItemsState(
            value: [
              NavigationItem(
                icon: const Icon(Icons.space_dashboard),
                label: PageLabel.dashboard,
                builder: (_) => CommonScaffold(
                  key: const GlobalObjectKey(PageLabel.dashboard),
                  title: 'Search page',
                  searchState: AppBarSearchState(
                    onSearch: (value) {
                      query = value;
                    },
                  ),
                  body: const SizedBox(),
                ),
              ),
              NavigationItem(
                icon: const Icon(Icons.construction),
                label: PageLabel.tools,
                builder: (_) => const SizedBox.shrink(),
              ),
            ],
          ),
        ),
        systemActionProvider.overrideWith(
          () => _TestSystemAction(() => closeCount++),
        ),
      ],
    );
    addTearDown(container.dispose);
    globalState.container = container;
    container.read(viewSizeProvider.notifier).value = const Size(1200, 800);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.delegate.supportedLocales,
          home: const HomePage(),
        ),
      ),
    );
    await tester.pump();
    expect(find.byType(NavigationRail), findsOneWidget);

    await tester.tap(find.byIcon(Icons.search));
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'needle');
    expect(query, 'needle');

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(closeCount, 0, reason: 'back must not fall through to app close');
    expect(find.byType(TextField), findsNothing);
    expect(query, isEmpty);
  });
}

class _TestSystemAction extends SystemAction {
  final int Function() closeCount;

  _TestSystemAction(this.closeCount);

  @override
  void build() {}

  @override
  Future<void> handleClose([bool exit = true]) async {
    closeCount();
  }
}
