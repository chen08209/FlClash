import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/action.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/providers/database.dart';
import 'package:fl_clash/providers/state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';

void main() {
  group('ProfilesAction', () {
    test('keeps edited profile data when remote update fails', () async {
      final original = Profile.normal(label: 'old label', url: 'bad-url');
      final edited = original.copyWith(
        label: 'new label',
        url: 'still-bad-url',
      );
      final container = ProviderContainer(
        overrides: [
          currentProfileIdProvider.overrideWithBuild((_, _) => null),
          profilesProvider.overrideWith(() => _TestProfiles([original])),
        ],
      );
      addTearDown(container.dispose);

      expect(
        container.read(profilesProvider).getProfile(original.id),
        original,
      );

      await expectLater(
        container.read(profilesActionProvider.notifier).updateProfile(edited),
        throwsA(anything),
      );

      final profile = container.read(profilesProvider).getProfile(original.id);
      expect(profile?.label, edited.label);
      expect(profile?.url, edited.url);
    });

    test('toggles favorites, deduplicates, and preserves order', () {
      const profile = Profile(id: 1, autoUpdateDuration: defaultUpdateDuration);
      final container = _buildProfilesActionContainer(profile);
      addTearDown(container.dispose);
      const first = FavoriteProxy(groupName: 'GLOBAL', proxyName: 'HK');
      const second = FavoriteProxy(groupName: 'GLOBAL', proxyName: 'JP');
      final action = container.read(profilesActionProvider.notifier);

      expect(action.toggleFavoriteProxy(first), true);
      expect(action.toggleFavoriteProxy(second), true);
      expect(container.read(currentProfileProvider)?.favoriteProxies, [
        first,
        second,
      ]);

      expect(action.toggleFavoriteProxy(first), true);
      expect(container.read(currentProfileProvider)?.favoriteProxies, [second]);
    });

    test('rejects a ninth favorite', () {
      final favorites = List.generate(
        maxFavoriteProxies,
        (index) =>
            FavoriteProxy(groupName: 'GLOBAL', proxyName: 'proxy-$index'),
      );
      final profile = Profile(
        id: 1,
        autoUpdateDuration: defaultUpdateDuration,
        favoriteProxies: favorites,
      );
      final container = _buildProfilesActionContainer(profile);
      addTearDown(container.dispose);

      final updated = container
          .read(profilesActionProvider.notifier)
          .toggleFavoriteProxy(
            const FavoriteProxy(groupName: 'GLOBAL', proxyName: 'overflow'),
          );

      expect(updated, false);
      expect(
        container.read(currentProfileProvider)?.favoriteProxies,
        favorites,
      );
    });

    test('removes stale and non-selectable favorites after group refresh', () {
      const valid = FavoriteProxy(groupName: 'Selectable', proxyName: 'HK');
      const missing = FavoriteProxy(groupName: 'Selectable', proxyName: 'US');
      const automatic = FavoriteProxy(groupName: 'Relay', proxyName: 'JP');
      const profile = Profile(
        id: 1,
        autoUpdateDuration: defaultUpdateDuration,
        favoriteProxies: [valid, missing, automatic],
      );
      final container = _buildProfilesActionContainer(profile);
      addTearDown(container.dispose);

      container.read(profilesActionProvider.notifier).reconcileFavoriteProxies(
        const [
          Group(
            name: 'Selectable',
            type: GroupType.Selector,
            all: [Proxy(name: 'HK', type: 'ss')],
          ),
          Group(
            name: 'Relay',
            type: GroupType.Relay,
            all: [Proxy(name: 'JP', type: 'ss')],
          ),
        ],
      );

      expect(container.read(currentProfileProvider)?.favoriteProxies, [valid]);
    });
  });

  group('GeoResourceAction', () {
    test('GeoResource has correct updatingKey', () {
      expect(GeoResource.MMDB.updatingKey, 'geo_resource_MMDB');
      expect(GeoResource.ASN.updatingKey, 'geo_resource_ASN');
      expect(GeoResource.GEOIP.updatingKey, 'geo_resource_GEOIP');
      expect(GeoResource.GEOSITE.updatingKey, 'geo_resource_GEOSITE');
    });

    test('IsUpdating provider works with geo resource key', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final key = GeoResource.MMDB.updatingKey;
      expect(container.read(isUpdatingProvider(key)), false);

      container.read(isUpdatingProvider(key).notifier).value = true;
      expect(container.read(isUpdatingProvider(key)), true);

      container.read(isUpdatingProvider(key).notifier).value = false;
      expect(container.read(isUpdatingProvider(key)), false);
    });
  });
}

ProviderContainer _buildProfilesActionContainer(Profile profile) {
  return ProviderContainer(
    overrides: [
      currentProfileIdProvider.overrideWithBuild((_, _) => profile.id),
      profilesProvider.overrideWith(() => _TestProfiles([profile])),
    ],
  );
}

class _TestProfiles extends Profiles {
  final List<Profile> initial;

  _TestProfiles(this.initial);

  @override
  List<Profile> build() => initial;

  @override
  void put(Profile profile) {
    final next = List<Profile>.from(state);
    final index = next.indexWhere((item) => item.id == profile.id);
    if (index == -1) {
      next.add(profile);
    } else {
      next[index] = profile;
    }
    state = next;
  }
}
