// ignore_for_file: invalid_annotation_target

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/common/constant.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../enum/enum.dart';

part 'generated/clash_config.g.dart';

part 'generated/clash_config.freezed.dart';

@freezed
class Tun with _$Tun {
  const factory Tun({
    @Default(false) bool enable,
    @Default(appName) String device,
    @Default(TunStack.gvisor) TunStack stack,
    @JsonKey(name: "dns-hijack") @Default(["any:53"]) List<String> dnsHijack,
  }) = _Tun;

  factory Tun.fromJson(Map<String, Object?> json) => _$TunFromJson(json);
}

@JsonSerializable()
class Dns {
  bool enable;
  bool ipv6;
  @JsonKey(name: "default-nameserver")
  List<String> defaultNameserver;
  @JsonKey(name: "enhanced-mode")
  String enhancedMode;
  @JsonKey(name: "fake-ip-range")
  String fakeIpRange;
  @JsonKey(name: "use-hosts")
  bool useHosts;
  List<String> nameserver;
  List<String> fallback;
  @JsonKey(name: "fake-ip-filter")
  List<String> fakeIpFilter;

  Dns()
      : enable = true,
        ipv6 = false,
        defaultNameserver = [
          "223.5.5.5",
          "119.29.29.29",
          "8.8.4.4",
          "1.0.0.1",
        ],
        enhancedMode = "fake-ip",
        fakeIpRange = "198.18.0.1/16",
        useHosts = true,
        nameserver = [
          "8.8.8.8",
          "114.114.114.114",
          "https://doh.pub/dns-query",
          "https://dns.alidns.com/dns-query",
        ],
        fallback = [
          'https://doh.dns.sb/dns-query',
          'https://dns.cloudflare.com/dns-query',
          'https://dns.twnic.tw/dns-query',
          'tls://8.8.4.4:853',
        ],
        fakeIpFilter = [
          // Stun Services
          "+.stun.*.*",
          "+.stun.*.*.*",
          "+.stun.*.*.*.*",
          "+.stun.*.*.*.*.*",

          // Google Voices
          "lens.l.google.com",

          // Nintendo Switch STUN
          "*.n.n.srv.nintendo.net",

          // PlayStation STUN
          "+.stun.playstation.net",

          // XBox
          "xbox.*.*.microsoft.com",
          "*.*.xboxlive.com",

          // Microsoft Captive Portal
          "*.msftncsi.com",
          "*.msftconnecttest.com",

          // Bilibili CDN
          "*.mcdn.bilivideo.cn",

          // Windows Default LAN WorkGroup
          "WORKGROUP",
        ];

  factory Dns.fromJson(Map<String, dynamic> json) {
    return _$DnsFromJson(json);
  }

  Map<String, dynamic> toJson() {
    return _$DnsToJson(this);
  }
}

@JsonSerializable()
class ClashConfig extends ChangeNotifier {
  int _mixedPort;
  bool _allowLan;
  bool _ipv6;
  String _externalController;
  Mode _mode;
  LogLevel _logLevel;
  Tun _tun;
  Dns _dns;
  List<String> _rules;

  ClashConfig({
    int? mixedPort,
    Mode? mode,
    bool? allowLan,
    bool? ipv6,
    LogLevel? logLevel,
    String? externalController,
    Tun? tun,
    Dns? dns,
    List<String>? rules,
  })  : _mixedPort = mixedPort ?? 7890,
        _mode = mode ?? Mode.rule,
        _ipv6 = ipv6 ?? false,
        _allowLan = allowLan ?? false,
        _logLevel = logLevel ?? LogLevel.info,
        _tun = tun ?? const Tun(),
        _externalController = externalController ?? '',
        _dns = dns ?? Dns(),
        _rules = rules ?? [];

  @JsonKey(name: "mixed-port")
  int get mixedPort => _mixedPort;

  set mixedPort(int value) {
    if (_mixedPort != value) {
      _mixedPort = value;
      notifyListeners();
    }
  }

  Mode get mode => _mode;

  set mode(Mode value) {
    if (_mode != value) {
      _mode = value;
      notifyListeners();
    }
  }

  @JsonKey(name: "allow-lan")
  bool get allowLan => _allowLan;

  set allowLan(bool value) {
    if (_allowLan != value) {
      _allowLan = value;
      notifyListeners();
    }
  }

  @JsonKey(name: "log-level")
  LogLevel get logLevel => _logLevel;

  set logLevel(LogLevel value) {
    if (_logLevel != value) {
      _logLevel = value;
      notifyListeners();
    }
  }

  @JsonKey(name: "external-controller", defaultValue: '')
  String get externalController => _externalController;

  set externalController(String value) {
    if (_externalController != value) {
      _externalController = value;
      notifyListeners();
    }
  }

  @JsonKey(defaultValue: false)
  bool get ipv6 => _ipv6;

  set ipv6(bool value) {
    if (_ipv6 != value) {
      ipv6 = value;
      notifyListeners();
    }
  }

  Tun get tun => _tun;

  set tun(Tun value) {
    if (_tun != value) {
      _tun = value;
      notifyListeners();
    }
  }

  Dns get dns => _dns;

  set dns(Dns value) {
    if (_dns != value) {
      _dns = value;
      notifyListeners();
    }
  }

  List<String> get rules => _rules;

  set rules(List<String> value) {
    if (_rules != value) {
      _rules = value;
      notifyListeners();
    }
  }

  update([ClashConfig? clashConfig]) {
    if (clashConfig != null) {
      _mixedPort = clashConfig._mixedPort;
      _allowLan = clashConfig._allowLan;
      _mode = clashConfig._mode;
      _logLevel = clashConfig._logLevel;
      _tun = clashConfig._tun;
      _dns = clashConfig._dns;
      _rules = clashConfig._rules;
    }
    notifyListeners();
  }

  Map<String, dynamic> toJson() {
    return _$ClashConfigToJson(this);
  }

  factory ClashConfig.fromJson(Map<String, dynamic> json) {
    return _$ClashConfigFromJson(json);
  }

  ClashConfig copyWith({Tun? tun}) {
    return ClashConfig(
      mixedPort: mixedPort,
      mode: mode,
      logLevel: logLevel,
      tun: tun ?? this.tun,
      dns: dns,
      allowLan: allowLan,
    );
  }

  @override
  String toString() {
    return 'ClashConfig{_mixedPort: $_mixedPort, _allowLan: $_allowLan, _mode: $_mode, _logLevel: $_logLevel, _tun: $_tun, _dns: $_dns, _rules: $_rules}';
  }
}
