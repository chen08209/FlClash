import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rust_api/tray.dart';

import '../../helpers/fake_tray_host.dart';

const _asset = 'assets/images/tray/unix/status_1.png';

TraySpec _spec({
  String asset = _asset,
  String toolTip = 'FlClash',
  List<TrayMenuItem> menu = const [],
}) {
  return TraySpec(icon: TrayIcon.asset(asset), toolTip: toolTip, menu: menu);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeTrayHost host;

  setUp(() {
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;
    host = FakeTrayHost();
    Tray.instance.resetForTesting(host);
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler('flutter/assets', null);
    Tray.fileExists = (filePath) => false;
    debugDefaultTargetPlatformOverride = null;
  });

  Future<void> select(int id) async {
    host.emit(TraySignalKind.itemSelected, id);
    await Future<void>.delayed(Duration.zero);
  }

  group('menu encoding', () {
    test('assigns ids in pre-order starting at the first id', () async {
      await Tray.instance.show(
        _spec(
          menu: const [
            TrayMenuAction(label: 'a'),
            TrayMenuSubmenu(
              label: 'group',
              items: [
                TrayMenuAction(label: 'child'),
                TrayMenuAction(label: 'other'),
              ],
            ),
            TrayMenuAction(label: 'b'),
          ],
        ),
      );

      final top = host.lastShown!.menu;
      expect(top.map((item) => item.id), [1024, 1025, 1028]);
      expect(top[1].items.map((item) => item.id), [1026, 1027]);
    });

    test('a detail travels only when it has text', () async {
      await Tray.instance.show(
        _spec(
          menu: const [
            TrayMenuAction(label: 'a', detail: '⌃⌥S'),
            TrayMenuCheckbox(label: 'b', checked: true, detail: '88 ms'),
            TrayMenuSubmenu(label: 'c', detail: 'HK', items: []),
            TrayMenuAction(label: 'd'),
            TrayMenuAction(label: 'e', detail: ''),
          ],
        ),
      );

      expect(host.lastShown!.menu.map((item) => item.detail), [
        '⌃⌥S',
        '88 ms',
        'HK',
        null,
        null,
      ]);
    });

    test('kinds and checked state reach the host', () async {
      await Tray.instance.show(
        _spec(
          menu: const [
            TrayMenuCheckbox(label: 'a', checked: true),
            TrayMenuSeparator(),
            TrayMenuAction(label: 'b', enabled: false),
          ],
        ),
      );

      final menu = host.lastShown!.menu;
      expect(menu.map((item) => item.kind), [
        TrayItemKind.checkbox,
        TrayItemKind.separator,
        TrayItemKind.action,
      ]);
      expect(menu[0].checked, isTrue);
      expect(menu[2].enabled, isFalse);
    });
  });

  group('unchanged payloads', () {
    test('a rebuilt menu with new callbacks is not shown again', () async {
      await Tray.instance.show(
        _spec(
          menu: [TrayMenuAction(label: 'a', onSelected: () {})],
        ),
      );
      await Tray.instance.show(
        _spec(
          menu: [TrayMenuAction(label: 'a', onSelected: () {})],
        ),
      );

      expect(host.shown, hasLength(1));
    });

    for (final (name, changed) in <(String, TraySpec)>[
      (
        'checked state',
        _spec(menu: const [TrayMenuCheckbox(label: 'a', checked: true)]),
      ),
      (
        'label',
        _spec(menu: const [TrayMenuCheckbox(label: 'b', checked: false)]),
      ),
      (
        'detail',
        _spec(
          menu: const [
            TrayMenuCheckbox(label: 'a', checked: false, detail: '1'),
          ],
        ),
      ),
      (
        'tooltip',
        _spec(
          toolTip: 'other',
          menu: const [TrayMenuCheckbox(label: 'a', checked: false)],
        ),
      ),
      (
        'icon',
        _spec(
          asset: 'assets/other.png',
          menu: const [TrayMenuCheckbox(label: 'a', checked: false)],
        ),
      ),
    ]) {
      test('a changed $name is shown again', () async {
        await Tray.instance.show(
          _spec(menu: const [TrayMenuCheckbox(label: 'a', checked: false)]),
        );
        await Tray.instance.show(changed);

        expect(host.shown, hasLength(2));
      });
    }

    test('a rejected show stays invisible and is retried', () async {
      host.showResult = false;
      await Tray.instance.show(_spec());

      expect(host.shown, hasLength(1));
      expect(Tray.instance.isVisible, isFalse);

      host.showResult = true;
      await Tray.instance.show(_spec());

      expect(host.shown, hasLength(2));
      expect(Tray.instance.isVisible, isTrue);
    });

    test('suppression starts only after an accepted show', () async {
      await Tray.instance.show(_spec());
      await Tray.instance.show(_spec());
      expect(host.shown, hasLength(1));

      host.showResult = false;
      await Tray.instance.show(_spec(menu: const [TrayMenuAction(label: 'a')]));
      await Tray.instance.show(_spec(menu: const [TrayMenuAction(label: 'a')]));
      expect(host.shown, hasLength(3));
    });
  });

  group('selection', () {
    test('dispatches only for ids of the current menu', () async {
      var selected = 0;
      await Tray.instance.show(
        _spec(
          menu: [TrayMenuAction(label: 'a', onSelected: () => selected++)],
        ),
      );

      await select(1024);
      expect(selected, 1);

      await select(4096);
      expect(selected, 1);
    });

    test('a rejected show keeps callbacks for the visible menu', () async {
      var oldSelected = 0;
      var newSelected = 0;
      await Tray.instance.show(
        _spec(
          menu: [TrayMenuAction(label: 'old', onSelected: () => oldSelected++)],
        ),
      );

      host.showResult = false;
      await Tray.instance.show(
        _spec(
          menu: [TrayMenuAction(label: 'new', onSelected: () => newSelected++)],
        ),
      );
      await select(1024);

      expect([oldSelected, newSelected], [1, 0]);
    });

    test(
      'an unchanged show refreshes callbacks without a native show',
      () async {
        var oldSelected = 0;
        var newSelected = 0;
        await Tray.instance.show(
          _spec(
            menu: [
              TrayMenuAction(label: 'item', onSelected: () => oldSelected++),
            ],
          ),
        );
        await Tray.instance.show(
          _spec(
            menu: [
              TrayMenuAction(label: 'item', onSelected: () => newSelected++),
            ],
          ),
        );
        await select(1024);

        expect(host.shown, hasLength(1));
        expect([oldSelected, newSelected], [0, 1]);
      },
    );

    test(
      'selection follows the per-item callback with a stream event',
      () async {
        final order = <String>[];
        final subscription = Tray.instance.events.listen((event) {
          if (event is TrayMenuItemSelected) {
            order.add('event');
          }
        });
        addTearDown(subscription.cancel);
        await Tray.instance.show(
          _spec(
            menu: [
              TrayMenuAction(
                label: 'a',
                onSelected: () => order.add('callback'),
              ),
            ],
          ),
        );

        await select(1024);

        expect(order, ['callback', 'event']);
      },
    );
  });

  test('hide reaches the host once and is idempotent', () async {
    await Tray.instance.show(_spec());
    await Tray.instance.hide();
    await Tray.instance.hide();

    expect(host.hideCount, 1);
    expect(Tray.instance.isVisible, isFalse);
  });

  test('titles queued behind a stalled call collapse to the newest', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
    final gate = Completer<void>();
    var stall = false;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler('flutter/assets', (message) async {
          if (stall) {
            await gate.future;
          }
          return ByteData.sublistView(Uint8List.fromList([1]));
        });
    await Tray.instance.show(_spec());

    stall = true;
    final stalled = Tray.instance.show(
      _spec(menu: const [TrayMenuAction(label: 'a')]),
    );
    unawaited(Tray.instance.setTitle('1'));
    unawaited(Tray.instance.setTitle('2'));
    final settled = Tray.instance.setTitle('3');
    gate.complete();
    await stalled;
    await settled;

    expect(
      host.titles,
      ['3'],
      reason:
          'a call that blocks the queue must not replay every title that '
          'piled up behind it',
    );
  });

  group('icons', () {
    test('variant assets follow the Flutter resolution layout', () {
      expect(Tray.variantAsset(_asset, 1.0), _asset);
      expect(
        Tray.variantAsset(_asset, 2.0),
        'assets/images/tray/unix/2.0x/status_1.png',
      );
      expect(Tray.variantAsset('status_1.png', 3.0), '3.0x/status_1.png');
    });

    test('linux hands the item the largest bundled variant', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.linux;
      Tray.fileExists = (filePath) => filePath.contains('/3.0x/');

      await Tray.instance.show(_spec());

      expect(
        host.lastShown!.image.path,
        endsWith('flutter_assets/assets/images/tray/unix/3.0x/status_1.png'),
      );
    });

    test('linux falls back to the base asset without variants', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.linux;

      await Tray.instance.show(_spec());

      expect(
        host.lastShown!.image.path,
        endsWith('flutter_assets/assets/images/tray/unix/status_1.png'),
      );
    });

    test('macOS sends every bundled scale as a representation', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
      final bundled = {
        _asset: [1],
        'assets/images/tray/unix/2.0x/status_1.png': [2, 2],
      };
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMessageHandler('flutter/assets', (message) async {
            final bytes = bundled[utf8.decode(message!.buffer.asUint8List())];
            return bytes == null
                ? null
                : ByteData.sublistView(Uint8List.fromList(bytes));
          });

      await Tray.instance.show(
        const TraySpec(icon: TrayIcon.asset(_asset, isTemplate: true)),
      );

      final image = host.lastShown!.image;
      expect(image.pngs, [
        [1],
        [2, 2],
      ]);
      expect(image.template, isTrue);
      expect(image.path, isEmpty);
    });
  });
}
