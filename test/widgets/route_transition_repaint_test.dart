import 'package:fl_clash/common/app_localizations.dart';
import 'package:fl_clash/common/app_ports.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/manager/theme_manager.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/pages/home.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/ui/icons/icons.dart';
import 'package:fl_clash/ui/ui.dart';
import 'package:fl_clash/views/navigation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import '../helpers/host_scaffold.dart';

const _size = Size(400, 860);

Widget _rows() => ListView(
  children: [
    generateSection(
      title: 'Section',
      items: [
        for (var i = 0; i < 8; i++)
          ListItem.open(
            title: Text('Row $i'),
            widget: const HostScaffold(body: Center(child: Text('Opened'))),
          ),
      ],
    ),
  ],
);

void main() {
  setUp(() {
    navigationPort = navigation;
    addTearDown(() => navigationPort = null);
  });

  testWidgets('a push repaints only its routes and the row it opened from', (
    tester,
  ) async {
    tester.view.physicalSize = _size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final container = ProviderContainer(
      overrides: [
        navigationItemsStateProvider.overrideWithValue(
          NavigationItemsState(
            value: [
              NavigationItem(
                glyph: AppGlyphs.tools,
                label: PageLabel.tools,
                builder: (_) => _rows(),
              ),
              NavigationItem(
                glyph: AppGlyphs.dashboard,
                label: PageLabel.dashboard,
                builder: (_) => const SizedBox(),
              ),
            ],
          ),
        ),
      ],
    );
    addTearDown(container.dispose);
    globalState.container = container;
    container.read(viewSizeProvider.notifier).value = _size;
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: PrismApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            AppUiLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.delegate.supportedLocales,
          builder: (_, child) => ThemeManager(child: child!),
          onGenerateRoute: (settings) =>
              HomeRoute(settings: settings, builder: (_) => const HomePage()),
        ),
      ),
    );
    await tester.pumpAndSettle();
    container.read(currentPageLabelProvider.notifier).toPage(PageLabel.tools);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Row 3'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 16));
    await tester.pump(const Duration(milliseconds: 16));

    final repainted = <RenderObject?>{};
    debugOnProfilePaint = (renderObject) {
      RenderObject? boundary = renderObject.parent;
      while (boundary != null && !boundary.isRepaintBoundary) {
        boundary = boundary.parent;
      }
      repainted.add(boundary);
    };
    addTearDown(() => debugOnProfilePaint = null);
    await tester.pump(const Duration(milliseconds: 16));
    debugOnProfilePaint = null;

    expect(find.text('Opened'), findsOneWidget);
    expect(repainted.where((boundary) => boundary?.parent == null), isEmpty);
    final untapped = tester
        .renderObjectList(
          find.ancestor(
            of: find.text('Row 0'),
            matching: find.byType(RepaintBoundary),
          ),
        )
        .take(2);
    expect(repainted.intersection(untapped.toSet()), isEmpty);
  });
}
