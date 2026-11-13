import 'dart:convert';
import 'dart:io';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/core/controller.dart';
import 'package:fl_clash/core/interface.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/core.dart';
import 'package:fl_clash/providers/database.dart';
import 'package:fl_clash/providers/state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:riverpod/riverpod.dart';

import '../helpers/app_paths.dart';
import '../helpers/test_database_providers.dart';
import '../helpers/test_profiles.dart';

class _MockCoreHandlerInterface extends Mock implements CoreHandlerInterface {}

void main() {
  late Directory tempDir;
  late _MockCoreHandlerInterface core;
  late Script script;
  late ScriptEvaluator engine;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('script_outbounds_test');
    await useAppPaths(tempDir);
    script = await Script(
      id: 7,
      label: 'rename',
      lastUpdateTime: DateTime(2026),
    ).save('const main = (config) => config;');
  });

  tearDownAll(() => tempDir.delete(recursive: true));

  setUp(() {
    engine = scriptEvaluator;
    core = _MockCoreHandlerInterface();
    when(() => core.readConfig(any())).thenAnswer(
      (_) async => <String, dynamic>{
        'proxies': [
          {'name': 'node', 'type': 'ss', 'server': 'example.com'},
        ],
        'proxy-groups': [
          {
            'name': 'Before',
            'type': 'select',
            'proxies': ['node'],
          },
        ],
      },
    );
  });

  tearDown(() => scriptEvaluator = engine);

  Future<ClashConfig?> outboundsOf(Profile profile) {
    final container = ProviderContainer(
      overrides: [
        profilesProvider.overrideWith(() => TestProfiles([profile])),
        scriptsProvider.overrideWith(() => TestScripts([script])),
        coreHandlerProvider.overrideWithValue(CoreController.scoped(core)),
      ],
    );
    addTearDown(container.dispose);
    final provider = scriptOutboundsProvider(profile.id);
    container.listen(provider, (_, _) {});
    return container.read(provider.future);
  }

  test('lists the groups the script hands the core', () async {
    final inputs = <Map<String, dynamic>>[];
    scriptEvaluator = ({required String script, required String config}) async {
      final input = json.decode(config) as Map<String, dynamic>;
      inputs.add(input);
      return json.encode({
        ...input,
        'proxy-groups': [
          {
            'name': 'After',
            'type': 'url-test',
            'proxies': ['node'],
          },
        ],
      });
    };
    final profile = Profile.normal(label: 'sub').copyWith(scriptId: script.id);

    final config = await outboundsOf(profile);

    expect(inputs.single['proxy-providers'], isEmpty);
    expect(config!.proxyGroups.map((group) => group.name), ['After']);
    expect(config.proxyGroups.single.type, GroupType.URLTest);
    expect(config.proxies.map((proxy) => (proxy.name, proxy.type)), [
      ('node', 'ss'),
    ]);
  });

  test('a script that fails is an error, not the groups before it', () async {
    scriptEvaluator = ({required String script, required String config}) =>
        Future.error(StateError('main is not a function'));
    final profile = Profile.normal(label: 'sub').copyWith(scriptId: script.id);

    await expectLater(
      outboundsOf(profile),
      throwsA(
        isA<MessageException>().having(
          (error) => error.message,
          'message',
          contains('main is not a function'),
        ),
      ),
    );
  });

  test('a profile without a script runs none', () async {
    final profile = Profile.normal(label: 'sub');

    expect(await outboundsOf(profile), isNull);
    verifyNever(() => core.readConfig(any()));
  });
}
