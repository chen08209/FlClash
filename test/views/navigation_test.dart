import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/views/navigation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('no navigation view carries a global key of its own', (
    tester,
  ) async {
    late BuildContext context;
    await tester.pumpWidget(
      Builder(
        builder: (value) {
          context = value;
          return const SizedBox();
        },
      ),
    );

    final items = navigation.getItems(openLogs: true, hasProxies: true);

    for (final item in items) {
      expect(item.builder(context).key, isNot(isA<GlobalKey>()));
    }
  });

  List<PageLabel> labelsFor(
    NavigationItemMode mode, {
    bool decrypting = false,
  }) => [
    for (final item in navigation.getItems(
      openLogs: true,
      hasProxies: true,
      decrypting: decrypting,
    ))
      if (item.modes.contains(mode)) item.label,
  ];

  test('the desktop sidebar keeps connections right after proxies', () {
    for (final decrypting in [false, true]) {
      expect(labelsFor(NavigationItemMode.desktop, decrypting: decrypting), [
        PageLabel.dashboard,
        PageLabel.proxies,
        PageLabel.requests,
        PageLabel.profiles,
        PageLabel.tools,
      ]);
    }
  });

  test('logs open from the tools list alone', () {
    for (final mode in NavigationItemMode.values) {
      expect(
        labelsFor(mode).contains(PageLabel.logs),
        mode == NavigationItemMode.more,
        reason: '$mode',
      );
    }
  });

  test('connections leaves the tools list for the mobile bar only while '
      'HTTPS is decrypted', () {
    expect(labelsFor(NavigationItemMode.mobile), [
      PageLabel.dashboard,
      PageLabel.proxies,
      PageLabel.profiles,
      PageLabel.tools,
    ]);
    expect(
      labelsFor(NavigationItemMode.moreFull),
      contains(PageLabel.requests),
    );

    expect(labelsFor(NavigationItemMode.mobile, decrypting: true), [
      PageLabel.dashboard,
      PageLabel.proxies,
      PageLabel.requests,
      PageLabel.profiles,
      PageLabel.tools,
    ]);
    expect(
      labelsFor(NavigationItemMode.moreFull, decrypting: true),
      isNot(contains(PageLabel.requests)),
    );
  });
}
