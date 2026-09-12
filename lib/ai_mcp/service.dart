import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:mcp_dart/mcp_dart.dart';

import 'backend.dart';

abstract interface class AiMcpStore {
  Future<Map<String, Object?>> load();
  Future<void> save(Map<String, Object?> settings);
}

enum AiMcpError { storage, listen }

class _BodyTooLarge implements Exception {}

class _Session {
  _Session(this.server, this.transport, this.advancedTools);

  final McpServer server;
  final StreamableHTTPServerTransport transport;
  final List<RegisteredTool> advancedTools;
  DateTime lastUsed = DateTime.now();
  bool busy = false;
}

class AiMcpService extends ChangeNotifier {
  AiMcpService({required this.store, required this.backend});

  static const defaultPort = 17890;
  static const maxSessions = 8;
  static const maxBodyBytes = 16384;
  static const maxDelayNodes = 8;
  final AiMcpStore store;
  final AiMcpBackend backend;
  final _sessions = <String, _Session>{};
  HttpServer? _listener;
  Timer? _expiry;
  bool _disposed = false;
  bool _enabled = false;
  bool _advanced = false;
  bool _toolBusy = false;
  int _revision = 0;
  int _requests = 0;
  int _port = defaultPort;
  String _token = '';
  bool ready = false;
  bool changing = false;
  AiMcpError? error;

  bool get enabled => _enabled;
  bool get advanced => _advanced;
  int get permissionRevision => _revision;
  int get port => _listener?.port ?? _port;
  String get connectionConfig => const JsonEncoder.withIndent('  ').convert({
    'mcpServers': {
      'flclash': {
        'type': 'http',
        'url': 'http://127.0.0.1:$port/mcp',
        'headers': {'Authorization': 'Bearer $_token'},
      },
    },
  });

  static String randomToken() {
    final random = Random.secure();
    return base64UrlEncode(
      List.generate(32, (_) => random.nextInt(256)),
    ).replaceAll('=', '');
  }

  Future<void> initialize() async {
    if (_disposed || ready) return;
    try {
      final settings = await store.load();
      if (_disposed) return;
      final savedPort = settings['port'];
      if (savedPort is int && savedPort >= 1024 && savedPort <= 65535) {
        _port = savedPort;
      }
      final token = settings['token'];
      _token = token is String && RegExp(r'^[A-Za-z0-9_-]{43}$').hasMatch(token)
          ? token
          : randomToken();
      await _save();
      ready = true;
      error = null;
    } catch (_) {
      error = AiMcpError.storage;
    }
    _notify();
  }

  Future<void> _save() => store.save({'port': _port, 'token': _token});

  Future<void> setPort(int value) async {
    if (changing ||
        _disposed ||
        !ready ||
        _enabled ||
        value < 1024 ||
        value > 65535) {
      return;
    }
    changing = true;
    final previous = _port;
    _port = value;
    _notify();
    try {
      await _save();
      error = null;
    } catch (_) {
      _port = previous;
      error = AiMcpError.storage;
    } finally {
      changing = false;
      _notify();
    }
  }

  Future<void> rotateToken() async {
    if (changing || _disposed || !ready) return;
    final restart = _enabled;
    _enabled = false;
    lock();
    final revision = _revision;
    changing = true;
    _notify();
    try {
      await _stop();
      _token = randomToken();
      await _save();
      error = null;
    } catch (_) {
      ready = false;
      error = AiMcpError.storage;
    } finally {
      changing = false;
      _notify();
    }
    if (restart && ready && revision == _revision && !_disposed) {
      await setEnabled(true);
    }
  }

  void lock() {
    _advanced = false;
    _revision++;
    for (final session in _sessions.values) {
      for (final tool in session.advancedTools) {
        tool.disable();
      }
    }
    _notify();
  }

  void unlock() {
    if (!_enabled || changing || _disposed) return;
    _advanced = true;
    for (final session in _sessions.values) {
      for (final tool in session.advancedTools) {
        tool.enable();
      }
    }
    _notify();
  }

