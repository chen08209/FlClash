import 'dart:async';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/common/mitm_module_file.dart';
import 'package:fl_clash/core/core.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fl_clash/database/database.dart' as db;
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/action.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/providers/core.dart';
import 'package:fl_clash/providers/database.dart';
import 'package:fl_clash/providers/mitm.dart';
import 'package:fl_clash/state.dart';
import 'package:flutter/widgets.dart' show Locale;
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart';
import 'package:riverpod/riverpod.dart';

import '../helpers/app_paths.dart';
import '../helpers/core_mocks.dart';
import '../helpers/module_reads.dart';

/// Real downloads over loopback: the test binding answers every request with a
/// 400, so its override is lifted while a test runs. The Core's reading of
/// each module text is given as [reads].
void main() {
  late HttpServer server;
  late Map<String, String> bodies;
  var holds = <String, Future<void>>{};
  late Map<String, JsonMap Function(Map<String, String> arguments)> reads;
  late CoreMocks mocks;
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
      await holds[request.uri.path];
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
    holds = {};
    home = await Directory.systemTemp.createTemp('mitm_modules_action');
    addTearDown(() => home.delete(recursive: true));
    await useAppPaths(home);
    testDatabase = db.Database(NativeDatabase.memory());
    db.database = testDatabase;
    reads = {};
    mocks = coreMocks();
    when(
      () => mocks.api.fetchMitmModule(name: any(named: 'name')),
    ).thenAnswer((_) async {});
    stubModuleReads(mocks.api, (text, arguments) {
      final read = reads[text];
      if (read == null) {
        throw StateError('No reading for: $text');
      }
      return read(arguments);
    });
    container = ProviderContainer(
      overrides: [coreHandlerProvider.overrideWithValue(mocks.controller)],
    );
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

  /// [module] of [name], which maps its line 5 to the server's blank.json.
  JsonMap moduleReadOf(String name) => moduleRead(
    meta: {'name': name},
    resources: [
      {
        'url': urlOf('/blank.json'),
        'kind': 'map-local',
        'lines': [5],
      },
    ],
    views: {
      'hostname': [
        lineEntry(
          3,
          const MitmLineView.hosts(
            entries: [MitmHostEntry(host: 'example.com')],
          ),
        ),
      ],
    },
  );

  /// [module] of Sample with a script at line 7 that reads [script].
  JsonMap withScriptRead(String script) {
    final read = moduleReadOf('Sample');
    return {
      ...read,
      'resources': [...read['resources'] as List, scriptResource(script, 7)],
      'declaredScripts': [7],
    };
  }

  void serve(List<String> names) {
    bodies = {'/blank.json': '{}'};
    for (final name in names) {
      bodies['/${name.toLowerCase()}.sgmodule'] = module(name);
      reads[module(name)] = (_) => moduleReadOf(name);
    }
  }

  MitmModulesAction action() =>
      container.read(mitmModulesActionProvider.notifier);

  Future<List<MitmModule>> stored() async {
    await pumpEventQueue();
    return testDatabase.mitmModulesDao.query().get();
  }

  Future<List<String>> files(Future<String> path) async {
    final directory = Directory(await path);
    if (!await directory.exists()) {
      return const [];
    }
    final entries = await directory.list().toList();
    return [for (final entry in entries) basename(entry.path)]..sort();
  }

  test('a module is saved and leaves its remote files to the Core', () async {
    serve(['Sample']);

    final added = await action().addFromUrl(urlOf('/sample.sgmodule'));

    final saved = (await stored()).single;
    expect(saved.name, 'Sample');
    expect(saved.url, urlOf('/sample.sgmodule'));
    expect(saved.resources, isEmpty);
    expect(await files(appPath.mitmModulesDirPath), [added.fileName]);
    expect(Directory(await appPath.mitmResourcesDirPath).existsSync(), isFalse);
  });

  test(
    'a file FlClash stored stays for the Core while a line reads it',
    () async {
      serve(['Sample']);
      final added = await action().addFromUrl(urlOf('/sample.sgmodule'));
      action().putModule(
        added.copyWith(
          resources: {
            urlOf('/blank.json'): 'ab12.json',
            urlOf('/gone.json'): 'cd34.json',
            'own.js': 'ef56.js',
          },
        ),
      );

      await action().updateModule((await stored()).single);

      final saved = (await stored()).single;
      expect(saved.resources, {urlOf('/blank.json'): 'ab12.json'});
    },
  );

  test('a new URL is downloaded and replaces the old one', () async {
    serve(['Sample', 'Moved']);
    await action().addFromUrl(urlOf('/sample.sgmodule'));

    final changed = await action().changeUrl(
      (await stored()).single,
      urlOf('/moved.sgmodule'),
    );

    final saved = (await stored()).single;
    expect(saved.url, urlOf('/moved.sgmodule'));
    expect(saved.name, 'Moved');
    expect(changed.url, saved.url);
  });

  test('an update that answers after a newer URL leaves the newer', () async {
    serve(['Sample', 'Moved']);
    await action().addFromUrl(urlOf('/sample.sgmodule'));
    final before = (await stored()).single;
    final slow = Completer<void>();
    holds['/sample.sgmodule'] = slow.future;

    final update = action().updateModule(before);
    await action().changeUrl(before, urlOf('/moved.sgmodule'));
    slow.complete();
    await update;

    final saved = (await stored()).single;
    expect(saved.url, urlOf('/moved.sgmodule'));
    expect(
      await File(
        join(await appPath.mitmModulesDirPath, saved.fileName),
      ).readAsString(),
      bodies['/moved.sgmodule'],
    );
  });

  test(
    'a new URL that fails to download leaves the module as it was',
    () async {
      serve(['Sample']);
      await action().addFromUrl(urlOf('/sample.sgmodule'));
      final before = (await stored()).single;

      await expectLater(
        action().changeUrl(before, urlOf('/missing.sgmodule')),
        throwsA(anything),
      );

      final after = (await stored()).single;
      expect(after.url, before.url);
      expect(after.name, 'Sample');
    },
  );

  test('a page that is not a module is turned down', () async {
    bodies = {'/page': '<html>Not found</html>'};
    reads['<html>Not found</html>'] = (_) => moduleRead(
      ignored: const [
        {'line': 1, 'text': '<html>Not found</html>', 'reason': 'section'},
      ],
    );

    await expectLater(
      action().addFromUrl(urlOf('/page')),
      throwsA(isA<MessageException>()),
    );
    expect(await stored(), isEmpty);
  });

  test(
    'cleaning keeps the module files something names and every other file',
    () async {
      serve(['Sample']);
      final ads = await action().addFromUrl(urlOf('/sample.sgmodule'));
      const ownText = '[Map Local]\n^https://own data="own.gif"\n';
      reads[ownText] = (_) => moduleRead(
        views: {
          'map-local': [
            lineEntry(
              2,
              const MitmLineView.mapLocal(
                pattern: '^https://own',
                dataType: 'file',
                data: 'own.gif',
              ),
            ),
          ],
        },
      );
      final local = await action().create(ownText);
      await action().attach(local, 'own.gif', 'gif'.codeUnits);
      final attachment = mitmAttachments(
        (await stored()).firstWhere((item) => item.id == local.id),
      )['own.gif']!;
      final resources = await appPath.mitmResourcesDirPath;
      await File(join(resources, 'core.json')).writeAsString('{}');
      final modules = await appPath.mitmModulesDirPath;
      await File(join(modules, 'stale.sgmodule')).writeAsString('');

      await action().clean();

      expect(
        await files(appPath.mitmModulesDirPath),
        unorderedEquals([ads.fileName, local.fileName]),
      );
      expect(
        await files(appPath.mitmResourcesDirPath),
        unorderedEquals(['core.json', attachment]),
      );
    },
  );

  test('cleanings that overlap remove each stale file once', () async {
    final modules = await appPath.mitmModulesDirPath;
    await Directory(modules).create(recursive: true);
    for (var index = 0; index < 32; index++) {
      await File(join(modules, 'stale$index.sgmodule')).writeAsString('');
    }

    await Future.wait([action().clean(), action().clean(), action().clean()]);

    expect(await files(appPath.mitmModulesDirPath), isEmpty);
  });

  test(
    'deleting a module removes its attachments, not one another names',
    () async {
      const text = '#!name=Mine\n';
      reads[text] = (_) => moduleRead(meta: const {'name': 'Mine'});
      final mine = await action().create(text);
      final other = await action().create(text);
      await action().attach(mine, 'own.js', 'a'.codeUnits);
      await action().attach(mine, 'shared.js', 'b'.codeUnits);
      await action().attach(other, 'shared.js', 'b'.codeUnits);
      final shared = mitmAttachments(
        (await stored()).firstWhere((item) => item.id == other.id),
      )['shared.js']!;

      await action().deleteModule(
        (await stored()).firstWhere((item) => item.id == mine.id),
      );

      expect(await files(appPath.mitmResourcesDirPath), [shared]);
    },
  );

  test(
    'a module with scripts is added off and keeps the user choice',
    () async {
      bodies = {
        '/sample.sgmodule':
            '''
[Argument]
Extra = switch,false
[Script]
Sample = type=http-response,pattern=^https://a,script-path=${urlOf('/sample.js')}
Extra = type=http-response,pattern=^https://b,script-path=${urlOf('/extra.js')},enable={Extra}
''',
        '/sample.js': r'$done({})',
        '/extra.js': r'$done({})',
      };

      reads[bodies['/sample.sgmodule']!] = (arguments) => moduleRead(
        arguments: const [
          {
            'name': 'Extra',
            'kind': {'type': 'switch'},
            'number': false,
            'default': 'false',
            'line': 2,
          },
        ],
        resources: [
          scriptResource(urlOf('/sample.js'), 4),
          if (arguments['Extra'] == 'true')
            scriptResource(urlOf('/extra.js'), 5),
        ],
        declaredScripts: const [4, 5],
      );

      await action().addFromUrl(urlOf('/sample.sgmodule'));
      final added = (await stored()).single;
      expect(added.enabled, isFalse);
      expect(added.scripts, 2);

      action().putModule(added.copyWith(enabled: true, accepted: true));
      await action().setArguments((await stored()).single, const {
        'Extra': 'true',
      });

      final changed = (await stored()).single;
      expect(changed.enabled, isTrue);
      expect(changed.arguments, {'Extra': 'true'});
      await action().updateModule(changed);
      expect((await stored()).single.enabled, isTrue);
    },
  );

  JsonMap dnsRead(_) => moduleRead(
    asksConsent: true,
    network: const {
      'nameserver': {
        'replace': true,
        'before': ['223.5.5.5'],
        'after': <String>[],
      },
      'lines': [2],
    },
  );

  test('a module that changes network settings is added off', () async {
    bodies = {'/dns.sgmodule': '[General]\ndns-server = 223.5.5.5\n'};
    reads['[General]\ndns-server = 223.5.5.5\n'] = dnsRead;
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
      reads[bodies['/cert.sgmodule']!] = (_) => moduleRead(
        asksConsent: true,
        views: {
          'hostname': [
            lineEntry(
              2,
              const MitmLineView.hosts(
                entries: [MitmHostEntry(host: 'api.example.com')],
              ),
            ),
          ],
          'skip-server-cert-verify-hostname': [
            lineEntry(
              3,
              const MitmLineView.hosts(
                entries: [MitmHostEntry(host: 'api.example.com')],
              ),
            ),
          ],
        },
      );
      reads[bodies['/lan.sgmodule']!] = (_) => moduleRead(
        asksConsent: true,
        views: {
          'client-source-address': [
            lineEntry(
              2,
              const MitmLineView.sources(
                entries: [MitmSourceEntry(network: '192.168.1.0/24')],
              ),
            ),
          ],
        },
      );
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
      '/sample.sgmodule':
          '${module('Sample')}[Script]\n'
          'Sample = type=cron,cronexp="0 * * * *",script-path=${urlOf('/a.js')}\n',
      '/a.js': r'$done({})',
      '/blank.json': '{}',
    };
    reads[bodies['/sample.sgmodule']!] = (_) => withScriptRead(urlOf('/a.js'));
    final added = await action().addFromUrl(urlOf('/sample.sgmodule'));
    expect(added.enabled, isFalse);
    expect(container.read(mitmModulesToAgreeProvider).single.id, added.id);

    action().putModule(added.copyWith(accepted: false));

    expect(container.read(mitmModulesToAgreeProvider), isEmpty);
  });

  test('a restore reads what each module asks from its own file', () async {
    serve(['Sample']);
    final added = await action().addFromUrl(urlOf('/sample.sgmodule'));
    action().putModule(added.copyWith(id: added.id + 1));
    await File(
      join(await appPath.mitmModulesDirPath, added.fileName),
    ).writeAsString('[General]\ndns-server = 223.5.5.5\n');
    reads['[General]\ndns-server = 223.5.5.5\n'] = dnsRead;
    expect(
      [for (final item in await stored()) item.asksConsent],
      [false, false],
    );

    await action().recheckConsent();

    expect([for (final item in await stored()) item.asksConsent], [true, true]);
  });

  test(
    'a restore turns off a module whose own file asks for consent',
    () async {
      serve(['Sample']);
      final added = await action().addFromUrl(urlOf('/sample.sgmodule'));
      expect(added.enabled, isTrue);
      await File(
        join(await appPath.mitmModulesDirPath, added.fileName),
      ).writeAsString('[General]\ndns-server = 223.5.5.5\n');
      reads['[General]\ndns-server = 223.5.5.5\n'] = dnsRead;

      await action().recheckConsent();

      final restored = (await stored()).single;
      expect(restored.enabled, isFalse);
      expect(restored.awaitsConsent, isTrue);
    },
  );

  test('a restore that cannot read a module leaves it on', () async {
    serve(['Sample']);
    final added = await action().addFromUrl(urlOf('/sample.sgmodule'));
    await File(
      join(await appPath.mitmModulesDirPath, added.fileName),
    ).writeAsString('unread\n');

    await action().recheckConsent();

    final restored = (await stored()).single;
    expect(restored.asksConsent, isTrue);
    expect(restored.enabled, isTrue);
  });

  group('an update that brings scripts', () {
    String withScript() =>
        '''
${module('Sample')}[Script]
Sample = type=http-response,pattern=^https://a,script-path=${urlOf('/sample.js')}
''';

    Future<MitmModule> bringScripts() async {
      bodies['/sample.sgmodule'] = withScript();
      reads[withScript()] = (_) => withScriptRead(urlOf('/sample.js'));
      bodies['/sample.js'] = r'$done({})';
      return action().updateModule((await stored()).single);
    }

    Set<int> awaitingConsent() => {
      for (final module in container.read(mitmModulesToAgreeProvider))
        module.id,
    };

    setUp(() async {
      serve(['Sample']);
      await action().addFromUrl(urlOf('/sample.sgmodule'));
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
      bodies['/sample.sgmodule'] = module(
        'Sample',
      ).replaceFirst('example.com', 'example.com, *.example.org');
      reads[bodies['/sample.sgmodule']!] = (_) => moduleReadOf('Sample');

      final updated = await action().updateModule((await stored()).single);

      expect(updated.enabled, isTrue);
      expect(awaitingConsent(), isEmpty);
    });
  });

  test(
    'an edit that brings scripts turns off a module never agreed to',
    () async {
      const rewrite = '[URL Rewrite]\n^https://a - reject\n';
      const script =
          '[Script]\nA = type=cron,cronexp="0 * * * *",script-path=a.js\n';
      reads[rewrite] = (_) => moduleRead(
        views: {
          'url-rewrite': [
            lineEntry(
              2,
              const MitmLineView.urlRewrite(
                pattern: '^https://a',
                action: 'reject',
              ),
            ),
          ],
        },
      );
      reads[script] = (_) => moduleRead(
        declaredScripts: const [2],
        ignored: const [
          {
            'line': 2,
            'text': 'A = type=cron,cronexp="0 * * * *",script-path=a.js',
            'reason': 'noAttachment',
          },
        ],
      );
      final local = await action().create(rewrite);
      action().putModule(local.copyWith(enabled: true));

      final edited = await action().edit((await stored()).single, script);

      expect(edited.enabled, isFalse);
      expect(container.read(mitmModulesToAgreeProvider).single.id, edited.id);
    },
  );

  group('an accepted module', () {
    String scripted(String pattern) =>
        '''
#!name=Sample
[MITM]
hostname = example.com
[Script]
Sample = type=http-response,pattern=$pattern,script-path=${urlOf('/sample.js')}
''';

    setUp(() {
      for (final pattern in ['^https://a', '.*']) {
        reads[scripted(pattern)] = (_) => moduleRead(
          meta: const {'name': 'Sample'},
          resources: [scriptResource(urlOf('/sample.js'), 5)],
          declaredScripts: const [5],
        );
      }
    });

    Future<MitmModule> accepted() async {
      bodies = {
        '/sample.sgmodule': scripted('^https://a'),
        '/sample.js': 'one',
      };
      await action().addFromUrl(urlOf('/sample.sgmodule'));
      action().putModule(
        (await stored()).single.copyWith(enabled: true, accepted: true),
      );
      return (await stored()).single;
    }

    // The sweep a save leaves running must end before the test's directory goes.
    tearDown(() => Future<void>.delayed(const Duration(milliseconds: 50)));

    test('stays on through an update that changes its scripts', () async {
      final ads = await accepted();
      bodies['/sample.sgmodule'] = scripted('.*');
      bodies['/sample.js'] = 'two';

      await action().updateModule(ads);

      expect((await stored()).single.enabled, isTrue);
    });

    test('asks again at a new URL whose content asks', () async {
      final ads = await accepted();
      bodies['/moved.sgmodule'] = scripted('.*');

      await action().changeUrl(ads, urlOf('/moved.sgmodule'));

      final moved = (await stored()).single;
      expect(moved.url, urlOf('/moved.sgmodule'));
      expect(moved.enabled, isFalse);
      expect(moved.awaitsConsent, isTrue);
    });

    test('stays on at a new URL whose content asks nothing', () async {
      final ads = await accepted();
      bodies['/moved.sgmodule'] = module('Moved');
      reads[module('Moved')] = (_) => moduleReadOf('Moved');

      await action().changeUrl(ads, urlOf('/moved.sgmodule'));

      final moved = (await stored()).single;
      expect(moved.name, 'Moved');
      expect(moved.enabled, isTrue);
    });

    test('stays on through an auto update that changes its scripts', () async {
      final ads = await accepted();
      bodies['/sample.js'] = 'two';
      action().putModule(ads.copyWith(lastUpdateTime: DateTime.utc(2000)));
      container.read(patchClashConfigProvider.notifier).value =
          const PatchClashConfig(mitm: Mitm(enable: true), geoAutoUpdate: true);

      await action().autoUpdate();

      final updated = (await stored()).single;
      expect(updated.enabled, isTrue);
      expect(updated.lastUpdateTime.isAfter(DateTime.utc(2000)), isTrue);
    });
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
      reads[bodies['/q.snippet']!] = (arguments) => moduleRead(
        format: 'quantumult-x',
        arguments: const [
          {
            'name': 'Line',
            'kind': {'type': 'text'},
            'number': false,
            'default': '',
            'line': 1,
          },
        ],
        resources: [
          if (arguments['Line'] != null) scriptResource(urlOf('/a.js'), 3),
        ],
        declaredScripts: [if (arguments['Line'] != null) 3],
        views: {
          'url-rewrite': [
            lineEntry(
              4,
              const MitmLineView.urlRewrite(
                pattern: '^https://a',
                action: 'reject',
              ),
            ),
          ],
        },
      );
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
    serve(['Sample']);
    await action().addFromUrl(urlOf('/sample.sgmodule'));
    final added = (await stored()).single;

    final update = action().updateModule(added);
    action().putModule(added.copyWith(enabled: false));
    await update;

    expect((await stored()).single.enabled, isFalse);
  });

  test('a new module goes first and may start empty', () async {
    serve(['Sample']);
    await action().addFromUrl(urlOf('/sample.sgmodule'));

    reads['#!name=Mine\n[URL Rewrite]\n'] = (_) =>
        moduleRead(meta: const {'name': 'Mine'});
    final created = await action().create('#!name=Mine\n[URL Rewrite]\n');

    final modules = await stored();
    expect(modules.map((item) => item.name), ['Mine', 'Sample']);
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
    const withOwn =
        '#!name=Mine\n[Script]\nOwn = type=http-request,pattern=a,script-path=own.js\n';
    reads['#!name=Mine\n'] = (_) => moduleRead(meta: const {'name': 'Mine'});
    reads[withOwn] = (_) =>
        moduleRead(meta: const {'name': 'Mine'}, declaredScripts: const [3]);
    final local = await action().create('#!name=Mine\n');
    await action().attach(local, 'own.js', r'$done()'.codeUnits);

    await action().edit((await stored()).single, withOwn);
    final edited = (await stored()).single;
    expect(mitmAttachments(edited).keys, ['own.js']);
    expect(edited.scripts, 1);

    await action().detach(edited, 'own.js');
    await action().clean();

    expect(mitmAttachments((await stored()).single), isEmpty);
    expect(await files(appPath.mitmResourcesDirPath), isEmpty);
  });

  test('an attachment replaced under its name leaves no old copy', () async {
    reads['#!name=Mine\n'] = (_) => moduleRead(meta: const {'name': 'Mine'});
    final local = await action().create('#!name=Mine\n');
    await action().attach(local, 'own.js', 'one'.codeUnits);

    await action().attach((await stored()).single, 'own.js', 'two'.codeUnits);

    final kept = mitmAttachments((await stored()).single)['own.js'];
    expect(await files(appPath.mitmResourcesDirPath), [kept]);
  });

  test(
    'a captured response mapped locally reads from its attachment',
    () async {
      final line = mitmMapLocalLine(
        'https://a.test/ad.json?id=1',
        file: 'ad.json',
        contentType: 'application/json',
      );
      final text = mitmAddLine('#!name=Mine\n', mitmMapLocalSection, line)!;
      reads[text] = (_) => moduleRead(meta: const {'name': 'Mine'});
      final created = await action().create(text);
      await action().attach(created, 'ad.json', '{"ad":0}'.codeUnits);

      final saved = (await stored()).single;
      final kept = saved.resources['ad.json']!;
      expect(
        await File(
          join(await appPath.mitmModulesDirPath, saved.fileName),
        ).readAsString(),
        contains('data=ad.json'),
      );
      expect(mitmAttachments(saved), {'ad.json': kept});
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
      serve(['Sample']);
      final added = await action().addFromUrl(urlOf('/sample.sgmodule'));
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
      final ads = (await stored()).single;
      verify(() => mocks.api.fetchMitmModule(name: '${ads.id}')).called(1);
    });

    test('a module its update turns off fetches nothing', () async {
      serve(['Sample']);
      final added = await action().addFromUrl(urlOf('/sample.sgmodule'));
      expect(added.enabled, isTrue);
      action().putModule(added.copyWith(lastUpdateTime: DateTime.utc(2000)));
      final withScript =
          '${module('Sample')}[Script]\n'
          'Sample = type=http-response,pattern=^https://a,'
          'script-path=${urlOf('/sample.js')}\n';
      bodies['/sample.sgmodule'] = withScript;
      reads[withScript] = (_) => withScriptRead(urlOf('/sample.js'));
      container
          .read(patchClashConfigProvider.notifier)
          .update(
            (state) => state.copyWith(
              geoAutoUpdate: true,
              geoUpdateInterval: 24,
              mitm: state.mitm.copyWith(enable: true),
            ),
          );

      await action().autoUpdate();

      expect((await stored()).single.enabled, isFalse);
      verifyNever(() => mocks.api.fetchMitmModule(name: any(named: 'name')));
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
      serve(['Sample']);
      final added = await action().addFromUrl(urlOf('/sample.sgmodule'));
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

  group('with the Core unavailable', () {
    const unavailable = CoreMethodException(
      code: 'core_unavailable',
      message: 'Core is not connected',
    );

    void coreDown() => stubModuleReads(mocks.api, (_, _) => throw unavailable);

    test('adding a module fails and leaves nothing behind', () async {
      serve(['Ads']);
      coreDown();

      await expectLater(
        action().addFromUrl(urlOf('/ads.sgmodule')),
        throwsA(unavailable),
      );

      expect(await stored(), isEmpty);
      expect(await files(appPath.mitmModulesDirPath), isEmpty);
    });

    test('editing or updating a module fails and keeps it as it was', () async {
      serve(['Ads']);
      final added = await action().addFromUrl(urlOf('/ads.sgmodule'));
      final before = (await stored()).single;
      final path = join(await appPath.mitmModulesDirPath, added.fileName);
      final text = await File(path).readAsString();
      coreDown();

      await expectLater(
        action().edit(before, '#!name=Edited\n'),
        throwsA(unavailable),
      );
      await expectLater(action().updateModule(before), throwsA(unavailable));

      expect((await stored()).single, before);
      expect(await File(path).readAsString(), text);
    });

    test(
      'an auto update that comes due leaves the module for the next run',
      () async {
        serve(['Ads']);
        final added = await action().addFromUrl(urlOf('/ads.sgmodule'));
        action().putModule(
          added.copyWith(
            enabled: true,
            accepted: true,
            lastUpdateTime: DateTime.now().subtract(const Duration(hours: 25)),
          ),
        );
        final before = (await stored()).single;
        container
            .read(patchClashConfigProvider.notifier)
            .update(
              (state) => state.copyWith(
                geoAutoUpdate: true,
                geoUpdateInterval: 24,
                mitm: state.mitm.copyWith(enable: true),
              ),
            );
        coreDown();

        await action().autoUpdate();

        expect((await stored()).single, before);
        verifyNever(() => mocks.api.fetchMitmModule(name: any(named: 'name')));
      },
    );

    test('the error says the Core is not running', () {
      expect(
        userFacingErrorMessage(unavailable, currentAppLocalizations),
        currentAppLocalizations.coreUnavailableTip,
      );
    });
  });

  test('deleting a module removes its content', () async {
    serve(['Sample']);
    await action().addFromUrl(urlOf('/sample.sgmodule'));

    await action().deleteModule((await stored()).single);

    expect(await stored(), isEmpty);
    expect(await files(appPath.mitmModulesDirPath), isEmpty);
    expect(await files(appPath.mitmResourcesDirPath), isEmpty);
  });
}
