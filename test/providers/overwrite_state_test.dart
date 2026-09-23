import 'dart:async';

import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/database.dart';
import 'package:fl_clash/providers/state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../helpers/test_profiles.dart';

class _TestClashProviders extends ClashProviders {
  final List<ClashProvider> initial;

  _TestClashProviders(this.initial);

  @override
  Stream<List<ClashProvider>> build(ProviderKind kind) =>
      Stream.value(initial.where((item) => item.kind == kind).toList());
}

class _TestProxyGroups extends ProxyGroups {
  final List<ProxyGroup> initial;

  _TestProxyGroups(this.initial);

  @override
  Stream<List<ProxyGroup>> build(int profileId) => Stream.value(initial);

  @override
  void order(int oldIndex, int newIndex) {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const profileId = 1;
  const proxyGroup = ProxyGroup(
    id: 7,
    profileId: profileId,
    name: 'Group',
    type: GroupType.Selector,
    proxies: ['Known'],
    use: ['provider'],
  );

  test('validity stays quiet until the profile config resolves', () async {
    final config = Completer<ClashConfig>();
    final container = ProviderContainer(
      overrides: [
        profilesProvider.overrideWith(TestProfiles.new),
        clashProvidersProvider.overrideWith2((_) => _TestClashProviders([])),
        proxyGroupsProvider.overrideWith2(
          (_) => _TestProxyGroups([proxyGroup]),
        ),
        clashConfigProvider(profileId).overrideWith((_) => config.future),
      ],
    );
    addTearDown(container.dispose);
    container.listen(customOverwriteDateProvider(profileId), (_, _) {});
    await container.read(proxyGroupsProvider(profileId).future);

    expect(
      container.read(customOverwriteDateProvider(profileId)).loaded,
      false,
    );
    expect(container.read(invalidProxyGroupIdsProvider(profileId)), isEmpty);
    expect(
      container.read(customOverwriteTargetIsValidProvider(profileId, 'Known')),
      true,
    );
    expect(
      container.read(
        customOverwriteProxiesIsValidProvider(profileId, const ['Known']),
      ),
      true,
    );
    expect(
      container.read(
        customOverwriteUseIsValidProvider(profileId, const ['provider']),
      ),
      true,
    );

    config.complete(
      const ClashConfig(
        proxies: [Proxy(name: 'Known', type: 'ss')],
        proxyProviders: ['provider'],
      ),
    );
    await container.read(clashConfigProvider(profileId).future);

    final overwrite = container.read(customOverwriteDateProvider(profileId));
    expect(overwrite.loaded, true);
    expect(overwrite.proxyNames, ['Known']);
    expect(overwrite.proxyTypes, {'Known': 'ss'});
    expect(container.read(invalidProxyGroupIdsProvider(profileId)), isEmpty);
    expect(
      container.read(customOverwriteTargetIsValidProvider(profileId, 'Gone')),
      false,
    );
  });

  test('an app-level provider and a profile count as valid names', () async {
    const appProvider = ClashProvider(
      id: 9,
      kind: ProviderKind.proxy,
      label: 'provider',
      url: 'https://example.com/nodes.yaml',
    );
    final profile = Profile.normal(label: 'Subscription');
    final container = ProviderContainer(
      overrides: [
        profilesProvider.overrideWith(() => TestProfiles([profile])),
        clashProvidersProvider.overrideWith2(
          (_) => _TestClashProviders([appProvider]),
        ),
        proxyGroupsProvider.overrideWith2(
          (_) => _TestProxyGroups([
            proxyGroup.copyWith(proxies: null, use: ['provider']),
          ]),
        ),
        clashConfigProvider(profileId).overrideWith((_) => const ClashConfig()),
      ],
    );
    addTearDown(container.dispose);
    container.listen(customOverwriteDateProvider(profileId), (_, _) {});
    await container.read(proxyGroupsProvider(profileId).future);
    await container.read(clashConfigProvider(profileId).future);
    await container.read(clashProvidersProvider(ProviderKind.proxy).future);

    expect(container.read(invalidProxyGroupIdsProvider(profileId)), isEmpty);
    expect(
      container.read(
        customOverwriteProxyProviderIsValidProvider(profileId, 'provider'),
      ),
      true,
    );
    expect(
      container.read(
        customOverwriteUseIsValidProvider(profileId, const ['Subscription']),
      ),
      true,
    );
    expect(
      container.read(appProviderNamesProvider(ProviderKind.rule)),
      isEmpty,
    );
  });

  test(
    'a resolved config reports the groups that reference missing names',
    () async {
      final container = ProviderContainer(
        overrides: [
          profilesProvider.overrideWith(TestProfiles.new),
          clashProvidersProvider.overrideWith2((_) => _TestClashProviders([])),
          proxyGroupsProvider.overrideWith2(
            (_) => _TestProxyGroups([proxyGroup]),
          ),
          clashConfigProvider(
            profileId,
          ).overrideWith((_) => const ClashConfig()),
        ],
      );
      addTearDown(container.dispose);
      container.listen(customOverwriteDateProvider(profileId), (_, _) {});
      await container.read(proxyGroupsProvider(profileId).future);
      await container.read(clashConfigProvider(profileId).future);

      expect(
        container.read(customOverwriteDateProvider(profileId)).loaded,
        true,
      );
      expect(container.read(invalidProxyGroupIdsProvider(profileId)), {7});
      expect(
        container.read(
          customOverwriteProxyProviderIsValidProvider(profileId, 'provider'),
        ),
        false,
      );
    },
  );
}
