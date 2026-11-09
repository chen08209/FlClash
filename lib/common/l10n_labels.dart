import 'package:fl_clash/enum/enum.dart';
import 'package:flutter/widgets.dart';
import 'package:prism_ui/color.dart';

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
      PageLabel.dns => appLocalizations.dnsQueries,
    };
  }
}

extension DnsQueryInitiatorL10n on DnsQueryInitiator {
  String get label {
    final appLocalizations = currentAppLocalizations;
    return switch (this) {
      DnsQueryInitiator.app => appLocalizations.app,
      DnsQueryInitiator.rule => appLocalizations.rule,
      DnsQueryInitiator.direct => appLocalizations.direct,
      DnsQueryInitiator.proxy => appLocalizations.proxies,
      DnsQueryInitiator.other => appLocalizations.other,
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
      ProxyCardType.loose => appLocalizations.loose,
      ProxyCardType.standard => appLocalizations.standard,
      ProxyCardType.compact => appLocalizations.compact,
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
      HotAction.ruleMode => appLocalizations.actionRuleMode,
      HotAction.globalMode => appLocalizations.actionGlobalMode,
      HotAction.directMode => appLocalizations.actionDirectMode,
      HotAction.delayTest => appLocalizations.actionDelayTest,
      HotAction.updateProfiles => appLocalizations.actionUpdateProfiles,
      HotAction.copyEnv => appLocalizations.copyEnvVar,
      HotAction.exit => appLocalizations.exit,
    };
  }
}

extension MitmListL10n on MitmList {
  String get label {
    final appLocalizations = currentAppLocalizations;
    return switch (this) {
      MitmList.hostname => appLocalizations.hostname,
      MitmList.urlRewrite => appLocalizations.urlRewrite,
      MitmList.headerRewrite => appLocalizations.headerRewrite,
      MitmList.bodyRewrite => appLocalizations.bodyRewrite,
      MitmList.mapLocal => appLocalizations.mapLocal,
      MitmList.script => appLocalizations.script,
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

extension ColorStyleL10n on ColorStyle {
  String get label {
    final appLocalizations = currentAppLocalizations;
    return switch (this) {
      ColorStyle.vivid => appLocalizations.vividStyle,
      ColorStyle.tinted => appLocalizations.tintedStyle,
      ColorStyle.soft => appLocalizations.softStyle,
      ColorStyle.monochrome => appLocalizations.monochromeScheme,
    };
  }
}

extension LocaleL10n on Locale {
  String get label {
    final appLocalizations = currentAppLocalizations;
    return switch (toString()) {
      'en' => appLocalizations.en,
      'es' => appLocalizations.es,
      'fr' => appLocalizations.fr,
      'ja' => appLocalizations.ja,
      'ko' => appLocalizations.ko,
      'ru' => appLocalizations.ru,
      'zh_CN' => appLocalizations.zhCN,
      final code => code,
    };
  }
}

extension RecordFacetKindL10n on RecordFacetKind {
  String? get title {
    final appLocalizations = currentAppLocalizations;
    return switch (this) {
      RecordFacetKind.network => appLocalizations.protocol,
      RecordFacetKind.rule => appLocalizations.rule,
      RecordFacetKind.level => appLocalizations.logLevel,
      RecordFacetKind.mitm ||
      RecordFacetKind.app ||
      RecordFacetKind.proxy ||
      RecordFacetKind.type ||
      RecordFacetKind.initiator ||
      RecordFacetKind.cache ||
      RecordFacetKind.rcode => null,
    };
  }
}

extension RecordGroupingL10n on RecordGrouping {
  String get label {
    final appLocalizations = currentAppLocalizations;
    return switch (this) {
      RecordGrouping.app => appLocalizations.app,
      RecordGrouping.host => appLocalizations.host,
      RecordGrouping.rule => appLocalizations.rule,
      RecordGrouping.exit => appLocalizations.outboundExit,
    };
  }
}
