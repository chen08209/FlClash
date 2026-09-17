import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/state.dart';

class Request {
  static const _redirectStatusCodes = {301, 302, 303, 307, 308};
  static const _maxRedirects = 5;

  late final Dio dio;
  late final Dio _clashDio;
  final Future<List<InternetAddress>> Function(String host) _resolveHost;
  String? userAgent;

  ProviderReader? _read;

  void attach(ProviderReader read) {
    _read = read;
  }

  Request({
    Dio? clashDio,
    Future<List<InternetAddress>> Function(String host)? resolveHost,
  }) : _resolveHost = resolveHost ?? ((host) => InternetAddress.lookup(host)) {
    dio = Dio(BaseOptions(headers: {'User-Agent': browserUa}));
    _clashDio = clashDio ?? Dio();
    if (clashDio != null) return;
    _clashDio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        final client = HttpClient();
        client.findProxy = (Uri uri) {
          client.userAgent = globalState.ua;
          final read = _read;
          if (read == null) {
            return 'DIRECT';
          }
          return FlClashHttpOverrides.findProxyForReader(read, uri);
        };
        return client;
      },
    );
  }

  Future<Response<Uint8List>> getFileResponseForUrl(String url) async {
    try {
      return await _getResponseForUrl<Uint8List>(url, ResponseType.bytes);
    } catch (e) {
      commonPrint.log(
        'getFileResponseForUrl error ${compactError(e)}',
        logLevel: LogLevel.warning,
      );
      rethrow;
    }
  }

  Future<Response<String>> getTextResponseForUrl(String url) async {
    try {
      return await _getResponseForUrl<String>(url, ResponseType.plain);
    } catch (e) {
      commonPrint.log(
        'getTextResponseForUrl error ${compactError(e)}',
        logLevel: LogLevel.warning,
      );
      rethrow;
    }
  }

  Future<Response<T>> _getResponseForUrl<T>(
    String url,
    ResponseType responseType,
  ) async {
    var uri = Uri.parse(url);
    for (var redirects = 0; ; redirects++) {
      final response = await _clashDio.getUri<T>(
        uri,
        options: Options(
          responseType: responseType,
          followRedirects: false,
          maxRedirects: 0,
          validateStatus: (status) =>
              status != null &&
              ((status >= 200 && status < 300) ||
                  _redirectStatusCodes.contains(status)),
        ),
      );
      if (!_redirectStatusCodes.contains(response.statusCode)) {
        return response;
      }
      final target = _redirectTarget(uri, response);
      if (target == null || redirects >= _maxRedirects) {
        throw _redirectException(response);
      }
      await _validateRedirectTarget(target, response);
      uri = target;
    }
  }

  Uri? _redirectTarget(Uri uri, Response<dynamic> response) {
    final location = response.headers.value('location');
    if (location == null || location.isEmpty) return null;
    final target = Uri.tryParse(location);
    return target == null ? null : uri.resolveUri(target);
  }

  Future<void> _validateRedirectTarget(
    Uri target,
    Response<dynamic> response,
  ) async {
    if ((target.scheme != 'http' && target.scheme != 'https') ||
        target.host.isEmpty) {
      throw _redirectException(response);
    }
    final literal = InternetAddress.tryParse(target.host);
    if (literal != null) {
      if (_isLocalAddress(literal)) throw _redirectException(response);
      return;
    }
    final host = target.host.toLowerCase();
    if (host == 'localhost' || host.endsWith('.localhost')) {
      throw _redirectException(response);
    }
    final List<InternetAddress> addresses;
    try {
      addresses = await _resolveHost(target.host);
    } catch (_) {
      throw _redirectException(response);
    }
    if (addresses.isEmpty ||
        addresses.any(
          (address) => _isLocalAddress(address, allowFakeIp: true),
        )) {
      throw _redirectException(response);
    }
  }

  bool _isLocalAddress(InternetAddress address, {bool allowFakeIp = false}) {
    final bytes = address.rawAddress;
    if (address.type == InternetAddressType.IPv4) {
      return bytes[0] == 0 ||
          bytes[0] == 10 ||
          bytes[0] == 127 ||
          (bytes[0] == 100 && bytes[1] >= 64 && bytes[1] <= 127) ||
          (bytes[0] == 169 && bytes[1] == 254) ||
          (bytes[0] == 172 && bytes[1] >= 16 && bytes[1] <= 31) ||
          (bytes[0] == 192 && bytes[1] == 168) ||
          (!allowFakeIp &&
              bytes[0] == 198 &&
              bytes[1] >= 18 &&
              bytes[1] <= 19) ||
          bytes[0] >= 224;
    }
    final isUnspecified = bytes.every((byte) => byte == 0);
    final isUniqueLocal = bytes[0] & 0xfe == 0xfc;
    final isLinkLocal = bytes[0] == 0xfe && bytes[1] & 0xc0 == 0x80;
    final isMulticast = bytes[0] == 0xff;
    final isIPv4Mapped =
        bytes.take(10).every((byte) => byte == 0) &&
        bytes[10] == 0xff &&
        bytes[11] == 0xff;
    if (isIPv4Mapped) {
      return _isLocalAddress(InternetAddress.fromRawAddress(bytes.sublist(12)));
    }
    return address.isLoopback ||
        isUnspecified ||
        isUniqueLocal ||
        isLinkLocal ||
        isMulticast;
  }

  DioException _redirectException(Response<dynamic> response) {
    return DioException(
      requestOptions: response.requestOptions,
      response: response,
      type: DioExceptionType.badResponse,
      message: 'Profile redirect target is not allowed',
    );
  }

  Future<Map<String, dynamic>?> checkForUpdate() async {
    try {
      final response = await dio.get(
        'https://api.github.com/repos/$repository/releases/latest',
        options: Options(responseType: ResponseType.json),
      );
      if (response.statusCode != 200) return null;
      final data = response.data as Map<String, dynamic>;
      final remoteVersion = data['tag_name'];
      final version = globalState.packageInfo.version;
      final hasUpdate =
          compareVersions(remoteVersion.replaceAll('v', ''), version) > 0;
      if (!hasUpdate) return null;
      return data;
    } catch (e) {
      commonPrint.log('checkForUpdate failed', logLevel: LogLevel.warning);
      return null;
    }
  }

  final Map<String, IpInfo Function(Map<String, dynamic>)> _ipInfoSources = {
    'https://ipwho.is': IpInfo.fromIpWhoIsJson,
    'https://api.myip.com': IpInfo.fromMyIpJson,
    'https://ipapi.co/json': IpInfo.fromIpApiCoJson,
    'https://ident.me/json': IpInfo.fromIdentMeJson,
    'http://ip-api.com/json': IpInfo.fromIpAPIJson,
    'https://api.ip.sb/geoip': IpInfo.fromIpSbJson,
    'https://ipinfo.io/json': IpInfo.fromIpInfoIoJson,
  };

  Future<Result<IpInfo?>> checkIp({CancelToken? cancelToken}) async {
    var failureCount = 0;
    final token = cancelToken ?? CancelToken();
    final futures = _ipInfoSources.entries.map((source) async {
      final Completer<Result<IpInfo?>> completer = Completer();
      void handleFailRes() {
        if (!completer.isCompleted && failureCount == _ipInfoSources.length) {
          completer.complete(Result.success(null));
        }
      }

      final future = dio
          .get<Map<String, dynamic>>(
            source.key,
            cancelToken: token,
            options: Options(responseType: ResponseType.json),
          )
          .timeout(const Duration(seconds: 10));
      unawaited(
        future
            .then((res) {
              if (res.statusCode == HttpStatus.ok && res.data != null) {
                completer.complete(Result.success(source.value(res.data!)));
                return;
              }
              commonPrint.log('checkIp data empty', logLevel: LogLevel.info);
              failureCount++;
              handleFailRes();
            })
            .catchError((e) {
              failureCount++;
              if (e is DioException && e.type == DioExceptionType.cancel) {
                completer.complete(Result.error('cancelled'));
                return;
              }
              commonPrint.log('checkIp error $e', logLevel: LogLevel.warning);
              handleFailRes();
            }),
      );
      return completer.future;
    });
    final res = await Future.any(futures);
    token.cancel();
    return res;
  }
}

final request = Request();

String? getFileNameForDisposition(String? disposition) {
  if (disposition == null) return null;
  final parseValue = HeaderValue.parse(disposition);
  final parameters = parseValue.parameters;
  final fileNamePointKey = parameters.keys.firstWhere(
    (key) => key == 'filename*',
    orElse: () => '',
  );
  if (fileNamePointKey.isNotEmpty) {
    final res = parameters[fileNamePointKey]?.split("''") ?? [];
    if (res.length >= 2) {
      return Uri.decodeComponent(res[1]);
    }
  }
  final fileNameKey = parameters.keys.firstWhere(
    (key) => key == 'filename',
    orElse: () => '',
  );
  if (fileNameKey.isEmpty) return null;
  return parameters[fileNameKey];
}
