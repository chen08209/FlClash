import 'dart:io';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/providers/database.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/resources.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' hide context;

import '../helpers/context_menu.dart';
import '../helpers/glyph_finders.dart';
import '../helpers/test_app.dart';
import '../helpers/test_database_providers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory home;
  final supportDirectory = AppPath.supportDirectory;
  final temporaryDirectory = AppPath.temporaryDirectory;
  final cacheDirectory = AppPath.cacheDirectory;

  setUpAll(() async {
    home = Directory.systemTemp.createTempSync('flclash-resources-');
    AppPath.supportDirectory = () async => home;
    AppPath.temporaryDirectory = () async => home;
    AppPath.cacheDirectory = () async => home;
    await appPath.homeDirPath;
  });

  tearDownAll(() {
    AppPath.supportDirectory = supportDirectory;
    AppPath.temporaryDirectory = temporaryDirectory;
    AppPath.cacheDirectory = cacheDirectory;
    if (home.existsSync()) home.deleteSync(recursive: true);
  });

  // `getFileInfo` stats the file on the real event loop, outside fake-async.
  Future<void> settle(WidgetTester tester, {int rounds = 1}) async {
    for (var i = 0; i < rounds; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  ProviderContainer createContainer({
    List<IconSet> iconSets = const [],
    List<ClashProvider> ruleProviders = const [],
    List<Script> scripts = const [],
  }) {
    final container = ProviderContainer(
      overrides: [
        iconSetsProvider.overrideWith(() => TestIconSets(iconSets)),
        clashProvidersProvider.overrideWith(
          () => TestClashProviders(ruleProviders),
        ),
        scriptsProvider.overrideWith(() => TestScripts(scripts)),
      ],
    );
    addTearDown(container.dispose);
    globalState.container = container;
    return container;
  }

  Future<void> pumpUntilFound(WidgetTester tester, Finder finder) async {
    for (var i = 0; i < 100; i++) {
      await settle(tester);
      if (finder.evaluate().isNotEmpty) {
        return;
      }
    }
    fail('timed out waiting for $finder');
  }

  testWidgets('a geo row opens its link editor without a per-row action', (
    tester,
  ) async {
    const size = Size(1000, 1000);
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final container = createContainer();
    container.read(viewSizeProvider.notifier).update((_) => size);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(child: ResourcesView()),
      ),
    );
    await pumpUntilFound(tester, find.text(GeoResource.MMDB.name));
    await tester.pumpAndSettle();

    expect(find.text(currentAppLocalizations.geoResources), findsOneWidget);
    expect(find.byType(DecorationListItem), findsNWidgets(4));
    expect(find.byType(ItemPositionProvider), findsNWidgets(4));
    expect(find.byType(Switch), findsNothing);
    expect(
      find.descendant(
        of: find.byType(DecorationListItem),
        matching: find.byGlyph(AppGlyphs.more),
      ),
      findsNothing,
    );
    expect(find.byType(FutureBuilder<FileInfo?>), findsNWidgets(4));
    for (final url in defaultGeoXUrl.values) {
      expect(find.text(url), findsNothing);
    }

    await tester.tap(find.text(GeoResource.MMDB.name));
    await tester.pumpAndSettle();

    expect(
      find.descendant(
        of: find.byType(UpdateGeoUrlFormDialog),
        matching: find.text(defaultGeoXUrl[GeoResource.MMDB]!),
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), null);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('the bar menu switches auto update and sets its interval', (
    tester,
  ) async {
    const size = Size(1000, 1000);
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final container = createContainer();
    container.read(viewSizeProvider.notifier).update((_) => size);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(child: ResourcesView()),
      ),
    );
    await tester.pumpAndSettle();

    final l10n = currentAppLocalizations;
    bool autoUpdate() => container.read(patchClashConfigProvider).geoAutoUpdate;
    Future<void> tapMenuPath(List<String> labels) async {
      await tester.tap(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.byGlyph(AppGlyphs.more),
        ),
      );
      await tester.pumpAndSettle();
      for (final label in labels) {
        await tester.tap(find.text(label).last);
        await tester.pumpAndSettle();
      }
    }

    expect(find.byTooltip(l10n.update), findsOneWidget);
    expect(autoUpdate(), isFalse);

    await tapMenuPath([l10n.autoUpdate, l10n.turnOn]);
    expect(autoUpdate(), isTrue);

    await tapMenuPath([l10n.autoUpdate, l10n.turnOff]);
    expect(autoUpdate(), isFalse);

    await tapMenuPath([l10n.resourceUpdateInterval]);
    expect(find.byType(InputDialog), findsOneWidget);
    expect(
      find.text(defaultClashConfig.geoUpdateInterval.toString()),
      findsOneWidget,
    );

    await tester.enterText(find.byType(TextFormField), '6');
    await tester.tap(find.text(l10n.submit));
    await tester.pumpAndSettle();

    expect(find.byType(InputDialog), findsNothing);
    expect(container.read(patchClashConfigProvider).geoUpdateInterval, 6);
    expect(tester.takeException(), null);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('refreshes the update time once the core finishes updating', (
    tester,
  ) async {
    const size = Size(1000, 1000);
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final file = File(join(home.path, MMDB))
      ..writeAsBytesSync([0])
      ..setLastModifiedSync(DateTime.now().subtract(const Duration(days: 3)));
    addTearDown(file.deleteSync);

    final container = createContainer();
    container.read(viewSizeProvider.notifier).update((_) => size);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(child: ResourcesView()),
      ),
    );
    final l10n = currentAppLocalizations;
    await pumpUntilFound(tester, find.text(1.traffic.show));
    expect(find.text(l10n.daysAgo(3)), findsOneWidget);

    final updatingKeys = container.read(updatingKeysProvider.notifier);
    final key = GeoResource.MMDB.updatingKey;
    final operation = updatingKeys.start(key, scope: UpdatingScope.core);
    await settle(tester);
    await tester.pump(const Duration(seconds: 1));
    final geoItem = find.ancestor(
      of: find.text(GeoResource.MMDB.name),
      matching: find.byType(DecorationListItem),
    );
    expect(
      find.descendant(of: geoItem, matching: find.byType(CommonCircleLoading)),
      findsOneWidget,
    );
    expect(find.text(1.traffic.show), findsNothing);

    file.writeAsBytesSync(List.filled(2048, 0));
    await settle(tester, rounds: 5);
    expect(find.text(l10n.daysAgo(3)), findsOneWidget);

    updatingKeys.stop(key, operation);
    await pumpUntilFound(tester, find.text(2048.traffic.show));
    await tester.pump(const Duration(seconds: 1));

    expect(find.text(l10n.justNow), findsOneWidget);
    expect(find.text(l10n.daysAgo(3)), findsNothing);
    expect(find.byType(CommonCircleLoading), findsNothing);
    expect(tester.takeException(), null);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('a row opens its actions from a context menu', (tester) async {
    const size = Size(1000, 1000);
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    String? copied;
    final messenger = tester.binding.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'Clipboard.setData') {
        copied = (call.arguments as Map)['text'] as String;
      }
      return null;
    });
    addTearDown(
      () => messenger.setMockMethodCallHandler(SystemChannels.platform, null),
    );

    final iconSet = IconSet(
      id: 1,
      name: 'Remote icons',
      url: 'https://example.com/icons.json',
      lastUpdateTime: DateTime.now(),
    );
    final container = createContainer(iconSets: [iconSet]);
    container.read(viewSizeProvider.notifier).update((_) => size);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(child: ResourcesView()),
      ),
    );
    await pumpUntilFound(tester, find.text('Remote icons'));

    final l10n = currentAppLocalizations;
    Future<void> openMenu(String title) async {
      await rightClick(tester, find.text(title));
      await tester.pumpAndSettle();
    }

    await openMenu(GeoResource.MMDB.name);
    expect(find.text(l10n.sync), findsOneWidget);
    expect(find.text(l10n.edit), findsOneWidget);
    await tester.tap(find.text(l10n.copyLink));
    await tester.pumpAndSettle();
    expect(copied, defaultGeoXUrl[GeoResource.MMDB]);

    await openMenu('Remote icons');
    expect(find.text(l10n.sync), findsOneWidget);
    expect(find.text(l10n.edit), findsNothing);
    await tester.tap(find.text(l10n.copyLink));
    await tester.pumpAndSettle();
    expect(copied, iconSet.url);

    container.read(updatingKeysProvider.notifier).start(iconSet.updatingKey);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await rightClick(tester, find.text('Remote icons'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.text(l10n.copyLink), findsOneWidget);
    expect(find.text(l10n.sync), findsNothing);
    expect(tester.takeException(), null);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('lists remote resources and shows which are updating', (
    tester,
  ) async {
    const size = Size(1000, 1400);
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final remoteIconSet = IconSet(
      id: 1,
      name: 'Remote icons',
      url: 'https://example.com/icons.json',
      icons: const [
        IconSetIcon(name: 'a', url: 'https://example.com/a.png'),
        IconSetIcon(name: 'b', url: 'https://example.com/b.png'),
      ],
      lastUpdateTime: DateTime.now(),
    );
    const localIconSet = IconSet(id: 2, name: 'Local icons');
    const remoteProvider = ClashProvider(
      id: 3,
      label: 'Remote set',
      url: 'https://example.com/set.yaml',
      behavior: RuleProviderBehavior.domain,
    );
    const localProvider = ClashProvider(id: 4, label: 'Local set');
    final remoteScript = Script(
      id: 5,
      label: 'Remote script',
      url: 'https://example.com/script.js',
      lastUpdateTime: DateTime.now(),
    );
    final localScript = Script(
      id: 6,
      label: 'Local script',
      lastUpdateTime: DateTime.now(),
    );

    final container = createContainer(
      iconSets: [remoteIconSet, localIconSet],
      ruleProviders: [remoteProvider, localProvider],
      scripts: [remoteScript, localScript],
    );
    container.read(viewSizeProvider.notifier).update((_) => size);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(child: ResourcesView()),
      ),
    );
    await pumpUntilFound(tester, find.text('Remote script'));

    final l10n = currentAppLocalizations;
    for (final title in [l10n.iconSets, l10n.ruleProviders, l10n.script]) {
      expect(find.text(title), findsOneWidget);
    }
    for (final label in ['Remote icons', 'Remote set', 'Remote script']) {
      expect(find.text(label), findsOneWidget);
    }
    for (final label in ['Local icons', 'Local set', 'Local script']) {
      expect(find.text(label), findsNothing);
    }
    final iconSetItem = find.ancestor(
      of: find.text('Remote icons'),
      matching: find.byType(DecorationListItem),
    );
    final iconCount = find.descendant(
      of: iconSetItem,
      matching: find.widgetWithText(TonalChip, '2'),
    );
    expect(iconCount, findsOneWidget);
    expect(
      find.descendant(of: iconSetItem, matching: find.text(l10n.justNow)),
      findsOneWidget,
    );
    expect(find.text(remoteIconSet.url), findsNothing);
    await pumpUntilFound(
      tester,
      find.descendant(
        of: find.ancestor(
          of: find.text('Remote set'),
          matching: find.byType(DecorationListItem),
        ),
        matching: find.text(l10n.unknown),
      ),
    );
    expect(find.byType(CommonCircleLoading), findsNothing);
    expect(find.byGlyph(AppGlyphs.sync), findsOneWidget);

    container
        .read(updatingKeysProvider.notifier)
        .start(remoteIconSet.updatingKey);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(
      find.descendant(
        of: iconSetItem,
        matching: find.byType(CommonCircleLoading),
      ),
      findsOneWidget,
    );
    expect(iconCount, findsNothing);
    expect(
      find.descendant(of: iconSetItem, matching: find.text(l10n.justNow)),
      findsOneWidget,
    );
    expect(find.byGlyph(AppGlyphs.sync), findsNothing);
    expect(tester.takeException(), null);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('shows the loading illustration until every row is ready', (
    tester,
  ) async {
    const size = Size(1000, 1400);
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final container = createContainer(
      scripts: [
        Script(
          id: 1,
          label: 'Remote script',
          url: 'https://example.com/script.js',
          lastUpdateTime: DateTime.now(),
        ),
      ],
    );
    container.read(viewSizeProvider.notifier).update((_) => size);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TestApp(
          child: Builder(
            builder: (context) => TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const ResourcesView()),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pump();
    await settle(tester);

    final l10n = currentAppLocalizations;
    final illustration = find.byKey(
      const ValueKey(NullStatusIllustration.data),
    );
    expect(illustration, findsOneWidget);
    expect(find.text(GeoResource.MMDB.name), findsNothing);

    await tester.pumpAndSettle();
    await pumpUntilFound(tester, find.text(GeoResource.MMDB.name));
    expect(find.text('Remote script'), findsOneWidget);
    expect(find.text(l10n.unknown), findsNWidgets(GeoResource.values.length));
    await tester.pumpAndSettle();
    expect(illustration, findsNothing);
    expect(tester.takeException(), null);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
