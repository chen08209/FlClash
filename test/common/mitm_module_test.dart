import 'dart:convert';

import 'package:fl_clash/common/mitm_module.dart';
import 'package:fl_clash/common/mitm_network.dart';
import 'package:fl_clash/common/mitm_requirement.dart';
import 'package:fl_clash/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

const _surge = r'''
#!name=Ads
#!desc=Removes ads\nfrom a few apps
#!system=ios
#!arguments=Toggle:true,Path:"a,b"

[General]
skip-proxy = example.com

[Rule]
DOMAIN-SUFFIX,ads.example.com,REJECT
DOMAIN,track.example.com,REJECT-TINYGIF,pre-matching
IP-CIDR,10.0.0.1,REJECT-DROP,no-resolve
AND,((DOMAIN-SUFFIX,googlevideo.com), (PROTOCOL,UDP)),REJECT
URL-REGEX,"^https?://example\.com/ad,1",REJECT-DICT
USER-AGENT,Example*,REJECT
DOMAIN,proxied.example.com,PROXY
RULE-SET,https://example.com/list,REJECT

[URL Rewrite]
^https?://example\.com/old https://example.com/new 302
// a comment

[Header Rewrite]
http-request ^https://example\.com header-del Cookie

[Body Rewrite]
http-response ^https://example\.com/api "ad":true "ad":false
http-response-jq ^https://example\.com/api 'del(.ad)'

[Map Local]
^https://example\.com/a data-type=text data='{"ok": 1}' header='Content-Type:application/json'
^https://example\.com/b data="https://cdn.example.com/blank.json"
^https://example\.com/c data="blank.json"

[Script]
ad = type=http-response,pattern=^https://example\.com,script-path=https://cdn.example.com/a.js

[MITM]
hostname = %APPEND% *.example.com, api.example.com
hostname = %INSERT% -safe.example.com
skip-server-cert-verify = true
''';

const _loon = r'''
#!name = Loon ads
#!desc = For Loon

[Argument]
Block = switch,true,false,tag=Block ads,desc=Blocks the ad requests
Region = select,"US","JP",tag=Region

[Rule]
DOMAIN-SUFFIX, ads.example.com, REJECT
DOMAIN, example.com

[Rewrite]
^https://example\.com/a reject-dict
^https://example\.com/b - reject
^https://example\.com/c 302 https://example.com/d
^https://example\.com/e header-add X-Region {Region}
^https://example\.com/f response-header-del Set-Cookie
^https://example\.com/g response-body-replace-regex ad noad
^https://example\.com/h response-body-json-del data.ad
^https://example\.com/i mock-response-body data-type=json data="{}" status-code=200
^https://example\.com/j mock-response-body data-type=json data-path=https://cdn.example.com/j.json
response if ${url} ~= /x/ then response.header.del("X")

[MitM]
hostname = *.example.com
''';

