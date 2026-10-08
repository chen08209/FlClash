import 'package:drift/native.dart';
import 'package:fl_clash/database/database.dart' hide IconSets;
import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/profiles/custom/icon.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/glyph_finders.dart';
import '../helpers/test_app.dart';

class _TestIconSets extends IconSets {
  _TestIconSets(this.initial);

  final List<IconSet> initial;

  @override
  Stream<List<IconSet>> build() => Stream.value(initial);
}

const _hongKong = IconSetIcon(
  name: 'Hong_Kong.png',
  url: 'https://example.com/hk.png',
);
const _japan = IconSetIcon(
  name: 'Japan.png',
  url: 'https://example.com/jp.png',
);
const _youTube = IconSetIcon(
  name: 'YouTube.png',
  url: 'https://example.com/yt.png',
);
const _netflix = IconSetIcon(
  name: 'Netflix.png',
  url: 'https://example.com/nf.png',
);
const _regions = IconSet(id: 1, name: 'Regions', icons: [_hongKong, _japan]);
const _services = IconSet(id: 2, name: 'Services', icons: [_youTube, _netflix]);

class _PopResult {
  String? value;
  bool popped = false;
}

Future<_PopResult> _pumpPicker(
  WidgetTester tester, {
  List<IconSet> iconSets = const [],
  String? value,
  String groupName = '',
}) async {
  const size = Size(1400, 1000);
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final container = ProviderContainer(
    overrides: [iconSetsProvider.overrideWith(() => _TestIconSets(iconSets))],
  );
  addTearDown(container.dispose);
  globalState.container = container;
  container.read(viewSizeProvider.notifier).update((_) => size);

  final result = _PopResult();
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: TestApp(
        child: Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              result.value = await Navigator.of(context).push<String>(
                MaterialPageRoute(
                  builder: (_) =>
                      IconPickerView(value: value, groupName: groupName),
                ),
              );
              result.popped = true;
            },
            child: const Text('open'),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
  return result;
}

