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

ProxyGroup _$ProxyGroupFromJson(Map<String, dynamic> json) {
  return _ProxyGroup.fromJson(json);
}

/// @nodoc
mixin _$ProxyGroup {
  String get name => throw _privateConstructorUsedError;
  @JsonKey(fromJson: GroupType.parseProfileType)
  GroupType get type => throw _privateConstructorUsedError;
  List<String>? get proxies => throw _privateConstructorUsedError;
  List<String>? get use => throw _privateConstructorUsedError;
  int? get interval => throw _privateConstructorUsedError;
  bool? get lazy => throw _privateConstructorUsedError;
  String? get url => throw _privateConstructorUsedError;
  int? get timeout => throw _privateConstructorUsedError;
  @JsonKey(name: "max-failed-times")
  int? get maxFailedTimes => throw _privateConstructorUsedError;
  String? get filter => throw _privateConstructorUsedError;
  @JsonKey(name: "expected-filter")
  String? get excludeFilter => throw _privateConstructorUsedError;
  @JsonKey(name: "exclude-type")
  String? get excludeType => throw _privateConstructorUsedError;
  @JsonKey(name: "expected-status")
  int? get expectedStatus => throw _privateConstructorUsedError;
  bool? get hidden => throw _privateConstructorUsedError;
  String? get icon => throw _privateConstructorUsedError;

  /// Serializes this ProxyGroup to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ProxyGroup
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProxyGroupCopyWith<ProxyGroup> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProxyGroupCopyWith<$Res> {
  factory $ProxyGroupCopyWith(
          ProxyGroup value, $Res Function(ProxyGroup) then) =
      _$ProxyGroupCopyWithImpl<$Res, ProxyGroup>;
  @useResult
  $Res call(
      {String name,
      @JsonKey(fromJson: GroupType.parseProfileType) GroupType type,
      List<String>? proxies,
      List<String>? use,
      int? interval,
      bool? lazy,
      String? url,
      int? timeout,
      @JsonKey(name: "max-failed-times") int? maxFailedTimes,
      String? filter,
      @JsonKey(name: "expected-filter") String? excludeFilter,
      @JsonKey(name: "exclude-type") String? excludeType,
      @JsonKey(name: "expected-status") int? expectedStatus,
      bool? hidden,
      String? icon});
}

/// @nodoc
class _$ProxyGroupCopyWithImpl<$Res, $Val extends ProxyGroup>
    implements $ProxyGroupCopyWith<$Res> {
  _$ProxyGroupCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProxyGroup
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? type = null,
    Object? proxies = freezed,
    Object? use = freezed,
    Object? interval = freezed,
    Object? lazy = freezed,
    Object? url = freezed,
    Object? timeout = freezed,
    Object? maxFailedTimes = freezed,
    Object? filter = freezed,
    Object? excludeFilter = freezed,
    Object? excludeType = freezed,
    Object? expectedStatus = freezed,
    Object? hidden = freezed,
    Object? icon = freezed,
  }) {
    return _then(_value.copyWith(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as GroupType,
      proxies: freezed == proxies
          ? _value.proxies
          : proxies // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      use: freezed == use
          ? _value.use
          : use // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      interval: freezed == interval
          ? _value.interval
          : interval // ignore: cast_nullable_to_non_nullable
              as int?,
      lazy: freezed == lazy
          ? _value.lazy
          : lazy // ignore: cast_nullable_to_non_nullable
              as bool?,
      url: freezed == url
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as String?,
      timeout: freezed == timeout
          ? _value.timeout
          : timeout // ignore: cast_nullable_to_non_nullable
              as int?,
      maxFailedTimes: freezed == maxFailedTimes
          ? _value.maxFailedTimes
          : maxFailedTimes // ignore: cast_nullable_to_non_nullable
              as int?,
      filter: freezed == filter
          ? _value.filter
          : filter // ignore: cast_nullable_to_non_nullable
              as String?,
      excludeFilter: freezed == excludeFilter
          ? _value.excludeFilter
          : excludeFilter // ignore: cast_nullable_to_non_nullable
              as String?,
      excludeType: freezed == excludeType
          ? _value.excludeType
          : excludeType // ignore: cast_nullable_to_non_nullable
              as String?,
      expectedStatus: freezed == expectedStatus
          ? _value.expectedStatus
          : expectedStatus // ignore: cast_nullable_to_non_nullable
              as int?,
      hidden: freezed == hidden
          ? _value.hidden
          : hidden // ignore: cast_nullable_to_non_nullable
              as bool?,
      icon: freezed == icon
          ? _value.icon
          : icon // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ProxyGroupImplCopyWith<$Res>
    implements $ProxyGroupCopyWith<$Res> {
  factory _$$ProxyGroupImplCopyWith(
          _$ProxyGroupImpl value, $Res Function(_$ProxyGroupImpl) then) =
      __$$ProxyGroupImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String name,
      @JsonKey(fromJson: GroupType.parseProfileType) GroupType type,
      List<String>? proxies,
      List<String>? use,
      int? interval,
      bool? lazy,
      String? url,
      int? timeout,
      @JsonKey(name: "max-failed-times") int? maxFailedTimes,
      String? filter,
      @JsonKey(name: "expected-filter") String? excludeFilter,
      @JsonKey(name: "exclude-type") String? excludeType,
      @JsonKey(name: "expected-status") int? expectedStatus,
      bool? hidden,
      String? icon});
}

/// @nodoc
class __$$ProxyGroupImplCopyWithImpl<$Res>
    extends _$ProxyGroupCopyWithImpl<$Res, _$ProxyGroupImpl>
    implements _$$ProxyGroupImplCopyWith<$Res> {
  __$$ProxyGroupImplCopyWithImpl(
      _$ProxyGroupImpl _value, $Res Function(_$ProxyGroupImpl) _then)
      : super(_value, _then);

  /// Create a copy of ProxyGroup
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? type = null,
    Object? proxies = freezed,
    Object? use = freezed,
    Object? interval = freezed,
    Object? lazy = freezed,
    Object? url = freezed,
    Object? timeout = freezed,
    Object? maxFailedTimes = freezed,
    Object? filter = freezed,
    Object? excludeFilter = freezed,
    Object? excludeType = freezed,
    Object? expectedStatus = freezed,
    Object? hidden = freezed,
    Object? icon = freezed,
  }) {
    return _then(_$ProxyGroupImpl(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as GroupType,
      proxies: freezed == proxies
          ? _value._proxies
          : proxies // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      use: freezed == use
          ? _value._use
          : use // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      interval: freezed == interval
          ? _value.interval
          : interval // ignore: cast_nullable_to_non_nullable
              as int?,
      lazy: freezed == lazy
          ? _value.lazy
          : lazy // ignore: cast_nullable_to_non_nullable
              as bool?,
      url: freezed == url
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as String?,
      timeout: freezed == timeout
          ? _value.timeout
          : timeout // ignore: cast_nullable_to_non_nullable
              as int?,
      maxFailedTimes: freezed == maxFailedTimes
          ? _value.maxFailedTimes
          : maxFailedTimes // ignore: cast_nullable_to_non_nullable
              as int?,
      filter: freezed == filter
          ? _value.filter
          : filter // ignore: cast_nullable_to_non_nullable
              as String?,
      excludeFilter: freezed == excludeFilter
          ? _value.excludeFilter
          : excludeFilter // ignore: cast_nullable_to_non_nullable
              as String?,
      excludeType: freezed == excludeType
          ? _value.excludeType
          : excludeType // ignore: cast_nullable_to_non_nullable
              as String?,
      expectedStatus: freezed == expectedStatus
          ? _value.expectedStatus
          : expectedStatus // ignore: cast_nullable_to_non_nullable
              as int?,
      hidden: freezed == hidden
          ? _value.hidden
          : hidden // ignore: cast_nullable_to_non_nullable
              as bool?,
      icon: freezed == icon
          ? _value.icon
          : icon // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ProxyGroupImpl implements _ProxyGroup {
  const _$ProxyGroupImpl(
      {required this.name,
      @JsonKey(fromJson: GroupType.parseProfileType) required this.type,
      final List<String>? proxies,
      final List<String>? use,
      this.interval,
      this.lazy,
      this.url,
      this.timeout,
      @JsonKey(name: "max-failed-times") this.maxFailedTimes,
      this.filter,
      @JsonKey(name: "expected-filter") this.excludeFilter,
      @JsonKey(name: "exclude-type") this.excludeType,
      @JsonKey(name: "expected-status") this.expectedStatus,
      this.hidden,
      this.icon})
      : _proxies = proxies,
        _use = use;

  factory _$ProxyGroupImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProxyGroupImplFromJson(json);

  @override
  final String name;
  @override
  @JsonKey(fromJson: GroupType.parseProfileType)
  final GroupType type;
  final List<String>? _proxies;
  @override
  List<String>? get proxies {
    final value = _proxies;
    if (value == null) return null;
    if (_proxies is EqualUnmodifiableListView) return _proxies;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<String>? _use;
  @override
  List<String>? get use {
    final value = _use;
    if (value == null) return null;
    if (_use is EqualUnmodifiableListView) return _use;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final int? interval;
  @override
  final bool? lazy;
  @override
  final String? url;
  @override
  final int? timeout;
  @override
  @JsonKey(name: "max-failed-times")
  final int? maxFailedTimes;
  @override
  final String? filter;
  @override
  @JsonKey(name: "expected-filter")
  final String? excludeFilter;
  @override
  @JsonKey(name: "exclude-type")
  final String? excludeType;
  @override
  @JsonKey(name: "expected-status")
  final int? expectedStatus;
  @override
  final bool? hidden;
  @override
  final String? icon;

  @override
  String toString() {
    return 'ProxyGroup(name: $name, type: $type, proxies: $proxies, use: $use, interval: $interval, lazy: $lazy, url: $url, timeout: $timeout, maxFailedTimes: $maxFailedTimes, filter: $filter, excludeFilter: $excludeFilter, excludeType: $excludeType, expectedStatus: $expectedStatus, hidden: $hidden, icon: $icon)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProxyGroupImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.type, type) || other.type == type) &&
            const DeepCollectionEquality().equals(other._proxies, _proxies) &&
            const DeepCollectionEquality().equals(other._use, _use) &&
            (identical(other.interval, interval) ||
                other.interval == interval) &&
            (identical(other.lazy, lazy) || other.lazy == lazy) &&
            (identical(other.url, url) || other.url == url) &&
            (identical(other.timeout, timeout) || other.timeout == timeout) &&
            (identical(other.maxFailedTimes, maxFailedTimes) ||
                other.maxFailedTimes == maxFailedTimes) &&
            (identical(other.filter, filter) || other.filter == filter) &&
            (identical(other.excludeFilter, excludeFilter) ||
                other.excludeFilter == excludeFilter) &&
            (identical(other.excludeType, excludeType) ||
                other.excludeType == excludeType) &&
            (identical(other.expectedStatus, expectedStatus) ||
                other.expectedStatus == expectedStatus) &&
            (identical(other.hidden, hidden) || other.hidden == hidden) &&
            (identical(other.icon, icon) || other.icon == icon));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      name,
      type,
      const DeepCollectionEquality().hash(_proxies),
      const DeepCollectionEquality().hash(_use),
      interval,
      lazy,
      url,
      timeout,
      maxFailedTimes,
      filter,
      excludeFilter,
      excludeType,
      expectedStatus,
      hidden,
      icon);

  /// Create a copy of ProxyGroup
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProxyGroupImplCopyWith<_$ProxyGroupImpl> get copyWith =>
      __$$ProxyGroupImplCopyWithImpl<_$ProxyGroupImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ProxyGroupImplToJson(
      this,
    );
  }
}

abstract class _ProxyGroup implements ProxyGroup {
  const factory _ProxyGroup(
      {required final String name,
      @JsonKey(fromJson: GroupType.parseProfileType)
      required final GroupType type,
      final List<String>? proxies,
      final List<String>? use,
      final int? interval,
      final bool? lazy,
      final String? url,
      final int? timeout,
      @JsonKey(name: "max-failed-times") final int? maxFailedTimes,
      final String? filter,
      @JsonKey(name: "expected-filter") final String? excludeFilter,
      @JsonKey(name: "exclude-type") final String? excludeType,
      @JsonKey(name: "expected-status") final int? expectedStatus,
      final bool? hidden,
      final String? icon}) = _$ProxyGroupImpl;

  factory _ProxyGroup.fromJson(Map<String, dynamic> json) =
      _$ProxyGroupImpl.fromJson;

  @override
  String get name;
  @override
  @JsonKey(fromJson: GroupType.parseProfileType)
  GroupType get type;
  @override
  List<String>? get proxies;
  @override
  List<String>? get use;
  @override
  int? get interval;
  @override
  bool? get lazy;
  @override
  String? get url;
  @override
  int? get timeout;
  @override
  @JsonKey(name: "max-failed-times")
  int? get maxFailedTimes;
  @override
  String? get filter;
  @override
  @JsonKey(name: "expected-filter")
  String? get excludeFilter;
  @override
  @JsonKey(name: "exclude-type")
  String? get excludeType;
  @override
  @JsonKey(name: "expected-status")
  int? get expectedStatus;
  @override
  bool? get hidden;
  @override
  String? get icon;

  /// Create a copy of ProxyGroup
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProxyGroupImplCopyWith<_$ProxyGroupImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

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
  @JsonKey(name: "route-address")
  List<String> get routeAddress => throw _privateConstructorUsedError;

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
      @JsonKey(name: "dns-hijack") List<String> dnsHijack,
      @JsonKey(name: "route-address") List<String> routeAddress});
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
    Object? routeAddress = null,
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
      routeAddress: null == routeAddress
          ? _value.routeAddress
          : routeAddress // ignore: cast_nullable_to_non_nullable
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
      @JsonKey(name: "dns-hijack") List<String> dnsHijack,
      @JsonKey(name: "route-address") List<String> routeAddress});
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
    Object? routeAddress = null,
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
      routeAddress: null == routeAddress
          ? _value._routeAddress
          : routeAddress // ignore: cast_nullable_to_non_nullable
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
      final List<String> dnsHijack = const ["any:53"],
      @JsonKey(name: "route-address")
      final List<String> routeAddress = const []})
      : _dnsHijack = dnsHijack,
        _routeAddress = routeAddress;

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

  final List<String> _routeAddress;
  @override
  @JsonKey(name: "route-address")
  List<String> get routeAddress {
    if (_routeAddress is EqualUnmodifiableListView) return _routeAddress;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_routeAddress);
  }

  @override
  String toString() {
    return 'Tun(enable: $enable, device: $device, stack: $stack, dnsHijack: $dnsHijack, routeAddress: $routeAddress)';
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
                .equals(other._dnsHijack, _dnsHijack) &&
            const DeepCollectionEquality()
                .equals(other._routeAddress, _routeAddress));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      enable,
      device,
      stack,
      const DeepCollectionEquality().hash(_dnsHijack),
      const DeepCollectionEquality().hash(_routeAddress));

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
          @JsonKey(name: "dns-hijack") final List<String> dnsHijack,
          @JsonKey(name: "route-address") final List<String> routeAddress}) =
      _$TunImpl;

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
  @override
  @JsonKey(name: "route-address")
  List<String> get routeAddress;

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
  String get listen => throw _privateConstructorUsedError;
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
      String listen,
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
    Object? listen = null,
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
      listen: null == listen
          ? _value.listen
          : listen // ignore: cast_nullable_to_non_nullable
              as String,
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
      String listen,
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
    Object? listen = null,
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
      listen: null == listen
          ? _value.listen
          : listen // ignore: cast_nullable_to_non_nullable
              as String,
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
      this.listen = "0.0.0.0:1053",
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
  @JsonKey()
  final String listen;
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
    return 'Dns(enable: $enable, listen: $listen, preferH3: $preferH3, useHosts: $useHosts, useSystemHosts: $useSystemHosts, respectRules: $respectRules, ipv6: $ipv6, defaultNameserver: $defaultNameserver, enhancedMode: $enhancedMode, fakeIpRange: $fakeIpRange, fakeIpFilter: $fakeIpFilter, nameserverPolicy: $nameserverPolicy, nameserver: $nameserver, fallback: $fallback, proxyServerNameserver: $proxyServerNameserver, fallbackFilter: $fallbackFilter)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DnsImpl &&
            (identical(other.enable, enable) || other.enable == enable) &&
            (identical(other.listen, listen) || other.listen == listen) &&
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
      listen,
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
      final String listen,
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
  String get listen;
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