  Future<void> setEnabled(bool value) async {
    if (!value) {
      _enabled = false;
      lock();
    }
    if (changing || _disposed || (value && (!ready || _enabled))) return;
    changing = true;
    _notify();
    try {
      if (!value) {
        await _stop();
      } else {
        error = null;
        final revision = _revision;
        final listener = await HttpServer.bind(
          InternetAddress.loopbackIPv4,
          _port,
        );
        if (_disposed || revision != _revision) {
          await listener.close(force: true);
          return;
        }
        _listener = listener;
        listener.idleTimeout = const Duration(seconds: 10);
        _enabled = true;
        listener.listen(
          _handle,
          onError: (_) {
            error = AiMcpError.listen;
            unawaited(setEnabled(false));
          },
        );
        _expiry = Timer.periodic(const Duration(minutes: 1), (_) {
          for (final session in _sessions.values.toList()) {
            if (!session.busy &&
                DateTime.now().difference(session.lastUsed) >
                    const Duration(minutes: 10)) {
              unawaited(session.server.close());
            }
          }
        });
      }
    } catch (_) {
      _enabled = false;
      error = AiMcpError.listen;
      await _stop();
    } finally {
      changing = false;
      _notify();
    }
  }

  Future<void> _stop() async {
    _expiry?.cancel();
    _expiry = null;
    final listener = _listener;
    _listener = null;
    await listener?.close(force: true);
    final sessions = _sessions.values.toList();
    _sessions.clear();
    for (final session in sessions) {
      await session.server.close();
    }
  }

  bool _authorized(HttpRequest request) {
    final supplied =
        request.headers.value(HttpHeaders.authorizationHeader) ?? '';
    final expected = 'Bearer $_token';
    var difference = supplied.length ^ expected.length;
    for (var i = 0; i < expected.length; i++) {
      difference |=
          expected.codeUnitAt(i) ^
          (i < supplied.length ? supplied.codeUnitAt(i) : 0);
    }
    return _enabled && !_disposed && difference == 0;
  }

  Future<void> _reject(HttpRequest request, int status) async {
    request.response.statusCode = status;
    request.response.persistentConnection = false;
    if (status == HttpStatus.unauthorized) {
      request.response.headers.set(HttpHeaders.wwwAuthenticateHeader, 'Bearer');
    }
    await request.response.close();
  }

  Future<dynamic> _readBody(HttpRequest request) async {
    final iterator = StreamIterator(request);
    final clock = Stopwatch()..start();
    final bytes = <int>[];
    try {
      while (await iterator.moveNext().timeout(
        const Duration(seconds: 5) - clock.elapsed,
      )) {
        final chunk = iterator.current;
        if (bytes.length + chunk.length > maxBodyBytes) throw _BodyTooLarge();
        bytes.addAll(chunk);
      }
      return jsonDecode(utf8.decode(bytes));
    } on _BodyTooLarge {
      await _reject(request, HttpStatus.requestEntityTooLarge);
      rethrow;
    } on TimeoutException {
      await _reject(request, HttpStatus.requestTimeout);
      rethrow;
    } finally {
      await iterator.cancel();
    }
  }

