import 'dart:io';

import 'package:drift/native.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/common/mitm_module.dart';
import 'package:fl_clash/database/database.dart' as db;
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/action.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/providers/database.dart';
import 'package:fl_clash/state.dart';
import 'package:flutter/widgets.dart' show Locale;
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart';
import 'package:riverpod/riverpod.dart';

import '../helpers/app_paths.dart';

/// Real downloads over loopback: the test binding answers every request with a
/// 400, so its override is lifted while a test runs.
void main() {
  setUp(() {
    mitmFeature = true;
    addTearDown(() => mitmFeature = false);
  });

  late HttpServer server;
  late Map<String, String> bodies;
  late Directory home;
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
      final response = request.response;
      final body = bodies[request.uri.path];
      if (body == null) {
        response.statusCode = HttpStatus.notFound;
      } else {
        response.write(body);
      }
      await response.close();
    });
  });

  tearDownAll(() => server.close(force: true));

  setUp(() async {
    final bindingOverrides = HttpOverrides.current;
    HttpOverrides.global = null;
    addTearDown(() => HttpOverrides.global = bindingOverrides);
    home = await Directory.systemTemp.createTemp('mitm_modules_action');
    addTearDown(() => home.delete(recursive: true));
    await useAppPaths(home);
    testDatabase = db.Database(NativeDatabase.memory());
    db.database = testDatabase;
    container = ProviderContainer();
    globalState.container = container;
    container.listen(mitmModulesProvider, (_, _) {});
    container.listen(patchClashConfigProvider, (_, _) {});
  });

  tearDown(() async {
    container.dispose();
    await testDatabase.close();
  });

  String urlOf(String path) => 'http://127.0.0.1:${server.port}$path';

  String module(String name) =>
      '''
#!name=$name
[MITM]
hostname = %APPEND% example.com
[Map Local]
^https://example\\.com/a data="${urlOf('/blank.json')}"
''';

  MitmModulesAction action() =>
      container.read(mitmModulesActionProvider.notifier);

  Future<List<MitmModule>> stored() async {
    await pumpEventQueue();
    return testDatabase.mitmModulesDao.query().get();
  }

  Future<List<String>> files(Future<String> directory) async {
    final entries = await Directory(await directory).list().toList();
    return [for (final entry in entries) basename(entry.path)]..sort();
  }

  test('a module downloads with the files it serves', () async {
    bodies = {'/ads.sgmodule': module('Ads'), '/blank.json': '{}'};

    final added = await action().addFromUrl(urlOf('/ads.sgmodule'));

    final saved = (await stored()).single;
    expect(saved.name, 'Ads');
    expect(saved.url, urlOf('/ads.sgmodule'));
    final resource = saved.resources[urlOf('/blank.json')]!;
    expect(resource, endsWith('.json'));
    expect(await files(appPath.mitmModulesDirPath), [added.fileName]);
    expect(
      await File(
        join(await appPath.mitmResourcesDirPath, resource),
      ).readAsString(),
      '{}',
    );
  });

  test('a resource that fails to download keeps its last copy', () async {
    bodies = {'/ads.sgmodule': module('Ads'), '/blank.json': '{}'};
    await action().addFromUrl(urlOf('/ads.sgmodule'));
    final resources = (await stored()).single.resources;
    bodies.remove('/blank.json');

    await action().updateModule((await stored()).single);

    expect((await stored()).single.resources, resources);
  });

  test('a page that is not a module is turned down', () async {
    bodies = {'/page': '<html>Not found</html>'};

    await expectLater(
      action().addFromUrl(urlOf('/page')),
      throwsA(isA<MessageException>()),
    );
    expect(await stored(), isEmpty);
  });

  test('cleaning keeps only the files something still names', () async {
    bodies = {'/ads.sgmodule': module('Ads'), '/blank.json': '{}'};
    await action().addFromUrl(urlOf('/ads.sgmodule'));
    final resource = (await stored()).single.resources.values.single;
    final local = await action().create(
      '[Map Local]\n^https://own data="own.gif"\n',
    );
    await action().attach(local, 'own.gif', 'gif'.codeUnits);
    final attachment = mitmAttachments(
      (await stored()).firstWhere((item) => item.id == local.id),
    )['own.gif']!;
    final resources = await appPath.mitmResourcesDirPath;
    await File(join(resources, 'stale.json')).writeAsString('{}');

    await action().clean();

    expect(
      await files(appPath.mitmResourcesDirPath),
      unorderedEquals([resource, attachment]),
    );
  });

  test(
    'a module with scripts is added off and keeps the user choice',
    () async {
      bodies = {
        '/ads.sgmodule':
            '''
[Argument]
Extra = switch,false
[Script]
Ads = type=http-response,pattern=^https://a,script-path=${urlOf('/ads.js')}
Extra = type=http-response,pattern=^https://b,script-path=${urlOf('/extra.js')},enable={Extra}
''',
        '/ads.js': r'$done({})',
        '/extra.js': r'$done({})',
      };

      await action().addFromUrl(urlOf('/ads.sgmodule'));
      final added = (await stored()).single;
      expect(added.enabled, isFalse);
      expect(added.scripts, 2);
      expect(added.resources.keys, [urlOf('/ads.js')]);

      action().putModule(added.copyWith(enabled: true));
      await action().setArguments((await stored()).single, const {
        'Extra': 'true',
      });

      final changed = (await stored()).single;
      expect(changed.enabled, isTrue);
      expect(changed.resources.keys, {urlOf('/ads.js'), urlOf('/extra.js')});
      await action().updateModule(changed);
      expect((await stored()).single.enabled, isTrue);
    },
  );

  test('an update that brings more scripts turns the module off', () async {
    bodies = {'/ads.sgmodule': module('Ads'), '/blank.json': '{}'};
    await action().addFromUrl(urlOf('/ads.sgmodule'));
    expect((await stored()).single.enabled, isTrue);
    bodies['/ads.sgmodule'] =
        '''
${module('Ads')}[Script]
Ads = type=http-response,pattern=^https://a,script-path=${urlOf('/ads.js')}
''';
    bodies['/ads.js'] = r'$done({})';

    final updated = await action().updateModule((await stored()).single);

    expect(updated.enabled, isFalse);
    expect((await stored()).single.scripts, 1);
  });

  group('an accepted module', () {
    String scripted(String pattern) =>
        '''
#!name=Ads
[MITM]
hostname = example.com
[Script]
Ads = type=http-response,pattern=$pattern,script-path=${urlOf('/ads.js')}
''';

    Future<MitmModule> accepted() async {
      bodies = {'/ads.sgmodule': scripted('^https://a'), '/ads.js': 'one'};
      await action().addFromUrl(urlOf('/ads.sgmodule'));
      action().putModule((await stored()).single.copyWith(enabled: true));
      return (await stored()).single;
    }

    // The sweep a save leaves running must end before the test's directory goes.
    tearDown(() => Future<void>.delayed(const Duration(milliseconds: 50)));

    Future<bool> enabledAfterUpdate(MitmModule ads) async {
      await action().updateModule(ads);
      return (await stored()).single.enabled;
    }

    test('stays on through an update that changes no script', () async {
      final ads = await accepted();

      expect(await enabledAfterUpdate(ads), isTrue);
    });

    test('turns off when an update replaces a script\'s content', () async {
      final ads = await accepted();
      bodies['/ads.js'] = 'two';

      expect(await enabledAfterUpdate(ads), isFalse);
    });

    test('turns off when an update changes a script line', () async {
      final ads = await accepted();
      bodies['/ads.sgmodule'] = scripted('.*');

      expect(await enabledAfterUpdate(ads), isFalse);
    });

    test('stays on when an update drops a script', () async {
      final ads = await accepted();
      bodies['/ads.sgmodule'] = module('Ads');
      bodies['/blank.json'] = '{}';

      expect(await enabledAfterUpdate(ads), isTrue);
    });

    test('stays on through an update with no text to compare', () async {
      final ads = await accepted();
      await File(join(await appPath.mitmModulesDirPath, ads.fileName)).delete();

      expect(await enabledAfterUpdate(ads), isTrue);
    });

    test('an auto update that turns it off leaves it off', () async {
      final ads = await accepted();
      bodies['/ads.js'] = 'two';
      action().putModule(ads.copyWith(lastUpdateTime: DateTime.utc(2000)));
      container.read(patchClashConfigProvider.notifier).value =
          const PatchClashConfig(mitm: Mitm(enable: true), geoAutoUpdate: true);

      await action().autoUpdate();

      expect((await stored()).single.enabled, isFalse);
    });
  });

  test('values that declare a new script turn a module off to offer', () async {
    bodies = {
      '/q.snippet': '''
#!arguments=Line:
[rewrite_local]
{{{Line}}}
^https://a url reject
''',
    };
    await action().addFromUrl(urlOf('/q.snippet'));
    final module = (await stored()).single;
    expect(module.enabled, isTrue);
    bodies['/a.js'] = 'one';

    final turnedOff = await action().setArguments(module, {
      'Line': '^https://b url script-response-body ${urlOf('/a.js')}',
    });

    expect(turnedOff?.enabled, isFalse);
    expect((await stored()).single.enabled, isFalse);
    expect((await stored()).single.scripts, 1);
    expect((await stored()).single.resources.keys, [urlOf('/a.js')]);
  });

  test('an update keeps what the user changed while it ran', () async {
    bodies = {'/ads.sgmodule': module('Ads'), '/blank.json': '{}'};
    await action().addFromUrl(urlOf('/ads.sgmodule'));
    final added = (await stored()).single;

    final update = action().updateModule(added);
    action().putModule(added.copyWith(enabled: false));
    await update;

    expect((await stored()).single.enabled, isFalse);
  });

  test('a new module goes first and may start empty', () async {
    bodies = {'/ads.sgmodule': module('Ads'), '/blank.json': '{}'};
    await action().addFromUrl(urlOf('/ads.sgmodule'));

    final created = await action().create('#!name=Mine\n[URL Rewrite]\n');

    final modules = await stored();
    expect(modules.map((item) => item.name), ['Mine', 'Ads']);
    expect(modules.first.isRemote, isFalse);
    expect(modules.first.enabled, isTrue);
    expect(
      await File(
        join(await appPath.mitmModulesDirPath, created.fileName),
      ).readAsString(),
      '#!name=Mine\n[URL Rewrite]\n',
    );
  });

  test('an attachment outlasts an edit until it is removed', () async {
    final local = await action().create('#!name=Mine\n');
    await action().attach(local, 'own.js', r'$done()'.codeUnits);

    await action().edit(
      (await stored()).single,
      '#!name=Mine\n[Script]\nOwn = type=http-request,pattern=a,script-path=own.js\n',
    );
    final edited = (await stored()).single;
    expect(mitmAttachments(edited).keys, ['own.js']);
    expect(edited.scripts, 1);
    expect(edited.enabled, isFalse);

    await action().detach(edited, 'own.js');
    await action().clean();

    expect(mitmAttachments((await stored()).single), isEmpty);
    expect(await files(appPath.mitmResourcesDirPath), isEmpty);
  });

  test(
    'a captured response mapped locally reads from its attachment',
    () async {
      final line = mitmMapLocalLine(
        'https://a.test/ad.json?id=1',
        file: 'ad.json',
        contentType: 'application/json',
      );
      final created = await action().create(
        mitmAddLine('#!name=Mine\n', mitmMapLocalSection, line)!,
      );
      await action().attach(created, 'ad.json', '{"ad":0}'.codeUnits);

      final saved = (await stored()).single;
      final kept = saved.resources['ad.json']!;
      final content = parseMitmModule(
        await File(
          join(await appPath.mitmModulesDirPath, saved.fileName),
        ).readAsString(),
        resources: saved.resources,
      );
      expect(content.mapLocal.single, contains('data="$kept"'));
      expect(
        await File(
          join(await appPath.mitmResourcesDirPath, kept),
        ).readAsString(),
        '{"ad":0}',
      );
    },
  );

  group('auto update follows the resources settings', () {
    Future<DateTime> updatedAfter({
      required bool autoUpdate,
      required Duration age,
    }) async {
      bodies = {'/ads.sgmodule': module('Ads'), '/blank.json': '{}'};
      final added = await action().addFromUrl(urlOf('/ads.sgmodule'));
      final last = DateTime.now().subtract(age);
      action().putModule(added.copyWith(lastUpdateTime: last));
      await stored();
      container
          .read(patchClashConfigProvider.notifier)
          .update(
            (state) => state.copyWith(
              geoAutoUpdate: autoUpdate,
              geoUpdateInterval: 24,
              mitm: state.mitm.copyWith(enable: true),
            ),
          );
      await action().autoUpdate();
      final updated = (await stored()).single.lastUpdateTime;
      return updated.isAfter(last.add(const Duration(seconds: 1)))
          ? updated
          : last;
    }

    bool recent(DateTime time) =>
        DateTime.now().difference(time) < const Duration(minutes: 1);

    test('a module past the interval updates', () async {
      final time = await updatedAfter(
        autoUpdate: true,
        age: const Duration(hours: 25),
      );
      expect(recent(time), isTrue);
    });

    test('a module within the interval waits', () async {
      final time = await updatedAfter(
        autoUpdate: true,
        age: const Duration(hours: 23),
      );
      expect(recent(time), isFalse);
    });

    test('auto update off leaves a module with its content alone', () async {
      final time = await updatedAfter(
        autoUpdate: false,
        age: const Duration(hours: 25),
      );
      expect(recent(time), isFalse);
    });

    test('auto update off still brings back missing content', () async {
      bodies = {'/ads.sgmodule': module('Ads'), '/blank.json': '{}'};
      final added = await action().addFromUrl(urlOf('/ads.sgmodule'));
      await stored();
      container
          .read(patchClashConfigProvider.notifier)
          .update(
            (state) => state.copyWith(
              geoAutoUpdate: false,
              mitm: state.mitm.copyWith(enable: true),
            ),
          );
      final file = File(join(await appPath.mitmModulesDirPath, added.fileName));
      await file.delete();
      await action().autoUpdate();
      expect(await file.exists(), isTrue);
    });
  });

  test('deleting a module removes its content', () async {
    bodies = {'/ads.sgmodule': module('Ads'), '/blank.json': '{}'};
    await action().addFromUrl(urlOf('/ads.sgmodule'));

    await action().deleteModule((await stored()).single);

    expect(await stored(), isEmpty);
    expect(await files(appPath.mitmModulesDirPath), isEmpty);
    expect(await files(appPath.mitmResourcesDirPath), isEmpty);
  });
}
