import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi_ssid/wifi_ssid.dart';

typedef SsidReader = Future<String?> Function();

class ConnectivityManager extends ConsumerStatefulWidget {
  final Function(List<ConnectivityResult> results)? onConnectivityChanged;
  final Stream<List<ConnectivityResult>>? connectivityStream;
  final SsidReader? readSsid;
  final Widget child;

  const ConnectivityManager({
    super.key,
    this.onConnectivityChanged,
    this.connectivityStream,
    this.readSsid,
    required this.child,
  });

  @override
  ConsumerState<ConnectivityManager> createState() =>
      _ConnectivityManagerState();
}

class _ConnectivityManagerState extends ConsumerState<ConnectivityManager> {
  late final StreamSubscription subscription;
  late final SsidReader _readSsid =
      widget.readSsid ?? WifiSsidManager.instance.getSsid;

  int _ssidRequestId = 0;
  bool _onWifi = false;

  @override
  void initState() {
    super.initState();
    final stream =
        widget.connectivityStream ?? Connectivity().onConnectivityChanged;
    subscription = stream.listen(_handleResults);
    ref.listenManual(excludeSSIDsProvider.select((state) => state.isNotEmpty), (
      previous,
      next,
    ) {
      if (previous != next) {
        unawaited(_updateSsid());
      }
    });
  }

  void _handleResults(List<ConnectivityResult> results) {
    _onWifi = results.contains(ConnectivityResult.wifi);
    unawaited(_updateSsid());
    widget.onConnectivityChanged?.call(results);
  }

  Future<void> _updateSsid() async {
    final requestId = ++_ssidRequestId;
    // The SSID costs a blocking platform call and a location permission on
    // Android and macOS, and nothing reads it until a network is excluded.
    if (!_onWifi || ref.read(excludeSSIDsProvider).isEmpty) {
      _publishSsid(requestId, null);
      return;
    }
    try {
      final ssid = await _readSsid();
      if (_publishSsid(requestId, ssid)) {
        commonPrint.log('Wi-fi SSID: $ssid', logLevel: LogLevel.info);
      }
    } catch (error) {
      commonPrint.log(
        'Unable to read the Wi-Fi SSID: $error',
        logLevel: LogLevel.warning,
      );
      _publishSsid(requestId, null);
    }
  }

  bool _publishSsid(int requestId, String? ssid) {
    if (requestId != _ssidRequestId || !mounted) {
      return false;
    }
    ref.read(currentSSIDProvider.notifier).value = ssid;
    return true;
  }

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
