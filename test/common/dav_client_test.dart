import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/common/dav_client.dart';
import 'package:fl_clash/models/models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

class _FakeDAVClient extends DAVClient {
  _FakeDAVClient(super.dav, this.result, [this.onPing]);

  final Future<bool> result;
  final void Function()? onPing;

  @override
  Future<bool> ping() {
    onPing?.call();
    return result;
  }
}

class _FakePathProvider extends PathProviderPlatform {
  final String root;

  _FakePathProvider(this.root);

  @override
  Future<String?> getTemporaryPath() async => root;

  @override
  Future<String?> getApplicationSupportPath() async => root;

  @override
  Future<String?> getApplicationCachePath() async => root;
}

class _RecordedRequest {
  _RecordedRequest(this.method, this.path, this.authorization, this.body);

  final String method;
  final String path;
  final String? authorization;
  final List<int> body;
}

typedef _ScriptedResponse = ({
  String method,
  int status,
  Map<String, String> headers,
});

/// A stand-in WebDAV origin: the tests drive the real client against a real
/// socket, so status handling, auth and redirects are exercised end to end.
class _TestServer {
  _TestServer(this._server) {
    unawaited(_serve());
  }

  static Future<_TestServer> start() async {
    return _TestServer(await HttpServer.bind(InternetAddress.loopbackIPv4, 0));
  }

  final HttpServer _server;
  final List<_RecordedRequest> requests = [];
  final Map<String, List<int>> files = {};

  /// Answers the next request of a matching method with this status instead of
  /// the default behaviour.
  final List<_ScriptedResponse> responses = [];

  String get uri => 'http://${_server.address.host}:${_server.port}';

  Future<void> close() => _server.close(force: true);

  Future<void> _serve() async {
    await for (final request in _server) {
      final body = await _collect(request);
      requests.add(
        _RecordedRequest(
          request.method,
          request.uri.path,
          request.headers.value(HttpHeaders.authorizationHeader),
          body,
        ),
      );
      final index = responses.indexWhere(
        (item) => item.method == request.method,
      );
      if (index != -1) {
        final scripted = responses.removeAt(index);
        request.response.statusCode = scripted.status;
        scripted.headers.forEach(request.response.headers.set);
        await request.response.close();
        continue;
      }
      await _respond(request, body);
    }
  }

  Future<List<int>> _collect(HttpRequest request) async {
    final bytes = <int>[];
    await for (final chunk in request) {
      bytes.addAll(chunk);
    }
    return bytes;
  }

