import 'dart:convert';
import 'dart:io';

import 'package:fl_clash/common/common.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';

import 'method.dart';

/// Mirrors spilledResponseDirName in core/spill.go.
const coreSpillDirectoryName = 'responses';

Future<bool> _isSpilled(String file) async {
  final directory = join(await appPath.homeDirPath, coreSpillDirectoryName);
  return equals(dirname(file), directory);
}

Future<CoreMethodResponse> resolveSpilledResponse(
  CoreMethodResponse response,
) async {
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
      await compute(_readSpilledResponse, file),
    );
  } catch (error) {
    return CoreMethodResponse(
      id: response.id,
      error: CoreMethodError(code: 'spill_error', message: '$error'),
    );
  }
}

Map<String, Object?> _readSpilledResponse(String path) {
  final file = File(path);
  try {
    final decoded = utf8.decoder
        .fuse(json.decoder)
        .convert(file.readAsBytesSync());
    return Map<String, Object?>.from(decoded as Map);
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
