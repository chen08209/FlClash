import 'dart:convert';

import 'package:fl_clash/common/mitm_module_file.dart';
import 'package:fl_clash/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('a resource is named by its content and keeps the extension', () {
    final name = mitmResourceName('https://a.test/x/blank.JSON?v=1', [1, 2, 3]);

    expect(name, endsWith('.json'));
    expect(name, hasLength(32 + '.json'.length));
    expect(mitmResourceName('https://a.test/x/blank.JSON', [1, 2, 3]), name);
    expect(mitmResourceName('https://a.test/x', [1, 2, 4]), hasLength(32));
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
    });

    test('answers with no body when none was kept', () {
      expect(
        mitmMapLocalLine(url),
        r'^https://a\.test/v1/ad\.json(\?|$) data-type=text data=""',
      );
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
          'name: Sample\nhttp:\n  mitm:\n    - a.test\n',
          mitmUrlRewriteSection,
          mitmRejectLine(url),
        ),
        isNull,
      );
    });
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
