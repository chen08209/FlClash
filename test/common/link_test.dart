import 'dart:async';

import 'package:fl_clash/common/link.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late StreamController<Uri> links;
  late List<String> received;

  setUp(() {
    links = StreamController<Uri>.broadcast();
    received = [];
    linkManager.uriLinkStream = () => links.stream;
  });

  tearDown(() async {
    linkManager.destroy();
    await links.close();
  });

  Future<void> listen() async {
    await linkManager.initAppLinksListen(received.add);
  }

  Future<void> emit(String uri) async {
    links.add(Uri.parse(uri));
    await Future<void>.delayed(Duration.zero);
  }

  test('LinkManager is a singleton', () {
    expect(LinkManager(), same(linkManager));
  });

  test('an install-config link reports its url', () async {
    await listen();

    await emit('flclash://install-config?url=https://example.com/a.yaml');

    expect(received, ['https://example.com/a.yaml']);
  });

  test('an install-config link without a url is ignored', () async {
    await listen();

    await emit('flclash://install-config');

    expect(received, isEmpty);
  });

  test('an install-config link with a blank url is ignored', () async {
    await listen();

    await emit('flclash://install-config?url=');
    await emit('flclash://install-config?url=%20');

    expect(received, isEmpty);
  });

  test('a link for another host is ignored', () async {
    await listen();

    await emit('flclash://open-profile?url=https://example.com/a.yaml');

    expect(received, isEmpty);
  });

  test('listening again replaces the previous subscription', () async {
    await listen();
    final first = linkManager.subscription;

    await listen();

    expect(linkManager.subscription, isNot(same(first)));

    await emit('flclash://install-config?url=https://example.com/a.yaml');

    expect(received, ['https://example.com/a.yaml']);
  });

  test('a link with a scheme the app does not claim is ignored', () async {
    await listen();

    await emit('https://install-config?url=https://example.com/a.yaml');

    expect(received, isEmpty);
  });

  group('androidLinks', () {
    const channel = MethodChannel('test/link');
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

    tearDown(() => messenger.setMockMethodCallHandler(channel, null));

    Future<void> push(String link) async {
      await messenger.handlePlatformMessage(
        channel.name,
        channel.codec.encodeMethodCall(MethodCall('link', link)),
        (_) {},
      );
    }

    test('delivers the held links, then pushed ones', () async {
      final calls = <String>[];
      messenger.setMockMethodCallHandler(channel, (call) async {
        calls.add(call.method);
        return ['flclash://install-config?url=https://example.com/a.yaml'];
      });
      final uris = <Uri>[];
      final subscription = androidLinks(channel).listen(uris.add);
      await pumpEventQueue();

      await push('flclash://install-config?url=https://example.com/b.yaml');
      await pumpEventQueue();

      expect(calls, ['takeLinks']);
      expect(uris.map((uri) => uri.queryParameters['url']), [
        'https://example.com/a.yaml',
        'https://example.com/b.yaml',
      ]);
      await subscription.cancel();
    });
  });

  test('destroy stops delivery and is safe to repeat', () async {
    await listen();

    linkManager.destroy();
    linkManager.destroy();
    await emit('flclash://install-config?url=https://example.com/a.yaml');

    expect(linkManager.subscription, isNull);
    expect(received, isEmpty);
  });

  group('profileUrlFromQrCodes', () {
    test('accepts a bare url with surrounding whitespace', () {
      expect(
        profileUrlFromQrCodes([' https://example.com/sub?token=1\n']),
        'https://example.com/sub?token=1',
      );
    });

    test('unwraps the url of an install-config link for every scheme', () {
      for (final scheme in ['clash', 'clashmeta', 'flclash']) {
        expect(
          profileUrlFromQrCodes([
            '$scheme://install-config?url=https%3A%2F%2Fexample.com%2Fa.yaml',
          ]),
          'https://example.com/a.yaml',
        );
      }
    });

    test('rejects codes that carry no profile url', () {
      expect(
        profileUrlFromQrCodes([
          null,
          '',
          'plain text',
          'https://',
          'clash://install-config?url=not-a-url',
          'clash://open-profile?url=https://example.com/a.yaml',
          'other://install-config?url=https://example.com/a.yaml',
        ]),
        isNull,
      );
    });

    test('accepts a proxy share link', () {
      expect(
        profileUrlFromQrCodes([
          'plain text',
          'vmess://eyJhZGQiOiIxLjIuMy40In0=',
        ]),
        'vmess://eyJhZGQiOiIxLjIuMy40In0=',
      );
    });

    test('returns the first code that carries a profile url', () {
      expect(
        profileUrlFromQrCodes([
          'plain text',
          'flclash://install-config?url=https://example.com/first.yaml',
          'https://example.com/second.yaml',
        ]),
        'https://example.com/first.yaml',
      );
    });
  });
}
