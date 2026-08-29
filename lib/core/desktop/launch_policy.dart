import 'dart:io';

import 'package:fl_clash/core/desktop/helper_client.dart';
import 'package:fl_clash/core/desktop/model.dart';
import 'package:win32_registry/win32_registry.dart';

/// CreateProcess reports these when a policy, not the file, refused the image:
/// ERROR_VIRUS_INFECTED, ERROR_INVALID_IMAGE_HASH, ERROR_ACCESS_DISABLED_BY_POLICY.
const policyBlockedOsErrors = {225, 577, 1260};

enum SmartAppControlState { off, on, evaluation, unknown }

typedef SmartAppControlStateReader = SmartAppControlState Function();

/// Swapped out by tests; the real reader needs a Windows registry.
SmartAppControlStateReader smartAppControlStateReader =
    readSmartAppControlState;

SmartAppControlState readSmartAppControlState() {
  if (!Platform.isWindows) {
    return SmartAppControlState.unknown;
  }
  try {
    final key = LOCAL_MACHINE.open(
      r'SYSTEM\CurrentControlSet\Control\CI\Policy',
    );
    try {
      return switch (key.getInt('VerifiedAndReputablePolicyState')) {
        0 => SmartAppControlState.off,
        1 => SmartAppControlState.on,
        2 => SmartAppControlState.evaluation,
        _ => SmartAppControlState.unknown,
      };
    } finally {
      key.close();
    }
  } catch (_) {
    return SmartAppControlState.unknown;
  }
}

/// The OS error behind a failed Core launch, whether the Helper spawned it
/// (the code travels in the response details, older Helpers only in the
/// message) or the app did (dart:io keeps it on the exception).
int? launchOsError(Object? error) {
  return switch (error) {
    DesktopCoreFailure(:final cause) => launchOsError(cause),
    ProcessException(:final errorCode) => errorCode == 0 ? null : errorCode,
    WindowsHelperException(code: 'processLaunchFailed') => _helperOsError(
      error,
    ),
    _ => null,
  };
}

bool isPolicyBlockedLaunch(Object? error) {
  return policyBlockedOsErrors.contains(launchOsError(error));
}

int? _helperOsError(WindowsHelperException error) {
  final details = error.details;
  if (details is Map && details['osError'] is int) {
    return details['osError'] as int;
  }
  final match = RegExp(r'os error (\d+)').firstMatch(error.message);
  return match == null ? null : int.tryParse(match.group(1)!);
}
