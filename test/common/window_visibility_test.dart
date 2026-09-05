import 'dart:async';

import 'package:fl_clash/common/window.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeNativeWindow {
  final List<String> calls = [];
  bool visible = true;
  Completer<void>? hideGate;

  WindowVisibilityController controller({
    Duration dockSettleDuration = const Duration(seconds: 1),
  }) {
    return WindowVisibilityController(
      showWindow: () async {
        calls.add('show');
        visible = true;
      },
      hideWindow: () async {
        calls.add('hide');
        await hideGate?.future;
        visible = false;
      },
      isWindowVisible: () async => visible,
      setSkipTaskbar: (skip) async {
        calls.add(skip ? 'dock:off' : 'dock:on');
      },
      dockSettleDuration: dockSettleDuration,
    );
  }
}

void main() {
  testWidgets('a hide right after a show waits for the Dock policy to settle', (
    tester,
  ) async {
    final native = _FakeNativeWindow()..visible = false;
    final controller = native.controller();

    unawaited(controller.show());
    await controller.hide();

    expect(native.calls, ['show', 'dock:on', 'hide']);

    await tester.pump(const Duration(milliseconds: 999));
    expect(native.calls, ['show', 'dock:on', 'hide']);

    await tester.pump(const Duration(milliseconds: 1));
    expect(native.calls, ['show', 'dock:on', 'hide', 'dock:off']);
  });

  testWidgets(
    'a show during the settle window cancels the deferred Dock hide',
    (tester) async {
      final native = _FakeNativeWindow()..visible = false;
      final controller = native.controller();

      unawaited(controller.show());
      unawaited(controller.hide());
      await controller.show();
      await tester.pump(const Duration(seconds: 2));

      expect(native.calls, ['show', 'dock:on', 'hide', 'show', 'dock:on']);
      expect(native.visible, isTrue);
    },
  );

  testWidgets('a hide outside the settle window switches the Dock at once', (
    tester,
  ) async {
    final native = _FakeNativeWindow()..visible = false;
    final controller = native.controller();

    await controller.show();
    await tester.pump(const Duration(seconds: 1));
    await controller.hide();

    expect(native.calls, ['show', 'dock:on', 'hide', 'dock:off']);
  });

  test('a zero settle duration never defers the Dock switch', () async {
    final native = _FakeNativeWindow()..visible = false;
    final controller = native.controller(dockSettleDuration: Duration.zero);

    unawaited(controller.show());
    await controller.hide();

    expect(native.calls, ['show', 'dock:on', 'hide', 'dock:off']);
  });

  testWidgets('rapid toggles run one at a time and flip parity each press', (
    tester,
  ) async {
    final native = _FakeNativeWindow();
    native.hideGate = Completer<void>();
    final controller = native.controller();

    unawaited(controller.toggle());
    unawaited(controller.toggle());
    final last = controller.toggle();
    await tester.pump();

    expect(native.calls, ['hide']);

    native.hideGate!.complete();
    native.hideGate = null;
    await last;
    await tester.pump(const Duration(seconds: 2));

    expect(native.calls, [
      'hide',
      'dock:off',
      'show',
      'dock:on',
      'hide',
      'dock:off',
    ]);
    expect(native.visible, isFalse);
  });

  test('an idle controller starts a request without waiting a tick', () {
    final native = _FakeNativeWindow()..visible = false;
    final controller = native.controller(dockSettleDuration: Duration.zero);

    unawaited(controller.show());

    expect(native.calls, ['show']);
  });

  test('a failed step does not block later requests', () async {
    var failShow = true;
    final calls = <String>[];
    final controller = WindowVisibilityController(
      showWindow: () async {
        if (failShow) {
          throw StateError('show failed');
        }
        calls.add('show');
      },
      hideWindow: () async => calls.add('hide'),
      isWindowVisible: () async => false,
      setSkipTaskbar: (skip) async => calls.add(skip ? 'dock:off' : 'dock:on'),
      dockSettleDuration: Duration.zero,
    );

    await expectLater(controller.show(), throwsStateError);
    failShow = false;
    await controller.hide();
    await controller.show();

    expect(calls, ['hide', 'dock:off', 'show', 'dock:on']);
  });
}
