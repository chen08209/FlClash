import 'package:fl_clash/common/print.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/manager/proxy_sync.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProxyManager extends ConsumerStatefulWidget {
  final Widget child;

  const ProxyManager({super.key, required this.child});

  @override
  ConsumerState createState() => _ProxyManagerState();
}

class _ProxyManagerState extends ConsumerState<ProxyManager> {
  Future<void> _pendingUpdate = Future.value();

  void _scheduleUpdateProxy(ProxyState proxyState) {
    _pendingUpdate = _pendingUpdate
        .then((_) => syncSystemProxy(proxyState))
        .catchError((Object error) {
          commonPrint.log(
            'update system proxy failed: $error',
            logLevel: LogLevel.warning,
          );
        });
  }

  @override
  void initState() {
    super.initState();
    ref.listenManual(proxyStateProvider, (prev, next) {
      if (prev != next) {
        _scheduleUpdateProxy(next);
      }
    }, fireImmediately: true);
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
