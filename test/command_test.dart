// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

Future<void> main() async {
  // final cmdList = [];
  // final ignoreHosts = "\"ass\"";
  // cmdList.add(
  //   ["gsettings", "set", "org.gnome.system.proxy", "port", ignoreHosts],
  // );
  // print(cmdList.first);
  final internetAddress = InternetAddress(
    "/tmp/FlClashSocket.sock",
    type: InternetAddressType.unix,
  );

  final socket = await Socket.connect(internetAddress, 0);
  socket
      .transform(
        StreamTransformer<Uint8List, String>.fromHandlers(
          handleData: (Uint8List data, EventSink<String> sink) {
            sink.add(utf8.decode(data));
          },
        ),
      )
      .transform(LineSplitter())
      .listen((res) {
        print(res);
      });
}

startService() async {
  try {
    // 创建服务器
    final server = await HttpServer.bind("127.0.0.1", 10001);
    print('服务器正在监听 ${server.address.address}:${server.port}');

    // 监听请求
    await for (HttpRequest request in server) {
      handleRequest(request);
    }
  } catch (e) {
    print('服务器错误: $e');
  }
}

void handleRequest(HttpRequest request) {
  print(request.headers);
  // 处理请求
  request.response
    ..statusCode = HttpStatus.ok
    ..headers.contentType = ContentType.html
    ..write('<html><body><h1>Hello, Dart Server!</h1></body></html>');

  // 完成响应
  request.response.close();
}
