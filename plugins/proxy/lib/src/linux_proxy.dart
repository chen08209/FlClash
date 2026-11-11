import 'dart:io';

import 'package:path/path.dart' as path;

import 'proxy_command.dart';

enum LinuxProxyBackend { gnome, kde }

enum _ProxyType { http, https, socks }

const _fallbackBackends = [LinuxProxyBackend.gnome, LinuxProxyBackend.kde];

/// Firefox, Chromium and GIO read only this schema, whatever the desktop.
const _gnomeProxySchema = 'org.gnome.system.proxy';

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
        mirrorGnome: selection.mirrorGnome,
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
        mirrorGnome: selection.mirrorGnome,
      ),
    );
  }

  Future<_LinuxBackendSelection?> _resolveBackend(String? desktop) async {
    final preferredBackend = LinuxProxyCommands.preferredBackend(desktop);
    if (preferredBackend != null) {
      return _resolveSelection(preferredBackend, probeGnome: true);
    }
    // GNOME is tried first, so reaching KDE here means gsettings is missing.
    for (final backend in _fallbackBackends) {
      final selection = await _resolveSelection(backend, probeGnome: false);
      if (selection != null) {
        return selection;
      }
    }
    return null;
  }

  Future<_LinuxBackendSelection?> _resolveSelection(
    LinuxProxyBackend backend, {
    required bool probeGnome,
  }) async {
    switch (backend) {
      case LinuxProxyBackend.gnome:
        if (await _executableChecker('gsettings')) {
          return _LinuxBackendSelection(backend, 'gsettings');
        }
        return null;
      case LinuxProxyBackend.kde:
        for (final executable in const ['kwriteconfig6', 'kwriteconfig5']) {
          if (await _executableChecker(executable)) {
            return _LinuxBackendSelection(
              backend,
              executable,
              mirrorGnome: probeGnome && await _executableChecker('gsettings'),
            );
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
    if (desktops.any(
      (desktop) => const {
        'GNOME',
        'CINNAMON',
        'BUDGIE',
        'UNITY',
        'MATE',
      }.contains(desktop),
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
      mirrorGnome: availableExecutables?.contains('gsettings') ?? true,
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
      mirrorGnome: availableExecutables?.contains('gsettings') ?? true,
    );
  }

  static List<ProxyCommand> buildStartForBackend({
    required int port,
    required List<String> bypassDomain,
    required String homeDir,
    required LinuxProxyBackend backend,
    required String kdeConfigWriter,
    bool mirrorGnome = false,
  }) {
    return switch (backend) {
      LinuxProxyBackend.gnome => _buildGSettingsStart(
        port: port,
        bypassDomain: bypassDomain,
        schemaPrefix: _gnomeProxySchema,
      ),
      LinuxProxyBackend.kde => [
        ..._buildKdeStart(
          port: port,
          bypassDomain: bypassDomain,
          homeDir: homeDir,
          executable: kdeConfigWriter,
        ),
        if (mirrorGnome)
          ..._buildGSettingsStart(
            port: port,
            bypassDomain: bypassDomain,
            schemaPrefix: _gnomeProxySchema,
            optional: true,
          ),
      ],
    };
  }

  static List<ProxyCommand> buildStopForBackend({
    required String homeDir,
    required LinuxProxyBackend backend,
    required String kdeConfigWriter,
    bool mirrorGnome = false,
  }) {
    return switch (backend) {
      LinuxProxyBackend.gnome => _buildGSettingsStop(
        schemaPrefix: _gnomeProxySchema,
      ),
      LinuxProxyBackend.kde => [
        ..._buildKdeStop(homeDir: homeDir, executable: kdeConfigWriter),
        if (mirrorGnome)
          ..._buildGSettingsStop(
            schemaPrefix: _gnomeProxySchema,
            optional: true,
          ),
      ],
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
      LinuxProxyBackend.gnome => availableExecutables.contains('gsettings'),
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
    bool optional = false,
  }) {
    final commands = <ProxyCommand>[
      ProxyCommand('gsettings', [
        'set',
        schemaPrefix,
        'ignore-hosts',
        _formatGSettingsStringList(bypassDomain),
      ], optional: optional),
    ];
    for (final type in _ProxyType.values) {
      commands.addAll([
        ProxyCommand('gsettings', [
          'set',
          '$schemaPrefix.${type.name}',
          'host',
          proxyHost,
        ], optional: optional),
        ProxyCommand('gsettings', [
          'set',
          '$schemaPrefix.${type.name}',
          'port',
          '$port',
        ], optional: optional),
      ]);
    }
    commands.add(
      ProxyCommand('gsettings', [
        'set',
        schemaPrefix,
        'mode',
        'manual',
      ], optional: optional),
    );
    return commands;
  }

  static List<ProxyCommand> _buildGSettingsStop({
    required String schemaPrefix,
    bool optional = false,
  }) {
    return [
      ProxyCommand('gsettings', [
        'set',
        schemaPrefix,
        'mode',
        'none',
      ], optional: optional),
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
          '${type == _ProxyType.socks ? 'socks' : 'http'}://$proxyHost:$port',
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
      _kdeReparseConfiguration,
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
      _kdeReparseConfiguration,
    ];
  }

  /// Running KIO programs keep the settings they read at startup until this
  /// signal, which is what the KDE proxy settings page sends after saving.
  static final _kdeReparseConfiguration = ProxyCommand('dbus-send', [
    '--session',
    '--type=signal',
    '/KIO/Scheduler',
    'org.kde.KIO.Scheduler.reparseSlaveConfiguration',
    'string:',
  ], optional: true);

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
  final bool mirrorGnome;

  const _LinuxBackendSelection(
    this.backend,
    this.executable, {
    this.mirrorGnome = false,
  });
}
