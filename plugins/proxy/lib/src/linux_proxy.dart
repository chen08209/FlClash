import 'dart:io';

import 'package:path/path.dart' as path;

import 'proxy_command.dart';

enum LinuxProxyBackend { gnome, mate, kde }

enum _ProxyType { http, https, socks }

const _fallbackBackends = [LinuxProxyBackend.gnome, LinuxProxyBackend.kde];

class LinuxProxy {
  final ProxyCommandRunner _commandRunner;
  final ProxyExecutableChecker _executableChecker;

  LinuxProxy({
    required ProxyCommandRunner commandRunner,
    ProxyExecutableChecker? executableChecker,
  }) : _commandRunner = commandRunner,
       _executableChecker = executableChecker ?? _hasExecutable;

  Future<bool> start(
    int port,
    List<String> bypassDomain, {
    required String? desktop,
    required String? homeDir,
  }) async {
    if (homeDir == null || homeDir.isEmpty) {
      return false;
    }
    final selection = await _resolveBackend(desktop);
    if (selection == null) {
      return false;
    }
    return _commandRunner.run(
      LinuxProxyCommands.buildStartForBackend(
        port: port,
        bypassDomain: bypassDomain,
        homeDir: homeDir,
        backend: selection.backend,
        kdeConfigWriter: selection.executable,
      ),
    );
  }

  Future<bool> stop({
    required String? desktop,
    required String? homeDir,
  }) async {
    if (homeDir == null || homeDir.isEmpty) {
      return false;
    }
    final selection = await _resolveBackend(desktop);
    if (selection == null) {
      return false;
    }
    return _commandRunner.run(
      LinuxProxyCommands.buildStopForBackend(
        homeDir: homeDir,
        backend: selection.backend,
        kdeConfigWriter: selection.executable,
      ),
    );
  }

  Future<_LinuxBackendSelection?> _resolveBackend(String? desktop) async {
    final preferredBackend = LinuxProxyCommands.preferredBackend(desktop);
    if (preferredBackend != null) {
      return _resolveSelection(preferredBackend);
    }
    for (final backend in _fallbackBackends) {
      final selection = await _resolveSelection(backend);
      if (selection != null) {
        return selection;
      }
    }
    return null;
  }

  Future<_LinuxBackendSelection?> _resolveSelection(
    LinuxProxyBackend backend,
  ) async {
    switch (backend) {
      case LinuxProxyBackend.gnome:
      case LinuxProxyBackend.mate:
        if (await _executableChecker('gsettings')) {
          return _LinuxBackendSelection(backend, 'gsettings');
        }
        return null;
      case LinuxProxyBackend.kde:
        for (final executable in const ['kwriteconfig6', 'kwriteconfig5']) {
          if (await _executableChecker(executable)) {
            return _LinuxBackendSelection(backend, executable);
          }
        }
    }
    return null;
  }

  static Future<bool> _hasExecutable(String executable) async {
    try {
      final result = await Process.run('which', [executable]);
      return result.exitCode == 0;
    } on ProcessException {
      return false;
    }
  }
}

class LinuxProxyCommands {
  static LinuxProxyBackend? preferredBackend(String? desktop) {
    final desktops = _desktops(desktop);
    if (desktops.contains('KDE')) {
      return LinuxProxyBackend.kde;
    }
    if (desktops.contains('MATE')) {
      return LinuxProxyBackend.mate;
    }
    if (desktops.any(
      (desktop) =>
          const {'GNOME', 'CINNAMON', 'BUDGIE', 'UNITY'}.contains(desktop),
    )) {
      return LinuxProxyBackend.gnome;
    }
    return null;
  }

  static List<ProxyCommand> buildStart({
    required int port,
    required List<String> bypassDomain,
    required String? desktop,
    required String homeDir,
    Set<String>? availableExecutables,
  }) {
    final backend = _resolveBackend(
      desktop: desktop,
      availableExecutables: availableExecutables,
    );
    if (backend == null) {
      return [];
    }
    return buildStartForBackend(
      port: port,
      bypassDomain: bypassDomain,
      homeDir: homeDir,
      backend: backend,
      kdeConfigWriter: _resolveKdeConfigWriter(availableExecutables),
    );
  }

  static List<ProxyCommand> buildStop({
    required String? desktop,
    required String homeDir,
    Set<String>? availableExecutables,
  }) {
    final backend = _resolveBackend(
      desktop: desktop,
      availableExecutables: availableExecutables,
    );
    if (backend == null) {
      return [];
    }
    return buildStopForBackend(
      homeDir: homeDir,
      backend: backend,
      kdeConfigWriter: _resolveKdeConfigWriter(availableExecutables),
    );
  }

  static List<ProxyCommand> buildStartForBackend({
    required int port,
    required List<String> bypassDomain,
    required String homeDir,
    required LinuxProxyBackend backend,
    required String kdeConfigWriter,
  }) {
    return switch (backend) {
      LinuxProxyBackend.gnome => _buildGSettingsStart(
        port: port,
        bypassDomain: bypassDomain,
        schemaPrefix: 'org.gnome.system.proxy',
      ),
      LinuxProxyBackend.mate => _buildGSettingsStart(
        port: port,
        bypassDomain: bypassDomain,
        schemaPrefix: 'org.mate.system.proxy',
      ),
      LinuxProxyBackend.kde => _buildKdeStart(
        port: port,
        bypassDomain: bypassDomain,
        homeDir: homeDir,
        executable: kdeConfigWriter,
      ),
    };
  }

