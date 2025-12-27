import 'package:fl_clash/common/function.dart';
import 'package:fl_clash/core/core.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/plugins/app.dart';
import 'package:fl_clash/plugins/service.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AndroidManager extends ConsumerStatefulWidget {
  final Widget child;

  const AndroidManager({super.key, required this.child});

  @override
  ConsumerState<AndroidManager> createState() => _AndroidContainerState();
}

class _AndroidContainerState extends ConsumerState<AndroidManager>
    with ServiceListener {
  @override
  void initState() {
    super.initState();
    ref.listenManual(appSettingProvider.select((state) => state.hidden), (
      prev,
      next,
    ) {
      app?.updateExcludeFromRecents(next);
    }, fireImmediately: true);
    ref.listenManual(sharedStateProvider, (prev, next) {
      if (prev != next) {
        debouncer.call(FunctionTag.saveSharedFile, () async {
          globalState.saveSharedFile();
        }, duration: Duration(seconds: 1));
        if (prev?.needSyncSharedState != next.needSyncSharedState) {
          service?.syncState(next.needSyncSharedState);
        }
      }
    });
    service?.addListener(this);
  }

  @override
  Future<void> dispose() async {
    service?.removeListener(this);
    super.dispose();
  }

  @override
  void onServiceEvent(CoreEvent event) {
    coreEventManager.sendEvent(event);
    super.onServiceEvent(event);
  }

  @override
  void onServiceCrash(String message) {
    coreEventManager.sendEvent(
      CoreEvent(type: CoreEventType.crash, data: message),
    );
    super.onServiceCrash(message);
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
