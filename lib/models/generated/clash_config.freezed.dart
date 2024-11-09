// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../clash_config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Tun _$TunFromJson(Map<String, dynamic> json) {
  return _Tun.fromJson(json);
}

/// @nodoc
mixin _$Tun {
  bool get enable => throw _privateConstructorUsedError;
  String get device => throw _privateConstructorUsedError;
  TunStack get stack => throw _privateConstructorUsedError;
  @JsonKey(name: "dns-hijack")
  List<String> get dnsHijack => throw _privateConstructorUsedError;

  /// Serializes this Tun to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Tun
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TunCopyWith<Tun> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TunCopyWith<$Res> {
  factory $TunCopyWith(Tun value, $Res Function(Tun) then) =
      _$TunCopyWithImpl<$Res, Tun>;
  @useResult
  $Res call(
      {bool enable,
      String device,
      TunStack stack,
      @JsonKey(name: "dns-hijack") List<String> dnsHijack});
}

/// @nodoc
class _$TunCopyWithImpl<$Res, $Val extends Tun> implements $TunCopyWith<$Res> {
  _$TunCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Tun
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? enable = null,
    Object? device = null,
    Object? stack = null,
    Object? dnsHijack = null,
  }) {
    return _then(_value.copyWith(
      enable: null == enable
          ? _value.enable
          : enable // ignore: cast_nullable_to_non_nullable
              as bool,
      device: null == device
          ? _value.device
          : device // ignore: cast_nullable_to_non_nullable
              as String,
      stack: null == stack
          ? _value.stack
          : stack // ignore: cast_nullable_to_non_nullable
              as TunStack,
      dnsHijack: null == dnsHijack
          ? _value.dnsHijack
          : dnsHijack // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TunImplCopyWith<$Res> implements $TunCopyWith<$Res> {
  factory _$$TunImplCopyWith(_$TunImpl value, $Res Function(_$TunImpl) then) =
      __$$TunImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool enable,
      String device,
      TunStack stack,
      @JsonKey(name: "dns-hijack") List<String> dnsHijack});
}

/// @nodoc
class __$$TunImplCopyWithImpl<$Res> extends _$TunCopyWithImpl<$Res, _$TunImpl>
    implements _$$TunImplCopyWith<$Res> {
  __$$TunImplCopyWithImpl(_$TunImpl _value, $Res Function(_$TunImpl) _then)
      : super(_value, _then);

  /// Create a copy of Tun
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? enable = null,
    Object? device = null,
    Object? stack = null,
    Object? dnsHijack = null,
  }) {
    return _then(_$TunImpl(
      enable: null == enable
          ? _value.enable
          : enable // ignore: cast_nullable_to_non_nullable
              as bool,
      device: null == device
          ? _value.device
          : device // ignore: cast_nullable_to_non_nullable
              as String,
      stack: null == stack
          ? _value.stack
          : stack // ignore: cast_nullable_to_non_nullable
              as TunStack,
      dnsHijack: null == dnsHijack
          ? _value._dnsHijack
          : dnsHijack // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TunImpl implements _Tun {
  const _$TunImpl(
      {this.enable = false,
      this.device = appName,
      this.stack = TunStack.gvisor,
      @JsonKey(name: "dns-hijack")
      final List<String> dnsHijack = const ["any:53"]})
      : _dnsHijack = dnsHijack;

  factory _$TunImpl.fromJson(Map<String, dynamic> json) =>
      _$$TunImplFromJson(json);

  @override
  @JsonKey()
  final bool enable;
  @override
  @JsonKey()
  final String device;
  @override
  @JsonKey()
  final TunStack stack;
  final List<String> _dnsHijack;
  @override
  @JsonKey(name: "dns-hijack")
  List<String> get dnsHijack {
    if (_dnsHijack is EqualUnmodifiableListView) return _dnsHijack;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_dnsHijack);
  }

  @override
  String toString() {
    return 'Tun(enable: $enable, device: $device, stack: $stack, dnsHijack: $dnsHijack)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TunImpl &&
            (identical(other.enable, enable) || other.enable == enable) &&
            (identical(other.device, device) || other.device == device) &&
            (identical(other.stack, stack) || other.stack == stack) &&
            const DeepCollectionEquality()
                .equals(other._dnsHijack, _dnsHijack));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, enable, device, stack,
      const DeepCollectionEquality().hash(_dnsHijack));

  /// Create a copy of Tun
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TunImplCopyWith<_$TunImpl> get copyWith =>
      __$$TunImplCopyWithImpl<_$TunImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TunImplToJson(
      this,
    );
  }
}

