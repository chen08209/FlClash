import 'dart:convert';
import 'dart:io';

import 'package:fl_clash/ai_mcp/backend.dart';
import 'package:fl_clash/ai_mcp/service.dart';

class MemoryAiMcpStore implements AiMcpStore {
  Map<String, Object?> settings = {};
  bool fail = false;
  Future<void> Function()? beforeLoad;
  Future<void> Function()? beforeSave;

  @override
  Future<Map<String, Object?>> load() async {
    await beforeLoad?.call();
    return settings;
  }

  @override
  Future<void> save(Map<String, Object?> settings) async {
    await beforeSave?.call();
    if (fail) throw StateError('private storage error');
    this.settings = Map.of(settings);
  }
}

class FakeAiMcpBackend implements AiMcpBackend {
  final calls = <String>[];
  bool fail = false;
  Future<void> Function()? beforeExecute;

  @override
  Future<Map<String, Object?>> execute(
    String name,
    Map<String, dynamic> arguments,
    void Function() checkPermission,
  ) async {
    await beforeExecute?.call();
    checkPermission();
    calls.add(name);
    if (fail) throw StateError('private backend details');
    return {'ok': true};
  }
}

Future<int> availableMcpPort() async {
  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
  final port = server.port;
  await server.close(force: true);
  return port;
}

class McpHttpPeer {
  McpHttpPeer(this.service);
  final AiMcpService service;
  final client = HttpClient()..findProxy = (_) => 'DIRECT';
  String? session;
  int _id = 0;

  String get token =>
      (jsonDecode(
            service.connectionConfig,
          )['mcpServers']['flclash']['headers']['Authorization']
          as String);

  Future<({int status, Map<String, dynamic>? body})> send({
    String method = 'POST',
    String? authorization,
    bool omitAuth = false,
    String? host,
    String? origin,
    String? raw,
    Map<String, dynamic>? message,
  }) async {
    final request = await client.openUrl(
      method,
      Uri.parse('http://127.0.0.1:${service.port}/mcp'),
    );
    request.persistentConnection = false;
    request.headers.set('Host', host ?? '127.0.0.1:${service.port}');
    request.headers.set('Accept', 'application/json, text/event-stream');
    request.headers.set('MCP-Protocol-Version', '2025-11-25');
    if (!omitAuth) request.headers.set('Authorization', authorization ?? token);
    if (origin != null) request.headers.set('Origin', origin);
    if (session != null) request.headers.set('mcp-session-id', session!);
    if (method == 'DELETE' && raw != null) {
      request.contentLength = utf8.encode(raw).length;
    }
    if (method == 'POST' || raw != null) {
      request.headers.contentType = ContentType.json;
      request.write(raw ?? jsonEncode(message));
    }
    final response = await request.close();
    session = response.headers.value('mcp-session-id') ?? session;
    final text = await utf8.decoder.bind(response).join();
    return (
      status: response.statusCode,
      body: text.isEmpty ? null : jsonDecode(text) as Map<String, dynamic>,
    );
  }

  Future<({int status, Map<String, dynamic>? body})> rpc(
    String method, [
    Map<String, dynamic>? params,
  ]) => send(
    message: {
      'jsonrpc': '2.0',
      'id': ++_id,
      'method': method,
      'params': ?params,
    },
  );

  Future<void> initialize() async {
    await rpc('initialize', {
      'protocolVersion': '2025-11-25',
      'capabilities': {},
      'clientInfo': {'name': 'test-client', 'version': '1'},
    });
    await send(
      message: {'jsonrpc': '2.0', 'method': 'notifications/initialized'},
    );
  }

  Future<({int status, Map<String, dynamic>? body})> call(
    String name, [
    Map<String, dynamic> arguments = const {},
  ]) => rpc('tools/call', {'name': name, 'arguments': arguments});

  void close() => client.close(force: true);
}
