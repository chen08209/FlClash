import 'dart:io';

import 'package:fl_clash/core/desktop/helper_client.dart';
import 'package:fl_clash/core/desktop/launch_policy.dart';
import 'package:fl_clash/core/desktop/model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('reads the OS error the Helper reports in the response details', () {
    const error = WindowsHelperException(
      code: 'processLaunchFailed',
      message: 'spawn failed',
      details: {'osError': 577},
    );

    expect(launchOsError(error), 577);
    expect(isPolicyBlockedLaunch(error), isTrue);
  });

  test('falls back to the code embedded in an older Helper message', () {
    const error = WindowsHelperException(
      code: 'processLaunchFailed',
      message: 'This program is blocked by group policy. (os error 1260)',
    );

    expect(launchOsError(error), 1260);
    expect(isPolicyBlockedLaunch(error), isTrue);
  });

  test('ignores Helper failures that happened before the spawn', () {
    const error = WindowsHelperException(
      code: 'coreVerificationFailed',
      message: 'Core executable SHA256 mismatch (os error 577)',
    );

    expect(launchOsError(error), isNull);
    expect(isPolicyBlockedLaunch(error), isFalse);
  });

  test('reads the OS error from a direct launch failure', () {
    const error = ProcessException('FlClashCore.exe', [], 'refused', 225);

    expect(launchOsError(error), 225);
    expect(isPolicyBlockedLaunch(error), isTrue);
  });

  test('looks through the lifecycle failure to its cause', () {
    const failure = DesktopCoreFailure(
      code: 'start_failed',
      phase: DesktopCorePhase.starting,
      revision: 1,
      cause: ProcessException('FlClashCore.exe', [], 'refused', 577),
    );

    expect(launchOsError(failure), 577);
    expect(isPolicyBlockedLaunch(failure), isTrue);
  });

  test('a missing file or a plain crash is not a policy block', () {
    expect(
      isPolicyBlockedLaunch(
        const ProcessException('FlClashCore.exe', [], 'not found', 2),
      ),
      isFalse,
    );
    expect(
      isPolicyBlockedLaunch(
        const DesktopCoreFailure(
          code: 'start_failed',
          phase: DesktopCorePhase.starting,
          revision: 1,
          cause: 'receive timeout',
        ),
      ),
      isFalse,
    );
    expect(isPolicyBlockedLaunch(null), isFalse);
  });

  test('the registry state is unknown off Windows', () {
    if (Platform.isWindows) {
      return;
    }
    expect(readSmartAppControlState(), SmartAppControlState.unknown);
  });
}
