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
    bool capturing = false,
  }) => [
    for (final item in navigation.getItems(
      openLogs: true,
      hasProxies: true,
      capturing: capturing,
    ))
      if (item.modes.contains(mode)) item.label,
  ];

  test('the desktop sidebar keeps connections right after proxies', () {
    for (final capturing in [false, true]) {
      expect(labelsFor(NavigationItemMode.desktop, capturing: capturing), [
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

  test('requests leaves the tools list for the mobile bar only while HTTP '
      'is captured', () {
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

    expect(labelsFor(NavigationItemMode.mobile, capturing: true), [
      PageLabel.dashboard,
      PageLabel.proxies,
      PageLabel.requests,
      PageLabel.profiles,
      PageLabel.tools,
    ]);
    expect(
      labelsFor(NavigationItemMode.moreFull, capturing: true),
      isNot(contains(PageLabel.requests)),
    );
  });
}
