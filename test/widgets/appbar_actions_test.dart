import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/glyph_finders.dart';
import '../helpers/test_app.dart';

void _noop() {}

const _mobile = Size(400, 900);
const _desktop = Size(1200, 900);

final _views = {'a mobile view': _mobile, 'a desktop view': _desktop};

Finder _container(Finder button) =>
    find.descendant(of: button, matching: find.byType(Material)).first;

Iterable<Rect> _clipsAbove(RenderObject box) sync* {
  var child = box;
  for (var parent = box.parent; parent != null; parent = parent.parent) {
    final clip = parent.describeApproximatePaintClip(child);
    if (clip != null) {
      yield MatrixUtils.transformRect(parent.getTransformTo(null), clip);
    }
    child = parent;
  }
}

Future<Rect> _pumpBar(
  WidgetTester tester, {
  required Widget child,
  required Size view,
  required TargetPlatform platform,
}) async {
  tester.view.physicalSize = view;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    TestApp(
      overrides: [viewSizeProvider.overrideWithBuild((_, _) => view)],
      homeBuilder: (page) => Navigator(
        onGenerateInitialRoutes: (_, _) => [
          MaterialPageRoute<void>(builder: (_) => const SizedBox()),
          MaterialPageRoute<void>(builder: (_) => page),
        ],
      ),
      child: Theme(
        data: ThemeData(platform: platform),
        child: child,
      ),
    ),
  );
  await tester.pumpAndSettle();
  return tester.getRect(find.byType(NavigationToolbar).first);
}

