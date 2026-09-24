import 'package:fl_clash/widgets/route_motion_hold.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

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
  Widget build(BuildContext context) {
    return Scaffold(body: Text('shown $_shown'));
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
        home: _Feed(source: source),
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
}
