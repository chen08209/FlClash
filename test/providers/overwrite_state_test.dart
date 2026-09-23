import 'dart:async';
import 'dart:io';

import 'package:fl_clash/common/feature.dart';

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

class _TestCustomProxies extends CustomProxies {
  final List<CustomProxy> initial;

  _TestCustomProxies([this.initial = const []]);

  @override
  Stream<List<CustomProxy>> build(int profileId) => Stream.value(initial);
}

class _TestCustomRules extends ProfileCustomRules {
  @override
  Stream<List<Rule>> build(int profileId) => Stream.value(const []);
}

class _TestProxyGroups extends ProxyGroups {
  final List<ProxyGroup> initial;

  _TestProxyGroups(this.initial);

  @override
  Stream<List<ProxyGroup>> build(int profileId) => Stream.value(initial);

  @override
  void order(int oldIndex, int newIndex) {}
}

const profileId = 1;

Set<int> _invalidGroupIds(ProviderContainer container) => container
    .read(customOverwriteIssuesProvider(profileId))
    .proxyGroups
    .keys
    .toSet();

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(
    () => feature = const Feature(customProviders: true, customProxies: true),
  );
  tearDown(() => feature = const Feature());

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
        customProxiesProvider.overrideWith2((_) => _TestCustomProxies()),
        profileCustomRulesProvider.overrideWith2((_) => _TestCustomRules()),
        proxyGroupsProvider.overrideWith2(
          (_) => _TestProxyGroups([proxyGroup]),
        ),
        clashConfigProvider(profileId).overrideWith((_) => config.future),
      ],
    );
    addTearDown(container.dispose);
    container.listen(customOverwriteDateProvider(profileId), (_, _) {});
    await container.read(proxyGroupsProvider(profileId).future);
    await container.read(customProxiesProvider(profileId).future);

    expect(
      container.read(customOverwriteDateProvider(profileId)).loaded,
      false,
    );
    expect(_invalidGroupIds(container), isEmpty);
    expect(
      container.read(customOverwriteTargetIsValidProvider(profileId, 'Known')),
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
    expect(_invalidGroupIds(container), isEmpty);
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
        customProxiesProvider.overrideWith2((_) => _TestCustomProxies()),
        profileCustomRulesProvider.overrideWith2((_) => _TestCustomRules()),
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
    await container.read(customProxiesProvider(profileId).future);
    await container.read(clashConfigProvider(profileId).future);
    await container.read(clashProvidersProvider(ProviderKind.proxy).future);

    expect(_invalidGroupIds(container), isEmpty);
    expect(
      container.read(
        customOverwriteProxyProviderIsValidProvider(profileId, 'provider'),
      ),
      true,
    );
    expect(
      proxyGroupIssues(
        proxyGroup.copyWith(proxies: null, use: ['Subscription']),
        container.read(customOverwriteDateProvider(profileId)),
      ),
      isEmpty,
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
          customProxiesProvider.overrideWith2((_) => _TestCustomProxies()),
          profileCustomRulesProvider.overrideWith2((_) => _TestCustomRules()),
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
      await container.read(customProxiesProvider(profileId).future);
      await container.read(clashConfigProvider(profileId).future);

      expect(
        container.read(customOverwriteDateProvider(profileId)).loaded,
        true,
      );
      expect(_invalidGroupIds(container), {7});
      expect(
        container.read(
          customOverwriteProxyProviderIsValidProvider(profileId, 'provider'),
        ),
        false,
      );
    },
  );

  group('issues', () {
    const overwrite = CustomOverwriteDate(
      loaded: true,
      proxyNames: ['Node'],
      proxyGroups: [
        ProxyGroup(id: 1, name: 'A', type: GroupType.Selector, proxies: ['B']),
        ProxyGroup(id: 2, name: 'B', type: GroupType.Selector, proxies: ['A']),
      ],
      ruleTargets: {'DIRECT', 'REJECT', 'Node', 'A', 'B'},
    );

    test('a group that reaches itself names the loop', () {
      expect(proxyGroupIssues(overwrite.proxyGroups.first, overwrite), [
        const OverwriteIssue.groupLoop(['A', 'B', 'A']),
      ]);
    });

    test('a group without members or providers is refused', () {
      const group = ProxyGroup(id: 3, name: 'C', type: GroupType.Selector);
      expect(proxyGroupIssues(group, overwrite), [
        const OverwriteIssue.noProxySource(),
      ]);
      expect(
        proxyGroupIssues(group.copyWith(includeAllProxies: true), overwrite),
        isEmpty,
      );
    });

    test('a group cannot take a proxy or built-in name', () {
      const group = ProxyGroup(
        id: 3,
        name: 'Node',
        type: GroupType.Selector,
        proxies: ['DIRECT', 'Gone'],
      );
      expect(proxyGroupIssues(group, overwrite), [
        const OverwriteIssue.duplicateName('Node'),
        const OverwriteIssue.missingProxies(['Gone']),
      ]);
      expect(
        proxyGroupIssues(group.copyWith(name: 'DIRECT'), overwrite).first,
        const OverwriteIssue.reservedName('DIRECT'),
      );
    });

    test('custom proxies report names and core errors together', () {
      const first = CustomProxy(id: 1, definition: {'name': 'X'});
      const second = CustomProxy(id: 2, definition: {'name': 'X'});
      expect(
        customProxyIssues(
          first,
          proxies: const [first, second],
          proxyGroups: const [],
          coreError: 'missing type',
        ),
        [
          const OverwriteIssue.duplicateName('X'),
          const OverwriteIssue.coreRejected('missing type'),
        ],
      );
      expect(
        customProxyIssues(
          const CustomProxy(id: 3, definition: {'name': 'A'}),
          proxies: const [],
          proxyGroups: overwrite.proxyGroups,
        ),
        [const OverwriteIssue.duplicateName('A')],
      );
    });

    test(
      'custom proxies replace the profile names they are checked against',
      () async {
        const proxy = CustomProxy(
          id: 5,
          definition: {'name': 'Mine', 'type': 'socks5'},
        );
        final container = ProviderContainer(
          overrides: [
            profilesProvider.overrideWith(TestProfiles.new),
            clashProvidersProvider.overrideWith2(
              (_) => _TestClashProviders([]),
            ),
            customProxiesProvider.overrideWith2(
              (_) => _TestCustomProxies([proxy]),
            ),
            profileCustomRulesProvider.overrideWith2((_) => _TestCustomRules()),
            customProxyCoreErrorsProvider(
              profileId,
            ).overrideWith((_) async => {proxy.id: 'bad cipher'}),
            proxyGroupsProvider.overrideWith2(
              (_) => _TestProxyGroups([proxyGroup]),
            ),
            clashConfigProvider(profileId).overrideWith(
              (_) => const ClashConfig(
                proxies: [Proxy(name: 'Known', type: 'ss')],
                proxyProviders: ['provider'],
              ),
            ),
          ],
        );
        addTearDown(container.dispose);
        container.listen(customOverwriteIssuesProvider(profileId), (_, _) {});
        await container.read(proxyGroupsProvider(profileId).future);
        await container.read(customProxiesProvider(profileId).future);
        await container.read(profileCustomRulesProvider(profileId).future);
        await container.read(clashConfigProvider(profileId).future);
        await container.read(customProxyCoreErrorsProvider(profileId).future);

        final overwrite = container.read(
          customOverwriteDateProvider(profileId),
        );
        expect(overwrite.proxyNames, ['Mine']);
        final issues = container.read(customOverwriteIssuesProvider(profileId));
        expect(issues.proxies, {
          proxy.id: [const OverwriteIssue.coreRejected('bad cipher')],
        });
        expect(issues.proxyGroups, {
          proxyGroup.id: [
            const OverwriteIssue.missingProxies(['Known']),
          ],
        });
      },
    );
  });

  test('customProxyTypes lists every type the core parses', () {
    final source = File('core/Clash.Meta/adapter/parser.go').readAsStringSync();
    expect(customProxyTypes, [
      for (final match in RegExp(
        r'^\tcase "([^"]+)":',
        multiLine: true,
      ).allMatches(source))
        match.group(1)!,
    ]);
  });

  test(
    'switched-off features leave app providers and custom proxies out',
    () async {
      feature = const Feature();
      const appProvider = ClashProvider(
        id: 9,
        kind: ProviderKind.proxy,
        label: 'provider',
        url: 'https://example.com/nodes.yaml',
      );
      final container = ProviderContainer(
        overrides: [
          profilesProvider.overrideWith(
            () => TestProfiles([Profile.normal(label: 'Subscription')]),
          ),
          clashProvidersProvider.overrideWith2(
            (_) => _TestClashProviders([appProvider]),
          ),
          customProxiesProvider.overrideWith2(
            (_) => _TestCustomProxies([
              const CustomProxy(id: 5, definition: {'name': 'Mine'}),
            ]),
          ),
          profileCustomRulesProvider.overrideWith2((_) => _TestCustomRules()),
          proxyGroupsProvider.overrideWith2((_) => _TestProxyGroups([])),
          clashConfigProvider(profileId).overrideWith(
            (_) => const ClashConfig(
              proxies: [Proxy(name: 'Known', type: 'ss')],
            ),
          ),
        ],
      );
      addTearDown(container.dispose);
      container.listen(customOverwriteIssuesProvider(profileId), (_, _) {});
      await container.read(proxyGroupsProvider(profileId).future);
      await container.read(clashConfigProvider(profileId).future);

      expect(
        container.read(appProviderNamesProvider(ProviderKind.proxy)),
        isEmpty,
      );
      expect(
        container.read(appProviderLabelsProvider(ProviderKind.proxy)),
        isEmpty,
      );
      final overwrite = container.read(customOverwriteDateProvider(profileId));
      expect(overwrite.loaded, true);
      expect(overwrite.proxyNames, ['Known']);
      expect(
        container.read(customOverwriteIssuesProvider(profileId)).proxies,
        isEmpty,
      );
    },
  );
}
