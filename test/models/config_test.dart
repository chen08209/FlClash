import 'dart:convert';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:material_ui/material_ui.dart';
import 'package:test/test.dart';

/// Helper to round-trip a model through JSON encode/decode.
T roundTrip<T>(
  Object? Function() toJson,
  T Function(Map<String, Object?> json) fromJson,
) {
  final encoded = jsonEncode(toJson());
  final decoded = jsonDecode(encoded) as Map<String, Object?>;
  return fromJson(decoded);
}

void main() {
  group('GeoResource JSON', () {
    test('exposes mihomo raw config keys', () {
      expect(GeoResource.MMDB.configKey, 'mmdb');
      expect(GeoResource.ASN.configKey, 'asn');
      expect(GeoResource.GEOIP.configKey, 'geoip');
      expect(GeoResource.GEOSITE.configKey, 'geosite');
    });

    test('parses canonical GeoResource keys from config JSON', () {
      final config = PatchClashConfig.fromJson({
        'geox-url': {
          'mmdb': 'https://example.com/mmdb',
          'asn': 'https://example.com/asn.mmdb',
          'geoip': 'https://example.com/geoip.dat',
          'geosite': 'https://example.com/geosite.dat',
        },
      });

      expect(config.geoXUrl, {
        GeoResource.MMDB: 'https://example.com/mmdb',
        GeoResource.ASN: 'https://example.com/asn.mmdb',
        GeoResource.GEOIP: 'https://example.com/geoip.dat',
        GeoResource.GEOSITE: 'https://example.com/geosite.dat',
      });
    });

    test('parses hyphenated GeoResource keys from config JSON', () {
      final config = PatchClashConfig.fromJson({
        'geox-url': {
          'geo-ip': 'https://example.com/legacy-geoip.dat',
          'geo-site': 'https://example.com/legacy-geosite.dat',
        },
      });

      expect(config.geoXUrl, {
        GeoResource.GEOIP: 'https://example.com/legacy-geoip.dat',
        GeoResource.GEOSITE: 'https://example.com/legacy-geosite.dat',
      });
    });

    test('GeoXUrl defaults use GeoResource keys', () {
      expect(defaultGeoXUrl.keys, GeoResource.values);
    });

    test('PatchClashConfig serializes geoXUrl map with lowercase keys', () {
      final json = const PatchClashConfig(
        geoXUrl: {GeoResource.GEOIP: 'https://example.com/geoip.dat'},
      ).toJson();

      expect(json['geox-url'], {'geoip': 'https://example.com/geoip.dat'});
    });

    test('converts geoXUrl map to raw config map', () {
      const geoXUrl = {
        GeoResource.MMDB: 'https://example.com/mmdb',
        GeoResource.GEOSITE: 'https://example.com/geosite.dat',
      };

      expect(geoXUrl.raw, {
        'mmdb': 'https://example.com/mmdb',
        'geosite': 'https://example.com/geosite.dat',
      });
    });

    test('PatchClashConfig parses geoXUrl map with GeoResource keys', () {
      final config = PatchClashConfig.fromJson({
        'geox-url': {'mmdb': 'https://example.com/mmdb'},
      });

      expect(config.geoXUrl, {GeoResource.MMDB: 'https://example.com/mmdb'});
    });
  });

  group('AppSettingProps JSON round-trip', () {
    test('default values survive round-trip', () {
      const props = AppSettingProps();
      final restored = roundTrip(
        () => props.toJson(),
        AppSettingProps.fromJson,
      );
      expect(restored.onlyStatisticsProxy, false);
      expect(restored.autoLaunch, false);
      expect(restored.silentLaunch, false);
      expect(restored.autoRun, false);
      expect(restored.openLogs, false);
      expect(restored.closeConnections, true);
      expect(restored.isAnimateToPage, true);
      expect(restored.autoCheckUpdate, true);
      expect(restored.sidebarExpanded, true);
      expect(restored.minimizeOnExit, true);
      expect(restored.restoreStrategy, RestoreStrategy.compatible);
      expect(restored.userAgents, defaultUserAgents);
      expect(restored.testUrl, defaultTestUrl);
    });

    test('a saved outboundModeV2 card folds into outboundMode', () {
      final restored = AppSettingProps.fromJson({
        'dashboardWidgets': ['networkSpeed', 'outboundModeV2', 'outboundMode'],
      });
      expect(restored.dashboardWidgets, [
        DashboardWidget.networkSpeed,
        DashboardWidget.outboundMode,
      ]);

      final alone = AppSettingProps.fromJson({
        'dashboardWidgets': ['outboundModeV2', 'trafficUsage'],
      });
      expect(alone.dashboardWidgets, [
        DashboardWidget.outboundMode,
        DashboardWidget.trafficUsage,
      ]);
    });

    test('custom values survive round-trip', () {
      const props = AppSettingProps(
        locale: 'zh_CN',
        onlyStatisticsProxy: true,
        autoLaunch: true,
        closeConnections: false,
        testUrl: 'https://custom.test',
        userAgents: ['CustomUA/1.0'],
      );
      final restored = roundTrip(
        () => props.toJson(),
        AppSettingProps.fromJson,
      );
      expect(restored.locale, 'zh_CN');
      expect(restored.onlyStatisticsProxy, true);
      expect(restored.autoLaunch, true);
      expect(restored.closeConnections, false);
      expect(restored.testUrl, 'https://custom.test');
      expect(restored.userAgents, ['CustomUA/1.0']);
    });

    test('a legacy custom user agent joins the presets', () {
      expect(
        AppSettingProps.fromJson({
          'customUserAgent': ' CustomUA/1.0 ',
        }).userAgents,
        [...defaultUserAgents, 'CustomUA/1.0'],
      );
      expect(
        AppSettingProps.fromJson({'customUserAgent': ''}).userAgents,
        defaultUserAgents,
      );
      expect(
        AppSettingProps.fromJson({
          'customUserAgent': 'CustomUA/1.0',
          'userAgents': <String>[],
        }).userAgents,
        isEmpty,
      );
    });

    test('safeFromJson returns default on null', () {
      final result = AppSettingProps.safeFromJson(null);
      expect(result, isA<AppSettingProps>());
      expect(result.onlyStatisticsProxy, false);
    });

    test('safeFromJson returns default on invalid JSON', () {
      final result = AppSettingProps.safeFromJson({'invalid': 'data'});
      expect(result, isA<AppSettingProps>());
    });
  });

  group('WindowProps JSON round-trip', () {
    test('default values', () {
      const props = WindowProps();
      expect(props.width, 0);
      expect(props.height, 0);
      expect(props.top, null);
      expect(props.left, null);
    });

    test('fromJson handles null', () {
      final props = WindowProps.fromJson(null);
      expect(props.width, 0);
    });

    test('size extension defaults to 680x580 when empty', () {
      const props = WindowProps();
      expect(props.size.width, 680);
      expect(props.size.height, 580);
    });

    test('size extension uses actual values', () {
      const props = WindowProps(width: 800, height: 600);
      expect(props.size.width, 800);
      expect(props.size.height, 600);
    });

    test('round-trip with values', () {
      const props = WindowProps(width: 1024, height: 768, top: 100, left: 200);
      final restored = roundTrip(() => props.toJson(), WindowProps.fromJson);
      expect(restored.width, 1024);
      expect(restored.height, 768);
      expect(restored.top, 100);
      expect(restored.left, 200);
    });
  });

  group('VpnProps JSON round-trip', () {
    test('default values', () {
      const props = VpnProps();
      expect(props.enable, true);
      expect(props.systemProxy, true);
      expect(props.ipv6, false);
      expect(props.allowBypass, true);
      expect(props.dnsHijacking, false);
      expect(props.accessControlProps.enable, false);
    });

    test('fromJson handles null', () {
      final props = VpnProps.fromJson(null);
      expect(props.enable, true);
    });

    test('round-trip with custom values', () {
      const accessControl = AccessControlProps(
        enable: true,
        mode: AccessControlMode.acceptSelected,
      );
      const props = VpnProps(
        enable: false,
        systemProxy: false,
        ipv6: true,
        accessControlProps: accessControl,
      );
      final restored = roundTrip(() => props.toJson(), VpnProps.fromJson);
      expect(restored.enable, false);
      expect(restored.systemProxy, false);
      expect(restored.ipv6, true);
    });
  });

  group('NetworkProps JSON round-trip', () {
    test('default values', () {
      const props = NetworkProps();
      expect(props.systemProxy, true);
      expect(props.bypassDomain, defaultBypassDomain);
      expect(props.routeMode, RouteMode.config);
      expect(props.autoSetSystemDns, true);
      expect(props.appendSystemDns, false);
    });

    test('round-trip with custom values', () {
      const props = NetworkProps(
        systemProxy: false,
        bypassDomain: ['example.com'],
        routeMode: RouteMode.bypassPrivate,
      );
      final restored = roundTrip(() => props.toJson(), NetworkProps.fromJson);
      expect(restored.systemProxy, false);
      expect(restored.bypassDomain, ['example.com']);
      expect(restored.routeMode, RouteMode.bypassPrivate);
    });
  });

  group('PatchClashConfig JSON round-trip', () {
    test('defaults match Clash patch defaults', () {
      const config = PatchClashConfig();

      expect(config.mixedPort, defaultMixedPort);
      expect(config.allowLan, false);
      expect(config.mode, Mode.rule);
      expect(config.externalController, ExternalControllerStatus.close);
      expect(config.geodataLoader, GeodataLoader.memconservative);
      expect(config.interfaceNameMode, InterfaceNameMode.clear);
      expect(config.interfaceName, '');
    });

    test('custom values survive round-trip', () {
      const config = PatchClashConfig(
        mixedPort: 7890,
        allowLan: true,
        mode: Mode.rule,
        logLevel: LogLevel.debug,
        externalController: ExternalControllerStatus.open,
        geodataLoader: GeodataLoader.memconservative,
        interfaceNameMode: InterfaceNameMode.custom,
        interfaceName: 'eth0',
      );

      final restored = roundTrip(
        () => config.toJson(),
        PatchClashConfig.fromJson,
      );

      expect(restored.mixedPort, 7890);
      expect(restored.allowLan, true);
      expect(restored.mode, Mode.rule);
      expect(restored.logLevel, LogLevel.debug);
      expect(restored.externalController, ExternalControllerStatus.open);
      expect(restored.geodataLoader, GeodataLoader.memconservative);
      expect(restored.interfaceNameMode, InterfaceNameMode.custom);
      expect(restored.interfaceName, 'eth0');
    });

    test('unknown interface-name-mode falls back to clear', () {
      final restored = PatchClashConfig.fromJson({
        'interface-name-mode': 'unknown',
      });

      expect(restored.interfaceNameMode, InterfaceNameMode.clear);
    });
  });

  group('ProxiesStyleProps JSON round-trip', () {
    test('default values', () {
      const props = ProxiesStyleProps();
      expect(props.type, ProxiesType.tab);
      expect(props.sortType, ProxiesSortType.none);
      expect(props.layout, ProxiesLayout.standard);
    });

    test('round-trip with custom values', () {
      const props = ProxiesStyleProps(
        type: ProxiesType.list,
        sortType: ProxiesSortType.delay,
      );
      final restored = roundTrip(
        () => props.toJson(),
        ProxiesStyleProps.fromJson,
      );
      expect(restored.type, ProxiesType.list);
      expect(restored.sortType, ProxiesSortType.delay);
    });

    test('reads the icon styles saved under their former names', () {
      expect(
        ProxiesStyleProps.fromJson({'iconStyle': 'standard'}).iconStyle,
        ProxiesIconStyle.filled,
      );
      expect(
        ProxiesStyleProps.fromJson({'iconStyle': 'icon'}).iconStyle,
        ProxiesIconStyle.plain,
      );
      expect(
        ProxiesStyleProps.fromJson({'iconStyle': 'none'}).iconStyle,
        ProxiesIconStyle.hidden,
      );
    });

    test('falls back to the default icon style', () {
      expect(ProxiesStyleProps.fromJson({}).iconStyle, ProxiesIconStyle.filled);
      expect(
        ProxiesStyleProps.fromJson({'iconStyle': 'nonsense'}).iconStyle,
        ProxiesIconStyle.filled,
      );
    });

    test('round-trips every icon style under its own name', () {
      for (final style in ProxiesIconStyle.values) {
        final restored = roundTrip(
          () => ProxiesStyleProps(iconStyle: style).toJson(),
          ProxiesStyleProps.fromJson,
        );
        expect(restored.iconStyle, style);
      }
    });

    test('round-trip keeps the timed-out node filter', () {
      final restored = roundTrip(
        () => const ProxiesStyleProps(hideTimeoutProxies: true).toJson(),
        ProxiesStyleProps.fromJson,
      );
      expect(restored.hideTimeoutProxies, true);
    });
  });

  group('ThemeProps JSON round-trip', () {
    test('default values', () {
      const props = ThemeProps();
      expect(props.primaryColor, null);
      expect(props.primaryColors, defaultPrimaryColors);
      expect(props.themeMode, ThemeMode.dark);
      expect(props.pureBlack, false);
      expect(props.textScale.scale, 1.0);
    });

    test('safeFromJson returns default on null', () {
      final result = ThemeProps.safeFromJson(null);
      expect(result.themeMode, ThemeMode.dark);
    });

    test('round-trip with custom values', () {
      const props = ThemeProps(
        primaryColor: 0xFF123456,
        themeMode: ThemeMode.light,
        pureBlack: true,
        textScale: TextScale(enable: true, scale: 1.5),
      );
      final restored = roundTrip(() => props.toJson(), ThemeProps.fromJson);
      expect(restored.primaryColor, 0xFF123456);
      expect(restored.themeMode, ThemeMode.light);
      expect(restored.pureBlack, true);
      expect(restored.textScale.scale, 1.5);
    });
  });

  group('AccessControlProps', () {
    test('currentList returns acceptList in acceptSelected mode', () {
      const props = AccessControlProps(
        enable: true,
        mode: AccessControlMode.acceptSelected,
        acceptList: ['app1', 'app2'],
        rejectList: ['app3'],
      );
      expect(props.currentList, ['app1', 'app2']);
    });

    test('currentList returns rejectList in rejectSelected mode', () {
      const props = AccessControlProps(
        enable: true,
        mode: AccessControlMode.rejectSelected,
        acceptList: ['app1'],
        rejectList: ['app3', 'app4'],
      );
      expect(props.currentList, ['app3', 'app4']);
    });
  });

  group('Config composite serialization', () {
    test('DAVProps obfuscates and restores its password', () {
      const props = DAVProps(
        uri: 'https://dav.example.com',
        user: 'user',
        password: '密碼-🔐',
      );

      final json = props.toJson();

      expect(json['password'], startsWith('v1.'));
      expect(json['password'], isNot(contains('密碼')));
      expect(DAVProps.fromJson(json), props);
      expect(props.toString(), isNot(contains('密碼')));
      expect(props.toString(), contains('password: ***'));
    });

    test('DAVProps accepts and rewrites a legacy plain-text password', () {
      final props = DAVProps.fromJson({
        'uri': 'https://dav.example.com',
        'user': 'user',
        'password': 'legacy-secret',
        'fileName': 'backup.zip',
      });

      expect(props.password, 'legacy-secret');
      expect(props.toJson()['password'], startsWith('v1.'));
      expect(props.toJson()['password'], isNot(contains('legacy-secret')));
    });

    test('DAVProps rejects a damaged obfuscated password', () {
      final props = DAVProps.fromJson({
        'uri': 'https://dav.example.com',
        'user': 'user',
        'password': 'v1.invalid.invalid',
        'fileName': 'backup.zip',
      });

      expect(props.password, isEmpty);
    });

    test('default Config round-trip', () {
      const config = Config(themeProps: ThemeProps());
      final restored = roundTrip(() => config.toJson(), Config.fromJson);
      expect(restored.currentProfileId, null);
      expect(restored.overrideDns, false);
      expect(restored.networkProps.systemProxy, true);
      expect(restored.vpnProps.enable, true);
      expect(restored.hotKeyActions, isEmpty);
    });

    test('realFromJson handles null', () {
      final result = Config.realFromJson(null);
      expect(result.appSettingProps.onlyStatisticsProxy, false);
    });

    test('a fresh config ships valid, distinct default hotkeys', () {
      final defaults = Config.realFromJson(null).hotKeyActions;

      expect(defaults.map((action) => action.action), [
        HotAction.view,
        HotAction.start,
        HotAction.mode,
        HotAction.proxy,
        HotAction.delayTest,
        HotAction.exit,
      ]);
      for (final action in defaults) {
        expect(
          isValidHotKey(action.modifiers, action.key),
          isTrue,
          reason: action.action.name,
        );
      }
      expect(
        defaults.map((action) => action.key).toSet(),
        hasLength(defaults.length),
      );
    });

    test('full config round-trip', () {
      const config = Config(
        currentProfileId: 42,
        overrideDns: true,
        hotKeyActions: [],
        appSettingProps: AppSettingProps(locale: 'en', autoLaunch: true),
        networkProps: NetworkProps(systemProxy: false),
        vpnProps: VpnProps(enable: false),
        themeProps: ThemeProps(
          primaryColor: 0xFF00FF00,
          themeMode: ThemeMode.system,
        ),
        windowProps: WindowProps(width: 1280, height: 720),
      );
      final restored = roundTrip(() => config.toJson(), Config.fromJson);
      expect(restored.currentProfileId, 42);
      expect(restored.overrideDns, true);
      expect(restored.appSettingProps.locale, 'en');
      expect(restored.appSettingProps.autoLaunch, true);
      expect(restored.networkProps.systemProxy, false);
      expect(restored.vpnProps.enable, false);
      expect(restored.windowProps.width, 1280);
      expect(restored.windowProps.height, 720);
    });
  });

  group('ProxyGroup definition', () {
    const group = ProxyGroup(
      profileId: 7,
      id: 99,
      name: 'Auto',
      type: GroupType.URLTest,
      proxies: ['A'],
      use: [],
      url: 'https://cp.cloudflare.com/generate_204',
      interval: 300,
      timeout: 5000,
      lazy: false,
      filter: '',
      tolerance: 50,
      strategy: LoadBalanceStrategy.roundRobin,
      order: 'a0',
    );

    test('emits only what the core reads', () {
      final definition = group.definition;

      expect(definition['name'], 'Auto');
      expect(definition['type'], 'url-test');
      expect(definition['proxies'], ['A']);
      expect(definition['interval'], 300);
      expect(definition['timeout'], 5000);
      expect(definition['lazy'], false);
      expect(definition.containsKey('profileId'), isFalse);
      expect(definition.containsKey('id'), isFalse);
      expect(definition.containsKey('order'), isFalse);
      expect(definition.containsKey('use'), isFalse);
      expect(definition.containsKey('filter'), isFalse);
      expect(definition.containsKey('max-failed-times'), isFalse);
    });

    test('scopes tolerance and strategy to the types that read them', () {
      expect(group.definition['tolerance'], 50);
      expect(group.definition.containsKey('strategy'), isFalse);

      final balanced = group.copyWith(type: GroupType.LoadBalance).definition;

      expect(balanced['strategy'], 'round-robin');
      expect(balanced.containsKey('tolerance'), isFalse);
    });
  });
}