GeoXUrl _$GeoXUrlFromJson(Map<String, dynamic> json) {
  return _GeoXUrl.fromJson(json);
}

/// @nodoc
mixin _$GeoXUrl {
  String get mmdb => throw _privateConstructorUsedError;
  String get asn => throw _privateConstructorUsedError;
  String get geoip => throw _privateConstructorUsedError;
  String get geosite => throw _privateConstructorUsedError;

  /// Serializes this GeoXUrl to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GeoXUrl
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GeoXUrlCopyWith<GeoXUrl> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GeoXUrlCopyWith<$Res> {
  factory $GeoXUrlCopyWith(GeoXUrl value, $Res Function(GeoXUrl) then) =
      _$GeoXUrlCopyWithImpl<$Res, GeoXUrl>;
  @useResult
  $Res call({String mmdb, String asn, String geoip, String geosite});
}

/// @nodoc
class _$GeoXUrlCopyWithImpl<$Res, $Val extends GeoXUrl>
    implements $GeoXUrlCopyWith<$Res> {
  _$GeoXUrlCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GeoXUrl
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? mmdb = null,
    Object? asn = null,
    Object? geoip = null,
    Object? geosite = null,
  }) {
    return _then(_value.copyWith(
      mmdb: null == mmdb
          ? _value.mmdb
          : mmdb // ignore: cast_nullable_to_non_nullable
              as String,
      asn: null == asn
          ? _value.asn
          : asn // ignore: cast_nullable_to_non_nullable
              as String,
      geoip: null == geoip
          ? _value.geoip
          : geoip // ignore: cast_nullable_to_non_nullable
              as String,
      geosite: null == geosite
          ? _value.geosite
          : geosite // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$GeoXUrlImplCopyWith<$Res> implements $GeoXUrlCopyWith<$Res> {
  factory _$$GeoXUrlImplCopyWith(
          _$GeoXUrlImpl value, $Res Function(_$GeoXUrlImpl) then) =
      __$$GeoXUrlImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String mmdb, String asn, String geoip, String geosite});
}

