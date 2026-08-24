import 'package:fl_clash/common/provider_reader.dart';
import 'package:fl_clash/models/models.dart';

abstract interface class WindowPort {
  Future<void> show();

  Future<void> hide();

  Future<void> close();

  Future<bool> get isVisible;

  void forceExit();
}

abstract interface class TrayPort {
  Future<void> shutdown();

  Future<void> update({
    required TrayState trayState,
    required Traffic traffic,
    required ProviderReader read,
  });
}

abstract interface class NavigationPort {
  List<NavigationItem> getItems({bool openLogs, bool hasProxies});
}

WindowPort? windowPort;
TrayPort? trayPort;
NavigationPort? navigationPort;
