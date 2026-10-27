import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:fl_clash/common/constant.dart';
import 'package:fl_clash/common/path.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;

enum HotspotCommand { inspect, enable, disable, repair }

class HotspotSnapshot {
  final bool managed;
  final bool on;
  final bool throughTun;
  final bool busy;
  final int clients;
  final String ssid;
  final String error;

  const HotspotSnapshot({
    this.managed = false,
    this.on = false,
    this.throughTun = false,
    this.busy = false,
    this.clients = 0,
    this.ssid = '',
    this.error = '',
  });

  factory HotspotSnapshot.fromJson(Map<String, dynamic> json) {
    return HotspotSnapshot(
      managed: json['managed'] == true,
      on: json['on'] == true,
      throughTun: json['throughTun'] == true,
      clients: (json['clients'] as num?)?.toInt() ?? 0,
      ssid: json['ssid'] as String? ?? '',
      error: json['error'] as String? ?? '',
    );
  }

  HotspotSnapshot copyWith({bool? busy, String? error}) {
    return HotspotSnapshot(
      managed: managed,
      on: on,
      throughTun: throughTun,
      busy: busy ?? this.busy,
      clients: clients,
      ssid: ssid,
      error: error ?? this.error,
    );
  }
}

abstract interface class HotspotBackend {
  Future<HotspotSnapshot> execute(HotspotCommand command);
}

class WindowsHotspotBackend implements HotspotBackend {
  final String tunName;
  Future<String>? _script;

  WindowsHotspotBackend({this.tunName = 'FlClash'});

  Future<String> _prepareScript() async {
    final bytes = await rootBundle.load('assets/windows/hotspot.ps1');
    final data = bytes.buffer.asUint8List(
      bytes.offsetInBytes,
      bytes.lengthInBytes,
    );
    final hash = sha256.convert(data).toString();
    final directory = Directory(p.join(await appPath.homeDirPath, 'hotspot'));
    await directory.create(recursive: true);
    final file = File(p.join(directory.path, 'helper-$hash.ps1'));
    if (!await file.exists() ||
        sha256.convert(await file.readAsBytes()).toString() != hash) {
      await file.writeAsBytes(data, flush: true);
    }
    return file.path;
  }

  @override
  Future<HotspotSnapshot> execute(HotspotCommand command) async {
    if (safeModeBuild || !Platform.isWindows) {
      throw StateError('Hotspot control is unavailable in this build');
    }
    final directory = p.join(await appPath.homeDirPath, 'hotspot');
    final stateFile = File(p.join(directory, 'session.json'));
    if ((command == HotspotCommand.inspect ||
            command == HotspotCommand.disable) &&
        !await stateFile.exists()) {
      return const HotspotSnapshot();
    }
    final script = await (_script ??= _prepareScript());
    final resultFile = File(p.join(directory, 'result-${command.name}.json'));
    if (await resultFile.exists()) await resultFile.delete();
    final executable = p.join(
      Platform.environment['SystemRoot'] ?? r'C:\Windows',
      'System32',
      'WindowsPowerShell',
      'v1.0',
      'powershell.exe',
    );
    final process = await Process.start(executable, [
      '-NoProfile',
      '-NonInteractive',
      '-ExecutionPolicy',
      'Bypass',
      '-File',
      script,
      '-Action',
      command.name,
      '-TunName',
      tunName,
      '-StateFile',
      stateFile.path,
      '-ResultFile',
      resultFile.path,
    ], mode: ProcessStartMode.normal);
    final stdout = process.stdout.drain<void>();
    final stderr = process.stderr.drain<void>();
    try {
      await process.exitCode.timeout(const Duration(seconds: 55));
      await Future.wait([stdout, stderr]);
      final json = jsonDecode(await resultFile.readAsString());
      return HotspotSnapshot.fromJson(json as Map<String, dynamic>);
    } on TimeoutException {
      process.kill();
      rethrow;
    }
  }
}