abstract class _Tun implements Tun {
  const factory _Tun(
      {final bool enable,
      final String device,
      final TunStack stack,
      @JsonKey(name: "dns-hijack") final List<String> dnsHijack}) = _$TunImpl;

  factory _Tun.fromJson(Map<String, dynamic> json) = _$TunImpl.fromJson;

  @override
  bool get enable;
  @override
  String get device;
  @override
  TunStack get stack;
  @override
  @JsonKey(name: "dns-hijack")
  List<String> get dnsHijack;

  /// Create a copy of Tun
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TunImplCopyWith<_$TunImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

FallbackFilter _$FallbackFilterFromJson(Map<String, dynamic> json) {
  return _FallbackFilter.fromJson(json);
}

/// @nodoc
mixin _$FallbackFilter {
  bool get geoip => throw _privateConstructorUsedError;
  @JsonKey(name: "geoip-code")
  String get geoipCode => throw _privateConstructorUsedError;
  List<String> get geosite => throw _privateConstructorUsedError;
  List<String> get ipcidr => throw _privateConstructorUsedError;
  List<String> get domain => throw _privateConstructorUsedError;

  /// Serializes this FallbackFilter to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FallbackFilter
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FallbackFilterCopyWith<FallbackFilter> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FallbackFilterCopyWith<$Res> {
  factory $FallbackFilterCopyWith(
          FallbackFilter value, $Res Function(FallbackFilter) then) =
      _$FallbackFilterCopyWithImpl<$Res, FallbackFilter>;
  @useResult
  $Res call(
      {bool geoip,
      @JsonKey(name: "geoip-code") String geoipCode,
      List<String> geosite,
      List<String> ipcidr,
      List<String> domain});
}

/// @nodoc
class _$FallbackFilterCopyWithImpl<$Res, $Val extends FallbackFilter>
    implements $FallbackFilterCopyWith<$Res> {
  _$FallbackFilterCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FallbackFilter
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? geoip = null,
    Object? geoipCode = null,
    Object? geosite = null,
    Object? ipcidr = null,
    Object? domain = null,
  }) {
    return _then(_value.copyWith(
      geoip: null == geoip
          ? _value.geoip
          : geoip // ignore: cast_nullable_to_non_nullable
              as bool,
      geoipCode: null == geoipCode
          ? _value.geoipCode
          : geoipCode // ignore: cast_nullable_to_non_nullable
              as String,
      geosite: null == geosite
          ? _value.geosite
          : geosite // ignore: cast_nullable_to_non_nullable
              as List<String>,
      ipcidr: null == ipcidr
          ? _value.ipcidr
          : ipcidr // ignore: cast_nullable_to_non_nullable
              as List<String>,
      domain: null == domain
          ? _value.domain
          : domain // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$FallbackFilterImplCopyWith<$Res>
    implements $FallbackFilterCopyWith<$Res> {
  factory _$$FallbackFilterImplCopyWith(_$FallbackFilterImpl value,
          $Res Function(_$FallbackFilterImpl) then) =
      __$$FallbackFilterImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool geoip,
      @JsonKey(name: "geoip-code") String geoipCode,
      List<String> geosite,
      List<String> ipcidr,
      List<String> domain});
}

/// @nodoc
class __$$FallbackFilterImplCopyWithImpl<$Res>
    extends _$FallbackFilterCopyWithImpl<$Res, _$FallbackFilterImpl>
    implements _$$FallbackFilterImplCopyWith<$Res> {
  __$$FallbackFilterImplCopyWithImpl(
      _$FallbackFilterImpl _value, $Res Function(_$FallbackFilterImpl) _then)
      : super(_value, _then);

  /// Create a copy of FallbackFilter
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? geoip = null,
    Object? geoipCode = null,
    Object? geosite = null,
    Object? ipcidr = null,
    Object? domain = null,
  }) {
    return _then(_$FallbackFilterImpl(
      geoip: null == geoip
          ? _value.geoip
          : geoip // ignore: cast_nullable_to_non_nullable
              as bool,
      geoipCode: null == geoipCode
          ? _value.geoipCode
          : geoipCode // ignore: cast_nullable_to_non_nullable
              as String,
      geosite: null == geosite
          ? _value._geosite
          : geosite // ignore: cast_nullable_to_non_nullable
              as List<String>,
      ipcidr: null == ipcidr
          ? _value._ipcidr
          : ipcidr // ignore: cast_nullable_to_non_nullable
              as List<String>,
      domain: null == domain
          ? _value._domain
          : domain // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$FallbackFilterImpl implements _FallbackFilter {
  const _$FallbackFilterImpl(
      {this.geoip = true,
      @JsonKey(name: "geoip-code") this.geoipCode = "CN",
      final List<String> geosite = const ["gfw"],
      final List<String> ipcidr = const ["240.0.0.0/4"],
      final List<String> domain = const [
        "+.google.com",
        "+.facebook.com",
        "+.youtube.com"
      ]})
      : _geosite = geosite,
        _ipcidr = ipcidr,
        _domain = domain;

  factory _$FallbackFilterImpl.fromJson(Map<String, dynamic> json) =>
      _$$FallbackFilterImplFromJson(json);

  @override
  @JsonKey()
  final bool geoip;
  @override
  @JsonKey(name: "geoip-code")
  final String geoipCode;
  final List<String> _geosite;
  @override
  @JsonKey()
  List<String> get geosite {
    if (_geosite is EqualUnmodifiableListView) return _geosite;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_geosite);
  }

  final List<String> _ipcidr;
  @override
  @JsonKey()
  List<String> get ipcidr {
    if (_ipcidr is EqualUnmodifiableListView) return _ipcidr;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_ipcidr);
  }

  final List<String> _domain;
  @override
  @JsonKey()
  List<String> get domain {
    if (_domain is EqualUnmodifiableListView) return _domain;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_domain);
  }

