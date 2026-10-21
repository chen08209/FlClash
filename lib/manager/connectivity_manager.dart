import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/providers/action.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/providers/on_demand.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi_ssid/wifi_ssid.dart';

typedef SsidReader = Future<String?> Function();

class ConnectivityManager extends ConsumerStatefulWidget {
  final Function(List<ConnectivityResult> results)? onConnectivityChanged;
  final Stream<List<ConnectivityResult>>? connectivityStream;
  final SsidReader? readSsid;
  final Future<List<ConnectivityResult>> Function()? checkConnectivity;
  final Widget child;

  const ConnectivityManager({
    super.key,
    this.onConnectivityChanged,
    this.connectivityStream,
    this.readSsid,
    this.checkConnectivity,
    required this.child,
  });

  @override
  ConsumerState<ConnectivityManager> createState() =>
      _ConnectivityManagerState();
}

class _ConnectivityManagerState extends ConsumerState<ConnectivityManager>
    with WidgetsBindingObserver {
  late final StreamSubscription subscription;
  late final SsidReader _readSsid =
      widget.readSsid ?? WifiSsidManager.instance.getSsid;

  int _ssidRequestId = 0;
  int _connectivityRequestId = 0;
  bool _onWifi = false;
  Timer? _ssidTimer;
  (String?, Mode)? _lastModeDecision;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
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
    ref.listenManual(wifiModeSettingProvider, (previous, next) {
      _lastModeDecision = null;
      unawaited(_updateSsid());
    });
    ref.listenManual(
      locationPermissionsProvider.select(
        (permission) => permission == WifiSsidPermission.granted,
      ),
      (previous, next) {
        if (previous != next) {
          unawaited(_updateSsid());
        }
      },
    );
    if (widget.connectivityStream == null || widget.checkConnectivity != null) {
      unawaited(_refreshConnectivity());
    }
  }

  void _handleResults(List<ConnectivityResult> results) {
    _connectivityRequestId++;
    _onWifi = results.contains(ConnectivityResult.wifi);
    unawaited(_updateSsid());
    widget.onConnectivityChanged?.call(results);
  }

  Future<void> _refreshConnectivity() async {
    final requestId = ++_connectivityRequestId;
    try {
      final results =
          await (widget.checkConnectivity ??
              Connectivity().checkConnectivity)();
      if (mounted && requestId == _connectivityRequestId) {
        _handleResults(results);
      }
    } catch (error) {
      commonPrint.log(
        'Unable to check connectivity: $error',
        logLevel: LogLevel.warning,
      );
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_refreshConnectivity());
    }
  }

  Future<void> _updateSsid() async {
    final requestId = ++_ssidRequestId;
    _ssidTimer?.cancel();
    if (!_onWifi ||
        ref.read(safeModeProvider) ||
        (ref.read(excludeSSIDsProvider).isEmpty &&
            !ref.read(wifiModeSettingProvider).enabled)) {
      _publishSsid(requestId, null);
      return;
    }
    try {
      final ssid = await _readSsid().timeout(const Duration(seconds: 4));
      final changed = mounted && ref.read(currentSSIDProvider) != ssid;
      if (_publishSsid(requestId, ssid) && changed) {
        commonPrint.log('Wi-fi SSID: $ssid', logLevel: LogLevel.info);
      }
    } catch (error) {
      commonPrint.log(
        'Unable to read the Wi-Fi SSID: $error',
        logLevel: LogLevel.warning,
      );
      _publishSsid(requestId, null);
    } finally {
      if (mounted &&
          requestId == _ssidRequestId &&
          ref.read(wifiModeSettingProvider).enabled) {
        _ssidTimer = Timer(const Duration(seconds: 5), _updateSsid);
      }
    }
  }

  bool _publishSsid(int requestId, String? ssid) {
    if (requestId != _ssidRequestId || !mounted) {
      return false;
    }
    ref.read(currentSSIDProvider.notifier).value = ssid;
    final settings = ref.read(wifiModeSettingProvider);
    if (settings.enabled && !ref.read(safeModeProvider)) {
      final mode = settings.rules[ssid] ?? settings.fallback;
      final decision = (ssid, mode);
      if (_lastModeDecision != decision) {
        _lastModeDecision = decision;
        if (ref.read(patchClashConfigProvider).mode != mode) {
          ref.read(setupActionProvider.notifier).changeMode(mode);
        }
      }
    }
    return true;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ssidTimer?.cancel();
    subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
