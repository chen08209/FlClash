import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/providers/database.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/dashboard/widgets/dns_queries.dart';
import 'package:fl_clash/views/dns_queries.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/glyph_finders.dart';
import '../../helpers/test_app.dart';
import '../../helpers/test_profiles.dart';

const _mobileSize = Size(400, 800);
final _shortTop = _mobileSize.height * (1 - snapSheetDetents.first);
final _tallTop = _mobileSize.height * (1 - snapSheetDetents.last);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer(
      overrides: [profilesProvider.overrideWith(TestProfiles.new)],
    );
    globalState.container = container;
    container.read(viewSizeProvider.notifier).value = const Size(1200, 1000);
  });

  tearDown(() => container.dispose());

  void seedDnsQueries(int count) {
    final notifier = container.read(dnsQueriesProvider.notifier);
    notifier.value = FixedList<DnsQuery>(500);
    for (var index = 0; index < count; index++) {
      notifier.addQuery(
        DnsQuery(
          domain: 'host-$index.example',
          type: 'A',
          answers: const ['1.1.1.1'],
          rcode: 'NOERROR',
          delay: 12,
          time: DateTime.utc(2026, 9, 18, 4, 30),
        ),
      );
    }
  }

  Future<void> pumpCard(
    WidgetTester tester, {
    Size size = const Size(1200, 1000),
  }) async {
    container.read(viewSizeProvider.notifier).value = size;
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TestApp(
          child: Scaffold(body: ListView(children: const [DnsQueriesCard()])),
        ),
      ),
    );
    await tester.pump();
  }

  double sheetTop(WidgetTester tester) {
    return tester.getTopLeft(find.byType(SheetDragHandle)).dy;
  }

  /// Drags the sheet by its title, above anything the content can scroll.
  Future<void> flingSheet(WidgetTester tester, double dy) {
    return tester.flingFrom(
      Offset(_mobileSize.width / 2, sheetTop(tester) + sheetAppBarHeight / 2),
      Offset(0, dy),
      900,
    );
  }

  testWidgets('shows the query count and follows it', (tester) async {
    await pumpCard(tester);

    expect(find.text('DNS queries'), findsOneWidget);
    expect(find.text('0'), findsOneWidget);

    container.read(dnsQueryCountProvider.notifier).value = 1234;
    await tester.pump();

    // The count repaints on the throttled cadence, not per query.
    expect(find.text('0'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 301));

    expect(find.text('1234'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('tapping the card opens the DNS list beside it', (tester) async {
    await pumpCard(tester);

    await tester.tap(find.byType(DnsQueriesCard));
    await tester.pumpAndSettle();

    expect(find.byType(DnsQueriesView), findsOneWidget);
    // A sheet this wide has nothing to drag between.
    expect(find.byType(SheetDragHandle), findsNothing);

    await tester.tap(find.byGlyph(AppGlyphs.close));
    await tester.pumpAndSettle();

    expect(find.byType(DnsQueriesView), findsNothing);
    expect(find.text('DNS queries'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 2));
  });

  testWidgets(
    'the sheet opens at the short detent and flings to the tall one',
    (tester) async {
      seedDnsQueries(40);
      await pumpCard(tester, size: _mobileSize);

      await tester.tap(find.byType(DnsQueriesCard));
      await tester.pumpAndSettle();

      expect(find.byType(DnsQueriesView), findsOneWidget);
      expect(sheetTop(tester), closeTo(_shortTop, 1));

      await flingSheet(tester, -120);
      await tester.pumpAndSettle();

      expect(sheetTop(tester), closeTo(_tallTop, 1));

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(seconds: 2));
    },
  );

  testWidgets('swiping the list up opens the tall detent first', (
    tester,
  ) async {
    seedDnsQueries(40);
    await pumpCard(tester, size: _mobileSize);

    await tester.tap(find.byType(DnsQueriesCard));
    await tester.pumpAndSettle();

    await tester.flingFrom(const Offset(200, 600), const Offset(0, -150), 900);
    await tester.pumpAndSettle();

    expect(sheetTop(tester), closeTo(_tallTop, 1));

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 2));
  });

  testWidgets('flinging the sheet down stops at the short detent', (
    tester,
  ) async {
    seedDnsQueries(40);
    await pumpCard(tester, size: _mobileSize);

    await tester.tap(find.byType(DnsQueriesCard));
    await tester.pumpAndSettle();

    await flingSheet(tester, -120);
    await tester.pumpAndSettle();

    expect(sheetTop(tester), closeTo(_tallTop, 1));

    await flingSheet(tester, 200);
    await tester.pumpAndSettle();

    expect(sheetTop(tester), closeTo(_shortTop, 1));

    await flingSheet(tester, 200);
    await tester.pumpAndSettle();

    expect(find.byType(DnsQueriesView), findsOneWidget);
    expect(sheetTop(tester), closeTo(_shortTop, 1));

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 2));
  });

  testWidgets('a throw that runs the list out leaves the sheet alone', (
    tester,
  ) async {
    seedDnsQueries(40);
    await pumpCard(tester, size: _mobileSize);

    await tester.tap(find.byType(DnsQueriesCard));
    await tester.pumpAndSettle();

    await flingSheet(tester, -120);
    await tester.pumpAndSettle();
    await tester.drag(find.byType(DnsQueriesView), const Offset(0, -200));
    await tester.pumpAndSettle();

    expect(sheetTop(tester), closeTo(_tallTop, 1));

    await tester.fling(find.byType(DnsQueriesView), const Offset(0, 100), 2500);
    await tester.pumpAndSettle();

    expect(sheetTop(tester), closeTo(_tallTop, 1));

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 2));
  });

  testWidgets('the short detent gives under a drag and springs back', (
    tester,
  ) async {
    seedDnsQueries(40);
    await pumpCard(tester, size: _mobileSize);

    await tester.tap(find.byType(DnsQueriesCard));
    await tester.pumpAndSettle();

    final floor = sheetTop(tester);
    final gesture = await tester.startGesture(
      Offset(_mobileSize.width / 2, floor + sheetAppBarHeight / 2),
    );
    await gesture.moveBy(const Offset(0, 140));
    await tester.pump();

    final pulled = sheetTop(tester);
    expect(pulled, greaterThan(floor + 1));
    expect(pulled, lessThan(floor + 100));

    await gesture.up();
    await tester.pumpAndSettle();

    expect(sheetTop(tester), closeTo(floor, 1));

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 2));
  });

  testWidgets('the sheet closes from its header button', (tester) async {
    seedDnsQueries(40);
    await pumpCard(tester, size: _mobileSize);

    await tester.tap(find.byType(DnsQueriesCard));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Close'));
    await tester.pumpAndSettle();

    expect(find.byType(DnsQueriesView), findsNothing);
    expect(find.text('DNS queries'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 2));
  });
}
