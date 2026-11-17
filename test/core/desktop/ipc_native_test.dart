@TestOn('!windows')
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:fl_clash/core/desktop/ipc_auth.dart';
import 'package:fl_clash/core/desktop/transport.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../plugins/code_forge/support.dart' show initEditorNative;
import 'ipc_peer.dart';

const _wait = Duration(seconds: 5);
const _token = '0123456789abcdef0123456789abcdef';

Uint8List _frame(Object payload) {
  final bytes = payload is String ? utf8.encode(payload) : payload as List<int>;
  final header = ByteData(4)..setUint32(0, bytes.length, Endian.little);
  return Uint8List.fromList([...header.buffer.asUint8List(), ...bytes]);
}

final class _Frames {
  final StreamIterator<List<int>> _bytes;
  final List<int> _buffer = [];

  _Frames(Stream<List<int>> bytes) : _bytes = StreamIterator(bytes);

  Future<Uint8List> next() async {
    while (true) {
      if (_buffer.length >= 4) {
        final length = ByteData.sublistView(
          Uint8List.fromList(_buffer.sublist(0, 4)),
        ).getUint32(0, Endian.little);
        if (_buffer.length >= 4 + length) {
          final frame = Uint8List.fromList(_buffer.sublist(4, 4 + length));
          _buffer.removeRange(0, 4 + length);
          return frame;
        }
      }
      if (!await _bytes.moveNext().timeout(_wait)) {
        throw StateError('the transport closed the connection');
      }
      _buffer.addAll(_bytes.current);
    }
  }
}

void main() {
  late Directory directory;
  late String address;
  late IpcCoreTransport transport;

  setUpAll(initEditorNative);

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('ipc');
    address = '${directory.path}/core.sock';
    transport = IpcCoreTransport(address: address);
  });

  tearDown(() async {
    await transport.close();
    await directory.delete(recursive: true);
  });

  Future<Socket> connect() {
    return Socket.connect(
      InternetAddress(address, type: InternetAddressType.unix),
      0,
    );
  }

  test('a socket peer exchanges frames with the transport', () async {
    await transport.open();
    expect(
      FileSystemEntity.typeSync(address),
      FileSystemEntityType.unixDomainSock,
    );

    transport.expectSession(_token);
    final connected = transport.waitUntilConnected(_wait);
    final peer = await connect();
    final frames = _Frames(peer);
    final core = CoreHandshakePeer(_token);
    peer.add(_frame(core.opening()));
    peer.add(_frame(core.answer(await frames.next())));
    expect((await connected).generation, 1);

    final incoming = transport.frames.first.timeout(_wait);
    peer.add(_frame('ping'));
    expect(utf8.decode(await incoming), 'ping');

    transport.send(utf8.encode('pong'));
    expect(utf8.decode(await frames.next()), 'pong');

    final disconnected = transport.events
        .where((event) => event is TransportDisconnected)
        .cast<TransportDisconnected>()
        .first
        .timeout(_wait);
    peer.destroy();
    expect((await disconnected).generation, 1);
    expect(transport.state, DesktopTransportState.ready);

    await transport.close();
    expect(FileSystemEntity.typeSync(address), FileSystemEntityType.notFound);
  });

  test('a stale core that does not know the token is refused', () async {
    await transport.open();
    transport.expectSession(_token);
    final failure = transport.events
        .where((event) => event is TransportFailed)
        .cast<TransportFailed>()
        .first
        .timeout(_wait);
    final frames = <Uint8List>[];
    transport.frames.listen(frames.add);

    final peer = await connect();
    final received = _Frames(peer);
    final stale = CoreHandshakePeer('fedcba9876543210fedcba9876543210');
    peer.add(_frame(stale.opening()));
    await received.next();
    peer.add(_frame(Uint8List(32)));
    peer.add(_frame('{"jsonrpc":"2.0","id":1,"method":"core.stats"}'));

    expect((await failure).error, isA<IpcAuthException>());
    expect(transport.state, DesktopTransportState.failed);
    expect(frames, isEmpty);
    await expectLater(received.next(), throwsStateError);
    peer.destroy();
  });

  test(
    'a peer that sends no handshake is cut off and never answered',
    () async {
      final impatient = IpcCoreTransport(
        address: address,
        handshakeTimeout: const Duration(milliseconds: 200),
      );
      addTearDown(impatient.close);
      await impatient.open();
      impatient.expectSession(_token);
      final failure = impatient.events
          .where((event) => event is TransportFailed)
          .cast<TransportFailed>()
          .first
          .timeout(_wait);

      final peer = await connect();
      final received = _Frames(peer);

      expect((await failure).error.toString(), contains('did not answer'));
      await expectLater(received.next(), throwsStateError);
      peer.destroy();
    },
  );

  test(
    'a peer that opens with something other than a nonce is refused',
    () async {
      await transport.open();
      transport.expectSession(_token);
      final failure = transport.events
          .where((event) => event is TransportFailed)
          .cast<TransportFailed>()
          .first
          .timeout(_wait);

      final peer = await connect();
      final received = _Frames(peer);
      peer.add(_frame('{"jsonrpc":"2.0","id":1,"method":"core.hello"}'));

      expect((await failure).error, isA<IpcAuthException>());
      await expectLater(received.next(), throwsStateError);
      peer.destroy();
    },
  );

  test('the socket directory is created private to its owner', () async {
    final nested = '${directory.path}/runtime/core.sock';
    final private = IpcCoreTransport(address: nested);
    addTearDown(private.close);

    await private.open();

    final mode = FileStat.statSync('${directory.path}/runtime').mode & 0x1ff;
    expect(mode, 0x1c0);
  });

  test('a socket directory others can enter is refused', () async {
    final shared = Directory('${directory.path}/shared')..createSync();
    await Process.run('chmod', ['755', shared.path]);
    final unsafe = IpcCoreTransport(address: '${shared.path}/core.sock');
    addTearDown(unsafe.close);

    await expectLater(unsafe.open(), throwsA(anything));

    expect(unsafe.state, DesktopTransportState.failed);
  });

  test('sending without a peer is refused', () async {
    await transport.open();

    expect(
      () => transport.send(utf8.encode('early')),
      throwsA(contains('not connected')),
    );
  });

  test('an address that cannot be bound fails the transport', () async {
    final unbindable = IpcCoreTransport(
      address: '${directory.path}/missing/deeper/core.sock',
    );

    await expectLater(unbindable.open(), throwsA(anything));

    expect(unbindable.state, DesktopTransportState.failed);
    await unbindable.close();
  });
}