/// @nodoc
class __$$GeoXUrlImplCopyWithImpl<$Res>
    extends _$GeoXUrlCopyWithImpl<$Res, _$GeoXUrlImpl>
    implements _$$GeoXUrlImplCopyWith<$Res> {
  __$$GeoXUrlImplCopyWithImpl(
      _$GeoXUrlImpl _value, $Res Function(_$GeoXUrlImpl) _then)
      : super(_value, _then);

  /// Create a copy of GeoXUrl
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? mmdb = null,
    Object? asn = null,
    Object? geoip = null,
    Object? geosite = null,
  }) {
    return _then(_$GeoXUrlImpl(
      mmdb: null == mmdb
          ? _value.mmdb
          : mmdb // ignore: cast_nullable_to_non_nullable
              as String,
      asn: null == asn
          ? _value.asn
          : asn // ignore: cast_nullable_to_non_nullable
              as String,
      geoip: null == geoip
          ? _value.geoip
          : geoip // ignore: cast_nullable_to_non_nullable
              as String,
      geosite: null == geosite
          ? _value.geosite
          : geosite // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GeoXUrlImpl implements _GeoXUrl {
  const _$GeoXUrlImpl(
      {this.mmdb =
          "https://github.com/MetaCubeX/meta-rules-dat/releases/download/latest/geoip.metadb",
      this.asn =
          "https://github.com/MetaCubeX/meta-rules-dat/releases/download/latest/GeoLite2-ASN.mmdb",
      this.geoip =
          "https://github.com/MetaCubeX/meta-rules-dat/releases/download/latest/geoip.dat",
      this.geosite =
          "https://github.com/MetaCubeX/meta-rules-dat/releases/download/latest/geosite.dat"});

  factory _$GeoXUrlImpl.fromJson(Map<String, dynamic> json) =>
      _$$GeoXUrlImplFromJson(json);

  @override
  @JsonKey()
  final String mmdb;
  @override
  @JsonKey()
  final String asn;
  @override
  @JsonKey()
  final String geoip;
  @override
  @JsonKey()
  final String geosite;

  @override
  String toString() {
    return 'GeoXUrl(mmdb: $mmdb, asn: $asn, geoip: $geoip, geosite: $geosite)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GeoXUrlImpl &&
            (identical(other.mmdb, mmdb) || other.mmdb == mmdb) &&
            (identical(other.asn, asn) || other.asn == asn) &&
            (identical(other.geoip, geoip) || other.geoip == geoip) &&
            (identical(other.geosite, geosite) || other.geosite == geosite));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, mmdb, asn, geoip, geosite);

  /// Create a copy of GeoXUrl
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GeoXUrlImplCopyWith<_$GeoXUrlImpl> get copyWith =>
      __$$GeoXUrlImplCopyWithImpl<_$GeoXUrlImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GeoXUrlImplToJson(
      this,
    );
  }
}

