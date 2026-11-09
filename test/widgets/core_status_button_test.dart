import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/ui/icons/icons.dart';
import 'package:fl_clash/views/dashboard/widgets/core_status_button.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/glyph_finders.dart';
import '../helpers/test_app.dart';
import '../helpers/host_scaffold.dart';

void main() {
  testWidgets(
    'holds connecting for the minimum duration after a fast restart',
    (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      globalState.container = container;
      container.read(coreStatusProvider.notifier).value = CoreStatus.connected;

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: TestApp(
            includeNavigatorKey: false,
            homeBuilder: (child) => HostScaffold(body: Center(child: child)),
            child: const CoreStatusButton(),
          ),
        ),
      );
      await tester.pump();

      expect(find.byGlyph(AppGlyphs.check), findsOneWidget);
      expect(find.byType(ActivityIndicator), findsNothing);

      container.read(coreStatusProvider.notifier).value = CoreStatus.connecting;
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byType(ActivityIndicator), findsOneWidget);
      expect(find.byGlyph(AppGlyphs.check), findsNothing);

      container.read(coreStatusProvider.notifier).value = CoreStatus.connected;
      await tester.pump();
      expect(find.byType(ActivityIndicator), findsOneWidget);
      expect(find.byGlyph(AppGlyphs.check), findsNothing);

      await tester.pump(const Duration(milliseconds: 199));
      expect(find.byType(ActivityIndicator), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 1));
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byGlyph(AppGlyphs.check), findsOneWidget);
      expect(find.byType(ActivityIndicator), findsNothing);

      await tester.pump(const Duration(seconds: 1));
      expect(find.byGlyph(AppGlyphs.check), findsOneWidget);
    },
  );

  testWidgets(
    'shows disconnected immediately when restart fails during the hold',
    (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      globalState.container = container;
      container.read(coreStatusProvider.notifier).value = CoreStatus.connected;

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: TestApp(
            includeNavigatorKey: false,
            homeBuilder: (child) => HostScaffold(body: Center(child: child)),
            child: const CoreStatusButton(),
          ),
        ),
      );
      await tester.pump();

      container.read(coreStatusProvider.notifier).value = CoreStatus.connecting;
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byType(ActivityIndicator), findsOneWidget);

      container.read(coreStatusProvider.notifier).value =
          CoreStatus.disconnected;
      await tester.pump();
      expect(find.byGlyph(AppGlyphs.refresh), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byGlyph(AppGlyphs.refresh), findsOneWidget);
      expect(find.byType(ActivityIndicator), findsNothing);

      await tester.pump(const Duration(seconds: 1));
      expect(find.byGlyph(AppGlyphs.refresh), findsOneWidget);
      expect(find.byType(ActivityIndicator), findsNothing);
    },
  );

  testWidgets('labels the status on desktop and keeps it an icon on mobile', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    globalState.container = container;
    container.read(coreStatusProvider.notifier).value = CoreStatus.disconnected;

    Future<void> pumpAt(Size size) async {
      container.read(viewSizeProvider.notifier).value = size;
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: TestApp(
            includeNavigatorKey: false,
            homeBuilder: (child) => HostScaffold(body: Center(child: child)),
            child: const CoreStatusButton(),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 400));
    }

    await pumpAt(const Size(1200, 800));
    expect(find.text('Disconnected'), findsOneWidget);
    expect(find.byGlyph(AppGlyphs.refresh), findsOneWidget);

    await pumpAt(const Size(400, 800));
    expect(find.text('Disconnected'), findsNothing);
    expect(find.byType(IconButton), findsOneWidget);
    expect(find.byGlyph(AppGlyphs.refresh), findsOneWidget);
    expect(find.byTooltip('Core status'), findsOneWidget);

    container.read(coreStatusProvider.notifier).value = CoreStatus.connecting;
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Connecting…'), findsNothing);
    expect(find.byType(IconButton), findsOneWidget);
    expect(find.byType(ActivityIndicator), findsOneWidget);
  });

  testWidgets('does not clip a connecting state longer than the hold', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    globalState.container = container;
    container.read(coreStatusProvider.notifier).value = CoreStatus.connected;

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TestApp(
          includeNavigatorKey: false,
          homeBuilder: (child) => HostScaffold(body: Center(child: child)),
          child: const CoreStatusButton(),
        ),
      ),
    );
    await tester.pump();

    container.read(coreStatusProvider.notifier).value = CoreStatus.connecting;
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));
    expect(find.byType(ActivityIndicator), findsOneWidget);

    container.read(coreStatusProvider.notifier).value = CoreStatus.connected;
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byGlyph(AppGlyphs.check), findsOneWidget);
    expect(find.byType(ActivityIndicator), findsNothing);

    await tester.pump(const Duration(seconds: 1));
    expect(find.byGlyph(AppGlyphs.check), findsOneWidget);
  });

  testWidgets('holds connecting when restarting from disconnected', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    globalState.container = container;
    container.read(coreStatusProvider.notifier).value = CoreStatus.disconnected;

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TestApp(
          includeNavigatorKey: false,
          homeBuilder: (child) => HostScaffold(body: Center(child: child)),
          child: const CoreStatusButton(),
        ),
      ),
    );
    await tester.pump();

    expect(find.byGlyph(AppGlyphs.refresh), findsOneWidget);

    container.read(coreStatusProvider.notifier).value = CoreStatus.connecting;
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(ActivityIndicator), findsOneWidget);
    expect(find.byGlyph(AppGlyphs.refresh), findsNothing);

    container.read(coreStatusProvider.notifier).value = CoreStatus.connected;
    await tester.pump();
    expect(find.byType(ActivityIndicator), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 199));
    expect(find.byType(ActivityIndicator), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 1));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byGlyph(AppGlyphs.check), findsOneWidget);
    expect(find.byType(ActivityIndicator), findsNothing);

    await tester.pump(const Duration(seconds: 1));
    expect(find.byGlyph(AppGlyphs.check), findsOneWidget);
  });
}
