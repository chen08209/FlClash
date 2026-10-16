import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/views/config/override.dart';
import 'package:fl_clash/widgets/widgets.dart';

extension on TunOverrideKey {
  String label(AppLocalizations l) => switch (this) {
    TunOverrideKey.mtu => 'MTU',
    TunOverrideKey.congestionController => l.congestionController,
    TunOverrideKey.strictRoute => l.strictRoute,
    TunOverrideKey.routeAddress => l.routeAddress,
    TunOverrideKey.routeExcludeAddress => l.routeExcludeAddress,
    TunOverrideKey.dnsHijack => l.dnsHijacking,
    TunOverrideKey.udpTimeout => l.udpTimeout,
    TunOverrideKey.disableIcmpForwarding => l.disableIcmpForwarding,
    TunOverrideKey.gso => 'GSO',
    TunOverrideKey.includeInterface => l.includeInterface,
    TunOverrideKey.excludeInterface => l.excludeInterface,
    TunOverrideKey.includeUid => l.includeUid,
    TunOverrideKey.excludeUid => l.excludeUid,
    TunOverrideKey.excludeSrcPort => l.excludeSrcPort,
    TunOverrideKey.excludeDstPort => l.excludeDstPort,
  };

  ConfigLabel? get description => switch (this) {
    TunOverrideKey.mtu ||
    TunOverrideKey.routeAddress ||
    TunOverrideKey.routeExcludeAddress => null,
    TunOverrideKey.congestionController => (l) => l.congestionControllerDesc,
    TunOverrideKey.strictRoute => (l) => l.strictRouteDesc,
    TunOverrideKey.dnsHijack => (l) => l.dnsHijackDesc,
    TunOverrideKey.udpTimeout => (l) => l.udpTimeoutDesc,
    TunOverrideKey.disableIcmpForwarding => (l) => l.disableIcmpForwardingDesc,
    TunOverrideKey.gso => null,
    TunOverrideKey.includeInterface => (l) => l.includeInterfaceDesc,
    TunOverrideKey.excludeInterface => (l) => l.excludeInterfaceDesc,
    TunOverrideKey.includeUid => (l) => l.includeUidDesc,
    TunOverrideKey.excludeUid => (l) => l.excludeUidDesc,
    TunOverrideKey.excludeSrcPort => (l) => l.excludeSrcPortDesc,
    TunOverrideKey.excludeDstPort => (l) => l.excludeDstPortDesc,
  };
}

// Where sing-tun reads each key: strict-route in its Linux and Windows
// routing, the Linux-only ones in its Linux device setup and routing rules.
bool _isRead(
  TunOverrideKey key, {
  required bool isLinux,
  required bool isWindows,
}) => switch (key) {
  TunOverrideKey.strictRoute => isLinux || isWindows,
  TunOverrideKey.gso ||
  TunOverrideKey.includeInterface ||
  TunOverrideKey.excludeInterface ||
  TunOverrideKey.includeUid ||
  TunOverrideKey.excludeUid ||
  TunOverrideKey.excludeSrcPort ||
  TunOverrideKey.excludeDstPort => isLinux,
  _ => true,
};

const _maxUid = 0xFFFFFFFF;

const _maxPort = 65535;

List<TunOverrideKey> _tunOverrideKeys({
  required bool isLinux,
  required bool isWindows,
}) => [
  for (final key in TunOverrideKey.values)
    if (_isRead(key, isLinux: isLinux, isWindows: isWindows)) key,
];

typedef _TunState = OverrideState<TunOverrideKey, ProfileTun>;

_TunState _patchTun(PatchClashConfig config) =>
    (model: config.tunOverride, keys: config.tunOverrideKeys);

PatchClashConfig _setPatchTun(PatchClashConfig config, _TunState state) =>
    config.copyWith(tunOverride: state.model, tunOverrideKeys: state.keys);

_TunState _profileTun(ProfileOverrides overrides) =>
    (model: overrides.tun, keys: overrides.tunOverrideKeys);

ProfileOverrides _setProfileTun(ProfileOverrides overrides, _TunState state) =>
    overrides.copyWith(tun: state.model, tunOverrideKeys: state.keys);

String _patchTunDescription(AppLocalizations l) => l.tunOverrideDesc;

String _profileTunDescription(AppLocalizations l) => l.profileTunSettingsDesc;

OverrideSpec<TunOverrideKey, ProfileTun> appTunOverrideSpec({
  required bool isLinux,
  required bool isWindows,
}) => _TunOverrideSpec(
  const PatchOverrideTarget(
    get: _patchTun,
    set: _setPatchTun,
    description: _patchTunDescription,
  ),
  isLinux: isLinux,
  isWindows: isWindows,
);

class TunView extends OverrideView<TunOverrideKey, ProfileTun> {
  TunView(int profileId, {super.key, bool? isLinux, bool? isWindows})
    : super(
        spec: _TunOverrideSpec(
          ProfileOverrideTarget(
            profileId,
            get: _profileTun,
            set: _setProfileTun,
            description: _profileTunDescription,
          ),
          isLinux: isLinux ?? system.isLinux,
          isWindows: isWindows ?? system.isWindows,
        ),
      );
}