  @override
  String toString() {
    return 'FallbackFilter(geoip: $geoip, geoipCode: $geoipCode, geosite: $geosite, ipcidr: $ipcidr, domain: $domain)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FallbackFilterImpl &&
            (identical(other.geoip, geoip) || other.geoip == geoip) &&
            (identical(other.geoipCode, geoipCode) ||
                other.geoipCode == geoipCode) &&
            const DeepCollectionEquality().equals(other._geosite, _geosite) &&
            const DeepCollectionEquality().equals(other._ipcidr, _ipcidr) &&
            const DeepCollectionEquality().equals(other._domain, _domain));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      geoip,
      geoipCode,
      const DeepCollectionEquality().hash(_geosite),
      const DeepCollectionEquality().hash(_ipcidr),
      const DeepCollectionEquality().hash(_domain));

  /// Create a copy of FallbackFilter
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FallbackFilterImplCopyWith<_$FallbackFilterImpl> get copyWith =>
      __$$FallbackFilterImplCopyWithImpl<_$FallbackFilterImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FallbackFilterImplToJson(
      this,
    );
  }
}

abstract class _FallbackFilter implements FallbackFilter {
  const factory _FallbackFilter(
      {final bool geoip,
      @JsonKey(name: "geoip-code") final String geoipCode,
      final List<String> geosite,
      final List<String> ipcidr,
      final List<String> domain}) = _$FallbackFilterImpl;

  factory _FallbackFilter.fromJson(Map<String, dynamic> json) =
      _$FallbackFilterImpl.fromJson;

  @override
  bool get geoip;
  @override
  @JsonKey(name: "geoip-code")
  String get geoipCode;
  @override
  List<String> get geosite;
  @override
  List<String> get ipcidr;
  @override
  List<String> get domain;

