import 'dart:async';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/core/core.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/action.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/providers/state.dart';
import 'package:fl_clash/state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CoreManager extends ConsumerStatefulWidget {
  final Widget child;

  const CoreManager({super.key, required this.child});

  @override
  ConsumerState<CoreManager> createState() => _CoreContainerState();
}

class _CoreContainerState extends ConsumerState<CoreManager>
    with CoreEventListener {
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  @override
  void initState() {
    super.initState();
    coreEventManager.addListener(this);
    ref.listenManual(currentProfileIdProvider, (prev, next) {
      if (prev != next) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref.read(setupActionProvider.notifier).fullSetup();
        });
      }
    });
    ref.listenManual(updateParamsProvider, (prev, next) {
      if (prev != next) {
        ref.read(setupActionProvider.notifier).updateConfigDebounce();
      }
    });
    ref.listenManual(appSettingProvider.select((state) => state.openLogs), (
      prev,
      next,
    ) {
      if (next) {
        coreController.startLog();
      } else {
        coreController.stopLog();
      }
    }, fireImmediately: true);
  }

  @override
  Future<void> dispose() async {
    coreEventManager.removeListener(this);
    super.dispose();
  }

  @override
  Future<void> onDelay(Delay delay) async {
    super.onDelay(delay);
    final proxiesAction = ref.read(proxiesActionProvider.notifier);
    proxiesAction.setDelay(delay);
    debouncer.call(FunctionTag.updateDelay, () async {
      proxiesAction.updateGroupsDebounce();
    }, duration: const Duration(milliseconds: 5000));
  }

  @override
  void onLog(Log log) {
    ref.read(logsProvider.notifier).add(log);
    if (log.logLevel == LogLevel.error) {
      globalState.showNotifier(log.payload);
    }
    super.onLog(log);
  }

  @override
  void onRequest(TrackerInfo trackerInfo) async {
    ref.read(requestsProvider.notifier).addRequest(trackerInfo);
    super.onRequest(trackerInfo);
  }

  @override
  Future<void> onLoaded(String providerName) async {
    final ref = globalState.container;
    ref
        .read(providersProvider.notifier)
        .setProvider(await coreController.getExternalProvider(providerName));
    debouncer.call(FunctionTag.loadedProvider, () async {
      ref.read(proxiesActionProvider.notifier).updateGroupsDebounce();
    }, duration: const Duration(milliseconds: 5000));
    super.onLoaded(providerName);
  }

  @override
  Future<void> onCrash(String message) async {
    if (ref.read(coreStatusProvider) != CoreStatus.connected) {
      return;
    }
    ref.read(coreStatusProvider.notifier).value = CoreStatus.disconnected;
    if (WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed) {
      context.showNotifier(message);
    }
    await coreController.shutdown(false);
    if (system.isDesktop) {
      // The core is gone and desktop has no auto-restart: release the
      // started state so ProxyManager clears the system proxy instead of
      // leaving it pointed at a dead port. Not awaited: stopListener would
      // block on the dead transport's 10s timeout first, which is exactly
      // the window this is meant to avoid.
      unawaited(ref.read(setupActionProvider.notifier).handleStop());
      ref.read(runTimeProvider.notifier).value = null;
    }
    super.onCrash(message);
  }

  @override
  void onGeoUpdate(String geoType, bool updating, bool skipped, String? error) {
    final geoResource = GeoResource.fromJson(geoType.toLowerCase());
    final key = geoResource.updatingKey;
    final l10n = currentAppLocalizations;
    final hasError = error != null && error.isNotEmpty;
    if (updating) {
      globalState.showNotifier(l10n.geoUpdating(geoResource.name));
    } else if (hasError) {
      // Only the error below; announcing 'updated' first is misleading.
    } else if (skipped) {
      globalState.showNotifier(l10n.geoSkipped(geoResource.name));
    } else {
      globalState.showNotifier(l10n.geoUpdated(geoResource.name));
    }
    ref.read(isUpdatingProvider(key).notifier).value = updating;
    if (!updating && hasError) {
      globalState.showNotifier(error);
    }
    super.onGeoUpdate(geoType, updating, skipped, error);
  }
}
