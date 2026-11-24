import 'dart:math' as math;
import 'dart:typed_data';

import 'package:fl_clash/common/app_ports.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/pages/home.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/ui/icons/icons.dart';
import 'package:fl_clash/views/navigation.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../helpers/test_app.dart';
import '../helpers/host_scaffold.dart';

const _mobileSize = Size(400, 800);

final _lens = find.descendant(
  of: find.byType(FloatingNavigationBar),
  matching: find.byType(PositionedDirectional),
);
const _addLabel = 'Add';

IconButtonData _addAction() {
  return IconButtonData(
    glyph: AppGlyphs.add,
    onPressed: () {},
    tooltip: _addLabel,
  );
}

Widget _page(String title, {IconButtonData? primaryAction}) {
  return Scaffold(
    title: title,
    primaryAction: primaryAction,
    body: Text('page:$title'),
  );
}

Future<ProviderContainer> _pumpHome(
  WidgetTester tester, {
  List<Override> overrides = const [],
  bool settle = true,
}) async {
  tester.view.physicalSize = _mobileSize;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final container = ProviderContainer(
    overrides: [
      profilesProvider.overrideWithValue([
        const Profile(id: 1, autoUpdateDuration: Duration.zero),
      ]),
      suspendProvider.overrideWithValue(false),
      ...overrides,
      navigationItemsStateProvider.overrideWithValue(
        NavigationItemsState(
          value: [
            NavigationItem(
              glyph: AppGlyphs.dashboard,
              label: PageLabel.dashboard,
              builder: (_) => _page('dashboard'),
            ),
            NavigationItem(
              glyph: AppGlyphs.profiles,
              label: PageLabel.profiles,
              builder: (_) => _page('profiles', primaryAction: _addAction()),
            ),
            NavigationItem(
              glyph: AppGlyphs.tools,
              label: PageLabel.tools,
              builder: (_) => _page('tools'),
            ),
          ],
        ),
      ),
    ],
  );
  addTearDown(container.dispose);
  globalState.container = container;
  container.read(viewSizeProvider.notifier).value = _mobileSize;
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const TestApp(includeNavigatorKey: false, child: HomePage()),
    ),
  );
  if (settle) {
    await tester.pumpAndSettle();
  } else {
    await tester.pump(const Duration(seconds: 1));
  }
  return container;
}

Future<void> _pumpDock(WidgetTester tester, List<String> labels) {
  return tester.pumpWidget(
    TestApp(
      child: HostScaffold(
        body: Align(
          alignment: Alignment.bottomCenter,
          child: NavigationDock(
            destinations: [
              for (final label in labels)
                NavigationDockDestination(glyph: AppGlyphs.tools, label: label),
            ],
            selectedIndex: 0,
            onSelected: (_) {},
          ),
        ),
      ),
    ),
  );
}

