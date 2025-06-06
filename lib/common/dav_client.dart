import 'dart:async';
import 'dart:typed_data';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/models/models.dart';
import 'package:webdav_client/webdav_client.dart';

class DAVClient {
  late Client client;
  Completer<bool> pingCompleter = Completer();
  late String fileName;

  DAVClient(DAV dav) {
    client = newClient(
      dav.uri,
      user: dav.user,
      password: dav.password,
    );
    fileName = dav.fileName;
    client.setHeaders(
      {
        'accept-charset': 'utf-8',
        'Content-Type': 'text/xml',
      },
    );
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

  Future<bool> backup(Uint8List data) async {
    await client.mkdir(root);
    await client.write(backupFile, data);
    return true;
  }

  Future<List<int>> recovery() async {
    await client.mkdir(root);
    final data = await client.read(backupFile);
    return data;
  }
}