abstract class _GeoXUrl implements GeoXUrl {
  const factory _GeoXUrl(
      {final String mmdb,
      final String asn,
      final String geoip,
      final String geosite}) = _$GeoXUrlImpl;

  factory _GeoXUrl.fromJson(Map<String, dynamic> json) = _$GeoXUrlImpl.fromJson;

  @override
  String get mmdb;
  @override
  String get asn;
  @override
  String get geoip;
  @override
  String get geosite;

  /// Create a copy of GeoXUrl
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GeoXUrlImplCopyWith<_$GeoXUrlImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ClashConfigSnippet _$ClashConfigSnippetFromJson(Map<String, dynamic> json) {
  return _ClashConfigSnippet.fromJson(json);
}

/// @nodoc
mixin _$ClashConfigSnippet {
  @JsonKey(name: "proxy-groups")
  List<ProxyGroup> get proxyGroups => throw _privateConstructorUsedError;
  List<String> get rule => throw _privateConstructorUsedError;

  /// Serializes this ClashConfigSnippet to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ClashConfigSnippet
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ClashConfigSnippetCopyWith<ClashConfigSnippet> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ClashConfigSnippetCopyWith<$Res> {
  factory $ClashConfigSnippetCopyWith(
          ClashConfigSnippet value, $Res Function(ClashConfigSnippet) then) =
      _$ClashConfigSnippetCopyWithImpl<$Res, ClashConfigSnippet>;
  @useResult
  $Res call(
      {@JsonKey(name: "proxy-groups") List<ProxyGroup> proxyGroups,
      List<String> rule});
}

/// @nodoc
class _$ClashConfigSnippetCopyWithImpl<$Res, $Val extends ClashConfigSnippet>
    implements $ClashConfigSnippetCopyWith<$Res> {
  _$ClashConfigSnippetCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ClashConfigSnippet
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? proxyGroups = null,
    Object? rule = null,
  }) {
    return _then(_value.copyWith(
      proxyGroups: null == proxyGroups
          ? _value.proxyGroups
          : proxyGroups // ignore: cast_nullable_to_non_nullable
              as List<ProxyGroup>,
      rule: null == rule
          ? _value.rule
          : rule // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ClashConfigSnippetImplCopyWith<$Res>
    implements $ClashConfigSnippetCopyWith<$Res> {
  factory _$$ClashConfigSnippetImplCopyWith(_$ClashConfigSnippetImpl value,
          $Res Function(_$ClashConfigSnippetImpl) then) =
      __$$ClashConfigSnippetImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: "proxy-groups") List<ProxyGroup> proxyGroups,
      List<String> rule});
}

/// @nodoc
class __$$ClashConfigSnippetImplCopyWithImpl<$Res>
    extends _$ClashConfigSnippetCopyWithImpl<$Res, _$ClashConfigSnippetImpl>
    implements _$$ClashConfigSnippetImplCopyWith<$Res> {
  __$$ClashConfigSnippetImplCopyWithImpl(_$ClashConfigSnippetImpl _value,
      $Res Function(_$ClashConfigSnippetImpl) _then)
      : super(_value, _then);

  /// Create a copy of ClashConfigSnippet
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? proxyGroups = null,
    Object? rule = null,
  }) {
    return _then(_$ClashConfigSnippetImpl(
      proxyGroups: null == proxyGroups
          ? _value._proxyGroups
          : proxyGroups // ignore: cast_nullable_to_non_nullable
              as List<ProxyGroup>,
      rule: null == rule
          ? _value._rule
          : rule // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ClashConfigSnippetImpl implements _ClashConfigSnippet {
  const _$ClashConfigSnippetImpl(
      {@JsonKey(name: "proxy-groups")
      final List<ProxyGroup> proxyGroups = const [],
      final List<String> rule = const []})
      : _proxyGroups = proxyGroups,
        _rule = rule;

  factory _$ClashConfigSnippetImpl.fromJson(Map<String, dynamic> json) =>
      _$$ClashConfigSnippetImplFromJson(json);

  final List<ProxyGroup> _proxyGroups;
  @override
  @JsonKey(name: "proxy-groups")
  List<ProxyGroup> get proxyGroups {
    if (_proxyGroups is EqualUnmodifiableListView) return _proxyGroups;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_proxyGroups);
  }

  final List<String> _rule;
  @override
  @JsonKey()
  List<String> get rule {
    if (_rule is EqualUnmodifiableListView) return _rule;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_rule);
  }

  @override
  String toString() {
    return 'ClashConfigSnippet(proxyGroups: $proxyGroups, rule: $rule)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ClashConfigSnippetImpl &&
            const DeepCollectionEquality()
                .equals(other._proxyGroups, _proxyGroups) &&
            const DeepCollectionEquality().equals(other._rule, _rule));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_proxyGroups),
      const DeepCollectionEquality().hash(_rule));

  /// Create a copy of ClashConfigSnippet
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ClashConfigSnippetImplCopyWith<_$ClashConfigSnippetImpl> get copyWith =>
      __$$ClashConfigSnippetImplCopyWithImpl<_$ClashConfigSnippetImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ClashConfigSnippetImplToJson(
      this,
    );
  }
}

