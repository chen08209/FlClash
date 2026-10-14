import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/config/icon_sets.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/context_menu.dart';
import '../helpers/test_app.dart';

class _TestIconSets extends IconSets {
  _TestIconSets(this.initial);

  final List<IconSet> initial;
  final saved = <IconSet>[];
  final deleted = <int>[];

  @override
  Stream<List<IconSet>> build() => Stream.value(initial);

  @override
  void put(IconSet iconSet) => saved.add(iconSet);

  @override
  void del(int id) => deleted.add(id);

  @override
  void order(int oldIndex, int newIndex) {}
}

class _SlowIconSets extends _TestIconSets {
  _SlowIconSets(super.initial);

  @override
  Stream<List<IconSet>> build() => Stream.fromFuture(
    Future.delayed(const Duration(milliseconds: 100), () => initial),
  );
}

class _RecordingIconSetsAction extends IconSetsAction {
  _RecordingIconSetsAction({this.failure});

  final Exception? failure;
  final imported = <({String url, String name})>[];
  final synced = <IconSet>[];

  @override
  Future<IconSet> importUrl(String url, {String name = ''}) async {
    if (failure case final failure?) {
      throw failure;
    }
    imported.add((url: url, name: name));
    return IconSet(id: 9, name: name, url: url);
  }

  @override
  Future<IconSet> sync(IconSet iconSet) async {
    synced.add(iconSet);
    return iconSet;
  }
}

const _remote = IconSet(
  id: 1,
  name: 'Qure',
  url: 'https://example.com/qure.json',
  icons: [
    IconSetIcon(name: 'Hong_Kong.png', url: 'https://example.com/hk.png'),
    IconSetIcon(name: 'Japan.png', url: 'https://example.com/jp.png'),
  ],
);

const _local = IconSet(
  id: 2,
  name: 'Mine',
  icons: [IconSetIcon(name: 'Proxy.png', url: 'https://example.com/p.png')],
);

Future<void> _pumpView(
  WidgetTester tester, {
  required _TestIconSets iconSets,
  IconSetsAction? action,
  Widget child = const IconSetsView(),
}) async {
  const size = Size(1400, 1000);
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final container = ProviderContainer(
    overrides: [
      iconSetsProvider.overrideWith(() => iconSets),
      if (action != null) iconSetsActionProvider.overrideWith(() => action),
    ],
  );
  addTearDown(container.dispose);
  globalState.container = container;
  container.read(viewSizeProvider.notifier).update((_) => size);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: TestApp(child: child),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _openMenu(WidgetTester tester, String name) async {
  await rightClick(tester, find.text(name));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('lists each set with its size and where it comes from', (
    tester,
  ) async {
    await _pumpView(tester, iconSets: _TestIconSets(const [_remote, _local]));

    expect(find.text('Qure'), findsOne);
    expect(find.text('2'), findsOne);
    expect(find.text('Remote'), findsOne);
    expect(find.text('Mine'), findsOne);
    expect(find.text('1'), findsOne);
    expect(find.text('Local'), findsOne);
    expect(find.byType(DisclosureIndicator), findsNWidgets(2));
  });

  testWidgets('a url import hands over the url and the optional name', (
    tester,
  ) async {
    final action = _RecordingIconSetsAction();
    await _pumpView(tester, iconSets: _TestIconSets(const []), action: action);

    await tester.tap(find.byTooltip('Add'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Import from URL'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'URL'),
      'https://example.com/set.json',
    );
    await tester.tap(find.text('Submit'));
    await tester.pumpAndSettle();

    expect(action.imported.single, (
      url: 'https://example.com/set.json',
      name: '',
    ));
  });

  testWidgets('an import that fails says why', (tester) async {
    final action = _RecordingIconSetsAction(
      failure: const MessageException('Not a valid icon set'),
    );
    await _pumpView(tester, iconSets: _TestIconSets(const []), action: action);

    await tester.tap(find.byTooltip('Add'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Import from URL'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'URL'),
      'https://example.com/page.html',
    );
    await tester.tap(find.text('Submit'));
    await tester.pumpAndSettle();

    expect(find.text('Not a valid icon set'), findsOne);
    expect(action.imported, isEmpty);
  });

  testWidgets('a set is deleted only after confirming', (tester) async {
    final iconSets = _TestIconSets(const [_remote]);
    await _pumpView(tester, iconSets: iconSets);

    await _openMenu(tester, 'Qure');
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(iconSets.deleted, isEmpty);

    await _openMenu(tester, 'Qure');
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();

    expect(iconSets.deleted, [_remote.id]);
  });

  testWidgets('a remote set syncs from its menu and a local one has none', (
    tester,
  ) async {
    final action = _RecordingIconSetsAction();
    await _pumpView(
      tester,
      iconSets: _TestIconSets(const [_remote, _local]),
      action: action,
    );

    await _openMenu(tester, 'Mine');
    expect(find.text('Sync'), findsNothing);
    await tester.tapAt(Offset.zero);
    await tester.pumpAndSettle();

    await _openMenu(tester, 'Qure');
    await tester.tap(find.text('Sync'));
    await tester.pumpAndSettle();

    expect(action.synced.single, _remote);
  });

  testWidgets('a local set is renamed from its options', (tester) async {
    final iconSets = _TestIconSets(const [_local]);
    await _pumpView(tester, iconSets: iconSets);

    await _openMenu(tester, 'Mine');
    await tester.tap(find.text('Options'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(TextFormField, 'URL'), findsNothing);

    await tester.enterText(find.byType(TextField), 'Flags');
    await tester.tap(find.text('Submit'));
    await tester.pumpAndSettle();

    expect(iconSets.saved.single, _local.copyWith(name: 'Flags'));
  });

  testWidgets('tapping a set previews its icons', (tester) async {
    await _pumpView(tester, iconSets: _TestIconSets(const [_remote]));

    await tester.tap(find.text('Qure'));
    await tester.pumpAndSettle();

    expect(find.text('Hong Kong'), findsOne);
    expect(find.text('Japan'), findsOne);
  });

  testWidgets('a reopened page lists its sets through its transition', (
    tester,
  ) async {
    await _pumpView(
      tester,
      iconSets: _SlowIconSets(const [_remote]),
      child: Builder(
        builder: (context) => TextButton(
          onPressed: () => Navigator.of(
            context,
          ).push(MaterialPageRoute<void>(builder: (_) => const IconSetsView())),
          child: const Text('open'),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    globalState.navigatorKey.currentState!.pop();
    await tester.pumpAndSettle();

    await tester.tap(find.text('open'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Qure'), findsOne);
  });
}
