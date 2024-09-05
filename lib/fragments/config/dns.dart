import 'package:collection/collection.dart';
import 'package:fl_clash/common/app_localizations.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OverrideItem extends StatelessWidget {
  const OverrideItem({super.key});

  _initActions(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final commonScaffoldState =
      context.findAncestorStateOfType<CommonScaffoldState>();
      commonScaffoldState?.actions = [
        IconButton(
          onPressed: () {
            globalState.appController.clashConfig.dns = const Dns();
          },
          tooltip: appLocalizations.resetDns,
          icon: const Icon(
            Icons.replay,
          ),
        )
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    _initActions(context);
    return Selector<Config, bool>(
      selector: (_, config) => config.overrideDns,
      builder: (_, override, __) {
        return ListItem.switchItem(
          title: Text(appLocalizations.overrideDns),
          subtitle: Text(appLocalizations.overrideDnsDesc),
          delegate: SwitchDelegate(
            value: override,
            onChanged: (bool value) async {
              final config = globalState.appController.config;
              config.overrideDns = value;
            },
          ),
        );
      },
    );
  }
}

class DnsDisabledContainer extends StatelessWidget {
  final Widget child;

  const DnsDisabledContainer(this.child, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Selector<Config, bool>(
      selector: (_, config) => config.overrideDns,
      builder: (_, enable, child) {
        return AbsorbPointer(
          absorbing: !enable,
          child: DisabledMask(
            status: !enable,
            child: Container(
              color: context.colorScheme.surface,
              child: child!,
            ),
          ),
        );
      },
      child: child,
    );
  }
}

class StatusItem extends StatelessWidget {
  const StatusItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<ClashConfig, bool>(
      selector: (_, clashConfig) => clashConfig.dns.enable,
      builder: (_, enable, __) {
        return ListItem.switchItem(
          title: Text(appLocalizations.status),
          subtitle: Text(appLocalizations.statusDesc),
          delegate: SwitchDelegate(
            value: enable,
            onChanged: (bool value) async {
              final clashConfig = globalState.appController.clashConfig;
              final dns = clashConfig.dns;
              clashConfig.dns = dns.copyWith(
                enable: value,
              );
            },
          ),
        );
      },
    );
  }
}

class PreferH3Item extends StatelessWidget {
  const PreferH3Item({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<ClashConfig, bool>(
      selector: (_, clashConfig) => clashConfig.dns.preferH3,
      builder: (_, preferH3, __) {
        return ListItem.switchItem(
          title: const Text("PreferH3"),
          subtitle: Text(appLocalizations.preferH3Desc),
          delegate: SwitchDelegate(
            value: preferH3,
            onChanged: (bool value) async {
              final clashConfig = globalState.appController.clashConfig;
              final dns = clashConfig.dns;
              clashConfig.dns = dns.copyWith(
                preferH3: value,
              );
            },
          ),
        );
      },
    );
  }
}

class IPv6Item extends StatelessWidget {
  const IPv6Item({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<ClashConfig, bool>(
      selector: (_, clashConfig) => clashConfig.dns.ipv6,
      builder: (_, ipv6, __) {
        return ListItem.switchItem(
          title: const Text("IPv6"),
          delegate: SwitchDelegate(
            value: ipv6,
            onChanged: (bool value) async {
              final clashConfig = globalState.appController.clashConfig;
              final dns = clashConfig.dns;
              clashConfig.dns = dns.copyWith(
                ipv6: value,
              );
            },
          ),
        );
      },
    );
  }
}

class RespectRulesItem extends StatelessWidget {
  const RespectRulesItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<ClashConfig, bool>(
      selector: (_, clashConfig) => clashConfig.dns.respectRules,
      builder: (_, respectRules, __) {
        return ListItem.switchItem(
          title: Text(appLocalizations.respectRules),
          subtitle: Text(appLocalizations.respectRulesDesc),
          delegate: SwitchDelegate(
            value: respectRules,
            onChanged: (bool value) async {
              final clashConfig = globalState.appController.clashConfig;
              final dns = clashConfig.dns;
              clashConfig.dns = dns.copyWith(
                respectRules: value,
              );
            },
          ),
        );
      },
    );
  }
}

class DnsModeItem extends StatelessWidget {
  const DnsModeItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<ClashConfig, DnsMode>(
      selector: (_, clashConfig) => clashConfig.dns.enhancedMode,
      builder: (_, enhancedMode, __) {
        return ListItem<DnsMode>.options(
          title: Text(appLocalizations.dnsMode),
          subtitle: Text(enhancedMode.name),
          delegate: OptionsDelegate(
            title: appLocalizations.dnsMode,
            options: DnsMode.values,
            onChanged: (value) {
              if (value == null) {
                return;
              }
              final clashConfig = globalState.appController.clashConfig;
              final dns = clashConfig.dns;
              clashConfig.dns = dns.copyWith(enhancedMode: value);
            },
            textBuilder: (dnsMode) => dnsMode.name,
            value: enhancedMode,
          ),
        );
      },
    );
  }
}

