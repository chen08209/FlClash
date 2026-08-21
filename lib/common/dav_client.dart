import 'dart:async';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:flutter/foundation.dart';
import 'package:webdav_client/webdav_client.dart';

typedef DAVClientFactory = DAVClient Function(DAVProps props);

class DAVClient {
  late Client client;
  late String fileName;

  DAVClient(DAVProps dav) {
    client = newClient(dav.uri, user: dav.user, password: dav.password);
    fileName = dav.fileName;
    client.setHeaders({'accept-charset': 'utf-8', 'Content-Type': 'text/xml'});
    client.setConnectTimeout(8000);
    client.setSendTimeout(60000);
    client.setReceiveTimeout(60000);
  }

  Future<bool> ping() async {
    try {
      await client.ping();
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
    await client.mkdir(root);
    await client.writeFromFile(localFilePath, backupFile);
    return true;
  }

  Future<bool> restore() async {
    await client.mkdir(root);
    final backupFilePath = await appPath.backupFilePath;
    await client.read2File(backupFile, backupFilePath);
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
