import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';

import 'link.dart';

typedef LinkReceiverTexts = ({
  String title,
  String hint,
  String send,
  String sent,
  String invalid,
});

/// Serves a one-page form on the local network so a phone that scans [address]
/// can hand a link to a device that has no way to type one.
class LinkReceiver {
  static const _maxBodyBytes = 16 * 1024;

  final HttpServer _server;
  final String _token;
  final LinkReceiverTexts _texts;
  final _link = Completer<String?>();

  final Uri address;

  LinkReceiver._(this._server, this._token, this._texts, String host)
    : address = Uri(
        scheme: 'http',
        host: host,
        port: _server.port,
        path: '/$_token',
      );

  /// The first valid link a phone sends, or null if [close] comes first.
  Future<String?> get link => _link.future;

  static final _preferredInterface = RegExp(
    r'^(wlan|wl|eth|en|wi-?fi|ethernet)',
    caseSensitive: false,
  );

  static Future<LinkReceiver?> start(
    LinkReceiverTexts texts, {
    @visibleForTesting String? host,
  }) async {
    host ??= await _lanHost();
    if (host == null) {
      return null;
    }
    final server = await HttpServer.bind(InternetAddress(host), 0);
    final receiver = LinkReceiver._(server, _newToken(), texts, host);
    server.listen((request) => receiver._serve(request), onError: (_) {});
    return receiver;
  }

  static Future<String?> _lanHost() async {
    final interfaces = await NetworkInterface.list(
      type: InternetAddressType.IPv4,
    );
    final ordered = [
      ...interfaces.where((i) => _preferredInterface.hasMatch(i.name)),
      ...interfaces.where((i) => !_preferredInterface.hasMatch(i.name)),
    ];
    return lanAddress(ordered.expand((interface) => interface.addresses));
  }

  Future<void> close() {
    if (!_link.isCompleted) {
      _link.complete(null);
    }
    return _server.close(force: true);
  }

  static String _newToken() {
    final random = Random.secure();
    return base64Url
        .encode(List<int>.generate(16, (_) => random.nextInt(256)))
        .replaceAll('=', '');
  }

  @visibleForTesting
  static String? lanAddress(Iterable<InternetAddress> addresses) {
    for (final address in addresses) {
      final bytes = address.rawAddress;
      if (bytes.length != 4 || address.isLoopback || address.isLinkLocal) {
        continue;
      }
      final isPrivate =
          bytes[0] == 10 ||
          (bytes[0] == 172 && bytes[1] >= 16 && bytes[1] < 32) ||
          (bytes[0] == 192 && bytes[1] == 168);
      if (isPrivate) {
        return address.address;
      }
    }
    return null;
  }

  void _serve(HttpRequest request) {
    unawaited(
      _handle(request).catchError(
        (Object _) => request.response.close().catchError((Object _) {}),
      ),
    );
  }

  Future<void> _handle(HttpRequest request) async {
    final response = request.response;
    response.headers
      ..set(HttpHeaders.cacheControlHeader, 'no-store')
      ..contentType = ContentType.html;
    if (request.uri.path != '/$_token' || _link.isCompleted) {
      response.statusCode = HttpStatus.notFound;
      await response.close();
      return;
    }
    if (request.method == 'GET') {
      response.write(_page());
      await response.close();
      return;
    }
    if (request.method != 'POST') {
      response.statusCode = HttpStatus.methodNotAllowed;
      await response.close();
      return;
    }
    final text = await _readLink(request);
    final link = profileUrlFromQrCodes([text]);
    if (link == null) {
      response.statusCode = HttpStatus.badRequest;
      response.write(_page(error: _texts.invalid, value: text ?? ''));
      await response.close();
      return;
    }
    if (_link.isCompleted) {
      response.statusCode = HttpStatus.notFound;
      await response.close();
      return;
    }
    _link.complete(link);
    response.write(_page(done: true));
    await response.close();
    unawaited(close());
  }

  Future<String?> _readLink(HttpRequest request) async {
    final bytes = <int>[];
    await for (final chunk in request) {
      bytes.addAll(chunk);
      if (bytes.length > _maxBodyBytes) {
        return null;
      }
    }
    try {
      return Uri.splitQueryString(utf8.decode(bytes))['link']?.trim();
    } on FormatException {
      return null;
    } on ArgumentError {
      return null;
    }
  }

  String _page({bool done = false, String? error, String value = ''}) {
    const escape = HtmlEscape();
    final title = escape.convert(_texts.title);
    final body = done
        ? '<p>${escape.convert(_texts.sent)}</p>'
        : '''
<form method="post">
<textarea name="link" rows="4" placeholder="${escape.convert(_texts.hint)}" autofocus required>${escape.convert(value)}</textarea>
${error == null ? '' : '<p class="error">${escape.convert(error)}</p>'}
<button type="submit">${escape.convert(_texts.send)}</button>
</form>''';
    return '''
<!doctype html>
<html><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>$title</title>
<style>
body{font-family:system-ui,sans-serif;margin:0;padding:1.5rem;max-width:35rem;margin:auto;color-scheme:light dark}
h1{font-size:1.4rem}
textarea{width:100%;box-sizing:border-box;font:inherit;padding:.75rem;border-radius:.75rem;border:thin solid #8888}
button{margin-top:1rem;width:100%;padding:.9rem;font:inherit;font-weight:600;border:0;border-radius:.9rem;background:#007aff;color:#fff}
.error{color:#ff3b30}
</style></head>
<body><h1>$title</h1>$body</body></html>''';
  }
}
