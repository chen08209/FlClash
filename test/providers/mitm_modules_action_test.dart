import 'dart:io';

import 'package:drift/native.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/common/mitm_module.dart';
import 'package:fl_clash/database/database.dart' as db;
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/action.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/providers/database.dart';
import 'package:fl_clash/providers/mitm.dart';
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
  late HttpServer server;
  late Map<String, String> bodies;
  late Directory home;
  late db.Database testDatabase;
  late ProviderContainer container;

  setUpAll(() async {
    loadAppLocalizations(const Locale('en'));
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

  test('a script a module carries in its text is written out', () async {
    bodies = {
      '/inline.stoverride': r'''
name: Inline
http:
  script:
    - match: ^https?://a\.com
      name: inline
      type: response
script-providers:
  inline:
    payload: $done({})
''',
    };

    await action().addFromUrl(urlOf('/inline.stoverride'));

    final saved = (await stored()).single;
    final MapEntry(:key, :value) = saved.resources.entries.single;
    expect(key, startsWith('inline:'));
    expect(
      await File(
        join(await appPath.mitmResourcesDirPath, value),
      ).readAsString(),
      r'$done({})',
    );
    expect(saved.scripts, 1);
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

  test('cleanings that overlap remove each stale file once', () async {
    final resources = await appPath.mitmResourcesDirPath;
    await Directory(resources).create(recursive: true);
    for (var index = 0; index < 32; index++) {
      await File(join(resources, 'stale$index.json')).writeAsString('{}');
    }

    await Future.wait([action().clean(), action().clean(), action().clean()]);

    expect(await files(appPath.mitmResourcesDirPath), isEmpty);
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

      action().putModule(added.copyWith(enabled: true, accepted: true));
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

  test('a module that changes network settings is added off', () async {
    bodies = {'/dns.sgmodule': '[General]\ndns-server = 223.5.5.5\n'};
    await action().addFromUrl(urlOf('/dns.sgmodule'));
    expect((await stored()).single.enabled, isFalse);
  });

  test(
    'a module that skips verifying or limits clients is added off',
    () async {
      bodies = {
        '/cert.sgmodule':
            '[MITM]\nhostname = %APPEND% api.example.com\n'
            'skip-server-cert-verify = true\n',
        '/lan.sgmodule':
            '[MITM]\nclient-source-address = %APPEND% 192.168.1.0/24\n',
      };
      await action().addFromUrl(urlOf('/cert.sgmodule'));
      await action().addFromUrl(urlOf('/lan.sgmodule'));
      expect(
        [for (final module in await stored()) module.enabled],
        [false, false],
      );
    },
  );

  test('a module added with scripts waits until the user answers', () async {
    bodies = {
      '/ads.sgmodule':
          '${module('Ads')}[Script]\n'
          'Ads = type=cron,cronexp="0 * * * *",script-path=${urlOf('/a.js')}\n',
      '/a.js': r'$done({})',
      '/blank.json': '{}',
    };
    final added = await action().addFromUrl(urlOf('/ads.sgmodule'));
    expect(added.enabled, isFalse);
    expect(container.read(mitmModulesToAgreeProvider).single.id, added.id);

    action().putModule(added.copyWith(accepted: false));

    expect(container.read(mitmModulesToAgreeProvider), isEmpty);
  });

  test('a restore reads what each module asks from its own file', () async {
    bodies = {'/ads.sgmodule': module('Ads'), '/blank.json': '{}'};
    final added = await action().addFromUrl(urlOf('/ads.sgmodule'));
    action().putModule(added.copyWith(id: added.id + 1));
    await File(
      join(await appPath.mitmModulesDirPath, added.fileName),
    ).writeAsString('[General]\ndns-server = 223.5.5.5\n');
    expect(
      [for (final item in await stored()) item.asksConsent],
      [false, false],
    );

    await action().recheckConsent();

    expect([for (final item in await stored()) item.asksConsent], [true, true]);
  });

  group('an update that brings scripts', () {
    String withScript() =>
        '''
${module('Ads')}[Script]
Ads = type=http-response,pattern=^https://a,script-path=${urlOf('/ads.js')}
''';

    Future<MitmModule> bringScripts() async {
      bodies['/ads.sgmodule'] = withScript();
      bodies['/ads.js'] = r'$done({})';
      return action().updateModule((await stored()).single);
    }

    Set<int> awaitingConsent() => {
      for (final module in container.read(mitmModulesToAgreeProvider))
        module.id,
    };

    setUp(() async {
      bodies = {'/ads.sgmodule': module('Ads'), '/blank.json': '{}'};
      await action().addFromUrl(urlOf('/ads.sgmodule'));
    });

    test('turns off a module never agreed to and asks', () async {
      final added = (await stored()).single;
      expect(added.enabled, isTrue);
      expect(added.accepted, isNull);

      final updated = await bringScripts();

      expect(updated.enabled, isFalse);
      expect((await stored()).single.enabled, isFalse);
      expect((await stored()).single.scripts, 1);
      expect(awaitingConsent(), {updated.id});
    });

    test('keeps a module agreed to on', () async {
      action().putModule((await stored()).single.copyWith(accepted: true));

      final updated = await bringScripts();

      expect(updated.enabled, isTrue);
      expect((await stored()).single.scripts, 1);
      expect(awaitingConsent(), isEmpty);
    });

    test('leaves a module the user turned off alone', () async {
      action().putModule(
        (await stored()).single.copyWith(enabled: false, accepted: false),
      );

      await bringScripts();

      expect((await stored()).single.enabled, isFalse);
      expect(awaitingConsent(), isEmpty);
    });

    test('asks again about a module the user once declined', () async {
      action().putModule((await stored()).single.copyWith(accepted: false));

      final updated = await bringScripts();

      expect(updated.enabled, isFalse);
      expect(updated.accepted, isNull);
      expect(awaitingConsent(), {updated.id});
    });

    test('is told apart from one that only widens the hosts', () async {
      bodies['/ads.sgmodule'] = module(
        'Ads',
      ).replaceFirst('example.com', 'example.com, *.example.org');

      final updated = await action().updateModule((await stored()).single);

      expect(updated.enabled, isTrue);
      expect(awaitingConsent(), isEmpty);
    });
  });

  test(
    'an edit that brings scripts turns off a module never agreed to',
    () async {
      final local = await action().create(
        '[URL Rewrite]\n^https://a - reject\n',
      );
      action().putModule(local.copyWith(enabled: true));

      final edited = await action().edit(
        (await stored()).single,
        '[Script]\nA = type=cron,cronexp="0 * * * *",script-path=a.js\n',
      );

      expect(edited.enabled, isFalse);
      expect(container.read(mitmModulesToAgreeProvider).single.id, edited.id);
    },
  );

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
      action().putModule(
        (await stored()).single.copyWith(enabled: true, accepted: true),
      );
      return (await stored()).single;
    }

    // The sweep a save leaves running must end before the test's directory goes.
    tearDown(() => Future<void>.delayed(const Duration(milliseconds: 50)));

    test('stays on through an update that changes its scripts', () async {
      final ads = await accepted();
      bodies['/ads.sgmodule'] = scripted('.*');
      bodies['/ads.js'] = 'two';

      await action().updateModule(ads);

      expect((await stored()).single.enabled, isTrue);
    });

    if (rsFeature) {
      test(
        'stays on through an auto update that changes its scripts',
        () async {
          final ads = await accepted();
          bodies['/ads.js'] = 'two';
          action().putModule(ads.copyWith(lastUpdateTime: DateTime.utc(2000)));
          container
              .read(patchClashConfigProvider.notifier)
              .value = const PatchClashConfig(
            mitm: Mitm(enable: true),
            geoAutoUpdate: true,
          );

          await action().autoUpdate();

          final updated = (await stored()).single;
          expect(updated.enabled, isTrue);
          expect(updated.lastUpdateTime.isAfter(DateTime.utc(2000)), isTrue);
        },
      );
    }
  });

  group('values that declare a new script', () {
    setUp(() async {
      bodies = {
        '/q.snippet': '''
#!arguments=Line:
[rewrite_local]
{{{Line}}}
^https://a url reject
''',
        '/a.js': 'one',
      };
      await action().addFromUrl(urlOf('/q.snippet'));
    });

    Future<MitmModule?> declare(MitmModule module) => action().setArguments(
      module,
      {'Line': '^https://b url script-response-body ${urlOf('/a.js')}'},
    );

    test('turn off a module never agreed to', () async {
      final module = (await stored()).single;
      expect(module.enabled, isTrue);

      final returned = await declare(module);

      final changed = (await stored()).single;
      expect(returned, changed);
      expect(changed.enabled, isFalse);
      expect(changed.scripts, 1);
      expect(changed.resources.keys, [urlOf('/a.js')]);
      expect(container.read(mitmModulesToAgreeProvider).single.id, changed.id);
    });

    test('never leave a module never agreed to on with them', () async {
      final module = (await stored()).single;
      final seen = <MitmModule>[];
      container.listen(
        mitmModulesProvider,
        (_, next) => seen.addAll(next.value ?? const []),
      );

      await declare(module);

      expect(seen, isNotEmpty);
      expect(
        seen.where(
          (item) => item.enabled && item.arguments.containsKey('Line'),
        ),
        isEmpty,
      );
    });

    test('keep a module agreed to on', () async {
      action().putModule((await stored()).single.copyWith(accepted: true));

      await declare((await stored()).single);

      final changed = (await stored()).single;
      expect(changed.enabled, isTrue);
      expect(changed.scripts, 1);
    });
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

    if (rsFeature) {
      test('a module past the interval updates', () async {
        final time = await updatedAfter(
          autoUpdate: true,
          age: const Duration(hours: 25),
        );
        expect(recent(time), isTrue);
      });
    }

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

    if (rsFeature) {
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
        final file = File(
          join(await appPath.mitmModulesDirPath, added.fileName),
        );
        await file.delete();
        await action().autoUpdate();
        expect(await file.exists(), isTrue);
      });
    }
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
