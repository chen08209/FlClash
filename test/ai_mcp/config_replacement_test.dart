import 'dart:async';
import 'dart:io';

import 'package:fl_clash/ai_mcp/backend.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/core/controller.dart';
import 'package:fl_clash/core/interface.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/ai_mcp.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:riverpod/riverpod.dart';

import '../helpers/test_profiles.dart';

class _Core extends Mock implements CoreHandlerInterface {}

class _Paths extends PathProviderPlatform {
  _Paths(this.root);
  final String root;
  @override
  Future<String?> getApplicationSupportPath() async => root;
  @override
  Future<String?> getTemporaryPath() async => root;
  @override
  Future<String?> getApplicationCachePath() async => root;
}

class _ProfileBuilder extends SetupAction {
  @override
  Future<({String yaml, String md5})> getProfile({
    required SetupState setupState,
    required PatchClashConfig patchConfig,
  }) async => (yaml: 'mode: rule', md5: 'replacement');
}

const _url = 'https://configured.test';
const _names = ['one', 'two', 'three', 'four'];
const _setupState = SetupState(
  profileId: 1,
  profileLastUpdateDate: null,
  overwriteType: OverwriteType.standard,
  rules: [],
  proxyGroups: [],
  addedRules: [],
  script: null,
  overrideDns: false,
  dns: Dns(),
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() {
    registerFallbackValue(const SetupParams(selectedMap: {}, testUrl: ''));
    registerFallbackValue(
      const ChangeProxyParams(groupName: 'group', proxyName: 'one'),
    );
    PathProviderPlatform.instance = _Paths(
      Directory.systemTemp.createTempSync('mcp_config_replacement').path,
    );
  });
  for (final tool in ['select_proxy', 'test_delays']) {
    test(
      'ordinary same-profile apply invalidates $tool before awaiting core replacement',
      () async {
        final core = _Core();
        final container = ProviderContainer(
          overrides: [
            coreHandlerProvider.overrideWithValue(CoreController.scoped(core)),
            currentProfileIdProvider.overrideWithBuild((_, _) => 1),
            profilesProvider.overrideWith(
              () => TestProfiles([
                const Profile(
                  id: 1,
                  autoUpdateDuration: Duration.zero,
                  selectedMap: {'group': 'one'},
                ),
              ]),
            ),
            appSettingProvider.overrideWithBuild(
              (_, _) => const AppSettingProps(testUrl: _url),
            ),
            setupActionProvider.overrideWith(_ProfileBuilder.new),
            setupStateProvider.overrideWith((_, _) => _setupState),
          ],
        );
        addTearDown(container.dispose);
        final oldMd5 = globalState.lastConfigMd5;
        globalState.lastConfigMd5 = 'old';
        addTearDown(() => globalState.lastConfigMd5 = oldMd5);
        container.read(coreStatusProvider.notifier).value =
            CoreStatus.connected;
        final backend = container.read(Provider((ref) => AppAiMcpBackend(ref)));
        const data = ProxiesData(
          all: ['group'],
          proxies: {
            'group': {
              'name': 'group',
              'type': 'Selector',
              'all': _names,
              'now': 'one',
            },
            'one': {'name': 'one', 'type': 'ss'},
            'two': {'name': 'two', 'type': 'ss'},
            'three': {'name': 'three', 'type': 'ss'},
            'four': {'name': 'four', 'type': 'ss'},
          },
        );
        final entered = Completer<void>();
        final lookup = Completer<ProxiesData>();
        var reads = 0;
        when(core.getProxies).thenAnswer((_) {
          if (tool == 'select_proxy' && ++reads == 1) {
            entered.complete();
            return lookup.future;
          }
          return Future.value(data);
        });
        when(core.getExternalProviders).thenAnswer((_) async => []);
        final probes = <Completer<Delay?>>[];
        when(() => core.asyncTestDelay(any(), any())).thenAnswer((_) {
          final reply = Completer<Delay?>();
          probes.add(reply);
          if (probes.length == 2) entered.complete();
          if (probes.length > 2) {
            reply.complete(const Delay(name: 'three', url: _url, value: 10));
          }
          return reply.future;
        });
        when(() => core.changeProxy(any())).thenAnswer((_) async => '');
        final pending = backend.execute(
          tool,
          tool == 'select_proxy'
              ? {'group': 'group', 'node': 'two'}
              : {'nodes': _names},
          () {},
        );
        final rejected = expectLater(pending, throwsA(isA<AiMcpFailure>()));
        await entered.future;
        final setupEntered = Completer<void>();
        final setupReply = Completer<String>();
        when(() => core.setupConfig(any())).thenAnswer((_) {
          setupEntered.complete();
          return setupReply.future;
        });
        final applied = container
            .read(setupActionProvider.notifier)
            .applyProfile(silence: true);
        await setupEntered.future;
        expect(
          await File(await appPath.configFilePath).readAsString(),
          'mode: rule',
        );
        lookup.complete(data);
        for (var i = 0; i < probes.length; i++) {
          probes[i].complete(Delay(name: _names[i], url: _url, value: 10));
        }
        await rejected;
        expect(container.read(currentProfileIdProvider), 1);
        expect(container.read(coreStatusProvider), CoreStatus.connected);
        expect(container.read(delayDataSourceProvider), isEmpty);
        expect(probes, hasLength(tool == 'test_delays' ? 2 : 0));
        verifyNever(() => core.changeProxy(any()));
        setupReply.complete('');
        expect(await applied, true);
        final generation = container
            .read(proxiesActionProvider.notifier)
            .delayTestGeneration;
        expect(
          await container
              .read(setupActionProvider.notifier)
              .applyProfile(silence: true),
          true,
        );
        expect(
          container.read(proxiesActionProvider.notifier).delayTestGeneration,
          generation,
        );
        verify(() => core.setupConfig(any())).called(1);
      },
    );
  }
}