// UIKit's own frames (iOS 27 simulator, standalone UITabBar): per bar width,
// each item's start and width from the bar's start edge.
const _uikitTabBars = [
  (
    name: 'en5',
    labels: <double>[53.67, 36.33, 46.0, 37.67, 26.33],
    frames: {
      300: [
        (4.00, 74.53),
        (58.53, 62.87),
        (101.40, 66.87),
        (148.27, 62.87),
        (191.13, 62.87),
      ],
      340: [
        (4.00, 82.53),
        (66.53, 70.87),
        (117.40, 74.87),
        (172.27, 70.87),
        (223.13, 70.87),
      ],
      375: [
        (4.00, 90.11),
        (74.11, 77.66),
        (131.76, 81.92),
        (193.69, 77.66),
        (251.34, 77.66),
      ],
      390: [
        (4.00, 93.56),
        (77.56, 80.49),
        (138.05, 84.97),
        (203.02, 80.49),
        (263.51, 80.49),
      ],
      398: [
        (4.00, 95.40),
        (79.40, 82.00),
        (141.40, 86.59),
        (208.00, 82.00),
        (270.00, 82.00),
      ],
      402: [
        (4.00, 96.32),
        (80.32, 82.76),
        (143.08, 87.41),
        (210.48, 82.76),
        (273.24, 82.76),
      ],
      412: [
        (4.00, 98.62),
        (82.62, 84.65),
        (147.26, 89.44),
        (216.70, 84.65),
        (281.35, 84.65),
      ],
      414: [
        (4.00, 87.67),
        (73.08, 87.67),
        (142.17, 87.67),
        (211.25, 87.67),
        (280.33, 87.67),
      ],
      440: [
        (4.00, 87.67),
        (79.58, 87.67),
        (155.17, 87.67),
        (230.75, 87.67),
        (306.33, 87.67),
      ],
      480: [
        (4.00, 92.60),
        (88.35, 92.60),
        (172.70, 92.60),
        (257.05, 92.60),
        (341.40, 92.60),
      ],
    },
  ),
  (
    name: 'zh5',
    labels: <double>[30.0, 20.0, 20.0, 20.0, 20.0],
    frames: {
      300: [
        (4.00, 66.00),
        (50.00, 66.00),
        (96.00, 66.00),
        (142.00, 66.00),
        (188.00, 66.00),
      ],
      340: [
        (4.00, 74.00),
        (58.00, 74.00),
        (112.00, 74.00),
        (166.00, 74.00),
        (220.00, 74.00),
      ],
      375: [
        (4.00, 81.00),
        (65.00, 81.00),
        (126.00, 81.00),
        (187.00, 81.00),
        (248.00, 81.00),
      ],
      390: [
        (4.00, 84.00),
        (68.00, 84.00),
        (132.00, 84.00),
        (196.00, 84.00),
        (260.00, 84.00),
      ],
      398: [
        (4.00, 76.20),
        (71.95, 76.20),
        (139.90, 76.20),
        (207.85, 76.20),
        (275.80, 76.20),
      ],
      402: [
        (4.00, 77.00),
        (72.75, 77.00),
        (141.50, 77.00),
        (210.25, 77.00),
        (279.00, 77.00),
      ],
      412: [
        (4.00, 79.00),
        (74.75, 79.00),
        (145.50, 79.00),
        (216.25, 79.00),
        (287.00, 79.00),
      ],
      414: [
        (4.00, 79.40),
        (75.15, 79.40),
        (146.30, 79.40),
        (217.45, 79.40),
        (288.60, 79.40),
      ],
      440: [
        (4.00, 84.60),
        (80.35, 84.60),
        (156.70, 84.60),
        (233.05, 84.60),
        (309.40, 84.60),
      ],
      480: [
        (4.00, 92.60),
        (88.35, 92.60),
        (172.70, 92.60),
        (257.05, 92.60),
        (341.40, 92.60),
      ],
    },
  ),
  (
    name: 'en4',
    labels: <double>[53.67, 36.33, 37.67, 26.33],
    frames: {
      300: [(4.00, 86.34), (70.34, 74.55), (124.89, 74.55), (179.45, 74.55)],
      340: [(4.00, 97.88), (81.88, 84.04), (145.92, 84.04), (209.96, 84.04)],
      348: [(4.00, 100.18), (84.18, 85.94), (150.12, 85.94), (216.06, 85.94)],
      350: [(4.00, 100.76), (84.76, 86.41), (151.17, 86.41), (217.59, 86.41)],
      355: [(4.00, 102.20), (86.20, 87.60), (153.80, 87.60), (221.40, 87.60)],
      360: [(4.00, 93.67), (76.11, 93.67), (148.22, 93.67), (220.33, 93.67)],
      375: [(4.00, 93.67), (81.11, 93.67), (158.22, 93.67), (235.33, 93.67)],
      390: [(4.00, 93.67), (86.11, 93.67), (168.22, 93.67), (250.33, 93.67)],
      398: [(4.00, 94.00), (88.67, 94.00), (173.33, 94.00), (258.00, 94.00)],
      402: [(4.00, 95.00), (89.67, 95.00), (175.33, 95.00), (261.00, 95.00)],
      412: [(4.00, 97.50), (92.17, 97.50), (180.33, 97.50), (268.50, 97.50)],
      414: [(4.00, 98.00), (92.67, 98.00), (181.33, 98.00), (270.00, 98.00)],
      440: [
        (4.00, 104.50),
        (99.17, 104.50),
        (194.33, 104.50),
        (289.50, 104.50),
      ],
      480: [
        (4.00, 114.50),
        (109.17, 114.50),
        (214.33, 114.50),
        (319.50, 114.50),
      ],
    },
  ),
  (
    name: 'zh4',
    labels: <double>[30.0, 20.0, 20.0, 20.0],
    frames: {
      300: [(4.00, 77.50), (61.50, 77.50), (119.00, 77.50), (176.50, 77.50)],
      340: [(4.00, 87.50), (71.50, 87.50), (139.00, 87.50), (206.50, 87.50)],
      348: [(4.00, 94.00), (72.00, 94.00), (140.00, 94.00), (208.00, 94.00)],
      350: [(4.00, 94.00), (72.67, 94.00), (141.33, 94.00), (210.00, 94.00)],
      355: [(4.00, 94.00), (74.33, 94.00), (144.67, 94.00), (215.00, 94.00)],
      360: [(4.00, 94.00), (76.00, 94.00), (148.00, 94.00), (220.00, 94.00)],
      375: [(4.00, 94.00), (81.00, 94.00), (158.00, 94.00), (235.00, 94.00)],
      390: [(4.00, 95.00), (85.67, 95.00), (167.33, 95.00), (249.00, 95.00)],
      398: [(4.00, 97.00), (87.67, 97.00), (171.33, 97.00), (255.00, 97.00)],
      402: [(4.00, 98.00), (88.67, 98.00), (173.33, 98.00), (258.00, 98.00)],
      412: [
        (4.00, 100.50),
        (91.17, 100.50),
        (178.33, 100.50),
        (265.50, 100.50),
      ],
      414: [
        (4.00, 101.00),
        (91.67, 101.00),
        (179.33, 101.00),
        (267.00, 101.00),
      ],
      440: [
        (4.00, 107.50),
        (98.17, 107.50),
        (192.33, 107.50),
        (286.50, 107.50),
      ],
      480: [
        (4.00, 117.50),
        (108.17, 117.50),
        (212.33, 117.50),
        (316.50, 117.50),
      ],
    },
  ),
  (
    name: 'ja5',
    labels: <double>[66.67, 38.0, 47.67, 57.0, 28.67],
    frames: {
      300: [
        (4.00, 81.60),
        (65.60, 56.93),
        (102.53, 62.60),
        (145.13, 71.93),
        (197.07, 56.93),
      ],
      340: [
        (4.00, 89.60),
        (73.60, 64.93),
        (118.53, 70.60),
        (169.13, 79.93),
        (229.07, 64.93),
      ],
      375: [
        (4.00, 96.60),
        (80.60, 71.93),
        (132.53, 77.60),
        (190.13, 86.93),
        (257.07, 71.93),
      ],
      390: [
        (4.00, 99.83),
        (83.83, 74.80),
        (138.63, 80.55),
        (199.18, 90.02),
        (269.20, 74.80),
      ],
      398: [
        (4.00, 101.83),
        (85.83, 76.17),
        (142.00, 82.06),
        (204.06, 91.77),
        (275.83, 76.17),
      ],
      402: [
        (4.00, 102.83),
        (86.83, 76.85),
        (143.68, 82.82),
        (206.50, 92.65),
        (279.15, 76.85),
      ],
      412: [
        (4.00, 105.32),
        (89.32, 78.57),
        (147.89, 84.71),
        (212.60, 94.83),
        (287.43, 78.57),
      ],
      414: [
        (4.00, 105.82),
        (89.82, 78.91),
        (148.73, 85.09),
        (213.82, 95.27),
        (289.09, 78.91),
      ],
      440: [
        (4.00, 112.30),
        (96.30, 83.36),
        (159.67, 90.01),
        (229.68, 100.96),
        (310.64, 83.36),
      ],
      480: [
        (4.00, 100.67),
        (86.33, 100.67),
        (168.67, 100.67),
        (251.00, 100.67),
        (333.33, 100.67),
      ],
    },
  ),
  (
    name: 'ru4',
    labels: <double>[37.33, 38.33, 47.0, 70.33],
    frames: {
      300: [(4.00, 69.17), (53.17, 69.17), (102.33, 74.17), (156.50, 97.50)],
      340: [(4.00, 78.48), (62.48, 78.48), (120.95, 83.89), (184.84, 109.16)],
      375: [(4.00, 86.06), (70.06, 86.06), (136.11, 92.17), (208.28, 120.72)],
      390: [(4.00, 95.57), (71.57, 95.57), (139.14, 101.83), (212.97, 131.03)],
      398: [(4.00, 97.31), (73.31, 97.31), (142.61, 103.72), (218.33, 133.67)],
      402: [(4.00, 98.17), (74.17, 98.17), (144.34, 104.67), (221.01, 134.99)],
      412: [
        (4.00, 100.34),
        (76.34, 100.34),
        (148.67, 107.03),
        (227.71, 138.29),
      ],
      414: [
        (4.00, 100.77),
        (76.77, 100.77),
        (149.54, 107.51),
        (229.05, 138.95),
      ],
      440: [
        (4.00, 110.33),
        (97.22, 110.33),
        (190.44, 110.33),
        (283.67, 110.33),
      ],
      480: [
        (4.00, 114.50),
        (109.17, 114.50),
        (214.33, 114.50),
        (319.50, 114.50),
      ],
    },
  ),
  (
    name: 'fr4',
    labels: <double>[79.33, 33.33, 32.0, 29.0],
    frames: {
      300: [(4.00, 105.50), (89.50, 68.17), (137.67, 68.17), (185.83, 68.17)],
      340: [(4.00, 117.34), (101.34, 77.55), (158.90, 77.55), (216.45, 77.55)],
      375: [(4.00, 129.96), (113.96, 85.01), (178.97, 85.01), (243.99, 85.01)],
      390: [(4.00, 140.48), (116.48, 94.50), (182.99, 94.50), (249.50, 94.50)],
      398: [(4.00, 143.37), (119.37, 96.21), (187.58, 96.21), (255.79, 96.21)],
      402: [(4.00, 144.81), (120.81, 97.06), (189.87, 97.06), (258.94, 97.06)],
      412: [(4.00, 148.42), (124.42, 99.19), (195.61, 99.19), (266.81, 99.19)],
      414: [(4.00, 149.14), (125.14, 99.62), (196.76, 99.62), (268.38, 99.62)],
      440: [
        (4.00, 158.51),
        (134.51, 105.16),
        (211.67, 105.16),
        (288.84, 105.16),
      ],
      480: [
        (4.00, 119.33),
        (107.56, 119.33),
        (211.11, 119.33),
        (314.67, 119.33),
      ],
    },
  ),
  (
    name: 'es5',
    labels: <double>[27.33, 36.33, 55.0, 38.0, 67.0],
    frames: {
      300: [
        (4.00, 58.40),
        (42.40, 58.40),
        (80.80, 71.40),
        (132.20, 58.40),
        (170.60, 83.40),
      ],
      340: [
        (4.00, 66.40),
        (50.40, 66.40),
        (96.80, 79.40),
        (156.20, 66.40),
        (202.60, 91.40),
      ],
      375: [
        (4.00, 73.40),
        (57.40, 73.40),
        (110.80, 86.40),
        (177.20, 73.40),
        (230.60, 98.40),
      ],
      390: [
        (4.00, 76.10),
        (60.10, 76.10),
        (116.21, 89.61),
        (185.82, 76.10),
        (241.92, 102.08),
      ],
      398: [
        (4.00, 77.51),
        (61.51, 77.51),
        (119.01, 91.35),
        (190.36, 77.51),
        (247.87, 104.13),
      ],
      402: [
        (4.00, 78.21),
        (62.21, 78.21),
        (120.42, 92.22),
        (192.64, 78.21),
        (250.84, 105.16),
      ],
      412: [
        (4.00, 79.96),
        (63.96, 79.96),
        (123.92, 94.40),
        (198.32, 79.96),
        (258.28, 107.72),
      ],
      414: [
        (4.00, 80.31),
        (64.31, 80.31),
        (124.62, 94.83),
        (199.46, 80.31),
        (259.77, 108.23),
      ],
      440: [
        (4.00, 86.52),
        (68.52, 86.52),
        (133.04, 102.05),
        (213.09, 86.52),
        (277.61, 116.39),
      ],
      480: [
        (4.00, 101.00),
        (86.25, 101.00),
        (168.50, 101.00),
        (250.75, 101.00),
        (333.00, 101.00),
      ],
    },
  ),
];