abstract class _ClashConfigSnippet implements ClashConfigSnippet {
  const factory _ClashConfigSnippet(
      {@JsonKey(name: "proxy-groups") final List<ProxyGroup> proxyGroups,
      final List<String> rule}) = _$ClashConfigSnippetImpl;

  factory _ClashConfigSnippet.fromJson(Map<String, dynamic> json) =
      _$ClashConfigSnippetImpl.fromJson;

  @override
  @JsonKey(name: "proxy-groups")
  List<ProxyGroup> get proxyGroups;
  @override
  List<String> get rule;

  /// Create a copy of ClashConfigSnippet
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ClashConfigSnippetImplCopyWith<_$ClashConfigSnippetImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ClashConfig _$ClashConfigFromJson(Map<String, dynamic> json) {
  return _ClashConfig.fromJson(json);
}

/// @nodoc
mixin _$ClashConfig {
  @JsonKey(name: "mixed-port")
  int get mixedPort => throw _privateConstructorUsedError;
  Mode get mode => throw _privateConstructorUsedError;
  @JsonKey(name: "allow-lan")
  bool get allowLan => throw _privateConstructorUsedError;
  @JsonKey(name: "log-level")
  LogLevel get logLevel => throw _privateConstructorUsedError;
  bool get ipv6 => throw _privateConstructorUsedError;
  @JsonKey(name: "find-process-mode", unknownEnumValue: FindProcessMode.off)
  FindProcessMode get findProcessMode => throw _privateConstructorUsedError;
  @JsonKey(name: "keep-alive-interval")
  int get keepAliveInterval => throw _privateConstructorUsedError;
  @JsonKey(name: "unified-delay")
  bool get unifiedDelay => throw _privateConstructorUsedError;
  @JsonKey(name: "tcp-concurrent")
  bool get tcpConcurrent => throw _privateConstructorUsedError;
  @JsonKey(fromJson: Tun.safeFormJson)
  Tun get tun => throw _privateConstructorUsedError;
  @JsonKey(fromJson: Dns.safeDnsFromJson)
  Dns get dns => throw _privateConstructorUsedError;
  @JsonKey(name: "geox-url", fromJson: GeoXUrl.safeFormJson)
  GeoXUrl get geoXUrl => throw _privateConstructorUsedError;
  @JsonKey(name: "geodata-loader")
  GeodataLoader get geodataLoader => throw _privateConstructorUsedError;
  @JsonKey(name: "proxy-groups")
  List<ProxyGroup> get proxyGroups => throw _privateConstructorUsedError;
  List<String> get rule => throw _privateConstructorUsedError;
  @JsonKey(name: "global-ua")
  String? get globalUa => throw _privateConstructorUsedError;
  @JsonKey(name: "external-controller")
  ExternalControllerStatus get externalController =>
      throw _privateConstructorUsedError;
  Map<String, String> get hosts => throw _privateConstructorUsedError;

  /// Serializes this ClashConfig to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ClashConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ClashConfigCopyWith<ClashConfig> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ClashConfigCopyWith<$Res> {
  factory $ClashConfigCopyWith(
          ClashConfig value, $Res Function(ClashConfig) then) =
      _$ClashConfigCopyWithImpl<$Res, ClashConfig>;
  @useResult
  $Res call(
      {@JsonKey(name: "mixed-port") int mixedPort,
      Mode mode,
      @JsonKey(name: "allow-lan") bool allowLan,
      @JsonKey(name: "log-level") LogLevel logLevel,
      bool ipv6,
      @JsonKey(name: "find-process-mode", unknownEnumValue: FindProcessMode.off)
      FindProcessMode findProcessMode,
      @JsonKey(name: "keep-alive-interval") int keepAliveInterval,
      @JsonKey(name: "unified-delay") bool unifiedDelay,
      @JsonKey(name: "tcp-concurrent") bool tcpConcurrent,
      @JsonKey(fromJson: Tun.safeFormJson) Tun tun,
      @JsonKey(fromJson: Dns.safeDnsFromJson) Dns dns,
      @JsonKey(name: "geox-url", fromJson: GeoXUrl.safeFormJson)
      GeoXUrl geoXUrl,
      @JsonKey(name: "geodata-loader") GeodataLoader geodataLoader,
      @JsonKey(name: "proxy-groups") List<ProxyGroup> proxyGroups,
      List<String> rule,
      @JsonKey(name: "global-ua") String? globalUa,
      @JsonKey(name: "external-controller")
      ExternalControllerStatus externalController,
      Map<String, String> hosts});

  $TunCopyWith<$Res> get tun;
  $DnsCopyWith<$Res> get dns;
  $GeoXUrlCopyWith<$Res> get geoXUrl;
}

/// @nodoc
class _$ClashConfigCopyWithImpl<$Res, $Val extends ClashConfig>
    implements $ClashConfigCopyWith<$Res> {
  _$ClashConfigCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ClashConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? mixedPort = null,
    Object? mode = null,
    Object? allowLan = null,
    Object? logLevel = null,
    Object? ipv6 = null,
    Object? findProcessMode = null,
    Object? keepAliveInterval = null,
    Object? unifiedDelay = null,
    Object? tcpConcurrent = null,
    Object? tun = null,
    Object? dns = null,
    Object? geoXUrl = null,
    Object? geodataLoader = null,
    Object? proxyGroups = null,
    Object? rule = null,
    Object? globalUa = freezed,
    Object? externalController = null,
    Object? hosts = null,
  }) {
    return _then(_value.copyWith(
      mixedPort: null == mixedPort
          ? _value.mixedPort
          : mixedPort // ignore: cast_nullable_to_non_nullable
              as int,
      mode: null == mode
          ? _value.mode
          : mode // ignore: cast_nullable_to_non_nullable
              as Mode,
      allowLan: null == allowLan
          ? _value.allowLan
          : allowLan // ignore: cast_nullable_to_non_nullable
              as bool,
      logLevel: null == logLevel
          ? _value.logLevel
          : logLevel // ignore: cast_nullable_to_non_nullable
              as LogLevel,
      ipv6: null == ipv6
          ? _value.ipv6
          : ipv6 // ignore: cast_nullable_to_non_nullable
              as bool,
      findProcessMode: null == findProcessMode
          ? _value.findProcessMode
          : findProcessMode // ignore: cast_nullable_to_non_nullable
              as FindProcessMode,
      keepAliveInterval: null == keepAliveInterval
          ? _value.keepAliveInterval
          : keepAliveInterval // ignore: cast_nullable_to_non_nullable
              as int,
      unifiedDelay: null == unifiedDelay
          ? _value.unifiedDelay
          : unifiedDelay // ignore: cast_nullable_to_non_nullable
              as bool,
      tcpConcurrent: null == tcpConcurrent
          ? _value.tcpConcurrent
          : tcpConcurrent // ignore: cast_nullable_to_non_nullable
              as bool,
      tun: null == tun
          ? _value.tun
          : tun // ignore: cast_nullable_to_non_nullable
              as Tun,
      dns: null == dns
          ? _value.dns
          : dns // ignore: cast_nullable_to_non_nullable
              as Dns,
      geoXUrl: null == geoXUrl
          ? _value.geoXUrl
          : geoXUrl // ignore: cast_nullable_to_non_nullable
              as GeoXUrl,
      geodataLoader: null == geodataLoader
          ? _value.geodataLoader
          : geodataLoader // ignore: cast_nullable_to_non_nullable
              as GeodataLoader,
      proxyGroups: null == proxyGroups
          ? _value.proxyGroups
          : proxyGroups // ignore: cast_nullable_to_non_nullable
              as List<ProxyGroup>,
      rule: null == rule
          ? _value.rule
          : rule // ignore: cast_nullable_to_non_nullable
              as List<String>,
      globalUa: freezed == globalUa
          ? _value.globalUa
          : globalUa // ignore: cast_nullable_to_non_nullable
              as String?,
      externalController: null == externalController
          ? _value.externalController
          : externalController // ignore: cast_nullable_to_non_nullable
              as ExternalControllerStatus,
      hosts: null == hosts
          ? _value.hosts
          : hosts // ignore: cast_nullable_to_non_nullable
              as Map<String, String>,
    ) as $Val);
  }

  /// Create a copy of ClashConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TunCopyWith<$Res> get tun {
    return $TunCopyWith<$Res>(_value.tun, (value) {
      return _then(_value.copyWith(tun: value) as $Val);
    });
  }

  /// Create a copy of ClashConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DnsCopyWith<$Res> get dns {
    return $DnsCopyWith<$Res>(_value.dns, (value) {
      return _then(_value.copyWith(dns: value) as $Val);
    });
  }

  /// Create a copy of ClashConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $GeoXUrlCopyWith<$Res> get geoXUrl {
    return $GeoXUrlCopyWith<$Res>(_value.geoXUrl, (value) {
      return _then(_value.copyWith(geoXUrl: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ClashConfigImplCopyWith<$Res>
    implements $ClashConfigCopyWith<$Res> {
  factory _$$ClashConfigImplCopyWith(
          _$ClashConfigImpl value, $Res Function(_$ClashConfigImpl) then) =
      __$$ClashConfigImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: "mixed-port") int mixedPort,
      Mode mode,
      @JsonKey(name: "allow-lan") bool allowLan,
      @JsonKey(name: "log-level") LogLevel logLevel,
      bool ipv6,
      @JsonKey(name: "find-process-mode", unknownEnumValue: FindProcessMode.off)
      FindProcessMode findProcessMode,
      @JsonKey(name: "keep-alive-interval") int keepAliveInterval,
      @JsonKey(name: "unified-delay") bool unifiedDelay,
      @JsonKey(name: "tcp-concurrent") bool tcpConcurrent,
      @JsonKey(fromJson: Tun.safeFormJson) Tun tun,
      @JsonKey(fromJson: Dns.safeDnsFromJson) Dns dns,
      @JsonKey(name: "geox-url", fromJson: GeoXUrl.safeFormJson)
      GeoXUrl geoXUrl,
      @JsonKey(name: "geodata-loader") GeodataLoader geodataLoader,
      @JsonKey(name: "proxy-groups") List<ProxyGroup> proxyGroups,
      List<String> rule,
      @JsonKey(name: "global-ua") String? globalUa,
      @JsonKey(name: "external-controller")
      ExternalControllerStatus externalController,
      Map<String, String> hosts});

  @override
  $TunCopyWith<$Res> get tun;
  @override
  $DnsCopyWith<$Res> get dns;
  @override
  $GeoXUrlCopyWith<$Res> get geoXUrl;
}

/// @nodoc
class __$$ClashConfigImplCopyWithImpl<$Res>
    extends _$ClashConfigCopyWithImpl<$Res, _$ClashConfigImpl>
    implements _$$ClashConfigImplCopyWith<$Res> {
  __$$ClashConfigImplCopyWithImpl(
      _$ClashConfigImpl _value, $Res Function(_$ClashConfigImpl) _then)
      : super(_value, _then);

  /// Create a copy of ClashConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? mixedPort = null,
    Object? mode = null,
    Object? allowLan = null,
    Object? logLevel = null,
    Object? ipv6 = null,
    Object? findProcessMode = null,
    Object? keepAliveInterval = null,
    Object? unifiedDelay = null,
    Object? tcpConcurrent = null,
    Object? tun = null,
    Object? dns = null,
    Object? geoXUrl = null,
    Object? geodataLoader = null,
    Object? proxyGroups = null,
    Object? rule = null,
    Object? globalUa = freezed,
    Object? externalController = null,
    Object? hosts = null,
  }) {
    return _then(_$ClashConfigImpl(
      mixedPort: null == mixedPort
          ? _value.mixedPort
          : mixedPort // ignore: cast_nullable_to_non_nullable
              as int,
      mode: null == mode
          ? _value.mode
          : mode // ignore: cast_nullable_to_non_nullable
              as Mode,
      allowLan: null == allowLan
          ? _value.allowLan
          : allowLan // ignore: cast_nullable_to_non_nullable
              as bool,
      logLevel: null == logLevel
          ? _value.logLevel
          : logLevel // ignore: cast_nullable_to_non_nullable
              as LogLevel,
      ipv6: null == ipv6
          ? _value.ipv6
          : ipv6 // ignore: cast_nullable_to_non_nullable
              as bool,
      findProcessMode: null == findProcessMode
          ? _value.findProcessMode
          : findProcessMode // ignore: cast_nullable_to_non_nullable
              as FindProcessMode,
      keepAliveInterval: null == keepAliveInterval
          ? _value.keepAliveInterval
          : keepAliveInterval // ignore: cast_nullable_to_non_nullable
              as int,
      unifiedDelay: null == unifiedDelay
          ? _value.unifiedDelay
          : unifiedDelay // ignore: cast_nullable_to_non_nullable
              as bool,
      tcpConcurrent: null == tcpConcurrent
          ? _value.tcpConcurrent
          : tcpConcurrent // ignore: cast_nullable_to_non_nullable
              as bool,
      tun: null == tun
          ? _value.tun
          : tun // ignore: cast_nullable_to_non_nullable
              as Tun,
      dns: null == dns
          ? _value.dns
          : dns // ignore: cast_nullable_to_non_nullable
              as Dns,
      geoXUrl: null == geoXUrl
          ? _value.geoXUrl
          : geoXUrl // ignore: cast_nullable_to_non_nullable
              as GeoXUrl,
      geodataLoader: null == geodataLoader
          ? _value.geodataLoader
          : geodataLoader // ignore: cast_nullable_to_non_nullable
              as GeodataLoader,
      proxyGroups: null == proxyGroups
          ? _value._proxyGroups
          : proxyGroups // ignore: cast_nullable_to_non_nullable
              as List<ProxyGroup>,
      rule: null == rule
          ? _value._rule
          : rule // ignore: cast_nullable_to_non_nullable
              as List<String>,
      globalUa: freezed == globalUa
          ? _value.globalUa
          : globalUa // ignore: cast_nullable_to_non_nullable
              as String?,
      externalController: null == externalController
          ? _value.externalController
          : externalController // ignore: cast_nullable_to_non_nullable
              as ExternalControllerStatus,
      hosts: null == hosts
          ? _value._hosts
          : hosts // ignore: cast_nullable_to_non_nullable
              as Map<String, String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ClashConfigImpl implements _ClashConfig {
  const _$ClashConfigImpl(
      {@JsonKey(name: "mixed-port") this.mixedPort = defaultMixedPort,
      this.mode = Mode.rule,
      @JsonKey(name: "allow-lan") this.allowLan = false,
      @JsonKey(name: "log-level") this.logLevel = LogLevel.info,
      this.ipv6 = false,
      @JsonKey(name: "find-process-mode", unknownEnumValue: FindProcessMode.off)
      this.findProcessMode = FindProcessMode.off,
      @JsonKey(name: "keep-alive-interval")
      this.keepAliveInterval = defaultKeepAliveInterval,
      @JsonKey(name: "unified-delay") this.unifiedDelay = true,
      @JsonKey(name: "tcp-concurrent") this.tcpConcurrent = true,
      @JsonKey(fromJson: Tun.safeFormJson) this.tun = defaultTun,
      @JsonKey(fromJson: Dns.safeDnsFromJson) this.dns = defaultDns,
      @JsonKey(name: "geox-url", fromJson: GeoXUrl.safeFormJson)
      this.geoXUrl = defaultGeoXUrl,
      @JsonKey(name: "geodata-loader")
      this.geodataLoader = GeodataLoader.memconservative,
      @JsonKey(name: "proxy-groups")
      final List<ProxyGroup> proxyGroups = const [],
      final List<String> rule = const [],
      @JsonKey(name: "global-ua") this.globalUa,
      @JsonKey(name: "external-controller")
      this.externalController = ExternalControllerStatus.close,
      final Map<String, String> hosts = const {}})
      : _proxyGroups = proxyGroups,
        _rule = rule,
        _hosts = hosts;

  factory _$ClashConfigImpl.fromJson(Map<String, dynamic> json) =>
      _$$ClashConfigImplFromJson(json);

  @override
  @JsonKey(name: "mixed-port")
  final int mixedPort;
  @override
  @JsonKey()
  final Mode mode;
  @override
  @JsonKey(name: "allow-lan")
  final bool allowLan;
  @override
  @JsonKey(name: "log-level")
  final LogLevel logLevel;
  @override
  @JsonKey()
  final bool ipv6;
  @override
  @JsonKey(name: "find-process-mode", unknownEnumValue: FindProcessMode.off)
  final FindProcessMode findProcessMode;
  @override
  @JsonKey(name: "keep-alive-interval")
  final int keepAliveInterval;
  @override
  @JsonKey(name: "unified-delay")
  final bool unifiedDelay;
  @override
  @JsonKey(name: "tcp-concurrent")
  final bool tcpConcurrent;
  @override
  @JsonKey(fromJson: Tun.safeFormJson)
  final Tun tun;
  @override
  @JsonKey(fromJson: Dns.safeDnsFromJson)
  final Dns dns;
  @override
  @JsonKey(name: "geox-url", fromJson: GeoXUrl.safeFormJson)
  final GeoXUrl geoXUrl;
  @override
  @JsonKey(name: "geodata-loader")
  final GeodataLoader geodataLoader;
  final List<ProxyGroup> _proxyGroups;
  @override
  @JsonKey(name: "proxy-groups")
  List<ProxyGroup> get proxyGroups {
    if (_proxyGroups is EqualUnmodifiableListView) return _proxyGroups;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_proxyGroups);
  }

  final List<String> _rule;
  @override
  @JsonKey()
  List<String> get rule {
    if (_rule is EqualUnmodifiableListView) return _rule;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_rule);
  }

  @override
  @JsonKey(name: "global-ua")
  final String? globalUa;
  @override
  @JsonKey(name: "external-controller")
  final ExternalControllerStatus externalController;
  final Map<String, String> _hosts;
  @override
  @JsonKey()
  Map<String, String> get hosts {
    if (_hosts is EqualUnmodifiableMapView) return _hosts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_hosts);
  }

  @override
  String toString() {
    return 'ClashConfig(mixedPort: $mixedPort, mode: $mode, allowLan: $allowLan, logLevel: $logLevel, ipv6: $ipv6, findProcessMode: $findProcessMode, keepAliveInterval: $keepAliveInterval, unifiedDelay: $unifiedDelay, tcpConcurrent: $tcpConcurrent, tun: $tun, dns: $dns, geoXUrl: $geoXUrl, geodataLoader: $geodataLoader, proxyGroups: $proxyGroups, rule: $rule, globalUa: $globalUa, externalController: $externalController, hosts: $hosts)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ClashConfigImpl &&
            (identical(other.mixedPort, mixedPort) ||
                other.mixedPort == mixedPort) &&
            (identical(other.mode, mode) || other.mode == mode) &&
            (identical(other.allowLan, allowLan) ||
                other.allowLan == allowLan) &&
            (identical(other.logLevel, logLevel) ||
                other.logLevel == logLevel) &&
            (identical(other.ipv6, ipv6) || other.ipv6 == ipv6) &&
            (identical(other.findProcessMode, findProcessMode) ||
                other.findProcessMode == findProcessMode) &&
            (identical(other.keepAliveInterval, keepAliveInterval) ||
                other.keepAliveInterval == keepAliveInterval) &&
            (identical(other.unifiedDelay, unifiedDelay) ||
                other.unifiedDelay == unifiedDelay) &&
            (identical(other.tcpConcurrent, tcpConcurrent) ||
                other.tcpConcurrent == tcpConcurrent) &&
            (identical(other.tun, tun) || other.tun == tun) &&
            (identical(other.dns, dns) || other.dns == dns) &&
            (identical(other.geoXUrl, geoXUrl) || other.geoXUrl == geoXUrl) &&
            (identical(other.geodataLoader, geodataLoader) ||
                other.geodataLoader == geodataLoader) &&
            const DeepCollectionEquality()
                .equals(other._proxyGroups, _proxyGroups) &&
            const DeepCollectionEquality().equals(other._rule, _rule) &&
            (identical(other.globalUa, globalUa) ||
                other.globalUa == globalUa) &&
            (identical(other.externalController, externalController) ||
                other.externalController == externalController) &&
            const DeepCollectionEquality().equals(other._hosts, _hosts));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      mixedPort,
      mode,
      allowLan,
      logLevel,
      ipv6,
      findProcessMode,
      keepAliveInterval,
      unifiedDelay,
      tcpConcurrent,
      tun,
      dns,
      geoXUrl,
      geodataLoader,
      const DeepCollectionEquality().hash(_proxyGroups),
      const DeepCollectionEquality().hash(_rule),
      globalUa,
      externalController,
      const DeepCollectionEquality().hash(_hosts));

  /// Create a copy of ClashConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ClashConfigImplCopyWith<_$ClashConfigImpl> get copyWith =>
      __$$ClashConfigImplCopyWithImpl<_$ClashConfigImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ClashConfigImplToJson(
      this,
    );
  }
}

