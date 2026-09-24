import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

// [Clipboard] codes JSON on the UI isolate, tens of ms per megabyte.
const _inlineLimit = 1 << 16;
const _codec = JSONMethodCodec();

// One Binder call carries under 1 MiB and a clip takes a byte or more per
// UTF-16 unit, so Android is sure to refuse a clip this long.
const _androidLimit = 1 << 20;

// Reads and writes queue behind a large write still being coded.
Future<void>? _queue;

Future<bool> setClipboardText(String text) async {
  if (defaultTargetPlatform == TargetPlatform.android &&
      text.length >= _androidLimit) {
    return false;
  }
  try {
    await _setClipboardText(text);
    return true;
  } on Exception {
    return false;
  }
}

Future<void> _setClipboardText(String text) {
  final queue = _queue;
  if (queue == null && text.length < _inlineLimit) {
    return Clipboard.setData(ClipboardData(text: text));
  }
  final written = Completer<void>();
  _queue = written.future;
  return _write(queue, text).whenComplete(() {
    written.complete();
    if (identical(_queue, written.future)) _queue = null;
  });
}

Future<void> _write(Future<void>? after, String text) async {
  await after;
  if (text.length < _inlineLimit) {
    return Clipboard.setData(ClipboardData(text: text));
  }
  _decodeReply(await _send(await compute(_encodeSetData, text)));
}

Future<String?> getClipboardText() async {
  final queue = _queue;
  if (queue != null) await queue;
  final reply = await _send(
    _codec.encodeMethodCall(
      const MethodCall('Clipboard.getData', Clipboard.kTextPlain),
    ),
  );
  final result = reply != null && reply.lengthInBytes >= _inlineLimit
      ? await compute(_decodeReply, reply)
      : _decodeReply(reply);
  return (result as Map?)?['text'] as String?;
}

Future<ByteData?> _send(ByteData message) async {
  const channel = SystemChannels.platform;
  return await channel.binaryMessenger.send(channel.name, message);
}

ByteData _encodeSetData(String text) => _codec.encodeMethodCall(
  MethodCall('Clipboard.setData', <String, dynamic>{'text': text}),
);

Object? _decodeReply(ByteData? reply) {
  if (reply == null) {
    throw MissingPluginException(
      'No implementation found on channel ${SystemChannels.platform.name}',
    );
  }
  return _codec.decodeEnvelope(reply);
}
