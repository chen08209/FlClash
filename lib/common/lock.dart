import 'dart:async';
import 'dart:io';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' show basename;

class SingleInstanceLock {
  static SingleInstanceLock? _instance;
  RandomAccessFile? _accessFile;

  SingleInstanceLock._internal();

  factory SingleInstanceLock() {
    _instance ??= SingleInstanceLock._internal();
    return _instance!;
  }

  @visibleForTesting
  static Future<String> Function() resolvePath = () => appPath.lockFilePath;

  Future<bool> acquire() async {
    try {
      final lockFilePath = await resolvePath();
      final lockFile = File(lockFilePath);
      await lockFile.create();
      _accessFile = await lockFile.open(mode: FileMode.write);
      await _accessFile?.lock();
      return true;
    } catch (e) {
      commonPrint.log(
        'single instance lock acquire failed ${e.toString()}',
        logLevel: LogLevel.warning,
      );
      return false;
    }
  }

  @visibleForTesting
  Future<void> release() async {
    await _accessFile?.close();
    _accessFile = null;
  }

  Future<String> _activationPath() async => '${await resolvePath()}.activate';

  /// A launch that lost the lock leaves this marker so the holder raises its
  /// window; a taskbar or launcher click is the only way most users reach a
  /// window hidden in the tray.
  Future<void> requestActivation() async {
    try {
      final file = File(await _activationPath());
      await file.writeAsString(
        DateTime.now().millisecondsSinceEpoch.toString(),
        flush: true,
      );
    } catch (e) {
      commonPrint.log(
        'single instance activation request failed ${e.toString()}',
        logLevel: LogLevel.warning,
      );
    }
  }

  Stream<void> get activationRequests {
    late final StreamController<void> controller;
    StreamSubscription<FileSystemEvent>? subscription;
    var consuming = false;
    controller = StreamController<void>(
      onListen: () async {
        final file = File(await _activationPath());
        subscription = file.parent
            .watch(events: FileSystemEvent.create | FileSystemEvent.modify)
            .listen((event) async {
              if (basename(event.path) != basename(file.path) || consuming) {
                return;
              }
              consuming = true;
              try {
                if (await _consumeMarker(file)) {
                  controller.add(null);
                }
              } finally {
                consuming = false;
              }
            });
      },
      onCancel: () async {
        await subscription?.cancel();
        await controller.close();
      },
    );
    return controller.stream;
  }

  /// Windows raises the create event while the requesting process still holds
  /// the marker open, and deleting it then fails with a sharing violation.
  Future<bool> _consumeMarker(File file) async {
    for (var attempt = 0; attempt < 20; attempt++) {
      try {
        await file.delete();
        return true;
      } on PathNotFoundException {
        return false;
      } on FileSystemException {
        await Future<void>.delayed(const Duration(milliseconds: 25));
      }
    }
    return false;
  }
}

final singleInstanceLock = SingleInstanceLock();
