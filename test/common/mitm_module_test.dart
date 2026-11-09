import 'dart:convert';

import 'package:fl_clash/common/mitm_module.dart';
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
      ]);
      expect(
        [
          for (final skip in content.skipped)
            if (skip.section == 'Rule') skip.reason,
        ],
        [
          MitmModuleSkipReason.rule,
          MitmModuleSkipReason.policy,
          MitmModuleSkipReason.rule,
        ],
      );
    });

    test('turns a rejecting URL rule into a URL rewrite', () {
      expect(content.urlRewrite, [
        r'^https?://example\.com/ad,1 reject-dict',
        r'^https?://example\.com/old https://example.com/new 302',
      ]);
    });

    test('passes Surge rewrites on and skips jq ones', () {
      expect(content.headerRewrite, [
        r'http-request ^https://example\.com header-del Cookie',
      ]);
      expect(content.bodyRewrite, [
        r'http-response ^https://example\.com/api "ad":true "ad":false',
      ]);
      expect(
        content.skipped.where((skip) => skip.reason == MitmModuleSkipReason.jq),
        hasLength(1),
      );
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

    test('reads hostname lines and leaves other settings out', () {
      expect(content.hostname, ['*.example.com', 'api.example.com']);
      expect(content.insertedHostname, ['-safe.example.com']);
      expect(content.mitm.hostname, [
        '-safe.example.com',
        '*.example.com',
        'api.example.com',
      ]);
      expect(
        [
          for (final skip in content.skipped)
            if (skip.section == 'MITM' || skip.section == 'General')
              skip.reason,
        ],
        [MitmModuleSkipReason.section, MitmModuleSkipReason.setting],
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
      ]);
      expect(content.bodyRewrite, [
        r'http-response ^https://example\.com/g ad noad',
      ]);
      expect(content.mapLocal, [
        r'^https://example\.com/i data-type="text" data="{}" status-code="200" header="Content-Type:application/json"',
        r'^https://example\.com/j data-type="file" data="def.json" header="Content-Type:application/json"',
      ]);
      expect(content.hostname, ['*.example.com']);
    });

    test('lists what it cannot use', () {
      expect(content.rules, ['DOMAIN-SUFFIX,ads.example.com,REJECT']);
      expect(content.skipped.map((skip) => skip.reason), [
        MitmModuleSkipReason.policy,
        MitmModuleSkipReason.jsonBody,
        MitmModuleSkipReason.conditional,
      ]);
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

    test('the scope of consent follows script lines and their content', () {
      const module = '''
[MITM]
hostname = a.com
[Script]
A = type=http-request,pattern=^https://a,script-path=https://cdn.test/a.js
''';
      final scope = mitmScriptScope(
        module,
        resources: const {'https://cdn.test/a.js': 'one.js'},
      );

      expect(
        mitmScriptScope(
          module.replaceFirst('a.com', 'a.com, b.com'),
          resources: const {'https://cdn.test/a.js': 'one.js'},
        ),
        scope,
      );
      expect(
        mitmScriptScope(
          module,
          resources: const {'https://cdn.test/a.js': 'two.js'},
        ).difference(scope),
        isNotEmpty,
      );
      expect(
        mitmScriptScope(
          module.replaceFirst('^https://a', '.*'),
          resources: const {'https://cdn.test/a.js': 'one.js'},
        ).difference(scope),
        isNotEmpty,
      );
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
    };
    final content = parseMitmModule(snippet, resources: resources);

    test('is read without sections', () {
      expect(content.name, 'QX Ads');
      expect(content.hostname, ['a.com', '-b.com']);
      expect(content.rules, [
        'DOMAIN-SUFFIX,ads.a.com,REJECT',
        'DOMAIN,track.a.com,DIRECT',
        'IP-CIDR,10.0.0.0/8,REJECT,no-resolve',
      ]);
      expect(content.urlRewrite, [
        r'^https?://a\.com/ad reject-dict',
        r'^https?://a\.com/old https://a.com/new 302',
      ]);
      expect(content.bodyRewrite, [
        r'http-request ^https?://a\.com/api "\"ad\":true" "\"ad\":false"',
        r'http-response ^https?://a\.com/feed "\"ad\":\[.+\]" "\"ad\":[]"',
      ]);
      expect(content.mapLocal, [
        r'^https?://a\.com/page data-type="file" data="page0.html" header="Content-Type:text/html|X-Mock:1"',
      ]);
    });

    test('turns script rewrites and tasks into script lines', () {
      expect(content.script, [
        r'list.js = type=http-response,pattern=^https?://a\.com/list,requires-body=true,script-path=list0.js',
        r'sign.js = type=http-request,pattern=^https?://a\.com/sign,script-path=sign0.js',
        'Check in = type=cron,cronexp="0 8 * * *",script-path=checkin0.js,timeout=120',
        'weekday.js = type=cron,cronexp="30 0 9 * * 1-5",script-path=weekday0.js,timeout=120',
        'Network = type=event,event-name=network-changed,script-path=net0.js,timeout=120',
      ]);
      expect(content.declaredScripts, 6);
      expect(content.resourceUrls, resources.keys.toSet());
    });

    test('lists what it cannot use', () {
      expect(
        [for (final skip in content.skipped) (skip.section, skip.reason)],
        [
          ('filter_local', MitmModuleSkipReason.policy),
          ('filter_local', MitmModuleSkipReason.rule),
          ('rewrite_local', MitmModuleSkipReason.rawHeader),
          ('rewrite_local', MitmModuleSkipReason.jq),
          ('rewrite_local', MitmModuleSkipReason.conditional),
          ('task_local', MitmModuleSkipReason.scriptType),
          ('task_local', MitmModuleSkipReason.disabled),
        ],
      );
      expect(content.skipped.first.line, 'host-keyword, ad, proxy');
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
      expect(content.skipped.single.reason, MitmModuleSkipReason.section);
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
      expect(content.hostname, ['a.com', '*.b.com', 'c.com:8443']);
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
          ('http', MitmModuleSkipReason.setting),
          ('body-rewrite', MitmModuleSkipReason.jq),
          ('body-rewrite', MitmModuleSkipReason.jsonBody),
          ('script', MitmModuleSkipReason.relativeData),
          ('script', MitmModuleSkipReason.scriptType),
          ('tiles', MitmModuleSkipReason.section),
          ('rules', MitmModuleSkipReason.rule),
          ('rules', MitmModuleSkipReason.policy),
          ('dns', MitmModuleSkipReason.section),
        ],
      );
      expect(content.skipped[7].line, r'DOMAIN,keep.a.com,$${args.policy}');
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
