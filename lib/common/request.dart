import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/common/release_asset.dart';
import 'package:fl_clash/common/release_version.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/plugins/app.dart';
import 'package:fl_clash/state.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:path/path.dart' show join;

class Request {
  static const _releasesPerPage = 100;
  static const _releasePages = 5;

  late final Dio dio;
  late final Dio _clashDio;

  /// Refuses an untrusted certificate even with the certificate check turned
  /// off, because what it fetches is installed, on Windows as administrator.
  @visibleForTesting
  late final Dio releaseDio;
  String? userAgent;

  ProviderReader? _read;

  void attach(ProviderReader read) {
    _read = read;
  }

  Request() {
    dio = Dio(BaseOptions(headers: {'User-Agent': browserUa}));
    _clashDio = Dio();
    _clashDio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        final client = HttpClient();
        client.findProxy = (Uri uri) {
          client.userAgent = globalState.ua;
          return _findProxy(uri);
        };
        return client;
      },
    );
    releaseDio = Dio(BaseOptions(headers: {'User-Agent': browserUa}));
    releaseDio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        return HttpClient()
          ..badCertificateCallback = ((_, _, _) => false)
          ..findProxy = _findProxy;
      },
    );
  }

  String _findProxy(Uri uri) {
    final read = _read;
    if (read == null) {
      return 'DIRECT';
    }
    return FlClashHttpOverrides.findProxyForReader(read, uri);
  }

  Future<Response<T>> _download<T>(String url, ResponseType responseType) {
    final target = downloadTarget(url);
    final cancelToken = CancelToken();
    return _clashDio
        .getUri<T>(
          target.uri,
          options: Options(responseType: responseType, headers: target.headers),
          cancelToken: cancelToken,
        )
        .timeout(
          downloadTimeoutDuration,
          onTimeout: () {
            cancelToken.cancel();
            throw DioException.receiveTimeout(
              timeout: downloadTimeoutDuration,
              requestOptions: RequestOptions(path: url),
            );
          },
        );
  }

  Future<Response<Uint8List>> getFileResponseForUrl(String url) async {
    try {
      return await _download<Uint8List>(url, ResponseType.bytes);
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
      return await _download<String>(url, ResponseType.plain);
    } catch (e) {
      commonPrint.log(
        'getTextResponseForUrl error ${compactError(e)}',
        logLevel: LogLevel.warning,
      );
      rethrow;
    }
  }

  /// Null when this build is current; throws when GitHub cannot be asked.
  Future<Map<String, dynamic>?> checkForUpdate(UpdateChannel channel) async {
    final release = await newestRelease(channel);
    final remote = ReleaseVersion.tryParse(release['tag_name'] as String);
    final installed = installedReleaseVersion(globalState.packageInfo.version);
    return remote != null && remote > installed ? release : null;
  }

  /// The rs line publishes only prereleases and offers no channel to pick.
  Future<Map<String, dynamic>> newestRelease(UpdateChannel _) {
    return newestOfAllReleases();
  }

  /// `releases/latest` never names a prerelease, so this reads the list. The
  /// feed answers without the hourly API quota but carries no release body,
  /// and holds only GitHub's ten newest entries, so each can be probed.
  Future<Map<String, dynamic>> newestOfAllReleases() async {
    try {
      for (var page = 1; page <= _releasePages; page++) {
        final response = await dio.get<List<dynamic>>(
          'https://api.github.com/repos/$repository/releases',
          queryParameters: {'per_page': _releasesPerPage, 'page': page},
          options: Options(responseType: ResponseType.json),
        );
        final listed = response.data!;
        final releases = {
          for (final release in listed)
            if (release case {'draft': false, 'tag_name': final String tag})
              tag: release as Map<String, dynamic>,
        };
        for (final tag in _candidates(releases.keys)) {
          if (releases[tag] case {
            'assets': final List<dynamic> assets,
          } when _namesChecksums(assets, tag)) {
            return releases[tag]!;
          }
        }
        if (listed.length < _releasesPerPage) {
          break;
        }
      }
      throw FormatException('No ${appReleaseLine.name} release in the list');
    } on DioException catch (error) {
      commonPrint.log(
        'release list API failed: ${compactError(error)}',
        logLevel: LogLevel.warning,
      );
    }
    final response = await dio.get<String>(
      'https://github.com/$repository/releases.atom',
      options: Options(responseType: ResponseType.plain),
    );
    for (final tag in _candidates(releaseTagsOfFeed(response.data ?? ''))) {
      if (await _hasChecksums(tag)) return {'tag_name': tag};
    }
    throw FormatException('No ${appReleaseLine.name} release in the feed');
  }

  Iterable<String> _candidates(Iterable<String> tags) =>
      releaseTagsNewestFirst(tags, appReleaseLine).where(namesReleaseFiles);

  bool _namesChecksums(List<dynamic> assets, String tag) {
    final name = updateChecksumsName(tag);
    return assets.any((asset) => asset is Map && asset['name'] == name);
  }

  /// The feed lists bare tags too, such as one whose release is still building.
  Future<bool> _hasChecksums(String tag) async {
    try {
      await dio.headUri<void>(
        releaseAssetUri(tag, updateChecksumsName(tag)),
        options: Options(
          followRedirects: false,
          validateStatus: (status) => status != null && status < 400,
        ),
      );
      return true;
    } on DioException catch (error) {
      if (error.response?.statusCode == HttpStatus.notFound) return false;
      rethrow;
    }
  }

  /// The release page redirect still answers once the hourly API quota is spent.
  Future<Map<String, dynamic>> latestRelease() async {
    try {
      final response = await dio.get<Map<String, dynamic>>(
        'https://api.github.com/repos/$repository/releases/latest',
        options: Options(responseType: ResponseType.json),
      );
      return response.data!;
    } on DioException catch (error) {
      commonPrint.log(
        'latest release API failed: ${compactError(error)}',
        logLevel: LogLevel.warning,
      );
    }
    final response = await dio.get<void>(
      'https://github.com/$repository/releases/latest',
      options: Options(
        followRedirects: false,
        validateStatus: (status) => status != null && status < 400,
      ),
    );
    final location = response.headers.value(HttpHeaders.locationHeader);
    final segments = Uri.tryParse(location ?? '')?.pathSegments ?? const [];
    final tagIndex = segments.indexOf('tag') + 1;
    if (tagIndex == 0 || tagIndex >= segments.length) {
      throw FormatException('No release tag in the redirect', location);
    }
    return {'tag_name': segments[tagIndex]};
  }

  Future<String> downloadVerifiedRelease({
    required String tag,
    required String name,
    required String directory,
    ProgressCallback? onReceiveProgress,
    CancelToken? cancelToken,
  }) async {
    final checksums = updateChecksumsName(tag);
    final sums = await _releaseFile(
      checksums,
      () => releaseDio.getUri<String>(
        releaseAssetUri(tag, checksums),
        options: Options(responseType: ResponseType.plain),
        cancelToken: cancelToken,
      ),
    );
    final expected = releaseChecksum(sums.data ?? '', name);
    if (expected == null) {
      throw ReleaseFileMissingException(name);
    }
    final path = join(directory, name);
    final uri = releaseAssetUri(tag, name);
    await _releaseFile(name, () async {
      if (app case final android?) {
        await android.downloadFile(
          uri,
          path,
          title: name,
          onReceiveProgress: onReceiveProgress ?? (_, _) {},
          cancelToken: cancelToken ?? CancelToken(),
        );
      } else {
        await releaseDio.downloadUri(
          uri,
          path,
          onReceiveProgress: onReceiveProgress,
          cancelToken: cancelToken,
        );
      }
    });
    if (await fileSha256(path) != expected) {
      throw ReleaseNotVerifiedException(name);
    }
    return path;
  }
}

