import 'package:fl_clash/models/models.dart';
import 'package:test/test.dart';

import '../helpers/concord_config.dart';

void main() {
  final tunKeys = const Tun().toJson().keys.toSet();

  test('every Tun key is a key of the core TUN section', () {
    expect(concordKeys('tun'), containsAll(tunKeys));
  });

  test('a saved zero MTU or empty congestion control reads as the default', () {
    final tun = Tun.fromJson({'mtu': 0, 'congestion-controller': ''});

    expect(tun.mtu, defaultTunMtu);
    expect(tun.congestionController, defaultCongestionController);
  });

  test('a saved congestion control the core no longer offers reads as the '
      'default', () {
    expect(
      Tun.fromJson({'congestion-controller': 'bbr3'}).congestionController,
      defaultCongestionController,
    );
    expect(
      ProfileTun.fromJson({
        'congestion-controller': 'bbr3',
      }).congestionController,
      defaultCongestionController,
    );
    expect(
      ProfileTun.fromJson({
        'congestion-controller': 'bbr',
      }).congestionController,
      'bbr',
    );
  });

  test('a saved MTU outside what a TUN interface accepts is clamped', () {
    expect(Tun.fromJson({'mtu': 70000}).mtu, maxTunMtu);
    expect(Tun.fromJson({'mtu': 576}).mtu, minTunMtu);
    expect(Tun.fromJson({'mtu': 1500}).mtu, 1500);
  });

  test('the desktop TUN takes only its switch and device, routed', () {
    const tun = Tun(enable: true, mtu: 1400, routeAddress: ['1.0.0.0/8']);

    expect(tun.coreJson, {
      'enable': true,
      'device': tun.device,
      'auto-route': true,
    });
  });
}