abstract class _ClashConfig implements ClashConfig {
  const factory _ClashConfig(
      {@JsonKey(name: "mixed-port") final int mixedPort,
      final Mode mode,
      @JsonKey(name: "allow-lan") final bool allowLan,
      @JsonKey(name: "log-level") final LogLevel logLevel,
      final bool ipv6,
      @JsonKey(name: "find-process-mode", unknownEnumValue: FindProcessMode.off)
      final FindProcessMode findProcessMode,
      @JsonKey(name: "keep-alive-interval") final int keepAliveInterval,
      @JsonKey(name: "unified-delay") final bool unifiedDelay,
      @JsonKey(name: "tcp-concurrent") final bool tcpConcurrent,
      @JsonKey(fromJson: Tun.safeFormJson) final Tun tun,
      @JsonKey(fromJson: Dns.safeDnsFromJson) final Dns dns,
      @JsonKey(name: "geox-url", fromJson: GeoXUrl.safeFormJson)
      final GeoXUrl geoXUrl,
      @JsonKey(name: "geodata-loader") final GeodataLoader geodataLoader,
      @JsonKey(name: "proxy-groups") final List<ProxyGroup> proxyGroups,
      final List<String> rule,
      @JsonKey(name: "global-ua") final String? globalUa,
      @JsonKey(name: "external-controller")
      final ExternalControllerStatus externalController,
      final Map<String, String> hosts}) = _$ClashConfigImpl;