void main() {
  for (final view in _views.entries) {
    final inset = appBarActionInset(view.value == _mobile);

    for (final platform in [TargetPlatform.android, TargetPlatform.macOS]) {
      testWidgets(
        'an icon action mirrors the leading button in ${view.key} on $platform',
        (tester) async {
          final bar = await _pumpBar(
            tester,
            view: view.value,
            platform: platform,
            child: const CommonScaffold(
              title: 'Title',
              actions: [
                IconButton(onPressed: _noop, icon: GlyphIcon(AppGlyphs.sync)),
              ],
              body: SizedBox(),
            ),
          );
          final leading = tester.getRect(_container(find.byType(BackButton)));
          final action = tester.getRect(
            _container(find.widgetWithGlyph(IconButton, AppGlyphs.sync)),
          );

          expect(leading.left, inset);
          expect(bar.right - action.right, inset);
        },
      );

      testWidgets(
        'a sheet page ends where its back button starts in ${view.key} '
        'on $platform',
        (tester) async {
          final bar = await _pumpBar(
            tester,
            view: view.value,
            platform: platform,
            child: const SheetProvider(
              type: SheetType.page,
              child: CommonScaffold(
                title: 'Providers',
                actions: [
                  AppBarActionButton(
                    data: IconButtonData(
                      glyph: AppGlyphs.sync,
                      onPressed: _noop,
                    ),
                  ),
                ],
                body: SizedBox(),
              ),
            ),
          );
          final leading = tester.getRect(_container(find.byType(BackButton)));
          final action = tester.getRect(
            _container(find.widgetWithGlyph(IconButton, AppGlyphs.sync)),
          );

          expect(leading.left, inset);
          expect(bar.right - action.right, inset);
        },
      );
    }

    testWidgets(
      'a text action is a pill as tall as the leading button in ${view.key}',
      (tester) async {
        final bar = await _pumpBar(
          tester,
          view: view.value,
          platform: TargetPlatform.android,
          child: const CommonScaffold(
            title: 'Title',
            actions: [FilledButton.tonal(onPressed: _noop, child: Text('Add'))],
            body: SizedBox(),
          ),
        );
        final leading = tester.getRect(_container(find.byType(BackButton)));
        final action = tester.getRect(find.byType(FilledButton));

        expect(leading.width, leading.height);
        expect(action.height, leading.height);
        expect(action.width, greaterThan(action.height));
        expect(bar.right - action.right, inset);
      },
    );
  }

  testWidgets('two bar buttons share one pressable group', (tester) async {
    final bar = await _pumpBar(
      tester,
      view: _desktop,
      platform: TargetPlatform.android,
      child: const CommonScaffold(
        title: 'Title',
        iconActions: [
          IconButtonData(glyph: AppGlyphs.sync, onPressed: _noop),
          IconButtonData(glyph: AppGlyphs.sort, onPressed: _noop),
        ],
        body: SizedBox(),
      ),
    );
    final group = find.byType(TonalButtonGroup);
    final leading = tester.getRect(_container(find.byType(BackButton)));

    expect(group, findsOneWidget);
    expect(
      find.descendant(of: group, matching: find.byType(IconButton)),
      findsNWidgets(2),
    );
    expect(
      find.descendant(of: group, matching: find.byType(ElasticPress)),
      findsOneWidget,
    );
    expect(tester.getSize(group).height, leading.height);
    expect(bar.right - tester.getRect(group).right, appBarActionInset(false));
  });

  testWidgets('raw action widgets press on their own, one gap apart', (
    tester,
  ) async {
    await _pumpBar(
      tester,
      view: _desktop,
      platform: TargetPlatform.android,
      child: const CommonScaffold(
        title: 'Title',
        actions: [
          IconButton(onPressed: _noop, icon: GlyphIcon(AppGlyphs.sync)),
          IconButton(onPressed: _noop, icon: GlyphIcon(AppGlyphs.sort)),
        ],
        body: SizedBox(),
      ),
    );
    final first = find.widgetWithGlyph(IconButton, AppGlyphs.sync);
    final second = find.widgetWithGlyph(IconButton, AppGlyphs.sort);

    expect(find.byType(TonalButtonGroup), findsNothing);
    for (final button in [first, second, find.byType(BackButton)]) {
      expect(
        find.ancestor(of: button, matching: find.byType(ElasticPress)),
        findsOneWidget,
      );
    }
    expect(
      tester.getRect(second).left - tester.getRect(first).right,
      AppBarActionEdge.container.gap,
    );
  });

  for (final type in [SheetType.page, SheetType.bottomSheet]) {
    testWidgets('a press swells past the bar of a ${type.name} unclipped', (
      tester,
    ) async {
      tester.view.padding = const FakeViewPadding(top: 24);
      addTearDown(tester.view.resetPadding);
      await _pumpBar(
        tester,
        view: _mobile,
        platform: TargetPlatform.android,
        child: SheetProvider(
          type: type,
          child: const CommonScaffold(
            title: 'Title',
            actions: [
              IconButton(onPressed: _noop, icon: GlyphIcon(AppGlyphs.sync)),
            ],
            body: SizedBox(width: double.infinity, height: 200),
          ),
        ),
      );
      final presses = find.byType(ElasticPress).evaluate();

      expect(presses, isNotEmpty);
      for (final press in presses) {
        final box = press.renderObject! as RenderBox;
        final rest = box.localToGlobal(Offset.zero) & box.size;
        // A press swells an eighth of the button and pulls 7/32 further.
        final swell = rest.inflate(rest.shortestSide * 11 / 32);
        for (final clip in _clipsAbove(box)) {
          expect(clip.expandToInclude(swell), clip);
        }
      }
    });
  }

  for (final (name, view, type, compact) in [
    ('a phone page', _mobile, null, true),
    ('a desktop page', _desktop, null, false),
    ('a desktop side sheet', _desktop, SheetType.sideSheet, true),
    ('a phone bottom sheet', _mobile, SheetType.bottomSheet, true),
  ]) {
    testWidgets('$name keeps to its width class', (tester) async {
      const scaffold = CommonScaffold(
        title: 'Title',
        actions: [
          IconButton(onPressed: _noop, icon: GlyphIcon(AppGlyphs.sync)),
        ],
        body: SizedBox(width: double.infinity, height: 200),
      );
      final bar = await _pumpBar(
        tester,
        view: view,
        platform: TargetPlatform.android,
        child: type == null
            ? scaffold
            : SheetProvider(type: type, child: scaffold),
      );
      final title = tester.getRect(
        find.descendant(of: find.byType(AppBar), matching: find.text('Title')),
      );
      final action = tester.getRect(
        _container(find.widgetWithGlyph(IconButton, AppGlyphs.sync)),
      );

      if (type == SheetType.bottomSheet) {
        expect(title.center.dx, moreOrLessEquals(bar.center.dx));
      } else {
        expect(title.center.dx, lessThan(bar.center.dx));
      }
      expect(bar.right - action.right, appBarActionInset(compact));
    });
  }

  testWidgets('searching keeps the bar buttons where they stood', (
    tester,
  ) async {
    await _pumpBar(
      tester,
      view: _mobile,
      platform: TargetPlatform.android,
      child: CommonScaffold(
        title: 'Title',
        searchState: AppBarSearchState(onSearch: (_) {}),
        body: const SizedBox(),
      ),
    );
    final leading = find.descendant(
      of: find.byType(AppBar),
      matching: find.byType(IconButton),
    );
    Color? glyphColor(Finder button) => IconTheme.of(
      tester.element(
        find
            .descendant(
              of: button,
              matching: find.byWidgetPredicate(
                (widget) => widget is Icon || widget is GlyphIcon,
              ),
            )
            .first,
      ),
    ).color;
    final back = tester.getRect(_container(leading.first));
    final backColor = glyphColor(leading.first);
    final search = find.widgetWithGlyph(IconButton, AppGlyphs.search);
    final trailing = tester.getRect(_container(search));

    await tester.tap(search);
    await tester.pumpAndSettle();
    final clear = find.widgetWithGlyph(IconButton, AppGlyphs.close);

    expect(tester.getRect(_container(leading.first)), back);
    expect(glyphColor(leading.first), backColor);
    expect(tester.getRect(_container(clear)).right, trailing.right);
  });
}
