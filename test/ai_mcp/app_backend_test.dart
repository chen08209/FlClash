import 'dart:convert';

import 'package:fl_clash/ai_mcp/backend.dart';
import 'package:fl_clash/core/controller.dart';
import 'package:fl_clash/core/interface.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/ai_mcp.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:riverpod/riverpod.dart';

import '../helpers/test_profiles.dart';

class _Core extends Mock implements CoreHandlerInterface {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late _Core core;
  late ProviderContainer container;
  late AppAiMcpBackend backend;
  var selected = 'one';

  setUpAll(() {
    registerFallbackValue(
      const ChangeProxyParams(groupName: 'group', proxyName: 'one'),
    );
  });

  setUp(() {
    core = _Core();
    selected = 'one';
    final backendProvider = Provider((ref) => AppAiMcpBackend(ref));
    container = ProviderContainer(
      overrides: [
        coreHandlerProvider.overrideWithValue(CoreController.scoped(core)),
        profilesProvider.overrideWith(
          () => TestProfiles([
            const Profile(
              id: 1,
              autoUpdateDuration: Duration.zero,
              selectedMap: {'group': 'one'},
            ),
          ]),
        ),
        currentProfileIdProvider.overrideWithBuild((_, _) => 1),
        appSettingProvider.overrideWithBuild(
          (_, _) => const AppSettingProps(testUrl: 'https://configured.test'),
        ),
      ],
    );
    backend = container.read(backendProvider);
    container.read(coreStatusProvider.notifier).value = CoreStatus.connected;
    container.read(appSettingProvider.notifier).value = const AppSettingProps(
      testUrl: 'https://configured.test',
    );
    when(core.getProxies).thenAnswer(
      (_) async => ProxiesData(
        all: const ['group', 'hidden'],
        proxies: {
          'group': {
            'name': 'group',
            'type': 'Selector',
            'all': ['one', 'two'],
            'now': selected,
            'url': 'https://subscription-secret',
          },
          'hidden': {
            'name': 'hidden',
            'type': 'Selector',
            'hidden': true,
            'all': ['secret-node'],
          },
          'one': {
            'name': 'one',
            'type': 'ss',
            'server': 'private-destination',
            'password': 'secret',
          },
          'two': {'name': 'two', 'type': 'ss'},
          'secret-node': {'name': 'secret-node', 'type': 'ss'},
        },
      ),
    );
    when(() => core.changeProxy(any())).thenAnswer((invocation) async {
      selected = (invocation.positionalArguments.single as ChangeProxyParams)
          .proxyName;
      return '';
    });
    when(core.resetConnections).thenAnswer((_) async => true);
    when(core.closeConnections).thenAnswer((_) async => true);
  });

  tearDown(() => container.dispose());

  Future<Map<String, Object?>> execute(
    String name, [
    Map<String, dynamic> args = const {},
    void Function()? check,
  ]) => backend.execute(name, args, check ?? () {});

  test(
    'status and bounded proxy listing expose only explicit safe fields',
    () async {
      expect(
        (await execute('app_status')).keys,
        unorderedEquals(['app', 'core', 'running', 'configuredMode']),
      );
      final data = await execute('list_proxies', {'limit': 1});
      expect((data['items'] as List).length, 1);
      expect(data['nextOffset'], 1);
      final json = jsonEncode(data);
      for (final secret in [
        'subscription-secret',
        'private-destination',
        'password',
        'secret-node',
        'https://',
      ]) {
        expect(json, isNot(contains(secret)));
      }
    },
  );

  test(
    'selects real member, confirms core and updates app-managed persisted selection',
    () async {
      expect(await execute('select_proxy', {'group': 'group', 'node': 'two'}), {
        'group': 'group',
        'selected': 'two',
        'persistence': 'app_managed',
      });
      expect(
        container.read(currentProfileProvider)!.selectedMap['group'],
        'two',
      );
    },
  );

