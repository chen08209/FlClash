import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart';

import 'proxy_platform_interface.dart';

enum ProxyTypes { http, https, socks }

typedef ProxyProcessRunner = Future<ProcessResult> Function(
  String executable,
  List<String> arguments, {
  bool runInShell,
});

typedef ProxyExecutableChecker = Future<bool> Function(String executable);

@immutable
class ProxyCommand {
  final String executable;
  final List<String> args;
  final bool runInShell;

  const ProxyCommand(
    this.executable,
    this.args, {
    this.runInShell = false,
  });
}

enum LinuxProxyBackend {
  gnome,
  mate,
  kde,
}

class Proxy extends ProxyPlatform {
  static String url = '127.0.0.1';

  final ProxyProcessRunner _processRunner;
  final ProxyExecutableChecker _executableChecker;

  Proxy({
    ProxyProcessRunner? processRunner,
    ProxyExecutableChecker? executableChecker,
  })  : _processRunner = processRunner ?? Process.run,
        _executableChecker = executableChecker ?? _hasExecutable;

  @override
  Future<bool?> startProxy(
    int port, [
    List<String> bypassDomain = const [],
  ]) async {
    return switch (Platform.operatingSystem) {
      'macos' => await _startProxyWithMacos(port, bypassDomain),
      'linux' => await _startProxyWithLinux(port, bypassDomain),
      'windows' => await ProxyPlatform.instance.startProxy(port, bypassDomain),
      String() => false,
    };
  }

  @override
  Future<bool?> stopProxy() async {
    return switch (Platform.operatingSystem) {
      'macos' => await _stopProxyWithMacos(),
      'linux' => await _stopProxyWithLinux(),
      'windows' => await ProxyPlatform.instance.stopProxy(),
      String() => false,
    };
  }

  Future<bool> _startProxyWithLinux(int port, List<String> bypassDomain) async {
    final homeDir = Platform.environment['HOME'];
    if (homeDir == null || homeDir.isEmpty) {
      return false;
    }
    final commands = await _resolveLinuxStartCommands(
      port,
      bypassDomain,
      desktop: Platform.environment['XDG_CURRENT_DESKTOP'],
      homeDir: homeDir,
    );
    if (commands.isEmpty) {
      return false;
    }
    return _runCommands(commands);
  }

  Future<bool> _stopProxyWithLinux() async {
    final homeDir = Platform.environment['HOME'];
    if (homeDir == null || homeDir.isEmpty) {
      return false;
    }
    final commands = await _resolveLinuxStopCommands(
      desktop: Platform.environment['XDG_CURRENT_DESKTOP'],
      homeDir: homeDir,
    );
    if (commands.isEmpty) {
      return false;
    }
    return _runCommands(commands);
  }

  Future<bool> _startProxyWithMacos(int port, List<String> bypassDomain) async {
    final devices = await _getNetworkDeviceListWithMacos();
    final commands = devices.expand(
      (dev) => _buildMacosStartCommands(
        dev,
        port,
        bypassDomain,
      ),
    );
    return _runCommands(commands);
  }

  Future<bool> _stopProxyWithMacos() async {
    final devices = await _getNetworkDeviceListWithMacos();
    final commands = devices.expand(_buildMacosStopCommands);
    // Disabling must be attempted on every service: aborting on the first
    // failure would leave the remaining ones proxied.
    return _runAllCommands(commands);
  }

  Future<List<String>> _getNetworkDeviceListWithMacos() async {
    final res = await _processRunner(
      '/usr/sbin/networksetup',
      ['-listallnetworkservices'],
    );
    if (res.exitCode != 0) {
      return [];
    }
    return _parseMacosNetworkServices(res.stdout.toString());
  }

