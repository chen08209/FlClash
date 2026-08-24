import 'dart:ffi';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:ffi/ffi.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/common/system_dns.dart';
import 'package:fl_clash/core/desktop/helper_client.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/plugins/app.dart';
import 'package:fl_clash/widgets/input.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:flutter/services.dart';

typedef ProcessRunner =
    Future<ProcessResult> Function(String executable, List<String> arguments);

class System {
  static System? _instance;
  bool _isTV = false;

  @visibleForTesting
  ProcessRunner runProcess = Process.run;

  System._internal();

  factory System() {
    _instance ??= System._internal();
    return _instance!;
  }

  bool get isDesktop => isWindows || isMacOS || isLinux;

  bool get isWindows => Platform.isWindows;

  bool get isMacOS => Platform.isMacOS;

  bool get isAndroid => Platform.isAndroid;

  bool get isLinux => Platform.isLinux;

  bool get isTV => _isTV;

  Future<int> init() async {
    final deviceInfo = await DeviceInfoPlugin().deviceInfo;
    _isTV = switch (deviceInfo) {
      AndroidDeviceInfo(:final systemFeatures) => systemFeatures.any(
        const {
          'android.hardware.type.television',
          'android.software.leanback',
        }.contains,
      ),
      _ => false,
    };
    return switch (Platform.operatingSystem) {
      'macos' => (deviceInfo as MacOsDeviceInfo).majorVersion,
      'android' => (deviceInfo as AndroidDeviceInfo).version.sdkInt,
      'windows' => (deviceInfo as WindowsDeviceInfo).majorVersion,
      String() => 0,
    };
  }

  Future<bool> didCrashOnPreviousExecution() async {
    if (!isAndroid) return false;
    return await app?.didCrashOnPreviousExecution() ?? false;
  }

  /// Arguments for the `stat` call behind [checkIsAdmin].
  ///
  /// [corePath] is handed to `Process.run` as an argv entry, so it must stay
  /// verbatim. Shell-quoting or escaping it here reaches `stat` as part of the
  /// file name and turns every path containing a space into a miss.
  @visibleForTesting
  static List<String> statArguments(String corePath, {required bool isMacOS}) {
    return isMacOS
        ? ['-f', '%Su:%Sg %Sp', corePath]
        : ['-c', '%U:%G %A', corePath];
  }

  @visibleForTesting
  static bool isPrivilegedStatOutput(
    String output, {
    required String ownerPrefix,
  }) {
    final trimmed = output.trim();
    return trimmed.startsWith(ownerPrefix) && trimmed.contains('rws');
  }

  Future<bool> checkIsAdmin() async {
    if (system.isWindows) {
      return await windowsHelperClient.readiness() ==
          WindowsHelperReadiness.ready;
    }
    if (system.isMacOS) {
      final result = await runProcess(
        'stat',
        statArguments(appPath.corePath, isMacOS: true),
      );
      return isPrivilegedStatOutput(
        result.stdout.toString(),
        ownerPrefix: 'root:admin',
      );
    }
    if (system.isLinux) {
      final result = await runProcess(
        'stat',
        statArguments(appPath.corePath, isMacOS: false),
      );
      return isPrivilegedStatOutput(
        result.stdout.toString(),
        ownerPrefix: 'root:',
      );
    }
    return true;
  }

  static String _shellEscape(String value) {
    return "'${value.replaceAll("'", "'\\''")}'";
  }

