import 'dart:io';

import 'package:rust_api/rust_api.dart' as rust_api;

import 'constant.dart';
import 'print.dart';

const protocolSchemes = ['clash', 'clashmeta', 'flclash'];

/// A user-level desktop entry that claims the schemes for the running binary,
/// so an AppImage or a development build is reachable without a packaged
/// .desktop file. Rewritten on every launch, like the Windows registry keys.
class LinuxProtocolRegistrationPlan {
  final List<String> schemes;
  final String executable;
  final String applicationsDir;

  const LinuxProtocolRegistrationPlan({
    required this.schemes,
    required this.executable,
    required this.applicationsDir,
  });

  String get desktopId => linuxUrlHandlerDesktopId;

  String get desktopPath => '$applicationsDir/$desktopId';

  List<String> get mimeTypes =>
      schemes.map((scheme) => 'x-scheme-handler/$scheme').toList();

  String get exec => '"${_quoteExecArgument(executable)}" %u';

  String get desktopEntry => [
    '[Desktop Entry]',
    'Type=Application',
    'Name=$packageDisplayName',
    'NoDisplay=true',
    'Exec=$exec',
    'MimeType=${mimeTypes.join(';')};',
    '',
  ].join('\n');

  List<String> get xdgMimeArguments => ['default', desktopId, ...mimeTypes];

  static String _quoteExecArgument(String value) {
    return value
        .replaceAll(r'\', r'\\')
        .replaceAll('"', r'\"')
        .replaceAll(r'$', r'\$')
        .replaceAll('`', r'\`')
        .replaceAll('%', '%%');
  }
}

class Protocol {
  static Protocol? _instance;

  Protocol._internal();

  factory Protocol() {
    _instance ??= Protocol._internal();
    return _instance!;
  }

  Future<void> registerWindows(List<String> schemes) async {
    for (final scheme in schemes) {
      final registered = await rust_api.registerUrlScheme(
        scheme: scheme,
        executable: Platform.resolvedExecutable,
      );
      if (!registered) {
        commonPrint.log('windows protocol registration failed: $scheme');
      }
    }
  }

  Future<void> registerLinux(List<String> schemes) async {
    final env = Platform.environment;
    final home = env['HOME'];
    if (home == null || home.isEmpty) {
      return;
    }
    final dataHome = env['XDG_DATA_HOME'];
    final plan = LinuxProtocolRegistrationPlan(
      schemes: schemes,
      executable: env['APPIMAGE'] ?? Platform.resolvedExecutable,
      applicationsDir:
          '${dataHome?.isNotEmpty == true ? dataHome : '$home/.local/share'}/applications',
    );
    try {
      final file = File(plan.desktopPath);
      await file.parent.create(recursive: true);
      await file.writeAsString(plan.desktopEntry);
      final result = await Process.run('xdg-mime', plan.xdgMimeArguments);
      if (result.exitCode != 0) {
        commonPrint.log('xdg-mime default failed: ${result.stderr}'.trim());
      }
    } catch (e) {
      commonPrint.log('linux protocol registration failed: $e');
    }
  }
}

final protocol = Protocol();
