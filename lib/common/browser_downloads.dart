import 'dart:async';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:fl_clash/common/common.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

enum BrowserDownloadStatus { queued, downloading, paused, completed, failed }

class BrowserDownloadItem {
  final String id;
  final String url;
  final String filePath;
  final int received;
  final int total;
  final int speed;
  final BrowserDownloadStatus status;
  final String? error;

  const BrowserDownloadItem({
    required this.id,
    required this.url,
    required this.filePath,
    this.received = 0,
    this.total = 0,
    this.speed = 0,
    this.status = BrowserDownloadStatus.queued,
    this.error,
  });

  String get fileName => p.basename(filePath);

  double? get progress => total <= 0 ? null : received.clamp(0, total) / total;

  BrowserDownloadItem copyWith({
    int? received,
    int? total,
    int? speed,
    BrowserDownloadStatus? status,
    String? error,
  }) {
    return BrowserDownloadItem(
      id: id,
      url: url,
      filePath: filePath,
      received: received ?? this.received,
      total: total ?? this.total,
      speed: speed ?? this.speed,
      status: status ?? this.status,
      error: error,
    );
  }
}

class BrowserDownloadManager {
  static final BrowserDownloadManager instance = BrowserDownloadManager._();

  final ValueNotifier<List<BrowserDownloadItem>> itemsNotifier = ValueNotifier(
    const [],
  );
  final Map<String, CancelToken> _cancelTokens = {};

  BrowserDownloadManager._();

  Future<void> start(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) return;
    final filePath = await _createFilePath(uri);
    final item = BrowserDownloadItem(
      id: utils.id,
      url: url,
      filePath: filePath,
      status: BrowserDownloadStatus.queued,
    );
    _upsert(item);
    unawaited(_download(item));
  }

  Future<void> pause(String id) async {
    _cancelTokens.remove(id)?.cancel('paused');
    final item = _find(id);
    if (item != null) {
      _upsert(item.copyWith(status: BrowserDownloadStatus.paused, speed: 0));
    }
  }

  Future<void> resume(String id) async {
    final item = _find(id);
    if (item == null) return;
    if (item.status == BrowserDownloadStatus.completed) return;
    _upsert(item.copyWith(status: BrowserDownloadStatus.queued, error: null));
    unawaited(_download(item));
  }

  Future<void> delete(String id) async {
    _cancelTokens.remove(id)?.cancel('deleted');
    final item = _find(id);
    if (item != null) {
      await File(item.filePath).safeDelete();
    }
    itemsNotifier.value = itemsNotifier.value
        .where((item) => item.id != id)
        .toList(growable: false);
  }

  BrowserDownloadItem? _find(String id) {
    return itemsNotifier.value.firstWhereOrNull((item) => item.id == id);
  }

  void _upsert(BrowserDownloadItem item) {
    final next = [...itemsNotifier.value];
    final index = next.indexWhere((entry) => entry.id == item.id);
    if (index == -1) {
      next.insert(0, item);
    } else {
      next[index] = item;
    }
    itemsNotifier.value = next;
  }

  Future<void> _download(BrowserDownloadItem item) async {
    final file = File(item.filePath);
    await file.parent.create(recursive: true);
    final start = await file.exists() ? await file.length() : 0;
    final token = CancelToken();
    _cancelTokens[item.id] = token;
    var received = start;
    var total = item.total > 0 ? item.total : 0;
    var lastBytes = received;
    var lastTime = DateTime.now();
    IOSink? sink;
    try {
      final headers = start > 0 ? {'range': 'bytes=$start-'} : null;
      final response = await request.dio.get<ResponseBody>(
        item.url,
        options: Options(responseType: ResponseType.stream, headers: headers),
        cancelToken: token,
      );
      final contentLength = response.data?.contentLength ?? 0;
      if (contentLength > 0) {
        total = start + contentLength;
      }
      sink = file.openWrite(mode: start > 0 ? FileMode.append : FileMode.write);
      _upsert(
        item.copyWith(
          received: received,
          total: total,
          status: BrowserDownloadStatus.downloading,
        ),
      );
      await for (final chunk in response.data!.stream) {
        sink.add(chunk);
        received += chunk.length;
        final now = DateTime.now();
        final elapsed = now.difference(lastTime).inMilliseconds;
        if (elapsed >= 500) {
          final speed = ((received - lastBytes) * 1000 / elapsed).round();
          lastBytes = received;
          lastTime = now;
          _upsert(
            item.copyWith(
              received: received,
              total: total,
              speed: speed,
              status: BrowserDownloadStatus.downloading,
            ),
          );
        }
      }
      await sink.flush();
      _upsert(
        item.copyWith(
          received: received,
          total: total,
          speed: 0,
          status: BrowserDownloadStatus.completed,
        ),
      );
    } catch (e) {
      if (e is DioException && CancelToken.isCancel(e)) return;
      _upsert(
        item.copyWith(
          received: received,
          total: total,
          speed: 0,
          status: BrowserDownloadStatus.failed,
          error: e.toString(),
        ),
      );
    } finally {
      await sink?.close();
      _cancelTokens.remove(item.id);
    }
  }

  Future<String> _createFilePath(Uri uri) async {
    final dir = p.join(await appPath.downloadDirPath, 'flclash_browser');
    final rawName = uri.pathSegments.isEmpty ? '' : uri.pathSegments.last;
    final baseName = rawName.trim().isEmpty ? uri.host : rawName.trim();
    final safeName = baseName.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
    var path = p.join(dir, safeName);
    var index = 1;
    while (await File(path).exists()) {
      path = p.join(
        dir,
        '${p.basenameWithoutExtension(safeName)}_$index'
        '${p.extension(safeName)}',
      );
      index++;
    }
    return path;
  }
}
