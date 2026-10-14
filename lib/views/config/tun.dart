import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/views/config/override.dart';
import 'package:fl_clash/widgets/widgets.dart';

extension on TunOverrideKey {
  String label(AppLocalizations l) => switch (this) {
    TunOverrideKey.disableIcmpForwarding => l.disableIcmpForwarding,
    TunOverrideKey.excludeInterface => l.excludeInterface,
  };

  ConfigLabel get description => switch (this) {
    TunOverrideKey.disableIcmpForwarding => (l) => l.disableIcmpForwardingDesc,
    TunOverrideKey.excludeInterface => (l) => l.excludeInterfaceDesc,
  };
}

typedef _TunState = OverrideState<TunOverrideKey, ProfileTun>;

_TunState _profileTun(ProfileOverrides overrides) =>
    (model: overrides.tun, keys: overrides.tunOverrideKeys);

ProfileOverrides _setProfileTun(ProfileOverrides overrides, _TunState state) =>
    overrides.copyWith(tun: state.model, tunOverrideKeys: state.keys);

class TunView extends OverrideView<TunOverrideKey, ProfileTun> {
  TunView(int profileId, {super.key})
    : super(
        spec: _TunOverrideSpec(
          ProfileOverrideTarget(
            profileId,
            get: _profileTun,
            set: _setProfileTun,
          ),
        ),
      );
}

class _TunOverrideSpec extends OverrideSpec<TunOverrideKey, ProfileTun> {
  const _TunOverrideSpec(this.target);

  @override
  final OverrideTarget<TunOverrideKey, ProfileTun> target;

  @override
  String title(AppLocalizations l) => l.tun;

  @override
  List<TunOverrideKey> get values => TunOverrideKey.values;

  @override
  NullStatusIllustration get illustration => NullStatusIllustration.tun;

  @override
  ProfileTun get defaults => defaultProfileTun;

  @override
  String label(TunOverrideKey key, AppLocalizations l) => key.label(l);

  @override
  ConfigLabel description(TunOverrideKey key) => key.description;

  @override
  OverrideField<ProfileTun> fieldOf(TunOverrideKey key) => switch (key) {
    TunOverrideKey.disableIcmpForwarding => ToggleOverrideField(
      (tun) => tun.disableIcmpForwarding,
      (tun, value) => tun.copyWith(disableIcmpForwarding: value),
    ),
    TunOverrideKey.excludeInterface => ListOverrideField(
      (tun) => tun.excludeInterface,
      (tun, value) => tun.copyWith(excludeInterface: value),
      itemMaxLength: TextInputLimits.name,
    ),
  };
}
