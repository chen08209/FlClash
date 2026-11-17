import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

const _nonceLength = 16;
const _proofLength = 32;
const _label = 'concord-ipc/1';
const _initiatorRole = 1;
const _responderRole = 2;

final class IpcAuthException implements Exception {
  final String message;

  const IpcAuthException(this.message);

  @override
  String toString() => 'IpcAuthException: $message';
}

/// The listening side of the Core's handshake: the Core dials and speaks first.
/// The token keys the proofs and is never sent.
final class IpcHandshake {
  final List<int> _key;
  final Random _random;
  Uint8List? _initiatorNonce;
  Uint8List? _responderNonce;
  bool _complete = false;

  IpcHandshake(String token, {Random? random})
    : _key = utf8.encode(token),
      _random = random ?? Random.secure();

  bool get isComplete => _complete;

  Uint8List? receive(List<int> frame) {
    if (_complete) {
      throw const IpcAuthException('handshake already complete');
    }
    final initiator = _initiatorNonce;
    if (initiator == null) {
      if (frame.length != _nonceLength) {
        throw const IpcAuthException('the peer did not open with a nonce');
      }
      final ours = Uint8List.fromList(
        List<int>.generate(_nonceLength, (_) => _random.nextInt(256)),
      );
      _initiatorNonce = Uint8List.fromList(frame);
      _responderNonce = ours;
      return Uint8List.fromList([
        ...ours,
        ..._proof(_responderRole, _initiatorNonce!, ours),
      ]);
    }
    if (frame.length != _proofLength) {
      throw const IpcAuthException('the peer sent a malformed proof');
    }
    final expected = _proof(_initiatorRole, initiator, _responderNonce!);
    if (!_constantTimeEquals(expected, frame)) {
      throw const IpcAuthException('the peer does not know the session token');
    }
    _complete = true;
    return null;
  }

  List<int> _proof(int role, List<int> initiator, List<int> responder) {
    final data = BytesBuilder(copy: false)
      ..add(utf8.encode(_label))
      ..addByte(role)
      ..add(initiator)
      ..add(responder);
    return Hmac(sha256, _key).convert(data.takeBytes()).bytes;
  }
}

bool _constantTimeEquals(List<int> expected, List<int> actual) {
  var difference = expected.length ^ actual.length;
  for (var index = 0; index < expected.length; index++) {
    final other = index < actual.length ? actual[index] : 0;
    difference |= expected[index] ^ other;
  }
  return difference == 0;
}