  Future<AuthorizeCode> authorizeCore() async {
    if (system.isAndroid) {
      return AuthorizeCode.error;
    }
    if (system.isWindows) {
      return await windows?.registerService() ?? AuthorizeCode.error;
    }
    final isAdmin = await checkIsAdmin();
    if (isAdmin) {
      return AuthorizeCode.none;
    }

    if (system.isMacOS) {
      final escapedPath = _shellEscape(appPath.corePath);
      final shell = 'chown root:admin $escapedPath && chmod +sx $escapedPath';
      final arguments = [
        '-e',
        'do shell script "$shell" with administrator privileges',
      ];
      final result = await runProcess('osascript', arguments);
      if (result.exitCode != 0) {
        return AuthorizeCode.error;
      }
      return AuthorizeCode.success;
    } else if (Platform.isLinux) {
      final shell = Platform.environment['SHELL'] ?? 'bash';
      final password = await dialogs.showCommonDialog<String>(
        child: InputDialog(
          obscureText: true,
          title: currentAppLocalizations.pleaseInputAdminPassword,
          value: '',
          inputFormatters: TextInputLimits.limit(TextInputLimits.password),
        ),
      );
      if (password == null || password.isEmpty) {
        return AuthorizeCode.error;
      }
      final escapedPassword = _shellEscape(password);
      final escapedCorePath = _shellEscape(appPath.corePath);
      final arguments = [
        '-c',
        'echo $escapedPassword | sudo -S chown root:root $escapedCorePath && echo $escapedPassword | sudo -S chmod +sx $escapedCorePath',
      ];
      final result = await runProcess(shell, arguments);
      if (result.exitCode != 0) {
        return AuthorizeCode.error;
      }
      return AuthorizeCode.success;
    }
    return AuthorizeCode.error;
  }

  Future<void> back() async {
    await app?.moveTaskToBack();
  }

  Future<void> exit() async {
    if (system.isAndroid) {
      await SystemNavigator.pop();
    }
  }
}

final system = System();

class Windows {
  static Windows? _instance;
  late DynamicLibrary _shell32;

  Windows._internal() {
    _shell32 = DynamicLibrary.open('shell32.dll');
  }

  factory Windows() {
    _instance ??= Windows._internal();
    return _instance!;
  }

  bool runas(String command, String arguments) {
    final commandPtr = command.toNativeUtf16();
    final argumentsPtr = arguments.toNativeUtf16();
    final operationPtr = 'runas'.toNativeUtf16();

    final shellExecute = _shell32
        .lookupFunction<
          Int32 Function(
            Pointer<Utf16> hwnd,
            Pointer<Utf16> lpOperation,
            Pointer<Utf16> lpFile,
            Pointer<Utf16> lpParameters,
            Pointer<Utf16> lpDirectory,
            Int32 nShowCmd,
          ),
          int Function(
            Pointer<Utf16> hwnd,
            Pointer<Utf16> lpOperation,
            Pointer<Utf16> lpFile,
            Pointer<Utf16> lpParameters,
            Pointer<Utf16> lpDirectory,
            int nShowCmd,
          )
        >('ShellExecuteW');

    final result = shellExecute(
      nullptr,
      operationPtr,
      commandPtr,
      argumentsPtr,
      nullptr,
      1,
    );

    calloc.free(commandPtr);
    calloc.free(argumentsPtr);
    calloc.free(operationPtr);

    commonPrint.log(
      'windows runas: $command $arguments resultCode:$result',
      logLevel: LogLevel.warning,
    );

    if (result <= 32) {
      return false;
    }
    return true;
  }

  Future<AuthorizeCode> registerService() async {
    final readiness = await windowsHelperClient.readiness();
    switch (readiness) {
      case WindowsHelperReadiness.ready:
        commonPrint.log('helper service is ready');
        return AuthorizeCode.none;
      case WindowsHelperReadiness.manifestMissing:
        commonPrint.log(
          'Core manifest is missing or invalid; Helper service unavailable, '
          'falling back to direct Core',
          logLevel: LogLevel.warning,
        );
        dialogs.showNotifier(
          currentAppLocalizations.helperCorruptTip,
          level: MessageLevel.error,
        );
        return AuthorizeCode.error;
      case WindowsHelperReadiness.notReady:
        break;
    }

    commonPrint.log(
      'helper service is unavailable, requesting elevated installation',
      logLevel: LogLevel.warning,
    );
    if (!runas(appPath.helperPath, 'install')) {
      commonPrint.log(
        'failed to launch elevated helper installation',
        logLevel: LogLevel.error,
      );
      return AuthorizeCode.error;
    }

    final isRunning = await _waitForHelperService();
    commonPrint.log(
      isRunning
          ? 'helper service installation completed'
          : 'helper service did not become ready after installation',
      logLevel: isRunning ? LogLevel.info : LogLevel.error,
    );
    return isRunning ? AuthorizeCode.success : AuthorizeCode.error;
  }

