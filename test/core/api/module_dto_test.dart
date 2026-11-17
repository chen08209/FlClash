import 'package:fl_clash/core/api/dto.dart';
import 'package:fl_clash/core/api/model_api.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

const _read = <String, Object?>{
  'format': 'loon',
  'meta': {'name': 'Sample', 'argumentsDesc': 'pick a host'},
  'off': {'reason': 'requirement'},
  'arguments': [
    {
      'name': 'host',
      'kind': {'type': 'text'},
      'number': false,
      'default': 'a.test',
      'line': 3,
    },
    {
      'name': 'on',
      'kind': {'type': 'switch'},
      'number': false,
      'default': 'true',
      'label': 'Turn on',
      'line': 4,
    },
    {
      'name': 'region',
      'kind': {
        'type': 'select',
        'options': ['CN', 'US'],
      },
      'number': false,
      'default': 'CN',
      'line': 5,
    },
  ],
  'resources': [
    {
      'url': 'https://cdn.test/s.js',
      'kind': 'script',
      'lines': [14],
    },
  ],
  'declaredScripts': [14],
  'asksConsent': true,
  'issues': {
    'url-rewrite': [
      {'index': 12, 'kind': 'regex', 'message': 'bad pattern'},
    ],
  },
  'views': {
    'url-rewrite': [
      {
        'index': 11,
        'view': {
          'type': 'urlRewrite',
          'pattern': '^https://a',
          'action': 'reject',
        },
      },
    ],
  },
  'rules': [
    {
      'line': 8,
      'rule': 'DOMAIN,a.test',
      'policy': {'builtin': 'REJECT'},
      'noResolve': false,
      'extendedMatching': false,
    },
    {
      'line': 9,
      'rule': 'IP-CIDR,10.0.0.0/8',
      'policy': {'named': 'PROXY'},
      'noResolve': true,
      'extendedMatching': false,
    },
  ],
  'ruleSets': [
    {
      'name': 'mitm-0123456789ab',
      'domain': false,
      'source': {
        'type': 'inline',
        'rules': [
          {'line': 20, 'rule': 'DOMAIN,b.test'},
        ],
      },
    },
  ],
  'network': {
    'nameserver': {
      'replace': false,
      'before': ['8.8.8.8'],
      'after': [],
    },
  },
  'ignored': [
    {'line': 16, 'text': 'p = title=x', 'reason': 'appOnly'},
  ],
};

void main() {
  test('a module view reads its lines by module line', () {
    final read = MitmModuleRead.fromJson(_read);
    expect(read.format, 'loon');
    expect(read.meta.argumentsDesc, 'pick a host');
    expect(read.off, 'requirement');
    expect(
      [for (final argument in read.arguments) argument.type],
      [
        MitmArgumentType.text,
        MitmArgumentType.switcher,
        MitmArgumentType.select,
      ],
    );
    expect(read.arguments[2].options, ['CN', 'US']);
    expect(read.resources.single.lines, [14]);
    expect(read.namedPolicies, {'PROXY'});
    expect(read.rules[1].noResolve, isTrue);
    expect(read.ruleSets.single.rules, ['DOMAIN,b.test']);
    expect(read.ignored.single.reason, 'appOnly');
    final check = ModelApi.mitmCheckOf({
      'issues': read.issues,
      'views': read.views,
    });
    expect(check.issues[MitmList.urlRewrite], {12: 'bad pattern'});
    expect(check.views[MitmList.urlRewrite]?[11], isA<MitmUrlRewriteView>());
  });

  test('a module status names each file and why its fetch failed', () {
    final status = MitmModuleStatus.fromJson({
      'name': '7',
      'inForce': true,
      'resources': [
        {
          'url': 'https://cdn.test/s.js',
          'kind': 'script',
          'lines': [14],
          'state': 'failed',
          'error': {'reason': 'http', 'status': 404, 'detail': '404 Not Found'},
        },
        {
          'url': 'https://cdn.test/b.js',
          'kind': 'script',
          'lines': [15],
          'file': 'abc.js',
          'state': 'ok',
        },
      ],
      'refusedRules': [
        {'line': 3, 'detail': 'proxy [Nowhere] not found'},
      ],
      'hostNetwork': <String, Object?>{},
    });
    expect(status.resources.first.state, MitmResourceState.failed);
    expect(status.resources.first.error?.status, 404);
    expect(status.resources.last.file, 'abc.js');
    expect(status.refusedRules.single.line, 3);
    expect(
      MitmModuleStatus.fromJson({
        'name': 'gone',
        'problem': {'reason': 'unreadable', 'detail': 'no such file'},
      }).problemDetail,
      'no such file',
    );
  });

  test('a module fetch is a resource update of its own kind', () {
    expect(
      CoreEventDto.fromJson({
        'type': 'resourceUpdate',
        'kind': 'mitmModule',
        'name': '7',
        'phase': 'failed',
        'error': '404 Not Found',
      }),
      isA<ResourceUpdateEvent>().having(
        (event) => event.kind,
        'kind',
        ResourceKind.mitmModule,
      ),
    );
  });
}