  Future<bool> _runCommands(Iterable<ProxyCommand> commands) async {
    try {
      for (final command in commands) {
        final result = await _processRunner(
          command.executable,
          command.args,
          runInShell: command.runInShell,
        );
        if (result.exitCode != 0) {
          return false;
        }
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Runs every command even if one fails, reporting whether all succeeded.
  Future<bool> _runAllCommands(Iterable<ProxyCommand> commands) async {
    var success = true;
    for (final command in commands) {
      try {
        final result = await _processRunner(
          command.executable,
          command.args,
          runInShell: command.runInShell,
        );
        if (result.exitCode != 0) {
          success = false;
        }
      } catch (_) {
        success = false;
      }
    }
    return success;
  }

  Future<List<ProxyCommand>> _resolveLinuxStartCommands(
    int port,
    List<String> bypassDomain, {
    required String? desktop,
    required String homeDir,
  }) async {
    final backend = await _resolveLinuxBackend(desktop);
    if (backend == null) {
      return [];
    }
    return _buildLinuxStartCommands(
      port: port,
      bypassDomain: bypassDomain,
      desktop: desktop,
      homeDir: homeDir,
      backend: backend,
      kdeConfigWriter: await _resolveKdeConfigWriter(),
    );
  }

  Future<List<ProxyCommand>> _resolveLinuxStopCommands({
    required String? desktop,
    required String homeDir,
  }) async {
    final backend = await _resolveLinuxBackend(desktop);
    if (backend == null) {
      return [];
    }
    return _buildLinuxStopCommands(
      desktop: desktop,
      homeDir: homeDir,
      backend: backend,
      kdeConfigWriter: await _resolveKdeConfigWriter(),
    );
  }

  Future<LinuxProxyBackend?> _resolveLinuxBackend(String? desktop) async {
    final preferredBackend = _preferredLinuxBackend(desktop);
    if (preferredBackend != null) {
      return preferredBackend;
    }
    for (final backend in LinuxProxyBackend.values) {
      if (await _isLinuxBackendAvailable(backend)) {
        return backend;
      }
    }
    return null;
  }

  Future<bool> _isLinuxBackendAvailable(LinuxProxyBackend backend) async {
    return switch (backend) {
      LinuxProxyBackend.gnome => await _executableChecker('gsettings'),
      LinuxProxyBackend.mate => await _executableChecker('gsettings'),
      LinuxProxyBackend.kde => await _executableChecker('kwriteconfig6') ||
          await _executableChecker('kwriteconfig5'),
    };
  }

  Future<String> _resolveKdeConfigWriter() async {
    if (await _executableChecker('kwriteconfig6')) {
      return 'kwriteconfig6';
    }
    return 'kwriteconfig5';
  }

  static Future<bool> _hasExecutable(String executable) async {
    try {
      final result = await Process.run('which', [executable]);
      return result.exitCode == 0;
    } catch (_) {
      // Minimal images may not ship `which`; a failed probe must not abort
      // system-proxy configuration.
      return false;
    }
  }

  static LinuxProxyBackend? _preferredLinuxBackend(String? desktop) {
    final desktops = _linuxDesktops(desktop);
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

  static Set<String> _linuxDesktops(String? desktop) {
    if (desktop == null || desktop.isEmpty) {
      return {};
    }
    return desktop
        .split(':')
        .map((value) => value.trim().toUpperCase())
        .where((value) => value.isNotEmpty)
        .toSet();
  }

  static List<ProxyCommand> _buildLinuxStartCommands({
    required int port,
    required List<String> bypassDomain,
    required String? desktop,
    required String homeDir,
    LinuxProxyBackend? backend,
    String kdeConfigWriter = 'kwriteconfig5',
    Set<String>? availableExecutables,
  }) {
    final resolvedBackend = backend ??
        _resolveLinuxBackendForBuild(
          desktop: desktop,
          availableExecutables: availableExecutables,
        );
    if (resolvedBackend == null) {
      return [];
    }
    return switch (resolvedBackend) {
      LinuxProxyBackend.gnome => _buildGSettingsStartCommands(
          port: port,
          bypassDomain: bypassDomain,
          schemaPrefix: 'org.gnome.system.proxy',
        ),
      LinuxProxyBackend.mate => _buildGSettingsStartCommands(
          port: port,
          bypassDomain: bypassDomain,
          schemaPrefix: 'org.mate.system.proxy',
        ),
      LinuxProxyBackend.kde => _buildKdeStartCommands(
          port: port,
          bypassDomain: bypassDomain,
          homeDir: homeDir,
          executable: _resolveKdeConfigWriterForBuild(
            availableExecutables,
            fallback: kdeConfigWriter,
          ),
        ),
    };
  }

  static List<ProxyCommand> _buildLinuxStopCommands({
    required String? desktop,
    required String homeDir,
    LinuxProxyBackend? backend,
    String kdeConfigWriter = 'kwriteconfig5',
    Set<String>? availableExecutables,
  }) {
    final resolvedBackend = backend ??
        _resolveLinuxBackendForBuild(
          desktop: desktop,
          availableExecutables: availableExecutables,
        );
    if (resolvedBackend == null) {
      return [];
    }
    return switch (resolvedBackend) {
      LinuxProxyBackend.gnome => _buildGSettingsStopCommands(
          schemaPrefix: 'org.gnome.system.proxy',
        ),
      LinuxProxyBackend.mate => _buildGSettingsStopCommands(
          schemaPrefix: 'org.mate.system.proxy',
        ),
      LinuxProxyBackend.kde => _buildKdeStopCommands(
          homeDir: homeDir,
          executable: _resolveKdeConfigWriterForBuild(
            availableExecutables,
            fallback: kdeConfigWriter,
          ),
        ),
    };
  }

  static LinuxProxyBackend? _resolveLinuxBackendForBuild({
    required String? desktop,
    required Set<String>? availableExecutables,
  }) {
    final preferredBackend = _preferredLinuxBackend(desktop);
    if (preferredBackend != null) {
      return preferredBackend;
    }
    if (availableExecutables == null) {
      return LinuxProxyBackend.gnome;
    }
    for (final backend in LinuxProxyBackend.values) {
      if (_isLinuxBackendAvailableForBuild(backend, availableExecutables)) {
        return backend;
      }
    }
    return null;
  }

  static bool _isLinuxBackendAvailableForBuild(
    LinuxProxyBackend backend,
    Set<String> availableExecutables,
  ) {
    return switch (backend) {
      LinuxProxyBackend.gnome => availableExecutables.contains('gsettings'),
      LinuxProxyBackend.mate => availableExecutables.contains('gsettings'),
      LinuxProxyBackend.kde => availableExecutables.contains('kwriteconfig6') ||
          availableExecutables.contains('kwriteconfig5'),
    };
  }

  static String _resolveKdeConfigWriterForBuild(
    Set<String>? availableExecutables, {
    required String fallback,
  }) {
    if (availableExecutables?.contains('kwriteconfig6') ?? false) {
      return 'kwriteconfig6';
    }
    if (availableExecutables?.contains('kwriteconfig5') ?? false) {
      return 'kwriteconfig5';
    }
    return fallback;
  }

  static List<ProxyCommand> _buildGSettingsStartCommands({
    required int port,
    required List<String> bypassDomain,
    required String schemaPrefix,
  }) {
    final commands = <ProxyCommand>[
      ProxyCommand(
        'gsettings',
        ['set', schemaPrefix, 'mode', 'manual'],
      ),
      ProxyCommand(
        'gsettings',
        [
          'set',
          schemaPrefix,
          'ignore-hosts',
          _formatGSettingsStringList(bypassDomain),
        ],
      ),
    ];
    for (final type in ProxyTypes.values) {
      commands.addAll([
        ProxyCommand(
          'gsettings',
          [
            'set',
            '$schemaPrefix.${type.name}',
            'host',
            url,
          ],
        ),
        ProxyCommand(
          'gsettings',
          [
            'set',
            '$schemaPrefix.${type.name}',
            'port',
            '$port',
          ],
        ),
      ]);
    }
    return commands;
  }

  static List<ProxyCommand> _buildGSettingsStopCommands({
    required String schemaPrefix,
  }) {
    return [
      ProxyCommand(
        'gsettings',
        ['set', schemaPrefix, 'mode', 'none'],
      ),
    ];
  }

  static List<ProxyCommand> _buildKdeStartCommands({
    required int port,
    required List<String> bypassDomain,
    required String homeDir,
    required String executable,
  }) {
    final configDir = join(homeDir, '.config');
    final commands = <ProxyCommand>[];
    commands.addAll([
      ProxyCommand(
        executable,
        [
          '--file',
          join(configDir, 'kioslaverc'),
          '--group',
          'Proxy Settings',
          '--key',
          'ProxyType',
          '1',
        ],
      ),
      ProxyCommand(
        executable,
        [
          '--file',
          join(configDir, 'kioslaverc'),
          '--group',
          'Proxy Settings',
          '--key',
          'NoProxyFor',
          bypassDomain.join(','),
        ],
      ),
    ]);
    for (final type in ProxyTypes.values) {
      commands.add(
        ProxyCommand(
          executable,
          [
            '--file',
            join(configDir, 'kioslaverc'),
            '--group',
            'Proxy Settings',
            '--key',
            '${type.name}Proxy',
            '${type.name}://$url:$port',
          ],
        ),
      );
    }
    return commands;
  }

  static List<ProxyCommand> _buildKdeStopCommands({
    required String homeDir,
    required String executable,
  }) {
    return [
      ProxyCommand(
        executable,
        [
          '--file',
          join(homeDir, '.config', 'kioslaverc'),
          '--group',
          'Proxy Settings',
          '--key',
          'ProxyType',
          '0',
        ],
      ),
    ];
  }

  static String _formatGSettingsStringList(List<String> values) {
    if (values.isEmpty) {
      return '[]';
    }
    final escaped = values.map((value) => "'${value.replaceAll("'", "\\'")}'");
    return '[${escaped.join(', ')}]';
  }

  static List<ProxyCommand> _buildMacosStartCommands(
    String dev,
    int port,
    List<String> bypassDomain,
  ) {
    return [
      ProxyCommand(
        '/usr/sbin/networksetup',
        ['-setwebproxy', dev, url, '$port'],
      ),
      ProxyCommand(
        '/usr/sbin/networksetup',
        ['-setwebproxystate', dev, 'on'],
      ),
      ProxyCommand(
        '/usr/sbin/networksetup',
        ['-setsecurewebproxy', dev, url, '$port'],
      ),
      ProxyCommand(
        '/usr/sbin/networksetup',
        ['-setsecurewebproxystate', dev, 'on'],
      ),
      ProxyCommand(
        '/usr/sbin/networksetup',
        ['-setsocksfirewallproxy', dev, url, '$port'],
      ),
      ProxyCommand(
        '/usr/sbin/networksetup',
        ['-setsocksfirewallproxystate', dev, 'on'],
      ),
      _buildMacosProxyBypassCommand(dev, bypassDomain),
    ];
  }

  static List<ProxyCommand> _buildMacosStopCommands(String dev) {
    return [
      ProxyCommand(
        '/usr/sbin/networksetup',
        ['-setautoproxystate', dev, 'off'],
      ),
      ProxyCommand(
        '/usr/sbin/networksetup',
        ['-setwebproxystate', dev, 'off'],
      ),
      ProxyCommand(
        '/usr/sbin/networksetup',
        ['-setsecurewebproxystate', dev, 'off'],
      ),
      ProxyCommand(
        '/usr/sbin/networksetup',
        ['-setsocksfirewallproxystate', dev, 'off'],
      ),
      _buildMacosProxyBypassCommand(dev, const []),
    ];
  }

  static ProxyCommand _buildMacosProxyBypassCommand(
    String dev,
    List<String> bypassDomain,
  ) {
    return ProxyCommand(
      '/usr/sbin/networksetup',
      [
        '-setproxybypassdomains',
        dev,
        if (bypassDomain.isEmpty) 'Empty' else ...bypassDomain,
      ],
    );
  }

  static List<String> _parseMacosNetworkServices(String stdout) {
    return stdout
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .where((line) => !line.startsWith('*'))
        .where((line) => !line.startsWith('An asterisk '))
        .toList();
  }

  @visibleForTesting
  static List<ProxyCommand> buildLinuxStartCommandsForTest({
    required int port,
    required List<String> bypassDomain,
    required String? desktop,
    required String homeDir,
    Set<String>? availableExecutables,
  }) {
    return _buildLinuxStartCommands(
      port: port,
      bypassDomain: bypassDomain,
      desktop: desktop,
      homeDir: homeDir,
      availableExecutables: availableExecutables,
    );
  }

  @visibleForTesting
  static List<String> parseMacosNetworkServicesForTest(String stdout) {
    return _parseMacosNetworkServices(stdout);
  }

  @visibleForTesting
  static ProxyCommand buildMacosProxyBypassCommandForTest(
    String dev,
    List<String> bypassDomain,
  ) {
    return _buildMacosProxyBypassCommand(dev, bypassDomain);
  }
}