class FakeIpRangeItem extends StatelessWidget {
  const FakeIpRangeItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<ClashConfig, String>(
      selector: (_, clashConfig) => clashConfig.dns.fakeIpRange,
      builder: (_, fakeIpRange, __) {
        return ListItem.input(
          title: Text(appLocalizations.fakeipRange),
          subtitle: Text(fakeIpRange),
          delegate: InputDelegate(
            title: appLocalizations.fakeipRange,
            value: fakeIpRange,
            onChanged: (String? value) {
              if (value != null) {
                try {
                  final clashConfig = globalState.appController.clashConfig;
                  clashConfig.dns = clashConfig.dns.copyWith(
                    fakeIpRange: value,
                  );
                } catch (e) {
                  globalState.showMessage(
                    title: appLocalizations.fakeipRange,
                    message: TextSpan(
                      text: e.toString(),
                    ),
                  );
                }
              }
            },
          ),
        );
      },
    );
  }
}

class FakeIpFilterItem extends StatelessWidget {
  const FakeIpFilterItem({super.key});

  @override
  Widget build(BuildContext context) {
    return ListItem.open(
      title: Text(appLocalizations.fakeipFilter),
      delegate: OpenDelegate(
        isBlur: false,
        title: appLocalizations.fakeipFilter,
        widget: Selector<ClashConfig, List<String>>(
          selector: (_, clashConfig) => clashConfig.dns.fakeIpFilter,
          shouldRebuild: (prev, next) =>
          !const ListEquality<String>().equals(prev, next),
          builder: (_, fakeIpFilter, __) {
            return UpdatePage(
              title: appLocalizations.fakeipFilter,
              items: fakeIpFilter,
              titleBuilder: (item) => Text(item),
              onRemove: (value) {
                final clashConfig = globalState.appController.clashConfig;
                final dns = clashConfig.dns;
                clashConfig.dns = dns.copyWith(
                  fakeIpFilter: List.from(dns.fakeIpFilter)
                    ..remove(value),
                );
              },
              onAdd: (value) {
                final clashConfig = globalState.appController.clashConfig;
                final dns = clashConfig.dns;
                if (fakeIpFilter.contains(value)) return;
                clashConfig.dns = dns.copyWith(
                  fakeIpFilter: List.from(dns.fakeIpFilter)
                    ..add(value),
                );
              },
            );
          },
        ),
        extendPageWidth: 360,
      ),
    );
  }
}

class DefaultNameserverItem extends StatelessWidget {
  const DefaultNameserverItem({super.key});

