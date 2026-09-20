import 'dart:async';
import 'dart:convert';

import 'package:fl_clash/ai_mcp/backend.dart';
import 'package:fl_clash/ai_mcp/service.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/core/controller.dart';
import 'package:fl_clash/core/interface.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/ai_mcp.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:riverpod/riverpod.dart';

import '../helpers/test_profiles.dart';
import 'helpers.dart';

class _Core extends Mock implements CoreHandlerInterface {}

const _names = ['one', 'two', 'three', 'four'];
const _url = 'https://configured.test';

void main() {
  late _Core core;
  late ProviderContainer container;
  late AppAiMcpBackend backend;
  var selected = 'one';
  ProxiesData snapshot() => ProxiesData(
    all: const ['group', 'other'],
    proxies: {
      for (final group in ['group', 'other'])
        group: {
          'name': group,
          'type': 'Selector',
          'now': selected,
          'all': _names,
        },
      for (final name in _names) name: {'name': name, 'type': 'ss'},
    },
  );
  setUpAll(
    () => registerFallbackValue(
      const ChangeProxyParams(groupName: 'group', proxyName: 'one'),
    ),
  );
  setUp(() {
    core = _Core();
    selected = 'one';
    container = ProviderContainer(
      overrides: [
        coreHandlerProvider.overrideWithValue(CoreController.scoped(core)),
        profilesProvider.overrideWith(
          () => TestProfiles([
            for (final id in [1, 2])
              Profile(
                id: id,
                autoUpdateDuration: Duration.zero,
                selectedMap: const {'group': 'one', 'other': 'one'},
              ),
          ]),
        ),
        currentProfileIdProvider.overrideWithBuild((_, _) => 1),
        appSettingProvider.overrideWithBuild(
          (_, _) => const AppSettingProps(testUrl: _url),
        ),
      ],
    );
    container.read(coreStatusProvider.notifier).value = CoreStatus.connected;
    backend = container.read(Provider((ref) => AppAiMcpBackend(ref)));
    when(core.getProxies).thenAnswer((_) async => snapshot());
    when(() => core.changeProxy(any())).thenAnswer((call) async {
      selected =
          (call.positionalArguments.single as ChangeProxyParams).proxyName;
      return '';
    });
    when(core.resetConnections).thenAnswer((_) async => true);
  });
  tearDown(() {
    for (final group in ['group', 'other']) {
      debouncer.cancel((FunctionTag.changeProxy, group));
    }
    debouncer.cancel(FunctionTag.updateGroups);
    container.dispose();
  });

  for (final stored in [null, 'stale']) {
    test(
      'MCP rejection restores core default when stored selection is $stored',
      () async {
        container
            .read(profilesProvider.notifier)
            .put(
              Profile(
                id: 1,
                autoUpdateDuration: Duration.zero,
                selectedMap: {'group': ?stored},
              ),
            );
        when(() => core.changeProxy(any())).thenAnswer((_) async => 'rejected');
        await expectLater(
          backend.execute('select_proxy', {
            'group': 'group',
            'node': 'two',
          }, () {}),
          throwsA(isA<AiMcpFailure>()),
        );
        expect(
          container.read(currentProfileProvider)!.selectedMap['group'],
          'one',
        );
      },
    );
  }

  test(
    'manual rejection without a known baseline restores absence rather than an empty node',
    () async {
      container
          .read(profilesProvider.notifier)
          .put(const Profile(id: 1, autoUpdateDuration: Duration.zero));
      when(() => core.changeProxy(any())).thenAnswer((_) async => 'rejected');
      expect(
        await container
            .read(proxiesActionProvider.notifier)
            .changeProxy(
              groupName: 'group',
              proxyName: 'two',
              notifyFailure: false,
            ),
        false,
      );
      expect(
        container
            .read(currentProfileProvider)!
            .selectedMap
            .containsKey('group'),
        false,
      );
    },
  );

  for (final transition in [
    'none',
    'other group',
    'manual',
    'profile ABA',
    'core reconnect',
  ]) {
    test(
      'selection preflight respects $transition before acquiring effect ownership',
      () async {
        final lookup = Completer<ProxiesData>();
        final entered = Completer<void>();
        var reads = 0;
        when(core.getProxies).thenAnswer((_) {
          if (++reads == 1) {
            entered.complete();
            return lookup.future;
          }
          return Future.value(snapshot());
        });
        final pending = backend.execute('select_proxy', {
          'group': 'group',
          'node': 'two',
        }, () {});
        final valid = transition == 'none' || transition == 'other group';
        final checked = valid
            ? expectLater(pending, completion(containsPair('selected', 'two')))
            : expectLater(pending, throwsA(isA<AiMcpFailure>()));
        await entered.future;
        final action = container.read(proxiesActionProvider.notifier);
        switch (transition) {
          case 'manual':
            action.changeProxyDebounce('group', 'three');
          case 'other group':
            action.changeProxyDebounce('other', 'three');
          case 'profile ABA':
            container.read(currentProfileIdProvider.notifier).value = 2;
            container.read(currentProfileIdProvider.notifier).value = 1;
          case 'core reconnect':
            container.read(coreStatusProvider.notifier).value =
                CoreStatus.disconnected;
            container.read(coreStatusProvider.notifier).value =
                CoreStatus.connected;
        }
        lookup.complete(snapshot());
        await checked;
        if (valid) {
          verify(() => core.changeProxy(any())).called(1);
        } else {
          verifyNever(() => core.changeProxy(any()));
        }
        if (transition == 'manual') {
          expect(
            container.read(currentProfileProvider)!.selectedMap['group'],
            'three',
          );
          await Future<void>.delayed(const Duration(milliseconds: 650));
          expect(selected, 'three');
        }
      },
    );
  }

  for (final delete in [false, true]) {
    for (final tool in ['select_proxy', 'test_delays']) {
      test(
        'HTTP ${delete ? 'DELETE' : 'cancel'} stops real $tool continuation and retains global slot',
        () async {
          final service = AiMcpService(
            store: MemoryAiMcpStore(),
            backend: backend,
          );
          await service.initialize();
          await service.setPort(await availableMcpPort());
          await service.setEnabled(true);
          final peer = McpHttpPeer(service);
          final control = McpHttpPeer(service);
          final other = McpHttpPeer(service);
          final entered = Completer<void>();
          final lookup = Completer<ProxiesData>();
          final probes = <Completer<Delay?>>[];
          if (tool == 'select_proxy') {
            when(core.getProxies).thenAnswer((_) {
              entered.complete();
              return lookup.future;
            });
          } else {
            when(() => core.asyncTestDelay(any(), any())).thenAnswer((_) {
              final reply = Completer<Delay?>();
              probes.add(reply);
              if (probes.length == 2) entered.complete();
              return reply.future;
            });
          }
          try {
            await peer.initialize();
            await other.initialize();
            control.session = peer.session;
            final pending = peer.call(
              tool,
              tool == 'select_proxy'
                  ? {'group': 'group', 'node': 'two'}
                  : {'nodes': _names},
            );
            final settled = pending.then<void>((_) {}, onError: (Object _) {});
            await entered.future;
            expect(
              (await control.send(method: 'DELETE', omitAuth: true)).status,
              401,
            );
            expect(
              (await control.send(method: 'DELETE', raw: 'body')).status,
              400,
            );
            expect(
              (await control.send(
                method: 'DELETE',
                raw: 'x' * (AiMcpService.maxBodyBytes + 1),
              )).status,
              413,
            );
            expect(
              (await control.send(
                raw: 'x' * (AiMcpService.maxBodyBytes + 1),
              )).status,
              413,
            );
            expect(
              (await control.send(
                message: {
                  'jsonrpc': '2.0',
                  'method': 'notifications/cancelled',
                  'params': {'requestId': 2},
                },
                origin: 'null',
              )).status,
              403,
            );
            expect(
              (await control.send(
                message: {
                  'jsonrpc': '2.0',
                  'method': 'notifications/cancelled',
                  'params': {'requestId': 2},
                },
                authorization: 'Bearer wrong',
              )).status,
              401,
            );
            expect((await control.call('app_status')).status, 429);
            final response = delete
                ? await control.send(method: 'DELETE')
                : await control.send(
                    message: {
                      'jsonrpc': '2.0',
                      'method': 'notifications/cancelled',
                      'params': {'requestId': 2},
                    },
                  );
            expect(response.status, delete ? 200 : 202);
            expect(
              jsonEncode((await other.call('app_status')).body),
              contains('busy'),
            );
            if (tool == 'select_proxy') {
              lookup.complete(snapshot());
            } else {
              probes[0].complete(
                const Delay(name: 'one', url: _url, value: 10),
              );
              await Future<void>.delayed(const Duration(milliseconds: 30));
              expect(
                jsonEncode((await other.call('app_status')).body),
                contains('busy'),
              );
              probes[1].complete(
                const Delay(name: 'two', url: _url, value: 10),
              );
            }
            await Future<void>.delayed(const Duration(milliseconds: 30));
            verifyNever(() => core.changeProxy(any()));
            expect(probes.length, tool == 'test_delays' ? 2 : 0);
            expect(container.read(delayDataSourceProvider), isEmpty);
            expect(
              (await other.call('app_status')).body!['result']['isError'],
              isNot(true),
            );
            if (!delete) {
              expect((await control.send(method: 'DELETE')).status, 200);
            }
            await settled;
          } finally {
            if (!lookup.isCompleted) lookup.complete(snapshot());
            for (final probe in probes) {
              if (!probe.isCompleted) probe.complete(null);
            }
            peer.close();
            control.close();
            other.close();
            await service.setEnabled(false);
            service.dispose();
          }
        },
      );
    }
  }

  for (final reverse in [false, true]) {
    for (final firstSuccess in [false, true]) {
      for (final secondSuccess in [false, true]) {
        test(
          'overlapping selection reconciles confirmed baseline reverse=$reverse first=$firstSuccess second=$secondSuccess',
          () async {
            final replies = [Completer<String>(), Completer<String>()];
            final entered = [Completer<void>(), Completer<void>()];
            var count = 0;
            when(() => core.changeProxy(any())).thenAnswer((_) {
              final index = count++;
              entered[index].complete();
              return replies[index].future;
            });
            final action = container.read(proxiesActionProvider.notifier);
            final first = action.changeProxy(
              groupName: 'group',
              proxyName: 'two',
              notifyFailure: false,
              maintainConnections: false,
            );
            await entered[0].future;
            final second = action.changeProxy(
              groupName: 'group',
              proxyName: 'three',
              notifyFailure: false,
              maintainConnections: false,
            );
            await entered[1].future;
            final futures = [first, second];
            for (final index in reverse ? [1, 0] : [0, 1]) {
              replies[index].complete(
                (index == 0 ? firstSuccess : secondSuccess) ? '' : 'rejected',
              );
              await futures[index];
            }
            expect(
              container.read(currentProfileProvider)!.selectedMap['group'],
              secondSuccess
                  ? 'three'
                  : firstSuccess
                  ? 'two'
                  : 'one',
            );
          },
        );
      }
    }
  }
}
