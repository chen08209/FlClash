// ignore_for_file: avoid_print

import 'package:http/io_client.dart';
import 'dart:io';

void main() async {
  HttpClient httpClient = HttpClient();
  httpClient.findProxy = HttpClient.findProxyFromEnvironment;

  IOClient ioClient = IOClient(httpClient);
  var response = await ioClient.get(Uri.parse('https://mirror.ghproxy.com/https://raw.githubusercontent.com/Ruk1ng001/freeSub/main/clash_top30.yaml'));
  print(response.body);
}
