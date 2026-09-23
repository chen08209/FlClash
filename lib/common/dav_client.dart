import 'dart:async';
import 'dart:io' as io;

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:flutter/foundation.dart';

typedef DAVClientFactory = DAVClient Function(DAVProps props);

class DAVClient {
  late DAVTransport client;
  late String fileName;

  DAVClient(DAVProps dav) {
    client = DAVTransport(uri: dav.uri, user: dav.user, password: dav.password);
    fileName = dav.fileName;
  }

  Future<bool> ping() async {
    try {
      await client.options('/');
      return true;
    } catch (e) {
      commonPrint.log(
        'dav ping error ${e.toString()}',
        logLevel: LogLevel.warning,
      );
      return false;
    }
  }

  String get root => '/$appName';

  String get backupFile => '$root/$fileName';

  Future<bool> backup(String localFilePath) async {
    await client.mkcol(root);
    await client.put(backupFile, await io.File(localFilePath).readAsBytes());
    return true;
  }

  Future<bool> restore() async {
    final backupFilePath = await appPath.backupFilePath;
    final bytes = await client.get(backupFile);
    await io.File(backupFilePath).safeWriteAsBytes(bytes);
    return true;
  }
}

class DAVConnectionController extends ValueNotifier<bool?> {
  DAVConnectionController({DAVClientFactory? createClient})
    : _createClient = createClient ?? DAVClient.new,
      super(null);

  final DAVClientFactory _createClient;

  DAVProps? _lastProps;
  bool _hasUpdated = false;
  int _requestId = 0;
  bool _disposed = false;

  DAVClient? client;

  Future<void> update(DAVProps? props) async {
    final nextClient = props == null ? null : _createClient(props);
    client = nextClient;

    final rawProps = props?.copyWith(fileName: '');
    final rawLastProps = _lastProps?.copyWith(fileName: '');
    final isSameCredentials = _hasUpdated && rawProps == rawLastProps;
    _lastProps = props;
    _hasUpdated = true;
    if (isSameCredentials) {
      return;
    }

    final requestId = ++_requestId;
    value = null;
    final result = await nextClient?.ping() ?? false;
    if (!_disposed && requestId == _requestId) {
      value = result;
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _requestId++;
    super.dispose();
  }
}
