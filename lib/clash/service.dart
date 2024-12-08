import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:fl_clash/clash/clash.dart';
import 'package:fl_clash/clash/interface.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/core.dart';

class ClashService with ClashInterface {
  static ClashService? _instance;

  Completer<ServerSocket> serverCompleter = Completer();

  Completer<Socket> socketCompleter = Completer();

  Map<String, Completer> callbackCompleterMap = {};

  Process? process;

  factory ClashService() {
    _instance ??= ClashService._internal();
    return _instance!;
  }

  ClashService._internal() {
    _createServer();
    startCore();
  }

  _createServer() async {
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
              _handleAction(
                Action.fromJson(
                  json.decode(data.trim()),
                ),
              );
            },
          );
    }
  }

  startCore() async {
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

  _handleAction(Action action) {
    final completer = callbackCompleterMap[action.id];
    switch (action.method) {
      case ActionMethod.initClash:
      case ActionMethod.shutdown:
      case ActionMethod.getIsInit:
      case ActionMethod.startListener:
      case ActionMethod.resetTraffic:
      case ActionMethod.closeConnections:
      case ActionMethod.closeConnection:
      case ActionMethod.stopListener:
        completer?.complete(action.data as bool);
        return;
      case ActionMethod.changeProxy:
      case ActionMethod.getProxies:
      case ActionMethod.getTraffic:
      case ActionMethod.getTotalTraffic:
      case ActionMethod.asyncTestDelay:
      case ActionMethod.getConnections:
      case ActionMethod.getExternalProviders:
      case ActionMethod.getExternalProvider:
      case ActionMethod.validateConfig:
      case ActionMethod.updateConfig:
      case ActionMethod.updateGeoData:
      case ActionMethod.updateExternalProvider:
      case ActionMethod.sideLoadExternalProvider:
      case ActionMethod.getCountryCode:
      case ActionMethod.getMemory:
        completer?.complete(action.data as String);
        return;
      case ActionMethod.message:
        clashMessage.controller.add(action.data as String);
        return;
      case ActionMethod.forceGc:
      case ActionMethod.startLog:
      case ActionMethod.stopLog:
        return;
    }
  }

  Future<T> _invoke<T>({
    required ActionMethod method,
    dynamic data,
    Duration? timeout,
    FutureOr<T> Function()? onTimeout,
  }) async {
    final id = "${method.name}#${other.id}";
    final socket = await socketCompleter.future;
    callbackCompleterMap[id] = Completer<T>();
    socket.writeln(
      json.encode(
        Action(
          id: id,
          method: method,
          data: data,
        ),
      ),
    );
    return (callbackCompleterMap[id] as Completer<T>).safeFuture(
      timeout: timeout,
      onLast: () {
        callbackCompleterMap.remove(id);
      },
      onTimeout: onTimeout ??
          () {
            if (T is String) {
              return "" as T;
            }
            if (T is bool) {
              return false as T;
            }
            return null as T;
          },
      functionName: id,
    );
  }

  _prueInvoke({
    required ActionMethod method,
    dynamic data,
  }) async {
    final id = "${method.name}#${other.id}";
    final socket = await socketCompleter.future;
    socket.writeln(
      json.encode(
        Action(
          id: id,
          method: method,
          data: data,
        ),
      ),
    );
  }

  @override
  Future<bool> init(String homeDir) {
    return _invoke<bool>(
      method: ActionMethod.initClash,
      data: homeDir,
    );
  }

  @override
  shutdown() async {
    await _invoke<bool>(
      method: ActionMethod.shutdown,
    );
    if (Platform.isWindows) {
      await request.stopCoreByHelper();
    }
    await _destroySocket();
    process?.kill();
    process = null;
  }

  @override
  Future<bool> get isInit {
    return _invoke<bool>(
      method: ActionMethod.getIsInit,
    );
  }

  @override
  forceGc() {
    _prueInvoke(method: ActionMethod.forceGc);
  }

  @override
  FutureOr<String> validateConfig(String data) {
    return _invoke<String>(
      method: ActionMethod.validateConfig,
      data: data,
    );
  }

  @override
  Future<String> updateConfig(UpdateConfigParams updateConfigParams) async {
    return await _invoke<String>(
      method: ActionMethod.updateConfig,
      data: json.encode(updateConfigParams),
      timeout: const Duration(seconds: 20),
    );
  }

  @override
  Future<String> getProxies() {
    return _invoke<String>(
      method: ActionMethod.getProxies,
    );
  }

  @override
  FutureOr<String> changeProxy(ChangeProxyParams changeProxyParams) {
    return _invoke<String>(
      method: ActionMethod.changeProxy,
      data: json.encode(changeProxyParams),
    );
  }

  @override
  FutureOr<String> getExternalProviders() {
    return _invoke<String>(
      method: ActionMethod.getExternalProviders,
    );
  }

  @override
  FutureOr<String> getExternalProvider(String externalProviderName) {
    return _invoke<String>(
      method: ActionMethod.getExternalProvider,
      data: externalProviderName,
    );
  }

  @override
  Future<String> updateGeoData({
    required String geoType,
    required String geoName,
  }) {
    return _invoke<String>(
      method: ActionMethod.updateGeoData,
      data: json.encode(
        {
          "geoType": geoType,
          "geoName": geoName,
        },
      ),
    );
  }

  @override
  Future<String> sideLoadExternalProvider({
    required String providerName,
    required String data,
  }) {
    return _invoke<String>(
      method: ActionMethod.sideLoadExternalProvider,
      data: json.encode({
        "providerName": providerName,
        "data": data,
      }),
    );
  }

  @override
  Future<String> updateExternalProvider(String providerName) {
    return _invoke<String>(
      method: ActionMethod.updateExternalProvider,
      data: providerName,
    );
  }

  @override
  FutureOr<String> getConnections() {
    return _invoke<String>(
      method: ActionMethod.getConnections,
    );
  }

  @override
  Future<bool> closeConnections() {
    return _invoke<bool>(
      method: ActionMethod.closeConnections,
    );
  }

  @override
  Future<bool> closeConnection(String id) {
    return _invoke<bool>(
      method: ActionMethod.closeConnection,
      data: id,
    );
  }

  @override
  FutureOr<String> getTotalTraffic(bool value) {
    return _invoke<String>(
      method: ActionMethod.getTotalTraffic,
      data: value,
    );
  }

  @override
  FutureOr<String> getTraffic(bool value) {
    return _invoke<String>(
      method: ActionMethod.getTraffic,
      data: value,
    );
  }

  @override
  resetTraffic() {
    _prueInvoke(method: ActionMethod.resetTraffic);
  }

  @override
  startLog() {
    _prueInvoke(method: ActionMethod.startLog);
  }

  @override
  stopLog() {
    _prueInvoke(method: ActionMethod.stopLog);
  }

  @override
  Future<bool> startListener() {
    return _invoke<bool>(
      method: ActionMethod.startListener,
    );
  }

  @override
  stopListener() {
    return _invoke<bool>(
      method: ActionMethod.stopListener,
    );
  }

  @override
  Future<String> asyncTestDelay(String proxyName) {
    final delayParams = {
      "proxy-name": proxyName,
      "timeout": httpTimeoutDuration.inMilliseconds,
    };
    return _invoke<String>(
      method: ActionMethod.asyncTestDelay,
      data: json.encode(delayParams),
      timeout: Duration(
        milliseconds: 6000,
      ),
      onTimeout: () {
        return json.encode(
          Delay(
            name: proxyName,
            value: -1,
          ),
        );
      },
    );
  }

  destroy() async {
    final server = await serverCompleter.future;
    await server.close();
    await _deleteSocketFile();
  }

  @override
  FutureOr<String> getCountryCode(String ip) {
    return _invoke<String>(
      method: ActionMethod.getCountryCode,
      data: ip,
    );
  }

  @override
  FutureOr<String> getMemory() {
    return _invoke<String>(
      method: ActionMethod.getMemory,
    );
  }
}

final clashService = system.isDesktop ? ClashService() : null;
