import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

/// Written independently of `IpcHandshake` so the two check each other.
final class CoreHandshakePeer {
  final List<int> _key;
  final Uint8List nonce;

  CoreHandshakePeer(String token, {int seed = 7})
    : _key = utf8.encode(token),
      nonce = Uint8List.fromList(List.generate(16, (i) => (seed + i) & 0xff));

  Uint8List opening() => nonce;

  List<int> _mac(int role, List<int> responder) {
    final data = <int>[
      ...utf8.encode('concord-ipc/1'),
      role,
      ...nonce,
      ...responder,
    ];
    return Hmac(sha256, _key).convert(data).bytes;
  }

  Uint8List answer(List<int> reply) {
    if (reply.length != 48) {
      throw StateError('the host reply is ${reply.length} bytes');
    }
    final responder = reply.sublist(0, 16);
    final claimed = reply.sublist(16);
    if (!_equal(claimed, _mac(2, responder))) {
      throw StateError('the host does not know the token');
    }
    return Uint8List.fromList(_mac(1, responder));
  }
}

bool _equal(List<int> a, List<int> b) {
  if (a.length != b.length) {
    return false;
  }
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) {
      return false;
    }
  }
  return true;
}