// DownloadManager reports an HTTP failure by its status code.
Future<T> _releaseFile<T>(String name, Future<T> Function() fetch) async {
  try {
    return await fetch();
  } on DioException catch (error) {
    if (error.response?.statusCode == HttpStatus.notFound) {
      throw ReleaseFileMissingException(name);
    }
    rethrow;
  } on SystemDownloadException catch (error) {
    if (error.reason == HttpStatus.notFound) {
      throw ReleaseFileMissingException(name);
    }
    rethrow;
  }
}

final request = Request();

final _feedLink = RegExp(r'<link\b[^>]*\bhref="([^"]+)"');

@visibleForTesting
Iterable<String> releaseTagsOfFeed(String feed) sync* {
  for (final match in _feedLink.allMatches(feed)) {
    final segments = Uri.tryParse(match[1]!)?.pathSegments ?? const [];
    final tagIndex = segments.indexOf('tag') + 1;
    if (tagIndex > 0 && tagIndex < segments.length) {
      yield segments[tagIndex];
    }
  }
}

/// Some subscription servers send a gzip or zlib body without saying so in
/// Content-Encoding, which is the only signal dart:io decompresses on.
Uint8List decompressUnlabeled(Uint8List bytes) {
  final codec = switch (bytes) {
    [0x1f, 0x8b, ...] => gzip,
    [0x78, final flags, ...] when (0x78 << 8 | flags) % 31 == 0 => zlib,
    _ => null,
  };
  if (codec == null) {
    return bytes;
  }
  try {
    return Uint8List.fromList(codec.decode(bytes));
  } on FormatException {
    return bytes;
  }
}

/// dart:io turns [Uri.userInfo] into Basic credentials still percent-encoded.
@visibleForTesting
({Uri uri, Map<String, Object> headers}) downloadTarget(String url) {
  final uri = url.webUri ?? Uri.parse(url);
  if (uri.userInfo.isEmpty) {
    return (uri: uri, headers: const {});
  }
  final credentials = uri.userInfo.split(':').map(_decodeUserInfo).join(':');
  return (
    uri: uri.replace(userInfo: ''),
    headers: {
      HttpHeaders.authorizationHeader:
          'Basic ${base64.encode(utf8.encode(credentials))}',
    },
  );
}

String _decodeUserInfo(String value) {
  try {
    return Uri.decodeComponent(value);
  } on ArgumentError {
    return value;
  }
}

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
