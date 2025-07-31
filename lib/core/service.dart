import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/core/core.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/core.dart';

import 'interface.dart';

class CoreService extends CoreHandlerInterface {
  static CoreService? _instance;

  final Completer<ServerSocket> _serverCompleter = Completer();

  Completer<Socket> _socketCompleter = Completer();

  final Map<String, Completer> _callbackCompleterMap = {};

  Process? _process;

  factory CoreService() {
    _instance ??= CoreService._internal();
    return _instance!;
  }

  CoreService._internal() {
    _initServer();
  }

  Future<void> handleResult(ActionResult result) async {
    final completer = _callbackCompleterMap[result.id];
    final data = await parasResult(result);
    if (result.id?.isEmpty == true) {
      coreEventManager.sendEvent(CoreEvent.fromJson(result.data));
    }
    completer?.complete(data);
  }

  void _initServer() {
    runZonedGuarded(
      () async {
        final address = !system.isWindows
            ? InternetAddress(unixSocketPath, type: InternetAddressType.unix)
            : InternetAddress(localhost, type: InternetAddressType.IPv4);
        await _deleteSocketFile();
        final server = await ServerSocket.bind(address, 0, shared: true);
        _serverCompleter.complete(server);
        await for (final socket in server) {
          await _attachSocket(socket);
        }
      },
      (error, stack) async {
        commonPrint.log('Service error: $error');
      },
    );
  }

  Future<void> _attachSocket(Socket socket) async {
    await _destroySocket();
    _socketCompleter.complete(socket);
    socket
        .transform(uint8ListToListIntConverter)
        .transform(utf8.decoder)
        .transform(LineSplitter())
        .listen((data) {
          handleResult(ActionResult.fromJson(json.decode(data.trim())));
        })
        .onDone(() {
          _handleInvokeCrashEvent();
        });
  }

  void _handleInvokeCrashEvent() {
    coreEventManager.sendEvent(
      CoreEvent(type: CoreEventType.crash, data: 'socket done'),
    );
  }

  Future<void> start() async {
    if (_process != null) {
      await shutdown();
    }
    final serverSocket = await _serverCompleter.future;
    final arg = system.isWindows
        ? '${serverSocket.port}'
        : serverSocket.address.address;
    if (system.isWindows && await system.checkIsAdmin()) {
      final isSuccess = await request.startCoreByHelper(arg);
      if (isSuccess) {
        return;
      }
    }
    _process = await Process.start(appPath.corePath, [arg]);
    _process?.stdout.listen((_) {});
    _process?.stderr.listen((e) {
      final error = utf8.decode(e);
      if (error.isNotEmpty) {
        commonPrint.log(error);
      }
    });
  }

  @override
  destroy() async {
    final server = await _serverCompleter.future;
    await server.close();
    await _deleteSocketFile();
    return true;
  }

  Future<void> sendMessage(String message) async {
    final socket = await _socketCompleter.future;
    socket.writeln(message);
  }

  Future<void> _deleteSocketFile() async {
    if (!system.isWindows) {
      final file = File(unixSocketPath);
      if (await file.exists()) {
        await file.delete();
      }
    }
  }

  Future<void> _destroySocket() async {
    if (_socketCompleter.isCompleted) {
      final lastSocket = await _socketCompleter.future;
      _socketCompleter = Completer();
      lastSocket.close();
    }
  }

  @override
  shutdown() async {
    await _destroySocket();
    _clearCompleter();
    if (system.isWindows) {
      await request.stopCoreByHelper();
    }
    _process?.kill();
    _process = null;
    return true;
  }

  void _clearCompleter() {
    for (final completer in _callbackCompleterMap.values) {
      completer.safeCompleter(null);
    }
  }

  @override
  Future<String> preload() async {
    await _serverCompleter.future;
    await start();
    return '';
  }

  @override
  Future<T?> invoke<T>({
    required ActionMethod method,
    dynamic data,
    Duration? timeout,
  }) async {
    final id = '${method.name}#${utils.id}';
    _callbackCompleterMap[id] = Completer<T?>();
    sendMessage(json.encode(Action(id: id, method: method, data: data)));
    return (_callbackCompleterMap[id] as Completer<T?>).future.withTimeout(
      timeout: timeout,
      onLast: () {
        final completer = _callbackCompleterMap[id];
        completer?.safeCompleter(null);
        _callbackCompleterMap.remove(id);
      },
      tag: id,
      onTimeout: () => null,
    );
  }

  @override
  Future get connected => _socketCompleter.future;
}

final coreService = system.isDesktop ? CoreService() : null;
