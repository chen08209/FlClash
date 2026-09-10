import 'package:fl_clash/common/print.dart';
import 'package:fl_clash/common/proxy.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';

Future<void> syncSystemProxy(ProxyState proxyState) async {
  final isStart = proxyState.isStart;
  final systemProxy = proxyState.systemProxy;
  final port = proxyState.port;
  bool? result;
  if (isStart && systemProxy) {
    result = await proxy?.startProxy(port, proxyState.bassDomain);
  } else {
    result = await proxy?.stopProxy();
  }
  if (result == false) {
    commonPrint.log('update system proxy failed', logLevel: LogLevel.warning);
  }
}
