import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'models.dart';
import 'session_store.dart';

class V2BoardSubscriptionManager {
  final ProviderContainer container;
  final V2BoardSessionStore sessionStore;

  const V2BoardSubscriptionManager({
    required this.container,
    required this.sessionStore,
  });

  Future<void> synchronize(V2BoardSession session) async {
    final managedProfileId = await sessionStore.readManagedProfileId();
    final profiles = container.read(profilesProvider);
    final existing = profiles.getProfile(managedProfileId);
    final source =
        existing ??
        Profile.normal(label: session.email, url: session.subscribeUrl);
    final updated = await source
        .copyWith(
          label: session.email,
          url: session.subscribeUrl,
          autoUpdate: true,
        )
        .update();
    container.read(profilesProvider.notifier).put(updated);
    container.read(currentProfileIdProvider.notifier).value = updated.id;
    await sessionStore.saveManagedProfileId(updated.id);
    await preferences.saveConfig(container.read(configProvider));
    await container
        .read(setupActionProvider.notifier)
        .applyProfile(force: true);
  }
}
