import 'package:fl_clash/common/proxy_env.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('uses the LAN address only when LAN access is enabled', () {
    expect(
      proxyHostForCommand(allowLan: false, localIp: '192.168.1.20'),
      proxyLoopbackHost,
    );
    expect(
      proxyHostForCommand(allowLan: true, localIp: ' 192.168.1.20 '),
      '192.168.1.20',
    );
    expect(
      proxyHostForCommand(allowLan: true, localIp: null),
      proxyLoopbackHost,
    );
  });

  test('builds the Windows PowerShell command', () {
    expect(
      buildProxyEnvCommand(port: 7890, os: ProxyCommandOs.windows),
      r"""$env:http_proxy='http://127.0.0.1:7890'
$env:https_proxy='http://127.0.0.1:7890'
$env:all_proxy='http://127.0.0.1:7890'""",
    );
  });

  test('builds the Linux shell command', () {
    expect(
      buildProxyEnvCommand(port: 7890, os: ProxyCommandOs.linux),
      r"""export http_proxy='http://127.0.0.1:7890'
export https_proxy='http://127.0.0.1:7890'
export all_proxy='http://127.0.0.1:7890'""",
    );
  });

  test('builds the macOS shell command', () {
    expect(
      buildProxyEnvCommand(port: 7890, os: ProxyCommandOs.macos),
      buildProxyEnvCommand(port: 7890, os: ProxyCommandOs.linux),
    );
  });

  test('builds commands with a LAN host', () {
    expect(
      buildProxyEnvCommand(
        port: 7890,
        os: ProxyCommandOs.linux,
        host: '192.168.1.20',
      ),
      r"""export http_proxy='http://192.168.1.20:7890'
export https_proxy='http://192.168.1.20:7890'
export all_proxy='http://192.168.1.20:7890'""",
    );
  });
}