void main() {
  group('rules, requirements and settings', () {
    const ios = MitmRequirementEnvironment(system: 'iOS');
    const mac = MitmRequirementEnvironment(system: 'macOS');

    test('pass the rule types the Core shares with mihomo on', () {
      const module = r'''
[Rule]
GEOIP,CN,DIRECT,no-resolve
IP-ASN,13335,REJECT,no-resolve
GEOSITE,category-ads-all,REJECT
DOMAIN-REGEX,^ad\d+\.example\.com$,REJECT
NETWORK,udp,REJECT
PROCESS-PATH,/usr/bin/curl,DIRECT
PROTOCOL,UDP,REJECT
PROTOCOL,QUIC,REJECT
DEST-PORT,>=8000,REJECT
DST-PORT,<1024,DIRECT
DOMAIN,direct.example.com
IP-CIDR,10.1.0.0/16,no-resolve
FINAL,DIRECT
CELLULAR-RADIO,LTE,DIRECT
''';
      final content = parseMitmModule(module);
      expect(content.rules, [
        'GEOIP,CN,DIRECT,no-resolve',
        'IP-ASN,13335,REJECT,no-resolve',
        'GEOSITE,category-ads-all,REJECT',
        r'DOMAIN-REGEX,^ad\d+\.example\.com$,REJECT',
        'NETWORK,UDP,REJECT',
        'PROCESS-PATH,/usr/bin/curl,DIRECT',
        'NETWORK,UDP,REJECT',
        'DST-PORT,8000-65535,REJECT',
        'DST-PORT,0-1023,DIRECT',
        'DOMAIN,direct.example.com,DIRECT',
        'IP-CIDR,10.1.0.0/16,DIRECT,no-resolve',
      ]);
      expect(content.skipped.map((skip) => (skip.line, skip.reason)), [
        ('PROTOCOL,QUIC,REJECT', MitmModuleSkipReason.rule),
        ('FINAL,DIRECT', MitmModuleSkipReason.finalRule),
        ('CELLULAR-RADIO,LTE,DIRECT', MitmModuleSkipReason.deviceRule),
      ]);
      expect(
        parseMitmModule(
          'geoip, cn, direct\nip-asn, 4134, reject\nfinal, proxy',
        ).rules,
        ['GEOIP,cn,DIRECT', 'IP-ASN,4134,REJECT'],
      );
    });

    test('keep a line whose requirement holds and name one that does not', () {
      const module = r'''
#!requirement=CORE_VERSION>=20 && (SYSTEM = 'iOS' || SYSTEM = 'tvOS')
[Rule]
DOMAIN,a.example.com,REJECT #!MACOS-ONLY
DOMAIN,b.example.com,REJECT //!REQUIREMENT SYSTEM=='iOS'
#!REQUIREMENT "CORE_VERSION>=22 AND SYSTEM BEGINSWITH 'mac'" DOMAIN,c.example.com,REJECT
DOMAIN,d.example.com,REJECT #!REQUIREMENT CORE_VERSION<22
DOMAIN,e.example.com,REJECT #!REQUIREMENT NOSUCH>1
''';
      final onMac = parseMitmModule(module, environment: mac);
      expect(onMac.rules, [
        'DOMAIN,a.example.com,REJECT',
        'DOMAIN,c.example.com,REJECT',
      ]);
      expect(onMac.skipped.map((skip) => skip.reason).toSet(), {
        MitmModuleSkipReason.requirement,
      });
      expect(onMac.skipped, hasLength(3));
      expect(onMac.requirementMet, isFalse);
      final onIos = parseMitmModule(module, environment: ios);
      expect(onIos.rules, ['DOMAIN,b.example.com,REJECT']);
      expect(onIos.requirementMet, isTrue);
      expect(
        parseMitmModule('#!requirement=SYSTEM ~ 1').requirementMet,
        isNull,
      );
    });

    test('read the MITM settings a module may set', () {
      const module = r'''
[MITM]
hostname = a.example.com
h2 = true
ca-p12 = MIIJ...
ca-passphrase = secret
tcp-connection = true
''';
      final content = parseMitmModule(module);
      expect(content.h2, isTrue);
      expect(content.mitm.h2, isTrue);
      expect(content.skipped.map((skip) => skip.reason), [
        MitmModuleSkipReason.managedCa,
        MitmModuleSkipReason.managedCa,
        MitmModuleSkipReason.setting,
      ]);
      final merged = mergeMitmModules(const [], [
        parseMitmModule('[MITM]\nh2 = false'),
        content,
      ]);
      expect(merged.mitm.h2, isTrue);
      expect(const Mitm().coreJson(merged.mitm)['h2'], isTrue);
      expect(const Mitm().coreJson(const MitmRules())['h2'], isFalse);
    });

    test('read Quantumult X MITM lines and interaction tasks', () {
      const snippet = r'''
hostname = a.com
skip_dst_ip = 1.1.1.1, 8.8.8.8
p12 = MIIJ...
passphrase = secret
skip_validating_cert = true
event-interaction https://cdn.test/info.js, tag=Info, img-url=info.system
''';
      final content = parseMitmModule(
        snippet,
        resources: const {'https://cdn.test/info.js': 'info0.js'},
      );
      expect(content.mitm.hostname, ['-1.1.1.1', '-8.8.8.8', 'a.com']);
      expect(content.script, [
        'Info = type=generic,script-path=info0.js,timeout=120',
      ]);
      expect(content.skipped.map((skip) => skip.reason), [
        MitmModuleSkipReason.managedCa,
        MitmModuleSkipReason.managedCa,
      ]);
      expect(content.skipVerifyHostname, ['a.com']);
    });

    test('turn IP rewrites into rules and name the sections FlClash lacks', () {
      const module = r'''
[IP Rewrite]
203.0.113.0/24 = reject
2001:db8::/32 = drop
10.7.0.1 = reflect

[Proxy Group]
Ads = select, DIRECT, REJECT

[Panel]
Info = script-name=info

[WireGuard Home]
private-key = x
''';
      final content = parseMitmModule(module);
      expect(content.rules, [
        'IP-CIDR,203.0.113.0/24,REJECT,no-resolve',
        'IP-CIDR6,2001:db8::/32,REJECT-DROP,no-resolve',
      ]);
      expect(content.skipped.map((skip) => skip.reason), [
        MitmModuleSkipReason.reflect,
        MitmModuleSkipReason.proxies,
        MitmModuleSkipReason.appOnly,
        MitmModuleSkipReason.appOnly,
      ]);
    });

    test('split Loon header-add pairs and approximate reject-video', () {
      const plugin = r'''
[Rewrite]
^https://a\.com/x header-add X-A 1 X-B "two words"
^https://a\.com/y header-add X-A 1 X-B
^https://a\.com/v reject-video
''';
      final content = parseMitmModule(plugin);
      expect(content.headerRewrite, [
        r'http-request ^https://a\.com/x header-add X-A 1',
        r'http-request ^https://a\.com/x header-add X-B "two words"',
      ]);
      expect(content.urlRewrite, [r'^https://a\.com/v reject-200']);
      expect(content.skipped.single.reason, MitmModuleSkipReason.unreadable);
    });

    test('read Loon scripts a schedule, the network or a tap runs', () {
      const plugin = r'''
[Argument]
region = select,"CN","US",tag=Region
level = input,"2",type=number
cron = input,"0 9 * * *"

[Script]
cron "0 8 * * *" then script("https://cdn.test/cron.js") with tag="Daily Task", timeout=60
cron {cron} then script("https://cdn.test/cron.js", "a=1")
network-changed then script("https://cdn.test/net.js") with tag="Net"
generic then script("https://cdn.test/g.js", {${region}, ${level}}) with tag="Switch"
generic then script("https://cdn.test/g.js") with enable=false
''';
      final content = parseMitmModule(
        plugin,
        resources: const {
          'https://cdn.test/cron.js': 'cron0.js',
          'https://cdn.test/net.js': 'net0.js',
          'https://cdn.test/g.js': 'g0.js',
        },
      );
      expect(content.script, [
        'Daily Task = type=cron,cronexp="0 8 * * *",script-path=cron0.js,timeout=60',
        'cron.js = type=cron,cronexp="0 9 * * *",script-path=cron0.js,timeout=300,argument="a=1"',
        'Net = type=event,event-name=network-changed,script-path=net0.js,timeout=300',
        r'Switch = type=generic,script-path=g0.js,timeout=300,argument-json="{\"region\":\"CN\",\"level\":2}"',
      ]);
      expect(content.declaredScripts, 5);
      expect(content.skipped.single.reason, MitmModuleSkipReason.disabled);
    });

    test('read Stash force-http-engine and header rewrites', () {
      const override = r'''
name: Stash
http:
  force-http-engine:
    - "api.example.com:8080"
  url-rewrite:
    - ^https://a\.com/x https://b.com/x header
  ca: MIIJ...
''';
      final content = parseMitmModule(override);
      expect(content.mitm.hostname, ['api.example.com:8080']);
      expect(content.urlRewrite, [r'^https://a\.com/x https://b.com/x header']);
      expect(content.skipped.single.reason, MitmModuleSkipReason.managedCa);
    });
  });

  group('inline resources', () {
    test('write out a script provider that carries its payload', () {
      const override = r'''
name: Inline
http:
  script:
    - match: ^https?://a\.com/list
      name: inline
      type: response
script-providers:
  inline:
    payload: |
      $done({})
''';
      final pending = parseMitmModule(override);
      final key = pending.inlineResources.keys.single;
      expect(pending.inlineResources[key], '\$done({})\n');
      expect(pending.resourceUrls, isEmpty);
      expect(pending.skipped.single.reason, MitmModuleSkipReason.notDownloaded);
      final written = parseMitmModule(override, resources: {key: 'in0.js'});
      expect(written.script, [
        r'inline = type=http-response,pattern=^https?://a\.com/list,script-path=in0.js',
      ]);
      expect(written.skipped, isEmpty);
    });
  });

  group('JSON edits', () {
    test("turn Loon's legacy JSON lines into jq", () {
      final content = parseMitmModule(r'''
[Rewrite]
^https:\/\/saas-ad\.cloudpnr\.com\/huifuad-base-api\/api\/tactics\/ad$ response-body-json-del data[0] data[1] data[2]
^https:\/\/edith\.xiaohongshu\.com\/api\/sns\/v1\/search\/hot_list$ response-body-json-replace data.items []
^https:\/\/api\.gamer\.com\.tw\/mobile_app\/anime\/v1\/vip_info\.php response-body-json-add expire "2099-02-27\x2005:20:14" type "web" info "∞"
^http://example.com request-body-json-add data.apps[0] {"appName":"loon","appVersion":"3.2.1"} data.category tool
^http://example.com request-body-json-add data.apps[0]
''');
      expect(content.bodyRewrite, [
        r'http-response-jq ^https:\/\/saas-ad\.cloudpnr\.com\/huifuad-base-api\/api\/tactics\/ad$ del(.data[0], .data[1], .data[2])',
        r'http-response-jq ^https:\/\/edith\.xiaohongshu\.com\/api\/sns\/v1\/search\/hot_list$ if .data.items != null then .data.items = [] else . end',
        r'http-response-jq ^https:\/\/api\.gamer\.com\.tw\/mobile_app\/anime\/v1\/vip_info\.php .expire = "2099-02-27 05:20:14" | .type = "web" | .info = "∞"',
        r'http-request-jq ^http://example.com .data.apps[0] = {"appName":"loon","appVersion":"3.2.1"} | .data.category = "tool"',
      ]);
      expect(content.skipped.single.reason, MitmModuleSkipReason.unreadable);
    });

    test("leave null and false be as Stash's JSON lines say", () {
      final content = parseMitmModule(r'''
name: JSON
http:
  body-rewrite:
    - '^https://api\.zhihu\.com/questions/\d+/feeds\? response-json-del ad_info'
    - ^https:\/\/edith\.xiaohongshu\.com\/api\/sns\/v1\/search\/hot_list$ response-json-replace data.items []
    - ^https://example\.com/meta response-json-add meta.source "proxy" meta.version 1
''');
      expect(content.bodyRewrite, [
        r'http-response-jq ^https://api\.zhihu\.com/questions/\d+/feeds\? if (.ad_info | . != null and . != false) then del(.ad_info) else . end',
        r'http-response-jq ^https:\/\/edith\.xiaohongshu\.com\/api\/sns\/v1\/search\/hot_list$ if (.data.items | . != null and . != false) then .data.items = [] else . end',
        r'http-response-jq ^https://example\.com/meta if .meta.source == null then .meta.source = "proxy" else . end | if .meta.version == null then .meta.version = 1 else . end',
      ]);
      expect(content.skipped, isEmpty);
    });
  });

  group('trust settings', () {
    test("skip verifying only the module's own hosts, never every host", () {
      final surge = parseMitmModule('''
[MITM]
hostname = %APPEND% api.example.com, *.ads.test, -skip.test
skip-server-cert-verify = true
client-source-address = %APPEND% -192.168.1.2, 192.168.1.0/24
''');
      expect(surge.skipVerifyHostname, ['api.example.com', '*.ads.test']);
      expect(surge.clientSourceAddress, ['-192.168.1.2, 192.168.1.0/24']);
      expect(surge.asksConsent, isTrue);
      expect(surge.skipped, isEmpty);

      final all = parseMitmModule('''
[MITM]
hostname = %APPEND% *, api.example.com
skip-server-cert-verify = true
''');
      expect(all.skipVerifyHostname, ['api.example.com']);
      expect(all.skipped.single.reason, MitmModuleSkipReason.skipVerifyAll);

      final off = parseMitmModule('''
[MITM]
hostname = %APPEND% api.example.com
skip-server-cert-verify = false
''');
      expect(off.skipVerifyHostname, isEmpty);
      expect(off.asksConsent, isFalse);
    });

    test('read Quantumult X skip_src_ip and skip_validating_cert', () {
      final content = parseMitmModule(r'''
hostname = a.com, -b.com
skip_src_ip = 192.168.4.50, 192.168.4.51
skip_validating_cert = true
^https?://a\.com/ad url reject
''');
      expect(content.clientSourceAddress, ['-192.168.4.50, -192.168.4.51']);
      expect(content.skipVerifyHostname, ['a.com']);
      expect(content.skipped, isEmpty);
    });

    test("mock a request body with Loon's mock-request-body", () {
      final content = parseMitmModule(r'''
[Rewrite]
^https?://api\.example\.com/log mock-request-body data-type=json data="{\"a\":1}" status-code=200
''');
      expect(content.requestBodyMock, [
        r'^https?://api\.example\.com/log data-type="text" data="{\"a\":1}" header="Content-Type:application/json"',
      ]);
      expect(content.mapLocal, isEmpty);
      expect(content.skipped, isEmpty);
    });
  });

  group('rule sets', () {
    String setOf(MitmModuleContent content, int index) =>
        content.rules[index].split(',')[1];

    test('read a rule set file the module names once it is attached', () {
      const module = '''
[Rule]
DOMAIN-SET,reject.conf,REJECT
RULE-SET,rules/ad.list,REJECT
''';
      final content = parseMitmModule(
        module,
        resources: const {'reject.conf': 'ab12.conf'},
      );
      expect(content.ruleProviders[setOf(content, 0)], {
        'type': 'file',
        'behavior': 'domain',
        'format': 'domain-set',
        'path': 'mitm/resources/ab12.conf',
      });
      expect(content.rules, hasLength(1));
      expect(content.skipped.single.reason, MitmModuleSkipReason.relativeData);
    });

    test('read a DOMAIN-SET as Surge means its leading dots', () {
      const module = '''
[Rule]
DOMAIN-SET,https://ruleset.skk.moe/List/domainset/reject.conf,REJECT
RULE-SET,https://ruleset.skk.moe/List/domainset/reject.conf,REJECT
DOMAIN-SET,reject.conf,REJECT
''';
      final content = parseMitmModule(module);
      expect(content.ruleProviders[setOf(content, 0)], {
        'type': 'http',
        'behavior': 'domain',
        'format': 'domain-set',
        'url': 'https://ruleset.skk.moe/List/domainset/reject.conf',
        'interval': 86400,
      });
      expect(setOf(content, 1), isNot(setOf(content, 0)));
      expect(content.skipped.single.reason, MitmModuleSkipReason.relativeData);
    });

    test('bring their providers along', () {
      const module = r'''
[Rule]
RULE-SET,https://example.com/ads.list,REJECT,no-resolve,update-interval=-1
RULE-SET,https://example.com/cn.list,DIRECT,extended-matching
RULE-SET,LAN,DIRECT
RULE-SET,SYSTEM,DIRECT
RULE-SET,Streaming,REJECT
RULE-SET,Missing,REJECT
RULE-SET,https://example.com/p.list,Proxy

[Ruleset Streaming]
DOMAIN-SUFFIX,netflix.com
RULE-SET,https://example.com/nested.list
DOMAIN,netflixdnstest0.com
''';
      final content = parseMitmModule(module);
      expect(
        [for (final rule in content.rules) rule.split(',')..removeAt(1)],
        [
          ['RULE-SET', 'REJECT', 'no-resolve'],
          ['RULE-SET', 'DIRECT'],
          ['RULE-SET', 'DIRECT'],
          ['RULE-SET', 'DIRECT'],
          ['RULE-SET', 'REJECT'],
          ['RULE-SET', 'Proxy'],
        ],
      );
      expect(content.exits, {'Proxy'});
      final providers = content.ruleProviders;
      expect(providers[setOf(content, 0)], {
        'type': 'http',
        'behavior': 'classical',
        'format': 'text',
        'url': 'https://example.com/ads.list',
        'interval': 0,
      });
      expect(providers[setOf(content, 1)]!['interval'], 86400);
      expect(
        (providers[setOf(content, 2)]!['payload']! as List).first,
        'DOMAIN-SUFFIX,local',
      );
      expect(
        (providers[setOf(content, 3)]!['payload']! as List).last,
        'PROCESS-NAME,netbiosd',
      );
      expect(providers[setOf(content, 4)], {
        'type': 'inline',
        'behavior': 'classical',
        'payload': ['DOMAIN-SUFFIX,netflix.com', 'DOMAIN,netflixdnstest0.com'],
      });
      expect(content.skipped.map((skip) => (skip.line, skip.reason)), [
        ('RULE-SET,Missing,REJECT', MitmModuleSkipReason.relativeData),
        ('RULE-SET,https://example.com/nested.list', MitmModuleSkipReason.rule),
      ]);
    });

    test('of one name merge across modules, under names of their own', () {
      final a = parseMitmModule(
        '[Ruleset Ads]\nDOMAIN,a.com\n[Rule]\nRULE-SET,Ads,REJECT',
      );
      final b = parseMitmModule('[Ruleset Ads]\nDOMAIN,b.com');
      final merged = mergeMitmModules(const [], [a, b]);
      final name = setOf(a, 0);
      expect(name, startsWith('mitm-'));
      expect(merged.ruleProviders[name]!['payload'], [
        'DOMAIN,a.com',
        'DOMAIN,b.com',
      ]);
    });

    test('come from Loon remote rules and Stash rule providers', () {
      const plugin = r'''
[Rule]
https://example.com/loon.list, REJECT
[Remote Rule]
https://example.com/remote.list, policy=DIRECT, tag=CN, enabled=true
https://example.com/off.list, policy=REJECT, enabled=false
''';
      final loon = parseMitmModule(plugin);
      expect(loon.rules.map((rule) => rule.split(',').last), [
        'REJECT',
        'DIRECT',
      ]);
      expect(loon.ruleProviders.values.map((provider) => provider['url']), [
        'https://example.com/loon.list',
        'https://example.com/remote.list',
      ]);
      expect(loon.skipped.single.reason, MitmModuleSkipReason.disabled);
      const override = r'''
name: Stash
rule-providers:
  ads:
    type: http
    behavior: domain
    format: text
    url: https://example.com/ads.txt
    path: ./ads.txt
    interval: 3600
  local:
    type: file
    behavior: classical
    path: ./local.yaml
rules:
  - RULE-SET,ads,REJECT
  - RULE-SET,local,DIRECT
''';
      final stash = parseMitmModule(override);
      expect(stash.rules, ['RULE-SET,${setOf(stash, 0)},REJECT']);
      expect(stash.ruleProviders[setOf(stash, 0)], {
        'type': 'http',
        'behavior': 'domain',
        'format': 'text',
        'url': 'https://example.com/ads.txt',
        'interval': 3600,
      });
      expect(stash.skipped.map((skip) => skip.reason), [
        MitmModuleSkipReason.relativeData,
        MitmModuleSkipReason.rule,
      ]);
    });
  });

  group('network settings', () {
    test('a Surge module replaces DNS servers unless it marks them', () {
      final content = parseMitmModule('''
[General]
dns-server = 223.5.5.5, system
encrypted-dns-server = %APPEND% h3://dns.alidns.com/dns-query
skip-proxy = %APPEND% *.local, 10.0.0.0/8
tun-excluded-routes = 192.168.0.0/16, 1.1.1.1
tun-included-routes = 10.8.0.0/16
always-real-ip = *.srv.nintendo.net
force-http-engine-hosts = api.test:8080
hijack-dns = 8.8.8.8:53
tun-excluded-routes = lan

[Host]
ad.test = 0.0.0.0
alias.test = target.test
*.corp.test = server:10.0.0.1
bad host = 1.1.1.1
''');
      final network = content.network;
      expect(
        network.nameserver,
        const MitmListEdit(after: ['https://dns.alidns.com/dns-query#h3=true']),
      );
      expect(
        network.defaultNameserver,
        const MitmListEdit(replace: true, before: ['223.5.5.5', 'system://']),
      );
      expect(
        network.bypassDomain,
        const MitmListEdit(after: ['*.local', '10.0.0.0/8']),
      );
      expect(
        network.routeExcludeAddress,
        const MitmListEdit(
          replace: true,
          before: ['192.168.0.0/16', '1.1.1.1/32'],
        ),
      );
      expect(network.routeAddress, ['10.8.0.0/16']);
      expect(
        network.fakeIpFilter,
        const MitmListEdit(replace: true, before: ['*.srv.nintendo.net']),
      );
      expect(network.hosts, {
        'ad.test': ['0.0.0.0'],
        'alias.test': ['target.test'],
      });
      expect(network.nameserverPolicy, {
        '*.corp.test': ['10.0.0.1'],
      });
      expect(content.hostname, ['api.test:8080']);
      expect(
        [for (final skip in content.skipped) (skip.line, skip.reason)],
        [
          ('hijack-dns = 8.8.8.8:53', MitmModuleSkipReason.setting),
          ('tun-excluded-routes = lan', MitmModuleSkipReason.unreadable),
          ('bad host = 1.1.1.1', MitmModuleSkipReason.unreadable),
        ],
      );
      expect(
        parseMitmModule('[General]\ndns-server = 1.1.1.1').network.nameserver,
        const MitmListEdit(replace: true, before: ['1.1.1.1']),
      );
    });

    test('a Loon plugin adds its servers and routes', () {
      final network = parseMitmModule('''
[General]
dns-server = 119.29.29.29
doh-server = https://doh.pub/dns-query
bypass-tun = 10.0.0.0/8
include-tun = 172.16.0.0/12
real-ip = *.lan

[Rewrite]
^https://a\\.com/ad reject
''').network;
      expect(
        network.nameserver,
        const MitmListEdit(
          after: ['119.29.29.29', 'https://doh.pub/dns-query'],
        ),
      );
      expect(network.defaultNameserver, isNull);
      expect(
        network.routeExcludeAddress,
        const MitmListEdit(after: ['10.0.0.0/8']),
      );
      expect(network.routeAddress, ['172.16.0.0/12']);
      expect(network.fakeIpFilter, const MitmListEdit(after: ['*.lan']));
    });

    test('a Stash override puts its servers first unless marked', () {
      MitmNetwork read(String dns) => parseMitmModule('''
name: DNS
dns:
$dns
hosts:
  ad.test: 0.0.0.0
''').network;
      final network = read('''
  nameserver:
    - 223.5.5.5
  default-nameserver: #!replace
    - 119.29.29.29
  fake-ip-filter:
    - '*.lan'
  nameserver-policy:
    '+.corp.test': [10.0.0.1, system]
  enhanced-mode: redir-host''');
      expect(network.nameserver, const MitmListEdit(before: ['223.5.5.5']));
      expect(
        network.defaultNameserver,
        const MitmListEdit(replace: true, before: ['119.29.29.29']),
      );
      expect(network.fakeIpFilter, const MitmListEdit(before: ['*.lan']));
      expect(network.nameserverPolicy, {
        '+.corp.test': ['10.0.0.1', 'system://'],
      });
      expect(network.hosts, {
        'ad.test': ['0.0.0.0'],
      });
      expect(
        read('  nameserver: #!append\n    - 1.1.1.1').nameserver,
        const MitmListEdit(after: ['1.1.1.1']),
      );
    });

    test('later modules go over earlier ones when merged', () {
      final merged = mergeMitmModules(const [], [
        parseMitmModule('[General]\ndns-server = 1.1.1.1\nskip-proxy = a'),
        parseMitmModule('[General]\ndns-server = 8.8.8.8\nskip-proxy = b'),
      ]).network;
      expect(merged.nameserver?.applyTo(const ['p']), ['8.8.8.8']);
      expect(merged.bypassDomain?.applyTo(const ['own']), ['b']);
    });
  });

  group('exits', () {
    test('are the policies a module names that are not built in', () {
      const module = r'''
[Rule]
DOMAIN,a.example,Proxy
DOMAIN,b.example,"Media Group",no-resolve
IP-CIDR,10.0.0.0/8,Media Group,no-resolve
URL-REGEX,^http://a\.example/x,Proxy
DOMAIN,c.example,DIRECT
''';
      final surge = parseMitmModule(module);
      expect(surge.rules, [
        'DOMAIN,a.example,Proxy',
        'DOMAIN,b.example,Media Group',
        'IP-CIDR,10.0.0.0/8,Media Group,no-resolve',
        'DOMAIN,c.example,DIRECT',
      ]);
      expect(surge.exits, {'Proxy', 'Media Group'});
      expect(surge.skipped.single.reason, MitmModuleSkipReason.httpRulePolicy);
      expect(parseMitmModule('host-suffix, a.com, proxy').rules, [
        'DOMAIN-SUFFIX,a.com,PROXY',
      ]);
      expect(parseMitmModule('[Rule]\nDOMAIN,x,PROXY').exits, {'PROXY'});
      expect(parseMitmModule('[Rule]\nGEOSITE,nope,Proxy').exits, {'Proxy'});
    });

    test('are replaced by where the profile sends them', () {
      expect(
        mitmRulesWithExits(
          [
            'DOMAIN,a,Proxy',
            'IP-CIDR,1.0.0.0/8,Proxy,no-resolve',
            'AND,((DOMAIN,b),(NETWORK,UDP)),REJECT',
            'DOMAIN,c,DIRECT',
          ],
          {'Proxy'},
          (exit) => 'HK',
        ),
        [
          'DOMAIN,a,HK',
          'IP-CIDR,1.0.0.0/8,HK,no-resolve',
          'AND,((DOMAIN,b),(NETWORK,UDP)),REJECT',
          'DOMAIN,c,DIRECT',
        ],
      );
    });
  });

  group('Loon conditional rewrites', () {
    MitmModuleContent read(String lines) => parseMitmModule(
      '[Rewrite]\n$lines',
      resources: const {
        'https://cdn.test/s.js': 's0.js',
        'https://cdn.test/m.json': 'm0.json',
      },
    );

    test('turn URL conditions and actions into the Core lists', () {
      final content = read(r'''
request if ${url} ~= /^https:\/\/old\.example\.com(\/.*)$/ as m then url.replace("https://new.example.com${m.1}")
request if ${url} ~= /^http:\/\/example\.com/ then redirect(302, "https://api.example.com")
request if ${url} ~= /^https:\/\/a\.com\/(ad|track)/i || ${url} == "https://b.com/x" then reject_dict(200)
request if ${url} ~= /^https:\/\/a\.com\/legal/ then reject(451, "Unavailable for legal reasons")
request if ${url} ~= /^https:\/\/a\.com\/h/ then request.header.set("X-Loon", "true") | request.header.del(["Cookie", "Referer"])
response if ${url} ~= /^https:\/\/a\.com\/b/ then response.body.replace(/"enabled":\s*(false)/, "\"enabled\":true") | response.json.delete("data.ads") | response.json.add("data.items[0].vip", true) | response.json.jq(".data.ads = []")
response if ${url} ~= /^https:\/\/a\.com\/r/ then response.json.replace("data.price", 9.99) | response.header.replace("Server", /nginx(\d)/, "srv$1")
response if ${url} ~= /^https:\/\/a\.com\/m$/ then response.body.mock("json", `{"code":0}`, 200)
response if ${url} ~= /^https:\/\/a\.com\/f$/ then response.body.mock_file("json", "https://cdn.test/m.json")
request if ${url} ~= /^https:\/\/a\.com\/s/ then script("https://cdn.test/s.js", "k=v") with tag="S", timeout=10, requires_body=true
''');
      expect(content.urlRewrite, [
        r'^https:\/\/old\.example\.com(\/.*)$ https://new.example.com$1 header',
        r'^http:\/\/example\.com https://api.example.com 302',
      ]);
      expect(content.headerRewrite, [
        r'http-request ^https:\/\/a\.com\/h header-del X-Loon',
        r'http-request ^https:\/\/a\.com\/h header-add X-Loon true',
        r'http-request ^https:\/\/a\.com\/h header-del Cookie',
        r'http-request ^https:\/\/a\.com\/h header-del Referer',
        r'http-response ^https:\/\/a\.com\/r header-replace-regex Server nginx(\d) srv$1',
      ]);
      expect(content.bodyRewrite, [
        r'http-response ^https:\/\/a\.com\/b "\"enabled\":\s*(false)" "\"enabled\":true"',
        r'http-response-jq ^https:\/\/a\.com\/b del(.data.ads)',
        r'http-response-jq ^https:\/\/a\.com\/b .data.items[0].vip = true',
        r'http-response-jq ^https:\/\/a\.com\/b .data.ads = []',
        r'http-response-jq ^https:\/\/a\.com\/r if .data.price != null then .data.price = 9.99 else . end',
      ]);
      expect(content.mapLocal, [
        r'(?:(?i:^https:\/\/a\.com\/(ad|track)))|(?:^https://b\.com/x$) data-type="text" data="{}" status-code="200" header="Content-Type:application/json"',
        r'^https:\/\/a\.com\/legal data-type="text" data="Unavailable for legal reasons" status-code="451"',
        r'^https:\/\/a\.com\/m$ data-type="text" data="{\"code\":0}" status-code="200" header="Content-Type:application/json"',
        r'^https:\/\/a\.com\/f$ data-type="file" data="m0.json" header="Content-Type:application/json"',
      ]);
      expect(content.script, [
        r'S = type=http-request,pattern=^https:\/\/a\.com\/s,script-path=s0.js,requires-body=true,timeout=10,argument="k=v"',
      ]);
      expect(content.declaredScripts, 0);
      expect(content.skipped, isEmpty);
    });

    test('match the method and headers on the request head', () {
      final content = read(r'''
request if ${url} ~= /^https:\/\/a\.com\/api/ && ${request.method} == "POST" then reject_dict(200)
request if ${url} ~= /^https:\/\/a\.com\/ua/ && ${request.header['User-Agent']} ~= /httpdns/i then reject(200)
request if ${url} ~= /^https:\/\/a\.com\/x/ && ${request.method} == "GET" then request.header.del("X")
request if ${url} ~= /^https:\/\/a\.com\/y/ && ${request.method} == "GET" then reject(403)
response if ${url} ~= /^https:\/\/a\.com\/z/ && ${response.status} == 200 then response.header.del("X")
request if ${url} ~= /^https:\/\/a\.com\/q/ then request.body.mock("json", "{}")
request if ${url} then reject(200)
''');
      expect(content.urlRewrite, [
        r'^https:\/\/a\.com\/api "^(?=POST )" url-and-header reject-dict',
        r'^https:\/\/a\.com\/ua "^(?=[\s\S]*\r\n(?i:User-Agent): [^\r\n]*(?:(?i:httpdns))[^\r\n]*\r\n)" url-and-header reject-200',
      ]);
      expect(content.headerRewrite, [
        r'http-request ^https:\/\/a\.com\/x request-head "^(?=GET )" header-del X',
        r'http-response ^https:\/\/a\.com\/z response-head "^(?=\S+ 200(?: |\r\n))" header-del X',
      ]);
      expect(content.mapLocal, [
        r'^https:\/\/a\.com\/y request-head "^(?=GET )" data-type="text" data="" status-code="403"',
      ]);
      expect(content.requestBodyMock, [
        r'^https:\/\/a\.com\/q data-type="text" data="{}" header="Content-Type:application/json"',
      ]);
      expect(content.skipped.map((skip) => skip.reason), [
        MitmModuleSkipReason.unreadable,
      ]);
    });

    test('match the status and both heads on a response', () {
      final content = read(r'''
response if ${url} ~= /^https:\/\/api\.example\.com\/profile$/ && ${response.status} == 200 then response.json.replace("data.vip", true)
response if ${url} ~= /^https:\/\/a\.com\/c/ && ${response.header['Content-Type']} ~= /json/i && ${request.method} == "POST" then response.json.delete("ads") | response.header.set("Cache-Control", "no-store")
response if ${url} ~= /^https:\/\/a\.com\/s/ && ${response.status} ~= /^30[12]$/ then response.body.replace(/ad/, "")
request if ${url} ~= /^https:\/\/a\.com\/q/ && ${response.status} == 200 then request.header.del("X")
response if ${url} ~= /^https:\/\/a\.com\/m/ && ${response.status} == 200 then response.body.mock("json", "{}")
response if ${url} ~= /^https:\/\/a\.com\/u/ && ${response.status} == 200 then reject(200)
''');
      expect(content.bodyRewrite, [
        r'http-response-jq ^https:\/\/api\.example\.com\/profile$ response-head "^(?=\S+ 200(?: |\r\n))" if .data.vip != null then .data.vip = true else . end',
        r'http-response-jq ^https:\/\/a\.com\/c request-head "^(?=POST )" response-head "^(?=[\s\S]*\r\n(?i:Content-Type): [^\r\n]*(?:(?i:json))[^\r\n]*\r\n)" del(.ads)',
        r'http-response ^https:\/\/a\.com\/s response-head "^(?=\S+ (?:30[12])(?: |\r\n))" ad ""',
      ]);
      expect(content.headerRewrite, [
        r'http-response ^https:\/\/a\.com\/c request-head "^(?=POST )" response-head "^(?=[\s\S]*\r\n(?i:Content-Type): [^\r\n]*(?:(?i:json))[^\r\n]*\r\n)" header-del Cache-Control',
        r'http-response ^https:\/\/a\.com\/c request-head "^(?=POST )" response-head "^(?=[\s\S]*\r\n(?i:Content-Type): [^\r\n]*(?:(?i:json))[^\r\n]*\r\n)" header-add Cache-Control no-store',
      ]);
      expect(content.skipped.map((skip) => skip.reason), [
        MitmModuleSkipReason.unreadable,
        MitmModuleSkipReason.unreadable,
        MitmModuleSkipReason.conditional,
      ]);
    });

    test('join URL tests and alternatives on one head', () {
      final content = read(r'''
request if ${url} ~= /^https:\/\/api\.example\.com\// && ${url} ~= /ad_id=/ then reject(200)
request if ${url} ~= /^https:\/\/api\.example\.com\/feed/ && (${request.method} == "GET" || ${request.method} == "HEAD") then reject_dict(200)
response if ${url} ~= /^https:\/\/api\.example\.com\/v1/ && (${response.status} == 204 || ${response.header['X-Ad']} == "1") then response.header.del("Set-Cookie")
request if ${url} ~= /^https:\/\/a\.com/ || ${request.method} == "GET" then reject(200)
request if ${url} ~= /a/ as m && ${url} ~= /b/ then url.replace("https://c.com${m.1}")
''');
      expect(content.mapLocal, [
        r'^(?=[\s\S]*?(?:^https:\/\/api\.example\.com\/))(?=[\s\S]*?(?:ad_id=)) data-type="text" data="" status-code="200"',
      ]);
      expect(content.urlRewrite, [
        r'^https:\/\/api\.example\.com\/feed "^(?:(?=GET )|(?=HEAD ))" url-and-header reject-dict',
      ]);
      expect(content.headerRewrite, [
        r'http-response ^https:\/\/api\.example\.com\/v1 response-head "^(?:(?=\S+ 204(?: |\r\n))|(?=[\s\S]*\r\n(?i:X-Ad): 1\r\n))" header-del Set-Cookie',
      ]);
      expect(content.skipped.map((skip) => skip.reason), [
        MitmModuleSkipReason.conditional,
        MitmModuleSkipReason.conditional,
      ]);
    });

    test('run scripts by the request and response heads', () {
      final content = read(r'''
request if ${url} ~= /^https:\/\/a\.com\/s/ && ${request.method} == "POST" then script("https://cdn.test/s.js") with tag="S"
response if ${url} ~= /^https:\/\/a\.com\/r/ && ${response.status} == 200 then script("https://cdn.test/s.js") with tag="R"
''');
      expect(content.script, [
        r'S = type=http-request,pattern=^https:\/\/a\.com\/s,request-head="^(?=POST )",script-path=s0.js,timeout=20',
        r'R = type=http-response,pattern=^https:\/\/a\.com\/r,response-head="^(?=\S+ 200(?: |\r\n))",script-path=s0.js,timeout=20',
      ]);
      expect(content.skipped, isEmpty);
    });

    test('mock bodies by the request head', () {
      final content = read(r'''
request if ${url} ~= /^https:\/\/api\.example\.com\/v1\/report/ && ${request.method} == "POST" then request.body.mock("json", `{"events":[]}`)
request if ${url} ~= /^https:\/\/api\.example\.com\/v1\/upload/ then request.body.mock_file("json", "https://cdn.test/m.json")
response if ${url} ~= /^https:\/\/api\.example\.com\/ad/ && ${request.header['User-Agent']} ~= /^Example\// then response.body.mock("json", "{}", 200)
''');
      expect(content.requestBodyMock, [
        r'^https:\/\/api\.example\.com\/v1\/report request-head "^(?=POST )" data-type="text" data="{\"events\":[]}" header="Content-Type:application/json"',
        r'^https:\/\/api\.example\.com\/v1\/upload data-type="file" data="m0.json" header="Content-Type:application/json"',
      ]);
      expect(content.mapLocal, [
        r'^https:\/\/api\.example\.com\/ad request-head "^(?=[\s\S]*\r\n(?i:User-Agent): (?:Example\/)[^\r\n]*\r\n)" data-type="text" data="{}" status-code="200" header="Content-Type:application/json"',
      ]);
      expect(content.skipped, isEmpty);
    });
  });

  group('request rules', () {
    test('turn USER-AGENT rules into rewrites the Core judges by the head', () {
      const module = r'''
[Rule]
USER-AGENT,"httpdns*",REJECT
USER-AGENT,"Httpsdns*",REJECT
USER-AGENT,Apple.News?(1)*,REJECT-DICT
USER-AGENT,Instagram*,DIRECT
URL-REGEX,^http://a\.com/ad,PROXY
''';
      final content = parseMitmModule(module);
      expect(content.urlRewrite, [
        r'^https?:// "\r\nUser-Agent: httpdns[^\r\n]*\r\n" url-and-header reject',
        r'^https?:// "\r\nUser-Agent: Httpsdns[^\r\n]*\r\n" url-and-header reject',
        r'^https?:// "\r\nUser-Agent: Apple\.News[^\r\n]\(1\)[^\r\n]*\r\n" url-and-header reject-dict',
      ]);
      expect(content.requestRules, 3);
      expect(content.rules, isEmpty);
      expect(content.skipped.map((skip) => skip.reason), [
        MitmModuleSkipReason.httpRulePolicy,
        MitmModuleSkipReason.httpRulePolicy,
      ]);
      expect(parseMitmModule('user-agent, ?abc*, reject').urlRewrite, [
        r'^https?:// "\r\nUser-Agent: [^\r\n]abc[^\r\n]*\r\n" url-and-header reject',
      ]);
    });

    test('pass Quantumult X url-and-header rewrites on', () {
      const snippet = r'''
^http:\/\/.+\/amdc\/mobileDispatch %E8%8F%9C%E9%B8%9F%E8%A3%B9%E8%A3%B9* url-and-header reject
^https?:\/\/weibointl\.api\.weibo\.cn\/portal\.php\?a=get_searching_info WeiboOverseas url-and-header reject-dict
^http://example\.com/resource1/1/ ^POST url-and-header 302 http://example.com/post
^http://example\.com/resource1/1/ \r\nUser-Agent: example-agent url-and-header reject
^https:\/\/config\.ab\.qq\.com\/tab\/GetTabRemoteConfig(?:\?.*)?$ (?i)\r\nUser-Agent:\s*QQSportsV3\/ url-and-header script-response-body https://cdn.test/a.js
^https?:\/\/api\.weibo\.cn\/\d\/(cardlist\?v_f=\d|ad\/weibointl\?) WeiboOverseas url-and-header echo-response text/html echo-response https://cdn.test/reject-dict.json
^https:\/\/a\.com\/j WeiboOverseas url-and-header jsonjq-response-body '.ads = []'
^https:\/\/a\.com\/h ^POST url-and-header request-header (\r\n)X-Ad:[^\r]*(\r\n) request-header $1$2
''';
      final content = parseMitmModule(
        snippet,
        resources: const {
          'https://cdn.test/a.js': 'a0.js',
          'https://cdn.test/reject-dict.json': 'r0.json',
        },
      );
      expect(content.urlRewrite, [
        r'^http:\/\/.+\/amdc\/mobileDispatch %E8%8F%9C%E9%B8%9F%E8%A3%B9%E8%A3%B9* url-and-header reject',
        r'^https?:\/\/weibointl\.api\.weibo\.cn\/portal\.php\?a=get_searching_info WeiboOverseas url-and-header reject-dict',
        r'^http://example\.com/resource1/1/ ^POST url-and-header 302 http://example.com/post',
        r'^http://example\.com/resource1/1/ "\r\nUser-Agent: example-agent" url-and-header reject',
      ]);
      expect(content.script, [
        r'a.js = type=http-response,pattern="^https:\/\/config\.ab\.qq\.com\/tab\/GetTabRemoteConfig(?:\?.*)?$",request-head="(?i)\r\nUser-Agent:\s*QQSportsV3\/",requires-body=true,script-path=a0.js',
      ]);
      expect(content.mapLocal, [
        r'^https?:\/\/api\.weibo\.cn\/\d\/(cardlist\?v_f=\d|ad\/weibointl\?) request-head WeiboOverseas data-type="file" data="r0.json" header="Content-Type:text/html"',
      ]);
      expect(content.bodyRewrite, [
        r"http-response-jq ^https:\/\/a\.com\/j request-head WeiboOverseas '.ads = []'",
      ]);
      expect(content.headerRewrite, [
        r'http-request ^https:\/\/a\.com\/h request-head ^POST header-text-replace (\r\n)X-Ad:[^\r]*(\r\n) $1$2',
      ]);
      expect(content.skipped, isEmpty);
    });
  });

  group('jq rewrites', () {
    test('go to the Core as Surge writes them, from every format', () {
      const snippet = r'''
^https:\/\/bp-api\.bestv\.cn\/cms\/api\/free\/open\/advertisingV2 url jsonjq-response-body '.dt = []'
^https:\/\/bp-api\.bestv\.cn\/cms\/api\/c\/search\/hot\/v(2|4) url jsonjq-response-body '.dt.hot = [] | .dt.recommand = [] | .dt.bannerList = []'
^https:\/\/(apissl|az2-api(-js|-idc)?)\.(gifshow|ksapisrv)\.com\/rest\/system\/startup\? url jsonjq-response-body 'del(.reskinConfig.sidebarExSquareStyle.moreList, .reskinConfig.sidebarExSquareStyle.topList)'
^https?://a\.com/req url jsonjq-request-body '.ad = false'
''';
      final content = parseMitmModule(snippet);
      expect(content.bodyRewrite, [
        r"http-response-jq ^https:\/\/bp-api\.bestv\.cn\/cms\/api\/free\/open\/advertisingV2 '.dt = []'",
        r"http-response-jq ^https:\/\/bp-api\.bestv\.cn\/cms\/api\/c\/search\/hot\/v(2|4) '.dt.hot = [] | .dt.recommand = [] | .dt.bannerList = []'",
        r"http-response-jq ^https:\/\/(apissl|az2-api(-js|-idc)?)\.(gifshow|ksapisrv)\.com\/rest\/system\/startup\? 'del(.reskinConfig.sidebarExSquareStyle.moreList, .reskinConfig.sidebarExSquareStyle.topList)'",
        r"http-request-jq ^https?://a\.com/req '.ad = false'",
      ]);
      expect(content.skipped, isEmpty);
      final loon = parseMitmModule(r'''
[Rewrite]
^https?:\/\/api\.a\.com\/feed response-body-json-jq 'del(.data.ad)'
^https?:\/\/api\.a\.com\/post request-body-json-jq '.debug = false'
''');
      expect(loon.bodyRewrite, [
        r"http-response-jq ^https?:\/\/api\.a\.com\/feed 'del(.data.ad)'",
        r"http-request-jq ^https?:\/\/api\.a\.com\/post '.debug = false'",
      ]);
      expect(loon.skipped, isEmpty);
    });
  });

  group('a Surge module', () {
    final content = parseMitmModule(
      _surge,
      resources: const {'https://cdn.example.com/blank.json': 'abc.json'},
    );

    test('reads its metadata and arguments', () {
      expect(content.name, 'Ads');
      expect(content.description, 'Removes ads\nfrom a few apps');
      expect(content.system, 'ios');
      expect(
        [
          for (final argument in content.arguments)
            (argument.name, argument.defaultValue, argument.type),
        ],
        [
          ('Toggle', 'true', MitmModuleArgumentType.toggle),
          ('Path', 'a,b', MitmModuleArgumentType.input),
        ],
      );
    });

    test('keeps only rules mihomo can run with DIRECT or REJECT', () {
      expect(content.rules, [
        'DOMAIN-SUFFIX,ads.example.com,REJECT',
        'DOMAIN,track.example.com,REJECT',
        'IP-CIDR,10.0.0.1/32,REJECT-DROP,no-resolve',
        'AND,((DOMAIN-SUFFIX,googlevideo.com),(NETWORK,UDP)),REJECT',
        'DOMAIN,proxied.example.com,PROXY',
        'RULE-SET,${content.ruleProviders.keys.single},REJECT',
      ]);
      expect(content.exits, {'PROXY'});
      expect(content.skipped.where((skip) => skip.section == 'Rule'), isEmpty);
    });

    test('turns rejecting URL and User-Agent rules into URL rewrites', () {
      expect(content.urlRewrite, [
        r'^https?://example\.com/ad,1 reject-dict',
        r'^https?:// "\r\nUser-Agent: Example[^\r\n]*\r\n" url-and-header reject',
        r'^https?://example\.com/old https://example.com/new 302',
      ]);
      expect(content.requestRules, 2);
    });

    test('passes Surge rewrites on, jq ones included', () {
      expect(content.headerRewrite, [
        r'http-request ^https://example\.com header-del Cookie',
      ]);
      expect(content.bodyRewrite, [
        r'http-response ^https://example\.com/api "ad":true "ad":false',
        r"http-response-jq ^https://example\.com/api 'del(.ad)'",
      ]);
    });

    test('quotes map local values and serves URLs from resources', () {
      expect(content.mapLocal, [
        r'^https://example\.com/a data-type="text" data="{\"ok\": 1}" header="Content-Type:application/json"',
        r'^https://example\.com/b data="abc.json"',
      ]);
      expect(content.resourceUrls, {
        'https://cdn.example.com/blank.json',
        'https://cdn.example.com/a.js',
      });
      expect(
        content.skipped.map((skip) => skip.reason),
        contains(MitmModuleSkipReason.relativeData),
      );
    });

    test('reads hostname lines and skips verifying only them', () {
      expect(content.hostname, ['*.example.com', 'api.example.com']);
      expect(content.insertedHostname, ['-safe.example.com']);
      expect(content.mitm.hostname, [
        '-safe.example.com',
        '*.example.com',
        'api.example.com',
      ]);
      expect([
        for (final skip in content.skipped)
          if (skip.section == 'MITM' || skip.section == 'General') skip.reason,
      ], isEmpty);
      expect(content.skipVerifyHostname, ['*.example.com', 'api.example.com']);
      expect(
        content.network.bypassDomain,
        const MitmListEdit(replace: true, before: ['example.com']),
      );
    });

    test('a file not downloaded yet leaves its line out', () {
      final pending = parseMitmModule(_surge);

      expect(pending.mapLocal, hasLength(1));
      expect(
        pending.skipped.map((skip) => skip.reason),
        contains(MitmModuleSkipReason.notDownloaded),
      );
    });
  });

  test('Surge arguments are substituted, and can comment a line out', () {
    const module = '''
#!arguments=Host:a.example.com,Off:#
[MITM]
hostname = %APPEND% {{{Host}}}
[Rule]
{{{Off}}}DOMAIN,b.example.com,REJECT
''';

    expect(parseMitmModule(module).hostname, ['a.example.com']);
    expect(parseMitmModule(module).rules, isEmpty);
    final changed = parseMitmModule(
      module,
      values: const {'Host': 'c.example.com', 'Off': ''},
    );
    expect(changed.hostname, ['c.example.com']);
    expect(changed.rules, ['DOMAIN,b.example.com,REJECT']);
  });

  group('a Loon plugin', () {
    final content = parseMitmModule(
      _loon,
      values: const {'Region': 'JP'},
      resources: const {'https://cdn.example.com/j.json': 'def.json'},
    );

    test('reads its arguments', () {
      expect(content.name, 'Loon ads');
      final [block, region] = content.arguments;
      expect(block.title, 'Block ads');
      expect(block.type, MitmModuleArgumentType.toggle);
      expect(block.defaultValue, 'true');
      expect(block.description, 'Blocks the ad requests');
      expect(region.type, MitmModuleArgumentType.select);
      expect(region.options, ['US', 'JP']);
    });

    test('spreads its rewrites over the lists', () {
      expect(content.urlRewrite, [
        r'^https://example\.com/a reject-dict',
        r'^https://example\.com/b reject',
        r'^https://example\.com/c https://example.com/d 302',
      ]);
      expect(content.headerRewrite, [
        r'http-request ^https://example\.com/e header-add X-Region JP',
        r'http-response ^https://example\.com/f header-del Set-Cookie',
        'http-response x header-del X',
      ]);
      expect(content.bodyRewrite, [
        r'http-response ^https://example\.com/g ad noad',
        r'http-response-jq ^https://example\.com/h del(.data.ad)',
      ]);
      expect(content.mapLocal, [
        r'^https://example\.com/i data-type="text" data="{}" status-code="200" header="Content-Type:application/json"',
        r'^https://example\.com/j data-type="file" data="def.json" header="Content-Type:application/json"',
      ]);
      expect(content.hostname, ['*.example.com']);
    });

    test('lists what it cannot use', () {
      expect(content.rules, [
        'DOMAIN-SUFFIX,ads.example.com,REJECT',
        'DOMAIN,example.com,DIRECT',
      ]);
      expect(content.skipped, isEmpty);
    });
  });

  group('scripts', () {
    const module = r'''
[Argument]
Block = switch,true,false
Region = select,"US","JP"
Limit = input,"5",type=number

[Script]
Ads = type=http-response,pattern=^https?://(www\.)?a\.com/v\d{1,3},requires-body=1,max-size=-1,script-path=https://cdn.test/ads.js,engine=webview,argument="a=1,b=2"
http-response ^https:\/\/b\.com\/x script-path=https://cdn.test/b.js, requires-body=true, timeout=10, tag=Loon B, argument=[{Block},{Region},{Limit}], enable={Block}
http-request ^https:\/\/c\.com script-path=https://cdn.test/c.js, enable=false
http-request = type=http-request,pattern=^https://d\.com,script-path=https://cdn.test/d.js
cron "0 8 * * *" script-path=https://cdn.test/cron.js
Event = type=event,event-name=network-changed,script-path=https://cdn.test/e.js
Here = type=http-request,pattern=^https://e\.com,script-path=e.js
Later = type=http-request,pattern=^https://f\.com,script-path=https://cdn.test/f.js
network-changed script-path=https://cdn.test/net.js, tag=Loon Net
Wake = type=event,event-name=notification,script-path=https://cdn.test/n.js
generic script-path=https://cdn.test/tool.js, tag=Tool, timeout=60
DNS = type=dns,script-path=https://cdn.test/dns.js
''';
    const resources = {
      'https://cdn.test/ads.js': 'ads0.js',
      'https://cdn.test/b.js': 'b0.js',
      'https://cdn.test/c.js': 'c0.js',
      'https://cdn.test/d.js': 'd0.js',
      'https://cdn.test/cron.js': 'cron0.js',
      'https://cdn.test/e.js': 'e0.js',
      'https://cdn.test/net.js': 'net0.js',
      'https://cdn.test/tool.js': 'tool0.js',
    };

    test('are written in the form the Core reads, naming downloads', () {
      final content = parseMitmModule(
        module,
        values: const {'Region': 'JP'},
        resources: resources,
      );

      expect(content.script, [
        r'Ads = type=http-response,pattern="^https?://(www\.)?a\.com/v\d{1,3}",script-path=ads0.js,requires-body=1,max-size=-1,argument="a=1,b=2"',
        r'Loon B = type=http-response,pattern=^https:\/\/b\.com\/x,script-path=b0.js,requires-body=true,timeout=10,argument-json="{\"Block\":true,\"Region\":\"JP\",\"Limit\":5}"',
        r'http-request = type=http-request,pattern=^https://d\.com,script-path=d0.js',
        'cron.js = type=cron,cronexp="0 8 * * *",script-path=cron0.js',
        'Event = type=event,event-name=network-changed,script-path=e0.js',
        'Loon Net = type=event,event-name=network-changed,script-path=net0.js',
        'Tool = type=generic,script-path=tool0.js,timeout=60',
      ]);
      expect(content.resourceUrls, {
        'https://cdn.test/ads.js',
        'https://cdn.test/b.js',
        'https://cdn.test/d.js',
        'https://cdn.test/cron.js',
        'https://cdn.test/e.js',
        'https://cdn.test/f.js',
        'https://cdn.test/net.js',
        'https://cdn.test/tool.js',
      });
      expect(content.declaredScripts, 11);
      expect(
        [
          for (final skip in content.skipped)
            if (skip.section == 'Script') skip.reason,
        ],
        [
          MitmModuleSkipReason.disabled,
          MitmModuleSkipReason.relativeData,
          MitmModuleSkipReason.notDownloaded,
          MitmModuleSkipReason.event,
          MitmModuleSkipReason.scriptType,
        ],
      );
    });

    test('an argument can turn one off', () {
      final content = parseMitmModule(
        module,
        values: const {'Block': 'false'},
        resources: resources,
      );

      expect(content.script.map((line) => line.split(' = ').first), [
        'Ads',
        'http-request',
        'cron.js',
        'Event',
        'Loon Net',
        'Tool',
      ]);
      expect(content.declaredScripts, 11);
    });

    test('a module asks only for the scripts FlClash runs', () {
      expect(
        parseMitmModule('''
[Script]
DNS = type=dns,script-path=https://cdn.test/dns.js
[MITM]
hostname = a.com
''').declaredScripts,
        0,
      );
      expect(
        parseMitmModule('''
[Script]
cron "0 8 * * *" script-path=https://cdn.test/cron.js
''').declaredScripts,
        1,
      );
      expect(
        parseMitmModule('''
#!arguments=kind:dns
[Script]
Any = type={{{kind}}},pattern=^https://a,script-path=https://cdn.test/any.js
''').declaredScripts,
        1,
      );
    });

    test('a placeholder cannot hide a script from the count', () {
      const url = 'script-path=https://cdn.test/a.js';
      for (final line in const ['{{{Line}}}', 'A = type=dns,x={{{Line}}}']) {
        final module =
            '''
#!arguments=Line:http-request ^https://a $url
[Script]
$line
''';
        expect(parseMitmModule(module).declaredScripts, 1, reason: line);
      }
    });

    test('the lines the user can run are named as the Core names them', () {
      expect(
        mitmTaskName(
          'cron.js = type=cron,cronexp="0 8 * * *",script-path=cron0.js',
        ),
        'cron.js',
      );
      expect(
        mitmTaskName('cron "0 8 * * *" script-path=https://cdn.test/daily.js'),
        'daily.js',
      );
      expect(mitmTaskName('generic script-path=t.js, tag=Tool'), 'Tool');
      expect(mitmTaskName('network-changed script-path=n.js'), 'n.js');
      expect(
        mitmTaskName('Ads = type=http-response,pattern=a,script-path=a.js'),
        isNull,
      );
    });
  });

  group('a Quantumult X snippet', () {
    const snippet = r'''
#!name=QX Ads
hostname = a.com, -b.com
host-suffix, ads.a.com, reject
HOST, track.a.com, direct
ip-cidr, 10.0.0.0/8, reject, no-resolve
host-keyword, ad, proxy
user-agent, App*, reject
^https?://a\.com/ad url reject-dict
^https?://a\.com/old url 302 https://a.com/new
^https?://a\.com/api url request-body "ad":true request-body "ad":false
^https?://a\.com/feed url response-body "ad":\[.+\] response-body "ad":[]
^https?://a\.com/page url echo-response text/html\r\nX-Mock: 1 echo-response https://cdn.test/page.html
^https?://a\.com/list url script-response-body https://cdn.test/list.js
^https?://a\.com/sign url script-request-header https://cdn.test/sign.js
^https?://a\.com/hdr url request-header (\r\n)X-Ad:.+(\r\n) request-header $1
^https?://a\.com/cache url response-header (\r\n)Cache-Control:.+(\r\n) response-header $1Cache-Control: no-cache$2
^https?://a\.com/jq url jsonjq-response-body '.ads=[]'
^https?://a\.com/ua UA url-and-header reject
0 8 * * * https://cdn.test/checkin.js, tag=Check in, img-url=a.png, enabled=true
30 0 9 * * 1-5 https://cdn.test/weekday.js
event-network https://cdn.test/net.js, tag=Network
event-interaction https://cdn.test/node.js, tag=Node
0 9 * * * https://cdn.test/off.js, tag=Off, enabled=false
some text that is not a line of a snippet
''';
    const resources = {
      'https://cdn.test/page.html': 'page0.html',
      'https://cdn.test/list.js': 'list0.js',
      'https://cdn.test/sign.js': 'sign0.js',
      'https://cdn.test/checkin.js': 'checkin0.js',
      'https://cdn.test/weekday.js': 'weekday0.js',
      'https://cdn.test/net.js': 'net0.js',
      'https://cdn.test/node.js': 'node0.js',
    };
    final content = parseMitmModule(snippet, resources: resources);

    test('is read without sections', () {
      expect(content.name, 'QX Ads');
      expect(content.hostname, ['a.com', '-b.com']);
      expect(content.rules, [
        'DOMAIN-SUFFIX,ads.a.com,REJECT',
        'DOMAIN,track.a.com,DIRECT',
        'IP-CIDR,10.0.0.0/8,REJECT,no-resolve',
        'DOMAIN-KEYWORD,ad,PROXY',
      ]);
      expect(content.urlRewrite, [
        r'^https?:// "\r\nUser-Agent: App[^\r\n]*\r\n" url-and-header reject',
        r'^https?://a\.com/ad reject-dict',
        r'^https?://a\.com/old https://a.com/new 302',
        r'^https?://a\.com/ua UA url-and-header reject',
      ]);
      expect(content.bodyRewrite, [
        r'http-request ^https?://a\.com/api "\"ad\":true" "\"ad\":false"',
        r'http-response ^https?://a\.com/feed "\"ad\":\[.+\]" "\"ad\":[]"',
        r"http-response-jq ^https?://a\.com/jq '.ads=[]'",
      ]);
      expect(content.mapLocal, [
        r'^https?://a\.com/page data-type="file" data="page0.html" header="Content-Type:text/html|X-Mock:1"',
      ]);
      expect(content.headerRewrite, [
        r'http-request ^https?://a\.com/hdr header-text-replace (\r\n)X-Ad:.+(\r\n) $1',
        r'http-response ^https?://a\.com/cache header-text-replace (\r\n)Cache-Control:.+(\r\n) "$1Cache-Control: no-cache$2"',
      ]);
    });

    test('turns script rewrites and tasks into script lines', () {
      expect(content.script, [
        r'list.js = type=http-response,pattern=^https?://a\.com/list,requires-body=true,script-path=list0.js',
        r'sign.js = type=http-request,pattern=^https?://a\.com/sign,script-path=sign0.js',
        'Check in = type=cron,cronexp="0 8 * * *",script-path=checkin0.js,timeout=120',
        'weekday.js = type=cron,cronexp="30 0 9 * * 1-5",script-path=weekday0.js,timeout=120',
        'Network = type=event,event-name=network-changed,script-path=net0.js,timeout=120',
        'Node = type=generic,script-path=node0.js,timeout=120',
      ]);
      expect(content.declaredScripts, 7);
      expect(content.resourceUrls, resources.keys.toSet());
    });

    test('lists what it cannot use', () {
      expect(
        [for (final skip in content.skipped) (skip.section, skip.reason)],
        [('task_local', MitmModuleSkipReason.disabled)],
      );
      expect(content.exits, {'PROXY'});
    });

    test('reads its sections when it has them', () {
      final content = parseMitmModule(r'''
[filter_local]
host-suffix, x.com, reject
[rewrite_local]
^https://x\.com/a url reject
hostname = x.com
[mitm]
hostname = y.com
[general]
network_check_url = http://bing.com
''');

      expect(content.rules, ['DOMAIN-SUFFIX,x.com,REJECT']);
      expect(content.urlRewrite, [r'^https://x\.com/a reject']);
      expect(content.hostname, ['x.com', 'y.com']);
      expect(content.skipped.single.reason, MitmModuleSkipReason.setting);
    });
  });

  group('a Stash override', () {
    const override = r'''
#!name=Ignored
name: Stash Ads
desc: Blocks ads
arguments-version: 1
arguments:
  policy:
    type: select
    title: Policy
    default: REJECT
    options:
      - value: REJECT
        label: Reject
      - value: DIRECT
  verbose:
    type: switch
    title: Verbose
  region:
    type: input
    title: Region
    default: HK
http:
  force-http-engine:
    - a.com:80
  mitm:
    - a.com
    - "*.b.com:*"
    - c.com:8443
  url-rewrite:
    - ^https?://a\.com/ad - reject-img
    - ^https?://a\.com/old https://a.com/new 307
    - ^https?://a\.com/in https://a.com/out transparent
  header-rewrite:
    - ^https?://a\.com request-del X-Ad
    - ^https?://a\.com response-add X-Seen 1
  body-rewrite:
    - ^https?://a\.com/api response-replace-regex "ad":true "ad":false
    - ^https?://a\.com/api response-jq del(.ads)
    - ^https?://a\.com/api response-json-del ads
  mock:
    - match: ^https?://a\.com/empty
      text: '{}'
      status-code: 200
      headers:
        Content-Type: application/json
    - match: ^https?://a\.com/blob
      base64: AAEC
    - match: ^https?://a\.com/lines
      text: |
        one
        two
  script:
    - match: ^https?://a\.com/list
      name: list
      type: response
      require-body: true
      timeout: 10
      argument: '{"region":${args.region|json},"verbose":${args.verbose|json}}'
    - match: ^https?://a\.com/req
      name: missing
      type: request
    - match: ^https?://a\.com/x
      name: list
      type: dns
cron:
  script:
    - name: checkin
      cron: '0 8 * * *'
      timeout: 60
script-providers:
  list:
    url: https://cdn.test/list.js
    interval: 86400
  checkin:
    url: https://cdn.test/checkin.js
  missing:
    path: ./local.js
tiles:
  - name: panel
rules:
  - DOMAIN,ads.a.com,${args.policy}
  - DOMAIN-SUFFIX,track.a.com,REJECT
  - RULE-SET,ads,REJECT
  - DOMAIN,keep.a.com,$${args.policy}
dns:
  nameserver: [1.1.1.1]
''';
    const resources = {
      'https://cdn.test/list.js': 'list0.js',
      'https://cdn.test/checkin.js': 'checkin0.js',
    };
    final content = parseMitmModule(
      override,
      values: const {'region': 'JP'},
      resources: resources,
    );

    test('reads its metadata and arguments', () {
      expect(content.name, 'Stash Ads');
      expect(content.description, 'Blocks ads');
      expect(
        [
          for (final argument in content.arguments)
            (
              argument.name,
              argument.type,
              argument.defaultValue,
              argument.options.join('|'),
              argument.title,
            ),
        ],
        [
          (
            'policy',
            MitmModuleArgumentType.select,
            'REJECT',
            'REJECT|DIRECT',
            'Policy',
          ),
          ('verbose', MitmModuleArgumentType.toggle, 'false', '', 'Verbose'),
          ('region', MitmModuleArgumentType.input, 'HK', '', 'Region'),
        ],
      );
    });

    test('spreads its http section over the lists', () {
      expect(content.hostname, ['a.com:80', 'a.com', '*.b.com', 'c.com:8443']);
      expect(content.urlRewrite, [
        r'^https?://a\.com/ad reject-img',
        r'^https?://a\.com/old https://a.com/new 307',
        r'^https?://a\.com/in https://a.com/out header',
      ]);
      expect(content.headerRewrite, [
        r'http-request ^https?://a\.com header-del X-Ad',
        r'http-response ^https?://a\.com header-add X-Seen 1',
      ]);
      expect(content.bodyRewrite, [
        r'http-response ^https?://a\.com/api "ad":true "ad":false',
        r'http-response-jq ^https?://a\.com/api del(.ads)',
        r'http-response-jq ^https?://a\.com/api if (.ads | . != null and . != false) then del(.ads) else . end',
      ]);
      expect(content.mapLocal, [
        r'^https?://a\.com/empty data-type="text" data="{}" status-code="200" header="Content-Type:application/json"',
        r'^https?://a\.com/blob data-type="base64" data="AAEC"',
        r'^https?://a\.com/lines data-type="base64" data="b25lCnR3bwo="',
      ]);
    });

    test('fills its scripts from the script providers', () {
      expect(content.script, [
        r'list = type=http-response,pattern=^https?://a\.com/list,script-path=list0.js,requires-body=true,timeout=10,argument="{\"region\":\"JP\",\"verbose\":false}"',
        'checkin = type=cron,cronexp="0 8 * * *",script-path=checkin0.js,timeout=60',
      ]);
      expect(content.declaredScripts, 3);
      expect(content.resourceUrls, resources.keys.toSet());
    });

    test('puts its arguments in its rules', () {
      expect(content.rules, [
        'DOMAIN,ads.a.com,REJECT',
        'DOMAIN-SUFFIX,track.a.com,REJECT',
      ]);
      expect(
        parseMitmModule(
          override,
          values: const {'policy': 'DIRECT'},
        ).rules.first,
        'DOMAIN,ads.a.com,DIRECT',
      );
    });

    test('lists what it cannot use', () {
      expect(
        [for (final skip in content.skipped) (skip.section, skip.reason)],
        [
          ('script', MitmModuleSkipReason.relativeData),
          ('script', MitmModuleSkipReason.scriptType),
          ('tiles', MitmModuleSkipReason.appOnly),
          ('rules', MitmModuleSkipReason.rule),
          ('rules', MitmModuleSkipReason.rule),
        ],
      );
      expect(content.skipped[4].line, r'DOMAIN,keep.a.com,$${args.policy}');
    });

    test('is not taken for a Surge module or a snippet', () {
      expect(parseMitmModule('[MITM]\nhostname = a.com').hostname, ['a.com']);
      expect(parseMitmModule('rules:\n  - DOMAIN,a.com,REJECT').rules, [
        'DOMAIN,a.com,REJECT',
      ]);
      expect(parseMitmModule('name: Not a module').isEmpty, isTrue);
    });
  });

  test('text without a section is not a module', () {
    expect(parseMitmModule('#!name=Nothing\nhello').isEmpty, isTrue);
  });

  test('the user hostnames go first and module lines keep the list order', () {
    final first = parseMitmModule('''
[MITM]
hostname = %APPEND% a.com
hostname = %INSERT% -b.a.com
[URL Rewrite]
^https://first _ reject
[Rule]
DOMAIN,first.com,REJECT
''');
    final second = parseMitmModule('''
[MITM]
hostname = c.com
[URL Rewrite]
^https://second _ reject
[Rule]
DOMAIN,second.com,DIRECT
''');

    final merged = mergeMitmModules(['-own.a.com'], [first, second]);

    expect(merged.mitm.hostname, ['-own.a.com', '-b.a.com', 'a.com', 'c.com']);
    expect(merged.mitm.urlRewrite, [
      '^https://first _ reject',
      '^https://second _ reject',
    ]);
    expect(merged.rules, [
      'DOMAIN,first.com,REJECT',
      'DOMAIN,second.com,DIRECT',
    ]);
  });

  test('a resource is named by its content and keeps the extension', () {
    final name = mitmResourceName('https://a.com/x/blank.JSON?v=1', [1, 2, 3]);

    expect(name, endsWith('.json'));
    expect(name, hasLength(32 + '.json'.length));
    expect(mitmResourceName('https://a.com/x/blank.JSON', [1, 2, 3]), name);
    expect(mitmResourceName('https://a.com/x', [1, 2, 4]), hasLength(32));
  });

  test('a local module names its attachments by file name', () {
    final content = parseMitmModule(
      '''
[Map Local]
^https://a data="one.json"
^https://b data="two.gif"
[Script]
Ads = type=http-response,pattern=^https://a,script-path=ads.js
''',
      resources: const {'one.json': 'h1.json', 'ads.js': 'h2.js'},
    );

    expect(content.mapLocal, [contains('h1.json')]);
    expect(content.script.single, contains('script-path=h2.js'));
    expect(content.resourceUrls, isEmpty);
    expect(content.skipped.single.line, contains('two.gif'));
    expect(content.skipped.single.reason, MitmModuleSkipReason.relativeData);
  });

  test('only a local module has attachments', () {
    final module = MitmModule(
      id: 1,
      name: 'M',
      resources: const {'https://cdn.test/a.js': 'h1.js', 'b.js': 'h2.js'},
      lastUpdateTime: DateTime(2026),
    );

    expect(mitmAttachments(module), {'b.js': 'h2.js'});
    expect(
      mitmAttachments(module.copyWith(url: 'https://cdn.test/m')),
      isEmpty,
    );
  });

  group('a rule written for a captured request', () {
    const url = 'https://a.test/v1/ad.json?id=3';

    test('matches the URL with any query and nothing longer', () {
      final pattern = RegExp(mitmUrlPattern(url));
      expect(pattern.pattern, r'^https://a\.test/v1/ad\.json(\?|$)');
      expect(pattern.hasMatch('https://a.test/v1/ad.json'), isTrue);
      expect(pattern.hasMatch('https://a.test/v1/ad.json?id=4'), isTrue);
      expect(pattern.hasMatch('https://a.test/v1/ad.jsonp'), isFalse);
    });

    test('lands in its section and reads back as the Core takes it', () {
      const module =
          '#!name=Mine\n\n[URL Rewrite]\n^http://x old 302\n\n'
          '[MITM]\nhostname = %APPEND%\n';
      final rejected = mitmAddLine(
        module,
        mitmUrlRewriteSection,
        mitmRejectLine(url),
      )!;
      expect(
        rejected,
        contains('^http://x old 302\n${mitmRejectLine(url)}\n\n[MITM]'),
      );
      final mapped = mitmAddLine(
        rejected,
        mitmMapLocalSection,
        mitmMapLocalLine(
          url,
          file: 'ad.json',
          status: 201,
          contentType: 'application/json; charset=utf-8',
        ),
      )!;
      expect(
        mapped,
        endsWith(
          '\n\n[Map Local]\n${mitmMapLocalLine(url, file: 'ad.json', status: 201, contentType: 'application/json; charset=utf-8')}\n',
        ),
      );

      final content = parseMitmModule(
        mapped,
        resources: const {'ad.json': 'stored.json'},
      );
      expect(
        content.urlRewrite.last,
        r'^https://a\.test/v1/ad\.json(\?|$) reject',
      );
      expect(
        content.mapLocal.single,
        (r'^https://a\.test/v1/ad\.json(\?|$) data-type="file" '
            'data="stored.json" status-code="201" '
            'header="Content-Type:application/json; charset=utf-8"'),
      );
    });

    test('answers with no body when none was kept', () {
      final content = parseMitmModule(
        mitmAddLine('', mitmMapLocalSection, mitmMapLocalLine(url))!,
      );
      expect(content.mapLocal, [
        r'^https://a\.test/v1/ad\.json(\?|$) data-type="text" data=""',
      ]);
    });

    test('names its body after the URL, apart from the attachments', () {
      expect(mitmAttachmentName(url, const []), 'ad.json');
      expect(
        mitmAttachmentName(url, const ['ad.json', 'ad-2.json']),
        'ad-3.json',
      );
      expect(mitmAttachmentName('https://a.test/', const []), 'response');
      expect(mitmAttachmentName('https://a.test/a%20b?c', const []), 'a_b');
    });

    test('is not added to a Stash override', () {
      expect(
        mitmAddLine(
          'name: Ads\nhttp:\n  mitm:\n    - a.test\n',
          mitmUrlRewriteSection,
          mitmRejectLine(url),
        ),
        isNull,
      );
    });
  });

  test('a Loon cron expression an argument fills in keeps every field', () {
    final content = parseMitmModule(
      '''
[Argument]
cron=input, "55 23 * * *", tag=Schedule

[Script]
cron {cron} script-path=https://cdn.test/sync.js, timeout=900, tag=Sync
''',
      resources: const {'https://cdn.test/sync.js': 'sync0.js'},
    );
    expect(content.skipped, isEmpty);
    expect(content.script, [
      'Sync = type=cron,cronexp="55 23 * * *",script-path=sync0.js,timeout=900',
    ]);
  });

  group('install links', () {
    const url = 'https://example.com/a.module?x=1&y=2';
    final encoded = Uri.encodeComponent(url);

    test('name the module they install', () {
      for (final link in [
        url,
        'surge:///install-module?url=$encoded',
        'loon://import?plugin=$encoded',
        'shadowrocket://install?module=$encoded',
        'stash://install-override?url=$encoded',
        'clash://install-override?url=$encoded',
        '  surge:///install-module?url=$encoded\n',
      ]) {
        expect(mitmModuleUrls(link), [url], reason: link);
      }
    });

    test('of Stash may be a web link without a scheme', () {
      expect(
        mitmModuleUrls('https://link.stash.ws/install-override/a.test/b.yaml'),
        ['https://a.test/b.yaml'],
      );
      expect(
        mitmModuleUrls(
          'https://link.stash.ws/install-override/a.test/b.yaml?scheme=http',
        ),
        ['http://a.test/b.yaml'],
      );
    });

    test('of Quantumult X give every rewrite and nothing else', () {
      final resource = Uri.encodeComponent(
        jsonEncode({
          'server_remote': ['https://example.com/server, tag=S'],
          'rewrite_remote': [
            'https://example.com/a.snippet, tag=A, enabled=true',
            'https://example.com/b.snippet',
          ],
        }),
      );
      for (final action in ['add-resource', 'update-configuration']) {
        expect(
          mitmModuleUrls('quantumult-x:///$action?remote-resource=$resource'),
          ['https://example.com/a.snippet', 'https://example.com/b.snippet'],
        );
      }
    });

    test('name nothing when they install no module', () {
      for (final link in [
        '',
        'not a link',
        'surge:///start',
        'surge:///install-module',
        'surge:///install-module?url=file%3A%2F%2F%2Fa',
        'loon://update?sub=all',
        'clash://install-config?url=$encoded',
        'quantumult-x:///add-resource?remote-resource=%7B',
        'quantumult-x:///ui?module=gallery&action=add',
        'https://link.stash.ws/install-config/a.test/b.yaml',
      ]) {
        expect(mitmModuleUrls(link), isEmpty, reason: link);
      }
    });
  });
}