  @override
  Widget build(BuildContext context) {
    return ListItem.open(
      title: Text(appLocalizations.defaultNameserver),
      subtitle: Text(appLocalizations.defaultNameserverDesc),
      delegate: OpenDelegate(
        isBlur: false,
        title: appLocalizations.defaultNameserver,
        widget: Selector<ClashConfig, List<String>>(
          selector: (_, clashConfig) => clashConfig.dns.defaultNameserver,
          shouldRebuild: (prev, next) =>
          !const ListEquality<String>().equals(prev, next),
          builder: (_, defaultNameserver, __) {
            return UpdatePage(
              title: appLocalizations.defaultNameserver,
              items: defaultNameserver,
              titleBuilder: (item) => Text(item),
              onRemove: (value) {
                final clashConfig = globalState.appController.clashConfig;
                final dns = clashConfig.dns;
                clashConfig.dns = dns.copyWith(
                  defaultNameserver: List.from(dns.defaultNameserver)
                    ..remove(value),
                );
              },
              onAdd: (value) {
                final clashConfig = globalState.appController.clashConfig;
                final dns = clashConfig.dns;
                if (defaultNameserver.contains(value)) return;
                clashConfig.dns = dns.copyWith(
                  defaultNameserver: List.from(dns.defaultNameserver)
                    ..add(value),
                );
              },
            );
          },
        ),
        extendPageWidth: 360,
      ),
    );
  }
}

class NameserverItem extends StatelessWidget {
  const NameserverItem({super.key});

  @override
  Widget build(BuildContext context) {
    return ListItem.open(
      title: Text(appLocalizations.nameserver),
      subtitle: Text(appLocalizations.nameserverDesc),
      delegate: OpenDelegate(
        title: appLocalizations.nameserver,
        isBlur: false,
        widget: Selector<ClashConfig, List<String>>(
          selector: (_, clashConfig) => clashConfig.dns.nameserver,
          shouldRebuild: (prev, next) =>
          !const ListEquality<String>().equals(prev, next),
          builder: (_, nameserver, __) {
            return UpdatePage(
              title: "域名服务器",
              items: nameserver,
              titleBuilder: (item) => Text(item),
              onRemove: (value) {
                final clashConfig = globalState.appController.clashConfig;
                final dns = clashConfig.dns;
                clashConfig.dns = dns.copyWith(
                  nameserver: List.from(dns.nameserver)
                    ..remove(value),
                );
              },
              onAdd: (value) {
                final clashConfig = globalState.appController.clashConfig;
                final dns = clashConfig.dns;
                if (nameserver.contains(value)) return;
                clashConfig.dns = dns.copyWith(
                  nameserver: List.from(dns.nameserver)
                    ..add(value),
                );
              },
            );
          },
        ),
        extendPageWidth: 360,
      ),
    );
  }
}

class UseHostsItem extends StatelessWidget {
  const UseHostsItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<ClashConfig, bool>(
      selector: (_, clashConfig) => clashConfig.dns.useHosts,
      builder: (_, useHosts, __) {
        return ListItem.switchItem(
          title: Text(appLocalizations.useHosts),
          delegate: SwitchDelegate(
            value: useHosts,
            onChanged: (bool value) async {
              final clashConfig = globalState.appController.clashConfig;
              final dns = clashConfig.dns;
              clashConfig.dns = dns.copyWith(
                useHosts: value,
              );
            },
          ),
        );
      },
    );
  }
}

class UseSystemHostsItem extends StatelessWidget {
  const UseSystemHostsItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<ClashConfig, bool>(
      selector: (_, clashConfig) => clashConfig.dns.useSystemHosts,
      builder: (_, useSystemHosts, __) {
        return ListItem.switchItem(
          title: Text(appLocalizations.useSystemHosts),
          delegate: SwitchDelegate(
            value: useSystemHosts,
            onChanged: (bool value) async {
              final clashConfig = globalState.appController.clashConfig;
              final dns = clashConfig.dns;
              clashConfig.dns = dns.copyWith(
                useSystemHosts: value,
              );
            },
          ),
        );
      },
    );
  }
}

class NameserverPolicyItem extends StatelessWidget {
  const NameserverPolicyItem({super.key});

