import 'package:fl_clash/common/tray.dart';
import 'package:test/test.dart';

void main() {
  group('AppTray.getTrayIcon', () {
    final windows = AppTray.forPlatform(isMacOS: false, isWindows: true);
    final macOS = AppTray.forPlatform(isMacOS: true, isWindows: false);
    final linux = AppTray.forPlatform(isMacOS: false, isWindows: false);

    test('windows loads ico files from the windows directory', () {
      expect(
        windows.getTrayIcon(isStart: false, tunEnable: false, safeMode: false),
        'assets/images/tray/windows/status_1.ico',
      );
      expect(
        windows.getTrayIcon(isStart: true, tunEnable: false, safeMode: false),
        'assets/images/tray/windows/status_2.ico',
      );
      expect(
        windows.getTrayIcon(isStart: true, tunEnable: true, safeMode: false),
        'assets/images/tray/windows/status_3.ico',
      );
    });

    test('linux loads png files from the unix directory', () {
      expect(
        linux.getTrayIcon(isStart: false, tunEnable: false, safeMode: false),
        'assets/images/tray/unix/status_1.png',
      );
      expect(
        linux.getTrayIcon(isStart: true, tunEnable: false, safeMode: false),
        'assets/images/tray/unix/status_2.png',
      );
      expect(
        linux.getTrayIcon(isStart: true, tunEnable: true, safeMode: false),
        'assets/images/tray/unix/status_3.png',
      );
    });

    test('macOS 开启时保留现有模板图标', () {
      for (final (isStart, tunEnable) in [(true, false), (true, true)]) {
        expect(
          macOS.getTrayIcon(
            isStart: isStart,
            tunEnable: tunEnable,
            safeMode: false,
          ),
          'assets/images/tray/macos/status_1.png',
        );
      }
    });

    test('macOS 关闭时使用灰色图标', () {
      for (final monochrome in [true, false]) {
        for (final tunEnable in [true, false]) {
          expect(
            macOS.getTrayIcon(
              isStart: false,
              tunEnable: tunEnable,
              safeMode: false,
              monochrome: monochrome,
            ),
            'assets/images/tray/macos/status_inactive.png',
          );
        }
      }
    });

    test('macOS 关闭单色选项后仍使用现有彩色运行图标', () {
      for (final (isStart, tunEnable, safeMode, status) in [
        (true, false, false, 2),
        (true, true, false, 3),
        (true, true, true, 4),
      ]) {
        expect(
          macOS.getTrayIcon(
            isStart: isStart,
            tunEnable: tunEnable,
            safeMode: safeMode,
            monochrome: false,
          ),
          'assets/images/tray/unix/status_$status.png',
        );
      }
    });

    test('safe mode shows its own icon whatever the core is doing', () {
      for (final (isStart, tunEnable) in [
        (false, false),
        (true, false),
        (true, true),
      ]) {
        expect(
          windows.getTrayIcon(
            isStart: isStart,
            tunEnable: tunEnable,
            safeMode: true,
          ),
          'assets/images/tray/windows/status_4.ico',
        );
        expect(
          linux.getTrayIcon(
            isStart: isStart,
            tunEnable: tunEnable,
            safeMode: true,
          ),
          'assets/images/tray/unix/status_4.png',
        );
        expect(
          macOS.getTrayIcon(
            isStart: isStart,
            tunEnable: tunEnable,
            safeMode: true,
          ),
          'assets/images/tray/macos/status_4.png',
        );
      }
    });
  });
}
