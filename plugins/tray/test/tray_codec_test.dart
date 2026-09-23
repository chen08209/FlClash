import 'package:flutter_test/flutter_test.dart';
import 'package:tray/src/tray_codec.dart';
import 'package:tray/tray.dart';

TraySpec _spec({
  String asset = 'assets/icon.png',
  String toolTip = 'FlClash',
  List<TrayMenuItem> menu = const [],
}) {
  return TraySpec(icon: TrayIcon.asset(asset), toolTip: toolTip, menu: menu);
}

void main() {
  test('assigns ids in pre-order starting at the first id', () {
    final encoded = TrayCodec.encode(
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

    final top = encoded.menu.cast<Map<String, Object?>>();
    expect(top.map((item) => item['id']), [1024, 1025, 1028]);

    final children = (top[1]['items']! as List).cast<Map<String, Object?>>();
    expect(children.map((item) => item['id']), [1026, 1027]);
    expect(encoded.itemsById.keys, [1024, 1025, 1026, 1027, 1028]);
  });

  test('resolves every dispatchable id back to its item', () {
    const action = TrayMenuAction(label: 'a');
    const checkbox = TrayMenuCheckbox(label: 'b', checked: true);
    final encoded = TrayCodec.encode(_spec(menu: const [action, checkbox]));

    expect(encoded.itemsById[1024], same(action));
    expect(encoded.itemsById[1025], same(checkbox));
  });

  test('signature ignores callback identity', () {
    String signatureWith(void Function() onSelected) {
      return TrayCodec.encode(
        _spec(
          menu: [TrayMenuAction(label: 'a', onSelected: onSelected)],
        ),
      ).signature;
    }

    expect(signatureWith(() {}), signatureWith(() {}));
  });

  test('signature tracks label, checked state, tooltip and icon', () {
    final base = TrayCodec.encode(
      _spec(menu: const [TrayMenuCheckbox(label: 'a', checked: false)]),
    ).signature;

    expect(
      TrayCodec.encode(
        _spec(menu: const [TrayMenuCheckbox(label: 'a', checked: true)]),
      ).signature,
      isNot(base),
    );
    expect(
      TrayCodec.encode(
        _spec(menu: const [TrayMenuCheckbox(label: 'b', checked: false)]),
      ).signature,
      isNot(base),
    );
    expect(
      TrayCodec.encode(
        _spec(
          toolTip: 'other',
          menu: const [TrayMenuCheckbox(label: 'a', checked: false)],
        ),
      ).signature,
      isNot(base),
    );
    expect(
      TrayCodec.encode(
        _spec(
          asset: 'assets/other.png',
          menu: const [TrayMenuCheckbox(label: 'a', checked: false)],
        ),
      ).signature,
      isNot(base),
    );
  });

  test('separators serialize without label or state', () {
    final encoded = TrayCodec.encode(_spec(menu: const [TrayMenuSeparator()]));

    expect(encoded.menu.single, {'id': 1024, 'type': 'separator'});
  });
}