  @override
  Widget build(BuildContext context) {
    return ListItem.open(
      title: Text(appLocalizations.nameserverPolicy),
      subtitle: Text(appLocalizations.nameserverPolicyDesc),
      delegate: OpenDelegate(
        isBlur: false,
        title: appLocalizations.nameserverPolicy,
        widget: Selector<ClashConfig, Map<String, String>>(
          selector: (_, clashConfig) => clashConfig.dns.nameserverPolicy,
          shouldRebuild: (prev, next) =>
          !const MapEquality<String, String>().equals(prev, next),
          builder: (_, nameserverPolicy, __) {
            return UpdatePage(
              title: appLocalizations.nameserverPolicy,
              items: nameserverPolicy.entries,
              titleBuilder: (item) => Text(item.key),
              subtitleBuilder: (item) => Text(item.value),
              isMap: true,
              onRemove: (value) {
                final clashConfig = globalState.appController.clashConfig;
                final dns = clashConfig.dns;
                clashConfig.dns = dns.copyWith(
                  nameserverPolicy: Map.from(dns.nameserverPolicy)
                    ..remove(value.key),
                );
              },
              onAdd: (value) {
                final clashConfig = globalState.appController.clashConfig;
                final dns = clashConfig.dns;
                clashConfig.dns = dns.copyWith(
                  nameserverPolicy: Map.from(dns.nameserverPolicy)
                    ..addEntries([value]),
                );
              },
            );
          },
        ),
        extendPageWidth: 360,
      ),
    );
  }
}

class ProxyServerNameserverItem extends StatelessWidget {
  const ProxyServerNameserverItem({super.key});

  @override
  Widget build(BuildContext context) {
    return ListItem.open(
      title: Text(appLocalizations.proxyNameserver),
      subtitle: Text(appLocalizations.proxyNameserverDesc),
      delegate: OpenDelegate(
        isBlur: false,
        title: appLocalizations.proxyNameserver,
        widget: Selector<ClashConfig, List<String>>(
          selector: (_, clashConfig) => clashConfig.dns.proxyServerNameserver,
          shouldRebuild: (prev, next) =>
          !const ListEquality<String>().equals(prev, next),
          builder: (_, proxyServerNameserver, __) {
            return UpdatePage(
              title: appLocalizations.proxyNameserver,
              items: proxyServerNameserver,
              titleBuilder: (item) => Text(item),
              onRemove: (value) {
                final clashConfig = globalState.appController.clashConfig;
                final dns = clashConfig.dns;
                clashConfig.dns = dns.copyWith(
                  proxyServerNameserver: List.from(dns.proxyServerNameserver)
                    ..remove(value),
                );
              },
              onAdd: (value) {
                final clashConfig = globalState.appController.clashConfig;
                final dns = clashConfig.dns;
                if (proxyServerNameserver.contains(value)) return;
                clashConfig.dns = dns.copyWith(
                  proxyServerNameserver: List.from(dns.proxyServerNameserver)
                    ..add(value),
                );
              },
            );
          },
        ),
        extendPageWidth: 360,
      ),
    );
  }
}

class FallbackItem extends StatelessWidget {
  const FallbackItem({super.key});

  @override
  Widget build(BuildContext context) {
    return ListItem.open(
      title: Text(appLocalizations.fallback),
      subtitle: Text(appLocalizations.fallbackDesc),
      delegate: OpenDelegate(
        isBlur: false,
        title: appLocalizations.fallback,
        widget: Selector<ClashConfig, List<String>>(
          selector: (_, clashConfig) => clashConfig.dns.fallback,
          shouldRebuild: (prev, next) =>
          !const ListEquality<String>().equals(prev, next),
          builder: (_, fallback, __) {
            return UpdatePage(
              title: appLocalizations.fallback,
              items: fallback,
              titleBuilder: (item) => Text(item),
              onRemove: (value) {
                final clashConfig = globalState.appController.clashConfig;
                final dns = clashConfig.dns;
                clashConfig.dns = dns.copyWith(
                  fallback: List.from(dns.fallback)
                    ..remove(value),
                );
              },
              onAdd: (value) {
                final clashConfig = globalState.appController.clashConfig;
                final dns = clashConfig.dns;
                if (fallback.contains(value)) return;
                clashConfig.dns = dns.copyWith(
                  fallback: List.from(dns.fallback)
                    ..add(value),
                );
              },
            );
          },
        ),
        extendPageWidth: 360,
      ),
    );
  }
}

