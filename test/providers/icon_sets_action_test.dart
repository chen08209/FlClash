import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/database/database.dart' as db;
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/action.dart';
import 'package:fl_clash/providers/database.dart';
import 'package:fl_clash/state.dart';
import 'package:flutter/widgets.dart' show Locale;
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:riverpod/riverpod.dart';

String _iconSetJson(String name, List<String> icons) => json.encode({
  'name': name,
  'icons': [
    for (final icon in icons)
      {'name': '$icon.png', 'url': 'https://example.com/$icon.png'},
  ],
});

/// Real downloads over loopback: the test binding would answer every request
/// with a 400, so this suite runs without it.
void main() {
  late HttpServer server;
  late String body;
  Completer<void>? held;
  late db.Database testDatabase;
  late ProviderContainer container;

  setUpAll(() async {
    await AppLocalizations.load(const Locale('en'));
    globalState.packageInfo = PackageInfo(
      appName: 'FlClash',
      packageName: 'com.follow.clash',
      version: '1.0.0',
      buildNumber: '1',
    );
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    server.listen((request) async {
      await held?.future;
      final response = request.response;
      if (request.uri.path == '/missing') {
        response.statusCode = HttpStatus.notFound;
      } else {
        response.write(body);
      }
      await response.close();
    });
  });

  tearDownAll(() => server.close(force: true));

  setUp(() {
    held = null;
    testDatabase = db.Database(NativeDatabase.memory());
    db.database = testDatabase;
    container = ProviderContainer();
    globalState.container = container;
    container.listen(iconSetsProvider, (_, _) {});
  });

  tearDown(() async {
    container.dispose();
    await testDatabase.close();
  });

  String urlOf(String path) => 'http://127.0.0.1:${server.port}/$path';

  IconSetsAction action() => container.read(iconSetsActionProvider.notifier);

  Future<List<IconSet>> stored() async {
    await pumpEventQueue();
    return testDatabase.iconSetsDao.query().get();
  }

  test('a url import takes the name of the set unless one is given', () async {
    body = _iconSetJson('Qure', ['Proxy']);

    await action().importUrl(urlOf('qure.json'));
    await action().importUrl(urlOf('mine.json'), name: 'Mine');

    final iconSets = await stored();
    expect(iconSets.map((iconSet) => iconSet.name), ['Qure', 'Mine']);
    expect(iconSets.first.url, urlOf('qure.json'));
    expect(iconSets.first.icons.single.name, 'Proxy.png');
  });

  test('importing a url again syncs that set instead of adding one', () async {
    body = _iconSetJson('Qure', ['Proxy']);
    await action().importUrl(urlOf('qure.json'));
    await stored();
    body = _iconSetJson('Renamed upstream', ['Proxy', 'Direct']);

    await action().importUrl(urlOf('qure.json'));

    final iconSets = await stored();
    expect(iconSets.single.name, 'Qure');
    expect(iconSets.single.icons.map((icon) => icon.name), [
      'Proxy.png',
      'Direct.png',
    ]);
  });

  group('a set changed while it downloads', () {
    late IconSet saved;
    late Future<IconSet> syncing;

    setUp(() async {
      body = _iconSetJson('Qure', ['Proxy']);
      await action().importUrl(urlOf('qure.json'));
      saved = (await stored()).single;
      body = _iconSetJson('Qure', ['Proxy', 'Direct']);
      held = Completer();
      syncing = action().sync(saved);
      await pumpEventQueue();
    });

    Future<void> download() async {
      held!.complete();
      await syncing;
    }

    test('stays deleted', () async {
      container.read(iconSetsProvider.notifier).del(saved.id);
      await pumpEventQueue();

      await download();

      expect(await stored(), isEmpty);
    });

    test('keeps its new name and takes the new icons', () async {
      container
          .read(iconSetsProvider.notifier)
          .put(saved.copyWith(name: 'Renamed'));
      await pumpEventQueue();

      await download();

      final iconSet = (await stored()).single;
      expect(iconSet.name, 'Renamed');
      expect(iconSet.icons, hasLength(2));
    });
  });

  test(
    'a failed download or a document that is no icon set saves nothing',
    () async {
      body = '{"name": "x"}';

      await expectLater(
        action().importUrl(urlOf('missing')),
        throwsA(anything),
      );
      await expectLater(
        action().importUrl(urlOf('set.json')),
        throwsA(
          isA<MessageException>().having(
            (e) => e.message,
            'message',
            'Not a valid icon set',
          ),
        ),
      );
      expect(await stored(), isEmpty);
    },
  );

  test('a file import falls back to the file name', () async {
    action().importContent(
      'My icons.json',
      '{"icons": [{"url": "https://example.com/a.png"}]}',
    );

    final iconSets = await stored();
    expect(iconSets.single.name, 'My icons');
    expect(iconSets.single.isRemote, isFalse);
  });
}
