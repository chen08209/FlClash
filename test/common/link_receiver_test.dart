import 'dart:convert';
import 'dart:io';

import 'package:fl_clash/common/link_receiver.dart';
import 'package:flutter_test/flutter_test.dart';

const _texts = (
  title: 'Send a link',
  hint: 'Link',
  send: 'Send',
  sent: 'Sent',
  invalid: 'Not a link',
);

Future<(int, String)> _request(
  Uri uri, {
  String method = 'GET',
  String? link,
  String? body,
}) async {
  final client = HttpClient();
  try {
    final request = await client.openUrl(method, uri);
    final form =
        body ??
        (link == null ? null : 'link=${Uri.encodeQueryComponent(link)}');
    if (form != null) {
      request.headers.contentType = ContentType(
        'application',
        'x-www-form-urlencoded',
      );
      request.write(form);
    }
    final response = await request.close();
    return (response.statusCode, await utf8.decodeStream(response));
  } finally {
    client.close(force: true);
  }
}

void main() {
  group('lanAddress', () {
    test('skips loopback, link-local and FlClash TUN addresses', () {
      expect(
        LinkReceiver.lanAddress([
          for (final value in [
            '127.0.0.1',
            '198.18.0.1',
            '169.254.3.4',
            '192.168.1.20',
          ])
            InternetAddress(value),
        ]),
        '192.168.1.20',
      );
    });

    test('finds nothing without a private network', () {
      expect(LinkReceiver.lanAddress([InternetAddress('100.72.1.9')]), isNull);
    });
  });

  group('LinkReceiver', () {
    late LinkReceiver receiver;

    setUp(() async {
      receiver = (await LinkReceiver.start(_texts, host: '127.0.0.1'))!;
    });

    tearDown(() => receiver.close());

    test('answers only on its own token', () async {
      final (status, _) = await _request(
        receiver.address.replace(path: '/guess'),
      );
      expect(status, HttpStatus.notFound);

      final (formStatus, page) = await _request(receiver.address);
      expect(formStatus, HttpStatus.ok);
      expect(page, contains('<form method="post">'));
    });

    test('rejects a value that is no link and keeps waiting', () async {
      final (status, page) = await _request(
        receiver.address,
        method: 'POST',
        link: 'hello <b>',
      );
      expect(status, HttpStatus.badRequest);
      expect(page, contains('Not a link'));
      expect(page, contains('hello &lt;b&gt;'));

      final (formStatus, _) = await _request(receiver.address);
      expect(formStatus, HttpStatus.ok);
    });

    test('rejects a body with broken percent encoding', () async {
      for (final body in ['link=%zz', 'link=%']) {
        final (status, page) = await _request(
          receiver.address,
          method: 'POST',
          body: body,
        );
        expect(status, HttpStatus.badRequest);
        expect(page, contains('Not a link'));
      }
    });

    test('hands over the first link and then stops listening', () async {
      const link = 'https://example.com/sub?token=a&b=1';
      final (status, page) = await _request(
        receiver.address,
        method: 'POST',
        link: ' $link ',
      );
      expect(status, HttpStatus.ok);
      expect(page, contains('Sent'));
      expect(await receiver.link, link);

      await expectLater(
        _request(receiver.address),
        throwsA(isA<SocketException>()),
      );
    });

    test('accepts a clash install-config link', () async {
      const url = 'https://example.com/sub';
      final (status, _) = await _request(
        receiver.address,
        method: 'POST',
        link: 'clash://install-config?url=${Uri.encodeQueryComponent(url)}',
      );
      expect(status, HttpStatus.ok);
      expect(await receiver.link, url);
    });

    test('completes the link with null when closed first', () async {
      final pending = receiver.link;
      await receiver.close();
      expect(await pending, isNull);
    });
  });
}