  Future<void> _respond(HttpRequest request, List<int> body) async {
    final response = request.response;
    final path = request.uri.path;
    switch (request.method) {
      case 'OPTIONS':
        response.headers.set('dav', '1,2');
        response.statusCode = HttpStatus.ok;
      case 'MKCOL':
        response.statusCode = files.containsKey(path)
            ? HttpStatus.methodNotAllowed
            : HttpStatus.created;
        files.putIfAbsent(path, () => const []);
      case 'PUT':
        files[path] = body;
        response.statusCode = HttpStatus.created;
      case 'GET':
        final stored = files[path];
        if (stored == null) {
          response.statusCode = HttpStatus.notFound;
        } else {
          response.statusCode = HttpStatus.ok;
          response.add(stored);
        }
      default:
        response.statusCode = HttpStatus.methodNotAllowed;
    }
    await response.close();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const firstProps = DAVProps(
    uri: 'https://dav.example.com',
    user: 'first',
    password: 'first-password',
  );
  const secondProps = DAVProps(
    uri: 'https://dav.example.com',
    user: 'second',
    password: 'second-password',
  );

  test('latest DAV connectivity check wins', () async {
    final firstResult = Completer<bool>();
    final secondResult = Completer<bool>();
    final results = [firstResult.future, secondResult.future];
    var index = 0;
    final controller = DAVConnectionController(
      createClient: (props) {
        return _FakeDAVClient(props, results[index++]);
      },
    );
    addTearDown(controller.dispose);

    final firstUpdate = controller.update(firstProps);
    final secondUpdate = controller.update(secondProps);

    secondResult.complete(true);
    await secondUpdate;
    expect(controller.value, isTrue);

    firstResult.complete(false);
    await firstUpdate;
    expect(controller.value, isTrue);
  });

  test('changing only the remote file name does not ping again', () async {
    var pingCount = 0;
    final controller = DAVConnectionController(
      createClient: (props) {
        return _FakeDAVClient(props, Future.value(true), () => pingCount++);
      },
    );
    addTearDown(controller.dispose);

    await controller.update(firstProps);
    await controller.update(firstProps.copyWith(fileName: 'another.zip'));

    expect(pingCount, 1);
    expect(controller.value, isTrue);
    expect(controller.client?.fileName, 'another.zip');
  });

  test('new credentials reset connectivity while ping is pending', () async {
    final result = Completer<bool>();
    final controller = DAVConnectionController(
      createClient: (props) {
        return _FakeDAVClient(props, result.future);
      },
    );
    addTearDown(controller.dispose);

    final update = controller.update(firstProps);

    expect(controller.value, isNull);
    result.complete(true);
    await update;
    expect(controller.value, isTrue);
  });

  group('against a live server', () {
    late _TestServer server;
    late Directory root;
    HttpOverrides? testOverrides;

    // appPath resolves the data directory once per process, so every test in
    // this group has to share one root.
    setUpAll(() {
      root = Directory.systemTemp.createTempSync('dav_client_test');
      PathProviderPlatform.instance = _FakePathProvider(root.path);
    });

    tearDownAll(() {
      try {
        root.deleteSync(recursive: true);
      } catch (_) {}
    });

    setUp(() async {
      // The widget test binding installs an override that answers every
      // request with 400 instead of opening a socket.
      testOverrides = HttpOverrides.current;
      HttpOverrides.global = null;
      server = await _TestServer.start();
    });

    tearDown(() async {
      HttpOverrides.global = testOverrides;
      await server.close();
    });

    DAVClient buildClient({String path = ''}) {
      return DAVClient(
        DAVProps(
          uri: '${server.uri}$path',
          user: 'user',
          password: 'secret',
          fileName: 'backup.zip',
        ),
      );
    }

    File writeArchive(List<int> bytes) {
      return File(join(root.path, 'source.zip'))..writeAsBytesSync(bytes);
    }

    test('ping reports a server that answers OPTIONS', () async {
      expect(await buildClient().ping(), isTrue);
      expect(server.requests.single.method, 'OPTIONS');
    });

    test('ping reports a server that refuses the credentials', () async {
      server.responses.add((
        method: 'OPTIONS',
        status: HttpStatus.unauthorized,
        headers: const {},
      ));

      expect(await buildClient().ping(), isFalse);
    });

    test('backup creates the collection and uploads the archive', () async {
      final archive = writeArchive(List<int>.generate(32, (index) => index));

      expect(await buildClient().backup(archive.path), isTrue);

      expect(server.requests.map((item) => item.method), ['MKCOL', 'PUT']);
      expect(server.requests.last.path, '/$appName/backup.zip');
      expect(server.files['/$appName/backup.zip'], archive.readAsBytesSync());
    });

    test('a base path prefixes every request', () async {
      await buildClient(path: '/remote.php/dav').ping();

      expect(server.requests.single.path, '/remote.php/dav/');
    });

    test('an existing collection is not an error', () async {
      final archive = writeArchive(const [1, 2, 3]);
      final client = buildClient();

      await client.backup(archive.path);

      expect(await client.backup(archive.path), isTrue);
    });

    test('restore writes the downloaded archive to the backup file', () async {
      final payload = List<int>.generate(64, (index) => index);
      server.files['/$appName/backup.zip'] = payload;

      expect(await buildClient().restore(), isTrue);

      expect(File(join(root.path, 'backup.zip')).readAsBytesSync(), payload);
    });

    test('restore reports the status the server sent', () async {
      await expectLater(
        buildClient().restore(),
        throwsA(
          isA<DAVException>().having(
            (error) => error.toString(),
            'message',
            allOf(contains('GET'), contains('404')),
          ),
        ),
      );
    });

    test('a redirected download keeps the method', () async {
      final payload = List<int>.generate(8, (index) => index);
      server.files['/moved/backup.zip'] = payload;
      server.responses.add((
        method: 'GET',
        status: HttpStatus.movedPermanently,
        headers: const {'location': '/moved/backup.zip'},
      ));

      expect(await buildClient().restore(), isTrue);

      expect(server.requests.map((item) => item.method), ['GET', 'GET']);
      expect(File(join(root.path, 'backup.zip')).readAsBytesSync(), payload);
    });

    test('credentials are sent as basic auth', () async {
      await buildClient().ping();

      expect(
        server.requests.single.authorization,
        'Basic ${base64.encode(utf8.encode('user:secret'))}',
      );
    });

    test('a digest challenge is answered and retried once', () async {
      server.responses.add((
        method: 'OPTIONS',
        status: HttpStatus.unauthorized,
        headers: const {
          'www-authenticate':
              'Digest realm="dav", qop="auth", nonce="abc123", opaque="op"',
        },
      ));

      expect(await buildClient().ping(), isTrue);

      expect(server.requests, hasLength(2));
      expect(server.requests.first.authorization, startsWith('Basic '));
      final retry = server.requests.last.authorization!;
      expect(retry, startsWith('Digest '));
      expect(retry, contains('username="user"'));
      expect(retry, contains('nonce="abc123"'));
      expect(retry, contains('qop=auth'));
      expect(retry, contains('nc=00000001'));
    });

    test('anonymous access sends no authorization header', () async {
      await DAVClient(DAVProps(uri: server.uri, user: '', password: '')).ping();

      expect(server.requests.single.authorization, isNull);
    });
  });
}