  /// Create a copy of FallbackFilter
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FallbackFilterImplCopyWith<_$FallbackFilterImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Dns _$DnsFromJson(Map<String, dynamic> json) {
  return _Dns.fromJson(json);
}

/// @nodoc
mixin _$Dns {
  bool get enable => throw _privateConstructorUsedError;
  @JsonKey(name: "prefer-h3")
  bool get preferH3 => throw _privateConstructorUsedError;
  @JsonKey(name: "use-hosts")
  bool get useHosts => throw _privateConstructorUsedError;
  @JsonKey(name: "use-system-hosts")
  bool get useSystemHosts => throw _privateConstructorUsedError;
  @JsonKey(name: "respect-rules")
  bool get respectRules => throw _privateConstructorUsedError;
  bool get ipv6 => throw _privateConstructorUsedError;
  @JsonKey(name: "default-nameserver")
  List<String> get defaultNameserver => throw _privateConstructorUsedError;
  @JsonKey(name: "enhanced-mode")
  DnsMode get enhancedMode => throw _privateConstructorUsedError;
  @JsonKey(name: "fake-ip-range")
  String get fakeIpRange => throw _privateConstructorUsedError;
  @JsonKey(name: "fake-ip-filter")
  List<String> get fakeIpFilter => throw _privateConstructorUsedError;
  @JsonKey(name: "nameserver-policy")
  Map<String, String> get nameserverPolicy =>
      throw _privateConstructorUsedError;
  List<String> get nameserver => throw _privateConstructorUsedError;
  List<String> get fallback => throw _privateConstructorUsedError;
  @JsonKey(name: "proxy-server-nameserver")
  List<String> get proxyServerNameserver => throw _privateConstructorUsedError;
  @JsonKey(name: "fallback-filter")
  FallbackFilter get fallbackFilter => throw _privateConstructorUsedError;

  /// Serializes this Dns to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Dns
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DnsCopyWith<Dns> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DnsCopyWith<$Res> {
  factory $DnsCopyWith(Dns value, $Res Function(Dns) then) =
      _$DnsCopyWithImpl<$Res, Dns>;
  @useResult
  $Res call(
      {bool enable,
      @JsonKey(name: "prefer-h3") bool preferH3,
      @JsonKey(name: "use-hosts") bool useHosts,
      @JsonKey(name: "use-system-hosts") bool useSystemHosts,
      @JsonKey(name: "respect-rules") bool respectRules,
      bool ipv6,
      @JsonKey(name: "default-nameserver") List<String> defaultNameserver,
      @JsonKey(name: "enhanced-mode") DnsMode enhancedMode,
      @JsonKey(name: "fake-ip-range") String fakeIpRange,
      @JsonKey(name: "fake-ip-filter") List<String> fakeIpFilter,
      @JsonKey(name: "nameserver-policy") Map<String, String> nameserverPolicy,
      List<String> nameserver,
      List<String> fallback,
      @JsonKey(name: "proxy-server-nameserver")
      List<String> proxyServerNameserver,
      @JsonKey(name: "fallback-filter") FallbackFilter fallbackFilter});

  $FallbackFilterCopyWith<$Res> get fallbackFilter;
}

/// @nodoc
class _$DnsCopyWithImpl<$Res, $Val extends Dns> implements $DnsCopyWith<$Res> {
  _$DnsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Dns
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? enable = null,
    Object? preferH3 = null,
    Object? useHosts = null,
    Object? useSystemHosts = null,
    Object? respectRules = null,
    Object? ipv6 = null,
    Object? defaultNameserver = null,
    Object? enhancedMode = null,
    Object? fakeIpRange = null,
    Object? fakeIpFilter = null,
    Object? nameserverPolicy = null,
    Object? nameserver = null,
    Object? fallback = null,
    Object? proxyServerNameserver = null,
    Object? fallbackFilter = null,
  }) {
    return _then(_value.copyWith(
      enable: null == enable
          ? _value.enable
          : enable // ignore: cast_nullable_to_non_nullable
              as bool,
      preferH3: null == preferH3
          ? _value.preferH3
          : preferH3 // ignore: cast_nullable_to_non_nullable
              as bool,
      useHosts: null == useHosts
          ? _value.useHosts
          : useHosts // ignore: cast_nullable_to_non_nullable
              as bool,
      useSystemHosts: null == useSystemHosts
          ? _value.useSystemHosts
          : useSystemHosts // ignore: cast_nullable_to_non_nullable
              as bool,
      respectRules: null == respectRules
          ? _value.respectRules
          : respectRules // ignore: cast_nullable_to_non_nullable
              as bool,
      ipv6: null == ipv6
          ? _value.ipv6
          : ipv6 // ignore: cast_nullable_to_non_nullable
              as bool,
      defaultNameserver: null == defaultNameserver
          ? _value.defaultNameserver
          : defaultNameserver // ignore: cast_nullable_to_non_nullable
              as List<String>,
      enhancedMode: null == enhancedMode
          ? _value.enhancedMode
          : enhancedMode // ignore: cast_nullable_to_non_nullable
              as DnsMode,
      fakeIpRange: null == fakeIpRange
          ? _value.fakeIpRange
          : fakeIpRange // ignore: cast_nullable_to_non_nullable
              as String,
      fakeIpFilter: null == fakeIpFilter
          ? _value.fakeIpFilter
          : fakeIpFilter // ignore: cast_nullable_to_non_nullable
              as List<String>,
      nameserverPolicy: null == nameserverPolicy
          ? _value.nameserverPolicy
          : nameserverPolicy // ignore: cast_nullable_to_non_nullable
              as Map<String, String>,
      nameserver: null == nameserver
          ? _value.nameserver
          : nameserver // ignore: cast_nullable_to_non_nullable
              as List<String>,
      fallback: null == fallback
          ? _value.fallback
          : fallback // ignore: cast_nullable_to_non_nullable
              as List<String>,
      proxyServerNameserver: null == proxyServerNameserver
          ? _value.proxyServerNameserver
          : proxyServerNameserver // ignore: cast_nullable_to_non_nullable
              as List<String>,
      fallbackFilter: null == fallbackFilter
          ? _value.fallbackFilter
          : fallbackFilter // ignore: cast_nullable_to_non_nullable
              as FallbackFilter,
    ) as $Val);
  }

