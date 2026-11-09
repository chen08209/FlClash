import 'dart:ui' show lerpDouble;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prism_ui/prism_ui.dart';
import '../helpers/host_scaffold.dart';
import '../helpers/test_app.dart';

const _viewSize = Size(800, 600);

// iOS shrinks the page below by a width of 34.667 dp.
final _recededShrink = 34.667 / _viewSize.width;

void main() {
  testWidgets('OpenContainer opens, closes, and returns a value', (
    tester,
  ) async {
    String? result;

    await tester.pumpWidget(
      HostApp(
        home: HostScaffold(
          body: Center(
            child: SizedBox(
              width: 160,
              height: 80,
              child: OpenContainer<String>(
                transition: OpenContainerTransition.zoom,
                closedBuilder: (_, open) {
                  return FilledButton(
                    onPressed: open,
                    child: const Text('Closed'),
                  );
                },
                openBuilder: (_, close) {
                  return Center(
                    child: FilledButton(
                      onPressed: () => close(returnValue: 'done'),
                      child: const Text('Close'),
                    ),
                  );
                },
                onClosed: (value) {
                  result = value;
                },
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Closed'));
    await tester.pump(const Duration(milliseconds: 80));
    expect(find.text('Close'), findsOneWidget);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Close'));
    await tester.pump(const Duration(milliseconds: 80));
    await tester.pumpAndSettle();

    expect(result, 'done');
    expect(find.text('Closed'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('morphs the closed shape into the open page as it fills in', (
    tester,
  ) async {
    const closedShape = RoundedSuperellipseBorder(
      borderRadius: BorderRadius.all(Radius.circular(24)),
    );

    await tester.pumpWidget(
      HostApp(
        home: HostScaffold(
          body: Center(
            child: SizedBox(
              width: 160,
              height: 80,
              child: OpenContainer<void>(
                transition: OpenContainerTransition.zoom,
                closedShape: closedShape,
                closedBuilder: (_, open) {
                  return GestureDetector(
                    onTap: open,
                    child: const Text('Card'),
                  );
                },
                openBuilder: (_, close) {
                  return GestureDetector(
                    onTap: () => close(),
                    child: const Text('Page'),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );

    final closedMaterial = tester.widget<Surface>(
      find
          .ancestor(of: find.text('Card'), matching: find.byType(Surface))
          .first,
    );
    expect(closedMaterial.shape, closedShape);
    final closedRect = tester.getRect(find.byType(OpenContainer<void>));
    final navigator = find.byType(Navigator);
    final page = SurfaceLevel.page.colorOf(
      Theme.of(tester.element(find.text('Card'))).colorScheme,
    );

    // Opening runs in the page's scale, which the rect's width sets, and
    // closing in the screen's.
    PaintPattern container({required bool opening}) {
      final progress = ModalRoute.of(
        tester.element(find.text('Page', skipOffstage: false)),
      )!.animation!.value;
      final full = Offset.zero & _viewSize;
      final tile = recededRect(closedRect, _viewSize, progress);
      final closedRadius =
          closedShape.borderRadius.resolve(null) *
          (tile.width / closedRect.width);
      final Rect rect;
      final BorderRadius radius;
      if (opening) {
        final from = tile.width / _viewSize.width;
        final scale = lerpDouble(from, 1, progress)!;
        rect = Rect.fromCenter(
          center: Offset.lerp(tile.center, full.center, progress)!,
          width: _viewSize.width * scale,
          height:
              lerpDouble(tile.height / from, _viewSize.height, progress)! *
              scale,
        );
        radius =
            BorderRadius.lerp(
              closedRadius / from,
              BorderRadius.zero,
              progress,
            )! *
            scale;
      } else {
        rect = Rect.lerp(tile, full, progress)!;
        radius = BorderRadius.lerp(closedRadius, BorderRadius.zero, progress)!;
      }
      bool near(double a, double b) => (a - b).abs() < 0.01;
      bool nearRect(Rect a) =>
          near(a.left, rect.left) &&
          near(a.top, rect.top) &&
          near(a.right, rect.right) &&
          near(a.bottom, rect.bottom);
      return paints
        ..something((method, arguments) {
          if (method != #clipRSuperellipse) {
            return false;
          }
          final clip = arguments[0] as RSuperellipse;
          return nearRect(clip.outerRect) &&
              near(clip.tlRadiusX, radius.topLeft.x);
        })
        ..something((method, arguments) {
          if (method != #drawRect) {
            return false;
          }
          final color = (arguments[1] as Paint).color;
          return nearRect(arguments[0] as Rect) &&
              near(color.a, clampDouble(progress, 0, 1)) &&
              near(color.r, page.r);
        });
    }

    await tester.tap(find.text('Card'));
    await tester.pump();
    expect(navigator, container(opening: true));

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 60));
    expect(navigator, container(opening: true));

    await tester.pumpAndSettle();
    expect(navigator, isNot(paints..clipRSuperellipse()));

    await tester.tap(find.text('Page'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));
    expect(navigator, container(opening: false));

    await tester.pumpAndSettle();
    expect(find.text('Page'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('opens by callback and supports interrupted reverse', (
    tester,
  ) async {
    String? result = 'unchanged';

    await tester.pumpWidget(
      HostApp(
        home: HostScaffold(
          body: Align(
            alignment: Alignment.topLeft,
            child: OpenContainer<String>(
              transition: OpenContainerTransition.zoom,
              closedBuilder: (_, open) {
                return TextButton(
                  onPressed: open,
                  child: const Text('Open manually'),
                );
              },
              openBuilder: (_, close) {
                return TextButton(
                  onPressed: () => close(),
                  child: const Text('Reverse now'),
                );
              },
              onClosed: (value) {
                result = value;
              },
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open manually'));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(find.text('Reverse now'));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pumpAndSettle();
    await tester.pump();

    expect(result, isNull);
    expect(find.text('Reverse now'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a close that cuts the opening short sets off where it is', (
    tester,
  ) async {
    await tester.pumpWidget(
      HostApp(
        home: HostScaffold(
          body: Center(
            child: SizedBox(
              width: 160,
              height: 80,
              child: OpenContainer<void>(
                transition: OpenContainerTransition.zoom,
                closedShape: const RoundedSuperellipseBorder(
                  borderRadius: BorderRadius.all(Radius.circular(24)),
                ),
                closedBuilder: (_, open) {
                  return GestureDetector(
                    onTap: open,
                    child: const Text('Card'),
                  );
                },
                openBuilder: (_, _) => const Text('Page'),
              ),
            ),
          ),
        ),
      ),
    );

    RSuperellipse clip() {
      late RSuperellipse clip;
      expect(
        find.byType(Navigator),
        paints..something((method, arguments) {
          if (method != #clipRSuperellipse) {
            return false;
          }
          clip = arguments.first as RSuperellipse;
          return true;
        }),
      );
      return clip;
    }

    await tester.tap(find.text('Card'));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 44));
    final previous = clip();
    await tester.pump(const Duration(milliseconds: 16));
    final opening = clip();

    // The close carries on at the opening's speed, slowing.
    Navigator.of(tester.element(find.text('Page'))).pop();
    await tester.pump(const Duration(milliseconds: 16));
    final closing = clip();
    for (final (last, now) in [
      (opening.left - previous.left, closing.left - opening.left),
      (opening.top - previous.top, closing.top - opening.top),
      (opening.right - previous.right, closing.right - opening.right),
      (opening.bottom - previous.bottom, closing.bottom - opening.bottom),
    ]) {
      expect(now * last, greaterThanOrEqualTo(0));
      expect(now.abs(), lessThanOrEqualTo(last.abs()));
    }

    await tester.pumpAndSettle();
    expect(find.text('Page'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  Widget containerApp({
    required CloseContainerBuilder closedBuilder,
    required OpenContainerBuilder<void> openBuilder,
  }) {
    return HostApp(
      home: HostScaffold(
        body: Center(
          child: SizedBox(
            width: 160,
            height: 80,
            child: OpenContainer<void>(
              transition: OpenContainerTransition.zoom,
              closedBuilder: closedBuilder,
              openBuilder: openBuilder,
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('a transition builds the page once and the tile twice', (
    tester,
  ) async {
    var pageBuilds = 0;
    var tileBuilds = 0;
    final page = Builder(
      builder: (context) {
        pageBuilds++;
        return Text('${Theme.of(context).brightness}');
      },
    );

    await tester.pumpWidget(
      containerApp(
        closedBuilder: (_, open) {
          tileBuilds++;
          return TextButton(onPressed: open, child: const Text('Tile'));
        },
        openBuilder: (_, _) => page,
      ),
    );
    tileBuilds = 0;

    await tester.tap(find.text('Tile'));
    await tester.pumpAndSettle();
    expect(pageBuilds, 1);

    Navigator.of(tester.element(find.byWidget(page))).pop();
    await tester.pumpAndSettle();
    expect(pageBuilds, 1);
    expect(tileBuilds, 2);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a transition leaves no animation undisposed', (tester) async {
    var undisposed = 0;
    void track(ObjectEvent event) {
      if (event.object is! CurvedAnimation) {
        return;
      }
      undisposed += event is ObjectCreated ? 1 : -1;
    }

    await tester.pumpWidget(
      containerApp(
        closedBuilder: (_, open) {
          return GestureDetector(onTap: open, child: const Text('Tile'));
        },
        openBuilder: (_, close) {
          return GestureDetector(onTap: close, child: const Text('Page'));
        },
      ),
    );
    FlutterMemoryAllocations.instance.addListener(track);
    addTearDown(() => FlutterMemoryAllocations.instance.removeListener(track));

    await tester.tap(find.text('Tile'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Page'));
    await tester.pumpAndSettle();
    expect(undisposed, 0);
  });

  testWidgets('the page takes no taps until it starts to show', (tester) async {
    var taps = 0;

    await tester.pumpWidget(
      containerApp(
        closedBuilder: (_, open) {
          return TextButton(onPressed: open, child: const Text('Tile'));
        },
        openBuilder: (_, _) {
          return Align(
            alignment: Alignment.topLeft,
            child: TextButton(
              onPressed: () => taps++,
              child: const Text('Page'),
            ),
          );
        },
      ),
    );

    await tester.tap(find.text('Tile'));
    await tester.pump();
    await tester.tap(
      find.text('Page', skipOffstage: false),
      warnIfMissed: false,
    );
    expect(taps, 0);

    await tester.pumpAndSettle();
    await tester.tap(find.text('Page'));
    expect(taps, 1);
  });

  testWidgets('the tile keeps the theme of its place while it moves', (
    tester,
  ) async {
    final placeTheme = ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFF44336)),
    );
    final tileThemes = <ThemeData>[];

    await tester.pumpWidget(
      HostApp(
        home: HostScaffold(
          body: Theme(
            data: placeTheme,
            child: OpenContainer<void>(
              transition: OpenContainerTransition.zoom,
              closedBuilder: (context, open) {
                tileThemes.add(Theme.of(context));
                return TextButton(onPressed: open, child: const Text('Tile'));
              },
              openBuilder: (_, _) => const Text('Page'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Tile'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 30));
    expect(tileThemes, hasLength(2));
    expect(tileThemes.last.colorScheme, tileThemes.first.colorScheme);
  });

  bool snapshots(WidgetTester tester, String text) {
    return tester
        .widget<SnapshotWidget>(
          find
              .ancestor(
                of: find.text(text, skipOffstage: false),
                matching: find.byType(SnapshotWidget, skipOffstage: false),
              )
              .first,
        )
        .controller
        .allowSnapshotting;
  }

  testWidgets('zooms the page as a snapshot and shows it live once open', (
    tester,
  ) async {
    await tester.pumpWidget(
      containerApp(
        closedBuilder: (_, open) {
          return TextButton(onPressed: open, child: const Text('Tile'));
        },
        openBuilder: (_, _) => const Text('Page'),
      ),
    );

    await tester.tap(find.text('Tile'));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 90));
    expect(snapshots(tester, 'Page'), isTrue);
    expect(find.byType(Navigator), paints..drawImageRect());

    await tester.pumpAndSettle();
    expect(snapshots(tester, 'Page'), isFalse);
    final boundary = tester.renderObject<RenderRepaintBoundary>(
      find
          .ancestor(
            of: find.text('Page'),
            matching: find.byType(RepaintBoundary),
          )
          .first,
    );
    final layers = [
      for (
        Layer? layer = boundary.debugLayer;
        layer != null;
        layer = layer.parent
      )
        layer,
    ];
    expect(layers.last, same(tester.binding.renderViews.single.debugLayer));
    expect(layers, isNot(contains(isA<OpacityLayer>())));

    Navigator.of(tester.element(find.text('Page'))).pop();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(snapshots(tester, 'Page'), isTrue);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  Widget homeApp({ClosedCallback<void>? onClosed}) {
    return HostApp(
      onGenerateRoute: (settings) => HomeRoute<void>(
        settings: settings,
        builder: (_) => HostScaffold(
          body: Column(
            children: [
              const SizedBox(height: 100),
              const Text('Below'),
              SizedBox(
                width: 200,
                height: 60,
                child: OpenContainer<void>(
                  transition: OpenContainerTransition.zoom,
                  onClosed: onClosed,
                  closedBuilder: (_, open) {
                    return TextButton(
                      onPressed: open,
                      child: const Text('Tile'),
                    );
                  },
                  openBuilder: (_, _) {
                    return const Align(
                      alignment: Alignment.topLeft,
                      child: Text('Page'),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double progressOf(WidgetTester tester) {
    return ModalRoute.of(
      tester.element(find.text('Page', skipOffstage: false)),
    )!.animation!.value;
  }

  Rect scaledToward(Rect rect, double scale) {
    final center = _viewSize.center(Offset.zero);
    return Rect.fromLTRB(
      center.dx + (rect.left - center.dx) * scale,
      center.dy + (rect.top - center.dy) * scale,
      center.dx + (rect.right - center.dx) * scale,
      center.dy + (rect.bottom - center.dy) * scale,
    );
  }

  void expectRect(Rect actual, Rect expected) {
    expect(actual.left, moreOrLessEquals(expected.left, epsilon: 1e-6));
    expect(actual.top, moreOrLessEquals(expected.top, epsilon: 1e-6));
    expect(actual.right, moreOrLessEquals(expected.right, epsilon: 1e-6));
    expect(actual.bottom, moreOrLessEquals(expected.bottom, epsilon: 1e-6));
  }

  testWidgets('fades the page in over the tile and the tile in over it', (
    tester,
  ) async {
    await tester.pumpWidget(
      containerApp(
        closedBuilder: (_, open) {
          return TextButton(onPressed: open, child: const Text('Tile'));
        },
        openBuilder: (_, _) => const Text('Page'),
      ),
    );
    final page = SurfaceLevel.page.colorOf(
      Theme.of(tester.element(find.text('Tile'))).colorScheme,
    );
    final navigator = find.byType(Navigator);

    Future<void> pumpToCrossFade() async {
      for (var i = 0; i < 60; i++) {
        final progress = progressOf(tester);
        if (progress > 0.4 && progress < 0.6) {
          return;
        }
        await tester.pump(const Duration(milliseconds: 4));
      }
      fail('the zoom never crossed the middle');
    }

    await tester.tap(find.text('Tile'));
    await tester.pump();
    await pumpToCrossFade();
    expect(
      navigator,
      paints
        ..clipRect()
        ..rect()
        ..drawImageRect()
        ..rect(color: page)
        ..drawImageRect(),
    );

    await tester.pumpAndSettle();
    Navigator.of(tester.element(find.text('Page'))).pop();
    await tester.pump();
    await pumpToCrossFade();
    expect(
      navigator,
      paints
        ..clipRect()
        ..rect()
        ..rect(color: page)
        ..drawImageRect()
        ..drawImageRect(),
    );

    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('shrinks the page below and zooms out of the tile there', (
    tester,
  ) async {
    await tester.pumpWidget(homeApp());
    final below = tester.getRect(find.text('Below'));
    final tile = tester.getRect(find.byType(OpenContainer<void>));
    final page = tester.getSize(find.text('Tile'));

    await tester.tap(find.text('Tile'));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 60));
    var progress = progressOf(tester);
    expect(progress, inExclusiveRange(0, 1));
    expectRect(
      tester.getRect(find.text('Below')),
      scaledToward(below, 1 - _recededShrink * progress),
    );

    await tester.pumpAndSettle();
    expect(find.text('Below'), findsNothing);
    final open = tester.getRect(find.text('Page'));

    Navigator.of(tester.element(find.text('Page'))).pop();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    progress = progressOf(tester);
    expect(progress, inExclusiveRange(0, 1));
    final rect = Rect.lerp(
      scaledToward(tile, 1 - _recededShrink * progress),
      Offset.zero & _viewSize,
      progress,
    )!;
    final scale = rect.width / _viewSize.width;
    expectRect(
      tester.getRect(find.text('Page')),
      rect.topLeft + open.topLeft * scale & open.size * scale,
    );

    await tester.pumpAndSettle();
    expect(find.text('Page'), findsNothing);
    expect(tester.getSize(find.text('Tile')), page);
  });

  testWidgets('snapshots the page below only while the zoom moves', (
    tester,
  ) async {
    await tester.pumpWidget(homeApp());
    expect(snapshots(tester, 'Below'), isFalse);

    await tester.tap(find.text('Tile'));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 60));
    expect(snapshots(tester, 'Below'), isTrue);

    // Open, the page below may change, so a pop takes a new snapshot.
    await tester.pumpAndSettle();
    expect(snapshots(tester, 'Below'), isFalse);

    Navigator.of(tester.element(find.text('Page'))).pop();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(snapshots(tester, 'Below'), isTrue);

    await tester.pumpAndSettle();
    expect(snapshots(tester, 'Below'), isFalse);
  });

  const tileColor = Color(0xFFFF0000);

  /// Tiles C, A and B from the top, apart enough that a zoom out of A or B
  /// leaves C in view.
  Widget tilesApp(GlobalKey screen) {
    Widget tile(String name) {
      return SizedBox(
        height: 80,
        child: OpenContainer<void>(
          transition: OpenContainerTransition.zoom,
          closedBuilder: (_, open) {
            return GestureDetector(
              onTap: open,
              child: ColoredBox(
                color: tileColor,
                child: Center(child: Text('Tile $name')),
              ),
            );
          },
          openBuilder: (_, _) => Text('Page $name'),
        ),
      );
    }

    return RepaintBoundary(
      key: screen,
      child: HostApp(
        onGenerateRoute: (settings) => HomeRoute<void>(
          settings: settings,
          builder: (_) => HostScaffold(
            body: Column(
              children: [
                tile('C'),
                const SizedBox(height: 170),
                tile('A'),
                const SizedBox(height: 170),
                tile('B'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<Color> colorAt(
    WidgetTester tester,
    GlobalKey screen,
    Offset position,
  ) async {
    final boundary =
        screen.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final bytes = await tester.runAsync(() async {
      final image = await boundary.toImage();
      final data = await image.toByteData();
      image.dispose();
      return data!;
    });
    final offset =
        (position.dy.round() * _viewSize.width.round() + position.dx.round()) *
        4;
    return Color.fromARGB(
      bytes!.getUint8(offset + 3),
      bytes.getUint8(offset),
      bytes.getUint8(offset + 1),
      bytes.getUint8(offset + 2),
    );
  }

  // The page below dims as it recedes, so the tile only stays red.
  final showsTile = isA<Color>()
      .having((color) => color.r, 'red', greaterThan(0.8))
      .having((color) => color.g, 'green', lessThan(0.1));

  /// A point on the tile clear of its label.
  Offset tileSpot(WidgetTester tester, String name) {
    final tile = tester.getRect(
      find.ancestor(
        of: find.text('Tile $name'),
        matching: find.byType(OpenContainer<void>),
      ),
    );
    return tile.centerLeft + const Offset(12, 0);
  }

  double routeProgress(WidgetTester tester, String page) {
    return ModalRoute.of(
      tester.element(find.text(page, skipOffstage: false)),
    )!.animation!.value;
  }

  testWidgets('a zoom opened while another closes keeps the page below', (
    tester,
  ) async {
    tester.view.physicalSize = _viewSize;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final screen = GlobalKey();
    await tester.pumpWidget(tilesApp(screen));
    await tester.tap(find.text('Tile A'));
    await tester.pumpAndSettle();

    Navigator.of(tester.element(find.text('Page A'))).pop();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tap(find.text('Tile B'));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 24));
    expect(routeProgress(tester, 'Page A'), inExclusiveRange(0, 1));
    expect(routeProgress(tester, 'Page B'), inExclusiveRange(0, 0.3));
    expect(await colorAt(tester, screen, tileSpot(tester, 'C')), showsTile);

    // A hands its tile back while B, popped too, still covers the page.
    await tester.pump(const Duration(milliseconds: 60));
    Navigator.of(tester.element(find.text('Page B'))).pop();
    while (find.text('Page A', skipOffstage: false).evaluate().isNotEmpty) {
      await tester.pump(const Duration(milliseconds: 16));
    }
    expect(routeProgress(tester, 'Page B'), inExclusiveRange(0, 0.3));
    expect(await colorAt(tester, screen, tileSpot(tester, 'A')), showsTile);

    await tester.pumpAndSettle();
    for (final name in ['A', 'B', 'C']) {
      expect(find.text('Tile $name').hitTestable(), findsOneWidget);
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('a pop before the zoom moves hands the tile back', (
    tester,
  ) async {
    await tester.pumpWidget(homeApp());
    final tile = tester.getRect(find.text('Tile'));

    await tester.tap(find.text('Tile'));
    await tester.pump();
    Navigator.of(tester.element(find.text('Page', skipOffstage: false))).pop();
    await tester.pumpAndSettle();

    expect(find.text('Page', skipOffstage: false), findsNothing);
    expect(find.text('Tile').hitTestable(), findsOneWidget);
    expect(tester.getRect(find.text('Tile')), tile);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a drag back shrinks the page about the finger', (tester) async {
    var closed = false;
    await tester.pumpWidget(homeApp(onClosed: (_) => closed = true));
    await tester.tap(find.text('Tile'));
    await tester.pumpAndSettle();
    final open = tester.getRect(find.text('Page'));

    final gesture = await tester.startGesture(const Offset(100, 300));
    await gesture.moveBy(const Offset(40, 0));
    await tester.pump();
    final before = tester.getRect(find.text('Page'));
    expect(find.text('Below'), findsOneWidget);
    await gesture.moveBy(const Offset(80, 0));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    final after = tester.getRect(find.text('Page'));
    final shrink = (before.width - after.width) / open.width;
    expect(
      shrink,
      moreOrLessEquals(0.4 * 80 / (0.6 * _viewSize.width), epsilon: 1e-5),
    );
    // The point the drag started on stays under the finger.
    final startY = (after.top - before.top) / shrink;
    expect(startY, moreOrLessEquals(300, epsilon: 0.1));

    await gesture.up();
    await tester.pumpAndSettle();
    expect(tester.getRect(find.text('Page')), open);
    expect(find.text('Below'), findsNothing);
    expect(closed, isFalse);

    await gesture.down(const Offset(100, 300));
    await gesture.moveBy(const Offset(40, 0));
    await tester.pump();
    await gesture.moveBy(const Offset(300, 0));
    await tester.pump(const Duration(milliseconds: 500));
    await gesture.up();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    final closing = tester.getRect(find.text('Page'));
    expect(closing.width, lessThan(open.width));
    await tester.pumpAndSettle();
    expect(find.text('Page'), findsNothing);
    expect(closed, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a drag down dismisses the page and follows across, held back', (
    tester,
  ) async {
    var closed = false;
    await tester.pumpWidget(homeApp(onClosed: (_) => closed = true));
    await tester.tap(find.text('Tile'));
    await tester.pumpAndSettle();
    final open = tester.getRect(find.text('Page'));

    final gesture = await tester.startGesture(const Offset(400, 280));
    await gesture.moveBy(const Offset(0, 20));
    await gesture.moveBy(const Offset(100, 100));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    final dragged = tester.getRect(find.text('Page'));
    final scale = dragged.width / open.width;
    expect(
      scale,
      moreOrLessEquals(1 - 0.4 * 100 / (0.6 * _viewSize.height), epsilon: 1e-4),
    );
    final aside = dragged.left - _viewSize.width / 2 * (1 - scale);
    final rubber =
        (1 - 1 / (0.55 * 100 / _viewSize.width + 1)) * _viewSize.width;
    expect(aside, moreOrLessEquals(rubber, epsilon: 0.01));

    await gesture.moveBy(const Offset(0, 100));
    await gesture.up();
    await tester.pumpAndSettle();
    expect(find.text('Page'), findsNothing);
    expect(closed, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a drag with any upward part leaves the page alone', (
    tester,
  ) async {
    await tester.pumpWidget(homeApp());
    await tester.tap(find.text('Tile'));
    await tester.pumpAndSettle();
    final open = tester.getRect(find.text('Page'));

    final gesture = await tester.startGesture(const Offset(400, 300));
    await gesture.moveBy(const Offset(60, -3));
    await gesture.moveBy(const Offset(300, 0));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(tester.getRect(find.text('Page')), open);

    await gesture.up();
    await tester.pumpAndSettle();
    expect(find.text('Page'), findsOneWidget);
  });

  testWidgets('a drag let go short of 150 dp springs the page back', (
    tester,
  ) async {
    await tester.pumpWidget(homeApp());
    await tester.tap(find.text('Tile'));
    await tester.pumpAndSettle();
    final open = tester.getRect(find.text('Page'));

    final gesture = await tester.startGesture(const Offset(300, 300));
    await gesture.moveBy(const Offset(20, 0));
    await gesture.moveBy(const Offset(140, 0));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await gesture.up();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 60));
    final returning = tester.getRect(find.text('Page'));
    expect(returning.width, lessThan(open.width));

    await tester.pumpAndSettle();
    expect(tester.getRect(find.text('Page')), open);
    expect(find.text('Below'), findsNothing);
  });
}
