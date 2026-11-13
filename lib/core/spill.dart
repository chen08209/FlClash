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

/// A transport decodes a message at least this large off the UI isolate.
const coreIsolateDecodeBytes = 50 * 1024;

/// Turns a decoded result into what its caller reads. A transport runs it
/// where it decodes the response, in another isolate for a large one, so it
/// captures only values an isolate can be sent.
typedef CoreResultModel = Object? Function(Object? result);

const _resultModels = <CoreMethod, CoreResultModel>{
  CoreMethod.connectionList: trackerInfosOf,
};

CoreResultModel? coreResultModelOf(CoreMethod method) => _resultModels[method];

Map<String, Object?> withResultModel(
  CoreResultModel? model,
  Map<String, Object?> response,
) {
  if (model == null || response['error'] != null || response['file'] != null) {
    return response;
  }
  return {...response, 'result': model(response['result'])};
}

Future<CoreMethodResponse> resolveSpilledResponse(
  CoreMethodResponse response, {
  CoreResultModel? model,
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
      await compute(_readSpilledResponse, (file, model)),
    );
  } catch (error) {
    return CoreMethodResponse(
      id: response.id,
      error: CoreMethodError(code: 'spill_error', message: '$error'),
    );
  }
}

Map<String, Object?> _readSpilledResponse((String, CoreResultModel?) request) {
  final (path, model) = request;
  final file = File(path);
  try {
    final decoded = utf8.decoder
        .fuse(json.decoder)
        .convert(file.readAsBytesSync());
    return withResultModel(model, Map<String, Object?>.from(decoded as Map));
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
