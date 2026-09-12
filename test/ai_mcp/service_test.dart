import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:fl_clash/ai_mcp/service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mcp_dart/mcp_dart.dart';

import 'helpers.dart';

void main() {
  late MemoryAiMcpStore store;
  late FakeAiMcpBackend backend;
  late AiMcpService service;
  late McpHttpPeer peer;

  setUp(() async {
    store = MemoryAiMcpStore();
    backend = FakeAiMcpBackend();
    service = AiMcpService(store: store, backend: backend);
    await service.initialize();
    await service.setPort(await availableMcpPort());
    await service.setEnabled(true);
    peer = McpHttpPeer(service);
  });

  tearDown(() async {
    peer.close();
    await service.setEnabled(false);
    service.dispose();
  });

  test(
    'stable initialize, list and call use JSON with authenticated sessions',
    () async {
      await peer.initialize();
      expect(peer.session, isNotNull);
      final listed = await peer.rpc('tools/list');
      expect(listed.status, 200);
      final names = (listed.body!['result']['tools'] as List).map(
        (tool) => tool['name'],
      );
      expect(
        names,
        containsAll([
          'app_status',
          'list_proxies',
          'select_proxy',
          'test_delays',
        ]),
      );
      expect(names, isNot(contains('set_mode')));
      final response = await peer.call('app_status');
      expect(response.body!['result']['isError'], isNot(true));
      expect(backend.calls, ['app_status']);
    },
  );

  test(
    'every method including OPTIONS rejects missing and wrong auth',
    () async {
      await peer.initialize();
      for (final method in ['POST', 'GET', 'DELETE', 'OPTIONS']) {
        expect((await peer.send(method: method, omitAuth: true)).status, 401);
        expect(
          (await peer.send(
            method: method,
            authorization: 'Bearer wrong',
          )).status,
          401,
        );
      }
      expect(backend.calls, isEmpty);
    },
  );

  test('rejects hostile Host and all browser Origin headers', () async {
    for (final host in [
      'evil.test',
      'localhost:${service.port}',
      '127.0.0.1.evil.test',
    ]) {
      expect((await peer.send(host: host)).status, 403);
    }
    for (final origin in [
      'http://127.0.0.1:${service.port}',
      'null',
      'https://evil.test',
      '',
    ]) {
      expect((await peer.send(origin: origin)).status, 403);
    }
  });

  test(
    'relock takes effect on already connected clients and stale calls',
    () async {
      await peer.initialize();
      service.unlock();
      expect(
        (await peer.call('close_connections')).body!['result']['isError'],
        isNot(true),
      );
      final pending = Completer<void>();
      final entered = Completer<void>();
      backend.beforeExecute = () {
        entered.complete();
        return pending.future;
      };
      final call = peer.call('set_mode', {'mode': 'direct'});
      await entered.future;
      service.lock();
      pending.complete();
      expect((await call).body!['result']['isError'], true);
      expect(backend.calls, ['close_connections']);
      final locked = await peer.call('close_connections');
      expect(
        locked.body!['result']?['isError'] == true ||
            locked.body!.containsKey('error'),
        true,
      );
      final listed = await peer.rpc('tools/list');
      expect(
        (listed.body!['result']['tools'] as List).any(
          (tool) => tool['name'] == 'set_mode',
        ),
        false,
      );
    },
  );

  test(
    'unknown tools, invalid inputs and actual failures are not success or raw details',
    () async {
      await peer.initialize();
      for (final request in [
        () => peer.call('unknown'),
        () => peer.call('app_status', {'url': 'https://private.test'}),
        () =>
            peer.call('test_delays', {'nodes': List.generate(9, (i) => '$i')}),
        () => peer.call('select_proxy', {'group': 'g'}),
      ]) {
        final response = await request();
        expect(
          response.body!['result']?['isError'] == true ||
              response.body!.containsKey('error'),
          true,
        );
      }
      backend.fail = true;
      final failed = await peer.call('app_status');
      expect(failed.body!['result']['isError'], true);
      expect(jsonEncode(failed.body), contains('backend_failure'));
      expect(jsonEncode(failed.body), isNot(contains('private')));
    },
  );

  test('body and sessions are bounded; DELETE releases a slot', () async {
    expect(
      (await peer.send(raw: 'x' * (AiMcpService.maxBodyBytes + 1))).status,
      413,
    );
    expect((await peer.send(raw: '[]')).status, 400);
    final peers = List.generate(
      AiMcpService.maxSessions,
      (_) => McpHttpPeer(service),
    );
    addTearDown(() {
      for (final p in peers) {
        p.close();
      }
    });
    for (final p in peers) {
      await p.initialize();
    }
    expect((await peer.rpc('initialize')).status, 429);
    expect((await peers.first.send(method: 'DELETE')).status, 200);
    await peer.initialize();
    expect(peer.session, isNotNull);
  });

  test(
    'rotation revokes tokens/sessions and disables advanced; settings never save enable or unlock',
    () async {
      await peer.initialize();
      final oldToken = peer.token;
      service.unlock();
      await service.rotateToken();
      expect(service.advanced, false);
      expect(peer.token, isNot(oldToken));
      expect((await peer.send(authorization: oldToken)).status, 401);
      expect((await peer.call('app_status')).status, 404);
      expect(store.settings.keys, unorderedEquals(['port', 'token']));
      expect((store.settings['token'] as String).length, 43);
      final restarted = AiMcpService(store: store, backend: backend);
      await restarted.initialize();
      expect(restarted.enabled, false);
      expect(restarted.advanced, false);
      restarted.dispose();
    },
  );

  test(
    'storage rotation failure fails closed, occupied port reports error',
    () async {
      service.unlock();
      store.fail = true;
      await service.rotateToken();
      expect(service.enabled, false);
      expect(service.advanced, false);
      expect(service.ready, false);
      expect(service.error, AiMcpError.storage);
      store.fail = false;
      await service.initialize();
      final listener = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      addTearDown(() => listener.close(force: true));
      await service.setPort(listener.port);
      await service.setEnabled(true);
      expect(service.enabled, false);
      expect(service.error, AiMcpError.listen);
    },
  );

  test(
    'disable during start prevents stale listener from being published',
    () async {
      await service.setEnabled(false);
      final start = service.setEnabled(true);
      await service.setEnabled(false);
      await start;
      expect(service.enabled, false);
      expect(service.advanced, false);
    },
  );
  test(
    'maintained SDK client initializes, lists and calls over HTTP',
    () async {
      final client = McpClient(
        const Implementation(name: 'integration-test', version: '1'),
        options: const McpClientOptions(protocol: McpProtocol.stable),
      );
      final transport = StreamableHttpClientTransport(
        Uri.parse('http://127.0.0.1:${service.port}/mcp'),
        opts: StreamableHttpClientTransportOptions(
          requestInit: {
            'headers': {'Authorization': peer.token},
          },
        ),
      );
      addTearDown(client.close);
      await client.connect(transport);
      expect(
        (await client.listTools()).tools.map((tool) => tool.name),
        contains('app_status'),
      );
      final result = await client.callTool(
        const CallToolRequest(name: 'app_status'),
      );
      expect(result.isError, isNot(true));
      expect(backend.calls, ['app_status']);
    },
  );

  test('global tool concurrency is bounded across separate sessions', () async {
    await peer.initialize();
    final other = McpHttpPeer(service);
    addTearDown(other.close);
    await other.initialize();
    final entered = Completer<void>();
    final pending = Completer<void>();
    backend.beforeExecute = () {
      entered.complete();
      return pending.future;
    };
    final first = peer.call('app_status');
    await entered.future;
    final busy = await other.call('app_status');
    expect(jsonEncode(busy.body), contains('busy'));
    pending.complete();
    await first;
    expect(backend.calls, ['app_status']);
  });

  test('body has a total deadline even when chunks keep arriving', () async {
    final socket = await Socket.connect(
      InternetAddress.loopbackIPv4,
      service.port,
    );
    addTearDown(socket.destroy);
    final response = utf8.decoder.bind(socket).join();
    final crlf = String.fromCharCodes([13, 10]);
    socket.write(
      [
        'POST /mcp HTTP/1.1',
        'Host: 127.0.0.1:${service.port}',
        'Authorization: ${peer.token}',
        'Transfer-Encoding: chunked',
        'Content-Type: application/json',
        '',
        '',
      ].join(crlf),
    );
    await socket.flush();
    socket.write('1$crlf{$crlf');
    await socket.flush();
    await Future<void>.delayed(const Duration(seconds: 3));
    socket.write('1$crlf $crlf');
    await socket.flush();
    expect(await response.timeout(const Duration(seconds: 4)), contains('408'));
  });
}