  factory _ClashConfig.fromJson(Map<String, dynamic> json) =
      _$ClashConfigImpl.fromJson;

  @override
  @JsonKey(name: "mixed-port")
  int get mixedPort;
  @override
  Mode get mode;
  @override
  @JsonKey(name: "allow-lan")
  bool get allowLan;
  @override
  @JsonKey(name: "log-level")
  LogLevel get logLevel;
  @override
  bool get ipv6;
  @override
  @JsonKey(name: "find-process-mode", unknownEnumValue: FindProcessMode.off)
  FindProcessMode get findProcessMode;
  @override
  @JsonKey(name: "keep-alive-interval")
  int get keepAliveInterval;
  @override
  @JsonKey(name: "unified-delay")
  bool get unifiedDelay;
  @override
  @JsonKey(name: "tcp-concurrent")
  bool get tcpConcurrent;
  @override
  @JsonKey(fromJson: Tun.safeFormJson)
  Tun get tun;
  @override
  @JsonKey(fromJson: Dns.safeDnsFromJson)
  Dns get dns;
  @override
  @JsonKey(name: "geox-url", fromJson: GeoXUrl.safeFormJson)
  GeoXUrl get geoXUrl;
  @override
  @JsonKey(name: "geodata-loader")
  GeodataLoader get geodataLoader;
  @override
  @JsonKey(name: "proxy-groups")
  List<ProxyGroup> get proxyGroups;
  @override
  List<String> get rule;
  @override
  @JsonKey(name: "global-ua")
  String? get globalUa;
  @override
  @JsonKey(name: "external-controller")
  ExternalControllerStatus get externalController;
  @override
  Map<String, String> get hosts;

  /// Create a copy of ClashConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ClashConfigImplCopyWith<_$ClashConfigImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
