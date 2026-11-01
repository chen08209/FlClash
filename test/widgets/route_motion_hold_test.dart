import 'dart:async';

import 'package:fl_clash/providers/app.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prism_ui/prism_ui.dart';

import '../helpers/test_app.dart';
import '../helpers/host_scaffold.dart';

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

class _FirstContent extends StatefulWidget {
  const _FirstContent({required this.source});

  final ValueNotifier<int> source;

  @override
  State<_FirstContent> createState() => _FirstContentState();
}

class _FirstContentState extends State<_FirstContent>
    with RouteMotionHoldMixin<_FirstContent> {
  int? _shown;

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
    showFirstContent(() => setState(() => _shown = widget.source.value));
  }

  @override
  Widget build(BuildContext context) => ArrivalHold(
    ready: _shown != null,
    child: Text(_shown == null ? 'waiting' : 'shown $_shown'),
  );
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

class _ArrivalList extends StatefulWidget {
  const _ArrivalList();

  @override
  State<_ArrivalList> createState() => _ArrivalListState();
}

class _ArrivalListState extends State<_ArrivalList>
    with ArrivalCacheExtentMixin<_ArrivalList> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      scrollCacheExtent: arrivalCacheExtent,
      itemExtent: 100,
      itemCount: 50,
      itemBuilder: (_, index) => Text('row $index'),
    );
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
      HostApp(
        navigatorKey: navigator,
        home: HostScaffold(body: _Feed(source: source)),
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
      CardPageRoute<void>(builder: (_) => const HostScaffold()),
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

  testWidgets('keeps holding until what the stop set off has finished', (
    tester,
  ) async {
    final fade = AnimationController(
      vsync: const TestVSync(),
      duration: const Duration(milliseconds: 200),
    );
    addTearDown(fade.dispose);
    await tester.pumpWidget(
      HostApp(
        navigatorKey: navigator,
        home: HostScaffold(body: _Feed(source: source)),
      ),
    );
    navigator.currentState!.push(
      CardPageRoute<void>(builder: (_) => const HostScaffold()),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    source.value = 1;
    final route = ModalRoute.of(
      tester.element(find.byType(_Feed, skipOffstage: false)),
    )!;
    var settledAt = false;
    void startFade(AnimationStatus status) {
      if (!route.secondaryAnimation!.isAnimating && !settledAt) {
        settledAt = true;
        fade.forward();
      }
    }

    route.secondaryAnimation!.addStatusListener(startFade);
    addTearDown(
      () => route.secondaryAnimation!.removeStatusListener(startFade),
    );
    while (!settledAt) {
      await tester.pump(const Duration(milliseconds: 16));
    }
    await tester.pump(const Duration(milliseconds: 16));
    await tester.pump(const Duration(milliseconds: 16));

    expect(find.text('shown 0', skipOffstage: false), findsOneWidget);

    await tester.pumpAndSettle();
    expect(find.text('shown 1', skipOffstage: false), findsOneWidget);
  });

  group('showFirstContent', () {
    testWidgets('shows at once while the push is held for it', (tester) async {
      await tester.pumpWidget(
        HostApp(navigatorKey: navigator, home: const HostScaffold()),
      );
      navigator.currentState!.push(
        CardPageRoute<void>(builder: (_) => _FirstContent(source: source)),
      );
      await tester.pump();

      source.value = 1;
      await tester.pump();

      expect(find.text('shown 1'), findsOneWidget);
      await tester.pumpAndSettle();
    });

    testWidgets('waits for the route once the push has begun', (tester) async {
      await tester.pumpWidget(
        HostApp(navigatorKey: navigator, home: const HostScaffold()),
      );
      navigator.currentState!.push(
        CardPageRoute<void>(builder: (_) => _FirstContent(source: source)),
      );
      await tester.pump();
      await tester.pump(arrivalHoldLimit);
      await tester.pump(const Duration(milliseconds: 32));
      await tester.pump(const Duration(milliseconds: 32));

      source.value = 1;
      await tester.pump();
      expect(find.text('waiting'), findsOneWidget);

      await tester.pumpAndSettle();
      expect(find.text('shown 1'), findsOneWidget);
    });
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
          child: HostScaffold(
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
      await pumpOpener(tester, const HostScaffold(body: Text('sheet')));

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
          builder: (_) => HostScaffold(body: _Feed(source: inSheet)),
        ),
      );

      inSheet.value = 1;
      await tester.pump();
      expect(find.text('shown 0'), findsNWidgets(2));

      await tester.pumpAndSettle();
      expect(find.text('shown 1'), findsOneWidget);
    });
  });

  group('ArrivalCacheExtentMixin', () {
    testWidgets('builds rows ahead only once nothing animates', (tester) async {
      final spinner = AnimationController(
        vsync: const TestVSync(),
        duration: const Duration(seconds: 1),
      );
      addTearDown(spinner.dispose);
      await tester.pumpWidget(
        HostApp(navigatorKey: navigator, home: const HostScaffold()),
      );
      navigator.currentState!.push(
        HostPageRoute<void>(
          builder: (_) => const Align(
            alignment: Alignment.topCenter,
            child: SizedBox(height: 300, child: _ArrivalList()),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final ahead = find.text('row 3', skipOffstage: false);
      expect(ahead, findsOneWidget);

      navigator.currentState!.pop();
      await tester.pumpAndSettle();
      navigator.currentState!.push(
        HostPageRoute<void>(
          builder: (_) => const Align(
            alignment: Alignment.topCenter,
            child: SizedBox(height: 300, child: _ArrivalList()),
          ),
        ),
      );
      unawaited(spinner.repeat());
      await tester.pump();
      for (var frame = 0; frame < 40; frame++) {
        await tester.pump(const Duration(milliseconds: 16));
      }
      expect(ahead, findsNothing);

      spinner.stop();
      await tester.pump();
      await tester.pump();
      expect(ahead, findsOneWidget);
    });
  });

  group('RouteSettledMixin', () {
    testWidgets('settles at once on a page that sits still', (tester) async {
      final settles = <String>[];
      await tester.pumpWidget(HostApp(home: _Arrival(settles: settles)));
      await tester.pump();

      expect(settles, ['settled']);
      expect(find.text('settled'), findsOneWidget);
    });

    testWidgets('settles once the route bringing it in has arrived', (
      tester,
    ) async {
      final settles = <String>[];
      await tester.pumpWidget(
        HostApp(navigatorKey: navigator, home: const HostScaffold()),
      );

      navigator.currentState!.push(
        HostPageRoute<void>(builder: (_) => _Arrival(settles: settles)),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(settles, isEmpty);
      expect(find.text('arriving'), findsOneWidget);

      await tester.pumpAndSettle();

      expect(settles, ['settled']);
      expect(find.text('settled'), findsOneWidget);

      navigator.currentState!.push(
        CardPageRoute<void>(builder: (_) => const HostScaffold()),
      );
      await tester.pumpAndSettle();
      navigator.currentState!.pop();
      await tester.pumpAndSettle();

      expect(settles, ['settled']);
    });
  });
}