  /// Create a copy of Dns
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $FallbackFilterCopyWith<$Res> get fallbackFilter {
    return $FallbackFilterCopyWith<$Res>(_value.fallbackFilter, (value) {
      return _then(_value.copyWith(fallbackFilter: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$DnsImplCopyWith<$Res> implements $DnsCopyWith<$Res> {
  factory _$$DnsImplCopyWith(_$DnsImpl value, $Res Function(_$DnsImpl) then) =
      __$$DnsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool enable,
      @JsonKey(name: "prefer-h3") bool preferH3,
      @JsonKey(name: "use-hosts") bool useHosts,
      @JsonKey(name: "use-system-hosts") bool useSystemHosts,
      @JsonKey(name: "respect-rules") bool respectRules,
      bool ipv6,
      @JsonKey(name: "default-nameserver") List<String> defaultNameserver,
      @JsonKey(name: "enhanced-mode") DnsMode enhancedMode,
      @JsonKey(name: "fake-ip-range") String fakeIpRange,
      @JsonKey(name: "fake-ip-filter") List<String> fakeIpFilter,
      @JsonKey(name: "nameserver-policy") Map<String, String> nameserverPolicy,
      List<String> nameserver,
      List<String> fallback,
      @JsonKey(name: "proxy-server-nameserver")
      List<String> proxyServerNameserver,
      @JsonKey(name: "fallback-filter") FallbackFilter fallbackFilter});

  @override
  $FallbackFilterCopyWith<$Res> get fallbackFilter;
}

/// @nodoc
class __$$DnsImplCopyWithImpl<$Res> extends _$DnsCopyWithImpl<$Res, _$DnsImpl>
    implements _$$DnsImplCopyWith<$Res> {
  __$$DnsImplCopyWithImpl(_$DnsImpl _value, $Res Function(_$DnsImpl) _then)
      : super(_value, _then);

  /// Create a copy of Dns
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? enable = null,
    Object? preferH3 = null,
    Object? useHosts = null,
    Object? useSystemHosts = null,
    Object? respectRules = null,
    Object? ipv6 = null,
    Object? defaultNameserver = null,
    Object? enhancedMode = null,
    Object? fakeIpRange = null,
    Object? fakeIpFilter = null,
    Object? nameserverPolicy = null,
    Object? nameserver = null,
    Object? fallback = null,
    Object? proxyServerNameserver = null,
    Object? fallbackFilter = null,
  }) {
    return _then(_$DnsImpl(
      enable: null == enable
          ? _value.enable
          : enable // ignore: cast_nullable_to_non_nullable
              as bool,
      preferH3: null == preferH3
          ? _value.preferH3
          : preferH3 // ignore: cast_nullable_to_non_nullable
              as bool,
      useHosts: null == useHosts
          ? _value.useHosts
          : useHosts // ignore: cast_nullable_to_non_nullable
              as bool,
      useSystemHosts: null == useSystemHosts
          ? _value.useSystemHosts
          : useSystemHosts // ignore: cast_nullable_to_non_nullable
              as bool,
      respectRules: null == respectRules
          ? _value.respectRules
          : respectRules // ignore: cast_nullable_to_non_nullable
              as bool,
      ipv6: null == ipv6
          ? _value.ipv6
          : ipv6 // ignore: cast_nullable_to_non_nullable
              as bool,
      defaultNameserver: null == defaultNameserver
          ? _value._defaultNameserver
          : defaultNameserver // ignore: cast_nullable_to_non_nullable
              as List<String>,
      enhancedMode: null == enhancedMode
          ? _value.enhancedMode
          : enhancedMode // ignore: cast_nullable_to_non_nullable
              as DnsMode,
      fakeIpRange: null == fakeIpRange
          ? _value.fakeIpRange
          : fakeIpRange // ignore: cast_nullable_to_non_nullable
              as String,
      fakeIpFilter: null == fakeIpFilter
          ? _value._fakeIpFilter
          : fakeIpFilter // ignore: cast_nullable_to_non_nullable
              as List<String>,
      nameserverPolicy: null == nameserverPolicy
          ? _value._nameserverPolicy
          : nameserverPolicy // ignore: cast_nullable_to_non_nullable
              as Map<String, String>,
      nameserver: null == nameserver
          ? _value._nameserver
          : nameserver // ignore: cast_nullable_to_non_nullable
              as List<String>,
      fallback: null == fallback
          ? _value._fallback
          : fallback // ignore: cast_nullable_to_non_nullable
              as List<String>,
      proxyServerNameserver: null == proxyServerNameserver
          ? _value._proxyServerNameserver
          : proxyServerNameserver // ignore: cast_nullable_to_non_nullable
              as List<String>,
      fallbackFilter: null == fallbackFilter
          ? _value.fallbackFilter
          : fallbackFilter // ignore: cast_nullable_to_non_nullable
              as FallbackFilter,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DnsImpl implements _Dns {
  const _$DnsImpl(
      {this.enable = true,
      @JsonKey(name: "prefer-h3") this.preferH3 = false,
      @JsonKey(name: "use-hosts") this.useHosts = true,
      @JsonKey(name: "use-system-hosts") this.useSystemHosts = true,
      @JsonKey(name: "respect-rules") this.respectRules = false,
      this.ipv6 = false,
      @JsonKey(name: "default-nameserver")
      final List<String> defaultNameserver = const ["223.5.5.5"],
      @JsonKey(name: "enhanced-mode") this.enhancedMode = DnsMode.fakeIp,
      @JsonKey(name: "fake-ip-range") this.fakeIpRange = "198.18.0.1/16",
      @JsonKey(name: "fake-ip-filter") final List<String> fakeIpFilter = const [
        "*.lan",
        "localhost.ptlogin2.qq.com"
      ],
      @JsonKey(name: "nameserver-policy")
      final Map<String, String> nameserverPolicy = const {
        "www.baidu.com": "114.114.114.114",
        "+.internal.crop.com": "10.0.0.1",
        "geosite:cn": "https://doh.pub/dns-query"
      },
      final List<String> nameserver = const [
        "https://doh.pub/dns-query",
        "https://dns.alidns.com/dns-query"
      ],
      final List<String> fallback = const ["tls://8.8.4.4", "tls://1.1.1.1"],
      @JsonKey(name: "proxy-server-nameserver")
      final List<String> proxyServerNameserver = const [
        "https://doh.pub/dns-query"
      ],
      @JsonKey(name: "fallback-filter")
      this.fallbackFilter = const FallbackFilter()})
      : _defaultNameserver = defaultNameserver,
        _fakeIpFilter = fakeIpFilter,
        _nameserverPolicy = nameserverPolicy,
        _nameserver = nameserver,
        _fallback = fallback,
        _proxyServerNameserver = proxyServerNameserver;

  factory _$DnsImpl.fromJson(Map<String, dynamic> json) =>
      _$$DnsImplFromJson(json);

  @override
  @JsonKey()
  final bool enable;
  @override
  @JsonKey(name: "prefer-h3")
  final bool preferH3;
  @override
  @JsonKey(name: "use-hosts")
  final bool useHosts;
  @override
  @JsonKey(name: "use-system-hosts")
  final bool useSystemHosts;
  @override
  @JsonKey(name: "respect-rules")
  final bool respectRules;
  @override
  @JsonKey()
  final bool ipv6;
  final List<String> _defaultNameserver;
  @override
  @JsonKey(name: "default-nameserver")
  List<String> get defaultNameserver {
    if (_defaultNameserver is EqualUnmodifiableListView)
      return _defaultNameserver;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_defaultNameserver);
  }

  @override
  @JsonKey(name: "enhanced-mode")
  final DnsMode enhancedMode;
  @override
  @JsonKey(name: "fake-ip-range")
  final String fakeIpRange;
  final List<String> _fakeIpFilter;
  @override
  @JsonKey(name: "fake-ip-filter")
  List<String> get fakeIpFilter {
    if (_fakeIpFilter is EqualUnmodifiableListView) return _fakeIpFilter;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_fakeIpFilter);
  }

  final Map<String, String> _nameserverPolicy;
  @override
  @JsonKey(name: "nameserver-policy")
  Map<String, String> get nameserverPolicy {
    if (_nameserverPolicy is EqualUnmodifiableMapView) return _nameserverPolicy;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_nameserverPolicy);
  }

  final List<String> _nameserver;
  @override
  @JsonKey()
  List<String> get nameserver {
    if (_nameserver is EqualUnmodifiableListView) return _nameserver;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_nameserver);
  }

  final List<String> _fallback;
  @override
  @JsonKey()
  List<String> get fallback {
    if (_fallback is EqualUnmodifiableListView) return _fallback;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_fallback);
  }

  final List<String> _proxyServerNameserver;
  @override
  @JsonKey(name: "proxy-server-nameserver")
  List<String> get proxyServerNameserver {
    if (_proxyServerNameserver is EqualUnmodifiableListView)
      return _proxyServerNameserver;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_proxyServerNameserver);
  }