ListOverrideField<ProfileTun> _numbersField(
  List<int> Function(ProfileTun tun) select,
  ProfileTun Function(ProfileTun tun, List<int> value) update, {
  required ConfigLabel label,
  required int min,
  required int max,
}) {
  return ListOverrideField(
    (tun) => [for (final number in select(tun)) '$number'],
    (tun, value) =>
        update(tun, [for (final item in value) int.parse(item.trim())]),
    itemMaxLength: '$max'.length,
    itemValidator: (value, l) {
      final number = int.tryParse(value?.trim() ?? '');
      if (number == null) {
        return l.numberTip(label(l));
      }
      return number < min || number > max
          ? l.numberRangeTip(label(l), '$min', '$max')
          : null;
    },
  );
}

class _TunOverrideSpec extends OverrideSpec<TunOverrideKey, ProfileTun> {
  const _TunOverrideSpec(
    this.target, {
    required this.isLinux,
    required this.isWindows,
  });

  @override
  final OverrideTarget<TunOverrideKey, ProfileTun> target;

  final bool isLinux;
  final bool isWindows;

  @override
  String title(AppLocalizations l) => l.tun;

  @override
  List<TunOverrideKey> get values =>
      _tunOverrideKeys(isLinux: isLinux, isWindows: isWindows);

  @override
  NullStatusIllustration get illustration => NullStatusIllustration.tun;

  @override
  ProfileTun get defaults => defaultProfileTun;

  @override
  String label(TunOverrideKey key, AppLocalizations l) => key.label(l);

  @override
  ConfigLabel? description(TunOverrideKey key) => key.description;

  @override
  OverrideField<ProfileTun> fieldOf(TunOverrideKey key) => switch (key) {
    TunOverrideKey.mtu => NumberOverrideField(
      (tun) => tun.mtu,
      (tun, value) => tun.copyWith(mtu: value),
      min: minTunMtu,
      max: maxTunMtu,
    ),
    TunOverrideKey.congestionController => OptionsOverrideField(
      congestionControllers,
      (tun) => tun.congestionController,
      (tun, value) => tun.copyWith(congestionController: value),
    ),
    TunOverrideKey.strictRoute => ToggleOverrideField(
      (tun) => tun.strictRoute,
      (tun, value) => tun.copyWith(strictRoute: value),
    ),
    TunOverrideKey.routeAddress => ListOverrideField(
      (tun) => tun.routeAddress,
      (tun, value) => tun.copyWith(routeAddress: value),
      itemMaxLength: TextInputLimits.cidr,
      itemValidator: validateCidr,
    ),
    TunOverrideKey.routeExcludeAddress => ListOverrideField(
      (tun) => tun.routeExcludeAddress,
      (tun, value) => tun.copyWith(routeExcludeAddress: value),
      itemMaxLength: TextInputLimits.cidr,
      itemValidator: validateCidr,
    ),
    TunOverrideKey.dnsHijack => ListOverrideField(
      (tun) => tun.dnsHijack,
      (tun, value) => tun.copyWith(dnsHijack: value),
      itemMaxLength: TextInputLimits.dnsListen,
    ),
    TunOverrideKey.udpTimeout => NumberOverrideField(
      (tun) => tun.udpTimeout,
      (tun, value) => tun.copyWith(udpTimeout: value),
      min: 1,
    ),
    TunOverrideKey.disableIcmpForwarding => ToggleOverrideField(
      (tun) => tun.disableIcmpForwarding,
      (tun, value) => tun.copyWith(disableIcmpForwarding: value),
    ),
    TunOverrideKey.gso => ToggleOverrideField(
      (tun) => tun.gso,
      (tun, value) => tun.copyWith(gso: value),
    ),
    TunOverrideKey.includeInterface => ListOverrideField(
      (tun) => tun.includeInterface,
      (tun, value) => tun.copyWith(includeInterface: value),
      itemMaxLength: TextInputLimits.name,
    ),
    TunOverrideKey.excludeInterface => ListOverrideField(
      (tun) => tun.excludeInterface,
      (tun, value) => tun.copyWith(excludeInterface: value),
      itemMaxLength: TextInputLimits.name,
    ),
    TunOverrideKey.includeUid => _numbersField(
      (tun) => tun.includeUid,
      (tun, value) => tun.copyWith(includeUid: value),
      label: key.label,
      min: 0,
      max: _maxUid,
    ),
    TunOverrideKey.excludeUid => _numbersField(
      (tun) => tun.excludeUid,
      (tun, value) => tun.copyWith(excludeUid: value),
      label: key.label,
      min: 0,
      max: _maxUid,
    ),
    TunOverrideKey.excludeSrcPort => _numbersField(
      (tun) => tun.excludeSrcPort,
      (tun, value) => tun.copyWith(excludeSrcPort: value),
      label: key.label,
      min: 1,
      max: _maxPort,
    ),
    TunOverrideKey.excludeDstPort => _numbersField(
      (tun) => tun.excludeDstPort,
      (tun, value) => tun.copyWith(excludeDstPort: value),
      label: key.label,
      min: 1,
      max: _maxPort,
    ),
  };
}
