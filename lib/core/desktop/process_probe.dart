import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';

typedef ProcessLivenessProbe = Future<bool> Function(int pid);

/// A recycled pid reads as alive, which delays a confirmation but never fakes one.
Future<bool> isProcessAlive(int pid) async {
  if (pid <= 0) {
    return false;
  }
  if (Platform.isWindows) {
    return _isWindowsProcessAlive(pid);
  }
  if (Platform.isLinux) {
    return _isLinuxProcessAlive(pid);
  }
  final result = await Process.run('ps', ['-o', 'stat=', '-p', '$pid']);
  final state = (result.stdout as String).trim();
  return result.exitCode == 0 && state.isNotEmpty && !state.startsWith('Z');
}

Future<bool> _isLinuxProcessAlive(int pid) async {
  final String stat;
  try {
    stat = await File('/proc/$pid/stat').readAsString();
  } on FileSystemException {
    return false;
  }
  final state = stat.substring(stat.lastIndexOf(')') + 1).trim();
  return state.isNotEmpty && state[0] != 'Z' && state[0] != 'X';
}

const _processQueryLimitedInformation = 0x1000;
const _errorInvalidParameter = 87;
const _stillActive = 259;

// A Helper-spawned Core belongs to SYSTEM; OpenProcess fails with
// ERROR_INVALID_PARAMETER only when no such process exists.
bool _isWindowsProcessAlive(int pid) {
  final kernel32 = DynamicLibrary.open('kernel32.dll');
  final openProcess = kernel32
      .lookupFunction<
        Pointer<Void> Function(Uint32, Int32, Uint32),
        Pointer<Void> Function(int, int, int)
      >('OpenProcess');
  final getLastError = kernel32
      .lookupFunction<Uint32 Function(), int Function()>('GetLastError');
  final getExitCodeProcess = kernel32
      .lookupFunction<
        Int32 Function(Pointer<Void>, Pointer<Uint32>),
        int Function(Pointer<Void>, Pointer<Uint32>)
      >('GetExitCodeProcess');
  final closeHandle = kernel32
      .lookupFunction<
        Int32 Function(Pointer<Void>),
        int Function(Pointer<Void>)
      >('CloseHandle');

  final handle = openProcess(_processQueryLimitedInformation, 0, pid);
  if (handle == nullptr) {
    return getLastError() != _errorInvalidParameter;
  }
  final exitCode = calloc<Uint32>();
  try {
    if (getExitCodeProcess(handle, exitCode) == 0) {
      return true;
    }
    return exitCode.value == _stillActive;
  } finally {
    calloc.free(exitCode);
    closeHandle(handle);
  }
}
