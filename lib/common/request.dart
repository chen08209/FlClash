import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/models/ip.dart';
import 'package:fl_clash/state.dart';

class Request {
  late final Dio _dio;
  int? _port;

  Request() {
    _dio = Dio(
      BaseOptions(
        connectTimeout: httpTimeoutDuration,
        sendTimeout: httpTimeoutDuration,
        receiveTimeout: httpTimeoutDuration,
        headers: {"User-Agent": coreName},
      ),
    );
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        _syncProxy();
        return handler.next(options); // 继续请求
      },
    ));
  }

  _syncProxy() {
    final port = globalState.appController.clashConfig.mixedPort;
    if (_port != port) {
      _port = port;
      _dio.httpClientAdapter = IOHttpClientAdapter(
        createHttpClient: () {
          final client = HttpClient();
          client.findProxy = (url) {
            return "PROXY localhost:$_port;DIRECT";
          };
          return client;
        },
      );
    }
  }

  Future<Response> getFileResponseForUrl(String url) async {
    final response = await _dio
        .get(
          url,
          options: Options(
            responseType: ResponseType.bytes,
          ),
        )
        .timeout(
          httpTimeoutDuration,
        );
    return response;
  }

  Future<Map<String, dynamic>?> checkForUpdate() async {
    final response = await _dio.get(
      "https://api.github.com/repos/$repository/releases/latest",
      options: Options(
        responseType: ResponseType.json,
      ),
    );
    if (response.statusCode != 200) return null;
    final data = response.data as Map<String, dynamic>;
    final remoteVersion = data['tag_name'];
    final packageInfo = await appPackage.packageInfoCompleter.future;
    final version = packageInfo.version;
    final hasUpdate =
        other.compareVersions(remoteVersion.replaceAll('v', ''), version) > 0;
    if (!hasUpdate) return null;
    return data;
  }

  final Map<String, IpInfo Function(Map<String, dynamic>)> _ipInfoSources = {
    "https://ipwho.is/": IpInfo.fromIpwhoIsJson,
    "https://api.ip.sb/geoip/": IpInfo.fromIpSbJson,
    "https://ipapi.co/json/": IpInfo.fromIpApiCoJson,
    "https://ipinfo.io/json/": IpInfo.fromIpInfoIoJson,
  };

  Future<IpInfo> checkIp() async {
    for (final source in _ipInfoSources.entries) {
      try {
        final response = await _dio.get<Map<String, dynamic>>(
          source.key,
        );
        if (response.statusCode == 200 && response.data != null) {
          return source.value(response.data!);
        }
      } catch (e) {
        continue;
      }
    }
    throw "无法检索ip";
  }
}

final request = Request();
