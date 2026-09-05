import 'package:fl_clash/enum/enum.dart';
import 'package:material_ui/material_ui.dart';

import 'app_localizations.dart';

extension PageLabelL10n on PageLabel {
  String get label {
    final appLocalizations = currentAppLocalizations;
    return switch (this) {
      PageLabel.dashboard => appLocalizations.dashboard,
      PageLabel.proxies => appLocalizations.proxies,
      PageLabel.profiles => appLocalizations.profiles,
      PageLabel.tools => appLocalizations.tools,
      PageLabel.logs => appLocalizations.logs,
      PageLabel.requests => appLocalizations.requests,
      PageLabel.resources => appLocalizations.resources,
      PageLabel.connections => appLocalizations.connections,
    };
  }

  String? get description {
    final appLocalizations = currentAppLocalizations;
    return switch (this) {
      PageLabel.logs => appLocalizations.logsDesc,
      PageLabel.requests => appLocalizations.requestsDesc,
      PageLabel.resources => appLocalizations.resourcesDesc,
      PageLabel.connections => appLocalizations.connectionsDesc,
      PageLabel.dashboard ||
      PageLabel.proxies ||
      PageLabel.profiles ||
      PageLabel.tools => null,
    };
  }
}

extension ModeL10n on Mode {
  String get label {
    final appLocalizations = currentAppLocalizations;
    return switch (this) {
      Mode.rule => appLocalizations.rule,
      Mode.global => appLocalizations.global,
      Mode.direct => appLocalizations.direct,
    };
  }
}

extension ProxiesTypeL10n on ProxiesType {
  String get label {
    final appLocalizations = currentAppLocalizations;
    return switch (this) {
      ProxiesType.tab => appLocalizations.tab,
      ProxiesType.list => appLocalizations.list,
    };
  }
}

extension ProxyCardTypeL10n on ProxyCardType {
  String get label {
    final appLocalizations = currentAppLocalizations;
    return switch (this) {
      ProxyCardType.expand => appLocalizations.expand,
      ProxyCardType.shrink => appLocalizations.shrink,
      ProxyCardType.min => appLocalizations.min,
    };
  }
}

extension HotActionL10n on HotAction {
  String get label {
    final appLocalizations = currentAppLocalizations;
    return switch (this) {
      HotAction.start => appLocalizations.actionStart,
      HotAction.view => appLocalizations.actionView,
      HotAction.mode => appLocalizations.actionMode,
      HotAction.proxy => appLocalizations.actionProxy,
      HotAction.tun => appLocalizations.actionTun,
    };
  }
}

extension RouteModeL10n on RouteMode {
  String get label {
    final appLocalizations = currentAppLocalizations;
    return switch (this) {
      RouteMode.bypassPrivate => appLocalizations.routeModeBypassPrivate,
      RouteMode.config => appLocalizations.routeModeConfig,
    };
  }
}

extension RestoreStrategyL10n on RestoreStrategy {
  String get label {
    final appLocalizations = currentAppLocalizations;
    return switch (this) {
      RestoreStrategy.compatible => appLocalizations.restoreStrategyCompatible,
      RestoreStrategy.override => appLocalizations.restoreStrategyOverride,
    };
  }
}

extension DynamicSchemeVariantL10n on DynamicSchemeVariant {
  String get label {
    final appLocalizations = currentAppLocalizations;
    return switch (this) {
      DynamicSchemeVariant.tonalSpot => appLocalizations.tonalSpotScheme,
      DynamicSchemeVariant.fidelity => appLocalizations.fidelityScheme,
      DynamicSchemeVariant.monochrome => appLocalizations.monochromeScheme,
      DynamicSchemeVariant.neutral => appLocalizations.neutralScheme,
      DynamicSchemeVariant.vibrant => appLocalizations.vibrantScheme,
      DynamicSchemeVariant.expressive => appLocalizations.expressiveScheme,
      DynamicSchemeVariant.content => appLocalizations.contentScheme,
      DynamicSchemeVariant.rainbow => appLocalizations.rainbowScheme,
      DynamicSchemeVariant.fruitSalad => appLocalizations.fruitSaladScheme,
    };
  }
}

extension LocaleL10n on Locale {
  String get label {
    final appLocalizations = currentAppLocalizations;
    return switch (toString()) {
      'en' => appLocalizations.en,
      'ja' => appLocalizations.ja,
      'ru' => appLocalizations.ru,
      'zh_CN' => appLocalizations.zhCN,
      final code => code,
    };
  }
}
