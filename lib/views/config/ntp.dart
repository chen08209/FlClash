import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/pages/editor.dart';
import 'package:fl_clash/providers/state.dart';
import 'package:fl_clash/views/config/override.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

extension on NtpOverrideKey {
  String label(AppLocalizations l) => switch (this) {
    NtpOverrideKey.enable => l.status,
    NtpOverrideKey.server => l.server,
    NtpOverrideKey.port => l.port,
    NtpOverrideKey.interval => l.ntpInterval,
    NtpOverrideKey.dialerProxy => l.dialerProxy,
    NtpOverrideKey.writeToSystem => l.writeToSystem,
  };

  ConfigLabel? get description => switch (this) {
    NtpOverrideKey.enable => (l) => l.ntpStatusDesc,
    NtpOverrideKey.dialerProxy => (l) => l.dialerProxyDesc,
    NtpOverrideKey.writeToSystem => (l) => l.writeToSystemDesc,
    _ => null,
  };
}

typedef _NtpState = OverrideState<NtpOverrideKey, Ntp>;

_NtpState _profileNtp(ProfileOverrides overrides) =>
    (model: overrides.ntp, keys: overrides.ntpOverrideKeys);

ProfileOverrides _setProfileNtp(ProfileOverrides overrides, _NtpState state) =>
    overrides.copyWith(ntp: state.model, ntpOverrideKeys: state.keys);

class NtpView extends OverrideView<NtpOverrideKey, Ntp> {
  NtpView(int profileId, {super.key})
    : super(
        spec: _NtpOverrideSpec(
          ProfileOverrideTarget(
            profileId,
            get: _profileNtp,
            set: _setProfileNtp,
            issues: customProfileIssuesProvider(
              profileId,
            ).select((state) => state.ntp),
          ),
        ),
      );
}

class _NtpOverrideSpec extends OverrideSpec<NtpOverrideKey, Ntp>
    with OverrideQuickEdit<NtpOverrideKey, Ntp> {
  const _NtpOverrideSpec(this.target);

  @override
  final OverrideTarget<NtpOverrideKey, Ntp> target;

  @override
  String title(AppLocalizations l) => 'NTP';

  @override
  List<NtpOverrideKey> get values => NtpOverrideKey.values;

  @override
  String overrideYaml(Ntp model, Set<NtpOverrideKey> keys) =>
      model.overrideYaml(keys);

  @override
  _NtpState applyOverrideYaml(Ntp model, String content) {
    final result = model.applyOverrideYaml(content);
    return (model: result.ntp, keys: result.keys);
  }

  @override
  EditorSchema get schema => EditorSchema.ntp;

  @override
  NullStatusIllustration get illustration => NullStatusIllustration.ntp;

  @override
  Ntp get defaults => defaultNtp;

  @override
  String label(NtpOverrideKey key, AppLocalizations l) => key.label(l);

  @override
  ConfigLabel? description(NtpOverrideKey key) => key.description;

  @override
  OverrideField<Ntp> fieldOf(NtpOverrideKey key) => switch (key) {
    NtpOverrideKey.enable => ToggleOverrideField(
      (ntp) => ntp.enable,
      (ntp, value) => ntp.copyWith(enable: value),
    ),
    NtpOverrideKey.server => TextOverrideField(
      (ntp) => ntp.server,
      (ntp, value) => ntp.copyWith(server: value),
      maxLength: TextInputLimits.domain,
      validator: validateHost,
    ),
    NtpOverrideKey.port => NumberOverrideField(
      (ntp) => ntp.port,
      (ntp, value) => ntp.copyWith(port: value),
      maxLength: TextInputLimits.port,
      min: 1,
      max: 65535,
    ),
    NtpOverrideKey.interval => NumberOverrideField(
      (ntp) => ntp.interval,
      (ntp, value) => ntp.copyWith(interval: value),
      min: 1,
    ),
    NtpOverrideKey.dialerProxy => TextOverrideField(
      (ntp) => ntp.dialerProxy,
      (ntp, value) => ntp.copyWith(dialerProxy: value),
      maxLength: TextInputLimits.groupName,
    ),
    NtpOverrideKey.writeToSystem => ToggleOverrideField(
      (ntp) => ntp.writeToSystem,
      (ntp, value) => ntp.copyWith(writeToSystem: value),
    ),
  };
}