  Future<bool> _waitForHelperService() async {
    const timeout = Duration(seconds: 6);
    const interval = Duration(seconds: 1);
    const maxAttempts = 6;
    final stopwatch = Stopwatch()..start();
    for (var attempt = 0; attempt < maxAttempts; attempt++) {
      final remaining = timeout - stopwatch.elapsed;
      if (remaining <= Duration.zero) return false;
      final isRunning =
          await windowsHelperClient.readiness(
            timeout: remaining,
            logFailure: false,
          ) ==
          WindowsHelperReadiness.ready;
      if (isRunning) return true;
      final delay = timeout - stopwatch.elapsed;
      if (delay <= Duration.zero || attempt == maxAttempts - 1) return false;
      await Future.delayed(delay < interval ? delay : interval);
    }
    return false;
  }
}

final windows = system.isWindows ? Windows() : null;

class MacOS implements SystemDnsPort {
  static MacOS? _instance;

  @visibleForTesting
  ProcessRunner runProcess = Process.run;

  MacOS._internal();

  factory MacOS() {
    _instance ??= MacOS._internal();
    return _instance!;
  }

  @visibleForTesting
  static String? parseDefaultInterface(String routeOutput) {
    final deviceLine = routeOutput
        .split('\n')
        .firstWhere((s) => s.contains('interface:'), orElse: () => '');
    final lineSplits = deviceLine.trim().split(' ');
    if (lineSplits.length != 2) {
      return null;
    }
    return lineSplits[1];
  }

  @visibleForTesting
  static String? parseServiceName(String serviceOrderOutput, String device) {
    final currentService = serviceOrderOutput
        .split('\n\n')
        .firstWhere((s) => s.contains('Device: $device'), orElse: () => '');
    if (currentService.isEmpty) {
      return null;
    }
    final nameLine = currentService
        .split('\n')
        .firstWhere(
          (line) => RegExp(r'^\(\d+\).*').hasMatch(line),
          orElse: () => '',
        );
    final name = RegExp(
      r'^\(\d+\)\s+(.+)$',
    ).firstMatch(nameLine.trim())?.group(1)?.trim();
    if (name == null || name.isEmpty) {
      return null;
    }
    return name;
  }

  @visibleForTesting
  static List<String> parseDnsServers(String getDnsServersOutput) {
    final output = getDnsServersOutput.trim();
    if (output.startsWith("There aren't any DNS Servers set on")) {
      return [];
    }
    return output.split('\n');
  }

  @override
  Future<String?> resolveDefaultService() async {
    final result = await _run('route', ['-n', 'get', 'default']);
    if (result == null) {
      return null;
    }
    final device = parseDefaultInterface(result.stdout.toString());
    if (device == null) {
      return null;
    }
    final serviceResult = await _run('networksetup', [
      '-listnetworkserviceorder',
    ]);
    if (serviceResult == null) {
      return null;
    }
    return parseServiceName(serviceResult.stdout.toString(), device);
  }

  @override
  Future<List<String>?> readDnsServers(String service) async {
    final result = await _run('networksetup', ['-getdnsservers', service]);
    if (result == null) {
      return null;
    }
    return parseDnsServers(result.stdout.toString());
  }

  @override
  Future<bool> writeDnsServers(String service, List<String> servers) async {
    final result = await _run('networksetup', [
      '-setdnsservers',
      service,
      if (servers.isEmpty) 'Empty',
      if (servers.isNotEmpty) ...servers,
    ], logLevel: LogLevel.error);
    return result != null;
  }

  Future<ProcessResult?> _run(
    String executable,
    List<String> arguments, {
    LogLevel logLevel = LogLevel.warning,
  }) async {
    final label = '$executable ${arguments.first}';
    try {
      final result = await runProcess(executable, arguments);
      if (result.exitCode != 0) {
        commonPrint.log(
          '$label exited with ${result.exitCode}: ${result.stderr.toString().trim()}',
          logLevel: logLevel,
        );
        return null;
      }
      return result;
    } catch (error) {
      commonPrint.log(
        '$label failed: ${compactError(error)}',
        logLevel: logLevel,
      );
      return null;
    }
  }
}

final macOS = system.isMacOS ? MacOS() : null;
