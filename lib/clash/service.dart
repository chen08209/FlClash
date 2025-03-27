import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:fl_clash/clash/interface.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/models/core.dart';
import 'package:fl_clash/state.dart';

class ClashService extends ClashHandlerInterface {
  static ClashService? _instance;

  Completer<ServerSocket> serverCompleter = Completer();

  Completer<Socket> socketCompleter = Completer();

  bool isStarting = false;

  Process? process;

  factory ClashService() {
    _instance ??= ClashService._internal();
    return _instance!;
  }

  ClashService._internal() {
    _initServer();
    reStart();
  }

  _initServer() async {
    runZonedGuarded(() async {
      final address = !Platform.isWindows
          ? InternetAddress(
              unixSocketPath,
              type: InternetAddressType.unix,
            )
          : InternetAddress(
              localhost,
              type: InternetAddressType.IPv4,
            );
      await _deleteSocketFile();
      final server = await ServerSocket.bind(
        address,
        0,
        shared: true,
      );
      serverCompleter.complete(server);
      await for (final socket in server) {
        await _destroySocket();
        socketCompleter.complete(socket);
        socket
            .transform(
              StreamTransformer<Uint8List, String>.fromHandlers(
                handleData: (Uint8List data, EventSink<String> sink) {
                  sink.add(utf8.decode(data, allowMalformed: true));
                },
              ),
            )
            .transform(LineSplitter())
            .listen(
              (data) {
                handleResult(
                  ActionResult.fromJson(
                    json.decode(data.trim()),
                  ),
                );
              },
            );
      }
    }, (error, stack) {
      commonPrint.log(error.toString());
      if(error is SocketException){
        globalState.showNotifier(error.toString());
        globalState.appController.restartCore();
      }
    });
  }

  @override
  reStart() async {
    if (isStarting == true) {
      return;
    }
    isStarting = true;
    socketCompleter = Completer();
    if (process != null) {
      await shutdown();
    }
    final serverSocket = await serverCompleter.future;
    final arg = Platform.isWindows
        ? "${serverSocket.port}"
        : serverSocket.address.address;
    bool isSuccess = false;
    if (Platform.isWindows && await system.checkIsAdmin()) {
      isSuccess = await request.startCoreByHelper(arg);
    }
    if (isSuccess) {
      return;
    }
    process = await Process.start(
      appPath.corePath,
      [
        arg,
      ],
    );
    process!.stdout.listen((_) {});
    isStarting = false;
  }

  @override
  destroy() async {
    final server = await serverCompleter.future;
    await server.close();
    await _deleteSocketFile();
    return true;
  }

  @override
  sendMessage(String message) async {
    final socket = await socketCompleter.future;
    socket.writeln(message);
  }

  _deleteSocketFile() async {
    if (!Platform.isWindows) {
      final file = File(unixSocketPath);
      if (await file.exists()) {
        await file.delete();
      }
    }
  }

  _destroySocket() async {
    if (socketCompleter.isCompleted) {
      final lastSocket = await socketCompleter.future;
      await lastSocket.close();
      socketCompleter = Completer();
    }
  }

  @override
  shutdown() async {
    if (Platform.isWindows) {
      await request.stopCoreByHelper();
    }
    await _destroySocket();
    process?.kill();
    process = null;
    return true;
  }

  @override
  Future<bool> preload() async {
    await serverCompleter.future;
    return true;
  }
}

final clashService = system.isDesktop ? ClashService() : null;