class GeoipItem extends StatelessWidget {
  const GeoipItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<ClashConfig, bool>(
      selector: (_, clashConfig) => clashConfig.dns.fallbackFilter.geoip,
      builder: (_, geoip, __) {
        return ListItem.switchItem(
          title: const Text("Geoip"),
          delegate: SwitchDelegate(
            value: geoip,
            onChanged: (bool value) async {
              final clashConfig = globalState.appController.clashConfig;
              final dns = clashConfig.dns;
              clashConfig.dns = dns.copyWith(
                fallbackFilter: dns.fallbackFilter.copyWith(geoip: value),
              );
            },
          ),
        );
      },
    );
  }
}

class GeoipCodeItem extends StatelessWidget {
  const GeoipCodeItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<ClashConfig, String>(
      selector: (_, clashConfig) => clashConfig.dns.fallbackFilter.geoipCode,
      builder: (_, geoipCode, __) {
        return ListItem.input(
          title: Text(appLocalizations.geoipCode),
          subtitle: Text(geoipCode),
          delegate: InputDelegate(
            title: appLocalizations.geoipCode,
            value: geoipCode,
            onChanged: (String? value) {
              if (value != null) {
                try {
                  final clashConfig = globalState.appController.clashConfig;
                  final dns = clashConfig.dns;
                  clashConfig.dns = dns.copyWith(
                    fallbackFilter: dns.fallbackFilter.copyWith(
                      geoipCode: value,
                    ),
                  );
                } catch (e) {
                  globalState.showMessage(
                    title: appLocalizations.geoipCode,
                    message: TextSpan(
                      text: e.toString(),
                    ),
                  );
                }
              }
            },
          ),
        );
      },
    );
  }
}

class GeositeItem extends StatelessWidget {
  const GeositeItem({super.key});

  @override
  Widget build(BuildContext context) {
    return ListItem.open(
      title: const Text("Geosite"),
      delegate: OpenDelegate(
        isBlur: false,
        title: "Geosite",
        widget: Selector<ClashConfig, List<String>>(
          selector: (_, clashConfig) => clashConfig.dns.fallbackFilter.geosite,
          shouldRebuild: (prev, next) =>
          !const ListEquality<String>().equals(prev, next),
          builder: (_, geosite, __) {
            return UpdatePage(
              title: "Geosite",
              items: geosite,
              titleBuilder: (item) => Text(item),
              onRemove: (value) {
                final clashConfig = globalState.appController.clashConfig;
                final dns = clashConfig.dns;
                clashConfig.dns = dns.copyWith(
                  fallbackFilter: dns.fallbackFilter.copyWith(
                    geosite: List.from(geosite)
                      ..remove(value),
                  ),
                );
              },
              onAdd: (value) {
                final clashConfig = globalState.appController.clashConfig;
                final dns = clashConfig.dns;
                clashConfig.dns = dns.copyWith(
                  fallbackFilter: dns.fallbackFilter.copyWith(
                    geosite: List.from(geosite)
                      ..add(value),
                  ),
                );
              },
            );
          },
        ),
        extendPageWidth: 360,
      ),
    );
  }
}

class IpcidrItem extends StatelessWidget {
  const IpcidrItem({super.key});

