// ignore_for_file: avoid_print

import 'dart:io';

void main() {
  final cmdList = [];
  final ignoreHosts = "\"ass\"";
  cmdList.add(
    ["gsettings", "set", "org.gnome.system.proxy", "port", ignoreHosts],
  );
  print(cmdList.first);
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
