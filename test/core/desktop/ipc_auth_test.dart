import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:fl_clash/core/desktop/ipc_auth.dart';
import 'package:flutter_test/flutter_test.dart';

import 'ipc_peer.dart';

const _token = '0123456789abcdef0123456789abcdef';

String _hex(List<int> bytes) =>
    bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();

class _Counting implements Random {
  int next = 17;

  @override
  int nextInt(int max) => next++ & 0xff;

  @override
  bool nextBool() => false;

  @override
  double nextDouble() => 0;
}

void main() {
  test('the host proof matches the vector the Rust initiator pins', () {
    final host = IpcHandshake(_token, random: _Counting());
    final opening = Uint8List.fromList(List.generate(16, (i) => i + 1));

    final reply = host.receive(opening)!;

    expect(reply.sublist(0, 16), List.generate(16, (i) => i + 17));
    expect(
      _hex(reply.sublist(16)),
      '0e9ebf29efd273e966ce128e3f6adb19a7e52b419e7c32a3d21c940e145fa56f',
    );
    final proof = Uint8List.fromList(
      hexDecode(
        '4c1b89365b44dc2258ad724caeb98ec37695a565e62e82b5ccc57574d95be7a7',
      ),
    );
    expect(host.receive(proof), isNull);
    expect(host.isComplete, isTrue);
  });

  test('a Core with the same token completes the handshake', () {
    final host = IpcHandshake(_token);
    final core = CoreHandshakePeer(_token);

    final reply = host.receive(core.opening())!;
    expect(host.isComplete, isFalse);
    expect(host.receive(core.answer(reply)), isNull);

    expect(host.isComplete, isTrue);
    expect(() => host.receive(Uint8List(32)), throwsA(isA<IpcAuthException>()));
  });

  test('a Core with another token is refused', () {
    final host = IpcHandshake(_token);
    final core = CoreHandshakePeer('fedcba9876543210fedcba9876543210');

    final reply = host.receive(core.opening())!;

    expect(() => core.answer(reply), throwsStateError);
    final forged = Uint8List(32);
    expect(() => host.receive(forged), throwsA(isA<IpcAuthException>()));
    expect(host.isComplete, isFalse);
  });

  test('a replayed host reply is not an initiator proof', () {
    final host = IpcHandshake(_token);
    final core = CoreHandshakePeer(_token);
    final reply = host.receive(core.opening())!;

    expect(
      () => host.receive(reply.sublist(16)),
      throwsA(isA<IpcAuthException>()),
    );
  });

  test('anything but a nonce or a proof in the expected place is refused', () {
    expect(
      () =>
          IpcHandshake(_token).receive(utf8.encode('{"method":"core.hello"}')),
      throwsA(isA<IpcAuthException>()),
    );
    final host = IpcHandshake(_token)..receive(Uint8List(16));
    expect(() => host.receive(Uint8List(31)), throwsA(isA<IpcAuthException>()));
  });

  test('the reply carries a fresh nonce and never the token', () {
    final first = IpcHandshake(_token).receive(Uint8List(16))!;
    final second = IpcHandshake(_token).receive(Uint8List(16))!;

    expect(first.sublist(0, 16), isNot(second.sublist(0, 16)));
    expect(utf8.decode(first, allowMalformed: true), isNot(contains(_token)));
  });

  test('an error message never contains the token', () {
    final host = IpcHandshake(_token)..receive(Uint8List(16));

    try {
      host.receive(Uint8List(32));
      fail('expected a refusal');
    } on IpcAuthException catch (error) {
      expect(error.toString(), isNot(contains(_token)));
    }
  });
}

List<int> hexDecode(String text) => [
  for (var i = 0; i < text.length; i += 2)
    int.parse(text.substring(i, i + 2), radix: 16),
];