void main() {
  late Database testDatabase;

  setUp(() {
    testDatabase = Database(NativeDatabase.memory());
    database = testDatabase;
  });

  tearDown(() async {
    await testDatabase.close();
  });

  testWidgets('without icon sets or records it says where to add them', (
    tester,
  ) async {
    await _pumpPicker(tester);

    expect(
      find.text(
        'No icon sets yet. Add them in Advanced configuration → Icon sets',
      ),
      findsOne,
    );
    expect(find.byTooltip('Icon URL'), findsOne);
    expect(tester.takeException(), null);
  });

  testWidgets('suggests icons for the group name and returns the one tapped', (
    tester,
  ) async {
    final result = await _pumpPicker(
      tester,
      iconSets: [_regions, _services],
      groupName: 'YouTube Premium',
    );

    expect(find.text('Suggested'), findsOne);
    expect(find.text('YouTube'), findsOne);
    expect(find.text('Japan'), findsNothing);

    await tester.tap(find.text('YouTube'));
    await tester.pumpAndSettle();

    expect(result.value, _youTube.url);
  });

  testWidgets('switching the source shows the icons of that set', (
    tester,
  ) async {
    await _pumpPicker(tester, iconSets: [_regions, _services]);

    expect(find.text('Suggested'), findsNothing);
    expect(find.text('Hong Kong'), findsOne);

    await tester.tap(find.text('Services'));
    await tester.pumpAndSettle();

    expect(find.text('Hong Kong'), findsNothing);
    expect(find.text('Netflix'), findsOne);
  });

  testWidgets('opens on the set holding the current icon, which can be '
      'removed', (tester) async {
    final result = await _pumpPicker(
      tester,
      iconSets: [_regions, _services],
      value: _japan.url,
      groupName: 'YouTube',
    );

    expect(find.text('Hong Kong'), findsOne);
    expect(find.text('Japan'), findsNWidgets(2));

    await tester.tap(find.byTooltip('Remove'));
    await tester.pumpAndSettle();

    expect(result.value, '');
  });

  testWidgets('every icon sits on the same plate, only the chosen one is '
      'outlined, and names stay unframed below', (tester) async {
    await _pumpPicker(tester, iconSets: [_regions], value: _japan.url);

    Finder plateOf(String label) => find.descendant(
      of: find.byTooltip(label).last,
      matching: find.byType(Material),
    );
    BorderSide sideOf(String label) =>
        (tester.widget<Material>(plateOf(label)).shape! as OutlinedBorder).side;
    Color? colorOf(String label) =>
        tester.widget<Material>(plateOf(label)).color;

    expect(colorOf('Hong Kong'), isNot(Colors.transparent));
    expect(colorOf('Hong Kong'), colorOf('Japan'));
    expect(sideOf('Japan').style, BorderStyle.solid);
    expect(sideOf('Hong Kong'), BorderSide.none);
    expect(
      tester.getTopLeft(find.text('Hong Kong')).dy,
      greaterThanOrEqualTo(tester.getBottomLeft(plateOf('Hong Kong')).dy),
    );
  });

  testWidgets('leaving without a choice keeps the icon', (tester) async {
    final result = await _pumpPicker(
      tester,
      iconSets: [_regions],
      value: _japan.url,
    );

    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();

    expect(result.popped, isTrue);
    expect(result.value, isNull);
  });

  testWidgets('a search looks through every set by icon name', (tester) async {
    await _pumpPicker(tester, iconSets: [_regions, _services]);

    await tester.tap(find.byGlyph(AppGlyphs.search));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'net');
    await tester.pumpAndSettle();

    expect(find.text('Netflix'), findsOne);
    expect(find.text('Services'), findsOne);
    expect(find.text('Hong Kong'), findsNothing);
    expect(find.text('Regions'), findsNothing);

    await tester.enterText(find.byType(TextField), 'nothing like it');
    await tester.pumpAndSettle();

    expect(find.byType(NullStatus), findsOne);
  });

  testWidgets('a search shows an icon once, under the first source with it', (
    tester,
  ) async {
    await _pumpPicker(
      tester,
      iconSets: [_regions, _services],
      groupName: 'YouTube',
    );

    await tester.tap(find.byGlyph(AppGlyphs.search));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'you');
    await tester.pumpAndSettle();

    expect(find.text('YouTube'), findsOne);
    expect(find.text('Suggested'), findsOne);
    expect(find.text('Services'), findsNothing);
  });

  testWidgets('suggested leads with the matches and then the recent icons', (
    tester,
  ) async {
    await testDatabase.iconRecordsDao.put('https://example.com/Proxy.png');
    await _pumpPicker(
      tester,
      iconSets: [_regions, _services],
      groupName: 'YouTube',
    );

    expect(find.text('Suggested'), findsOne);
    expect(find.text('Recent'), findsNothing);
    final youTube = tester.getTopLeft(find.text('YouTube'));
    final proxy = tester.getTopLeft(find.text('Proxy'));
    expect(
      youTube.dy < proxy.dy || youTube.dy == proxy.dy && youTube.dx < proxy.dx,
      isTrue,
    );

    await tester.longPress(find.text('YouTube'));
    await tester.pumpAndSettle();
    expect(find.text('Confirm'), findsNothing);
  });

  testWidgets('a large set is matched off the UI isolate without an empty '
      'state first', (tester) async {
    final many = IconSet(
      id: 3,
      name: 'Many',
      icons: [
        for (var index = 0; index < 1000; index++)
          IconSetIcon(
            name: 'Icon_$index.png',
            url: 'https://example.com/$index.png',
          ),
        _youTube,
      ],
    );
    await _pumpPicker(tester, iconSets: [many], groupName: 'YouTube');

    expect(find.text('Suggested'), findsNothing);
    expect(find.byType(NullStatus), findsNothing);

    for (var attempt = 0; attempt < 40; attempt++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 50)),
      );
      await tester.pumpAndSettle();
      if (find.text('Suggested').evaluate().isNotEmpty) {
        break;
      }
    }

    expect(find.text('Suggested'), findsOne);
    expect(find.text('YouTube'), findsOne);
    expect(find.text('Icon 0'), findsNothing);
  });

  testWidgets('a recent icon can be forgotten with a long press', (
    tester,
  ) async {
    await testDatabase.iconRecordsDao.put('https://example.com/Proxy.png');
    await _pumpPicker(tester);

    expect(find.text('Suggested'), findsOne);

    await tester.longPress(find.text('Proxy'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();

    expect(find.text('Proxy'), findsNothing);
    expect(await testDatabase.iconRecordsDao.query(''), isEmpty);
  });

  testWidgets('a link is accepted only once it is a url', (tester) async {
    final result = await _pumpPicker(tester, iconSets: [_regions]);

    await tester.tap(find.byTooltip('Icon URL'));
    await tester.pumpAndSettle();

    final field = find.descendant(
      of: find.byType(InputDialog),
      matching: find.byType(TextFormField),
    );
    await tester.enterText(field, 'not a link');
    await tester.tap(find.text('Submit'));
    await tester.pumpAndSettle();

    expect(find.byType(InputDialog), findsOne);
    expect(result.popped, isFalse);

    await tester.enterText(field, ' https://example.com/custom.png ');
    await tester.tap(find.text('Submit'));
    await tester.pumpAndSettle();

    expect(result.value, 'https://example.com/custom.png');
  });

  testWidgets('the grid builds the rows past the viewport only once the page '
      'has arrived', (tester) async {
    tester.view.physicalSize = const Size(400, 600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    var lastBuilt = -1;
    await tester.pumpWidget(
      TestApp(
        child: Builder(
          builder: (context) => TextButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => IconGridScrollView(
                  slivers: [
                    SliverFixedExtentList.builder(
                      itemExtent: 100,
                      itemCount: 50,
                      itemBuilder: (_, index) {
                        lastBuilt = index > lastBuilt ? index : lastBuilt;
                        return Text('row $index');
                      },
                    ),
                  ],
                ),
              ),
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(lastBuilt, lessThan(7));

    await tester.pumpAndSettle();

    expect(lastBuilt, greaterThan(7));
  });
}
