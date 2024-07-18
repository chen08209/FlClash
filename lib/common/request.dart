import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/models/ip.dart';
import 'package:fl_clash/state.dart';

class Request {
  late final Dio _dio;
  int? _port;
  bool _isStart = false;

  Request() {
    _dio = Dio();
    _dio.options = BaseOptions(
      headers: {"User-Agent": globalState.appController.clashConfig.globalUa},
    );
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          _updateAdapter();
          return handler.next(options); // 继续请求
        },
      ),
    );
  }

  _updateAdapter() {
    final port = globalState.appController.clashConfig.mixedPort;
    final isStart = globalState.appController.appState.isStart;
    if (_port != port || isStart != _isStart) {
      _port = port;
      _isStart = isStart;
      _dio.httpClientAdapter = IOHttpClientAdapter(
        createHttpClient: () {
          final client = HttpClient();
          if (!_isStart) return client;
          client.userAgent = globalState.appController.clashConfig.globalUa;
          client.findProxy = (url) {
            return "PROXY localhost:$_port;DIRECT";
          };
          return client;
        },
        validateCertificate: (_, __, ___) => true,
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
          httpTimeoutDuration * 2,
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
    final version = globalState.packageInfo.version;
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

  Future<IpInfo?> checkIp(CancelToken? cancelToken) async {
    for (final source in _ipInfoSources.entries) {
      try {
        final response = await _dio
            .get<Map<String, dynamic>>(source.key, cancelToken: cancelToken)
            .timeout(
              httpTimeoutDuration,
            );
        if (response.statusCode == 200 && response.data != null) {
          return source.value(response.data!);
        }
      } catch (e) {
        continue;
      }
    }
    return null;
  }
}

final request = Request();
