import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:fl_clash/common/app_update.dart';
import 'package:fl_clash/common/constant.dart';
import 'package:fl_clash/common/exception.dart';
import 'package:fl_clash/common/release_asset.dart';
import 'package:fl_clash/common/request.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:flutter_test/flutter_test.dart';

class _StalledHttpClient extends Fake implements HttpClient {
  @override
  Duration? connectionTimeout;

  @override
  String Function(Uri url)? findProxy;

  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) =>
      Completer<HttpClientRequest>().future;
}

class _HostAdapter implements HttpClientAdapter {
  _HostAdapter(this.byHost);

  final Map<String, ResponseBody Function()> byHost;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return byHost[options.uri.host]!();
  }

  @override
  void close({bool force = false}) {}
}

class _PathAdapter implements HttpClientAdapter {
  _PathAdapter(this.byPath);

  final Map<String, ResponseBody Function()> byPath;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final answer = byPath[options.uri.path];
    return answer == null ? ResponseBody.fromString('', 404) : answer();
  }

  @override
  void close({bool force = false}) {}
}

class _UrlAdapter implements HttpClientAdapter {
  _UrlAdapter(this.byUrl);

  final Map<String, ResponseBody Function()> byUrl;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final answer = byUrl['${options.uri.host}${options.uri.path}'];
    return answer == null ? ResponseBody.fromString('', 404) : answer();
  }

  @override
  void close({bool force = false}) {}
}

/// Answers the release list by its page and everything else with a 404.
class _PageAdapter implements HttpClientAdapter {
  _PageAdapter(this.byPage);

  final Map<String, ResponseBody Function()> byPage;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final answer = options.uri.path.endsWith('/releases')
        ? byPage[options.uri.queryParameters['page'] ?? '1']
        : null;
    return answer == null ? ResponseBody.fromString('', 404) : answer();
  }

  @override
  void close({bool force = false}) {}
}