Future<ValueNotifier<int>> _pumpSelectableDock(
  WidgetTester tester,
  List<String> labels,
) async {
  final selected = ValueNotifier(0);
  addTearDown(selected.dispose);
  await tester.pumpWidget(
    TestApp(
      child: HostScaffold(
        body: Align(
          alignment: Alignment.bottomCenter,
          child: ValueListenableBuilder(
            valueListenable: selected,
            builder: (_, index, _) => NavigationDock(
              destinations: [
                for (final label in labels)
                  NavigationDockDestination(
                    glyph: AppGlyphs.tools,
                    label: label,
                  ),
              ],
              selectedIndex: index,
              onSelected: (index) => selected.value = index,
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return selected;
}

// A press only paints, so its swell shows in the paint transform.
Rect _painted(WidgetTester tester, RenderObject box, Rect resting) {
  Matrix4? transform;
  expect(
    box,
    paints..everything((method, arguments) {
      if (method == #transform) {
        transform ??= Matrix4.fromFloat64List(arguments.single as Float64List);
      }
      return true;
    }),
  );
  final local = Offset.zero & resting.size;
  return (transform == null
          ? local
          : MatrixUtils.transformRect(transform!, local))
      .shift(resting.topLeft);
}

void main() {
  setUp(() {
    navigationPort = navigation;
    addTearDown(() => navigationPort = null);
  });

  testWidgets('the dock stays centred alone on every page, the dashboard '
      'included', (tester) async {
    final container = await _pumpHome(tester);

    final bar = tester.getRect(find.byType(FloatingNavigationBar));
    expect(bar.center.dx, _mobileSize.width / 2);

    await tester.drag(
      find.byType(FloatingNavigationBar),
      Offset(bar.width * 0.7, 0),
      warnIfMissed: false,
    );
    await tester.pumpAndSettle();
    expect(container.read(currentPageLabelProvider), PageLabel.tools);
    final alone = tester.getRect(find.byType(FloatingNavigationBar));
    expect(alone.center.dx, _mobileSize.width / 2);
    expect(alone.width, lessThan(_mobileSize.width - 40));
    expect(tester.takeException(), isNull);
  });

  testWidgets('a tap that just misses the bar still reaches it', (
    tester,
  ) async {
    final container = await _pumpHome(tester);
    final bar = tester.getRect(find.byType(FloatingNavigationBar));
    final extent = (bar.width - 8) / 3;
    final tools = bar.left + 4 + extent * 2.5;

    await tester.tapAt(Offset(tools, bar.bottom + 12));
    await tester.pumpAndSettle();
    expect(container.read(currentPageLabelProvider), PageLabel.dashboard);

    await tester.tapAt(Offset(tools, bar.bottom + 6));
    await tester.pumpAndSettle();
    expect(container.read(currentPageLabelProvider), PageLabel.tools);

    final alone = tester.getRect(find.byType(FloatingNavigationBar));
    await tester.tapAt(Offset(alone.left - 6, alone.top - 6));
    await tester.pumpAndSettle();
    expect(container.read(currentPageLabelProvider), PageLabel.dashboard);
  });

  testWidgets('the lens keeps up with a finger that never pauses', (
    tester,
  ) async {
    await _pumpHome(tester);
    final bar = tester.getRect(find.byType(FloatingNavigationBar));
    final extent = (bar.width - 8) / 3;
    var finger = Offset(bar.left + 4 + extent / 2, bar.center.dy);
    final gesture = await tester.startGesture(finger);
    await tester.pump(const Duration(milliseconds: 16));
    for (var i = 0; i < 30; i++) {
      finger += Offset(extent * 2 / 30, 0);
      await gesture.moveTo(finger);
      await tester.pump(const Duration(milliseconds: 16));
    }

    expect(tester.getCenter(_lens).dx, closeTo(finger.dx, extent * 0.3));
    await gesture.up();
    await tester.pumpAndSettle();
  });

  testWidgets('the lens moving repaints the dock and not the page', (
    tester,
  ) async {
    await _pumpHome(tester);
    final page = tester.renderObject<RenderRepaintBoundary>(
      find
          .ancestor(
            of: find.byType(HomePage),
            matching: find.byType(RepaintBoundary),
          )
          .first,
    );
    final bar = tester.getRect(find.byType(FloatingNavigationBar));
    final extent = (bar.width - 8) / 3;
    var finger = Offset(bar.left + 4 + extent / 2, bar.center.dy);
    final gesture = await tester.startGesture(finger);
    await tester.pump(const Duration(milliseconds: 16));
    page.debugResetMetrics();
    for (var i = 0; i < 10; i++) {
      finger += Offset(extent / 10, 0);
      await gesture.moveTo(finger);
      await tester.pump(const Duration(milliseconds: 16));
    }

    expect(page.debugSymmetricPaintCount + page.debugAsymmetricPaintCount, 0);
    await gesture.up();
    await tester.pumpAndSettle();
  });

  testWidgets('the lens stops asking for frames once its wobble cannot show', (
    tester,
  ) async {
    final container = await _pumpHome(tester);
    container.read(currentPageLabelProvider.notifier).toPage(PageLabel.tools);
    await tester.pump();
    var elapsed = Duration.zero;
    while (tester.binding.hasScheduledFrame && elapsed.inSeconds < 3) {
      await tester.pump(const Duration(milliseconds: 16));
      elapsed += const Duration(milliseconds: 16);
    }
    expect(elapsed, lessThan(const Duration(milliseconds: 1200)));
  });

  testWidgets('a flick carries the lens on to the next item', (tester) async {
    final container = await _pumpHome(tester);
    final bar = tester.getRect(find.byType(FloatingNavigationBar));
    final extent = (bar.width - 8) / 3;
    final start = Offset(bar.left + 4 + extent / 2, bar.center.dy);

    Future<void> drag(Duration duration) async {
      await tester.timedDragFrom(start, Offset(extent * 0.35, 0), duration);
      await tester.pumpAndSettle();
    }

    await drag(const Duration(seconds: 1));
    expect(container.read(currentPageLabelProvider), PageLabel.dashboard);

    await drag(const Duration(milliseconds: 50));
    expect(container.read(currentPageLabelProvider), PageLabel.profiles);
  });

  testWidgets('a press lifts the lens past the bar until it is let go', (
    tester,
  ) async {
    await _pumpHome(tester);
    final bar = tester.getRect(find.byType(FloatingNavigationBar));
    final resting = tester.getRect(_lens);
    expect(resting.height, bar.height - 8);

    final gesture = await tester.startGesture(resting.center);
    await tester.pumpAndSettle();
    final lifted = tester.getRect(_lens);
    expect(lifted.top, lessThan(bar.top));
    expect(lifted.bottom, greaterThan(bar.bottom));

    await gesture.up();
    await tester.pumpAndSettle();
    expect(tester.getRect(_lens), resting);
  });

  testWidgets('a quick tap lifts the lens all the way before it drops', (
    tester,
  ) async {
    await _pumpHome(tester);
    final resting = tester.getRect(_lens);
    final hold = await tester.startGesture(resting.center);
    await tester.pumpAndSettle();
    final held = tester.getRect(_lens).height - resting.height;
    await hold.up();
    await tester.pumpAndSettle();

    final tap = await tester.startGesture(resting.center);
    await tester.pump(const Duration(milliseconds: 40));
    await tap.up();
    var lifted = 0.0;
    for (var i = 0; i < 30; i++) {
      await tester.pump(const Duration(milliseconds: 16));
      lifted = math.max(lifted, tester.getRect(_lens).height - resting.height);
    }
    expect(lifted, greaterThan(held * 0.97));

    await tester.pumpAndSettle();
    expect(tester.getRect(_lens), resting);
  });

  for (final (quality, lifted) in [
    (LiquidGlassQuality.standard, 2),
    (LiquidGlassQuality.ultra, 3),
  ]) {
    testWidgets('on ${quality.name} glass the dock and a lifted lens are panes '
        'of glass', (tester) async {
      tester.view.physicalSize = _mobileSize;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        TestApp(
          wrapInProviderScope: true,
          homeBuilder: (child) => HostScaffold(
            body: Align(
              alignment: Alignment.bottomCenter,
              child: LiquidGlassScope(
                enabled: true,
                quality: quality,
                child: child,
              ),
            ),
          ),
          child: NavigationDock(
            destinations: const [
              NavigationDockDestination(glyph: AppGlyphs.dashboard, label: 'a'),
              NavigationDockDestination(glyph: AppGlyphs.tools, label: 'b'),
            ],
            selectedIndex: 0,
            onSelected: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();
      final glass = find.byType(LiquidGlass);
      expect(glass, findsOneWidget);

      final gesture = await tester.startGesture(
        tester.getCenter(find.text('b')),
      );
      await tester.pumpAndSettle();
      expect(glass, findsNWidgets(lifted));

      await gesture.up();
      await tester.pumpAndSettle();
      expect(glass, findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('the bar swells under a pointer and stretches past its end', (
    tester,
  ) async {
    await _pumpHome(tester);
    final bar = find.byType(FloatingNavigationBar);
    final resting = tester.getRect(bar);
    Rect painted() => _painted(tester, tester.renderObject(bar), resting);

    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    addTearDown(mouse.removePointer);
    await mouse.addPointer(location: Offset.zero);
    await mouse.moveTo(resting.center);
    await tester.pumpAndSettle();
    final hovered = painted();
    expect(hovered.center, resting.center);
    expect(hovered.width, greaterThan(resting.width));

    await mouse.down(resting.center);
    await tester.pumpAndSettle();
    final pressed = painted();
    expect(tester.getRect(bar), resting);
    expect(pressed.center, resting.center);
    expect(pressed.width, greaterThan(hovered.width));
    expect(pressed.height, greaterThan(resting.height));

    await mouse.moveTo(resting.centerRight + const Offset(80, 0));
    await tester.pumpAndSettle();
    final pulled = painted();
    expect(pulled.center.dx, greaterThan(resting.center.dx + 4));
    expect(pulled.width, greaterThan(pressed.width));

    await mouse.up();
    await mouse.moveTo(Offset.zero);
    await tester.pumpAndSettle();
    expect(painted(), resting);
  });

  testWidgets(
    'a hovering pointer highlights and draws only the item under it',
    (tester) async {
      await _pumpHome(
        tester,
        overrides: [
          currentPageLabelProvider.overrideWithBuild((_, _) => PageLabel.tools),
        ],
      );
      final bar = find.byType(FloatingNavigationBar);
      final tools = find
          .descendant(of: bar, matching: find.byType(GlyphIcon))
          .last;
      final resting = tester.getRect(tools);
      // The lens is drawn first, so the highlight is the last positioned child.
      final positioned = find.descendant(
        of: bar,
        matching: find.byType(Positioned),
      );

      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      addTearDown(mouse.removePointer);
      await mouse.addPointer(location: Offset.zero);
      await mouse.moveTo(resting.center + const Offset(30, 0));
      await tester.pumpAndSettle();
      final hovered = tester.getRect(tools);
      expect(hovered.width, moreOrLessEquals(resting.width));
      expect(positioned, findsNWidgets(2));
      final highlight =
          tester.getCenter(positioned.last).dx - resting.center.dx;
      final drawn = hovered.center.dx - resting.center.dx;
      expect(drawn, greaterThan(0.5));
      expect(drawn, moreOrLessEquals(highlight / 2, epsilon: 0.5));
      expect(highlight, lessThan(30));
      expect(
        tester.getRect(positioned.first),
        rectMoreOrLessEquals(tester.getRect(positioned.last)),
      );

      await mouse.moveTo(resting.center - const Offset(80, 0));
      for (var i = 0; i < 30; i++) {
        await tester.pump(const Duration(milliseconds: 16));
        expect(
          tester.getRect(tools).center.dx,
          inInclusiveRange(resting.center.dx - 0.5, hovered.center.dx),
        );
      }
      await tester.pumpAndSettle();
      expect(tester.getCenter(tools).dx, moreOrLessEquals(resting.center.dx));

      await mouse.moveTo(resting.center);
      await tester.pumpAndSettle();

      await mouse.down(resting.center);
      await tester.pumpAndSettle();
      expect(positioned, findsOneWidget);
      await mouse.up();
      await tester.pumpAndSettle();
      expect(positioned, findsNWidgets(2));

      await mouse.moveTo(Offset.zero);
      await tester.pumpAndSettle();
      expect(tester.getCenter(tools).dx, moreOrLessEquals(resting.center.dx));
      expect(positioned, findsOneWidget);
    },
  );

  testWidgets('a tap leaves no highlight behind', (tester) async {
    await _pumpHome(tester);
    final bar = find.byType(FloatingNavigationBar);
    final tools = find
        .descendant(of: bar, matching: find.byType(GlyphIcon))
        .last;
    final positioned = find.descendant(
      of: bar,
      matching: find.byType(Positioned),
    );

    final finger = await tester.createGesture();
    addTearDown(finger.removePointer);
    await finger.addPointer(location: Offset.zero);
    await finger.moveTo(tester.getCenter(tools));
    await tester.pumpAndSettle();
    expect(positioned, findsOneWidget);

    await finger.down(tester.getCenter(tools));
    await finger.up();
    await tester.pumpAndSettle();
    expect(positioned, findsOneWidget);
  });

  for (final floating in [true, false]) {
    testWidgets('a phone page shows its primary action in its bar above a '
        '${floating ? 'floating' : 'fixed'} navigation bar', (tester) async {
      final container = await _pumpHome(tester);
      container
          .read(appSettingProvider.notifier)
          .update((state) => state.copyWith(floatingNavigationBar: floating));
      container
          .read(currentPageLabelProvider.notifier)
          .toPage(PageLabel.profiles);
      await tester.pumpAndSettle();

      final action = find.byWidgetPredicate(
        (widget) =>
            widget is AppBarActionButton && widget.data.tooltip == _addLabel,
      );
      expect(action, findsOneWidget);
      expect(
        find.ancestor(of: action, matching: find.byType(AppBar)),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('four destinations keep to their width, and five fill the row '
      'up to the widest iPhone and center past it', (tester) async {
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    Future<Rect> pumpBar(double width, int count) async {
      tester.view.physicalSize = Size(width, 800);
      await _pumpDock(tester, [
        for (var index = 0; index < count; index++) '$index',
      ]);
      return tester.getRect(find.byType(FloatingNavigationBar));
    }

    final four = await pumpBar(560, 4);
    expect(four.center.dx, 280);
    expect(four.width, 360);
    for (final width in [402.0, 440.0]) {
      final five = await pumpBar(width, 5);
      expect(five.left, 21);
      expect(five.right, width - 21);
    }
    for (final width in [441.0, 500.0, 600.0]) {
      final five = await pumpBar(width, 5);
      expect(five.width, 398);
      expect(five.center.dx, width / 2);
    }
  });

  testWidgets('five destinations rest as wide as iOS 27 rests them, and '
      'narrow without a jump once they crowd', (tester) async {
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    Future<double> lensWidthAt(double width) async {
      tester.view.physicalSize = Size(width, 800);
      await _pumpDock(tester, ['0', '1', '2', '3', '4']);
      return tester.getRect(_lens).width;
    }

    // UIKit's tab bar rests its lens 77 and 84.6 dp wide at 402 and 440. Below
    // 398 it overlaps neighbours by 20, widening the lens to 85.4 at 397; the
    // dock keeps them overlapping by 8.25 instead.
    expect(await lensWidthAt(402), closeTo(77, 0.01));
    expect(await lensWidthAt(398), closeTo(76.2, 0.01));
    expect(await lensWidthAt(397), closeTo(76, 0.01));
    expect(await lensWidthAt(375), closeTo(71.6, 0.01));
    expect(await lensWidthAt(440), closeTo(84.6, 0.01));
    expect(await lensWidthAt(600), closeTo(84.6, 0.01));
  });

  testWidgets('a destination stands its glyph and label where iOS 27 does', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(402, 874);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await _pumpDock(tester, ['Home', 'Apps', 'Logs', 'Tools', 'More']);

    final bar = find.byType(FloatingNavigationBar);
    final top = tester.getRect(bar).top;
    final glyph = tester.getRect(
      find.descendant(of: bar, matching: find.byType(GlyphIcon)).first,
    );
    final label = tester.getRect(
      find.descendant(of: bar, matching: find.text('Home')),
    );
    expect(glyph.center.dy - top, 24);
    expect(label.top - top, 39);
    expect(label.height, 12);
  });

  testWidgets('destinations rest where UIKit sets them out by their labels, '
      'overlapping less where it crowds them', (tester) async {
    for (final bar in _uikitTabBars) {
      final count = bar.labels.length;
      final rooms = bar.labels.fold(
        0.0,
        (sum, l) => sum + math.max(54, l + 12),
      );
      for (final MapEntry(key: width, value: frames) in bar.frames.entries) {
        final lenses = NavigationDock.restingLensesOf(width - 42, bar.labels);
        final span = width - 50.0;
        final reason = '${bar.name} at $width';
        if (span >= rooms + (count == 4 ? 82 : 78)) {
          for (final (index, (start, extent)) in frames.indexed) {
            expect(lenses[index].start, closeTo(start, 0.05), reason: reason);
            expect(lenses[index].width, closeTo(extent, 0.05), reason: reason);
          }
          continue;
        }
        // UIKit overlaps crowded neighbours by 20; the dock keeps 8.25 and
        // shares what is left out as UIKit does.
        final uikitShare = [for (final (_, extent) in frames) extent - 20];
        final share = [for (final lens in lenses) lens.width - 8.25];
        final uikitTotal = uikitShare.reduce((a, b) => a + b);
        final total = share.reduce((a, b) => a + b);
        expect(lenses.first.start, moreOrLessEquals(4), reason: reason);
        expect(total + 8.25, moreOrLessEquals(span), reason: reason);
        for (var index = 0; index < count; index++) {
          if (rooms <= uikitTotal) {
            expect(
              share[index] / total,
              closeTo(uikitShare[index] / uikitTotal, 1e-4),
              reason: '$reason, item $index',
            );
          }
          if (index > 0) {
            final previous = lenses[index - 1];
            expect(
              previous.start + previous.width - lenses[index].start,
              moreOrLessEquals(8.25),
              reason: '$reason, item $index',
            );
          }
        }
      }
    }
  });

  testWidgets('a long label widens its destination at its neighbours\' '
      'expense before it shrinks', (tester) async {
    tester.view.physicalSize = const Size(340, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await _pumpDock(tester, ['Home', 'Apps', 'Logs', 'Profile']);

    final bar = find.byType(FloatingNavigationBar);
    final lenses = NavigationDock.restingLensesOf(298, [40, 40, 40, 70]);
    expect(lenses.last.width, greaterThan(lenses.first.width + 30));
    expect(
      tester.getRect(_lens).width,
      moreOrLessEquals(lenses.first.width, epsilon: 0.01),
    );
    final texts = tester.widgetList<Text>(
      find.descendant(of: bar, matching: find.byType(Text)),
    );
    expect(texts.map((text) => text.style!.fontSize).toSet(), {10});
    expect(
      find.descendant(of: bar, matching: find.byType(Tooltip)),
      findsNothing,
    );
  });

  testWidgets('a label still too long shrinks to fit, then ellipsizes behind '
      'a tooltip', (tester) async {
    tester.view.physicalSize = const Size(340, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    Future<List<Text>> pumpLabels(String label) async {
      await _pumpDock(tester, ['Home', 'Apps', label]);
      return tester
          .widgetList<Text>(
            find.descendant(
              of: find.byType(FloatingNavigationBar),
              matching: find.byType(Text),
            ),
          )
          .toList();
    }

    final tooltips = find.descendant(
      of: find.byType(FloatingNavigationBar),
      matching: find.byType(Tooltip),
    );

    var labels = await pumpLabels('Profiles!');
    final shrunk = labels.first.style!.fontSize!;
    expect(shrunk, lessThan(10));
    expect(shrunk, greaterThan(9));
    expect(labels.map((text) => text.style!.fontSize).toSet(), {shrunk});
    expect(tooltips, findsNothing);

    labels = await pumpLabels('Configuration');
    expect(labels.first.style!.fontSize, closeTo(9, 0.001));
    expect(tester.widget<Tooltip>(tooltips).message, 'Configuration');
  });

  testWidgets('a label too long for even the narrowest share leaves every '
      'destination room for its glyph', (tester) async {
    final lenses = NavigationDock.restingLensesOf(298, [40, 40, 40, 600]);
    for (final lens in lenses.take(3)) {
      expect(lens.width, moreOrLessEquals(40.25));
    }
    expect(lenses.last.start + lenses.last.width, moreOrLessEquals(294));
  });

  testWidgets('a drag across destinations of unequal width settles on the one '
      'whose center is nearest', (tester) async {
    tester.view.physicalSize = const Size(440, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    const labels = ['Dashboard', 'Proxies', 'Requests', 'Profiles', 'Tools'];
    final selected = await _pumpSelectableDock(tester, labels);
    final bar = tester.getRect(find.byType(FloatingNavigationBar));
    final lenses = NavigationDock.restingLensesOf(bar.width, [
      for (final label in labels) label.length * 10.0,
    ]);
    expect(lenses.map((lens) => lens.width).toSet(), hasLength(4));
    double centerOf(int index) =>
        bar.left + lenses[index].start + lenses[index].width / 2;
    Rect restingOf(int index) => Rect.fromLTWH(
      bar.left + lenses[index].start,
      bar.top + 4,
      lenses[index].width,
      bar.height - 8,
    );

    for (final (from, to, share, settled) in [
      (0, 3, 1.0, 3),
      (3, 4, 0.4, 3),
      (3, 4, 0.6, 4),
      (4, 1, 1.0, 1),
    ]) {
      final end = centerOf(from) + (centerOf(to) - centerOf(from)) * share;
      final gesture = await tester.startGesture(
        Offset(centerOf(from), bar.center.dy),
      );
      await tester.pump(const Duration(milliseconds: 16));
      for (var step = 1; step <= 40; step++) {
        await gesture.moveTo(
          Offset(
            centerOf(from) + (end - centerOf(from)) * step / 40,
            bar.center.dy,
          ),
        );
        await tester.pump(const Duration(milliseconds: 16));
      }
      await tester.pump(const Duration(milliseconds: 300));
      await gesture.up();
      await tester.pumpAndSettle();
      expect(selected.value, settled, reason: 'from $from toward $to');
      expect(tester.getRect(_lens), rectMoreOrLessEquals(restingOf(settled)));
    }
  });

  testWidgets('a tap just inside a wide destination\'s edge selects it, not '
      'the narrow one past the midpoint of their centers', (tester) async {
    tester.view.physicalSize = const Size(402, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    const labels = ['Dashboard', 'Apps', 'Requests', 'Profiles', 'Tools'];
    final selected = await _pumpSelectableDock(tester, labels);
    final bar = tester.getRect(find.byType(FloatingNavigationBar));
    final lenses = NavigationDock.restingLensesOf(bar.width, [
      for (final label in labels) label.length * 10.0,
    ]);
    final (first, second) = (lenses[0], lenses[1]);
    final overlap = first.start + first.width - second.start;
    final edge = bar.left + first.start + first.width - overlap / 2;
    final midpoint =
        bar.left +
        (first.start + first.width / 2 + second.start + second.width / 2) / 2;
    expect(edge - midpoint, greaterThan(2));

    await tester.tapAt(Offset(edge + 1, bar.center.dy));
    await tester.pumpAndSettle();
    expect(selected.value, 1);
    await tester.tapAt(Offset(edge - 1, bar.center.dy));
    await tester.pumpAndSettle();
    expect(selected.value, 0);
  });

  testWidgets('a bar too narrow for its destinations lays them out empty '
      'rather than negative', (tester) async {
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    for (final count in [3, 5]) {
      tester.view.physicalSize = const Size(50, 800);
      await _pumpDock(tester, [for (var i = 0; i < count; i++) '$i']);
      final cells = tester.widgetList<SizedBox>(
        find.descendant(
          of: find.byType(FloatingNavigationBar),
          matching: find.byWidgetPredicate(
            (widget) =>
                widget is SizedBox &&
                widget.width != null &&
                widget.child?.runtimeType.toString() == '_FloatingBarItem',
          ),
        ),
      );
      expect(cells, hasLength(count));
      for (final cell in cells) {
        expect(cell.width, greaterThanOrEqualTo(0));
      }
    }
  });

  testWidgets('a tap on a narrow destination between wide ones selects it', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(375, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    const labels = ['Dashboard', 'Apps', 'Requests', 'Profiles', 'Tools'];
    final selected = await _pumpSelectableDock(tester, labels);
    final bar = tester.getRect(find.byType(FloatingNavigationBar));
    final lenses = NavigationDock.restingLensesOf(bar.width, [
      for (final label in labels) label.length * 10.0,
    ]);
    final apps = lenses[1];
    await tester.tapAt(
      Offset(bar.left + apps.start + apps.width / 2, bar.center.dy),
    );
    await tester.pumpAndSettle();
    expect(selected.value, 1);
    expect(tester.getRect(_lens).width, moreOrLessEquals(apps.width));
  });

  testWidgets('a quick tap swells an elastic press all the way', (
    tester,
  ) async {
    await tester.pumpWidget(
      const TestApp(
        child: Center(
          child: ElasticPress(
            child: ColoredBox(
              color: Color(0xFF2196F3),
              child: SizedBox.square(dimension: 40),
            ),
          ),
        ),
      ),
    );
    final press = find.byType(ElasticPress);
    final resting = tester.getRect(press);
    Rect painted() => _painted(tester, tester.renderObject(press), resting);

    final gesture = await tester.startGesture(resting.center);
    await tester.pump(const Duration(milliseconds: 40));
    await gesture.up();
    var swollen = resting.width;
    for (var i = 0; i < 30; i++) {
      await tester.pump(const Duration(milliseconds: 16));
      swollen = math.max(swollen, painted().width);
    }
    expect(swollen, greaterThan(resting.width * 1.24));

    await tester.pumpAndSettle();
    expect(painted(), resting);
  });

  testWidgets('a pointer lifts a tonal button part way, with no state layer', (
    tester,
  ) async {
    await tester.pumpWidget(
      TestApp(
        child: Center(
          child: TonalButtonTheme(
            child: ElasticPress(
              child: IconButton(
                tooltip: _addLabel,
                onPressed: () {},
                icon: const GlyphIcon(AppGlyphs.add),
              ),
            ),
          ),
        ),
      ),
    );
    final press = find.byType(ElasticPress);
    final resting = tester.getRect(press);
    double width() =>
        _painted(tester, tester.renderObject(press), resting).width;
    CardSurface surface() => tester.widget<CardSurface>(
      find.descendant(
        of: find.byType(IconButton),
        matching: find.byType(CardSurface),
      ),
    );
    final fill = surface().fill;
    expect(surface().look, PressLook.none);

    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: Offset.zero);
    await mouse.moveTo(resting.center);
    await tester.pumpAndSettle();
    final hovered = width();
    expect(hovered, greaterThan(resting.width * 1.05));
    expect(surface().fill, fill);

    await mouse.down(resting.center);
    await tester.pumpAndSettle();
    expect(width(), greaterThan(hovered));
    expect(surface().fill, fill);

    await mouse.up();
    await tester.pumpAndSettle();
    expect(width(), moreOrLessEquals(hovered));

    await mouse.moveTo(Offset.zero);
    await tester.pumpAndSettle();
    expect(width(), resting.width);
    await mouse.removePointer();
  });

  testWidgets('a pointer trembling on the edge of a tonal button keeps it '
      'lifted', (tester) async {
    await tester.pumpWidget(
      TestApp(
        child: Center(
          child: TonalButton(
            size: TonalButtonSize.bar,
            glyph: AppGlyphs.sync,
            label: _addLabel,
            onPressed: () {},
          ),
        ),
      ),
    );
    final press = find.byType(ElasticPress);
    final resting = tester.getRect(press);
    double width() =>
        _painted(tester, tester.renderObject(press), resting).width;
    final inside = resting.centerRight - const Offset(1, 0);
    final outside = resting.centerRight + const Offset(1, 0);

    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: outside);
    await tester.pumpAndSettle();
    expect(width(), resting.width);

    await mouse.moveTo(inside);
    await tester.pumpAndSettle();
    final hovered = width();
    expect(hovered, greaterThan(resting.width));
    for (var i = 0; i < 7; i++) {
      await mouse.moveTo(i.isEven ? outside : inside);
      await tester.pump(const Duration(milliseconds: 50));
    }
    await tester.pumpAndSettle();
    expect(width(), moreOrLessEquals(hovered));

    await mouse.moveTo(Offset.zero);
    await tester.pumpAndSettle();
    expect(width(), resting.width);
    await mouse.removePointer();
  });

  testWidgets(
    'an elastic button leaves a press to the swell and keeps the icon theme',
    (tester) async {
      await tester.pumpWidget(
        TestApp(
          child: HostScaffold(
            body: IconTheme.merge(
              data: const IconThemeData(fill: 1),
              child: Row(
                children: [
                  ElasticButton(
                    child: IconButton.filled(
                      tooltip: _addLabel,
                      onPressed: () {},
                      icon: const GlyphIcon(AppGlyphs.add),
                    ),
                  ),
                  ElasticButton(
                    child: FilledButton(
                      onPressed: () {},
                      child: const Text(_addLabel),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      for (final button in [IconButton, FilledButton]) {
        expect(
          tester
              .widget<CardSurface>(
                find.descendant(
                  of: find.byType(button),
                  matching: find.byType(CardSurface),
                ),
              )
              .look,
          PressLook.none,
        );
      }
      expect(
        IconTheme.of(tester.element(find.byType(GlyphIcon).first)).fill,
        1,
      );
    },
  );
}
