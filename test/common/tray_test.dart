import 'package:fl_clash/common/tray.dart';
import 'package:test/test.dart';

void main() {
  group('AppTray.getTrayIcon', () {
    final windows = AppTray.forPlatform(isMacOS: false, isWindows: true);
    final macOS = AppTray.forPlatform(isMacOS: true, isWindows: false);
    final linux = AppTray.forPlatform(isMacOS: false, isWindows: false);

    test('windows loads ico files from the windows directory', () {
      expect(
        windows.getTrayIcon(isStart: false, tunEnable: false),
        'assets/images/tray/windows/status_1.ico',
      );
      expect(
        windows.getTrayIcon(isStart: true, tunEnable: false),
        'assets/images/tray/windows/status_2.ico',
      );
      expect(
        windows.getTrayIcon(isStart: true, tunEnable: true),
        'assets/images/tray/windows/status_3.ico',
      );
    });

    test('linux loads png files from the unix directory', () {
      expect(
        linux.getTrayIcon(isStart: false, tunEnable: false),
        'assets/images/tray/unix/status_1.png',
      );
      expect(
        linux.getTrayIcon(isStart: true, tunEnable: false),
        'assets/images/tray/unix/status_2.png',
      );
      expect(
        linux.getTrayIcon(isStart: true, tunEnable: true),
        'assets/images/tray/unix/status_3.png',
      );
    });

    test('macOS keeps the template icon in every state', () {
      for (final (isStart, tunEnable) in [
        (false, false),
        (true, false),
        (true, true),
      ]) {
        expect(
          macOS.getTrayIcon(isStart: isStart, tunEnable: tunEnable),
          'assets/images/tray/unix/status_1.png',
        );
      }
    });
  });
}