  Future<void> _handle(HttpRequest request) async {
    _Session? session;
    var ownsSession = false;
    var admitted = false;
    try {
      final host = request.headers.value(HttpHeaders.hostHeader);
      if ((host != '127.0.0.1:$port' && host != '127.0.0.1') ||
          request.headers['origin'] != null) {
        await _reject(request, HttpStatus.forbidden);
        return;
      }
      if (!_authorized(request)) {
        await _reject(request, HttpStatus.unauthorized);
        return;
      }
      if (request.uri.path != '/mcp' || request.uri.hasQuery) {
        await _reject(request, HttpStatus.notFound);
        return;
      }
      // JSON-only MCP permits declining the optional standalone SSE stream.
      if (request.method != 'POST' && request.method != 'DELETE') {
        await _reject(request, HttpStatus.methodNotAllowed);
        return;
      }
      if (_requests >= maxSessions) {
        await _reject(request, HttpStatus.tooManyRequests);
        return;
      }
      _requests++;
      admitted = true;
      final revision = _revision;
      dynamic body;
      if (request.method == 'POST') {
        if (request.contentLength > maxBodyBytes) {
          await _reject(request, HttpStatus.requestEntityTooLarge);
          return;
        }
        body = await _readBody(request);
        if (body is! Map<String, dynamic>) {
          await _reject(request, HttpStatus.badRequest);
          return;
        }
      }
      if (!_authorized(request) || revision != _revision) {
        await _reject(request, HttpStatus.unauthorized);
        return;
      }
      final id = request.headers.value('mcp-session-id');
      if (id != null) {
        session = _sessions[id];
        if (session == null) {
          await _reject(request, HttpStatus.notFound);
          return;
        }
      } else {
        if (body is! Map || body['method'] != 'initialize') {
          await _reject(request, HttpStatus.badRequest);
          return;
        }
        if (_sessions.length >= maxSessions) {
          await _reject(request, HttpStatus.tooManyRequests);
          return;
        }
        session = _createSession();
        await session.server.connect(session.transport);
      }
      if (session.busy) {
        await _reject(request, HttpStatus.tooManyRequests);
        return;
      }
      session.busy = true;
      ownsSession = true;
      session.lastUsed = DateTime.now();
      await session.transport.handleRequest(request, body);
      await request.response.done.timeout(const Duration(seconds: 60));
      if (session.transport.sessionId == null) await session.server.close();
    } on _BodyTooLarge {
      return;
    } on TimeoutException {
      if (session != null) await session.server.close();
    } on FormatException {
      await _reject(request, HttpStatus.badRequest);
    } catch (_) {
      if (session != null) await session.server.close();
      try {
        await _reject(request, HttpStatus.badRequest);
      } catch (_) {}
    } finally {
      if (session != null && ownsSession) session.busy = false;
      if (admitted) _requests--;
    }
  }

  _Session _createSession() {
    final id = randomToken();
    final server = McpServer(
      const Implementation(name: 'flclash', version: '1.0.0'),
      options: const McpServerOptions(protocol: McpProtocol.stable),
    );
    final transport = StreamableHTTPServerTransport(
      options: StreamableHTTPServerTransportOptions(
        sessionIdGenerator: () => id,
        enableJsonResponse: true,
        allowedHosts: {'127.0.0.1'},
        allowedOrigins: {},
      ),
    );
    final advancedTools = <RegisteredTool>[];
    for (final definition in aiMcpTools) {
      final tool = server.registerTool(
        definition.name,
        description: definition.description,
        inputSchema: definition.schema,
        callback: (arguments, _) => _call(id, definition, arguments),
      );
      if (definition.advanced) {
        advancedTools.add(tool);
        if (!_advanced) tool.disable();
      }
    }
    final session = _Session(server, transport, advancedTools);
    _sessions[id] = session;
    server.server.onclose = () => _sessions.remove(id);
    return session;
  }

  Future<CallToolResult> _call(
    String sessionId,
    AiMcpTool tool,
    Map<String, dynamic> arguments,
  ) async {
    final revision = _revision;
    void check() {
      if (_disposed ||
          !_enabled ||
          !_sessions.containsKey(sessionId) ||
          revision != _revision ||
          (tool.advanced && !_advanced)) {
        throw const AiMcpFailure('permission_denied');
      }
    }

    if (_toolBusy) return _failure('busy');
    _toolBusy = true;
    try {
      check();
      final result = await backend.execute(tool.name, arguments, check);
      check();
      return CallToolResult(content: [TextContent(text: jsonEncode(result))]);
    } on AiMcpFailure catch (failure) {
      return _failure(failure.code);
    } catch (_) {
      return _failure('backend_failure');
    } finally {
      _toolBusy = false;
    }
  }

  CallToolResult _failure(String code) => CallToolResult(
    isError: true,
    content: [
      TextContent(text: jsonEncode({'error': code})),
    ],
  );

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _enabled = false;
    lock();
    _disposed = true;
    unawaited(_stop());
    super.dispose();
  }
}
