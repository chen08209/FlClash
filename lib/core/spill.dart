import 'dart:convert';
import 'dart:io';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/models/models.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';

import 'method.dart';

/// Mirrors spilledResponseDirName in core/spill.go.
const coreSpillDirectoryName = 'responses';

Future<bool> _isSpilled(String file) async {
  final directory = join(await appPath.homeDirPath, coreSpillDirectoryName);
  return equals(dirname(file), directory);
}

/// Parsed where a transport decodes them, off the UI isolate for a large one.
const _resultModels = <CoreMethod, Object? Function(Object?)>{
  CoreMethod.getConnections: trackerInfosOf,
};

Map<String, Object?> withResultModel(
  CoreMethod? method,
  Map<String, Object?> response,
) {
  final model = _resultModels[method];
  if (model == null || response['error'] != null || response['file'] != null) {
    return response;
  }
  return {...response, 'result': model(response['result'])};
}

Future<CoreMethodResponse> resolveSpilledResponse(
  CoreMethodResponse response, {
  CoreMethod? method,
}) async {
  final file = response.file;
  if (file == null) {
    return response;
  }
  if (!await _isSpilled(file)) {
    return CoreMethodResponse(
      id: response.id,
      error: CoreMethodError(
        code: 'spill_error',
        message: 'Core answered with a file outside its spill directory: $file',
      ),
    );
  }
  try {
    return CoreMethodResponse.fromJson(
      await compute(_readSpilledResponse, (file, method)),
    );
  } catch (error) {
    return CoreMethodResponse(
      id: response.id,
      error: CoreMethodError(code: 'spill_error', message: '$error'),
    );
  }
}

Map<String, Object?> _readSpilledResponse((String, CoreMethod?) request) {
  final (path, method) = request;
  final file = File(path);
  try {
    final decoded = utf8.decoder
        .fuse(json.decoder)
        .convert(file.readAsBytesSync());
    return withResultModel(method, Map<String, Object?>.from(decoded as Map));
  } finally {
    try {
      file.deleteSync();
    } on FileSystemException catch (_) {}
  }
}

Future<String> readSpilledText(String path) async {
  if (!await _isSpilled(path)) {
    throw CoreMethodException(
      code: 'spill_error',
      message: 'Core wrote a file outside its spill directory: $path',
    );
  }
  return compute(_readSpilledText, path);
}

String _readSpilledText(String path) {
  final file = File(path);
  try {
    return file.readAsStringSync();
  } finally {
    try {
      file.deleteSync();
    } on FileSystemException catch (_) {}
  }
}

Future<void> discardSpilledResponse(CoreMethodResponse response) async {
  await discardSpilledFile(response.file);
  await discardSpilledFile(response.result);
}

Future<void> discardSpilledFile(Object? file) async {
  if (file is! String || !await _isSpilled(file)) {
    return;
  }
  try {
    await File(file).delete();
  } on FileSystemException catch (_) {}
}