  @override
  Widget build(BuildContext context) {
    return ListItem.open(
      title: Text(appLocalizations.ipcidr),
      delegate: OpenDelegate(
        isBlur: false,
        title: appLocalizations.ipcidr,
        widget: Selector<ClashConfig, List<String>>(
          selector: (_, clashConfig) => clashConfig.dns.fallbackFilter.ipcidr,
          shouldRebuild: (prev, next) =>
          !const ListEquality<String>().equals(prev, next),
          builder: (_, ipcidr, __) {
            return UpdatePage(
              title: appLocalizations.ipcidr,
              items: ipcidr,
              titleBuilder: (item) => Text(item),
              onRemove: (value) {
                final clashConfig = globalState.appController.clashConfig;
                final dns = clashConfig.dns;
                clashConfig.dns = dns.copyWith(
                  fallbackFilter: dns.fallbackFilter.copyWith(
                    ipcidr: List.from(ipcidr)
                      ..remove(value),
                  ),
                );
              },
              onAdd: (value) {
                final clashConfig = globalState.appController.clashConfig;
                final dns = clashConfig.dns;
                clashConfig.dns = dns.copyWith(
                  fallbackFilter: dns.fallbackFilter.copyWith(
                    ipcidr: List.from(ipcidr)
                      ..add(value),
                  ),
                );
              },
            );
          },
        ),
        extendPageWidth: 360,
      ),
    );
  }
}

class DomainItem extends StatelessWidget {
  const DomainItem({super.key});

  @override
  Widget build(BuildContext context) {
    return ListItem.open(
      title: Text(appLocalizations.domain),
      delegate: OpenDelegate(
        isBlur: false,
        title: appLocalizations.domain,
        widget: Selector<ClashConfig, List<String>>(
          selector: (_, clashConfig) => clashConfig.dns.fallbackFilter.domain,
          shouldRebuild: (prev, next) =>
          !const ListEquality<String>().equals(prev, next),
          builder: (_, domain, __) {
            return UpdatePage(
              title: appLocalizations.domain,
              items: domain,
              titleBuilder: (item) => Text(item),
              onRemove: (value) {
                final clashConfig = globalState.appController.clashConfig;
                final dns = clashConfig.dns;
                clashConfig.dns = dns.copyWith(
                  fallbackFilter: dns.fallbackFilter.copyWith(
                    domain: List.from(domain)
                      ..remove(value),
                  ),
                );
              },
              onAdd: (value) {
                final clashConfig = globalState.appController.clashConfig;
                final dns = clashConfig.dns;
                clashConfig.dns = dns.copyWith(
                  fallbackFilter: dns.fallbackFilter.copyWith(
                    domain: List.from(domain)
                      ..add(value),
                  ),
                );
              },
            );
          },
        ),
        extendPageWidth: 360,
      ),
    );
  }
}

class DnsOptions extends StatelessWidget {
  const DnsOptions({super.key});

  @override
  Widget build(BuildContext context) {
    return DnsDisabledContainer(
      Column(
        children: generateSection(
          title: appLocalizations.options,
          items: [
            const StatusItem(),
            const UseHostsItem(),
            const UseSystemHostsItem(),
            const IPv6Item(),
            const RespectRulesItem(),
            const PreferH3Item(),
            const DnsModeItem(),
            const FakeIpRangeItem(),
            const FakeIpFilterItem(),
            const DefaultNameserverItem(),
            const NameserverPolicyItem(),
            const NameserverItem(),
            const FallbackItem(),
            const ProxyServerNameserverItem(),
          ],
        ),
      ),
    );
  }
}

class FallbackFilterOptions extends StatelessWidget {
  const FallbackFilterOptions({super.key});

  @override
  Widget build(BuildContext context) {
    return DnsDisabledContainer(
      Column(
        children: generateSection(
          title: appLocalizations.fallbackFilter,
          items: [
            const GeoipItem(),
            const GeoipCodeItem(),
            const GeositeItem(),
            const IpcidrItem(),
            const DomainItem(),
          ],
        ),
      ),
    );
  }
}

const dnsItems = <Widget>[
  OverrideItem(),
  DnsOptions(),
  FallbackFilterOptions(),
];
