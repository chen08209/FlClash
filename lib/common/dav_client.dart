import 'dart:async';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/models/models.dart';
import 'package:webdav_client/webdav_client.dart';

class DAVClient {
  late Client client;
  Completer<bool> pingCompleter = Completer();
  late String fileName;

  DAVClient(DAVProps dav) {
    client = newClient(dav.uri, user: dav.user, password: dav.password);
    fileName = dav.fileName;
    client.setHeaders({'accept-charset': 'utf-8', 'Content-Type': 'text/xml'});
    client.setConnectTimeout(8000);
    client.setSendTimeout(60000);
    client.setReceiveTimeout(60000);
    pingCompleter.complete(_ping());
  }

  Future<bool> _ping() async {
    try {
      await client.ping();
      return true;
    } catch (_) {
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
