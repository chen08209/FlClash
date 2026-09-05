import 'dart:async';

import 'package:fl_clash/common/link.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
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

  test(
    'a seeded launch argument is delivered once a listener attaches',
    () async {
      linkManager.seedInitialLink([
        '--verbose',
        'flclash://install-config?url=https://example.com/a.yaml',
      ]);

      expect(received, isEmpty);

      await listen();

      expect(received, ['https://example.com/a.yaml']);

      await listen();

      expect(received, ['https://example.com/a.yaml']);
    },
  );

  test('launch arguments without a known scheme are ignored', () async {
    linkManager.seedInitialLink(['https://example.com/a.yaml', 'not a uri']);

    await listen();

    expect(received, isEmpty);
  });

  test('destroy stops delivery and is safe to repeat', () async {
    await listen();

    linkManager.destroy();
    linkManager.destroy();
    await emit('flclash://install-config?url=https://example.com/a.yaml');

    expect(linkManager.subscription, isNull);
    expect(received, isEmpty);
  });
}
