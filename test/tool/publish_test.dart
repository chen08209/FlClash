import 'dart:io';

import 'package:test/test.dart';
import 'package:yaml/yaml.dart';

import '../../tool/src/publish/prune.dart';
import '../../tool/src/publish/telegram.dart';

Map<String, dynamic> _release(
  String tag, {
  bool? prerelease,
  bool draft = false,
}) {
  return {
    'tag_name': tag,
    'prerelease': prerelease ?? tag.contains('-'),
    'draft': draft,
  };
}

void main() {
  group('prereleasesToPrune', () {
    final releases = [
      _release('v1.2.0-pre.3'),
      _release('v1.1.0'),
      _release('v1.2.0-pre.1'),
      _release('v1.2.0-rs.4'),
      _release('v1.2.0-pre.2+1'),
      _release('v1.2.0-rs.1'),
      _release('v1.2.0-pre.2'),
      _release('v1.0.0'),
      _release('v1.2.0-rs.3'),
    ];

    test('keeps the newest two prereleases of the published line', () {
      expect(prereleasesToPrune(releases, 'v1.2.0-pre.3'), [
        'v1.2.0-pre.2',
        'v1.2.0-pre.1',
      ]);
      expect(prereleasesToPrune(releases, 'v1.2.0-rs.4'), ['v1.2.0-rs.1']);
    });

    test('never deletes a stable release', () {
      final everything = [
        for (final tag in ['v1.2.0-pre.3', 'v1.2.0-rs.4', 'v1.2.0'])
          ...prereleasesToPrune([...releases, _release('v1.2.0')], tag),
      ];

      expect(everything, isNot(anyOf(contains('v1.1.0'), contains('v1.0.0'))));
      expect(everything, isNot(contains('v1.2.0')));
    });

    test('leaves a release GitHub does not flag as a prerelease', () {
      expect(
        prereleasesToPrune([
          _release('v1.2.0-pre.9', prerelease: false),
          _release('v1.2.0-pre.3'),
          _release('v1.2.0-pre.2'),
          _release('v1.2.0-pre.1'),
        ], 'v1.2.0-pre.3'),
        ['v1.2.0-pre.1'],
      );
    });

    test('leaves drafts and tags that are no release', () {
      expect(
        prereleasesToPrune([
          _release('v1.2.0-pre.3'),
          _release('v1.2.0-pre.2'),
          _release('v1.2.0-pre.1', draft: true),
          _release('nightly-pre', prerelease: true),
        ], 'v1.2.0-pre.3'),
        isEmpty,
      );
    });

    test('a stable release removes the prereleases below it', () {
      expect(
        prereleasesToPrune([
          ...releases,
          _release('v1.2.0'),
          _release('v1.2.1-pre.1'),
        ], 'v1.2.0'),
        ['v1.2.0-pre.3', 'v1.2.0-pre.2+1', 'v1.2.0-pre.2', 'v1.2.0-pre.1'],
      );
    });

    test('a stable release keeps the newer prereleases within the two', () {
      expect(
        prereleasesToPrune([
          _release('v1.3.0-pre.2'),
          _release('v1.3.0-pre.1'),
          _release('v1.2.1'),
        ], 'v1.2.1'),
        isEmpty,
      );
    });

    test('any prune removes the prereleases below a listed stable release', () {
      final late = [
        _release('v1.2.0'),
        _release('v1.2.0-pre.2'),
        _release('v1.2.0-pre.1'),
      ];

      expect(prereleasesToPrune(late, 'v1.2.0-pre.2'), ['v1.2.0-pre.1']);
      expect(
        prereleasesToPrune([...late, _release('v1.3.0-pre.1')], 'v1.3.0-pre.1'),
        ['v1.2.0-pre.2', 'v1.2.0-pre.1'],
      );
      expect(
        prereleasesToPrune([...late, _release('v1.2.0-rs.1')], 'v1.2.0-rs.1'),
        isEmpty,
      );
    });

    test('never deletes the release it was run for', () {
      expect(
        prereleasesToPrune([
          _release('v1.2.0-pre.5'),
          _release('v1.2.0-pre.4'),
          _release('v1.2.0-pre.3'),
        ], 'v1.2.0-pre.3'),
        isNot(contains('v1.2.0-pre.3')),
      );
    });

    test('refuses a tag that is no release', () {
      expect(() => prereleasesToPrune(releases, 'main'), throwsArgumentError);
    });
  });

  test('a release that cannot be deleted leaves the rest to be', () async {
    final tried = <String>[];

    final failed = await deleteReleases(['a', 'b', 'c'], (tag) async {
      tried.add(tag);
      return tag == 'b' ? 'release not found' : null;
    });

    expect(tried, ['a', 'b', 'c']);
    expect(failed, {'b': 'release not found'});
  });

  test('the Telegram post is a title and the release page alone', () {
    expect(telegramReleaseMessage('owner/repo', 'v1.2.0-pre.2+1'), {
      'chat_id': telegramChannel,
      'text':
          'FlClash v1.2.0-pre.2+1\n'
          'https://github.com/owner/repo/releases/tag/v1.2.0-pre.2+1',
    });
  });

  group('postToTelegram', () {
    late HttpServer server;
    HttpOverrides? overrides;

    setUp(() async {
      // A widget test in the same isolate leaves flutter_test's overrides,
      // which answer every request with 400.
      overrides = HttpOverrides.current;
      HttpOverrides.global = null;
      server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    });

    tearDown(() async {
      HttpOverrides.global = overrides;
      await server.close(force: true);
    });

    Uri api() => Uri.http('127.0.0.1:${server.port}');

    test('posts to the bot and takes an ok answer', () async {
      String? path;
      server.listen((request) async {
        path = request.uri.path;
        request.response.write('{"ok":true}');
        await request.response.close();
      });

      expect(await postToTelegram({'text': 'hi'}, '1:token', api: api()), null);
      expect(path, '/bot1:token/sendMessage');
    });

    test('gives up on a bot that never answers', () async {
      server.listen((_) {});

      expect(
        await postToTelegram(
          {'text': 'hi'},
          '1:token',
          api: api(),
          timeout: const Duration(milliseconds: 200),
        ),
        startsWith('Telegram could not be reached'),
      );
    }, timeout: const Timeout(Duration(seconds: 10)));

    test('reports a dropped connection without the token', () async {
      server.listen((request) async {
        final socket = await request.response.detachSocket(writeHeaders: false);
        socket.destroy();
      });

      final problem = await postToTelegram(
        {'text': 'hi'},
        '1:secret',
        api: api(),
      );

      expect(problem, startsWith('Telegram could not be reached'));
      expect(problem, isNot(contains('secret')));
    });
  });

  YamlList releaseSteps() {
    final workflow =
        loadYaml(File('.github/workflows/build.yaml').readAsStringSync())
            as YamlMap;
    return workflow['jobs']['upload']['steps'] as YamlList;
  }

  test('a release is announced once its packages are out, and pruned last', () {
    final steps = [
      for (final step in releaseSteps()) (step as YamlMap)['name'] as String?,
    ];
    int at(String name) {
      expect(steps, contains(name));
      return steps.indexOf(name);
    }

    final announced = at('Post to Telegram');
    expect(announced, greaterThan(at('Release')));
    expect(announced, greaterThan(at('Push to Homebrew tap')));
    expect(announced, greaterThan(at('Push to fdroid repo')));
    expect(at('Delete superseded prereleases'), steps.length - 1);
  });

  test('the prune fails when a page of the release list does', () {
    final prune = releaseSteps().cast<YamlMap>().singleWhere(
      (step) => step['name'] == 'Delete superseded prereleases',
    );

    expect(prune['run'], contains('gh api --paginate'));
    expect(prune['shell'], 'bash', reason: 'GitHub adds pipefail to bash');
  });
}
