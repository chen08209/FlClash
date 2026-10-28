import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/proxies/card.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/test_app.dart';
import '../helpers/test_profiles.dart';
import '../helpers/context_menu.dart';

const _testUrl = 'https://example.com/generate_204';

class _RecordingProxiesAction extends ProxiesAction {
  static final List<String> tested = [];
  static final List<String> copied = [];
  static final List<String> selected = [];

  @override
  void changeProxyDebounce(String groupName, String proxyName) {
    selected.add(proxyName);
  }

  @override
  Future<void> copyProxy(String proxyName) async {
    copied.add(proxyName);
  }

  @override
  Future<void> proxyDelayTest(Proxy proxy, [String? testUrl]) async {
    tested.add(proxy.name);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;

  setUp(() {
    _RecordingProxiesAction.tested.clear();
    _RecordingProxiesAction.copied.clear();
    _RecordingProxiesAction.selected.clear();
    container = ProviderContainer(
      overrides: [
        profilesProvider.overrideWith(TestProfiles.new),
        proxiesActionProvider.overrideWith(_RecordingProxiesAction.new),
        delayDataSourceProvider.overrideWithBuild(
          (_, _) => {
            _testUrl: {'proxy 0': 123, 'proxy 1': 456},
          },
        ),
      ],
    );
    globalState.container = container;
    container.read(viewSizeProvider.notifier).value = const Size(900, 600);
  });

  tearDown(() => container.dispose());

  Future<void> pumpCards(
    WidgetTester tester,
    ProxyCardType type, {
    String proxyType = 'Shadowsocks',
  }) async {
    tester.view.physicalSize = const Size(900, 600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TestApp(
          homeBuilder: (child) => Scaffold(body: child),
          child: Column(
            children: [
              for (var index = 0; index < 2; index++)
                SizedBox(
                  height: 120,
                  child: ProxyCard(
                    key: ValueKey('proxy $index'),
                    groupName: 'group',
                    testUrl: _testUrl,
                    proxy: Proxy(name: 'proxy $index', type: proxyType),
                    groupType: GroupType.Selector,
                    type: type,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> focusCard(WidgetTester tester, int index) async {
    for (var attempt = 0; attempt < 10; attempt++) {
      final context = FocusManager.instance.primaryFocus?.context;
      if (context?.findAncestorWidgetOfExactType<ProxyCard>()?.key ==
          ValueKey('proxy $index')) {
        return;
      }
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
    }
    fail('proxy card $index was not reachable by tab');
  }

  for (final type in ProxyCardType.values) {
    testWidgets('right click copies the targeted ${type.name} node', (
      tester,
    ) async {
      await pumpCards(tester, type);

      await rightClick(tester, find.byType(ProxyCard).at(1));
      await tester.pumpAndSettle();
      expect(find.text('Copy'), findsOneWidget);
      expect(_RecordingProxiesAction.copied, isEmpty);
      expect(_RecordingProxiesAction.selected, isEmpty);

      await tester.tap(find.text('Copy'));
      await tester.pumpAndSettle();

      expect(_RecordingProxiesAction.copied, ['proxy 1']);
      expect(_RecordingProxiesAction.selected, isEmpty);
      expect(tester.takeException(), isNull);
    });

    testWidgets('arrow right from a ${type.name} proxy card focuses its '
        'delay control', (tester) async {
      await pumpCards(tester, type);

      for (var index = 0; index < 2; index++) {
        await focusCard(tester, index);

        await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
        await tester.pump();

        final focusNode = FocusManager.instance.primaryFocus;
        expect(focusNode, isA<SkipTraversalFocusNode>());
        expect(
          find.descendant(
            of: find.byWidget(focusNode!.context!.widget),
            matching: find.text(index == 0 ? '123 ms' : '456 ms'),
          ),
          findsOneWidget,
        );
      }
    });
  }

  testWidgets('a group without a node definition has no copy action', (
    tester,
  ) async {
    await pumpCards(tester, ProxyCardType.standard, proxyType: 'Selector');

    await rightClick(tester, find.byType(ProxyCard).first);
    await tester.pumpAndSettle();

    expect(find.text('Select'), findsOneWidget);
    expect(find.text('Copy'), findsNothing);
  });

  testWidgets('the keyboard context menu can copy a node', (tester) async {
    await pumpCards(tester, ProxyCardType.standard);
    await focusCard(tester, 0);

    await tester.sendKeyEvent(LogicalKeyboardKey.contextMenu);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Copy'));
    await tester.pumpAndSettle();

    expect(_RecordingProxiesAction.copied, ['proxy 0']);
    expect(_RecordingProxiesAction.selected, isEmpty);
  });

  testWidgets('tab walks card to card without stopping on the delay control', (
    tester,
  ) async {
    await pumpCards(tester, ProxyCardType.standard);

    await focusCard(tester, 0);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();

    final context = FocusManager.instance.primaryFocus?.context;
    expect(
      context?.findAncestorWidgetOfExactType<ProxyCard>()?.key,
      const ValueKey('proxy 1'),
    );
  });

  testWidgets('enter on the delay control runs the delay test', (tester) async {
    await pumpCards(tester, ProxyCardType.standard);

    await focusCard(tester, 0);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pump();
    expect(FocusManager.instance.primaryFocus, isA<SkipTraversalFocusNode>());

    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();

    expect(_RecordingProxiesAction.tested, ['proxy 0']);
  });
}