const _feed = '''
<?xml version="1.0" encoding="UTF-8"?>
<feed xmlns="http://www.w3.org/2005/Atom" xml:lang="en-US">
  <id>tag:github.com,2008:https://github.com/owner/repo/releases</id>
  <link type="text/html" rel="alternate" href="https://github.com/owner/repo/releases"/>
  <link type="application/atom+xml" rel="self" href="https://github.com/owner/repo/releases.atom"/>
  <title>Release notes from repo</title>
  <entry>
    <link rel="alternate" type="text/html" href="https://github.com/owner/repo/releases/tag/v0.9.3"/>
    <title>v0.9.3</title>
    <content type="html">&lt;h3&gt;Features&lt;/h3&gt;</content>
  </entry>
  <entry>
    <link rel="alternate" type="text/html" href="https://github.com/owner/repo/releases/tag/v0.9.4-rs.2"/>
  </entry>
  <entry>
    <link rel="alternate" type="text/html" href="https://github.com/owner/repo/releases/tag/v0.9.4-pre.2%2B2"/>
  </entry>
  <entry>
    <link rel="alternate" type="text/html" href="https://github.com/owner/repo/releases/tag/v0.9.4-pre.1"/>
  </entry>
  <entry>
    <link rel="alternate" type="text/html" href="https://github.com/owner/repo/releases/tag/v0.9.4-rs.1"/>
  </entry>
</feed>
''';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('getTextResponseForUrl propagates the typed DioException', () async {
    // flutter_test's mocked HttpClient answers every request with HTTP 400,
    // which Dio surfaces as a badResponse DioException.
    await expectLater(
      request.getTextResponseForUrl('http://127.0.0.1/anything'),
      throwsA(
        isA<DioException>().having(
          (e) => e.type,
          'type',
          DioExceptionType.badResponse,
        ),
      ),
    );
  });

  test('getFileResponseForUrl propagates the typed DioException', () async {
    await expectLater(
      request.getFileResponseForUrl('http://127.0.0.1/anything'),
      throwsA(
        isA<DioException>().having(
          (e) => e.type,
          'type',
          DioExceptionType.badResponse,
        ),
      ),
    );
  });

  group('latestRelease', () {
    Request requestAnswering(Map<String, ResponseBody Function()> byHost) {
      return Request()..dio.httpClientAdapter = _HostAdapter(byHost);
    }

    test('reads the release from the API', () async {
      final request = requestAnswering({
        'api.github.com': () => ResponseBody.fromString(
          '{"tag_name":"v1.2.3","body":"notes"}',
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        ),
      });

      expect(await request.latestRelease(), {
        'tag_name': 'v1.2.3',
        'body': 'notes',
      });
    });

    test(
      'falls back to the release page when the API is rate limited',
      () async {
        final request = requestAnswering({
          'api.github.com': () => ResponseBody.fromString('{}', 403),
          'github.com': () => ResponseBody.fromString(
            '',
            302,
            headers: {
              HttpHeaders.locationHeader: [
                'https://github.com/owner/repo/releases/tag/v1.2.4',
              ],
            },
          ),
        });

        expect(await request.latestRelease(), {'tag_name': 'v1.2.4'});
      },
    );

    test('fails instead of answering when neither endpoint does', () async {
      final request = requestAnswering({
        'api.github.com': () => ResponseBody.fromString('{}', 403),
        'github.com': () => ResponseBody.fromString('', 503),
      });

      await expectLater(request.latestRelease(), throwsA(isA<DioException>()));
    });
  });

  group('newestRelease', () {
    ResponseBody json(Object body, [int status = 200]) {
      return ResponseBody.fromString(
        jsonEncode(body),
        status,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
    }

    Request requestAnswering(Map<String, ResponseBody Function()> byUrl) {
      return Request()..dio.httpClientAdapter = _UrlAdapter(byUrl);
    }

    Map<String, Object> listed(
      String tag, {
      bool draft = false,
      String? body,
      bool uploaded = true,
    }) {
      return {
        'tag_name': tag,
        'draft': draft,
        'body': ?body,
        'assets': [
          if (uploaded) {'name': updateChecksumsName(tag)},
          {'name': 'FlClash-${releaseVersionOfTag(tag)}-android-arm64.apk'},
        ],
      };
    }

    const api = 'api.github.com/repos/$repository/releases';
    const feed = 'github.com/$repository/releases.atom';

    String published(String tag) {
      final uri = releaseAssetUri(tag, updateChecksumsName(tag));
      return '${uri.host}${uri.path}';
    }

    ResponseBody redirect() => ResponseBody.fromString('', 302);

    test(
      'reads the list on either channel and takes the newest rs release',
      () async {
        final request = requestAnswering({
          '$api/latest': () => json(listed('v99.0.0')),
          api: () => json([
            listed('v99.0.0', body: 'Go stable'),
            listed('v1.3.0-pre.9', body: 'Go prerelease'),
            listed('v1.3.0-rs.11', draft: true),
            listed('v1.3.0-rs.2', body: 'rs 2'),
            listed('v1.3.0-rs.10', body: 'rs 10'),
          ]),
        });

        for (final channel in UpdateChannel.values) {
          final release = await request.newestRelease(channel);
          expect(release['tag_name'], 'v1.3.0-rs.10');
          expect(release['body'], 'rs 10');
        }
      },
    );

    test('looks past a full page with no rs release on it', () async {
      final request = Request()
        ..dio.httpClientAdapter = _PageAdapter({
          '1': () => json([for (var i = 0; i < 100; i++) listed('v99.0.$i')]),
          '2': () => json([listed('v1.3.0-rs.2')]),
        });

      expect(
        (await request.newestRelease(UpdateChannel.stable))['tag_name'],
        'v1.3.0-rs.2',
      );
    });

    test('skips a release still uploading its files', () async {
      final request = requestAnswering({
        api: () => json([
          listed('v1.3.0-rs.3', uploaded: false),
          listed('v1.3.0-rs.2'),
        ]),
      });

      expect(
        (await request.newestRelease(UpdateChannel.stable))['tag_name'],
        'v1.3.0-rs.2',
      );
    });

    test('falls back to the feed when the API is rate limited', () async {
      final request = requestAnswering({
        api: () => json({'message': 'rate limited'}, 403),
        feed: () => ResponseBody.fromString(_feed, 200),
        published('v0.9.3'): redirect,
        published('v0.9.4-pre.2+2'): redirect,
        published('v0.9.4-rs.2'): redirect,
        published('v0.9.4-rs.1'): redirect,
      });

      expect(await request.newestRelease(UpdateChannel.stable), {
        'tag_name': 'v0.9.4-rs.2',
      });
    });

    test('skips a feed tag whose release has no files yet', () async {
      final request = requestAnswering({
        api: () => json({'message': 'rate limited'}, 403),
        feed: () => ResponseBody.fromString(_feed, 200),
        published('v0.9.4-rs.1'): redirect,
      });

      expect(await request.newestRelease(UpdateChannel.stable), {
        'tag_name': 'v0.9.4-rs.1',
      });
    });

    const unnamed = ['nightly', 'v1.3.0-rs.beta-1'];

    test('passes over a listed tag no release files are named after', () async {
      final request = requestAnswering({
        api: () => json([
          for (final tag in unnamed)
            {'tag_name': tag, 'draft': false, 'assets': <Object>[]},
          listed('v1.2.0-rs.2'),
        ]),
      });

      expect(
        (await request.newestRelease(UpdateChannel.stable))['tag_name'],
        'v1.2.0-rs.2',
      );
    });

    String entryOf(String tag) =>
        '<entry><link rel="alternate" type="text/html" '
        'href="https://github.com/$repository/releases/tag/'
        '${Uri.encodeComponent(tag)}"/></entry>';

    String feedOf(List<String> tags) => [
      '<feed xmlns="http://www.w3.org/2005/Atom">',
      ...tags.map(entryOf),
      '</feed>',
    ].join('\n');

    test('passes over a feed tag no release files are named after', () async {
      final request = requestAnswering({
        api: () => json({'message': 'rate limited'}, 403),
        feed: () =>
            ResponseBody.fromString(feedOf([...unnamed, 'v1.2.0-rs.2']), 200),
        published('v1.2.0-rs.2'): redirect,
      });

      expect(await request.newestRelease(UpdateChannel.stable), {
        'tag_name': 'v1.2.0-rs.2',
      });
    });

    test('looks past every feed tag whose release has no files yet', () async {
      final request = requestAnswering({
        api: () => json({'message': 'rate limited'}, 403),
        feed: () => ResponseBody.fromString(
          feedOf([for (var n = 5; n > 0; n--) 'v1.2.0-rs.$n']),
          200,
        ),
        published('v1.2.0-rs.1'): redirect,
      });

      expect(await request.newestRelease(UpdateChannel.stable), {
        'tag_name': 'v1.2.0-rs.1',
      });
    });

    test('fails when neither the API nor the feed answers', () async {
      final request = requestAnswering({
        api: () => json({}, 403),
        feed: () => ResponseBody.fromString('', 503),
      });

      await expectLater(
        request.newestRelease(UpdateChannel.stable),
        throwsA(isA<DioException>()),
      );
    });
  });

  test('releaseTagsOfFeed reads every entry and decodes the tag', () {
    expect(releaseTagsOfFeed(_feed).toList(), [
      'v0.9.3',
      'v0.9.4-rs.2',
      'v0.9.4-pre.2+2',
      'v0.9.4-pre.1',
      'v0.9.4-rs.1',
    ]);
  });

  group('downloadVerifiedRelease', () {
    final name = releaseAssetName(
      version: '1.2.3',
      os: ReleaseOs.android,
      arch: ReleaseArch.arm64,
      extension: 'apk',
    );
    final package = utf8.encode('package');
    final digest = sha256.convert(package).toString();
    late Directory directory;

    setUp(() async {
      directory = await Directory.systemTemp.createTemp('release');
    });

    tearDown(() => directory.delete(recursive: true));

    const release = '/$repository/releases/download/v1.2.3';
    final sumsPath = '$release/${updateChecksumsName('v1.2.3')}';

    Request requestAt(Map<String, ResponseBody Function()> byPath) {
      return Request()..releaseDio.httpClientAdapter = _PathAdapter(byPath);
    }

    Request requestServing(String sums, List<int> asset) {
      return requestAt({
        sumsPath: () => ResponseBody.fromString(sums, 200),
        '$release/$name': () => ResponseBody.fromBytes(asset, 200),
      });
    }

    Future<String> download(Request request) {
      return request.downloadVerifiedRelease(
        tag: 'v1.2.3',
        name: name,
        directory: directory.path,
      );
    }

    test('keeps a file matching the published digest', () async {
      final request = requestServing('$digest  $name\n', package);

      final path = await download(request);

      expect(await File(path).readAsBytes(), package);
    });

    test('refuses a file that does not match', () async {
      final request = requestServing('$digest  $name\n', utf8.encode('x'));

      await expectLater(
        download(request),
        throwsA(isA<ReleaseNotVerifiedException>()),
      );
    });

    test('reports an asset the listing does not name as missing', () async {
      final request = requestServing('$digest  other.apk\n', package);

      await expectLater(
        download(request),
        throwsA(isA<ReleaseFileMissingException>()),
      );
      expect(directory.listSync(), isEmpty);
    });

    test('reports a checksum file the release lacks as missing', () async {
      final request = requestAt({});

      await expectLater(
        download(request),
        throwsA(isA<ReleaseFileMissingException>()),
      );
    });

    test('reports an asset the release lacks as missing', () async {
      final request = requestAt({
        sumsPath: () => ResponseBody.fromString('$digest  $name\n', 200),
      });

      await expectLater(
        download(request),
        throwsA(
          isA<ReleaseFileMissingException>().having(
            (error) => error.name,
            'name',
            name,
          ),
        ),
      );
    });

    test('leaves any other failure as it was', () async {
      final request = requestAt({
        sumsPath: () => ResponseBody.fromString('', 503),
      });

      await expectLater(download(request), throwsA(isA<DioException>()));
    });
  });

  group('downloadTarget', () {
    test('sends a URL without credentials unchanged', () {
      final target = downloadTarget('https://example.com/a.yaml?x=1');

      expect(target.uri.toString(), 'https://example.com/a.yaml?x=1');
      expect(target.headers, isEmpty);
    });

    test('moves decoded credentials into the Authorization header', () {
      for (final url in [
        'https://me@mail.com:p:w@dav.example.com/dav/a.yaml',
        'https://me%40mail.com:p%3Aw@dav.example.com/dav/a.yaml',
      ]) {
        final target = downloadTarget(url);

        expect(target.uri.toString(), 'https://dav.example.com/dav/a.yaml');
        expect(
          target.headers[HttpHeaders.authorizationHeader],
          'Basic ${base64.encode(utf8.encode('me@mail.com:p:w'))}',
        );
      }
    });
  });

  group('decompressUnlabeled', () {
    final yaml = utf8.encode('proxies: []\n');

    test('inflates a gzip or zlib body that arrived unlabeled', () {
      for (final codec in [gzip, zlib]) {
        final body = Uint8List.fromList(codec.encode(yaml));

        expect(decompressUnlabeled(body), yaml);
      }
    });

    test('leaves a plain body untouched', () {
      final body = Uint8List.fromList(yaml);

      expect(decompressUnlabeled(body), same(body));
    });

    test('keeps a body that only starts like gzip', () {
      final body = Uint8List.fromList([0x1f, 0x8b, 1, 2, 3]);

      expect(decompressUnlabeled(body), same(body));
    });
  });

  testWidgets('a stalled download fails at the shared download deadline', (
    tester,
  ) async {
    late final Future<Response<String>> pending;
    HttpOverrides.runZoned(() {
      pending = Request().getTextResponseForUrl('http://127.0.0.1/stalled');
    }, createHttpClient: (_) => _StalledHttpClient());
    var settled = false;
    final outcome = expectLater(
      pending.whenComplete(() => settled = true),
      throwsA(
        isA<DioException>().having(
          (e) => e.type,
          'type',
          DioExceptionType.receiveTimeout,
        ),
      ),
    );

    await tester.pump(downloadTimeoutDuration - const Duration(seconds: 1));
    expect(settled, isFalse);
    await tester.pump(const Duration(seconds: 1));
    await outcome;
  });
}
