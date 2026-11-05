import 'dart:io';

import 'proxy_command.dart';

class MacosProxy {
  final ProxyCommandRunner _commandRunner;

  MacosProxy({required ProxyCommandRunner commandRunner})
    : _commandRunner = commandRunner;

  Future<bool> start(int port, List<String> bypassDomain) async {
    final services = await _networkServices();
    return _commandRunner.run(
      services.expand(
        (service) => MacosProxyCommands.buildStart(service, port, bypassDomain),
      ),
    );
  }

  Future<bool> stop() async {
    final services = await _networkServices();
    return _commandRunner.run(services.expand(MacosProxyCommands.buildStop));
  }

  /// The loopback port the system proxy is enabled for, or null when none is.
  Future<int?> readLoopbackProxyPort() async {
    final ProcessResult result;
    try {
      result = await _commandRunner.process('/usr/sbin/scutil', ['--proxy']);
    } on ProcessException {
      return null;
    }
    if (result.exitCode != 0) {
      return null;
    }
    return MacosProxyCommands.parseLoopbackProxyPort(result.stdout.toString());
  }

  Future<List<String>> _networkServices() async {
    try {
      final result = await _commandRunner.process('/usr/sbin/networksetup', [
        '-listallnetworkservices',
      ]);
      if (result.exitCode != 0) {
        return [];
      }
      return MacosProxyCommands.parseNetworkServices(result.stdout.toString());
    } on ProcessException {
      return [];
    }
  }
}

class MacosProxyCommands {
  static List<ProxyCommand> buildStart(
    String service,
    int port,
    List<String> bypassDomain,
  ) {
    return [
      ProxyCommand('/usr/sbin/networksetup', [
        '-setwebproxy',
        service,
        proxyHost,
        '$port',
      ]),
      ProxyCommand('/usr/sbin/networksetup', [
        '-setsecurewebproxy',
        service,
        proxyHost,
        '$port',
      ]),
      ProxyCommand('/usr/sbin/networksetup', [
        '-setsocksfirewallproxy',
        service,
        proxyHost,
        '$port',
      ]),
      buildProxyBypass(service, bypassDomain),
      ProxyCommand('/usr/sbin/networksetup', [
        '-setwebproxystate',
        service,
        'on',
      ]),
      ProxyCommand('/usr/sbin/networksetup', [
        '-setsecurewebproxystate',
        service,
        'on',
      ]),
      ProxyCommand('/usr/sbin/networksetup', [
        '-setsocksfirewallproxystate',
        service,
        'on',
      ]),
    ];
  }

  static List<ProxyCommand> buildStop(String service) {
    return [
      ProxyCommand('/usr/sbin/networksetup', [
        '-setautoproxystate',
        service,
        'off',
      ]),
      ProxyCommand('/usr/sbin/networksetup', [
        '-setwebproxystate',
        service,
        'off',
      ]),
      ProxyCommand('/usr/sbin/networksetup', [
        '-setsecurewebproxystate',
        service,
        'off',
      ]),
      ProxyCommand('/usr/sbin/networksetup', [
        '-setsocksfirewallproxystate',
        service,
        'off',
      ]),
      buildProxyBypass(service, const []),
    ];
  }

  static ProxyCommand buildProxyBypass(
    String service,
    List<String> bypassDomain,
  ) {
    return ProxyCommand('/usr/sbin/networksetup', [
      '-setproxybypassdomains',
      service,
      if (bypassDomain.isEmpty) 'Empty' else ...bypassDomain,
    ]);
  }

  /// Reads what `scutil --proxy` reports; only a loopback host answers.
  static int? parseLoopbackProxyPort(String stdout) {
    final values = <String, String>{};
    for (final line in stdout.split('\n')) {
      final separator = line.indexOf(' : ');
      if (separator == -1) {
        continue;
      }
      final key = line.substring(0, separator).trim();
      values[key] = _withoutQuotes(line.substring(separator + 3).trim());
    }
    for (final kind in const ['HTTP', 'HTTPS', 'SOCKS']) {
      if (values['${kind}Enable'] != '1') {
        continue;
      }
      final host = values['${kind}Proxy'];
      final port = int.tryParse(values['${kind}Port'] ?? '');
      if (host == null ||
          port == null ||
          port < 1 ||
          port > 65535 ||
          !_isLoopbackHost(host)) {
        continue;
      }
      return port;
    }
    return null;
  }

  static const _loopbackHosts = {'localhost', '::1', '0:0:0:0:0:0:0:1'};

  static bool _isLoopbackHost(String host) {
    return _loopbackHosts.contains(host) || host.startsWith('127.');
  }

  static String _withoutQuotes(String value) {
    return value.replaceAll('"', '');
  }

  static List<String> parseNetworkServices(String stdout) {
    return stdout
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .where((line) => !line.startsWith('*'))
        .where((line) => !line.startsWith('An asterisk '))
        .toList();
  }
}
