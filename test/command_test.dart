// ignore_for_file: avoid_print

import 'dart:io';

import 'package:fl_clash/common/other.dart';
import 'package:lpinyin/lpinyin.dart';

void main() {
  final res = const [
    "https://doh.pub/dns-query",
    "https://dns.alidns.com/dns-query"
  ];

  List.from(res)..remove("https://doh.pub/dns-query");
}

startService() async {
  // 定义服务器将要监听的地址和端口
  final host = InternetAddress.anyIPv4; // 监听所有网络接口
  const port = 8080; // 使用 8080 端口

  try {
    // 创建服务器
    final server = await HttpServer.bind(host, port);
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
