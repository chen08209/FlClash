import 'dart:async';
import 'dart:io';

import 'package:fl_clash/ai_mcp/backend.dart';
import 'package:fl_clash/ai_mcp/service.dart';
import 'package:fl_clash/common/common.dart';
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
import 'helpers.dart';

class _LoopbackHttpOverrides extends HttpOverrides {}

class _Core extends Mock implements CoreHandlerInterface {}

class _Setup extends SetupAction {
  @override
  Future<bool> applyProfile({
    bool silence = false,
    bool force = false,
    Future<void> Function()? preloadInvoke,
  }) async => true;
}

const _url = 'https://configured.test';
const _names = ['one', 'two', 'three', 'four'];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late ProviderContainer container;
  late _Core core;
  late AppAiMcpBackend backend;
  var selected = 'one';

  ProxiesData proxies() => ProxiesData(
    all: const ['group'],
    proxies: {
      'group': {
        'name': 'group',
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
            const Profile(
              id: 1,
              autoUpdateDuration: Duration.zero,
              selectedMap: {'group': 'one'},
            ),
            const Profile(
              id: 2,
              autoUpdateDuration: Duration.zero,
              selectedMap: {'group': 'three'},
            ),
          ]),
        ),
        currentProfileIdProvider.overrideWithBuild((_, _) => 1),
        appSettingProvider.overrideWithBuild(
          (_, _) => const AppSettingProps(testUrl: _url),
        ),
        setupActionProvider.overrideWith(_Setup.new),
      ],
    );
    backend = container.read(Provider((ref) => AppAiMcpBackend(ref)));
    container.read(coreStatusProvider.notifier).value = CoreStatus.connected;
    when(core.getProxies).thenAnswer((_) async => proxies());
    when(() => core.changeProxy(any())).thenAnswer((call) async {
      selected =
          (call.positionalArguments.single as ChangeProxyParams).proxyName;
      return '';
    });
    when(core.closeConnections).thenAnswer((_) async => true);
    when(core.resetConnections).thenAnswer((_) async => true);
  });
  tearDown(() {
    debouncer.cancel((FunctionTag.changeProxy, 'group'));
    container.dispose();
  });

  Future<Map<String, Object?>> select(String node, [void Function()? check]) =>
      backend.execute('select_proxy', {
        'group': 'group',
        'node': node,
      }, check ?? () {});
  String? selection(int id) => container
      .read(profilesProvider)
      .firstWhere((p) => p.id == id)
      .selectedMap['group'];

  for (final close in [true, false]) {
    test(
      'basic select has no connection maintenance, changed or unchanged, close=$close',
      () async {
        container.listen(appSettingProvider, (_, _) {});
        container.read(appSettingProvider.notifier).value = AppSettingProps(
          testUrl: _url,
          closeConnections: close,
        );
        await select('one');
        await select('two');
        verifyNever(core.closeConnections);
        verifyNever(core.resetConnections);
        expect(selection(1), 'two');
      },
    );
  }

  for (final fail in [true, false]) {
    test(
      'revoked pending selection has no later RPC or state mutation, fail=$fail',
      () async {
        final entered = Completer<void>();
        final reply = Completer<String>();
        when(() => core.changeProxy(any())).thenAnswer((_) {
          entered.complete();
          return reply.future;
        });
        var valid = true;
        final pending = select('two', () {
          if (!valid) throw const AiMcpFailure('permission_denied');
        });
        final rejected = expectLater(pending, throwsA(isA<AiMcpFailure>()));
        await entered.future;
        final before = container.read(profilesProvider);
        final ipBefore = container.read(checkIpNumProvider);
        valid = false;
        reply.complete(fail ? 'refused' : '');
        await rejected;
        expect(container.read(profilesProvider), same(before));
        expect(container.read(checkIpNumProvider), ipBefore);
        verifyNever(core.closeConnections);
        verifyNever(core.resetConnections);
      },
    );
  }

  test('failed switch cannot roll back into another current profile', () async {
    final entered = Completer<void>();
    final reply = Completer<String>();
    when(() => core.changeProxy(any())).thenAnswer((_) {
      entered.complete();
      return reply.future;
    });
    final pending = select('two');
    final rejected = expectLater(pending, throwsA(isA<AiMcpFailure>()));
    await entered.future;
    container.read(currentProfileIdProvider.notifier).value = 2;
    final before = container.read(profilesProvider);
    reply.complete('refused');
    await rejected;
    expect(selection(2), 'three');
    expect(container.read(profilesProvider), same(before));
    verifyNever(core.closeConnections);
    verifyNever(core.resetConnections);
  });

  test(
    'old failed operation cannot undo newer same-profile ABA selection',
    () async {
      final entered = Completer<void>();
      final oldReply = Completer<String>();
      var calls = 0;
      when(() => core.changeProxy(any())).thenAnswer((call) async {
        if (++calls == 1) {
          entered.complete();
          return oldReply.future;
        }
        selected =
            (call.positionalArguments.single as ChangeProxyParams).proxyName;
        return '';
      });
      final old = select('two');
      final rejected = expectLater(old, throwsA(isA<AiMcpFailure>()));
      await entered.future;
      await select('three');
      await select('two');
      oldReply.complete('old refused');
      await rejected;
      expect(selection(1), 'two');
    },
  );

  test(
    'new debounced UI selection owns rollback before its RPC starts',
    () async {
      final entered = Completer<void>();
      final reply = Completer<String>();
      when(() => core.changeProxy(any())).thenAnswer((_) {
        entered.complete();
        return reply.future;
      });
      final old = select('two');
      final rejected = expectLater(old, throwsA(isA<AiMcpFailure>()));
      await entered.future;
      final action = container.read(proxiesActionProvider.notifier);
      action.changeProxyDebounce('group', 'three');
      action.changeProxyDebounce('group', 'two');
      reply.complete('refused');
      await rejected;
      expect(selection(1), 'two');
    },
  );

  test(
    'external profile-selection ABA cannot be rolled back by old operation',
    () async {
      final entered = Completer<void>();
      final reply = Completer<String>();
      when(() => core.changeProxy(any())).thenAnswer((_) {
        entered.complete();
        return reply.future;
      });
      final old = select('two');
      final rejected = expectLater(old, throwsA(isA<AiMcpFailure>()));
      await entered.future;
      final profiles = container.read(profilesActionProvider.notifier);
      profiles.updateCurrentSelectedMap('group', 'three');
      profiles.updateCurrentSelectedMap('group', 'two');
      reply.complete('refused');
      await rejected;
      expect(selection(1), 'two');
    },
  );

  test(
    'locked HTTP client selects without closing or resetting connections',
    () async {
      final service = AiMcpService(store: MemoryAiMcpStore(), backend: backend);
      final peer = HttpOverrides.runWithHttpOverrides(
        () => McpHttpPeer(service),
        _LoopbackHttpOverrides(),
      );
      try {
        await service.initialize();
        await service.setPort(await availableMcpPort());
        await service.setEnabled(true);
        await peer.initialize();
        expect(service.advanced, false);
        for (final node in ['one', 'two']) {
          final response = await peer.call('select_proxy', {
            'group': 'group',
            'node': node,
          });
          expect(response.body!['result']['isError'], isNot(true));
        }
        verifyNever(core.closeConnections);
        verifyNever(core.resetConnections);
      } finally {
        peer.close();
        await service.setEnabled(false);
        service.dispose();
      }
    },
  );

  test(
    'profile ABA invalidates pending selection even when initiating profile is current again',
    () async {
      final entered = Completer<void>();
      final reply = Completer<String>();
      when(() => core.changeProxy(any())).thenAnswer((_) {
        entered.complete();
        return reply.future;
      });
      final old = select('two');
      final rejected = expectLater(old, throwsA(isA<AiMcpFailure>()));
      await entered.future;
      container.read(currentProfileIdProvider.notifier).value = 2;
      container.read(currentProfileIdProvider.notifier).value = 1;
      final before = container.read(profilesProvider);
      reply.complete('refused');
      await rejected;
      expect(container.read(profilesProvider), same(before));
      expect(selection(2), 'three');
    },
  );

  test('newest failed selection still rolls back its own value', () async {
    final firstEntered = Completer<void>();
    final firstReply = Completer<String>();
    var calls = 0;
    when(() => core.changeProxy(any())).thenAnswer((_) {
      if (++calls == 1) {
        firstEntered.complete();
        return firstReply.future;
      }
      return Future.value('new refused');
    });
    final old = select('two');
    final rejected = expectLater(old, throwsA(isA<AiMcpFailure>()));
    await firstEntered.future;
    await expectLater(select('three'), throwsA(isA<AiMcpFailure>()));
    expect(selection(1), 'two');
    firstReply.complete('old refused');
    await rejected;
    expect(selection(1), 'two');
  });

  test(
    'uncancelled four-node delay run keeps two-probe concurrency and configured URL',
    () async {
      var concurrent = 0;
      var maximum = 0;
      final probes = <String>[];
      when(() => core.asyncTestDelay(any(), any())).thenAnswer((call) async {
        expect(call.positionalArguments.first, _url);
        final node = call.positionalArguments[1] as String;
        probes.add(node);
        concurrent++;
        if (concurrent > maximum) maximum = concurrent;
        await Future<void>.delayed(Duration.zero);
        concurrent--;
        return Delay(name: node, url: _url, value: 10);
      });
      final response = await backend.execute('test_delays', {
        'nodes': _names,
      }, () {});
      expect(response['results'], hasLength(4));
      expect(maximum, 2);
      expect(probes, _names);
      expect(container.read(delayDataSourceProvider)[_url], hasLength(4));
    },
  );

  test(
    'superseded debounced rollback cannot leak into a later selection',
    () async {
      final action = container.read(proxiesActionProvider.notifier);
      action.changeProxyDebounce('group', 'two');
      container
          .read(profilesActionProvider.notifier)
          .updateCurrentSelectedMap('group', 'three');
      when(() => core.changeProxy(any())).thenAnswer((_) async => 'refused');
      await expectLater(select('four'), throwsA(isA<AiMcpFailure>()));
      expect(selection(1), 'three');
    },
  );

  Future<void> invalidate(String transition) async {
    switch (transition) {
      case 'profile ABA':
        container.read(currentProfileIdProvider.notifier).value = 2;
        container.read(currentProfileIdProvider.notifier).value = 1;
      case 'core reconnect':
        container.read(coreStatusProvider.notifier).value =
            CoreStatus.disconnected;
        container.read(coreStatusProvider.notifier).value =
            CoreStatus.connected;
      case 'fullSetup':
        container.read(initProvider.notifier).value = true;
        await container.read(setupActionProvider.notifier).fullSetup();
      case 'cancelDelayTests':
        container.read(proxiesActionProvider.notifier).cancelDelayTests();
    }
    container.read(delayDataSourceProvider.notifier).value = {};
  }

  for (final transition in [
    'profile ABA',
    'core reconnect',
    'fullSetup',
    'cancelDelayTests',
  ]) {
    test(
      'MCP delay first batch is cancelled by $transition, no cache writes/queued probes',
      () async {
        final replies = <Completer<Delay?>>[];
        final entered = Completer<void>();
        when(() => core.asyncTestDelay(any(), any())).thenAnswer((call) {
          final reply = Completer<Delay?>();
          replies.add(reply);
          if (replies.length == 2) entered.complete();
          if (replies.length > 2) {
            reply.complete(
              Delay(
                name: call.positionalArguments[1] as String,
                url: _url,
                value: 1,
              ),
            );
          }
          return reply.future;
        });
        final pending = backend.execute('test_delays', {
          'nodes': _names,
        }, () {});
        final rejected = expectLater(pending, throwsA(isA<AiMcpFailure>()));
        await entered.future;
        await invalidate(transition);
        replies[0].complete(const Delay(name: 'one', url: _url, value: 10));
        replies[1].complete(const Delay(name: 'two', url: _url, value: 20));
        await rejected;
        expect(replies, hasLength(2));
        expect(container.read(delayDataSourceProvider), isEmpty);
      },
    );

    test(
      'MCP delay cancellation during group lookup stops every probe: $transition',
      () async {
        final entered = Completer<void>();
        final groups = Completer<ProxiesData>();
        when(core.getProxies).thenAnswer((_) {
          entered.complete();
          return groups.future;
        });
        when(() => core.asyncTestDelay(any(), any())).thenAnswer(
          (call) async => Delay(
            name: call.positionalArguments[1] as String,
            url: _url,
            value: 10,
          ),
        );
        final pending = backend.execute('test_delays', {
          'nodes': _names,
        }, () {});
        final rejected = expectLater(pending, throwsA(isA<AiMcpFailure>()));
        await entered.future;
        await invalidate(transition);
        groups.complete(proxies());
        await rejected;
        verifyNever(() => core.asyncTestDelay(any(), any()));
        expect(container.read(delayDataSourceProvider), isEmpty);
      },
    );
  }
}
