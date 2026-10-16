import 'dart:io';

import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:test/test.dart';

Set<String> _keysOf(String path, String struct, String tag) {
  final source = File(path).readAsStringSync();
  final body = RegExp(
    'type $struct struct {([^}]*)}',
  ).firstMatch(source)!.group(1)!;
  return {
    for (final line in body.split('\n'))
      if (!line.trim().startsWith('//'))
        for (final match in RegExp('$tag:"([^",]+)').allMatches(line))
          match.group(1)!,
  };
}

void main() {
  final tunKeys = const Tun().toJson().keys.toSet();

  test('every Tun key is a key of the core TUN section', () {
    expect(
      _keysOf('core/Clash.Meta/config/config.go', 'RawTun', 'yaml'),
      containsAll(tunKeys),
    );
  });

  test('a saved zero MTU or empty congestion control reads as the default', () {
    final tun = Tun.fromJson({'mtu': 0, 'congestion-controller': ''});

    expect(tun.mtu, defaultTunMtu);
    expect(tun.congestionController, defaultCongestionController);
  });

  test('a saved MTU outside what a TUN interface accepts is clamped', () {
    expect(Tun.fromJson({'mtu': 70000}).mtu, maxTunMtu);
    expect(Tun.fromJson({'mtu': 576}).mtu, minTunMtu);
    expect(Tun.fromJson({'mtu': 1500}).mtu, 1500);
  });

  test('the desktop TUN takes only its switch, device and stack, routed', () {
    const tun = Tun(
      enable: true,
      stack: TunStack.gvisor,
      mtu: 1400,
      routeAddress: ['1.0.0.0/8'],
    );

    expect(tun.coreJson, {
      'enable': true,
      'device': tun.device,
      'stack': 'gvisor',
      'auto-route': true,
    });
  });

  test('a config update patches every key the desktop TUN takes', () {
    expect(
      _keysOf('core/protocol.go', 'tunSchema', 'json'),
      const Tun().coreJson.keys.toSet(),
    );
  });
}
