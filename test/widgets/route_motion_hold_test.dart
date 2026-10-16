import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/ui/paged_sheet.dart';
import 'package:fl_clash/ui/route_motion_hold.dart';
import 'package:fl_clash/ui/sheet.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/test_app.dart';

class _Feed extends StatefulWidget {
  const _Feed({required this.source});

  final ValueNotifier<int> source;

  @override
  State<_Feed> createState() => _FeedState();
}

class _FeedState extends State<_Feed> with RouteMotionHoldMixin<_Feed> {
  late int _shown = widget.source.value;

  @override
  void initState() {
    super.initState();
    widget.source.addListener(_handleSource);
  }

  @override
  void dispose() {
    widget.source.removeListener(_handleSource);
    super.dispose();
  }

  void _handleSource() {
    updateWhenRouteSettled(() => setState(() => _shown = widget.source.value));
  }

  @override
  Widget build(BuildContext context) => Text('shown $_shown');
}

class _Arrival extends StatefulWidget {
  const _Arrival({required this.settles});

  final List<String> settles;

  @override
  State<_Arrival> createState() => _ArrivalState();
}

class _ArrivalState extends State<_Arrival> with RouteSettledMixin<_Arrival> {
  @override
  void didSettleRoute() => setState(() => widget.settles.add('settled'));

  @override
  Widget build(BuildContext context) {
    return Text(routeSettled ? 'settled' : 'arriving');
  }
}

void main() {
  late ValueNotifier<int> source;
  late GlobalKey<NavigatorState> navigator;

  setUp(() {
    source = ValueNotifier(0);
    navigator = GlobalKey<NavigatorState>();
  });

  tearDown(() => source.dispose());

  Future<void> pumpFeed(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: navigator,
        home: Scaffold(body: _Feed(source: source)),
      ),
    );
  }

  testWidgets('applies updates at once while the route is still', (
    tester,
  ) async {
    await pumpFeed(tester);

    source.value = 1;
    await tester.pump();

    expect(find.text('shown 1'), findsOneWidget);
  });

  testWidgets('holds updates while covered and replays the latest', (
    tester,
  ) async {
    await pumpFeed(tester);

    navigator.currentState!.push(
      MaterialPageRoute<void>(builder: (_) => const Scaffold()),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    source.value = 1;
    source.value = 2;
    await tester.pump();

    expect(find.text('shown 0', skipOffstage: false), findsOneWidget);

    await tester.pumpAndSettle();
    expect(find.text('shown 2', skipOffstage: false), findsOneWidget);
  });

  testWidgets('holds updates through a user gesture', (tester) async {
    await pumpFeed(tester);

    navigator.currentState!.didStartUserGesture();
    await tester.pump();
    source.value = 3;
    await tester.pump();
    expect(find.text('shown 0'), findsOneWidget);

    navigator.currentState!.didStopUserGesture();
    await tester.pump();
    expect(find.text('shown 3'), findsOneWidget);
  });

  group('under a sheet', () {
    Future<void> pumpOpener(WidgetTester tester, Widget content) async {
      const view = Size(400, 900);
      tester.view.physicalSize = view;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        TestApp(
          wrapInProviderScope: true,
          child: Scaffold(
            body: Column(
              children: [
                _Feed(source: source),
                Builder(
                  builder: (context) => TextButton(
                    onPressed: () => showSnapSheet<void>(
                      context,
                      builder: (_, _) => content,
                    ),
                    child: const Text('open'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      ProviderScope.containerOf(
        tester.element(find.text('open')),
      ).read(viewSizeProvider.notifier).value = view;
      await tester.pumpAndSettle();
      await tester.tap(find.text('open'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
    }

    testWidgets('holds the page below while a sheet slides over it', (
      tester,
    ) async {
      await pumpOpener(tester, const Scaffold(body: Text('sheet')));

      source.value = 1;
      await tester.pump();
      expect(find.text('shown 0'), findsOneWidget);

      await tester.pumpAndSettle();
      expect(find.text('shown 1'), findsOneWidget);
    });

    testWidgets('holds a page in a sheet while the sheet slides in', (
      tester,
    ) async {
      final inSheet = ValueNotifier(0);
      addTearDown(inSheet.dispose);
      await pumpOpener(
        tester,
        NestedPagedSheet(
          builder: (_) => Scaffold(body: _Feed(source: inSheet)),
        ),
      );

      inSheet.value = 1;
      await tester.pump();
      expect(find.text('shown 0'), findsNWidgets(2));

      await tester.pumpAndSettle();
      expect(find.text('shown 1'), findsOneWidget);
    });
  });

  group('RouteSettledMixin', () {
    testWidgets('settles at once on a page that sits still', (tester) async {
      final settles = <String>[];
      await tester.pumpWidget(MaterialApp(home: _Arrival(settles: settles)));
      await tester.pump();

      expect(settles, ['settled']);
      expect(find.text('settled'), findsOneWidget);
    });

    testWidgets('settles once the route bringing it in has arrived', (
      tester,
    ) async {
      final settles = <String>[];
      await tester.pumpWidget(
        MaterialApp(navigatorKey: navigator, home: const Scaffold()),
      );

      navigator.currentState!.push(
        MaterialPageRoute<void>(builder: (_) => _Arrival(settles: settles)),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(settles, isEmpty);
      expect(find.text('arriving'), findsOneWidget);

      await tester.pumpAndSettle();

      expect(settles, ['settled']);
      expect(find.text('settled'), findsOneWidget);

      navigator.currentState!.push(
        MaterialPageRoute<void>(builder: (_) => const Scaffold()),
      );
      await tester.pumpAndSettle();
      navigator.currentState!.pop();
      await tester.pumpAndSettle();

      expect(settles, ['settled']);
    });
  });
}
