import 'dart:convert';

import 'package:fl_clash/common/constant.dart';
import 'package:fl_clash/common/mitm_body.dart';
import 'package:fl_clash/models/models.dart';

String _shellQuoted(String text) => "'${text.replaceAll("'", r"'\''")}'";

/// A POSIX shell command that sends [exchange] again, with [body] as the
/// request body; a body that is not text is piped in from Base64.
String mitmCurl(MitmExchange exchange, MitmBody? body) {
  final bytes = body == null ? const <int>[] : base64Decode(body.data);
  final authority = Uri.tryParse(exchange.url)?.authority;
  final method = exchange.method;
  final hasBody = bytes.isNotEmpty;
  final arguments = [_shellQuoted(exchange.url)];
  if (method == 'HEAD') {
    arguments.add('--head');
  } else if (method != (hasBody ? 'POST' : 'GET')) {
    arguments.add('-X ${_shellQuoted(method)}');
  }
  var compressed = false;
  for (final MapEntry(key: name, value: values)
      in exchange.requestHeader.entries) {
    final lower = name.toLowerCase();
    for (final value in values) {
      if (lower == 'content-length' ||
          lower == 'host' && value == authority ||
          lower == 'content-encoding' && hasBody && body!.encoding.isEmpty) {
        continue;
      }
      compressed |= lower == 'accept-encoding';
      arguments.add('-H ${_shellQuoted('$name: $value')}');
    }
  }
  if (compressed) {
    arguments.add('--compressed');
  }
  var input = '';
  if (hasBody) {
    final text = mitmBodyText(bytes);
    if (text != null) {
      arguments.add('--data-raw ${_shellQuoted(text)}');
    } else {
      input = "printf '%s' '${base64Encode(bytes)}' | base64 --decode | ";
      arguments.add('--data-binary @-');
    }
  }
  return '${input}curl ${arguments.join(' \\\n  ')}';
}

String _rawMessage(
  String startLine,
  Map<String, List<String>> header,
  MitmBody? body,
) {
  final out = StringBuffer(startLine);
  for (final MapEntry(key: name, value: values) in header.entries) {
    for (final value in values) {
      out.write('\n$name: $value');
    }
  }
  if (body != null && body.data.isNotEmpty) {
    out.write('\n\n${mitmBodyCopyText(body)}');
  }
  return out.toString();
}

/// [exchange]'s request as HTTP/1 text; a body that is not text is Base64.
String mitmRawRequest((MitmExchange, MitmBody?) input) {
  final (exchange, body) = input;
  final uri = Uri.tryParse(exchange.url);
  final target = uri == null || !uri.hasAuthority
      ? exchange.url
      : '${uri.path.isEmpty ? '/' : uri.path}'
            '${uri.hasQuery ? '?${uri.query}' : ''}';
  return _rawMessage(
    '${exchange.method} $target ${exchange.proto}',
    exchange.requestHeader,
    body,
  );
}

/// [exchange]'s response as HTTP/1 text; a body that is not text is Base64.
String mitmRawResponse((MitmExchange, MitmBody?) input) {
  final (exchange, body) = input;
  return _rawMessage(
    '${exchange.proto} ${exchange.status}',
    exchange.responseHeader,
    body,
  );
}

List<Map<String, String>> _harHeaders(Map<String, List<String>> header) => [
  for (final MapEntry(key: name, value: values) in header.entries)
    for (final value in values) {'name': name, 'value': value},
];

Map<String, Object> _harText(MitmBody body) {
  final bytes = base64Decode(body.data);
  final text = body.encoding.isEmpty ? mitmBodyText(bytes) : null;
  return {
    'text': text ?? body.data,
    if (text == null) 'encoding': 'base64',
    if (body.truncated) 'comment': 'truncated',
  };
}

/// [exchange] with its bodies as an HTTP Archive 1.2 log, which browser
/// developer tools import.
String mitmHar(
  (MitmExchange exchange, MitmBody? request, MitmBody? response, String) input,
) {
  final (exchange, request, response, version) = input;
  final requestType = mitmHeaderValue(exchange.requestHeader, 'Content-Type');
  final responseType = mitmHeaderValue(exchange.responseHeader, 'Content-Type');
  final ttfb = exchange.ttfb > 0 ? exchange.ttfb : exchange.duration;
  final responseText = response == null ? null : _harText(response);
  final requestText = request == null || request.data.isEmpty
      ? null
      : _harText(request);
  final entry = {
    'startedDateTime': exchange.start.toUtc().toIso8601String(),
    'time': exchange.duration,
    'request': {
      'method': exchange.method,
      'url': exchange.url,
      'httpVersion': exchange.proto,
      'cookies': const [],
      'headers': _harHeaders(exchange.requestHeader),
      'queryString': [
        for (final MapEntry(key: name, value: values)
            in (Uri.tryParse(exchange.url)?.queryParametersAll ??
                    const <String, List<String>>{})
                .entries)
          for (final value in values) {'name': name, 'value': value},
      ],
      'headersSize': -1,
      'bodySize': exchange.requestSize,
      if (requestText != null)
        'postData': {
          'mimeType': requestType,
          'text': requestText['text'],
          if (requestText['encoding'] != null)
            '_encoding': requestText['encoding'],
        },
    },
    'response': {
      'status': exchange.status,
      'statusText': '',
      'httpVersion': exchange.proto,
      'cookies': const [],
      'headers': _harHeaders(exchange.responseHeader),
      'content': {
        'size': response == null
            ? exchange.responseSize
            : base64Decode(response.data).length,
        'mimeType': responseType.isEmpty ? 'x-unknown' : responseType,
        ...?responseText,
      },
      'redirectURL': mitmHeaderValue(exchange.responseHeader, 'Location'),
      'headersSize': -1,
      'bodySize': exchange.responseSize,
    },
    'cache': const {},
    'timings': {
      'send': 0,
      'wait': ttfb,
      'receive': exchange.duration > ttfb ? exchange.duration - ttfb : 0,
    },
    if (exchange.connection.isNotEmpty) 'connection': exchange.connection,
  };
  return const JsonEncoder.withIndent('  ').convert({
    'log': {
      'version': '1.2',
      'creator': {'name': appName, 'version': version},
      'entries': [entry],
    },
  });
}