  test(
    'core throws or returns an error: no success, selected state rolled back',
    () async {
      for (final throws in [false, true]) {
        when(() => core.changeProxy(any())).thenAnswer((_) async {
          if (throws) throw StateError('private secret');
          return 'core refused';
        });
        await expectLater(
          execute('select_proxy', {'group': 'group', 'node': 'two'}),
          throwsA(isA<AiMcpFailure>()),
        );
        expect(
          container.read(currentProfileProvider)!.selectedMap['group'],
          'one',
        );
      }
    },
  );

  test('core selection mismatch never reports success', () async {
    when(() => core.changeProxy(any())).thenAnswer((_) async => '');
    await expectLater(
      execute('select_proxy', {'group': 'group', 'node': 'two'}),
      throwsA(isA<AiMcpFailure>()),
    );
  });

  test(
    'invalid inputs cannot request URLs, hidden nodes or unknown members',
    () async {
      for (final args in [
        {
          'nodes': ['one'],
          'url': 'https://arbitrary.test',
        },
        {
          'nodes': ['secret-node'],
        },
        {
          'nodes': ['unknown'],
        },
        {
          'nodes': ['one', 'one'],
        },
      ]) {
        await expectLater(
          execute('test_delays', args),
          throwsA(isA<AiMcpFailure>()),
        );
      }
      await expectLater(
        execute('select_proxy', {'group': 'group', 'node': 'unknown'}),
        throwsA(isA<AiMcpFailure>()),
      );
      verifyNever(() => core.changeProxy(any()));
    },
  );

  test(
    'delay tests use configured URL and update cache without leaking URL',
    () async {
      var concurrent = 0;
      var maximum = 0;
      when(() => core.asyncTestDelay(any(), any())).thenAnswer((
        invocation,
      ) async {
        concurrent++;
        if (concurrent > maximum) maximum = concurrent;
        await Future<void>.delayed(Duration.zero);
        concurrent--;
        expect(invocation.positionalArguments.first, 'https://configured.test');
        return Delay(
          name: invocation.positionalArguments[1] as String,
          url: 'https://configured.test',
          value: 42,
        );
      });
      final response = await execute('test_delays', {
        'nodes': ['one', 'two'],
      });
      expect(maximum, 2);
      expect(jsonEncode(response), isNot(contains('https://')));
      expect(
        container.read(
          delayDataSourceProvider,
        )['https://configured.test']!['one'],
        42,
      );
      when(
        () => core.asyncTestDelay(any(), any()),
      ).thenAnswer((_) async => null);
      await expectLater(
        execute('test_delays', {
          'nodes': ['one'],
        }),
        throwsA(isA<AiMcpFailure>()),
      );
    },
  );

  test(
    'rechecks authorization after asynchronous group lookup before mutation',
    () async {
      var checks = 0;
      await expectLater(
        execute('select_proxy', {'group': 'group', 'node': 'two'}, () {
          if (++checks > 1) throw const AiMcpFailure('permission_denied');
        }),
        throwsA(isA<AiMcpFailure>()),
      );
      verifyNever(() => core.changeProxy(any()));
    },
  );

  test(
    'false close result is failure and mode only acknowledges configured intent',
    () async {
      when(core.closeConnections).thenAnswer((_) async => false);
      await expectLater(
        execute('close_connections'),
        throwsA(isA<AiMcpFailure>()),
      );
      when(core.closeConnections).thenAnswer((_) async => true);
      expect(await execute('close_connections'), {'closed': true});
      expect(await execute('set_mode', {'mode': 'direct'}), {
        'configuredMode': 'direct',
        'coreApplication': 'requested',
      });
      expect(container.read(patchClashConfigProvider).mode, Mode.direct);
      await expectLater(
        execute('set_mode', {'mode': 'script'}),
        throwsA(isA<AiMcpFailure>()),
      );
    },
  );
}