  static List<ProxyCommand> buildStopForBackend({
    required String homeDir,
    required LinuxProxyBackend backend,
    required String kdeConfigWriter,
  }) {
    return switch (backend) {
      LinuxProxyBackend.gnome => _buildGSettingsStop(
        schemaPrefix: 'org.gnome.system.proxy',
      ),
      LinuxProxyBackend.mate => _buildGSettingsStop(
        schemaPrefix: 'org.mate.system.proxy',
      ),
      LinuxProxyBackend.kde => _buildKdeStop(
        homeDir: homeDir,
        executable: kdeConfigWriter,
      ),
    };
  }

  static LinuxProxyBackend? _resolveBackend({
    required String? desktop,
    required Set<String>? availableExecutables,
  }) {
    final preferred = preferredBackend(desktop);
    if (preferred != null) {
      if (availableExecutables == null ||
          _isBackendAvailable(preferred, availableExecutables)) {
        return preferred;
      }
      return null;
    }
    if (availableExecutables == null) {
      return LinuxProxyBackend.gnome;
    }
    for (final backend in _fallbackBackends) {
      if (_isBackendAvailable(backend, availableExecutables)) {
        return backend;
      }
    }
    return null;
  }

  static bool _isBackendAvailable(
    LinuxProxyBackend backend,
    Set<String> availableExecutables,
  ) {
    return switch (backend) {
      LinuxProxyBackend.gnome ||
      LinuxProxyBackend.mate => availableExecutables.contains('gsettings'),
      LinuxProxyBackend.kde =>
        availableExecutables.contains('kwriteconfig6') ||
            availableExecutables.contains('kwriteconfig5'),
    };
  }

  static String _resolveKdeConfigWriter(Set<String>? availableExecutables) {
    if (availableExecutables?.contains('kwriteconfig6') ?? false) {
      return 'kwriteconfig6';
    }
    return 'kwriteconfig5';
  }

  static List<ProxyCommand> _buildGSettingsStart({
    required int port,
    required List<String> bypassDomain,
    required String schemaPrefix,
  }) {
    final commands = <ProxyCommand>[
      ProxyCommand('gsettings', [
        'set',
        schemaPrefix,
        'ignore-hosts',
        _formatGSettingsStringList(bypassDomain),
      ]),
    ];
    for (final type in _ProxyType.values) {
      commands.addAll([
        ProxyCommand('gsettings', [
          'set',
          '$schemaPrefix.${type.name}',
          'host',
          proxyHost,
        ]),
        ProxyCommand('gsettings', [
          'set',
          '$schemaPrefix.${type.name}',
          'port',
          '$port',
        ]),
      ]);
    }
    commands.add(
      ProxyCommand('gsettings', ['set', schemaPrefix, 'mode', 'manual']),
    );
    return commands;
  }

  static List<ProxyCommand> _buildGSettingsStop({
    required String schemaPrefix,
  }) {
    return [
      ProxyCommand('gsettings', ['set', schemaPrefix, 'mode', 'none']),
    ];
  }

  static List<ProxyCommand> _buildKdeStart({
    required int port,
    required List<String> bypassDomain,
    required String homeDir,
    required String executable,
  }) {
    final configFile = path.join(homeDir, '.config', 'kioslaverc');
    return [
      ProxyCommand(executable, [
        '--file',
        configFile,
        '--group',
        'Proxy Settings',
        '--key',
        'NoProxyFor',
        bypassDomain.join(','),
      ]),
      for (final type in _ProxyType.values)
        ProxyCommand(executable, [
          '--file',
          configFile,
          '--group',
          'Proxy Settings',
          '--key',
          '${type.name}Proxy',
          '${type.name}://$proxyHost:$port',
        ]),
      ProxyCommand(executable, [
        '--file',
        configFile,
        '--group',
        'Proxy Settings',
        '--key',
        'ProxyType',
        '1',
      ]),
    ];
  }

  static List<ProxyCommand> _buildKdeStop({
    required String homeDir,
    required String executable,
  }) {
    return [
      ProxyCommand(executable, [
        '--file',
        path.join(homeDir, '.config', 'kioslaverc'),
        '--group',
        'Proxy Settings',
        '--key',
        'ProxyType',
        '0',
      ]),
    ];
  }

  static String _formatGSettingsStringList(List<String> values) {
    final escaped = values.map((value) {
      return value.replaceAll(r'\', r'\\').replaceAll("'", r"\'");
    });
    return "[${escaped.map((value) => "'$value'").join(', ')}]";
  }

  static Set<String> _desktops(String? desktop) {
    if (desktop == null || desktop.isEmpty) {
      return {};
    }
    return desktop
        .split(':')
        .map((value) => value.trim().toUpperCase())
        .where((value) => value.isNotEmpty)
        .toSet();
  }
}

class _LinuxBackendSelection {
  final LinuxProxyBackend backend;
  final String executable;

  const _LinuxBackendSelection(this.backend, this.executable);
}
