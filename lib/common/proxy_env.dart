enum ProxyCommandOs {
  windows('Windows'),
  linux('Linux'),
  macos('macOS');

  const ProxyCommandOs(this.label);

  final String label;
}

const proxyLoopbackHost = '127.0.0.1';

const minProxyPort = 1024;

const maxProxyPort = 49151;

bool isValidProxyPort(int port) {
  return port >= minProxyPort && port <= maxProxyPort;
}

String proxyHostForCommand({required bool allowLan, required String? localIp}) {
  final host = localIp?.trim();
  return allowLan && host != null && host.isNotEmpty ? host : proxyLoopbackHost;
}

ProxyCommandOs proxyCommandOsForPlatform({
  required bool isWindows,
  required bool isMacOS,
}) {
  if (isWindows) return ProxyCommandOs.windows;
  if (isMacOS) return ProxyCommandOs.macos;
  return ProxyCommandOs.linux;
}

String buildProxyEnvCommand({
  required int port,
  required ProxyCommandOs os,
  String host = proxyLoopbackHost,
}) {
  final url = 'http://$host:$port';
  return switch (os) {
    ProxyCommandOs.windows => [
      '\$env:http_proxy=\'$url\'',
      '\$env:https_proxy=\'$url\'',
      '\$env:all_proxy=\'$url\'',
    ].join('\n'),
    ProxyCommandOs.linux || ProxyCommandOs.macos => [
      'export http_proxy=\'$url\'',
      'export https_proxy=\'$url\'',
      'export all_proxy=\'$url\'',
    ].join('\n'),
  };
}
