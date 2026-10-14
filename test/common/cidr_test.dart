import 'package:fl_clash/common/cidr.dart';
import 'package:fl_clash/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('cuts a block out of a range as the fewest covering blocks', () {
    expect(subtractCidrs(['0.0.0.0/0'], ['10.0.0.0/8']), [
      '0.0.0.0/5',
      '8.0.0.0/7',
      '11.0.0.0/8',
      '12.0.0.0/6',
      '16.0.0.0/4',
      '32.0.0.0/3',
      '64.0.0.0/2',
      '128.0.0.0/1',
    ]);
  });

  test('a family without an included block counts as whole on request', () {
    expect(
      subtractCidrs(['10.0.0.0/8'], ['10.1.0.0/16']),
      isNot(contains('::/0')),
    );
    expect(subtractCidrs(['10.0.0.0/8'], const [], wholeWhenEmpty: true), [
      '10.0.0.0/8',
      '::/0',
    ]);
  });

  test('a CIDR is read as strictly as the core reads a prefix', () {
    for (final value in [
      '192.168.1.5/24',
      '0.0.0.0/0',
      'fd00::/8',
      '::ffff:1.2.3.4/96',
    ]) {
      expect(isCidr(value), isTrue, reason: value);
    }
    for (final value in [
      '192.168.1.5',
      '192.168.1.0/33',
      '192.168.01.0/24',
      '192.168.1.0/024',
      ' 10.0.0.0/8',
      '10.0.0.0/8 ',
      '10.0.0/8',
      'fe80::1%eth0/64',
      'fd00::/129',
    ]) {
      expect(isCidr(value), isFalse, reason: value);
    }
  });

  test('merges overlapping blocks and ignores what does not parse', () {
    expect(subtractCidrs(['10.0.0.0/8', 'bad', '10.1.0.0/16'], const []), [
      '10.0.0.0/8',
    ]);
  });

  test('bypassing private ranges covers exactly the rest of both families', () {
    final routes = subtractCidrs(
      const [],
      privateRouteAddress,
      wholeWhenEmpty: true,
    );

    expect(routes, hasLength(82));
    expect(subtractCidrs(privateRouteAddress, routes), privateRouteAddress);
    expect(
      subtractCidrs(
        const ['0.0.0.0/0', '::/0'],
        [...routes, ...privateRouteAddress],
      ),
      isEmpty,
    );
  });

  test('an include list wholly excluded leaves that family unrouted', () async {
    final routes = await const Tun(
      routeAddress: ['192.168.1.0/24'],
    ).vpnRouteAddress(bypassPrivateRoute: true);

    expect(routes, isNotEmpty);
    expect(routes.where((route) => !route.contains(':')), isEmpty);
    expect(
      await const Tun().vpnRouteAddress(bypassPrivateRoute: false),
      isEmpty,
    );
  });

  test('the task subtracts as the function does', () async {
    const include = ['10.0.0.0/8', '2001:db8::/32'];
    const exclude = ['10.1.0.0/16', '2001:db8:1::/48'];

    expect(
      await subtractCidrsTask(include, exclude, wholeWhenEmpty: true),
      subtractCidrs(include, exclude, wholeWhenEmpty: true),
    );
  });
}
