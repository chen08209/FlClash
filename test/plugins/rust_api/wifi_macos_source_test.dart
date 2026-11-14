import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

String _body(String source, String start, String end) {
  final from = source.indexOf(start);
  expect(from, isNonNegative, reason: '$start is gone; update this test');
  final to = source.indexOf(end, from + start.length);
  return source.substring(from, to < 0 ? source.length : to);
}

void main() {
  late String source;

  setUpAll(() {
    source = File('plugins/rust_api/rust/src/wifi/macos.rs').readAsStringSync();
  });

  test('macOS reads the SSID off the main thread', () {
    final ssid = _body(source, 'pub async fn ssid()', '\n}\n');
    expect(
      ssid,
      contains('tokio::task::spawn_blocking'),
      reason: 'CoreWLAN reaches wifid over XPC and can stall the window',
    );
    expect(ssid, isNot(contains('on_main(')));
  });

  test('macOS skips CoreWLAN without the location permission on macOS 14+', () {
    final ssid = _body(source, 'pub async fn ssid()', 'spawn_blocking');
    expect(
      ssid,
      contains(
        'location_gated() && check_permission().await != '
        'WifiSsidPermission::Granted',
      ),
    );
    expect(source, contains('available!(macos = 14.0)'));
  });

  test('macOS lets a second permission request wait for the same answer', () {
    final request = _body(source, 'pub async fn request_permission()', '\n}\n');
    expect(request, contains('location.pending.push(sender)'));
  });

  test('macOS reports the location permission as granted below macOS 14', () {
    final grantedBelow14 = allOf(
      contains('if !location_gated() {'),
      contains('return WifiSsidPermission::Granted;'),
    );
    expect(
      _body(source, 'pub async fn check_permission()', '\n}\n'),
      grantedBelow14,
    );
    expect(
      _body(source, 'pub async fn request_permission()', '\n}\n'),
      grantedBelow14,
    );
  });
}