  @override
  @JsonKey(name: "fallback-filter")
  final FallbackFilter fallbackFilter;

  @override
  String toString() {
    return 'Dns(enable: $enable, preferH3: $preferH3, useHosts: $useHosts, useSystemHosts: $useSystemHosts, respectRules: $respectRules, ipv6: $ipv6, defaultNameserver: $defaultNameserver, enhancedMode: $enhancedMode, fakeIpRange: $fakeIpRange, fakeIpFilter: $fakeIpFilter, nameserverPolicy: $nameserverPolicy, nameserver: $nameserver, fallback: $fallback, proxyServerNameserver: $proxyServerNameserver, fallbackFilter: $fallbackFilter)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DnsImpl &&
            (identical(other.enable, enable) || other.enable == enable) &&
            (identical(other.preferH3, preferH3) ||
                other.preferH3 == preferH3) &&
            (identical(other.useHosts, useHosts) ||
                other.useHosts == useHosts) &&
            (identical(other.useSystemHosts, useSystemHosts) ||
                other.useSystemHosts == useSystemHosts) &&
            (identical(other.respectRules, respectRules) ||
                other.respectRules == respectRules) &&
            (identical(other.ipv6, ipv6) || other.ipv6 == ipv6) &&
            const DeepCollectionEquality()
                .equals(other._defaultNameserver, _defaultNameserver) &&
            (identical(other.enhancedMode, enhancedMode) ||
                other.enhancedMode == enhancedMode) &&
            (identical(other.fakeIpRange, fakeIpRange) ||
                other.fakeIpRange == fakeIpRange) &&
            const DeepCollectionEquality()
                .equals(other._fakeIpFilter, _fakeIpFilter) &&
            const DeepCollectionEquality()
                .equals(other._nameserverPolicy, _nameserverPolicy) &&
            const DeepCollectionEquality()
                .equals(other._nameserver, _nameserver) &&
            const DeepCollectionEquality().equals(other._fallback, _fallback) &&
            const DeepCollectionEquality()
                .equals(other._proxyServerNameserver, _proxyServerNameserver) &&
            (identical(other.fallbackFilter, fallbackFilter) ||
                other.fallbackFilter == fallbackFilter));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      enable,
      preferH3,
      useHosts,
      useSystemHosts,
      respectRules,
      ipv6,
      const DeepCollectionEquality().hash(_defaultNameserver),
      enhancedMode,
      fakeIpRange,
      const DeepCollectionEquality().hash(_fakeIpFilter),
      const DeepCollectionEquality().hash(_nameserverPolicy),
      const DeepCollectionEquality().hash(_nameserver),
      const DeepCollectionEquality().hash(_fallback),
      const DeepCollectionEquality().hash(_proxyServerNameserver),
      fallbackFilter);

  /// Create a copy of Dns
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DnsImplCopyWith<_$DnsImpl> get copyWith =>
      __$$DnsImplCopyWithImpl<_$DnsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DnsImplToJson(
      this,
    );
  }
}

