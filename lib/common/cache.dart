import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fl_clash/common/common.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class LocalImageCacheManager extends CacheManager {
  static const key = 'ImageCaches';

  static final LocalImageCacheManager _instance = LocalImageCacheManager._();

  factory LocalImageCacheManager() {
    return _instance;
  }

  LocalImageCacheManager._()
    : super(Config(key, fileService: _LocalImageCacheFileService()));
}

class _LocalImageCacheFileService extends FileService {
  _LocalImageCacheFileService();

  @override
  Future<FileServiceResponse> get(
    String url, {
    Map<String, String>? headers,
  }) async {
    final response = await request.dio.get<ResponseBody>(
      url,
      options: Options(headers: headers, responseType: ResponseType.stream),
    );
    return _LocalImageResponse(response);
  }
}

class _LocalImageResponse implements FileServiceResponse {
  _LocalImageResponse(this._response);

  final DateTime _receivedTime = DateTime.now();

  final Response<ResponseBody> _response;

  String? _header(String name) {
    return _response.headers.value(name);
  }

  @override
  int get statusCode => _response.statusCode ?? 0;

  @override
  Stream<List<int>> get content =>
      _response.data!.stream.transform(uint8ListToListIntConverter);

  @override
  int? get contentLength => _response.data?.contentLength;

  @override
  DateTime get validTill {
    var ageDuration = const Duration(days: 7);
    final controlHeader = _header(HttpHeaders.cacheControlHeader);
    if (controlHeader != null) {
      final controlSettings = controlHeader.split(',');
      for (final setting in controlSettings) {
        final sanitizedSetting = setting.trim().toLowerCase();
        if (sanitizedSetting == 'no-cache') {
          ageDuration = Duration.zero;
        }
        if (sanitizedSetting.startsWith('max-age=')) {
          final validSeconds =
              int.tryParse(sanitizedSetting.split('=')[1]) ?? 0;
          if (validSeconds > 0) {
            ageDuration = Duration(seconds: validSeconds);
          }
        }
      }
    }

    if (ageDuration > const Duration(days: 7)) {
      return _receivedTime.add(ageDuration);
    }
    return _receivedTime.add(const Duration(days: 7));
  }

  @override
  String? get eTag => _header(HttpHeaders.etagHeader);

  @override
  String get fileExtension {
    var fileExtension = '';
    final contentTypeHeader = _header(HttpHeaders.contentTypeHeader);
    if (contentTypeHeader != null) {
      final contentType = ContentType.parse(contentTypeHeader);
      fileExtension = contentType.fileExtension;
    }
    return fileExtension;
  }
}

extension ContentTypeConverter on ContentType {
  String get fileExtension => mimeTypes[mimeType] ?? '.$subType';
}

const mimeTypes = {
  'application/vnd.android.package-archive': '.apk',
  'application/epub+zip': '.epub',
  'application/gzip': '.gz',
  'application/java-archive': '.jar',
  'application/json': '.json',
  'application/ld+json': '.jsonld',
  'application/msword': '.doc',
  'application/octet-stream': '.bin',
  'application/ogg': '.ogx',
  'application/pdf': '.pdf',
  'application/php': '.php',
  'application/rtf': '.rtf',
  'application/vnd.amazon.ebook': '.azw',
  'application/vnd.apple.installer+xml': '.mpkg',
  'application/vnd.mozilla.xul+xml': '.xul',
  'application/vnd.ms-excel': '.xls',
  'application/vnd.ms-fontobject': '.eot',
  'application/vnd.ms-powerpoint': '.ppt',
  'application/vnd.oasis.opendocument.presentation': '.odp',
  'application/vnd.oasis.opendocument.spreadsheet': '.ods',
  'application/vnd.oasis.opendocument.text': '.odt',
  'application/vnd.openxmlformats-officedocument.presentationml.presentation':
      '.pptx',
  'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet': '.xlsx',
  'application/vnd.openxmlformats-officedocument.wordprocessingml.document':
      '.docx',
  'application/vnd.rar': '.rar',
  'application/vnd.visio': '.vsd',
  'application/x-7z-compressed': '.7z',
  'application/x-abiword': '.abw',
  'application/x-bzip': '.bz',
  'application/x-bzip2': '.bz2',
  'application/x-csh': '.csh',
  'application/x-freearc': '.arc',
  'application/x-sh': '.sh',
  'application/x-shockwave-flash': '.swf',
  'application/x-tar': '.tar',
  'application/xhtml+xml': '.xhtml',
  'application/xml': '.xml',
  'application/zip': '.zip',
  'audio/3gpp': '.3gp',
  'audio/3gpp2': '.3g2',
  'audio/aac': '.aac',
  'audio/x-aac': '.aac',
  'audio/midi': '.midi',
  'audio/x-midi': '.midi',
  'audio/x-m4a': '.m4a',
  'audio/m4a': '.m4a',
  'audio/mpeg': '.mp3',
  'audio/ogg': '.oga',
  'audio/opus': '.opus',
  'audio/wav': '.wav',
  'audio/x-wav': '.wav',
  'audio/webm': '.weba',
  'font/otf': '.otf',
  'font/ttf': '.ttf',
  'font/woff': '.woff',
  'font/woff2': '.woff2',
  'image/bmp': '.bmp',
  'image/gif': '.gif',
  'image/jpeg': '.jpg',
  'image/png': '.png',
  'image/svg+xml': '.svg',
  'image/tiff': '.tiff',
  'image/vnd.microsoft.icon': '.ico',
  'image/webp': '.webp',
  'text/calendar': '.ics',
  'text/css': '.css',
  'text/csv': '.csv',
  'text/html': '.html',
  'text/javascript': '.js',
  'text/plain': '.txt',
  'text/xml': '.xml',
  'video/3gpp': '.3gp',
  'video/3gpp2': '.3g2',
  'video/mp2t': '.ts',
  'video/mpeg': '.mpeg',
  'video/ogg': '.ogv',
  'video/webm': '.webm',
  'video/x-msvideo': '.avi',
  'video/quicktime': '.mov',
};