abstract class _Dns implements Dns {
  const factory _Dns(
      {final bool enable,
      @JsonKey(name: "prefer-h3") final bool preferH3,
      @JsonKey(name: "use-hosts") final bool useHosts,
      @JsonKey(name: "use-system-hosts") final bool useSystemHosts,
      @JsonKey(name: "respect-rules") final bool respectRules,
      final bool ipv6,
      @JsonKey(name: "default-nameserver") final List<String> defaultNameserver,
      @JsonKey(name: "enhanced-mode") final DnsMode enhancedMode,
      @JsonKey(name: "fake-ip-range") final String fakeIpRange,
      @JsonKey(name: "fake-ip-filter") final List<String> fakeIpFilter,
      @JsonKey(name: "nameserver-policy")
      final Map<String, String> nameserverPolicy,
      final List<String> nameserver,
      final List<String> fallback,
      @JsonKey(name: "proxy-server-nameserver")
      final List<String> proxyServerNameserver,
      @JsonKey(name: "fallback-filter")
      final FallbackFilter fallbackFilter}) = _$DnsImpl;

  factory _Dns.fromJson(Map<String, dynamic> json) = _$DnsImpl.fromJson;

  @override
  bool get enable;
  @override
  @JsonKey(name: "prefer-h3")
  bool get preferH3;
  @override
  @JsonKey(name: "use-hosts")
  bool get useHosts;
  @override
  @JsonKey(name: "use-system-hosts")
  bool get useSystemHosts;
  @override
  @JsonKey(name: "respect-rules")
  bool get respectRules;
  @override
  bool get ipv6;
  @override
  @JsonKey(name: "default-nameserver")
  List<String> get defaultNameserver;
  @override
  @JsonKey(name: "enhanced-mode")
  DnsMode get enhancedMode;
  @override
  @JsonKey(name: "fake-ip-range")
  String get fakeIpRange;
  @override
  @JsonKey(name: "fake-ip-filter")
  List<String> get fakeIpFilter;
  @override
  @JsonKey(name: "nameserver-policy")
  Map<String, String> get nameserverPolicy;
  @override
  List<String> get nameserver;
  @override
  List<String> get fallback;
  @override
  @JsonKey(name: "proxy-server-nameserver")
  List<String> get proxyServerNameserver;
  @override
  @JsonKey(name: "fallback-filter")
  FallbackFilter get fallbackFilter;

  /// Create a copy of Dns
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DnsImplCopyWith<_$DnsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
