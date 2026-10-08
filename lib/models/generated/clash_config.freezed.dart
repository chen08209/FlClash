// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../clash_config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ProxyGroup {

 int? get profileId;@JsonKey(fromJson: Snowflake.buildId) int get id; String get name; GroupType get type; List<String>? get proxies; List<String>? get use; int? get interval; bool? get lazy;@JsonKey(name: 'disable-udp') bool? get disableUDP; String? get url; int? get timeout;@JsonKey(name: 'max-failed-times') int? get maxFailedTimes; String? get filter;@JsonKey(name: 'exclude-filter') String? get excludeFilter;@JsonKey(name: 'exclude-type') String? get excludeType;@JsonKey(name: 'expected-status') String? get expectedStatus; int? get tolerance; LoadBalanceStrategy? get strategy;@JsonKey(name: 'hash-key') String? get hashKey;@JsonKey(name: 'default-selected') String? get defaultSelected;@JsonKey(name: 'empty-fallback') String? get emptyFallback;@JsonKey(name: 'include-all') bool? get includeAll;@JsonKey(name: 'include-all-proxies') bool? get includeAllProxies;@JsonKey(name: 'include-all-providers') bool? get includeAllProviders; bool? get hidden; String? get icon; String? get order;
/// Create a copy of ProxyGroup
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProxyGroupCopyWith<ProxyGroup> get copyWith => _$ProxyGroupCopyWithImpl<ProxyGroup>(this as ProxyGroup, _$identity);

  /// Serializes this ProxyGroup to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ProxyGroup;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProxyGroup&&(identical(other.profileId, _this.profileId) || other.profileId == _this.profileId)&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.type, _this.type) || other.type == _this.type)&&const DeepCollectionEquality().equals(other.proxies, _this.proxies)&&const DeepCollectionEquality().equals(other.use, _this.use)&&(identical(other.interval, _this.interval) || other.interval == _this.interval)&&(identical(other.lazy, _this.lazy) || other.lazy == _this.lazy)&&(identical(other.disableUDP, _this.disableUDP) || other.disableUDP == _this.disableUDP)&&(identical(other.url, _this.url) || other.url == _this.url)&&(identical(other.timeout, _this.timeout) || other.timeout == _this.timeout)&&(identical(other.maxFailedTimes, _this.maxFailedTimes) || other.maxFailedTimes == _this.maxFailedTimes)&&(identical(other.filter, _this.filter) || other.filter == _this.filter)&&(identical(other.excludeFilter, _this.excludeFilter) || other.excludeFilter == _this.excludeFilter)&&(identical(other.excludeType, _this.excludeType) || other.excludeType == _this.excludeType)&&(identical(other.expectedStatus, _this.expectedStatus) || other.expectedStatus == _this.expectedStatus)&&(identical(other.tolerance, _this.tolerance) || other.tolerance == _this.tolerance)&&(identical(other.strategy, _this.strategy) || other.strategy == _this.strategy)&&(identical(other.hashKey, _this.hashKey) || other.hashKey == _this.hashKey)&&(identical(other.defaultSelected, _this.defaultSelected) || other.defaultSelected == _this.defaultSelected)&&(identical(other.emptyFallback, _this.emptyFallback) || other.emptyFallback == _this.emptyFallback)&&(identical(other.includeAll, _this.includeAll) || other.includeAll == _this.includeAll)&&(identical(other.includeAllProxies, _this.includeAllProxies) || other.includeAllProxies == _this.includeAllProxies)&&(identical(other.includeAllProviders, _this.includeAllProviders) || other.includeAllProviders == _this.includeAllProviders)&&(identical(other.hidden, _this.hidden) || other.hidden == _this.hidden)&&(identical(other.icon, _this.icon) || other.icon == _this.icon)&&(identical(other.order, _this.order) || other.order == _this.order));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ProxyGroup;
  return Object.hashAll([runtimeType,_this.profileId,_this.id,_this.name,_this.type,const DeepCollectionEquality().hash(_this.proxies),const DeepCollectionEquality().hash(_this.use),_this.interval,_this.lazy,_this.disableUDP,_this.url,_this.timeout,_this.maxFailedTimes,_this.filter,_this.excludeFilter,_this.excludeType,_this.expectedStatus,_this.tolerance,_this.strategy,_this.hashKey,_this.defaultSelected,_this.emptyFallback,_this.includeAll,_this.includeAllProxies,_this.includeAllProviders,_this.hidden,_this.icon,_this.order]);
}

@override
String toString() {
  final _this = this as ProxyGroup;
  return 'ProxyGroup(profileId: ${_this.profileId}, id: ${_this.id}, name: ${_this.name}, type: ${_this.type}, proxies: ${_this.proxies}, use: ${_this.use}, interval: ${_this.interval}, lazy: ${_this.lazy}, disableUDP: ${_this.disableUDP}, url: ${_this.url}, timeout: ${_this.timeout}, maxFailedTimes: ${_this.maxFailedTimes}, filter: ${_this.filter}, excludeFilter: ${_this.excludeFilter}, excludeType: ${_this.excludeType}, expectedStatus: ${_this.expectedStatus}, tolerance: ${_this.tolerance}, strategy: ${_this.strategy}, hashKey: ${_this.hashKey}, defaultSelected: ${_this.defaultSelected}, emptyFallback: ${_this.emptyFallback}, includeAll: ${_this.includeAll}, includeAllProxies: ${_this.includeAllProxies}, includeAllProviders: ${_this.includeAllProviders}, hidden: ${_this.hidden}, icon: ${_this.icon}, order: ${_this.order})';
}


}

/// @nodoc
abstract mixin class $ProxyGroupCopyWith<$Res>  {
  factory $ProxyGroupCopyWith(ProxyGroup value, $Res Function(ProxyGroup) _then) = _$ProxyGroupCopyWithImpl;
@useResult
$Res call({
 int? profileId,@JsonKey(fromJson: Snowflake.buildId) int id, String name, GroupType type, List<String>? proxies, List<String>? use, int? interval, bool? lazy,@JsonKey(name: 'disable-udp') bool? disableUDP, String? url, int? timeout,@JsonKey(name: 'max-failed-times') int? maxFailedTimes, String? filter,@JsonKey(name: 'exclude-filter') String? excludeFilter,@JsonKey(name: 'exclude-type') String? excludeType,@JsonKey(name: 'expected-status') String? expectedStatus, int? tolerance, LoadBalanceStrategy? strategy,@JsonKey(name: 'hash-key') String? hashKey,@JsonKey(name: 'default-selected') String? defaultSelected,@JsonKey(name: 'empty-fallback') String? emptyFallback,@JsonKey(name: 'include-all') bool? includeAll,@JsonKey(name: 'include-all-proxies') bool? includeAllProxies,@JsonKey(name: 'include-all-providers') bool? includeAllProviders, bool? hidden, String? icon, String? order
});




}
/// @nodoc
class _$ProxyGroupCopyWithImpl<$Res>
    implements $ProxyGroupCopyWith<$Res> {
  _$ProxyGroupCopyWithImpl(this._self, this._then);

  final ProxyGroup _self;
  final $Res Function(ProxyGroup) _then;

/// Create a copy of ProxyGroup
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? profileId = freezed,Object? id = null,Object? name = null,Object? type = null,Object? proxies = freezed,Object? use = freezed,Object? interval = freezed,Object? lazy = freezed,Object? disableUDP = freezed,Object? url = freezed,Object? timeout = freezed,Object? maxFailedTimes = freezed,Object? filter = freezed,Object? excludeFilter = freezed,Object? excludeType = freezed,Object? expectedStatus = freezed,Object? tolerance = freezed,Object? strategy = freezed,Object? hashKey = freezed,Object? defaultSelected = freezed,Object? emptyFallback = freezed,Object? includeAll = freezed,Object? includeAllProxies = freezed,Object? includeAllProviders = freezed,Object? hidden = freezed,Object? icon = freezed,Object? order = freezed,}) {
  return _then(ProxyGroup(
profileId: freezed == profileId ? _self.profileId : profileId // ignore: cast_nullable_to_non_nullable
as int?,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as GroupType,proxies: freezed == proxies ? _self.proxies : proxies // ignore: cast_nullable_to_non_nullable
as List<String>?,use: freezed == use ? _self.use : use // ignore: cast_nullable_to_non_nullable
as List<String>?,interval: freezed == interval ? _self.interval : interval // ignore: cast_nullable_to_non_nullable
as int?,lazy: freezed == lazy ? _self.lazy : lazy // ignore: cast_nullable_to_non_nullable
as bool?,disableUDP: freezed == disableUDP ? _self.disableUDP : disableUDP // ignore: cast_nullable_to_non_nullable
as bool?,url: freezed == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String?,timeout: freezed == timeout ? _self.timeout : timeout // ignore: cast_nullable_to_non_nullable
as int?,maxFailedTimes: freezed == maxFailedTimes ? _self.maxFailedTimes : maxFailedTimes // ignore: cast_nullable_to_non_nullable
as int?,filter: freezed == filter ? _self.filter : filter // ignore: cast_nullable_to_non_nullable
as String?,excludeFilter: freezed == excludeFilter ? _self.excludeFilter : excludeFilter // ignore: cast_nullable_to_non_nullable
as String?,excludeType: freezed == excludeType ? _self.excludeType : excludeType // ignore: cast_nullable_to_non_nullable
as String?,expectedStatus: freezed == expectedStatus ? _self.expectedStatus : expectedStatus // ignore: cast_nullable_to_non_nullable
as String?,tolerance: freezed == tolerance ? _self.tolerance : tolerance // ignore: cast_nullable_to_non_nullable
as int?,strategy: freezed == strategy ? _self.strategy : strategy // ignore: cast_nullable_to_non_nullable
as LoadBalanceStrategy?,hashKey: freezed == hashKey ? _self.hashKey : hashKey // ignore: cast_nullable_to_non_nullable
as String?,defaultSelected: freezed == defaultSelected ? _self.defaultSelected : defaultSelected // ignore: cast_nullable_to_non_nullable
as String?,emptyFallback: freezed == emptyFallback ? _self.emptyFallback : emptyFallback // ignore: cast_nullable_to_non_nullable
as String?,includeAll: freezed == includeAll ? _self.includeAll : includeAll // ignore: cast_nullable_to_non_nullable
as bool?,includeAllProxies: freezed == includeAllProxies ? _self.includeAllProxies : includeAllProxies // ignore: cast_nullable_to_non_nullable
as bool?,includeAllProviders: freezed == includeAllProviders ? _self.includeAllProviders : includeAllProviders // ignore: cast_nullable_to_non_nullable
as bool?,hidden: freezed == hidden ? _self.hidden : hidden // ignore: cast_nullable_to_non_nullable
as bool?,icon: freezed == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String?,order: freezed == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ProxyGroup].
extension ProxyGroupPatterns on ProxyGroup {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProxyGroup value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProxyGroup() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProxyGroup value)  $default,){
final _that = this;
switch (_that) {
case _ProxyGroup():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProxyGroup value)?  $default,){
final _that = this;
switch (_that) {
case _ProxyGroup() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? profileId, @JsonKey(fromJson: Snowflake.buildId)  int id,  String name,  GroupType type,  List<String>? proxies,  List<String>? use,  int? interval,  bool? lazy, @JsonKey(name: 'disable-udp')  bool? disableUDP,  String? url,  int? timeout, @JsonKey(name: 'max-failed-times')  int? maxFailedTimes,  String? filter, @JsonKey(name: 'exclude-filter')  String? excludeFilter, @JsonKey(name: 'exclude-type')  String? excludeType, @JsonKey(name: 'expected-status')  String? expectedStatus,  int? tolerance,  LoadBalanceStrategy? strategy, @JsonKey(name: 'hash-key')  String? hashKey, @JsonKey(name: 'default-selected')  String? defaultSelected, @JsonKey(name: 'empty-fallback')  String? emptyFallback, @JsonKey(name: 'include-all')  bool? includeAll, @JsonKey(name: 'include-all-proxies')  bool? includeAllProxies, @JsonKey(name: 'include-all-providers')  bool? includeAllProviders,  bool? hidden,  String? icon,  String? order)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProxyGroup() when $default != null:
return $default(_that.profileId,_that.id,_that.name,_that.type,_that.proxies,_that.use,_that.interval,_that.lazy,_that.disableUDP,_that.url,_that.timeout,_that.maxFailedTimes,_that.filter,_that.excludeFilter,_that.excludeType,_that.expectedStatus,_that.tolerance,_that.strategy,_that.hashKey,_that.defaultSelected,_that.emptyFallback,_that.includeAll,_that.includeAllProxies,_that.includeAllProviders,_that.hidden,_that.icon,_that.order);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? profileId, @JsonKey(fromJson: Snowflake.buildId)  int id,  String name,  GroupType type,  List<String>? proxies,  List<String>? use,  int? interval,  bool? lazy, @JsonKey(name: 'disable-udp')  bool? disableUDP,  String? url,  int? timeout, @JsonKey(name: 'max-failed-times')  int? maxFailedTimes,  String? filter, @JsonKey(name: 'exclude-filter')  String? excludeFilter, @JsonKey(name: 'exclude-type')  String? excludeType, @JsonKey(name: 'expected-status')  String? expectedStatus,  int? tolerance,  LoadBalanceStrategy? strategy, @JsonKey(name: 'hash-key')  String? hashKey, @JsonKey(name: 'default-selected')  String? defaultSelected, @JsonKey(name: 'empty-fallback')  String? emptyFallback, @JsonKey(name: 'include-all')  bool? includeAll, @JsonKey(name: 'include-all-proxies')  bool? includeAllProxies, @JsonKey(name: 'include-all-providers')  bool? includeAllProviders,  bool? hidden,  String? icon,  String? order)  $default,) {final _that = this;
switch (_that) {
case _ProxyGroup():
return $default(_that.profileId,_that.id,_that.name,_that.type,_that.proxies,_that.use,_that.interval,_that.lazy,_that.disableUDP,_that.url,_that.timeout,_that.maxFailedTimes,_that.filter,_that.excludeFilter,_that.excludeType,_that.expectedStatus,_that.tolerance,_that.strategy,_that.hashKey,_that.defaultSelected,_that.emptyFallback,_that.includeAll,_that.includeAllProxies,_that.includeAllProviders,_that.hidden,_that.icon,_that.order);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? profileId, @JsonKey(fromJson: Snowflake.buildId)  int id,  String name,  GroupType type,  List<String>? proxies,  List<String>? use,  int? interval,  bool? lazy, @JsonKey(name: 'disable-udp')  bool? disableUDP,  String? url,  int? timeout, @JsonKey(name: 'max-failed-times')  int? maxFailedTimes,  String? filter, @JsonKey(name: 'exclude-filter')  String? excludeFilter, @JsonKey(name: 'exclude-type')  String? excludeType, @JsonKey(name: 'expected-status')  String? expectedStatus,  int? tolerance,  LoadBalanceStrategy? strategy, @JsonKey(name: 'hash-key')  String? hashKey, @JsonKey(name: 'default-selected')  String? defaultSelected, @JsonKey(name: 'empty-fallback')  String? emptyFallback, @JsonKey(name: 'include-all')  bool? includeAll, @JsonKey(name: 'include-all-proxies')  bool? includeAllProxies, @JsonKey(name: 'include-all-providers')  bool? includeAllProviders,  bool? hidden,  String? icon,  String? order)?  $default,) {final _that = this;
switch (_that) {
case _ProxyGroup() when $default != null:
return $default(_that.profileId,_that.id,_that.name,_that.type,_that.proxies,_that.use,_that.interval,_that.lazy,_that.disableUDP,_that.url,_that.timeout,_that.maxFailedTimes,_that.filter,_that.excludeFilter,_that.excludeType,_that.expectedStatus,_that.tolerance,_that.strategy,_that.hashKey,_that.defaultSelected,_that.emptyFallback,_that.includeAll,_that.includeAllProxies,_that.includeAllProviders,_that.hidden,_that.icon,_that.order);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProxyGroup implements ProxyGroup {
  const _ProxyGroup({this.profileId, @JsonKey(fromJson: Snowflake.buildId) required this.id, required this.name, required this.type,  List<String>? proxies,  List<String>? use, this.interval, this.lazy, @JsonKey(name: 'disable-udp') this.disableUDP, this.url, this.timeout, @JsonKey(name: 'max-failed-times') this.maxFailedTimes, this.filter, @JsonKey(name: 'exclude-filter') this.excludeFilter, @JsonKey(name: 'exclude-type') this.excludeType, @JsonKey(name: 'expected-status') this.expectedStatus, this.tolerance, this.strategy, @JsonKey(name: 'hash-key') this.hashKey, @JsonKey(name: 'default-selected') this.defaultSelected, @JsonKey(name: 'empty-fallback') this.emptyFallback, @JsonKey(name: 'include-all') this.includeAll, @JsonKey(name: 'include-all-proxies') this.includeAllProxies, @JsonKey(name: 'include-all-providers') this.includeAllProviders, this.hidden, this.icon, this.order}): _proxies = proxies,_use = use;
  factory _ProxyGroup.fromJson(Map<String, dynamic> json) => _$ProxyGroupFromJson(json);

@override final  int? profileId;
@override@JsonKey(fromJson: Snowflake.buildId) final  int id;
@override final  String name;
@override final  GroupType type;
 final  List<String>? _proxies;
@override List<String>? get proxies {
  final value = _proxies;
  if (value == null) return null;
  if (_proxies is EqualUnmodifiableListView) return _proxies;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  List<String>? _use;
@override List<String>? get use {
  final value = _use;
  if (value == null) return null;
  if (_use is EqualUnmodifiableListView) return _use;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override final  int? interval;
@override final  bool? lazy;
@override@JsonKey(name: 'disable-udp') final  bool? disableUDP;
@override final  String? url;
@override final  int? timeout;
@override@JsonKey(name: 'max-failed-times') final  int? maxFailedTimes;
@override final  String? filter;
@override@JsonKey(name: 'exclude-filter') final  String? excludeFilter;
@override@JsonKey(name: 'exclude-type') final  String? excludeType;
@override@JsonKey(name: 'expected-status') final  String? expectedStatus;
@override final  int? tolerance;
@override final  LoadBalanceStrategy? strategy;
@override@JsonKey(name: 'hash-key') final  String? hashKey;
@override@JsonKey(name: 'default-selected') final  String? defaultSelected;
@override@JsonKey(name: 'empty-fallback') final  String? emptyFallback;
@override@JsonKey(name: 'include-all') final  bool? includeAll;
@override@JsonKey(name: 'include-all-proxies') final  bool? includeAllProxies;
@override@JsonKey(name: 'include-all-providers') final  bool? includeAllProviders;
@override final  bool? hidden;
@override final  String? icon;
@override final  String? order;

/// Create a copy of ProxyGroup
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProxyGroupCopyWith<_ProxyGroup> get copyWith => __$ProxyGroupCopyWithImpl<_ProxyGroup>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProxyGroupToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProxyGroup&&(identical(other.profileId, profileId) || other.profileId == profileId)&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&const DeepCollectionEquality().equals(other.proxies, _proxies)&&const DeepCollectionEquality().equals(other.use, _use)&&(identical(other.interval, interval) || other.interval == interval)&&(identical(other.lazy, lazy) || other.lazy == lazy)&&(identical(other.disableUDP, disableUDP) || other.disableUDP == disableUDP)&&(identical(other.url, url) || other.url == url)&&(identical(other.timeout, timeout) || other.timeout == timeout)&&(identical(other.maxFailedTimes, maxFailedTimes) || other.maxFailedTimes == maxFailedTimes)&&(identical(other.filter, filter) || other.filter == filter)&&(identical(other.excludeFilter, excludeFilter) || other.excludeFilter == excludeFilter)&&(identical(other.excludeType, excludeType) || other.excludeType == excludeType)&&(identical(other.expectedStatus, expectedStatus) || other.expectedStatus == expectedStatus)&&(identical(other.tolerance, tolerance) || other.tolerance == tolerance)&&(identical(other.strategy, strategy) || other.strategy == strategy)&&(identical(other.hashKey, hashKey) || other.hashKey == hashKey)&&(identical(other.defaultSelected, defaultSelected) || other.defaultSelected == defaultSelected)&&(identical(other.emptyFallback, emptyFallback) || other.emptyFallback == emptyFallback)&&(identical(other.includeAll, includeAll) || other.includeAll == includeAll)&&(identical(other.includeAllProxies, includeAllProxies) || other.includeAllProxies == includeAllProxies)&&(identical(other.includeAllProviders, includeAllProviders) || other.includeAllProviders == includeAllProviders)&&(identical(other.hidden, hidden) || other.hidden == hidden)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.order, order) || other.order == order));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hashAll([runtimeType,profileId,id,name,type,const DeepCollectionEquality().hash(_proxies),const DeepCollectionEquality().hash(_use),interval,lazy,disableUDP,url,timeout,maxFailedTimes,filter,excludeFilter,excludeType,expectedStatus,tolerance,strategy,hashKey,defaultSelected,emptyFallback,includeAll,includeAllProxies,includeAllProviders,hidden,icon,order]);
}

@override
String toString() {
    return 'ProxyGroup(profileId: $profileId, id: $id, name: $name, type: $type, proxies: $proxies, use: $use, interval: $interval, lazy: $lazy, disableUDP: $disableUDP, url: $url, timeout: $timeout, maxFailedTimes: $maxFailedTimes, filter: $filter, excludeFilter: $excludeFilter, excludeType: $excludeType, expectedStatus: $expectedStatus, tolerance: $tolerance, strategy: $strategy, hashKey: $hashKey, defaultSelected: $defaultSelected, emptyFallback: $emptyFallback, includeAll: $includeAll, includeAllProxies: $includeAllProxies, includeAllProviders: $includeAllProviders, hidden: $hidden, icon: $icon, order: $order)';
}


}

/// @nodoc
abstract mixin class _$ProxyGroupCopyWith<$Res> implements $ProxyGroupCopyWith<$Res> {
  factory _$ProxyGroupCopyWith(_ProxyGroup value, $Res Function(_ProxyGroup) _then) = __$ProxyGroupCopyWithImpl;
@override @useResult
$Res call({
 int? profileId,@JsonKey(fromJson: Snowflake.buildId) int id, String name, GroupType type, List<String>? proxies, List<String>? use, int? interval, bool? lazy,@JsonKey(name: 'disable-udp') bool? disableUDP, String? url, int? timeout,@JsonKey(name: 'max-failed-times') int? maxFailedTimes, String? filter,@JsonKey(name: 'exclude-filter') String? excludeFilter,@JsonKey(name: 'exclude-type') String? excludeType,@JsonKey(name: 'expected-status') String? expectedStatus, int? tolerance, LoadBalanceStrategy? strategy,@JsonKey(name: 'hash-key') String? hashKey,@JsonKey(name: 'default-selected') String? defaultSelected,@JsonKey(name: 'empty-fallback') String? emptyFallback,@JsonKey(name: 'include-all') bool? includeAll,@JsonKey(name: 'include-all-proxies') bool? includeAllProxies,@JsonKey(name: 'include-all-providers') bool? includeAllProviders, bool? hidden, String? icon, String? order
});




}
/// @nodoc
class __$ProxyGroupCopyWithImpl<$Res>
    implements _$ProxyGroupCopyWith<$Res> {
  __$ProxyGroupCopyWithImpl(this._self, this._then);

  final _ProxyGroup _self;
  final $Res Function(_ProxyGroup) _then;

/// Create a copy of ProxyGroup
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? profileId = freezed,Object? id = null,Object? name = null,Object? type = null,Object? proxies = freezed,Object? use = freezed,Object? interval = freezed,Object? lazy = freezed,Object? disableUDP = freezed,Object? url = freezed,Object? timeout = freezed,Object? maxFailedTimes = freezed,Object? filter = freezed,Object? excludeFilter = freezed,Object? excludeType = freezed,Object? expectedStatus = freezed,Object? tolerance = freezed,Object? strategy = freezed,Object? hashKey = freezed,Object? defaultSelected = freezed,Object? emptyFallback = freezed,Object? includeAll = freezed,Object? includeAllProxies = freezed,Object? includeAllProviders = freezed,Object? hidden = freezed,Object? icon = freezed,Object? order = freezed,}) {
  return _then(_ProxyGroup(
profileId: freezed == profileId ? _self.profileId : profileId // ignore: cast_nullable_to_non_nullable
as int?,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as GroupType,proxies: freezed == proxies ? _self._proxies : proxies // ignore: cast_nullable_to_non_nullable
as List<String>?,use: freezed == use ? _self._use : use // ignore: cast_nullable_to_non_nullable
as List<String>?,interval: freezed == interval ? _self.interval : interval // ignore: cast_nullable_to_non_nullable
as int?,lazy: freezed == lazy ? _self.lazy : lazy // ignore: cast_nullable_to_non_nullable
as bool?,disableUDP: freezed == disableUDP ? _self.disableUDP : disableUDP // ignore: cast_nullable_to_non_nullable
as bool?,url: freezed == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String?,timeout: freezed == timeout ? _self.timeout : timeout // ignore: cast_nullable_to_non_nullable
as int?,maxFailedTimes: freezed == maxFailedTimes ? _self.maxFailedTimes : maxFailedTimes // ignore: cast_nullable_to_non_nullable
as int?,filter: freezed == filter ? _self.filter : filter // ignore: cast_nullable_to_non_nullable
as String?,excludeFilter: freezed == excludeFilter ? _self.excludeFilter : excludeFilter // ignore: cast_nullable_to_non_nullable
as String?,excludeType: freezed == excludeType ? _self.excludeType : excludeType // ignore: cast_nullable_to_non_nullable
as String?,expectedStatus: freezed == expectedStatus ? _self.expectedStatus : expectedStatus // ignore: cast_nullable_to_non_nullable
as String?,tolerance: freezed == tolerance ? _self.tolerance : tolerance // ignore: cast_nullable_to_non_nullable
as int?,strategy: freezed == strategy ? _self.strategy : strategy // ignore: cast_nullable_to_non_nullable
as LoadBalanceStrategy?,hashKey: freezed == hashKey ? _self.hashKey : hashKey // ignore: cast_nullable_to_non_nullable
as String?,defaultSelected: freezed == defaultSelected ? _self.defaultSelected : defaultSelected // ignore: cast_nullable_to_non_nullable
as String?,emptyFallback: freezed == emptyFallback ? _self.emptyFallback : emptyFallback // ignore: cast_nullable_to_non_nullable
as String?,includeAll: freezed == includeAll ? _self.includeAll : includeAll // ignore: cast_nullable_to_non_nullable
as bool?,includeAllProxies: freezed == includeAllProxies ? _self.includeAllProxies : includeAllProxies // ignore: cast_nullable_to_non_nullable
as bool?,includeAllProviders: freezed == includeAllProviders ? _self.includeAllProviders : includeAllProviders // ignore: cast_nullable_to_non_nullable
as bool?,hidden: freezed == hidden ? _self.hidden : hidden // ignore: cast_nullable_to_non_nullable
as bool?,icon: freezed == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String?,order: freezed == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$Proxy {

 String get name; String get type; String? get now;
/// Create a copy of Proxy
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProxyCopyWith<Proxy> get copyWith => _$ProxyCopyWithImpl<Proxy>(this as Proxy, _$identity);

  /// Serializes this Proxy to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Proxy;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Proxy&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.now, _this.now) || other.now == _this.now));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Proxy;
  return Object.hash(runtimeType,_this.name,_this.type,_this.now);
}

@override
String toString() {
  final _this = this as Proxy;
  return 'Proxy(name: ${_this.name}, type: ${_this.type}, now: ${_this.now})';
}


}

/// @nodoc
abstract mixin class $ProxyCopyWith<$Res>  {
  factory $ProxyCopyWith(Proxy value, $Res Function(Proxy) _then) = _$ProxyCopyWithImpl;
@useResult
$Res call({
 String name, String type, String? now
});




}
/// @nodoc
class _$ProxyCopyWithImpl<$Res>
    implements $ProxyCopyWith<$Res> {
  _$ProxyCopyWithImpl(this._self, this._then);

  final Proxy _self;
  final $Res Function(Proxy) _then;

/// Create a copy of Proxy
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? type = null,Object? now = freezed,}) {
  return _then(Proxy(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,now: freezed == now ? _self.now : now // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Proxy].
extension ProxyPatterns on Proxy {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Proxy value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Proxy() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Proxy value)  $default,){
final _that = this;
switch (_that) {
case _Proxy():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Proxy value)?  $default,){
final _that = this;
switch (_that) {
case _Proxy() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String type,  String? now)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Proxy() when $default != null:
return $default(_that.name,_that.type,_that.now);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String type,  String? now)  $default,) {final _that = this;
switch (_that) {
case _Proxy():
return $default(_that.name,_that.type,_that.now);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String type,  String? now)?  $default,) {final _that = this;
switch (_that) {
case _Proxy() when $default != null:
return $default(_that.name,_that.type,_that.now);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Proxy implements Proxy {
  const _Proxy({required this.name, required this.type, this.now});
  factory _Proxy.fromJson(Map<String, dynamic> json) => _$ProxyFromJson(json);

@override final  String name;
@override final  String type;
@override final  String? now;

/// Create a copy of Proxy
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProxyCopyWith<_Proxy> get copyWith => __$ProxyCopyWithImpl<_Proxy>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProxyToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Proxy&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&(identical(other.now, now) || other.now == now));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,name,type,now);
}

@override
String toString() {
    return 'Proxy(name: $name, type: $type, now: $now)';
}


}

/// @nodoc
abstract mixin class _$ProxyCopyWith<$Res> implements $ProxyCopyWith<$Res> {
  factory _$ProxyCopyWith(_Proxy value, $Res Function(_Proxy) _then) = __$ProxyCopyWithImpl;
@override @useResult
$Res call({
 String name, String type, String? now
});




}
/// @nodoc
class __$ProxyCopyWithImpl<$Res>
    implements _$ProxyCopyWith<$Res> {
  __$ProxyCopyWithImpl(this._self, this._then);

  final _Proxy _self;
  final $Res Function(_Proxy) _then;

/// Create a copy of Proxy
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? type = null,Object? now = freezed,}) {
  return _then(_Proxy(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,now: freezed == now ? _self.now : now // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$CustomProxy {

@JsonKey(fromJson: Snowflake.buildId) int get id; Map<String, dynamic> get definition; String? get order;
/// Create a copy of CustomProxy
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CustomProxyCopyWith<CustomProxy> get copyWith => _$CustomProxyCopyWithImpl<CustomProxy>(this as CustomProxy, _$identity);

  /// Serializes this CustomProxy to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as CustomProxy;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CustomProxy&&(identical(other.id, _this.id) || other.id == _this.id)&&const DeepCollectionEquality().equals(other.definition, _this.definition)&&(identical(other.order, _this.order) || other.order == _this.order));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CustomProxy;
  return Object.hash(runtimeType,_this.id,const DeepCollectionEquality().hash(_this.definition),_this.order);
}

@override
String toString() {
  final _this = this as CustomProxy;
  return 'CustomProxy(id: ${_this.id}, definition: ${_this.definition}, order: ${_this.order})';
}


}

/// @nodoc
abstract mixin class $CustomProxyCopyWith<$Res>  {
  factory $CustomProxyCopyWith(CustomProxy value, $Res Function(CustomProxy) _then) = _$CustomProxyCopyWithImpl;
@useResult
$Res call({
@JsonKey(fromJson: Snowflake.buildId) int id, Map<String, dynamic> definition, String? order
});




}
/// @nodoc
class _$CustomProxyCopyWithImpl<$Res>
    implements $CustomProxyCopyWith<$Res> {
  _$CustomProxyCopyWithImpl(this._self, this._then);

  final CustomProxy _self;
  final $Res Function(CustomProxy) _then;

/// Create a copy of CustomProxy
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? definition = null,Object? order = freezed,}) {
  return _then(CustomProxy(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,definition: null == definition ? _self.definition : definition // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,order: freezed == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CustomProxy].
extension CustomProxyPatterns on CustomProxy {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CustomProxy value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CustomProxy() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CustomProxy value)  $default,){
final _that = this;
switch (_that) {
case _CustomProxy():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CustomProxy value)?  $default,){
final _that = this;
switch (_that) {
case _CustomProxy() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(fromJson: Snowflake.buildId)  int id,  Map<String, dynamic> definition,  String? order)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CustomProxy() when $default != null:
return $default(_that.id,_that.definition,_that.order);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(fromJson: Snowflake.buildId)  int id,  Map<String, dynamic> definition,  String? order)  $default,) {final _that = this;
switch (_that) {
case _CustomProxy():
return $default(_that.id,_that.definition,_that.order);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(fromJson: Snowflake.buildId)  int id,  Map<String, dynamic> definition,  String? order)?  $default,) {final _that = this;
switch (_that) {
case _CustomProxy() when $default != null:
return $default(_that.id,_that.definition,_that.order);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CustomProxy implements CustomProxy {
  const _CustomProxy({@JsonKey(fromJson: Snowflake.buildId) required this.id,  Map<String, dynamic> definition = const {}, this.order}): _definition = definition;
  factory _CustomProxy.fromJson(Map<String, dynamic> json) => _$CustomProxyFromJson(json);

@override@JsonKey(fromJson: Snowflake.buildId) final  int id;
 final  Map<String, dynamic> _definition;
@override@JsonKey() Map<String, dynamic> get definition {
  if (_definition is EqualUnmodifiableMapView) return _definition;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_definition);
}

@override final  String? order;

/// Create a copy of CustomProxy
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CustomProxyCopyWith<_CustomProxy> get copyWith => __$CustomProxyCopyWithImpl<_CustomProxy>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CustomProxyToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CustomProxy&&(identical(other.id, id) || other.id == id)&&const DeepCollectionEquality().equals(other.definition, _definition)&&(identical(other.order, order) || other.order == order));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,const DeepCollectionEquality().hash(_definition),order);
}

@override
String toString() {
    return 'CustomProxy(id: $id, definition: $definition, order: $order)';
}


}

/// @nodoc
abstract mixin class _$CustomProxyCopyWith<$Res> implements $CustomProxyCopyWith<$Res> {
  factory _$CustomProxyCopyWith(_CustomProxy value, $Res Function(_CustomProxy) _then) = __$CustomProxyCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(fromJson: Snowflake.buildId) int id, Map<String, dynamic> definition, String? order
});




}
/// @nodoc
class __$CustomProxyCopyWithImpl<$Res>
    implements _$CustomProxyCopyWith<$Res> {
  __$CustomProxyCopyWithImpl(this._self, this._then);

  final _CustomProxy _self;
  final $Res Function(_CustomProxy) _then;

/// Create a copy of CustomProxy
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? definition = null,Object? order = freezed,}) {
  return _then(_CustomProxy(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,definition: null == definition ? _self._definition : definition // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,order: freezed == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$ProxyDialer {

 int get profileId; int get proxyId; String get target;
/// Create a copy of ProxyDialer
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProxyDialerCopyWith<ProxyDialer> get copyWith => _$ProxyDialerCopyWithImpl<ProxyDialer>(this as ProxyDialer, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ProxyDialer;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProxyDialer&&(identical(other.profileId, _this.profileId) || other.profileId == _this.profileId)&&(identical(other.proxyId, _this.proxyId) || other.proxyId == _this.proxyId)&&(identical(other.target, _this.target) || other.target == _this.target));
}


@override
int get hashCode {
  final _this = this as ProxyDialer;
  return Object.hash(runtimeType,_this.profileId,_this.proxyId,_this.target);
}

@override
String toString() {
  final _this = this as ProxyDialer;
  return 'ProxyDialer(profileId: ${_this.profileId}, proxyId: ${_this.proxyId}, target: ${_this.target})';
}


}

/// @nodoc
abstract mixin class $ProxyDialerCopyWith<$Res>  {
  factory $ProxyDialerCopyWith(ProxyDialer value, $Res Function(ProxyDialer) _then) = _$ProxyDialerCopyWithImpl;
@useResult
$Res call({
 int profileId, int proxyId, String target
});




}
/// @nodoc
class _$ProxyDialerCopyWithImpl<$Res>
    implements $ProxyDialerCopyWith<$Res> {
  _$ProxyDialerCopyWithImpl(this._self, this._then);

  final ProxyDialer _self;
  final $Res Function(ProxyDialer) _then;

/// Create a copy of ProxyDialer
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? profileId = null,Object? proxyId = null,Object? target = null,}) {
  return _then(ProxyDialer(
profileId: null == profileId ? _self.profileId : profileId // ignore: cast_nullable_to_non_nullable
as int,proxyId: null == proxyId ? _self.proxyId : proxyId // ignore: cast_nullable_to_non_nullable
as int,target: null == target ? _self.target : target // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ProxyDialer].
extension ProxyDialerPatterns on ProxyDialer {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProxyDialer value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProxyDialer() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProxyDialer value)  $default,){
final _that = this;
switch (_that) {
case _ProxyDialer():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProxyDialer value)?  $default,){
final _that = this;
switch (_that) {
case _ProxyDialer() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int profileId,  int proxyId,  String target)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProxyDialer() when $default != null:
return $default(_that.profileId,_that.proxyId,_that.target);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int profileId,  int proxyId,  String target)  $default,) {final _that = this;
switch (_that) {
case _ProxyDialer():
return $default(_that.profileId,_that.proxyId,_that.target);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int profileId,  int proxyId,  String target)?  $default,) {final _that = this;
switch (_that) {
case _ProxyDialer() when $default != null:
return $default(_that.profileId,_that.proxyId,_that.target);case _:
  return null;

}
}

}

/// @nodoc


class _ProxyDialer implements ProxyDialer {
  const _ProxyDialer({required this.profileId, required this.proxyId, required this.target});
  

@override final  int profileId;
@override final  int proxyId;
@override final  String target;

/// Create a copy of ProxyDialer
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProxyDialerCopyWith<_ProxyDialer> get copyWith => __$ProxyDialerCopyWithImpl<_ProxyDialer>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProxyDialer&&(identical(other.profileId, profileId) || other.profileId == profileId)&&(identical(other.proxyId, proxyId) || other.proxyId == proxyId)&&(identical(other.target, target) || other.target == target));
}


@override
int get hashCode {
    return Object.hash(runtimeType,profileId,proxyId,target);
}

@override
String toString() {
    return 'ProxyDialer(profileId: $profileId, proxyId: $proxyId, target: $target)';
}


}

/// @nodoc
abstract mixin class _$ProxyDialerCopyWith<$Res> implements $ProxyDialerCopyWith<$Res> {
  factory _$ProxyDialerCopyWith(_ProxyDialer value, $Res Function(_ProxyDialer) _then) = __$ProxyDialerCopyWithImpl;
@override @useResult
$Res call({
 int profileId, int proxyId, String target
});




}
/// @nodoc
class __$ProxyDialerCopyWithImpl<$Res>
    implements _$ProxyDialerCopyWith<$Res> {
  __$ProxyDialerCopyWithImpl(this._self, this._then);

  final _ProxyDialer _self;
  final $Res Function(_ProxyDialer) _then;

/// Create a copy of ProxyDialer
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? profileId = null,Object? proxyId = null,Object? target = null,}) {
  return _then(_ProxyDialer(
profileId: null == profileId ? _self.profileId : profileId // ignore: cast_nullable_to_non_nullable
as int,proxyId: null == proxyId ? _self.proxyId : proxyId // ignore: cast_nullable_to_non_nullable
as int,target: null == target ? _self.target : target // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$CustomIssue {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is CustomIssue);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'CustomIssue()';
}


}

/// @nodoc
class $CustomIssueCopyWith<$Res>  {
$CustomIssueCopyWith(CustomIssue _, $Res Function(CustomIssue) __);
}


/// Adds pattern-matching-related methods to [CustomIssue].
extension CustomIssuePatterns on CustomIssue {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( EmptyNameIssue value)?  emptyName,TResult Function( ReservedNameIssue value)?  reservedName,TResult Function( DuplicateNameIssue value)?  duplicateName,TResult Function( CoreRejectedIssue value)?  coreRejected,TResult Function( MissingProxiesIssue value)?  missingProxies,TResult Function( MissingProvidersIssue value)?  missingProviders,TResult Function( NoProxySourceIssue value)?  noProxySource,TResult Function( GroupLoopIssue value)?  groupLoop,TResult Function( InvalidEmptyFallbackIssue value)?  invalidEmptyFallback,TResult Function( InvalidFilterIssue value)?  invalidFilter,TResult Function( InvalidPayloadIssue value)?  invalidPayload,TResult Function( MissingRuleSetIssue value)?  missingRuleSet,TResult Function( MissingSubRuleIssue value)?  missingSubRule,TResult Function( MissingTargetIssue value)?  missingTarget,TResult Function( MissingDialerIssue value)?  missingDialer,TResult Function( DialerLoopIssue value)?  dialerLoop,required TResult orElse(),}){
final _that = this;
switch (_that) {
case EmptyNameIssue() when emptyName != null:
return emptyName(_that);case ReservedNameIssue() when reservedName != null:
return reservedName(_that);case DuplicateNameIssue() when duplicateName != null:
return duplicateName(_that);case CoreRejectedIssue() when coreRejected != null:
return coreRejected(_that);case MissingProxiesIssue() when missingProxies != null:
return missingProxies(_that);case MissingProvidersIssue() when missingProviders != null:
return missingProviders(_that);case NoProxySourceIssue() when noProxySource != null:
return noProxySource(_that);case GroupLoopIssue() when groupLoop != null:
return groupLoop(_that);case InvalidEmptyFallbackIssue() when invalidEmptyFallback != null:
return invalidEmptyFallback(_that);case InvalidFilterIssue() when invalidFilter != null:
return invalidFilter(_that);case InvalidPayloadIssue() when invalidPayload != null:
return invalidPayload(_that);case MissingRuleSetIssue() when missingRuleSet != null:
return missingRuleSet(_that);case MissingSubRuleIssue() when missingSubRule != null:
return missingSubRule(_that);case MissingTargetIssue() when missingTarget != null:
return missingTarget(_that);case MissingDialerIssue() when missingDialer != null:
return missingDialer(_that);case DialerLoopIssue() when dialerLoop != null:
return dialerLoop(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( EmptyNameIssue value)  emptyName,required TResult Function( ReservedNameIssue value)  reservedName,required TResult Function( DuplicateNameIssue value)  duplicateName,required TResult Function( CoreRejectedIssue value)  coreRejected,required TResult Function( MissingProxiesIssue value)  missingProxies,required TResult Function( MissingProvidersIssue value)  missingProviders,required TResult Function( NoProxySourceIssue value)  noProxySource,required TResult Function( GroupLoopIssue value)  groupLoop,required TResult Function( InvalidEmptyFallbackIssue value)  invalidEmptyFallback,required TResult Function( InvalidFilterIssue value)  invalidFilter,required TResult Function( InvalidPayloadIssue value)  invalidPayload,required TResult Function( MissingRuleSetIssue value)  missingRuleSet,required TResult Function( MissingSubRuleIssue value)  missingSubRule,required TResult Function( MissingTargetIssue value)  missingTarget,required TResult Function( MissingDialerIssue value)  missingDialer,required TResult Function( DialerLoopIssue value)  dialerLoop,}){
final _that = this;
switch (_that) {
case EmptyNameIssue():
return emptyName(_that);case ReservedNameIssue():
return reservedName(_that);case DuplicateNameIssue():
return duplicateName(_that);case CoreRejectedIssue():
return coreRejected(_that);case MissingProxiesIssue():
return missingProxies(_that);case MissingProvidersIssue():
return missingProviders(_that);case NoProxySourceIssue():
return noProxySource(_that);case GroupLoopIssue():
return groupLoop(_that);case InvalidEmptyFallbackIssue():
return invalidEmptyFallback(_that);case InvalidFilterIssue():
return invalidFilter(_that);case InvalidPayloadIssue():
return invalidPayload(_that);case MissingRuleSetIssue():
return missingRuleSet(_that);case MissingSubRuleIssue():
return missingSubRule(_that);case MissingTargetIssue():
return missingTarget(_that);case MissingDialerIssue():
return missingDialer(_that);case DialerLoopIssue():
return dialerLoop(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( EmptyNameIssue value)?  emptyName,TResult? Function( ReservedNameIssue value)?  reservedName,TResult? Function( DuplicateNameIssue value)?  duplicateName,TResult? Function( CoreRejectedIssue value)?  coreRejected,TResult? Function( MissingProxiesIssue value)?  missingProxies,TResult? Function( MissingProvidersIssue value)?  missingProviders,TResult? Function( NoProxySourceIssue value)?  noProxySource,TResult? Function( GroupLoopIssue value)?  groupLoop,TResult? Function( InvalidEmptyFallbackIssue value)?  invalidEmptyFallback,TResult? Function( InvalidFilterIssue value)?  invalidFilter,TResult? Function( InvalidPayloadIssue value)?  invalidPayload,TResult? Function( MissingRuleSetIssue value)?  missingRuleSet,TResult? Function( MissingSubRuleIssue value)?  missingSubRule,TResult? Function( MissingTargetIssue value)?  missingTarget,TResult? Function( MissingDialerIssue value)?  missingDialer,TResult? Function( DialerLoopIssue value)?  dialerLoop,}){
final _that = this;
switch (_that) {
case EmptyNameIssue() when emptyName != null:
return emptyName(_that);case ReservedNameIssue() when reservedName != null:
return reservedName(_that);case DuplicateNameIssue() when duplicateName != null:
return duplicateName(_that);case CoreRejectedIssue() when coreRejected != null:
return coreRejected(_that);case MissingProxiesIssue() when missingProxies != null:
return missingProxies(_that);case MissingProvidersIssue() when missingProviders != null:
return missingProviders(_that);case NoProxySourceIssue() when noProxySource != null:
return noProxySource(_that);case GroupLoopIssue() when groupLoop != null:
return groupLoop(_that);case InvalidEmptyFallbackIssue() when invalidEmptyFallback != null:
return invalidEmptyFallback(_that);case InvalidFilterIssue() when invalidFilter != null:
return invalidFilter(_that);case InvalidPayloadIssue() when invalidPayload != null:
return invalidPayload(_that);case MissingRuleSetIssue() when missingRuleSet != null:
return missingRuleSet(_that);case MissingSubRuleIssue() when missingSubRule != null:
return missingSubRule(_that);case MissingTargetIssue() when missingTarget != null:
return missingTarget(_that);case MissingDialerIssue() when missingDialer != null:
return missingDialer(_that);case DialerLoopIssue() when dialerLoop != null:
return dialerLoop(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  emptyName,TResult Function( String name)?  reservedName,TResult Function( String name)?  duplicateName,TResult Function( String message)?  coreRejected,TResult Function( List<String> names)?  missingProxies,TResult Function( List<String> names)?  missingProviders,TResult Function()?  noProxySource,TResult Function( List<String> names)?  groupLoop,TResult Function( String name)?  invalidEmptyFallback,TResult Function( String name,  String message)?  invalidFilter,TResult Function( RulePayloadError error)?  invalidPayload,TResult Function( String name)?  missingRuleSet,TResult Function( String name)?  missingSubRule,TResult Function( String name)?  missingTarget,TResult Function( String name)?  missingDialer,TResult Function( String proxy,  String target)?  dialerLoop,required TResult orElse(),}) {final _that = this;
switch (_that) {
case EmptyNameIssue() when emptyName != null:
return emptyName();case ReservedNameIssue() when reservedName != null:
return reservedName(_that.name);case DuplicateNameIssue() when duplicateName != null:
return duplicateName(_that.name);case CoreRejectedIssue() when coreRejected != null:
return coreRejected(_that.message);case MissingProxiesIssue() when missingProxies != null:
return missingProxies(_that.names);case MissingProvidersIssue() when missingProviders != null:
return missingProviders(_that.names);case NoProxySourceIssue() when noProxySource != null:
return noProxySource();case GroupLoopIssue() when groupLoop != null:
return groupLoop(_that.names);case InvalidEmptyFallbackIssue() when invalidEmptyFallback != null:
return invalidEmptyFallback(_that.name);case InvalidFilterIssue() when invalidFilter != null:
return invalidFilter(_that.name,_that.message);case InvalidPayloadIssue() when invalidPayload != null:
return invalidPayload(_that.error);case MissingRuleSetIssue() when missingRuleSet != null:
return missingRuleSet(_that.name);case MissingSubRuleIssue() when missingSubRule != null:
return missingSubRule(_that.name);case MissingTargetIssue() when missingTarget != null:
return missingTarget(_that.name);case MissingDialerIssue() when missingDialer != null:
return missingDialer(_that.name);case DialerLoopIssue() when dialerLoop != null:
return dialerLoop(_that.proxy,_that.target);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  emptyName,required TResult Function( String name)  reservedName,required TResult Function( String name)  duplicateName,required TResult Function( String message)  coreRejected,required TResult Function( List<String> names)  missingProxies,required TResult Function( List<String> names)  missingProviders,required TResult Function()  noProxySource,required TResult Function( List<String> names)  groupLoop,required TResult Function( String name)  invalidEmptyFallback,required TResult Function( String name,  String message)  invalidFilter,required TResult Function( RulePayloadError error)  invalidPayload,required TResult Function( String name)  missingRuleSet,required TResult Function( String name)  missingSubRule,required TResult Function( String name)  missingTarget,required TResult Function( String name)  missingDialer,required TResult Function( String proxy,  String target)  dialerLoop,}) {final _that = this;
switch (_that) {
case EmptyNameIssue():
return emptyName();case ReservedNameIssue():
return reservedName(_that.name);case DuplicateNameIssue():
return duplicateName(_that.name);case CoreRejectedIssue():
return coreRejected(_that.message);case MissingProxiesIssue():
return missingProxies(_that.names);case MissingProvidersIssue():
return missingProviders(_that.names);case NoProxySourceIssue():
return noProxySource();case GroupLoopIssue():
return groupLoop(_that.names);case InvalidEmptyFallbackIssue():
return invalidEmptyFallback(_that.name);case InvalidFilterIssue():
return invalidFilter(_that.name,_that.message);case InvalidPayloadIssue():
return invalidPayload(_that.error);case MissingRuleSetIssue():
return missingRuleSet(_that.name);case MissingSubRuleIssue():
return missingSubRule(_that.name);case MissingTargetIssue():
return missingTarget(_that.name);case MissingDialerIssue():
return missingDialer(_that.name);case DialerLoopIssue():
return dialerLoop(_that.proxy,_that.target);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  emptyName,TResult? Function( String name)?  reservedName,TResult? Function( String name)?  duplicateName,TResult? Function( String message)?  coreRejected,TResult? Function( List<String> names)?  missingProxies,TResult? Function( List<String> names)?  missingProviders,TResult? Function()?  noProxySource,TResult? Function( List<String> names)?  groupLoop,TResult? Function( String name)?  invalidEmptyFallback,TResult? Function( String name,  String message)?  invalidFilter,TResult? Function( RulePayloadError error)?  invalidPayload,TResult? Function( String name)?  missingRuleSet,TResult? Function( String name)?  missingSubRule,TResult? Function( String name)?  missingTarget,TResult? Function( String name)?  missingDialer,TResult? Function( String proxy,  String target)?  dialerLoop,}) {final _that = this;
switch (_that) {
case EmptyNameIssue() when emptyName != null:
return emptyName();case ReservedNameIssue() when reservedName != null:
return reservedName(_that.name);case DuplicateNameIssue() when duplicateName != null:
return duplicateName(_that.name);case CoreRejectedIssue() when coreRejected != null:
return coreRejected(_that.message);case MissingProxiesIssue() when missingProxies != null:
return missingProxies(_that.names);case MissingProvidersIssue() when missingProviders != null:
return missingProviders(_that.names);case NoProxySourceIssue() when noProxySource != null:
return noProxySource();case GroupLoopIssue() when groupLoop != null:
return groupLoop(_that.names);case InvalidEmptyFallbackIssue() when invalidEmptyFallback != null:
return invalidEmptyFallback(_that.name);case InvalidFilterIssue() when invalidFilter != null:
return invalidFilter(_that.name,_that.message);case InvalidPayloadIssue() when invalidPayload != null:
return invalidPayload(_that.error);case MissingRuleSetIssue() when missingRuleSet != null:
return missingRuleSet(_that.name);case MissingSubRuleIssue() when missingSubRule != null:
return missingSubRule(_that.name);case MissingTargetIssue() when missingTarget != null:
return missingTarget(_that.name);case MissingDialerIssue() when missingDialer != null:
return missingDialer(_that.name);case DialerLoopIssue() when dialerLoop != null:
return dialerLoop(_that.proxy,_that.target);case _:
  return null;

}
}

}

/// @nodoc


class EmptyNameIssue implements CustomIssue {
  const EmptyNameIssue();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is EmptyNameIssue);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'CustomIssue.emptyName()';
}


}




/// @nodoc


class ReservedNameIssue implements CustomIssue {
  const ReservedNameIssue(this.name);
  

 final  String name;

/// Create a copy of CustomIssue
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReservedNameIssueCopyWith<ReservedNameIssue> get copyWith => _$ReservedNameIssueCopyWithImpl<ReservedNameIssue>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ReservedNameIssue&&(identical(other.name, name) || other.name == name));
}


@override
int get hashCode {
    return Object.hash(runtimeType,name);
}

@override
String toString() {
    return 'CustomIssue.reservedName(name: $name)';
}


}

/// @nodoc
abstract mixin class $ReservedNameIssueCopyWith<$Res> implements $CustomIssueCopyWith<$Res> {
  factory $ReservedNameIssueCopyWith(ReservedNameIssue value, $Res Function(ReservedNameIssue) _then) = _$ReservedNameIssueCopyWithImpl;
@useResult
$Res call({
 String name
});




}
/// @nodoc
class _$ReservedNameIssueCopyWithImpl<$Res>
    implements $ReservedNameIssueCopyWith<$Res> {
  _$ReservedNameIssueCopyWithImpl(this._self, this._then);

  final ReservedNameIssue _self;
  final $Res Function(ReservedNameIssue) _then;

/// Create a copy of CustomIssue
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? name = null,}) {
  return _then(ReservedNameIssue(
null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class DuplicateNameIssue implements CustomIssue {
  const DuplicateNameIssue(this.name);
  

 final  String name;

/// Create a copy of CustomIssue
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DuplicateNameIssueCopyWith<DuplicateNameIssue> get copyWith => _$DuplicateNameIssueCopyWithImpl<DuplicateNameIssue>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is DuplicateNameIssue&&(identical(other.name, name) || other.name == name));
}


@override
int get hashCode {
    return Object.hash(runtimeType,name);
}

@override
String toString() {
    return 'CustomIssue.duplicateName(name: $name)';
}


}

/// @nodoc
abstract mixin class $DuplicateNameIssueCopyWith<$Res> implements $CustomIssueCopyWith<$Res> {
  factory $DuplicateNameIssueCopyWith(DuplicateNameIssue value, $Res Function(DuplicateNameIssue) _then) = _$DuplicateNameIssueCopyWithImpl;
@useResult
$Res call({
 String name
});




}
/// @nodoc
class _$DuplicateNameIssueCopyWithImpl<$Res>
    implements $DuplicateNameIssueCopyWith<$Res> {
  _$DuplicateNameIssueCopyWithImpl(this._self, this._then);

  final DuplicateNameIssue _self;
  final $Res Function(DuplicateNameIssue) _then;

/// Create a copy of CustomIssue
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? name = null,}) {
  return _then(DuplicateNameIssue(
null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class CoreRejectedIssue implements CustomIssue {
  const CoreRejectedIssue(this.message);
  

 final  String message;

/// Create a copy of CustomIssue
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CoreRejectedIssueCopyWith<CoreRejectedIssue> get copyWith => _$CoreRejectedIssueCopyWithImpl<CoreRejectedIssue>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is CoreRejectedIssue&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode {
    return Object.hash(runtimeType,message);
}

@override
String toString() {
    return 'CustomIssue.coreRejected(message: $message)';
}


}

/// @nodoc
abstract mixin class $CoreRejectedIssueCopyWith<$Res> implements $CustomIssueCopyWith<$Res> {
  factory $CoreRejectedIssueCopyWith(CoreRejectedIssue value, $Res Function(CoreRejectedIssue) _then) = _$CoreRejectedIssueCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class _$CoreRejectedIssueCopyWithImpl<$Res>
    implements $CoreRejectedIssueCopyWith<$Res> {
  _$CoreRejectedIssueCopyWithImpl(this._self, this._then);

  final CoreRejectedIssue _self;
  final $Res Function(CoreRejectedIssue) _then;

/// Create a copy of CustomIssue
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(CoreRejectedIssue(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class MissingProxiesIssue implements CustomIssue {
  const MissingProxiesIssue( List<String> names): _names = names;
  

 final  List<String> _names;
 List<String> get names {
  if (_names is EqualUnmodifiableListView) return _names;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_names);
}


/// Create a copy of CustomIssue
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MissingProxiesIssueCopyWith<MissingProxiesIssue> get copyWith => _$MissingProxiesIssueCopyWithImpl<MissingProxiesIssue>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is MissingProxiesIssue&&const DeepCollectionEquality().equals(other.names, _names));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_names));
}

@override
String toString() {
    return 'CustomIssue.missingProxies(names: $names)';
}


}

/// @nodoc
abstract mixin class $MissingProxiesIssueCopyWith<$Res> implements $CustomIssueCopyWith<$Res> {
  factory $MissingProxiesIssueCopyWith(MissingProxiesIssue value, $Res Function(MissingProxiesIssue) _then) = _$MissingProxiesIssueCopyWithImpl;
@useResult
$Res call({
 List<String> names
});




}
/// @nodoc
class _$MissingProxiesIssueCopyWithImpl<$Res>
    implements $MissingProxiesIssueCopyWith<$Res> {
  _$MissingProxiesIssueCopyWithImpl(this._self, this._then);

  final MissingProxiesIssue _self;
  final $Res Function(MissingProxiesIssue) _then;

/// Create a copy of CustomIssue
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? names = null,}) {
  return _then(MissingProxiesIssue(
null == names ? _self._names : names // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

/// @nodoc


class MissingProvidersIssue implements CustomIssue {
  const MissingProvidersIssue( List<String> names): _names = names;
  

 final  List<String> _names;
 List<String> get names {
  if (_names is EqualUnmodifiableListView) return _names;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_names);
}


/// Create a copy of CustomIssue
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MissingProvidersIssueCopyWith<MissingProvidersIssue> get copyWith => _$MissingProvidersIssueCopyWithImpl<MissingProvidersIssue>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is MissingProvidersIssue&&const DeepCollectionEquality().equals(other.names, _names));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_names));
}

@override
String toString() {
    return 'CustomIssue.missingProviders(names: $names)';
}


}

/// @nodoc
abstract mixin class $MissingProvidersIssueCopyWith<$Res> implements $CustomIssueCopyWith<$Res> {
  factory $MissingProvidersIssueCopyWith(MissingProvidersIssue value, $Res Function(MissingProvidersIssue) _then) = _$MissingProvidersIssueCopyWithImpl;
@useResult
$Res call({
 List<String> names
});




}
/// @nodoc
class _$MissingProvidersIssueCopyWithImpl<$Res>
    implements $MissingProvidersIssueCopyWith<$Res> {
  _$MissingProvidersIssueCopyWithImpl(this._self, this._then);

  final MissingProvidersIssue _self;
  final $Res Function(MissingProvidersIssue) _then;

/// Create a copy of CustomIssue
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? names = null,}) {
  return _then(MissingProvidersIssue(
null == names ? _self._names : names // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

/// @nodoc


class NoProxySourceIssue implements CustomIssue {
  const NoProxySourceIssue();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is NoProxySourceIssue);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'CustomIssue.noProxySource()';
}


}




/// @nodoc


class GroupLoopIssue implements CustomIssue {
  const GroupLoopIssue( List<String> names): _names = names;
  

 final  List<String> _names;
 List<String> get names {
  if (_names is EqualUnmodifiableListView) return _names;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_names);
}


/// Create a copy of CustomIssue
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GroupLoopIssueCopyWith<GroupLoopIssue> get copyWith => _$GroupLoopIssueCopyWithImpl<GroupLoopIssue>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is GroupLoopIssue&&const DeepCollectionEquality().equals(other.names, _names));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_names));
}

@override
String toString() {
    return 'CustomIssue.groupLoop(names: $names)';
}


}

/// @nodoc
abstract mixin class $GroupLoopIssueCopyWith<$Res> implements $CustomIssueCopyWith<$Res> {
  factory $GroupLoopIssueCopyWith(GroupLoopIssue value, $Res Function(GroupLoopIssue) _then) = _$GroupLoopIssueCopyWithImpl;
@useResult
$Res call({
 List<String> names
});




}
/// @nodoc
class _$GroupLoopIssueCopyWithImpl<$Res>
    implements $GroupLoopIssueCopyWith<$Res> {
  _$GroupLoopIssueCopyWithImpl(this._self, this._then);

  final GroupLoopIssue _self;
  final $Res Function(GroupLoopIssue) _then;

/// Create a copy of CustomIssue
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? names = null,}) {
  return _then(GroupLoopIssue(
null == names ? _self._names : names // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

/// @nodoc


class InvalidEmptyFallbackIssue implements CustomIssue {
  const InvalidEmptyFallbackIssue(this.name);
  

 final  String name;

/// Create a copy of CustomIssue
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InvalidEmptyFallbackIssueCopyWith<InvalidEmptyFallbackIssue> get copyWith => _$InvalidEmptyFallbackIssueCopyWithImpl<InvalidEmptyFallbackIssue>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is InvalidEmptyFallbackIssue&&(identical(other.name, name) || other.name == name));
}


@override
int get hashCode {
    return Object.hash(runtimeType,name);
}

@override
String toString() {
    return 'CustomIssue.invalidEmptyFallback(name: $name)';
}


}

/// @nodoc
abstract mixin class $InvalidEmptyFallbackIssueCopyWith<$Res> implements $CustomIssueCopyWith<$Res> {
  factory $InvalidEmptyFallbackIssueCopyWith(InvalidEmptyFallbackIssue value, $Res Function(InvalidEmptyFallbackIssue) _then) = _$InvalidEmptyFallbackIssueCopyWithImpl;
@useResult
$Res call({
 String name
});




}
/// @nodoc
class _$InvalidEmptyFallbackIssueCopyWithImpl<$Res>
    implements $InvalidEmptyFallbackIssueCopyWith<$Res> {
  _$InvalidEmptyFallbackIssueCopyWithImpl(this._self, this._then);

  final InvalidEmptyFallbackIssue _self;
  final $Res Function(InvalidEmptyFallbackIssue) _then;

/// Create a copy of CustomIssue
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? name = null,}) {
  return _then(InvalidEmptyFallbackIssue(
null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class InvalidFilterIssue implements CustomIssue {
  const InvalidFilterIssue(this.name, this.message);
  

 final  String name;
 final  String message;

/// Create a copy of CustomIssue
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InvalidFilterIssueCopyWith<InvalidFilterIssue> get copyWith => _$InvalidFilterIssueCopyWithImpl<InvalidFilterIssue>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is InvalidFilterIssue&&(identical(other.name, name) || other.name == name)&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode {
    return Object.hash(runtimeType,name,message);
}

@override
String toString() {
    return 'CustomIssue.invalidFilter(name: $name, message: $message)';
}


}

/// @nodoc
abstract mixin class $InvalidFilterIssueCopyWith<$Res> implements $CustomIssueCopyWith<$Res> {
  factory $InvalidFilterIssueCopyWith(InvalidFilterIssue value, $Res Function(InvalidFilterIssue) _then) = _$InvalidFilterIssueCopyWithImpl;
@useResult
$Res call({
 String name, String message
});




}
/// @nodoc
class _$InvalidFilterIssueCopyWithImpl<$Res>
    implements $InvalidFilterIssueCopyWith<$Res> {
  _$InvalidFilterIssueCopyWithImpl(this._self, this._then);

  final InvalidFilterIssue _self;
  final $Res Function(InvalidFilterIssue) _then;

/// Create a copy of CustomIssue
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? name = null,Object? message = null,}) {
  return _then(InvalidFilterIssue(
null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class InvalidPayloadIssue implements CustomIssue {
  const InvalidPayloadIssue(this.error);
  

 final  RulePayloadError error;

/// Create a copy of CustomIssue
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InvalidPayloadIssueCopyWith<InvalidPayloadIssue> get copyWith => _$InvalidPayloadIssueCopyWithImpl<InvalidPayloadIssue>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is InvalidPayloadIssue&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode {
    return Object.hash(runtimeType,error);
}

@override
String toString() {
    return 'CustomIssue.invalidPayload(error: $error)';
}


}

/// @nodoc
abstract mixin class $InvalidPayloadIssueCopyWith<$Res> implements $CustomIssueCopyWith<$Res> {
  factory $InvalidPayloadIssueCopyWith(InvalidPayloadIssue value, $Res Function(InvalidPayloadIssue) _then) = _$InvalidPayloadIssueCopyWithImpl;
@useResult
$Res call({
 RulePayloadError error
});




}
/// @nodoc
class _$InvalidPayloadIssueCopyWithImpl<$Res>
    implements $InvalidPayloadIssueCopyWith<$Res> {
  _$InvalidPayloadIssueCopyWithImpl(this._self, this._then);

  final InvalidPayloadIssue _self;
  final $Res Function(InvalidPayloadIssue) _then;

/// Create a copy of CustomIssue
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? error = null,}) {
  return _then(InvalidPayloadIssue(
null == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as RulePayloadError,
  ));
}


}

/// @nodoc


class MissingRuleSetIssue implements CustomIssue {
  const MissingRuleSetIssue(this.name);
  

 final  String name;

/// Create a copy of CustomIssue
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MissingRuleSetIssueCopyWith<MissingRuleSetIssue> get copyWith => _$MissingRuleSetIssueCopyWithImpl<MissingRuleSetIssue>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is MissingRuleSetIssue&&(identical(other.name, name) || other.name == name));
}


@override
int get hashCode {
    return Object.hash(runtimeType,name);
}

@override
String toString() {
    return 'CustomIssue.missingRuleSet(name: $name)';
}


}

/// @nodoc
abstract mixin class $MissingRuleSetIssueCopyWith<$Res> implements $CustomIssueCopyWith<$Res> {
  factory $MissingRuleSetIssueCopyWith(MissingRuleSetIssue value, $Res Function(MissingRuleSetIssue) _then) = _$MissingRuleSetIssueCopyWithImpl;
@useResult
$Res call({
 String name
});




}
/// @nodoc
class _$MissingRuleSetIssueCopyWithImpl<$Res>
    implements $MissingRuleSetIssueCopyWith<$Res> {
  _$MissingRuleSetIssueCopyWithImpl(this._self, this._then);

  final MissingRuleSetIssue _self;
  final $Res Function(MissingRuleSetIssue) _then;

/// Create a copy of CustomIssue
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? name = null,}) {
  return _then(MissingRuleSetIssue(
null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class MissingSubRuleIssue implements CustomIssue {
  const MissingSubRuleIssue(this.name);
  

 final  String name;

/// Create a copy of CustomIssue
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MissingSubRuleIssueCopyWith<MissingSubRuleIssue> get copyWith => _$MissingSubRuleIssueCopyWithImpl<MissingSubRuleIssue>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is MissingSubRuleIssue&&(identical(other.name, name) || other.name == name));
}


@override
int get hashCode {
    return Object.hash(runtimeType,name);
}

@override
String toString() {
    return 'CustomIssue.missingSubRule(name: $name)';
}


}

/// @nodoc
abstract mixin class $MissingSubRuleIssueCopyWith<$Res> implements $CustomIssueCopyWith<$Res> {
  factory $MissingSubRuleIssueCopyWith(MissingSubRuleIssue value, $Res Function(MissingSubRuleIssue) _then) = _$MissingSubRuleIssueCopyWithImpl;
@useResult
$Res call({
 String name
});




}
/// @nodoc
class _$MissingSubRuleIssueCopyWithImpl<$Res>
    implements $MissingSubRuleIssueCopyWith<$Res> {
  _$MissingSubRuleIssueCopyWithImpl(this._self, this._then);

  final MissingSubRuleIssue _self;
  final $Res Function(MissingSubRuleIssue) _then;

/// Create a copy of CustomIssue
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? name = null,}) {
  return _then(MissingSubRuleIssue(
null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class MissingTargetIssue implements CustomIssue {
  const MissingTargetIssue(this.name);
  

 final  String name;

/// Create a copy of CustomIssue
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MissingTargetIssueCopyWith<MissingTargetIssue> get copyWith => _$MissingTargetIssueCopyWithImpl<MissingTargetIssue>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is MissingTargetIssue&&(identical(other.name, name) || other.name == name));
}


@override
int get hashCode {
    return Object.hash(runtimeType,name);
}

@override
String toString() {
    return 'CustomIssue.missingTarget(name: $name)';
}


}

/// @nodoc
abstract mixin class $MissingTargetIssueCopyWith<$Res> implements $CustomIssueCopyWith<$Res> {
  factory $MissingTargetIssueCopyWith(MissingTargetIssue value, $Res Function(MissingTargetIssue) _then) = _$MissingTargetIssueCopyWithImpl;
@useResult
$Res call({
 String name
});




}
/// @nodoc
class _$MissingTargetIssueCopyWithImpl<$Res>
    implements $MissingTargetIssueCopyWith<$Res> {
  _$MissingTargetIssueCopyWithImpl(this._self, this._then);

  final MissingTargetIssue _self;
  final $Res Function(MissingTargetIssue) _then;

/// Create a copy of CustomIssue
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? name = null,}) {
  return _then(MissingTargetIssue(
null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class MissingDialerIssue implements CustomIssue {
  const MissingDialerIssue(this.name);
  

 final  String name;

/// Create a copy of CustomIssue
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MissingDialerIssueCopyWith<MissingDialerIssue> get copyWith => _$MissingDialerIssueCopyWithImpl<MissingDialerIssue>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is MissingDialerIssue&&(identical(other.name, name) || other.name == name));
}


@override
int get hashCode {
    return Object.hash(runtimeType,name);
}

@override
String toString() {
    return 'CustomIssue.missingDialer(name: $name)';
}


}

/// @nodoc
abstract mixin class $MissingDialerIssueCopyWith<$Res> implements $CustomIssueCopyWith<$Res> {
  factory $MissingDialerIssueCopyWith(MissingDialerIssue value, $Res Function(MissingDialerIssue) _then) = _$MissingDialerIssueCopyWithImpl;
@useResult
$Res call({
 String name
});




}
/// @nodoc
class _$MissingDialerIssueCopyWithImpl<$Res>
    implements $MissingDialerIssueCopyWith<$Res> {
  _$MissingDialerIssueCopyWithImpl(this._self, this._then);

  final MissingDialerIssue _self;
  final $Res Function(MissingDialerIssue) _then;

/// Create a copy of CustomIssue
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? name = null,}) {
  return _then(MissingDialerIssue(
null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class DialerLoopIssue implements CustomIssue {
  const DialerLoopIssue(this.proxy, this.target);
  

 final  String proxy;
 final  String target;

/// Create a copy of CustomIssue
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DialerLoopIssueCopyWith<DialerLoopIssue> get copyWith => _$DialerLoopIssueCopyWithImpl<DialerLoopIssue>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is DialerLoopIssue&&(identical(other.proxy, proxy) || other.proxy == proxy)&&(identical(other.target, target) || other.target == target));
}


@override
int get hashCode {
    return Object.hash(runtimeType,proxy,target);
}

@override
String toString() {
    return 'CustomIssue.dialerLoop(proxy: $proxy, target: $target)';
}


}

/// @nodoc
abstract mixin class $DialerLoopIssueCopyWith<$Res> implements $CustomIssueCopyWith<$Res> {
  factory $DialerLoopIssueCopyWith(DialerLoopIssue value, $Res Function(DialerLoopIssue) _then) = _$DialerLoopIssueCopyWithImpl;
@useResult
$Res call({
 String proxy, String target
});




}
/// @nodoc
class _$DialerLoopIssueCopyWithImpl<$Res>
    implements $DialerLoopIssueCopyWith<$Res> {
  _$DialerLoopIssueCopyWithImpl(this._self, this._then);

  final DialerLoopIssue _self;
  final $Res Function(DialerLoopIssue) _then;

/// Create a copy of CustomIssue
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? proxy = null,Object? target = null,}) {
  return _then(DialerLoopIssue(
null == proxy ? _self.proxy : proxy // ignore: cast_nullable_to_non_nullable
as String,null == target ? _self.target : target // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$CustomProfileIssues {

 Map<int, List<CustomIssue>> get proxyGroups; Map<int, List<CustomIssue>> get rules; Map<int, List<CustomIssue>> get dialers; List<CustomIssue> get dns; List<CustomIssue> get ntp;
/// Create a copy of CustomProfileIssues
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CustomProfileIssuesCopyWith<CustomProfileIssues> get copyWith => _$CustomProfileIssuesCopyWithImpl<CustomProfileIssues>(this as CustomProfileIssues, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as CustomProfileIssues;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CustomProfileIssues&&const DeepCollectionEquality().equals(other.proxyGroups, _this.proxyGroups)&&const DeepCollectionEquality().equals(other.rules, _this.rules)&&const DeepCollectionEquality().equals(other.dialers, _this.dialers)&&const DeepCollectionEquality().equals(other.dns, _this.dns)&&const DeepCollectionEquality().equals(other.ntp, _this.ntp));
}


@override
int get hashCode {
  final _this = this as CustomProfileIssues;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.proxyGroups),const DeepCollectionEquality().hash(_this.rules),const DeepCollectionEquality().hash(_this.dialers),const DeepCollectionEquality().hash(_this.dns),const DeepCollectionEquality().hash(_this.ntp));
}

@override
String toString() {
  final _this = this as CustomProfileIssues;
  return 'CustomProfileIssues(proxyGroups: ${_this.proxyGroups}, rules: ${_this.rules}, dialers: ${_this.dialers}, dns: ${_this.dns}, ntp: ${_this.ntp})';
}


}

/// @nodoc
abstract mixin class $CustomProfileIssuesCopyWith<$Res>  {
  factory $CustomProfileIssuesCopyWith(CustomProfileIssues value, $Res Function(CustomProfileIssues) _then) = _$CustomProfileIssuesCopyWithImpl;
@useResult
$Res call({
 Map<int, List<CustomIssue>> proxyGroups, Map<int, List<CustomIssue>> rules, Map<int, List<CustomIssue>> dialers, List<CustomIssue> dns, List<CustomIssue> ntp
});




}
/// @nodoc
class _$CustomProfileIssuesCopyWithImpl<$Res>
    implements $CustomProfileIssuesCopyWith<$Res> {
  _$CustomProfileIssuesCopyWithImpl(this._self, this._then);

  final CustomProfileIssues _self;
  final $Res Function(CustomProfileIssues) _then;

/// Create a copy of CustomProfileIssues
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? proxyGroups = null,Object? rules = null,Object? dialers = null,Object? dns = null,Object? ntp = null,}) {
  return _then(CustomProfileIssues(
proxyGroups: null == proxyGroups ? _self.proxyGroups : proxyGroups // ignore: cast_nullable_to_non_nullable
as Map<int, List<CustomIssue>>,rules: null == rules ? _self.rules : rules // ignore: cast_nullable_to_non_nullable
as Map<int, List<CustomIssue>>,dialers: null == dialers ? _self.dialers : dialers // ignore: cast_nullable_to_non_nullable
as Map<int, List<CustomIssue>>,dns: null == dns ? _self.dns : dns // ignore: cast_nullable_to_non_nullable
as List<CustomIssue>,ntp: null == ntp ? _self.ntp : ntp // ignore: cast_nullable_to_non_nullable
as List<CustomIssue>,
  ));
}

}


/// Adds pattern-matching-related methods to [CustomProfileIssues].
extension CustomProfileIssuesPatterns on CustomProfileIssues {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CustomProfileIssues value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CustomProfileIssues() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CustomProfileIssues value)  $default,){
final _that = this;
switch (_that) {
case _CustomProfileIssues():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CustomProfileIssues value)?  $default,){
final _that = this;
switch (_that) {
case _CustomProfileIssues() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Map<int, List<CustomIssue>> proxyGroups,  Map<int, List<CustomIssue>> rules,  Map<int, List<CustomIssue>> dialers,  List<CustomIssue> dns,  List<CustomIssue> ntp)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CustomProfileIssues() when $default != null:
return $default(_that.proxyGroups,_that.rules,_that.dialers,_that.dns,_that.ntp);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Map<int, List<CustomIssue>> proxyGroups,  Map<int, List<CustomIssue>> rules,  Map<int, List<CustomIssue>> dialers,  List<CustomIssue> dns,  List<CustomIssue> ntp)  $default,) {final _that = this;
switch (_that) {
case _CustomProfileIssues():
return $default(_that.proxyGroups,_that.rules,_that.dialers,_that.dns,_that.ntp);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Map<int, List<CustomIssue>> proxyGroups,  Map<int, List<CustomIssue>> rules,  Map<int, List<CustomIssue>> dialers,  List<CustomIssue> dns,  List<CustomIssue> ntp)?  $default,) {final _that = this;
switch (_that) {
case _CustomProfileIssues() when $default != null:
return $default(_that.proxyGroups,_that.rules,_that.dialers,_that.dns,_that.ntp);case _:
  return null;

}
}

}

/// @nodoc


class _CustomProfileIssues implements CustomProfileIssues {
  const _CustomProfileIssues({ Map<int, List<CustomIssue>> proxyGroups = const {},  Map<int, List<CustomIssue>> rules = const {},  Map<int, List<CustomIssue>> dialers = const {},  List<CustomIssue> dns = const [],  List<CustomIssue> ntp = const []}): _proxyGroups = proxyGroups,_rules = rules,_dialers = dialers,_dns = dns,_ntp = ntp;
  

 final  Map<int, List<CustomIssue>> _proxyGroups;
@override@JsonKey() Map<int, List<CustomIssue>> get proxyGroups {
  if (_proxyGroups is EqualUnmodifiableMapView) return _proxyGroups;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_proxyGroups);
}

 final  Map<int, List<CustomIssue>> _rules;
@override@JsonKey() Map<int, List<CustomIssue>> get rules {
  if (_rules is EqualUnmodifiableMapView) return _rules;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_rules);
}

 final  Map<int, List<CustomIssue>> _dialers;
@override@JsonKey() Map<int, List<CustomIssue>> get dialers {
  if (_dialers is EqualUnmodifiableMapView) return _dialers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_dialers);
}

 final  List<CustomIssue> _dns;
@override@JsonKey() List<CustomIssue> get dns {
  if (_dns is EqualUnmodifiableListView) return _dns;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_dns);
}

 final  List<CustomIssue> _ntp;
@override@JsonKey() List<CustomIssue> get ntp {
  if (_ntp is EqualUnmodifiableListView) return _ntp;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_ntp);
}


/// Create a copy of CustomProfileIssues
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CustomProfileIssuesCopyWith<_CustomProfileIssues> get copyWith => __$CustomProfileIssuesCopyWithImpl<_CustomProfileIssues>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CustomProfileIssues&&const DeepCollectionEquality().equals(other.proxyGroups, _proxyGroups)&&const DeepCollectionEquality().equals(other.rules, _rules)&&const DeepCollectionEquality().equals(other.dialers, _dialers)&&const DeepCollectionEquality().equals(other.dns, _dns)&&const DeepCollectionEquality().equals(other.ntp, _ntp));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_proxyGroups),const DeepCollectionEquality().hash(_rules),const DeepCollectionEquality().hash(_dialers),const DeepCollectionEquality().hash(_dns),const DeepCollectionEquality().hash(_ntp));
}

@override
String toString() {
    return 'CustomProfileIssues(proxyGroups: $proxyGroups, rules: $rules, dialers: $dialers, dns: $dns, ntp: $ntp)';
}


}

/// @nodoc
abstract mixin class _$CustomProfileIssuesCopyWith<$Res> implements $CustomProfileIssuesCopyWith<$Res> {
  factory _$CustomProfileIssuesCopyWith(_CustomProfileIssues value, $Res Function(_CustomProfileIssues) _then) = __$CustomProfileIssuesCopyWithImpl;
@override @useResult
$Res call({
 Map<int, List<CustomIssue>> proxyGroups, Map<int, List<CustomIssue>> rules, Map<int, List<CustomIssue>> dialers, List<CustomIssue> dns, List<CustomIssue> ntp
});




}
/// @nodoc
class __$CustomProfileIssuesCopyWithImpl<$Res>
    implements _$CustomProfileIssuesCopyWith<$Res> {
  __$CustomProfileIssuesCopyWithImpl(this._self, this._then);

  final _CustomProfileIssues _self;
  final $Res Function(_CustomProfileIssues) _then;

/// Create a copy of CustomProfileIssues
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? proxyGroups = null,Object? rules = null,Object? dialers = null,Object? dns = null,Object? ntp = null,}) {
  return _then(_CustomProfileIssues(
proxyGroups: null == proxyGroups ? _self._proxyGroups : proxyGroups // ignore: cast_nullable_to_non_nullable
as Map<int, List<CustomIssue>>,rules: null == rules ? _self._rules : rules // ignore: cast_nullable_to_non_nullable
as Map<int, List<CustomIssue>>,dialers: null == dialers ? _self._dialers : dialers // ignore: cast_nullable_to_non_nullable
as Map<int, List<CustomIssue>>,dns: null == dns ? _self._dns : dns // ignore: cast_nullable_to_non_nullable
as List<CustomIssue>,ntp: null == ntp ? _self._ntp : ntp // ignore: cast_nullable_to_non_nullable
as List<CustomIssue>,
  ));
}


}

/// @nodoc
mixin _$CustomProfileData {

 List<ProxyGroup> get proxyGroups; Set<String> get proxyProviders; Set<String> get ruleProviders; Set<String> get ruleTargets; Set<String> get proxies; Map<String, String> get dialers;
/// Create a copy of CustomProfileData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CustomProfileDataCopyWith<CustomProfileData> get copyWith => _$CustomProfileDataCopyWithImpl<CustomProfileData>(this as CustomProfileData, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as CustomProfileData;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CustomProfileData&&const DeepCollectionEquality().equals(other.proxyGroups, _this.proxyGroups)&&const DeepCollectionEquality().equals(other.proxyProviders, _this.proxyProviders)&&const DeepCollectionEquality().equals(other.ruleProviders, _this.ruleProviders)&&const DeepCollectionEquality().equals(other.ruleTargets, _this.ruleTargets)&&const DeepCollectionEquality().equals(other.proxies, _this.proxies)&&const DeepCollectionEquality().equals(other.dialers, _this.dialers));
}


@override
int get hashCode {
  final _this = this as CustomProfileData;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.proxyGroups),const DeepCollectionEquality().hash(_this.proxyProviders),const DeepCollectionEquality().hash(_this.ruleProviders),const DeepCollectionEquality().hash(_this.ruleTargets),const DeepCollectionEquality().hash(_this.proxies),const DeepCollectionEquality().hash(_this.dialers));
}

@override
String toString() {
  final _this = this as CustomProfileData;
  return 'CustomProfileData(proxyGroups: ${_this.proxyGroups}, proxyProviders: ${_this.proxyProviders}, ruleProviders: ${_this.ruleProviders}, ruleTargets: ${_this.ruleTargets}, proxies: ${_this.proxies}, dialers: ${_this.dialers})';
}


}

/// @nodoc
abstract mixin class $CustomProfileDataCopyWith<$Res>  {
  factory $CustomProfileDataCopyWith(CustomProfileData value, $Res Function(CustomProfileData) _then) = _$CustomProfileDataCopyWithImpl;
@useResult
$Res call({
 List<ProxyGroup> proxyGroups, Set<String> proxyProviders, Set<String> ruleProviders, Set<String> ruleTargets, Set<String> proxies, Map<String, String> dialers
});




}
/// @nodoc
class _$CustomProfileDataCopyWithImpl<$Res>
    implements $CustomProfileDataCopyWith<$Res> {
  _$CustomProfileDataCopyWithImpl(this._self, this._then);

  final CustomProfileData _self;
  final $Res Function(CustomProfileData) _then;

/// Create a copy of CustomProfileData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? proxyGroups = null,Object? proxyProviders = null,Object? ruleProviders = null,Object? ruleTargets = null,Object? proxies = null,Object? dialers = null,}) {
  return _then(CustomProfileData(
proxyGroups: null == proxyGroups ? _self.proxyGroups : proxyGroups // ignore: cast_nullable_to_non_nullable
as List<ProxyGroup>,proxyProviders: null == proxyProviders ? _self.proxyProviders : proxyProviders // ignore: cast_nullable_to_non_nullable
as Set<String>,ruleProviders: null == ruleProviders ? _self.ruleProviders : ruleProviders // ignore: cast_nullable_to_non_nullable
as Set<String>,ruleTargets: null == ruleTargets ? _self.ruleTargets : ruleTargets // ignore: cast_nullable_to_non_nullable
as Set<String>,proxies: null == proxies ? _self.proxies : proxies // ignore: cast_nullable_to_non_nullable
as Set<String>,dialers: null == dialers ? _self.dialers : dialers // ignore: cast_nullable_to_non_nullable
as Map<String, String>,
  ));
}

}


/// Adds pattern-matching-related methods to [CustomProfileData].
extension CustomProfileDataPatterns on CustomProfileData {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CustomProfileData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CustomProfileData() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CustomProfileData value)  $default,){
final _that = this;
switch (_that) {
case _CustomProfileData():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CustomProfileData value)?  $default,){
final _that = this;
switch (_that) {
case _CustomProfileData() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<ProxyGroup> proxyGroups,  Set<String> proxyProviders,  Set<String> ruleProviders,  Set<String> ruleTargets,  Set<String> proxies,  Map<String, String> dialers)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CustomProfileData() when $default != null:
return $default(_that.proxyGroups,_that.proxyProviders,_that.ruleProviders,_that.ruleTargets,_that.proxies,_that.dialers);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<ProxyGroup> proxyGroups,  Set<String> proxyProviders,  Set<String> ruleProviders,  Set<String> ruleTargets,  Set<String> proxies,  Map<String, String> dialers)  $default,) {final _that = this;
switch (_that) {
case _CustomProfileData():
return $default(_that.proxyGroups,_that.proxyProviders,_that.ruleProviders,_that.ruleTargets,_that.proxies,_that.dialers);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<ProxyGroup> proxyGroups,  Set<String> proxyProviders,  Set<String> ruleProviders,  Set<String> ruleTargets,  Set<String> proxies,  Map<String, String> dialers)?  $default,) {final _that = this;
switch (_that) {
case _CustomProfileData() when $default != null:
return $default(_that.proxyGroups,_that.proxyProviders,_that.ruleProviders,_that.ruleTargets,_that.proxies,_that.dialers);case _:
  return null;

}
}

}

/// @nodoc


class _CustomProfileData implements CustomProfileData {
  const _CustomProfileData({ List<ProxyGroup> proxyGroups = const [],  Set<String> proxyProviders = const {},  Set<String> ruleProviders = const {},  Set<String> ruleTargets = const {},  Set<String> proxies = const {},  Map<String, String> dialers = const {}}): _proxyGroups = proxyGroups,_proxyProviders = proxyProviders,_ruleProviders = ruleProviders,_ruleTargets = ruleTargets,_proxies = proxies,_dialers = dialers;
  

 final  List<ProxyGroup> _proxyGroups;
@override@JsonKey() List<ProxyGroup> get proxyGroups {
  if (_proxyGroups is EqualUnmodifiableListView) return _proxyGroups;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_proxyGroups);
}

 final  Set<String> _proxyProviders;
@override@JsonKey() Set<String> get proxyProviders {
  if (_proxyProviders is EqualUnmodifiableSetView) return _proxyProviders;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_proxyProviders);
}

 final  Set<String> _ruleProviders;
@override@JsonKey() Set<String> get ruleProviders {
  if (_ruleProviders is EqualUnmodifiableSetView) return _ruleProviders;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_ruleProviders);
}

 final  Set<String> _ruleTargets;
@override@JsonKey() Set<String> get ruleTargets {
  if (_ruleTargets is EqualUnmodifiableSetView) return _ruleTargets;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_ruleTargets);
}

 final  Set<String> _proxies;
@override@JsonKey() Set<String> get proxies {
  if (_proxies is EqualUnmodifiableSetView) return _proxies;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_proxies);
}

 final  Map<String, String> _dialers;
@override@JsonKey() Map<String, String> get dialers {
  if (_dialers is EqualUnmodifiableMapView) return _dialers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_dialers);
}


/// Create a copy of CustomProfileData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CustomProfileDataCopyWith<_CustomProfileData> get copyWith => __$CustomProfileDataCopyWithImpl<_CustomProfileData>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CustomProfileData&&const DeepCollectionEquality().equals(other.proxyGroups, _proxyGroups)&&const DeepCollectionEquality().equals(other.proxyProviders, _proxyProviders)&&const DeepCollectionEquality().equals(other.ruleProviders, _ruleProviders)&&const DeepCollectionEquality().equals(other.ruleTargets, _ruleTargets)&&const DeepCollectionEquality().equals(other.proxies, _proxies)&&const DeepCollectionEquality().equals(other.dialers, _dialers));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_proxyGroups),const DeepCollectionEquality().hash(_proxyProviders),const DeepCollectionEquality().hash(_ruleProviders),const DeepCollectionEquality().hash(_ruleTargets),const DeepCollectionEquality().hash(_proxies),const DeepCollectionEquality().hash(_dialers));
}

@override
String toString() {
    return 'CustomProfileData(proxyGroups: $proxyGroups, proxyProviders: $proxyProviders, ruleProviders: $ruleProviders, ruleTargets: $ruleTargets, proxies: $proxies, dialers: $dialers)';
}


}

/// @nodoc
abstract mixin class _$CustomProfileDataCopyWith<$Res> implements $CustomProfileDataCopyWith<$Res> {
  factory _$CustomProfileDataCopyWith(_CustomProfileData value, $Res Function(_CustomProfileData) _then) = __$CustomProfileDataCopyWithImpl;
@override @useResult
$Res call({
 List<ProxyGroup> proxyGroups, Set<String> proxyProviders, Set<String> ruleProviders, Set<String> ruleTargets, Set<String> proxies, Map<String, String> dialers
});




}
/// @nodoc
class __$CustomProfileDataCopyWithImpl<$Res>
    implements _$CustomProfileDataCopyWith<$Res> {
  __$CustomProfileDataCopyWithImpl(this._self, this._then);

  final _CustomProfileData _self;
  final $Res Function(_CustomProfileData) _then;

/// Create a copy of CustomProfileData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? proxyGroups = null,Object? proxyProviders = null,Object? ruleProviders = null,Object? ruleTargets = null,Object? proxies = null,Object? dialers = null,}) {
  return _then(_CustomProfileData(
proxyGroups: null == proxyGroups ? _self._proxyGroups : proxyGroups // ignore: cast_nullable_to_non_nullable
as List<ProxyGroup>,proxyProviders: null == proxyProviders ? _self._proxyProviders : proxyProviders // ignore: cast_nullable_to_non_nullable
as Set<String>,ruleProviders: null == ruleProviders ? _self._ruleProviders : ruleProviders // ignore: cast_nullable_to_non_nullable
as Set<String>,ruleTargets: null == ruleTargets ? _self._ruleTargets : ruleTargets // ignore: cast_nullable_to_non_nullable
as Set<String>,proxies: null == proxies ? _self._proxies : proxies // ignore: cast_nullable_to_non_nullable
as Set<String>,dialers: null == dialers ? _self._dialers : dialers // ignore: cast_nullable_to_non_nullable
as Map<String, String>,
  ));
}


}


/// @nodoc
mixin _$RuleProvider {

 String get name;
/// Create a copy of RuleProvider
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RuleProviderCopyWith<RuleProvider> get copyWith => _$RuleProviderCopyWithImpl<RuleProvider>(this as RuleProvider, _$identity);

  /// Serializes this RuleProvider to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as RuleProvider;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RuleProvider&&(identical(other.name, _this.name) || other.name == _this.name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as RuleProvider;
  return Object.hash(runtimeType,_this.name);
}

@override
String toString() {
  final _this = this as RuleProvider;
  return 'RuleProvider(name: ${_this.name})';
}


}

/// @nodoc
abstract mixin class $RuleProviderCopyWith<$Res>  {
  factory $RuleProviderCopyWith(RuleProvider value, $Res Function(RuleProvider) _then) = _$RuleProviderCopyWithImpl;
@useResult
$Res call({
 String name
});




}
/// @nodoc
class _$RuleProviderCopyWithImpl<$Res>
    implements $RuleProviderCopyWith<$Res> {
  _$RuleProviderCopyWithImpl(this._self, this._then);

  final RuleProvider _self;
  final $Res Function(RuleProvider) _then;

/// Create a copy of RuleProvider
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,}) {
  return _then(RuleProvider(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [RuleProvider].
extension RuleProviderPatterns on RuleProvider {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RuleProvider value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RuleProvider() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RuleProvider value)  $default,){
final _that = this;
switch (_that) {
case _RuleProvider():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RuleProvider value)?  $default,){
final _that = this;
switch (_that) {
case _RuleProvider() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RuleProvider() when $default != null:
return $default(_that.name);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name)  $default,) {final _that = this;
switch (_that) {
case _RuleProvider():
return $default(_that.name);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name)?  $default,) {final _that = this;
switch (_that) {
case _RuleProvider() when $default != null:
return $default(_that.name);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RuleProvider implements RuleProvider {
  const _RuleProvider({required this.name});
  factory _RuleProvider.fromJson(Map<String, dynamic> json) => _$RuleProviderFromJson(json);

@override final  String name;

/// Create a copy of RuleProvider
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RuleProviderCopyWith<_RuleProvider> get copyWith => __$RuleProviderCopyWithImpl<_RuleProvider>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RuleProviderToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RuleProvider&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,name);
}

@override
String toString() {
    return 'RuleProvider(name: $name)';
}


}

/// @nodoc
abstract mixin class _$RuleProviderCopyWith<$Res> implements $RuleProviderCopyWith<$Res> {
  factory _$RuleProviderCopyWith(_RuleProvider value, $Res Function(_RuleProvider) _then) = __$RuleProviderCopyWithImpl;
@override @useResult
$Res call({
 String name
});




}
/// @nodoc
class __$RuleProviderCopyWithImpl<$Res>
    implements _$RuleProviderCopyWith<$Res> {
  __$RuleProviderCopyWithImpl(this._self, this._then);

  final _RuleProvider _self;
  final $Res Function(_RuleProvider) _then;

/// Create a copy of RuleProvider
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,}) {
  return _then(_RuleProvider(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$ProxyProvider {

 String get name;
/// Create a copy of ProxyProvider
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProxyProviderCopyWith<ProxyProvider> get copyWith => _$ProxyProviderCopyWithImpl<ProxyProvider>(this as ProxyProvider, _$identity);

  /// Serializes this ProxyProvider to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ProxyProvider;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProxyProvider&&(identical(other.name, _this.name) || other.name == _this.name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ProxyProvider;
  return Object.hash(runtimeType,_this.name);
}

@override
String toString() {
  final _this = this as ProxyProvider;
  return 'ProxyProvider(name: ${_this.name})';
}


}

/// @nodoc
abstract mixin class $ProxyProviderCopyWith<$Res>  {
  factory $ProxyProviderCopyWith(ProxyProvider value, $Res Function(ProxyProvider) _then) = _$ProxyProviderCopyWithImpl;
@useResult
$Res call({
 String name
});




}
/// @nodoc
class _$ProxyProviderCopyWithImpl<$Res>
    implements $ProxyProviderCopyWith<$Res> {
  _$ProxyProviderCopyWithImpl(this._self, this._then);

  final ProxyProvider _self;
  final $Res Function(ProxyProvider) _then;

/// Create a copy of ProxyProvider
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,}) {
  return _then(ProxyProvider(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ProxyProvider].
extension ProxyProviderPatterns on ProxyProvider {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProxyProvider value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProxyProvider() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProxyProvider value)  $default,){
final _that = this;
switch (_that) {
case _ProxyProvider():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProxyProvider value)?  $default,){
final _that = this;
switch (_that) {
case _ProxyProvider() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProxyProvider() when $default != null:
return $default(_that.name);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name)  $default,) {final _that = this;
switch (_that) {
case _ProxyProvider():
return $default(_that.name);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name)?  $default,) {final _that = this;
switch (_that) {
case _ProxyProvider() when $default != null:
return $default(_that.name);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProxyProvider implements ProxyProvider {
  const _ProxyProvider({required this.name});
  factory _ProxyProvider.fromJson(Map<String, dynamic> json) => _$ProxyProviderFromJson(json);

@override final  String name;

/// Create a copy of ProxyProvider
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProxyProviderCopyWith<_ProxyProvider> get copyWith => __$ProxyProviderCopyWithImpl<_ProxyProvider>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProxyProviderToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProxyProvider&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,name);
}

@override
String toString() {
    return 'ProxyProvider(name: $name)';
}


}

/// @nodoc
abstract mixin class _$ProxyProviderCopyWith<$Res> implements $ProxyProviderCopyWith<$Res> {
  factory _$ProxyProviderCopyWith(_ProxyProvider value, $Res Function(_ProxyProvider) _then) = __$ProxyProviderCopyWithImpl;
@override @useResult
$Res call({
 String name
});




}
/// @nodoc
class __$ProxyProviderCopyWithImpl<$Res>
    implements _$ProxyProviderCopyWith<$Res> {
  __$ProxyProviderCopyWithImpl(this._self, this._then);

  final _ProxyProvider _self;
  final $Res Function(_ProxyProvider) _then;

/// Create a copy of ProxyProvider
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,}) {
  return _then(_ProxyProvider(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$Sniffer {

 bool get enable;@JsonKey(name: 'override-destination') bool get overrideDest;@JsonKey(name: 'force-dns-mapping') bool get forceDnsMapping;@JsonKey(name: 'parse-pure-ip') bool get parsePureIp;@JsonKey(name: 'force-domain') List<String> get forceDomain;@JsonKey(name: 'skip-domain') List<String> get skipDomain;@JsonKey(name: 'skip-src-address') List<String> get skipSrcAddress;@JsonKey(name: 'skip-dst-address') List<String> get skipDstAddress; Map<String, SnifferConfig> get sniff;
/// Create a copy of Sniffer
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnifferCopyWith<Sniffer> get copyWith => _$SnifferCopyWithImpl<Sniffer>(this as Sniffer, _$identity);

  /// Serializes this Sniffer to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Sniffer;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Sniffer&&(identical(other.enable, _this.enable) || other.enable == _this.enable)&&(identical(other.overrideDest, _this.overrideDest) || other.overrideDest == _this.overrideDest)&&(identical(other.forceDnsMapping, _this.forceDnsMapping) || other.forceDnsMapping == _this.forceDnsMapping)&&(identical(other.parsePureIp, _this.parsePureIp) || other.parsePureIp == _this.parsePureIp)&&const DeepCollectionEquality().equals(other.forceDomain, _this.forceDomain)&&const DeepCollectionEquality().equals(other.skipDomain, _this.skipDomain)&&const DeepCollectionEquality().equals(other.skipSrcAddress, _this.skipSrcAddress)&&const DeepCollectionEquality().equals(other.skipDstAddress, _this.skipDstAddress)&&const DeepCollectionEquality().equals(other.sniff, _this.sniff));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Sniffer;
  return Object.hash(runtimeType,_this.enable,_this.overrideDest,_this.forceDnsMapping,_this.parsePureIp,const DeepCollectionEquality().hash(_this.forceDomain),const DeepCollectionEquality().hash(_this.skipDomain),const DeepCollectionEquality().hash(_this.skipSrcAddress),const DeepCollectionEquality().hash(_this.skipDstAddress),const DeepCollectionEquality().hash(_this.sniff));
}

@override
String toString() {
  final _this = this as Sniffer;
  return 'Sniffer(enable: ${_this.enable}, overrideDest: ${_this.overrideDest}, forceDnsMapping: ${_this.forceDnsMapping}, parsePureIp: ${_this.parsePureIp}, forceDomain: ${_this.forceDomain}, skipDomain: ${_this.skipDomain}, skipSrcAddress: ${_this.skipSrcAddress}, skipDstAddress: ${_this.skipDstAddress}, sniff: ${_this.sniff})';
}


}

/// @nodoc
abstract mixin class $SnifferCopyWith<$Res>  {
  factory $SnifferCopyWith(Sniffer value, $Res Function(Sniffer) _then) = _$SnifferCopyWithImpl;
@useResult
$Res call({
 bool enable,@JsonKey(name: 'override-destination') bool overrideDest,@JsonKey(name: 'force-dns-mapping') bool forceDnsMapping,@JsonKey(name: 'parse-pure-ip') bool parsePureIp,@JsonKey(name: 'force-domain') List<String> forceDomain,@JsonKey(name: 'skip-domain') List<String> skipDomain,@JsonKey(name: 'skip-src-address') List<String> skipSrcAddress,@JsonKey(name: 'skip-dst-address') List<String> skipDstAddress, Map<String, SnifferConfig> sniff
});




}
/// @nodoc
class _$SnifferCopyWithImpl<$Res>
    implements $SnifferCopyWith<$Res> {
  _$SnifferCopyWithImpl(this._self, this._then);

  final Sniffer _self;
  final $Res Function(Sniffer) _then;

/// Create a copy of Sniffer
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? enable = null,Object? overrideDest = null,Object? forceDnsMapping = null,Object? parsePureIp = null,Object? forceDomain = null,Object? skipDomain = null,Object? skipSrcAddress = null,Object? skipDstAddress = null,Object? sniff = null,}) {
  return _then(Sniffer(
enable: null == enable ? _self.enable : enable // ignore: cast_nullable_to_non_nullable
as bool,overrideDest: null == overrideDest ? _self.overrideDest : overrideDest // ignore: cast_nullable_to_non_nullable
as bool,forceDnsMapping: null == forceDnsMapping ? _self.forceDnsMapping : forceDnsMapping // ignore: cast_nullable_to_non_nullable
as bool,parsePureIp: null == parsePureIp ? _self.parsePureIp : parsePureIp // ignore: cast_nullable_to_non_nullable
as bool,forceDomain: null == forceDomain ? _self.forceDomain : forceDomain // ignore: cast_nullable_to_non_nullable
as List<String>,skipDomain: null == skipDomain ? _self.skipDomain : skipDomain // ignore: cast_nullable_to_non_nullable
as List<String>,skipSrcAddress: null == skipSrcAddress ? _self.skipSrcAddress : skipSrcAddress // ignore: cast_nullable_to_non_nullable
as List<String>,skipDstAddress: null == skipDstAddress ? _self.skipDstAddress : skipDstAddress // ignore: cast_nullable_to_non_nullable
as List<String>,sniff: null == sniff ? _self.sniff : sniff // ignore: cast_nullable_to_non_nullable
as Map<String, SnifferConfig>,
  ));
}

}


/// Adds pattern-matching-related methods to [Sniffer].
extension SnifferPatterns on Sniffer {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Sniffer value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Sniffer() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Sniffer value)  $default,){
final _that = this;
switch (_that) {
case _Sniffer():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Sniffer value)?  $default,){
final _that = this;
switch (_that) {
case _Sniffer() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool enable, @JsonKey(name: 'override-destination')  bool overrideDest, @JsonKey(name: 'force-dns-mapping')  bool forceDnsMapping, @JsonKey(name: 'parse-pure-ip')  bool parsePureIp, @JsonKey(name: 'force-domain')  List<String> forceDomain, @JsonKey(name: 'skip-domain')  List<String> skipDomain, @JsonKey(name: 'skip-src-address')  List<String> skipSrcAddress, @JsonKey(name: 'skip-dst-address')  List<String> skipDstAddress,  Map<String, SnifferConfig> sniff)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Sniffer() when $default != null:
return $default(_that.enable,_that.overrideDest,_that.forceDnsMapping,_that.parsePureIp,_that.forceDomain,_that.skipDomain,_that.skipSrcAddress,_that.skipDstAddress,_that.sniff);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool enable, @JsonKey(name: 'override-destination')  bool overrideDest, @JsonKey(name: 'force-dns-mapping')  bool forceDnsMapping, @JsonKey(name: 'parse-pure-ip')  bool parsePureIp, @JsonKey(name: 'force-domain')  List<String> forceDomain, @JsonKey(name: 'skip-domain')  List<String> skipDomain, @JsonKey(name: 'skip-src-address')  List<String> skipSrcAddress, @JsonKey(name: 'skip-dst-address')  List<String> skipDstAddress,  Map<String, SnifferConfig> sniff)  $default,) {final _that = this;
switch (_that) {
case _Sniffer():
return $default(_that.enable,_that.overrideDest,_that.forceDnsMapping,_that.parsePureIp,_that.forceDomain,_that.skipDomain,_that.skipSrcAddress,_that.skipDstAddress,_that.sniff);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool enable, @JsonKey(name: 'override-destination')  bool overrideDest, @JsonKey(name: 'force-dns-mapping')  bool forceDnsMapping, @JsonKey(name: 'parse-pure-ip')  bool parsePureIp, @JsonKey(name: 'force-domain')  List<String> forceDomain, @JsonKey(name: 'skip-domain')  List<String> skipDomain, @JsonKey(name: 'skip-src-address')  List<String> skipSrcAddress, @JsonKey(name: 'skip-dst-address')  List<String> skipDstAddress,  Map<String, SnifferConfig> sniff)?  $default,) {final _that = this;
switch (_that) {
case _Sniffer() when $default != null:
return $default(_that.enable,_that.overrideDest,_that.forceDnsMapping,_that.parsePureIp,_that.forceDomain,_that.skipDomain,_that.skipSrcAddress,_that.skipDstAddress,_that.sniff);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Sniffer implements Sniffer {
  const _Sniffer({this.enable = false, @JsonKey(name: 'override-destination') this.overrideDest = true, @JsonKey(name: 'force-dns-mapping') this.forceDnsMapping = true, @JsonKey(name: 'parse-pure-ip') this.parsePureIp = true, @JsonKey(name: 'force-domain')  List<String> forceDomain = const [], @JsonKey(name: 'skip-domain')  List<String> skipDomain = const [], @JsonKey(name: 'skip-src-address')  List<String> skipSrcAddress = const [], @JsonKey(name: 'skip-dst-address')  List<String> skipDstAddress = const [],  Map<String, SnifferConfig> sniff = const {}}): _forceDomain = forceDomain,_skipDomain = skipDomain,_skipSrcAddress = skipSrcAddress,_skipDstAddress = skipDstAddress,_sniff = sniff;
  factory _Sniffer.fromJson(Map<String, dynamic> json) => _$SnifferFromJson(json);

@override@JsonKey() final  bool enable;
@override@JsonKey(name: 'override-destination') final  bool overrideDest;
@override@JsonKey(name: 'force-dns-mapping') final  bool forceDnsMapping;
@override@JsonKey(name: 'parse-pure-ip') final  bool parsePureIp;
 final  List<String> _forceDomain;
@override@JsonKey(name: 'force-domain') List<String> get forceDomain {
  if (_forceDomain is EqualUnmodifiableListView) return _forceDomain;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_forceDomain);
}

 final  List<String> _skipDomain;
@override@JsonKey(name: 'skip-domain') List<String> get skipDomain {
  if (_skipDomain is EqualUnmodifiableListView) return _skipDomain;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_skipDomain);
}

 final  List<String> _skipSrcAddress;
@override@JsonKey(name: 'skip-src-address') List<String> get skipSrcAddress {
  if (_skipSrcAddress is EqualUnmodifiableListView) return _skipSrcAddress;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_skipSrcAddress);
}

 final  List<String> _skipDstAddress;
@override@JsonKey(name: 'skip-dst-address') List<String> get skipDstAddress {
  if (_skipDstAddress is EqualUnmodifiableListView) return _skipDstAddress;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_skipDstAddress);
}

 final  Map<String, SnifferConfig> _sniff;
@override@JsonKey() Map<String, SnifferConfig> get sniff {
  if (_sniff is EqualUnmodifiableMapView) return _sniff;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_sniff);
}


/// Create a copy of Sniffer
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnifferCopyWith<_Sniffer> get copyWith => __$SnifferCopyWithImpl<_Sniffer>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnifferToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Sniffer&&(identical(other.enable, enable) || other.enable == enable)&&(identical(other.overrideDest, overrideDest) || other.overrideDest == overrideDest)&&(identical(other.forceDnsMapping, forceDnsMapping) || other.forceDnsMapping == forceDnsMapping)&&(identical(other.parsePureIp, parsePureIp) || other.parsePureIp == parsePureIp)&&const DeepCollectionEquality().equals(other.forceDomain, _forceDomain)&&const DeepCollectionEquality().equals(other.skipDomain, _skipDomain)&&const DeepCollectionEquality().equals(other.skipSrcAddress, _skipSrcAddress)&&const DeepCollectionEquality().equals(other.skipDstAddress, _skipDstAddress)&&const DeepCollectionEquality().equals(other.sniff, _sniff));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,enable,overrideDest,forceDnsMapping,parsePureIp,const DeepCollectionEquality().hash(_forceDomain),const DeepCollectionEquality().hash(_skipDomain),const DeepCollectionEquality().hash(_skipSrcAddress),const DeepCollectionEquality().hash(_skipDstAddress),const DeepCollectionEquality().hash(_sniff));
}

@override
String toString() {
    return 'Sniffer(enable: $enable, overrideDest: $overrideDest, forceDnsMapping: $forceDnsMapping, parsePureIp: $parsePureIp, forceDomain: $forceDomain, skipDomain: $skipDomain, skipSrcAddress: $skipSrcAddress, skipDstAddress: $skipDstAddress, sniff: $sniff)';
}


}

/// @nodoc
abstract mixin class _$SnifferCopyWith<$Res> implements $SnifferCopyWith<$Res> {
  factory _$SnifferCopyWith(_Sniffer value, $Res Function(_Sniffer) _then) = __$SnifferCopyWithImpl;
@override @useResult
$Res call({
 bool enable,@JsonKey(name: 'override-destination') bool overrideDest,@JsonKey(name: 'force-dns-mapping') bool forceDnsMapping,@JsonKey(name: 'parse-pure-ip') bool parsePureIp,@JsonKey(name: 'force-domain') List<String> forceDomain,@JsonKey(name: 'skip-domain') List<String> skipDomain,@JsonKey(name: 'skip-src-address') List<String> skipSrcAddress,@JsonKey(name: 'skip-dst-address') List<String> skipDstAddress, Map<String, SnifferConfig> sniff
});




}
/// @nodoc
class __$SnifferCopyWithImpl<$Res>
    implements _$SnifferCopyWith<$Res> {
  __$SnifferCopyWithImpl(this._self, this._then);

  final _Sniffer _self;
  final $Res Function(_Sniffer) _then;

/// Create a copy of Sniffer
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? enable = null,Object? overrideDest = null,Object? forceDnsMapping = null,Object? parsePureIp = null,Object? forceDomain = null,Object? skipDomain = null,Object? skipSrcAddress = null,Object? skipDstAddress = null,Object? sniff = null,}) {
  return _then(_Sniffer(
enable: null == enable ? _self.enable : enable // ignore: cast_nullable_to_non_nullable
as bool,overrideDest: null == overrideDest ? _self.overrideDest : overrideDest // ignore: cast_nullable_to_non_nullable
as bool,forceDnsMapping: null == forceDnsMapping ? _self.forceDnsMapping : forceDnsMapping // ignore: cast_nullable_to_non_nullable
as bool,parsePureIp: null == parsePureIp ? _self.parsePureIp : parsePureIp // ignore: cast_nullable_to_non_nullable
as bool,forceDomain: null == forceDomain ? _self._forceDomain : forceDomain // ignore: cast_nullable_to_non_nullable
as List<String>,skipDomain: null == skipDomain ? _self._skipDomain : skipDomain // ignore: cast_nullable_to_non_nullable
as List<String>,skipSrcAddress: null == skipSrcAddress ? _self._skipSrcAddress : skipSrcAddress // ignore: cast_nullable_to_non_nullable
as List<String>,skipDstAddress: null == skipDstAddress ? _self._skipDstAddress : skipDstAddress // ignore: cast_nullable_to_non_nullable
as List<String>,sniff: null == sniff ? _self._sniff : sniff // ignore: cast_nullable_to_non_nullable
as Map<String, SnifferConfig>,
  ));
}


}


/// @nodoc
mixin _$SnifferConfig {

@JsonKey(fromJson: _formJsonPorts) List<String> get ports;@JsonKey(name: 'override-destination', includeIfNull: false) bool? get overrideDest;
/// Create a copy of SnifferConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnifferConfigCopyWith<SnifferConfig> get copyWith => _$SnifferConfigCopyWithImpl<SnifferConfig>(this as SnifferConfig, _$identity);

  /// Serializes this SnifferConfig to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SnifferConfig;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnifferConfig&&const DeepCollectionEquality().equals(other.ports, _this.ports)&&(identical(other.overrideDest, _this.overrideDest) || other.overrideDest == _this.overrideDest));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SnifferConfig;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.ports),_this.overrideDest);
}

@override
String toString() {
  final _this = this as SnifferConfig;
  return 'SnifferConfig(ports: ${_this.ports}, overrideDest: ${_this.overrideDest})';
}


}

/// @nodoc
abstract mixin class $SnifferConfigCopyWith<$Res>  {
  factory $SnifferConfigCopyWith(SnifferConfig value, $Res Function(SnifferConfig) _then) = _$SnifferConfigCopyWithImpl;
@useResult
$Res call({
@JsonKey(fromJson: _formJsonPorts) List<String> ports,@JsonKey(name: 'override-destination', includeIfNull: false) bool? overrideDest
});




}
/// @nodoc
class _$SnifferConfigCopyWithImpl<$Res>
    implements $SnifferConfigCopyWith<$Res> {
  _$SnifferConfigCopyWithImpl(this._self, this._then);

  final SnifferConfig _self;
  final $Res Function(SnifferConfig) _then;

/// Create a copy of SnifferConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? ports = null,Object? overrideDest = freezed,}) {
  return _then(SnifferConfig(
ports: null == ports ? _self.ports : ports // ignore: cast_nullable_to_non_nullable
as List<String>,overrideDest: freezed == overrideDest ? _self.overrideDest : overrideDest // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}

}


/// Adds pattern-matching-related methods to [SnifferConfig].
extension SnifferConfigPatterns on SnifferConfig {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnifferConfig value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnifferConfig() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnifferConfig value)  $default,){
final _that = this;
switch (_that) {
case _SnifferConfig():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnifferConfig value)?  $default,){
final _that = this;
switch (_that) {
case _SnifferConfig() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(fromJson: _formJsonPorts)  List<String> ports, @JsonKey(name: 'override-destination', includeIfNull: false)  bool? overrideDest)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnifferConfig() when $default != null:
return $default(_that.ports,_that.overrideDest);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(fromJson: _formJsonPorts)  List<String> ports, @JsonKey(name: 'override-destination', includeIfNull: false)  bool? overrideDest)  $default,) {final _that = this;
switch (_that) {
case _SnifferConfig():
return $default(_that.ports,_that.overrideDest);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(fromJson: _formJsonPorts)  List<String> ports, @JsonKey(name: 'override-destination', includeIfNull: false)  bool? overrideDest)?  $default,) {final _that = this;
switch (_that) {
case _SnifferConfig() when $default != null:
return $default(_that.ports,_that.overrideDest);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnifferConfig implements SnifferConfig {
  const _SnifferConfig({@JsonKey(fromJson: _formJsonPorts)  List<String> ports = const [], @JsonKey(name: 'override-destination', includeIfNull: false) this.overrideDest}): _ports = ports;
  factory _SnifferConfig.fromJson(Map<String, dynamic> json) => _$SnifferConfigFromJson(json);

 final  List<String> _ports;
@override@JsonKey(fromJson: _formJsonPorts) List<String> get ports {
  if (_ports is EqualUnmodifiableListView) return _ports;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_ports);
}

@override@JsonKey(name: 'override-destination', includeIfNull: false) final  bool? overrideDest;

/// Create a copy of SnifferConfig
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnifferConfigCopyWith<_SnifferConfig> get copyWith => __$SnifferConfigCopyWithImpl<_SnifferConfig>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnifferConfigToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnifferConfig&&const DeepCollectionEquality().equals(other.ports, _ports)&&(identical(other.overrideDest, overrideDest) || other.overrideDest == overrideDest));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_ports),overrideDest);
}

@override
String toString() {
    return 'SnifferConfig(ports: $ports, overrideDest: $overrideDest)';
}


}

/// @nodoc
abstract mixin class _$SnifferConfigCopyWith<$Res> implements $SnifferConfigCopyWith<$Res> {
  factory _$SnifferConfigCopyWith(_SnifferConfig value, $Res Function(_SnifferConfig) _then) = __$SnifferConfigCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(fromJson: _formJsonPorts) List<String> ports,@JsonKey(name: 'override-destination', includeIfNull: false) bool? overrideDest
});




}
/// @nodoc
class __$SnifferConfigCopyWithImpl<$Res>
    implements _$SnifferConfigCopyWith<$Res> {
  __$SnifferConfigCopyWithImpl(this._self, this._then);

  final _SnifferConfig _self;
  final $Res Function(_SnifferConfig) _then;

/// Create a copy of SnifferConfig
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? ports = null,Object? overrideDest = freezed,}) {
  return _then(_SnifferConfig(
ports: null == ports ? _self._ports : ports // ignore: cast_nullable_to_non_nullable
as List<String>,overrideDest: freezed == overrideDest ? _self.overrideDest : overrideDest // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}


}


/// @nodoc
mixin _$Tun {

 bool get enable; String get device;@JsonKey(name: 'auto-route') bool get autoRoute; TunStack get stack;@JsonKey(name: 'dns-hijack') List<String> get dnsHijack;@JsonKey(name: 'route-address') List<String> get routeAddress;@JsonKey(fromJson: _mtuFromJson) int get mtu;@JsonKey(name: 'congestion-controller', fromJson: _congestionControllerFromJson) String get congestionController;@JsonKey(name: 'strict-route') bool get strictRoute;@JsonKey(name: 'route-exclude-address') List<String> get routeExcludeAddress;
/// Create a copy of Tun
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TunCopyWith<Tun> get copyWith => _$TunCopyWithImpl<Tun>(this as Tun, _$identity);

  /// Serializes this Tun to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Tun;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Tun&&(identical(other.enable, _this.enable) || other.enable == _this.enable)&&(identical(other.device, _this.device) || other.device == _this.device)&&(identical(other.autoRoute, _this.autoRoute) || other.autoRoute == _this.autoRoute)&&(identical(other.stack, _this.stack) || other.stack == _this.stack)&&const DeepCollectionEquality().equals(other.dnsHijack, _this.dnsHijack)&&const DeepCollectionEquality().equals(other.routeAddress, _this.routeAddress)&&(identical(other.mtu, _this.mtu) || other.mtu == _this.mtu)&&(identical(other.congestionController, _this.congestionController) || other.congestionController == _this.congestionController)&&(identical(other.strictRoute, _this.strictRoute) || other.strictRoute == _this.strictRoute)&&const DeepCollectionEquality().equals(other.routeExcludeAddress, _this.routeExcludeAddress));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Tun;
  return Object.hash(runtimeType,_this.enable,_this.device,_this.autoRoute,_this.stack,const DeepCollectionEquality().hash(_this.dnsHijack),const DeepCollectionEquality().hash(_this.routeAddress),_this.mtu,_this.congestionController,_this.strictRoute,const DeepCollectionEquality().hash(_this.routeExcludeAddress));
}

@override
String toString() {
  final _this = this as Tun;
  return 'Tun(enable: ${_this.enable}, device: ${_this.device}, autoRoute: ${_this.autoRoute}, stack: ${_this.stack}, dnsHijack: ${_this.dnsHijack}, routeAddress: ${_this.routeAddress}, mtu: ${_this.mtu}, congestionController: ${_this.congestionController}, strictRoute: ${_this.strictRoute}, routeExcludeAddress: ${_this.routeExcludeAddress})';
}


}

/// @nodoc
abstract mixin class $TunCopyWith<$Res>  {
  factory $TunCopyWith(Tun value, $Res Function(Tun) _then) = _$TunCopyWithImpl;
@useResult
$Res call({
 bool enable, String device,@JsonKey(name: 'auto-route') bool autoRoute, TunStack stack,@JsonKey(name: 'dns-hijack') List<String> dnsHijack,@JsonKey(name: 'route-address') List<String> routeAddress,@JsonKey(fromJson: _mtuFromJson) int mtu,@JsonKey(name: 'congestion-controller', fromJson: _congestionControllerFromJson) String congestionController,@JsonKey(name: 'strict-route') bool strictRoute,@JsonKey(name: 'route-exclude-address') List<String> routeExcludeAddress
});




}
/// @nodoc
class _$TunCopyWithImpl<$Res>
    implements $TunCopyWith<$Res> {
  _$TunCopyWithImpl(this._self, this._then);

  final Tun _self;
  final $Res Function(Tun) _then;

/// Create a copy of Tun
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? enable = null,Object? device = null,Object? autoRoute = null,Object? stack = null,Object? dnsHijack = null,Object? routeAddress = null,Object? mtu = null,Object? congestionController = null,Object? strictRoute = null,Object? routeExcludeAddress = null,}) {
  return _then(Tun(
enable: null == enable ? _self.enable : enable // ignore: cast_nullable_to_non_nullable
as bool,device: null == device ? _self.device : device // ignore: cast_nullable_to_non_nullable
as String,autoRoute: null == autoRoute ? _self.autoRoute : autoRoute // ignore: cast_nullable_to_non_nullable
as bool,stack: null == stack ? _self.stack : stack // ignore: cast_nullable_to_non_nullable
as TunStack,dnsHijack: null == dnsHijack ? _self.dnsHijack : dnsHijack // ignore: cast_nullable_to_non_nullable
as List<String>,routeAddress: null == routeAddress ? _self.routeAddress : routeAddress // ignore: cast_nullable_to_non_nullable
as List<String>,mtu: null == mtu ? _self.mtu : mtu // ignore: cast_nullable_to_non_nullable
as int,congestionController: null == congestionController ? _self.congestionController : congestionController // ignore: cast_nullable_to_non_nullable
as String,strictRoute: null == strictRoute ? _self.strictRoute : strictRoute // ignore: cast_nullable_to_non_nullable
as bool,routeExcludeAddress: null == routeExcludeAddress ? _self.routeExcludeAddress : routeExcludeAddress // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [Tun].
extension TunPatterns on Tun {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Tun value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Tun() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Tun value)  $default,){
final _that = this;
switch (_that) {
case _Tun():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Tun value)?  $default,){
final _that = this;
switch (_that) {
case _Tun() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool enable,  String device, @JsonKey(name: 'auto-route')  bool autoRoute,  TunStack stack, @JsonKey(name: 'dns-hijack')  List<String> dnsHijack, @JsonKey(name: 'route-address')  List<String> routeAddress, @JsonKey(fromJson: _mtuFromJson)  int mtu, @JsonKey(name: 'congestion-controller', fromJson: _congestionControllerFromJson)  String congestionController, @JsonKey(name: 'strict-route')  bool strictRoute, @JsonKey(name: 'route-exclude-address')  List<String> routeExcludeAddress)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Tun() when $default != null:
return $default(_that.enable,_that.device,_that.autoRoute,_that.stack,_that.dnsHijack,_that.routeAddress,_that.mtu,_that.congestionController,_that.strictRoute,_that.routeExcludeAddress);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool enable,  String device, @JsonKey(name: 'auto-route')  bool autoRoute,  TunStack stack, @JsonKey(name: 'dns-hijack')  List<String> dnsHijack, @JsonKey(name: 'route-address')  List<String> routeAddress, @JsonKey(fromJson: _mtuFromJson)  int mtu, @JsonKey(name: 'congestion-controller', fromJson: _congestionControllerFromJson)  String congestionController, @JsonKey(name: 'strict-route')  bool strictRoute, @JsonKey(name: 'route-exclude-address')  List<String> routeExcludeAddress)  $default,) {final _that = this;
switch (_that) {
case _Tun():
return $default(_that.enable,_that.device,_that.autoRoute,_that.stack,_that.dnsHijack,_that.routeAddress,_that.mtu,_that.congestionController,_that.strictRoute,_that.routeExcludeAddress);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool enable,  String device, @JsonKey(name: 'auto-route')  bool autoRoute,  TunStack stack, @JsonKey(name: 'dns-hijack')  List<String> dnsHijack, @JsonKey(name: 'route-address')  List<String> routeAddress, @JsonKey(fromJson: _mtuFromJson)  int mtu, @JsonKey(name: 'congestion-controller', fromJson: _congestionControllerFromJson)  String congestionController, @JsonKey(name: 'strict-route')  bool strictRoute, @JsonKey(name: 'route-exclude-address')  List<String> routeExcludeAddress)?  $default,) {final _that = this;
switch (_that) {
case _Tun() when $default != null:
return $default(_that.enable,_that.device,_that.autoRoute,_that.stack,_that.dnsHijack,_that.routeAddress,_that.mtu,_that.congestionController,_that.strictRoute,_that.routeExcludeAddress);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Tun implements Tun {
  const _Tun({this.enable = false, this.device = appName, @JsonKey(name: 'auto-route') this.autoRoute = false, this.stack = TunStack.mips, @JsonKey(name: 'dns-hijack')  List<String> dnsHijack = const ['any:53'], @JsonKey(name: 'route-address')  List<String> routeAddress = const [], @JsonKey(fromJson: _mtuFromJson) this.mtu = defaultTunMtu, @JsonKey(name: 'congestion-controller', fromJson: _congestionControllerFromJson) this.congestionController = defaultCongestionController, @JsonKey(name: 'strict-route') this.strictRoute = false, @JsonKey(name: 'route-exclude-address')  List<String> routeExcludeAddress = const []}): _dnsHijack = dnsHijack,_routeAddress = routeAddress,_routeExcludeAddress = routeExcludeAddress;
  factory _Tun.fromJson(Map<String, dynamic> json) => _$TunFromJson(json);

@override@JsonKey() final  bool enable;
@override@JsonKey() final  String device;
@override@JsonKey(name: 'auto-route') final  bool autoRoute;
@override@JsonKey() final  TunStack stack;
 final  List<String> _dnsHijack;
@override@JsonKey(name: 'dns-hijack') List<String> get dnsHijack {
  if (_dnsHijack is EqualUnmodifiableListView) return _dnsHijack;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_dnsHijack);
}

 final  List<String> _routeAddress;
@override@JsonKey(name: 'route-address') List<String> get routeAddress {
  if (_routeAddress is EqualUnmodifiableListView) return _routeAddress;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_routeAddress);
}

@override@JsonKey(fromJson: _mtuFromJson) final  int mtu;
@override@JsonKey(name: 'congestion-controller', fromJson: _congestionControllerFromJson) final  String congestionController;
@override@JsonKey(name: 'strict-route') final  bool strictRoute;
 final  List<String> _routeExcludeAddress;
@override@JsonKey(name: 'route-exclude-address') List<String> get routeExcludeAddress {
  if (_routeExcludeAddress is EqualUnmodifiableListView) return _routeExcludeAddress;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_routeExcludeAddress);
}


/// Create a copy of Tun
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TunCopyWith<_Tun> get copyWith => __$TunCopyWithImpl<_Tun>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TunToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Tun&&(identical(other.enable, enable) || other.enable == enable)&&(identical(other.device, device) || other.device == device)&&(identical(other.autoRoute, autoRoute) || other.autoRoute == autoRoute)&&(identical(other.stack, stack) || other.stack == stack)&&const DeepCollectionEquality().equals(other.dnsHijack, _dnsHijack)&&const DeepCollectionEquality().equals(other.routeAddress, _routeAddress)&&(identical(other.mtu, mtu) || other.mtu == mtu)&&(identical(other.congestionController, congestionController) || other.congestionController == congestionController)&&(identical(other.strictRoute, strictRoute) || other.strictRoute == strictRoute)&&const DeepCollectionEquality().equals(other.routeExcludeAddress, _routeExcludeAddress));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,enable,device,autoRoute,stack,const DeepCollectionEquality().hash(_dnsHijack),const DeepCollectionEquality().hash(_routeAddress),mtu,congestionController,strictRoute,const DeepCollectionEquality().hash(_routeExcludeAddress));
}

@override
String toString() {
    return 'Tun(enable: $enable, device: $device, autoRoute: $autoRoute, stack: $stack, dnsHijack: $dnsHijack, routeAddress: $routeAddress, mtu: $mtu, congestionController: $congestionController, strictRoute: $strictRoute, routeExcludeAddress: $routeExcludeAddress)';
}


}

/// @nodoc
abstract mixin class _$TunCopyWith<$Res> implements $TunCopyWith<$Res> {
  factory _$TunCopyWith(_Tun value, $Res Function(_Tun) _then) = __$TunCopyWithImpl;
@override @useResult
$Res call({
 bool enable, String device,@JsonKey(name: 'auto-route') bool autoRoute, TunStack stack,@JsonKey(name: 'dns-hijack') List<String> dnsHijack,@JsonKey(name: 'route-address') List<String> routeAddress,@JsonKey(fromJson: _mtuFromJson) int mtu,@JsonKey(name: 'congestion-controller', fromJson: _congestionControllerFromJson) String congestionController,@JsonKey(name: 'strict-route') bool strictRoute,@JsonKey(name: 'route-exclude-address') List<String> routeExcludeAddress
});




}
/// @nodoc
class __$TunCopyWithImpl<$Res>
    implements _$TunCopyWith<$Res> {
  __$TunCopyWithImpl(this._self, this._then);

  final _Tun _self;
  final $Res Function(_Tun) _then;

/// Create a copy of Tun
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? enable = null,Object? device = null,Object? autoRoute = null,Object? stack = null,Object? dnsHijack = null,Object? routeAddress = null,Object? mtu = null,Object? congestionController = null,Object? strictRoute = null,Object? routeExcludeAddress = null,}) {
  return _then(_Tun(
enable: null == enable ? _self.enable : enable // ignore: cast_nullable_to_non_nullable
as bool,device: null == device ? _self.device : device // ignore: cast_nullable_to_non_nullable
as String,autoRoute: null == autoRoute ? _self.autoRoute : autoRoute // ignore: cast_nullable_to_non_nullable
as bool,stack: null == stack ? _self.stack : stack // ignore: cast_nullable_to_non_nullable
as TunStack,dnsHijack: null == dnsHijack ? _self._dnsHijack : dnsHijack // ignore: cast_nullable_to_non_nullable
as List<String>,routeAddress: null == routeAddress ? _self._routeAddress : routeAddress // ignore: cast_nullable_to_non_nullable
as List<String>,mtu: null == mtu ? _self.mtu : mtu // ignore: cast_nullable_to_non_nullable
as int,congestionController: null == congestionController ? _self.congestionController : congestionController // ignore: cast_nullable_to_non_nullable
as String,strictRoute: null == strictRoute ? _self.strictRoute : strictRoute // ignore: cast_nullable_to_non_nullable
as bool,routeExcludeAddress: null == routeExcludeAddress ? _self._routeExcludeAddress : routeExcludeAddress // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}


/// @nodoc
mixin _$FallbackFilter {

 bool get geoip;@JsonKey(name: 'geoip-code') String get geoipCode; List<String> get geosite; List<String> get ipcidr; List<String> get domain;
/// Create a copy of FallbackFilter
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FallbackFilterCopyWith<FallbackFilter> get copyWith => _$FallbackFilterCopyWithImpl<FallbackFilter>(this as FallbackFilter, _$identity);

  /// Serializes this FallbackFilter to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as FallbackFilter;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FallbackFilter&&(identical(other.geoip, _this.geoip) || other.geoip == _this.geoip)&&(identical(other.geoipCode, _this.geoipCode) || other.geoipCode == _this.geoipCode)&&const DeepCollectionEquality().equals(other.geosite, _this.geosite)&&const DeepCollectionEquality().equals(other.ipcidr, _this.ipcidr)&&const DeepCollectionEquality().equals(other.domain, _this.domain));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as FallbackFilter;
  return Object.hash(runtimeType,_this.geoip,_this.geoipCode,const DeepCollectionEquality().hash(_this.geosite),const DeepCollectionEquality().hash(_this.ipcidr),const DeepCollectionEquality().hash(_this.domain));
}

@override
String toString() {
  final _this = this as FallbackFilter;
  return 'FallbackFilter(geoip: ${_this.geoip}, geoipCode: ${_this.geoipCode}, geosite: ${_this.geosite}, ipcidr: ${_this.ipcidr}, domain: ${_this.domain})';
}


}

/// @nodoc
abstract mixin class $FallbackFilterCopyWith<$Res>  {
  factory $FallbackFilterCopyWith(FallbackFilter value, $Res Function(FallbackFilter) _then) = _$FallbackFilterCopyWithImpl;
@useResult
$Res call({
 bool geoip,@JsonKey(name: 'geoip-code') String geoipCode, List<String> geosite, List<String> ipcidr, List<String> domain
});




}
/// @nodoc
class _$FallbackFilterCopyWithImpl<$Res>
    implements $FallbackFilterCopyWith<$Res> {
  _$FallbackFilterCopyWithImpl(this._self, this._then);

  final FallbackFilter _self;
  final $Res Function(FallbackFilter) _then;

/// Create a copy of FallbackFilter
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? geoip = null,Object? geoipCode = null,Object? geosite = null,Object? ipcidr = null,Object? domain = null,}) {
  return _then(FallbackFilter(
geoip: null == geoip ? _self.geoip : geoip // ignore: cast_nullable_to_non_nullable
as bool,geoipCode: null == geoipCode ? _self.geoipCode : geoipCode // ignore: cast_nullable_to_non_nullable
as String,geosite: null == geosite ? _self.geosite : geosite // ignore: cast_nullable_to_non_nullable
as List<String>,ipcidr: null == ipcidr ? _self.ipcidr : ipcidr // ignore: cast_nullable_to_non_nullable
as List<String>,domain: null == domain ? _self.domain : domain // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [FallbackFilter].
extension FallbackFilterPatterns on FallbackFilter {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FallbackFilter value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FallbackFilter() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FallbackFilter value)  $default,){
final _that = this;
switch (_that) {
case _FallbackFilter():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FallbackFilter value)?  $default,){
final _that = this;
switch (_that) {
case _FallbackFilter() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool geoip, @JsonKey(name: 'geoip-code')  String geoipCode,  List<String> geosite,  List<String> ipcidr,  List<String> domain)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FallbackFilter() when $default != null:
return $default(_that.geoip,_that.geoipCode,_that.geosite,_that.ipcidr,_that.domain);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool geoip, @JsonKey(name: 'geoip-code')  String geoipCode,  List<String> geosite,  List<String> ipcidr,  List<String> domain)  $default,) {final _that = this;
switch (_that) {
case _FallbackFilter():
return $default(_that.geoip,_that.geoipCode,_that.geosite,_that.ipcidr,_that.domain);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool geoip, @JsonKey(name: 'geoip-code')  String geoipCode,  List<String> geosite,  List<String> ipcidr,  List<String> domain)?  $default,) {final _that = this;
switch (_that) {
case _FallbackFilter() when $default != null:
return $default(_that.geoip,_that.geoipCode,_that.geosite,_that.ipcidr,_that.domain);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FallbackFilter implements FallbackFilter {
  const _FallbackFilter({this.geoip = true, @JsonKey(name: 'geoip-code') this.geoipCode = '',  List<String> geosite = const [],  List<String> ipcidr = const [],  List<String> domain = const []}): _geosite = geosite,_ipcidr = ipcidr,_domain = domain;
  factory _FallbackFilter.fromJson(Map<String, dynamic> json) => _$FallbackFilterFromJson(json);

@override@JsonKey() final  bool geoip;
@override@JsonKey(name: 'geoip-code') final  String geoipCode;
 final  List<String> _geosite;
@override@JsonKey() List<String> get geosite {
  if (_geosite is EqualUnmodifiableListView) return _geosite;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_geosite);
}

 final  List<String> _ipcidr;
@override@JsonKey() List<String> get ipcidr {
  if (_ipcidr is EqualUnmodifiableListView) return _ipcidr;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_ipcidr);
}

 final  List<String> _domain;
@override@JsonKey() List<String> get domain {
  if (_domain is EqualUnmodifiableListView) return _domain;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_domain);
}


/// Create a copy of FallbackFilter
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FallbackFilterCopyWith<_FallbackFilter> get copyWith => __$FallbackFilterCopyWithImpl<_FallbackFilter>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FallbackFilterToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _FallbackFilter&&(identical(other.geoip, geoip) || other.geoip == geoip)&&(identical(other.geoipCode, geoipCode) || other.geoipCode == geoipCode)&&const DeepCollectionEquality().equals(other.geosite, _geosite)&&const DeepCollectionEquality().equals(other.ipcidr, _ipcidr)&&const DeepCollectionEquality().equals(other.domain, _domain));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,geoip,geoipCode,const DeepCollectionEquality().hash(_geosite),const DeepCollectionEquality().hash(_ipcidr),const DeepCollectionEquality().hash(_domain));
}

@override
String toString() {
    return 'FallbackFilter(geoip: $geoip, geoipCode: $geoipCode, geosite: $geosite, ipcidr: $ipcidr, domain: $domain)';
}


}

/// @nodoc
abstract mixin class _$FallbackFilterCopyWith<$Res> implements $FallbackFilterCopyWith<$Res> {
  factory _$FallbackFilterCopyWith(_FallbackFilter value, $Res Function(_FallbackFilter) _then) = __$FallbackFilterCopyWithImpl;
@override @useResult
$Res call({
 bool geoip,@JsonKey(name: 'geoip-code') String geoipCode, List<String> geosite, List<String> ipcidr, List<String> domain
});




}
/// @nodoc
class __$FallbackFilterCopyWithImpl<$Res>
    implements _$FallbackFilterCopyWith<$Res> {
  __$FallbackFilterCopyWithImpl(this._self, this._then);

  final _FallbackFilter _self;
  final $Res Function(_FallbackFilter) _then;

/// Create a copy of FallbackFilter
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? geoip = null,Object? geoipCode = null,Object? geosite = null,Object? ipcidr = null,Object? domain = null,}) {
  return _then(_FallbackFilter(
geoip: null == geoip ? _self.geoip : geoip // ignore: cast_nullable_to_non_nullable
as bool,geoipCode: null == geoipCode ? _self.geoipCode : geoipCode // ignore: cast_nullable_to_non_nullable
as String,geosite: null == geosite ? _self._geosite : geosite // ignore: cast_nullable_to_non_nullable
as List<String>,ipcidr: null == ipcidr ? _self._ipcidr : ipcidr // ignore: cast_nullable_to_non_nullable
as List<String>,domain: null == domain ? _self._domain : domain // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}


/// @nodoc
mixin _$Dns {

 bool get enable; String get listen;@JsonKey(name: 'listen-routing-mark') int get listenRoutingMark;@JsonKey(name: 'prefer-h3') bool get preferH3;@JsonKey(name: 'use-hosts') bool get useHosts;@JsonKey(name: 'use-system-hosts') bool get useSystemHosts;@JsonKey(name: 'respect-rules') bool get respectRules; bool get ipv6;@JsonKey(name: 'ipv6-timeout') int get ipv6Timeout;@JsonKey(name: 'cache-algorithm') DnsCacheAlgorithm get cacheAlgorithm;@JsonKey(name: 'cache-max-size') int get cacheMaxSize;@JsonKey(name: 'default-nameserver') List<String> get defaultNameserver;@JsonKey(name: 'enhanced-mode') DnsMode get enhancedMode;@JsonKey(name: 'fake-ip-range') String get fakeIpRange;@JsonKey(name: 'fake-ip-range6') String get fakeIpRange6;@JsonKey(name: 'fake-ip-filter') List<String> get fakeIpFilter;@JsonKey(name: 'fake-ip-filter-mode') FakeIpFilterMode get fakeIpFilterMode;@JsonKey(name: 'fake-ip-ttl') int get fakeIpTtl;@JsonKey(name: 'nameserver-policy') Map<String, String> get nameserverPolicy; List<String> get nameserver; List<String> get fallback;@JsonKey(name: 'fallback-lazy-query') bool get fallbackLazyQuery;@JsonKey(name: 'proxy-server-nameserver') List<String> get proxyServerNameserver;@JsonKey(name: 'proxy-server-nameserver-policy') Map<String, String> get proxyServerNameserverPolicy;@JsonKey(name: 'direct-nameserver') List<String> get directNameserver;@JsonKey(name: 'direct-nameserver-follow-policy') bool get directNameserverFollowPolicy;@JsonKey(name: 'fallback-filter') FallbackFilter get fallbackFilter;
/// Create a copy of Dns
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DnsCopyWith<Dns> get copyWith => _$DnsCopyWithImpl<Dns>(this as Dns, _$identity);

  /// Serializes this Dns to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Dns;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Dns&&(identical(other.enable, _this.enable) || other.enable == _this.enable)&&(identical(other.listen, _this.listen) || other.listen == _this.listen)&&(identical(other.listenRoutingMark, _this.listenRoutingMark) || other.listenRoutingMark == _this.listenRoutingMark)&&(identical(other.preferH3, _this.preferH3) || other.preferH3 == _this.preferH3)&&(identical(other.useHosts, _this.useHosts) || other.useHosts == _this.useHosts)&&(identical(other.useSystemHosts, _this.useSystemHosts) || other.useSystemHosts == _this.useSystemHosts)&&(identical(other.respectRules, _this.respectRules) || other.respectRules == _this.respectRules)&&(identical(other.ipv6, _this.ipv6) || other.ipv6 == _this.ipv6)&&(identical(other.ipv6Timeout, _this.ipv6Timeout) || other.ipv6Timeout == _this.ipv6Timeout)&&(identical(other.cacheAlgorithm, _this.cacheAlgorithm) || other.cacheAlgorithm == _this.cacheAlgorithm)&&(identical(other.cacheMaxSize, _this.cacheMaxSize) || other.cacheMaxSize == _this.cacheMaxSize)&&const DeepCollectionEquality().equals(other.defaultNameserver, _this.defaultNameserver)&&(identical(other.enhancedMode, _this.enhancedMode) || other.enhancedMode == _this.enhancedMode)&&(identical(other.fakeIpRange, _this.fakeIpRange) || other.fakeIpRange == _this.fakeIpRange)&&(identical(other.fakeIpRange6, _this.fakeIpRange6) || other.fakeIpRange6 == _this.fakeIpRange6)&&const DeepCollectionEquality().equals(other.fakeIpFilter, _this.fakeIpFilter)&&(identical(other.fakeIpFilterMode, _this.fakeIpFilterMode) || other.fakeIpFilterMode == _this.fakeIpFilterMode)&&(identical(other.fakeIpTtl, _this.fakeIpTtl) || other.fakeIpTtl == _this.fakeIpTtl)&&const DeepCollectionEquality().equals(other.nameserverPolicy, _this.nameserverPolicy)&&const DeepCollectionEquality().equals(other.nameserver, _this.nameserver)&&const DeepCollectionEquality().equals(other.fallback, _this.fallback)&&(identical(other.fallbackLazyQuery, _this.fallbackLazyQuery) || other.fallbackLazyQuery == _this.fallbackLazyQuery)&&const DeepCollectionEquality().equals(other.proxyServerNameserver, _this.proxyServerNameserver)&&const DeepCollectionEquality().equals(other.proxyServerNameserverPolicy, _this.proxyServerNameserverPolicy)&&const DeepCollectionEquality().equals(other.directNameserver, _this.directNameserver)&&(identical(other.directNameserverFollowPolicy, _this.directNameserverFollowPolicy) || other.directNameserverFollowPolicy == _this.directNameserverFollowPolicy)&&(identical(other.fallbackFilter, _this.fallbackFilter) || other.fallbackFilter == _this.fallbackFilter));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Dns;
  return Object.hashAll([runtimeType,_this.enable,_this.listen,_this.listenRoutingMark,_this.preferH3,_this.useHosts,_this.useSystemHosts,_this.respectRules,_this.ipv6,_this.ipv6Timeout,_this.cacheAlgorithm,_this.cacheMaxSize,const DeepCollectionEquality().hash(_this.defaultNameserver),_this.enhancedMode,_this.fakeIpRange,_this.fakeIpRange6,const DeepCollectionEquality().hash(_this.fakeIpFilter),_this.fakeIpFilterMode,_this.fakeIpTtl,const DeepCollectionEquality().hash(_this.nameserverPolicy),const DeepCollectionEquality().hash(_this.nameserver),const DeepCollectionEquality().hash(_this.fallback),_this.fallbackLazyQuery,const DeepCollectionEquality().hash(_this.proxyServerNameserver),const DeepCollectionEquality().hash(_this.proxyServerNameserverPolicy),const DeepCollectionEquality().hash(_this.directNameserver),_this.directNameserverFollowPolicy,_this.fallbackFilter]);
}

@override
String toString() {
  final _this = this as Dns;
  return 'Dns(enable: ${_this.enable}, listen: ${_this.listen}, listenRoutingMark: ${_this.listenRoutingMark}, preferH3: ${_this.preferH3}, useHosts: ${_this.useHosts}, useSystemHosts: ${_this.useSystemHosts}, respectRules: ${_this.respectRules}, ipv6: ${_this.ipv6}, ipv6Timeout: ${_this.ipv6Timeout}, cacheAlgorithm: ${_this.cacheAlgorithm}, cacheMaxSize: ${_this.cacheMaxSize}, defaultNameserver: ${_this.defaultNameserver}, enhancedMode: ${_this.enhancedMode}, fakeIpRange: ${_this.fakeIpRange}, fakeIpRange6: ${_this.fakeIpRange6}, fakeIpFilter: ${_this.fakeIpFilter}, fakeIpFilterMode: ${_this.fakeIpFilterMode}, fakeIpTtl: ${_this.fakeIpTtl}, nameserverPolicy: ${_this.nameserverPolicy}, nameserver: ${_this.nameserver}, fallback: ${_this.fallback}, fallbackLazyQuery: ${_this.fallbackLazyQuery}, proxyServerNameserver: ${_this.proxyServerNameserver}, proxyServerNameserverPolicy: ${_this.proxyServerNameserverPolicy}, directNameserver: ${_this.directNameserver}, directNameserverFollowPolicy: ${_this.directNameserverFollowPolicy}, fallbackFilter: ${_this.fallbackFilter})';
}


}

/// @nodoc
abstract mixin class $DnsCopyWith<$Res>  {
  factory $DnsCopyWith(Dns value, $Res Function(Dns) _then) = _$DnsCopyWithImpl;
@useResult
$Res call({
 bool enable, String listen,@JsonKey(name: 'listen-routing-mark') int listenRoutingMark,@JsonKey(name: 'prefer-h3') bool preferH3,@JsonKey(name: 'use-hosts') bool useHosts,@JsonKey(name: 'use-system-hosts') bool useSystemHosts,@JsonKey(name: 'respect-rules') bool respectRules, bool ipv6,@JsonKey(name: 'ipv6-timeout') int ipv6Timeout,@JsonKey(name: 'cache-algorithm') DnsCacheAlgorithm cacheAlgorithm,@JsonKey(name: 'cache-max-size') int cacheMaxSize,@JsonKey(name: 'default-nameserver') List<String> defaultNameserver,@JsonKey(name: 'enhanced-mode') DnsMode enhancedMode,@JsonKey(name: 'fake-ip-range') String fakeIpRange,@JsonKey(name: 'fake-ip-range6') String fakeIpRange6,@JsonKey(name: 'fake-ip-filter') List<String> fakeIpFilter,@JsonKey(name: 'fake-ip-filter-mode') FakeIpFilterMode fakeIpFilterMode,@JsonKey(name: 'fake-ip-ttl') int fakeIpTtl,@JsonKey(name: 'nameserver-policy') Map<String, String> nameserverPolicy, List<String> nameserver, List<String> fallback,@JsonKey(name: 'fallback-lazy-query') bool fallbackLazyQuery,@JsonKey(name: 'proxy-server-nameserver') List<String> proxyServerNameserver,@JsonKey(name: 'proxy-server-nameserver-policy') Map<String, String> proxyServerNameserverPolicy,@JsonKey(name: 'direct-nameserver') List<String> directNameserver,@JsonKey(name: 'direct-nameserver-follow-policy') bool directNameserverFollowPolicy,@JsonKey(name: 'fallback-filter') FallbackFilter fallbackFilter
});


$FallbackFilterCopyWith<$Res> get fallbackFilter;

}
/// @nodoc
class _$DnsCopyWithImpl<$Res>
    implements $DnsCopyWith<$Res> {
  _$DnsCopyWithImpl(this._self, this._then);

  final Dns _self;
  final $Res Function(Dns) _then;

/// Create a copy of Dns
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? enable = null,Object? listen = null,Object? listenRoutingMark = null,Object? preferH3 = null,Object? useHosts = null,Object? useSystemHosts = null,Object? respectRules = null,Object? ipv6 = null,Object? ipv6Timeout = null,Object? cacheAlgorithm = null,Object? cacheMaxSize = null,Object? defaultNameserver = null,Object? enhancedMode = null,Object? fakeIpRange = null,Object? fakeIpRange6 = null,Object? fakeIpFilter = null,Object? fakeIpFilterMode = null,Object? fakeIpTtl = null,Object? nameserverPolicy = null,Object? nameserver = null,Object? fallback = null,Object? fallbackLazyQuery = null,Object? proxyServerNameserver = null,Object? proxyServerNameserverPolicy = null,Object? directNameserver = null,Object? directNameserverFollowPolicy = null,Object? fallbackFilter = null,}) {
  return _then(Dns(
enable: null == enable ? _self.enable : enable // ignore: cast_nullable_to_non_nullable
as bool,listen: null == listen ? _self.listen : listen // ignore: cast_nullable_to_non_nullable
as String,listenRoutingMark: null == listenRoutingMark ? _self.listenRoutingMark : listenRoutingMark // ignore: cast_nullable_to_non_nullable
as int,preferH3: null == preferH3 ? _self.preferH3 : preferH3 // ignore: cast_nullable_to_non_nullable
as bool,useHosts: null == useHosts ? _self.useHosts : useHosts // ignore: cast_nullable_to_non_nullable
as bool,useSystemHosts: null == useSystemHosts ? _self.useSystemHosts : useSystemHosts // ignore: cast_nullable_to_non_nullable
as bool,respectRules: null == respectRules ? _self.respectRules : respectRules // ignore: cast_nullable_to_non_nullable
as bool,ipv6: null == ipv6 ? _self.ipv6 : ipv6 // ignore: cast_nullable_to_non_nullable
as bool,ipv6Timeout: null == ipv6Timeout ? _self.ipv6Timeout : ipv6Timeout // ignore: cast_nullable_to_non_nullable
as int,cacheAlgorithm: null == cacheAlgorithm ? _self.cacheAlgorithm : cacheAlgorithm // ignore: cast_nullable_to_non_nullable
as DnsCacheAlgorithm,cacheMaxSize: null == cacheMaxSize ? _self.cacheMaxSize : cacheMaxSize // ignore: cast_nullable_to_non_nullable
as int,defaultNameserver: null == defaultNameserver ? _self.defaultNameserver : defaultNameserver // ignore: cast_nullable_to_non_nullable
as List<String>,enhancedMode: null == enhancedMode ? _self.enhancedMode : enhancedMode // ignore: cast_nullable_to_non_nullable
as DnsMode,fakeIpRange: null == fakeIpRange ? _self.fakeIpRange : fakeIpRange // ignore: cast_nullable_to_non_nullable
as String,fakeIpRange6: null == fakeIpRange6 ? _self.fakeIpRange6 : fakeIpRange6 // ignore: cast_nullable_to_non_nullable
as String,fakeIpFilter: null == fakeIpFilter ? _self.fakeIpFilter : fakeIpFilter // ignore: cast_nullable_to_non_nullable
as List<String>,fakeIpFilterMode: null == fakeIpFilterMode ? _self.fakeIpFilterMode : fakeIpFilterMode // ignore: cast_nullable_to_non_nullable
as FakeIpFilterMode,fakeIpTtl: null == fakeIpTtl ? _self.fakeIpTtl : fakeIpTtl // ignore: cast_nullable_to_non_nullable
as int,nameserverPolicy: null == nameserverPolicy ? _self.nameserverPolicy : nameserverPolicy // ignore: cast_nullable_to_non_nullable
as Map<String, String>,nameserver: null == nameserver ? _self.nameserver : nameserver // ignore: cast_nullable_to_non_nullable
as List<String>,fallback: null == fallback ? _self.fallback : fallback // ignore: cast_nullable_to_non_nullable
as List<String>,fallbackLazyQuery: null == fallbackLazyQuery ? _self.fallbackLazyQuery : fallbackLazyQuery // ignore: cast_nullable_to_non_nullable
as bool,proxyServerNameserver: null == proxyServerNameserver ? _self.proxyServerNameserver : proxyServerNameserver // ignore: cast_nullable_to_non_nullable
as List<String>,proxyServerNameserverPolicy: null == proxyServerNameserverPolicy ? _self.proxyServerNameserverPolicy : proxyServerNameserverPolicy // ignore: cast_nullable_to_non_nullable
as Map<String, String>,directNameserver: null == directNameserver ? _self.directNameserver : directNameserver // ignore: cast_nullable_to_non_nullable
as List<String>,directNameserverFollowPolicy: null == directNameserverFollowPolicy ? _self.directNameserverFollowPolicy : directNameserverFollowPolicy // ignore: cast_nullable_to_non_nullable
as bool,fallbackFilter: null == fallbackFilter ? _self.fallbackFilter : fallbackFilter // ignore: cast_nullable_to_non_nullable
as FallbackFilter,
  ));
}
/// Create a copy of Dns
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FallbackFilterCopyWith<$Res> get fallbackFilter {
  
  return $FallbackFilterCopyWith<$Res>(_self.fallbackFilter, (value) {
    return _then(_self.copyWith(fallbackFilter: value));
  });
}
}


/// Adds pattern-matching-related methods to [Dns].
extension DnsPatterns on Dns {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Dns value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Dns() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Dns value)  $default,){
final _that = this;
switch (_that) {
case _Dns():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Dns value)?  $default,){
final _that = this;
switch (_that) {
case _Dns() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool enable,  String listen, @JsonKey(name: 'listen-routing-mark')  int listenRoutingMark, @JsonKey(name: 'prefer-h3')  bool preferH3, @JsonKey(name: 'use-hosts')  bool useHosts, @JsonKey(name: 'use-system-hosts')  bool useSystemHosts, @JsonKey(name: 'respect-rules')  bool respectRules,  bool ipv6, @JsonKey(name: 'ipv6-timeout')  int ipv6Timeout, @JsonKey(name: 'cache-algorithm')  DnsCacheAlgorithm cacheAlgorithm, @JsonKey(name: 'cache-max-size')  int cacheMaxSize, @JsonKey(name: 'default-nameserver')  List<String> defaultNameserver, @JsonKey(name: 'enhanced-mode')  DnsMode enhancedMode, @JsonKey(name: 'fake-ip-range')  String fakeIpRange, @JsonKey(name: 'fake-ip-range6')  String fakeIpRange6, @JsonKey(name: 'fake-ip-filter')  List<String> fakeIpFilter, @JsonKey(name: 'fake-ip-filter-mode')  FakeIpFilterMode fakeIpFilterMode, @JsonKey(name: 'fake-ip-ttl')  int fakeIpTtl, @JsonKey(name: 'nameserver-policy')  Map<String, String> nameserverPolicy,  List<String> nameserver,  List<String> fallback, @JsonKey(name: 'fallback-lazy-query')  bool fallbackLazyQuery, @JsonKey(name: 'proxy-server-nameserver')  List<String> proxyServerNameserver, @JsonKey(name: 'proxy-server-nameserver-policy')  Map<String, String> proxyServerNameserverPolicy, @JsonKey(name: 'direct-nameserver')  List<String> directNameserver, @JsonKey(name: 'direct-nameserver-follow-policy')  bool directNameserverFollowPolicy, @JsonKey(name: 'fallback-filter')  FallbackFilter fallbackFilter)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Dns() when $default != null:
return $default(_that.enable,_that.listen,_that.listenRoutingMark,_that.preferH3,_that.useHosts,_that.useSystemHosts,_that.respectRules,_that.ipv6,_that.ipv6Timeout,_that.cacheAlgorithm,_that.cacheMaxSize,_that.defaultNameserver,_that.enhancedMode,_that.fakeIpRange,_that.fakeIpRange6,_that.fakeIpFilter,_that.fakeIpFilterMode,_that.fakeIpTtl,_that.nameserverPolicy,_that.nameserver,_that.fallback,_that.fallbackLazyQuery,_that.proxyServerNameserver,_that.proxyServerNameserverPolicy,_that.directNameserver,_that.directNameserverFollowPolicy,_that.fallbackFilter);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool enable,  String listen, @JsonKey(name: 'listen-routing-mark')  int listenRoutingMark, @JsonKey(name: 'prefer-h3')  bool preferH3, @JsonKey(name: 'use-hosts')  bool useHosts, @JsonKey(name: 'use-system-hosts')  bool useSystemHosts, @JsonKey(name: 'respect-rules')  bool respectRules,  bool ipv6, @JsonKey(name: 'ipv6-timeout')  int ipv6Timeout, @JsonKey(name: 'cache-algorithm')  DnsCacheAlgorithm cacheAlgorithm, @JsonKey(name: 'cache-max-size')  int cacheMaxSize, @JsonKey(name: 'default-nameserver')  List<String> defaultNameserver, @JsonKey(name: 'enhanced-mode')  DnsMode enhancedMode, @JsonKey(name: 'fake-ip-range')  String fakeIpRange, @JsonKey(name: 'fake-ip-range6')  String fakeIpRange6, @JsonKey(name: 'fake-ip-filter')  List<String> fakeIpFilter, @JsonKey(name: 'fake-ip-filter-mode')  FakeIpFilterMode fakeIpFilterMode, @JsonKey(name: 'fake-ip-ttl')  int fakeIpTtl, @JsonKey(name: 'nameserver-policy')  Map<String, String> nameserverPolicy,  List<String> nameserver,  List<String> fallback, @JsonKey(name: 'fallback-lazy-query')  bool fallbackLazyQuery, @JsonKey(name: 'proxy-server-nameserver')  List<String> proxyServerNameserver, @JsonKey(name: 'proxy-server-nameserver-policy')  Map<String, String> proxyServerNameserverPolicy, @JsonKey(name: 'direct-nameserver')  List<String> directNameserver, @JsonKey(name: 'direct-nameserver-follow-policy')  bool directNameserverFollowPolicy, @JsonKey(name: 'fallback-filter')  FallbackFilter fallbackFilter)  $default,) {final _that = this;
switch (_that) {
case _Dns():
return $default(_that.enable,_that.listen,_that.listenRoutingMark,_that.preferH3,_that.useHosts,_that.useSystemHosts,_that.respectRules,_that.ipv6,_that.ipv6Timeout,_that.cacheAlgorithm,_that.cacheMaxSize,_that.defaultNameserver,_that.enhancedMode,_that.fakeIpRange,_that.fakeIpRange6,_that.fakeIpFilter,_that.fakeIpFilterMode,_that.fakeIpTtl,_that.nameserverPolicy,_that.nameserver,_that.fallback,_that.fallbackLazyQuery,_that.proxyServerNameserver,_that.proxyServerNameserverPolicy,_that.directNameserver,_that.directNameserverFollowPolicy,_that.fallbackFilter);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool enable,  String listen, @JsonKey(name: 'listen-routing-mark')  int listenRoutingMark, @JsonKey(name: 'prefer-h3')  bool preferH3, @JsonKey(name: 'use-hosts')  bool useHosts, @JsonKey(name: 'use-system-hosts')  bool useSystemHosts, @JsonKey(name: 'respect-rules')  bool respectRules,  bool ipv6, @JsonKey(name: 'ipv6-timeout')  int ipv6Timeout, @JsonKey(name: 'cache-algorithm')  DnsCacheAlgorithm cacheAlgorithm, @JsonKey(name: 'cache-max-size')  int cacheMaxSize, @JsonKey(name: 'default-nameserver')  List<String> defaultNameserver, @JsonKey(name: 'enhanced-mode')  DnsMode enhancedMode, @JsonKey(name: 'fake-ip-range')  String fakeIpRange, @JsonKey(name: 'fake-ip-range6')  String fakeIpRange6, @JsonKey(name: 'fake-ip-filter')  List<String> fakeIpFilter, @JsonKey(name: 'fake-ip-filter-mode')  FakeIpFilterMode fakeIpFilterMode, @JsonKey(name: 'fake-ip-ttl')  int fakeIpTtl, @JsonKey(name: 'nameserver-policy')  Map<String, String> nameserverPolicy,  List<String> nameserver,  List<String> fallback, @JsonKey(name: 'fallback-lazy-query')  bool fallbackLazyQuery, @JsonKey(name: 'proxy-server-nameserver')  List<String> proxyServerNameserver, @JsonKey(name: 'proxy-server-nameserver-policy')  Map<String, String> proxyServerNameserverPolicy, @JsonKey(name: 'direct-nameserver')  List<String> directNameserver, @JsonKey(name: 'direct-nameserver-follow-policy')  bool directNameserverFollowPolicy, @JsonKey(name: 'fallback-filter')  FallbackFilter fallbackFilter)?  $default,) {final _that = this;
switch (_that) {
case _Dns() when $default != null:
return $default(_that.enable,_that.listen,_that.listenRoutingMark,_that.preferH3,_that.useHosts,_that.useSystemHosts,_that.respectRules,_that.ipv6,_that.ipv6Timeout,_that.cacheAlgorithm,_that.cacheMaxSize,_that.defaultNameserver,_that.enhancedMode,_that.fakeIpRange,_that.fakeIpRange6,_that.fakeIpFilter,_that.fakeIpFilterMode,_that.fakeIpTtl,_that.nameserverPolicy,_that.nameserver,_that.fallback,_that.fallbackLazyQuery,_that.proxyServerNameserver,_that.proxyServerNameserverPolicy,_that.directNameserver,_that.directNameserverFollowPolicy,_that.fallbackFilter);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Dns implements Dns {
  const _Dns({this.enable = false, this.listen = '', @JsonKey(name: 'listen-routing-mark') this.listenRoutingMark = 0, @JsonKey(name: 'prefer-h3') this.preferH3 = false, @JsonKey(name: 'use-hosts') this.useHosts = true, @JsonKey(name: 'use-system-hosts') this.useSystemHosts = true, @JsonKey(name: 'respect-rules') this.respectRules = false, this.ipv6 = false, @JsonKey(name: 'ipv6-timeout') this.ipv6Timeout = 100, @JsonKey(name: 'cache-algorithm') this.cacheAlgorithm = DnsCacheAlgorithm.lru, @JsonKey(name: 'cache-max-size') this.cacheMaxSize = 4096, @JsonKey(name: 'default-nameserver')  List<String> defaultNameserver = const [], @JsonKey(name: 'enhanced-mode') this.enhancedMode = DnsMode.redirHost, @JsonKey(name: 'fake-ip-range') this.fakeIpRange = '', @JsonKey(name: 'fake-ip-range6') this.fakeIpRange6 = '', @JsonKey(name: 'fake-ip-filter')  List<String> fakeIpFilter = const [], @JsonKey(name: 'fake-ip-filter-mode') this.fakeIpFilterMode = FakeIpFilterMode.blacklist, @JsonKey(name: 'fake-ip-ttl') this.fakeIpTtl = 1, @JsonKey(name: 'nameserver-policy')  Map<String, String> nameserverPolicy = const {},  List<String> nameserver = const [],  List<String> fallback = const [], @JsonKey(name: 'fallback-lazy-query') this.fallbackLazyQuery = false, @JsonKey(name: 'proxy-server-nameserver')  List<String> proxyServerNameserver = const [], @JsonKey(name: 'proxy-server-nameserver-policy')  Map<String, String> proxyServerNameserverPolicy = const {}, @JsonKey(name: 'direct-nameserver')  List<String> directNameserver = const [], @JsonKey(name: 'direct-nameserver-follow-policy') this.directNameserverFollowPolicy = false, @JsonKey(name: 'fallback-filter') this.fallbackFilter = const FallbackFilter()}): _defaultNameserver = defaultNameserver,_fakeIpFilter = fakeIpFilter,_nameserverPolicy = nameserverPolicy,_nameserver = nameserver,_fallback = fallback,_proxyServerNameserver = proxyServerNameserver,_proxyServerNameserverPolicy = proxyServerNameserverPolicy,_directNameserver = directNameserver;
  factory _Dns.fromJson(Map<String, dynamic> json) => _$DnsFromJson(json);

@override@JsonKey() final  bool enable;
@override@JsonKey() final  String listen;
@override@JsonKey(name: 'listen-routing-mark') final  int listenRoutingMark;
@override@JsonKey(name: 'prefer-h3') final  bool preferH3;
@override@JsonKey(name: 'use-hosts') final  bool useHosts;
@override@JsonKey(name: 'use-system-hosts') final  bool useSystemHosts;
@override@JsonKey(name: 'respect-rules') final  bool respectRules;
@override@JsonKey() final  bool ipv6;
@override@JsonKey(name: 'ipv6-timeout') final  int ipv6Timeout;
@override@JsonKey(name: 'cache-algorithm') final  DnsCacheAlgorithm cacheAlgorithm;
@override@JsonKey(name: 'cache-max-size') final  int cacheMaxSize;
 final  List<String> _defaultNameserver;
@override@JsonKey(name: 'default-nameserver') List<String> get defaultNameserver {
  if (_defaultNameserver is EqualUnmodifiableListView) return _defaultNameserver;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_defaultNameserver);
}

@override@JsonKey(name: 'enhanced-mode') final  DnsMode enhancedMode;
@override@JsonKey(name: 'fake-ip-range') final  String fakeIpRange;
@override@JsonKey(name: 'fake-ip-range6') final  String fakeIpRange6;
 final  List<String> _fakeIpFilter;
@override@JsonKey(name: 'fake-ip-filter') List<String> get fakeIpFilter {
  if (_fakeIpFilter is EqualUnmodifiableListView) return _fakeIpFilter;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_fakeIpFilter);
}

@override@JsonKey(name: 'fake-ip-filter-mode') final  FakeIpFilterMode fakeIpFilterMode;
@override@JsonKey(name: 'fake-ip-ttl') final  int fakeIpTtl;
 final  Map<String, String> _nameserverPolicy;
@override@JsonKey(name: 'nameserver-policy') Map<String, String> get nameserverPolicy {
  if (_nameserverPolicy is EqualUnmodifiableMapView) return _nameserverPolicy;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_nameserverPolicy);
}

 final  List<String> _nameserver;
@override@JsonKey() List<String> get nameserver {
  if (_nameserver is EqualUnmodifiableListView) return _nameserver;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_nameserver);
}

 final  List<String> _fallback;
@override@JsonKey() List<String> get fallback {
  if (_fallback is EqualUnmodifiableListView) return _fallback;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_fallback);
}

@override@JsonKey(name: 'fallback-lazy-query') final  bool fallbackLazyQuery;
 final  List<String> _proxyServerNameserver;
@override@JsonKey(name: 'proxy-server-nameserver') List<String> get proxyServerNameserver {
  if (_proxyServerNameserver is EqualUnmodifiableListView) return _proxyServerNameserver;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_proxyServerNameserver);
}

 final  Map<String, String> _proxyServerNameserverPolicy;
@override@JsonKey(name: 'proxy-server-nameserver-policy') Map<String, String> get proxyServerNameserverPolicy {
  if (_proxyServerNameserverPolicy is EqualUnmodifiableMapView) return _proxyServerNameserverPolicy;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_proxyServerNameserverPolicy);
}

 final  List<String> _directNameserver;
@override@JsonKey(name: 'direct-nameserver') List<String> get directNameserver {
  if (_directNameserver is EqualUnmodifiableListView) return _directNameserver;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_directNameserver);
}

@override@JsonKey(name: 'direct-nameserver-follow-policy') final  bool directNameserverFollowPolicy;
@override@JsonKey(name: 'fallback-filter') final  FallbackFilter fallbackFilter;

/// Create a copy of Dns
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DnsCopyWith<_Dns> get copyWith => __$DnsCopyWithImpl<_Dns>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DnsToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Dns&&(identical(other.enable, enable) || other.enable == enable)&&(identical(other.listen, listen) || other.listen == listen)&&(identical(other.listenRoutingMark, listenRoutingMark) || other.listenRoutingMark == listenRoutingMark)&&(identical(other.preferH3, preferH3) || other.preferH3 == preferH3)&&(identical(other.useHosts, useHosts) || other.useHosts == useHosts)&&(identical(other.useSystemHosts, useSystemHosts) || other.useSystemHosts == useSystemHosts)&&(identical(other.respectRules, respectRules) || other.respectRules == respectRules)&&(identical(other.ipv6, ipv6) || other.ipv6 == ipv6)&&(identical(other.ipv6Timeout, ipv6Timeout) || other.ipv6Timeout == ipv6Timeout)&&(identical(other.cacheAlgorithm, cacheAlgorithm) || other.cacheAlgorithm == cacheAlgorithm)&&(identical(other.cacheMaxSize, cacheMaxSize) || other.cacheMaxSize == cacheMaxSize)&&const DeepCollectionEquality().equals(other.defaultNameserver, _defaultNameserver)&&(identical(other.enhancedMode, enhancedMode) || other.enhancedMode == enhancedMode)&&(identical(other.fakeIpRange, fakeIpRange) || other.fakeIpRange == fakeIpRange)&&(identical(other.fakeIpRange6, fakeIpRange6) || other.fakeIpRange6 == fakeIpRange6)&&const DeepCollectionEquality().equals(other.fakeIpFilter, _fakeIpFilter)&&(identical(other.fakeIpFilterMode, fakeIpFilterMode) || other.fakeIpFilterMode == fakeIpFilterMode)&&(identical(other.fakeIpTtl, fakeIpTtl) || other.fakeIpTtl == fakeIpTtl)&&const DeepCollectionEquality().equals(other.nameserverPolicy, _nameserverPolicy)&&const DeepCollectionEquality().equals(other.nameserver, _nameserver)&&const DeepCollectionEquality().equals(other.fallback, _fallback)&&(identical(other.fallbackLazyQuery, fallbackLazyQuery) || other.fallbackLazyQuery == fallbackLazyQuery)&&const DeepCollectionEquality().equals(other.proxyServerNameserver, _proxyServerNameserver)&&const DeepCollectionEquality().equals(other.proxyServerNameserverPolicy, _proxyServerNameserverPolicy)&&const DeepCollectionEquality().equals(other.directNameserver, _directNameserver)&&(identical(other.directNameserverFollowPolicy, directNameserverFollowPolicy) || other.directNameserverFollowPolicy == directNameserverFollowPolicy)&&(identical(other.fallbackFilter, fallbackFilter) || other.fallbackFilter == fallbackFilter));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hashAll([runtimeType,enable,listen,listenRoutingMark,preferH3,useHosts,useSystemHosts,respectRules,ipv6,ipv6Timeout,cacheAlgorithm,cacheMaxSize,const DeepCollectionEquality().hash(_defaultNameserver),enhancedMode,fakeIpRange,fakeIpRange6,const DeepCollectionEquality().hash(_fakeIpFilter),fakeIpFilterMode,fakeIpTtl,const DeepCollectionEquality().hash(_nameserverPolicy),const DeepCollectionEquality().hash(_nameserver),const DeepCollectionEquality().hash(_fallback),fallbackLazyQuery,const DeepCollectionEquality().hash(_proxyServerNameserver),const DeepCollectionEquality().hash(_proxyServerNameserverPolicy),const DeepCollectionEquality().hash(_directNameserver),directNameserverFollowPolicy,fallbackFilter]);
}

@override
String toString() {
    return 'Dns(enable: $enable, listen: $listen, listenRoutingMark: $listenRoutingMark, preferH3: $preferH3, useHosts: $useHosts, useSystemHosts: $useSystemHosts, respectRules: $respectRules, ipv6: $ipv6, ipv6Timeout: $ipv6Timeout, cacheAlgorithm: $cacheAlgorithm, cacheMaxSize: $cacheMaxSize, defaultNameserver: $defaultNameserver, enhancedMode: $enhancedMode, fakeIpRange: $fakeIpRange, fakeIpRange6: $fakeIpRange6, fakeIpFilter: $fakeIpFilter, fakeIpFilterMode: $fakeIpFilterMode, fakeIpTtl: $fakeIpTtl, nameserverPolicy: $nameserverPolicy, nameserver: $nameserver, fallback: $fallback, fallbackLazyQuery: $fallbackLazyQuery, proxyServerNameserver: $proxyServerNameserver, proxyServerNameserverPolicy: $proxyServerNameserverPolicy, directNameserver: $directNameserver, directNameserverFollowPolicy: $directNameserverFollowPolicy, fallbackFilter: $fallbackFilter)';
}


}

/// @nodoc
abstract mixin class _$DnsCopyWith<$Res> implements $DnsCopyWith<$Res> {
  factory _$DnsCopyWith(_Dns value, $Res Function(_Dns) _then) = __$DnsCopyWithImpl;
@override @useResult
$Res call({
 bool enable, String listen,@JsonKey(name: 'listen-routing-mark') int listenRoutingMark,@JsonKey(name: 'prefer-h3') bool preferH3,@JsonKey(name: 'use-hosts') bool useHosts,@JsonKey(name: 'use-system-hosts') bool useSystemHosts,@JsonKey(name: 'respect-rules') bool respectRules, bool ipv6,@JsonKey(name: 'ipv6-timeout') int ipv6Timeout,@JsonKey(name: 'cache-algorithm') DnsCacheAlgorithm cacheAlgorithm,@JsonKey(name: 'cache-max-size') int cacheMaxSize,@JsonKey(name: 'default-nameserver') List<String> defaultNameserver,@JsonKey(name: 'enhanced-mode') DnsMode enhancedMode,@JsonKey(name: 'fake-ip-range') String fakeIpRange,@JsonKey(name: 'fake-ip-range6') String fakeIpRange6,@JsonKey(name: 'fake-ip-filter') List<String> fakeIpFilter,@JsonKey(name: 'fake-ip-filter-mode') FakeIpFilterMode fakeIpFilterMode,@JsonKey(name: 'fake-ip-ttl') int fakeIpTtl,@JsonKey(name: 'nameserver-policy') Map<String, String> nameserverPolicy, List<String> nameserver, List<String> fallback,@JsonKey(name: 'fallback-lazy-query') bool fallbackLazyQuery,@JsonKey(name: 'proxy-server-nameserver') List<String> proxyServerNameserver,@JsonKey(name: 'proxy-server-nameserver-policy') Map<String, String> proxyServerNameserverPolicy,@JsonKey(name: 'direct-nameserver') List<String> directNameserver,@JsonKey(name: 'direct-nameserver-follow-policy') bool directNameserverFollowPolicy,@JsonKey(name: 'fallback-filter') FallbackFilter fallbackFilter
});


@override $FallbackFilterCopyWith<$Res> get fallbackFilter;

}
/// @nodoc
class __$DnsCopyWithImpl<$Res>
    implements _$DnsCopyWith<$Res> {
  __$DnsCopyWithImpl(this._self, this._then);

  final _Dns _self;
  final $Res Function(_Dns) _then;

/// Create a copy of Dns
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? enable = null,Object? listen = null,Object? listenRoutingMark = null,Object? preferH3 = null,Object? useHosts = null,Object? useSystemHosts = null,Object? respectRules = null,Object? ipv6 = null,Object? ipv6Timeout = null,Object? cacheAlgorithm = null,Object? cacheMaxSize = null,Object? defaultNameserver = null,Object? enhancedMode = null,Object? fakeIpRange = null,Object? fakeIpRange6 = null,Object? fakeIpFilter = null,Object? fakeIpFilterMode = null,Object? fakeIpTtl = null,Object? nameserverPolicy = null,Object? nameserver = null,Object? fallback = null,Object? fallbackLazyQuery = null,Object? proxyServerNameserver = null,Object? proxyServerNameserverPolicy = null,Object? directNameserver = null,Object? directNameserverFollowPolicy = null,Object? fallbackFilter = null,}) {
  return _then(_Dns(
enable: null == enable ? _self.enable : enable // ignore: cast_nullable_to_non_nullable
as bool,listen: null == listen ? _self.listen : listen // ignore: cast_nullable_to_non_nullable
as String,listenRoutingMark: null == listenRoutingMark ? _self.listenRoutingMark : listenRoutingMark // ignore: cast_nullable_to_non_nullable
as int,preferH3: null == preferH3 ? _self.preferH3 : preferH3 // ignore: cast_nullable_to_non_nullable
as bool,useHosts: null == useHosts ? _self.useHosts : useHosts // ignore: cast_nullable_to_non_nullable
as bool,useSystemHosts: null == useSystemHosts ? _self.useSystemHosts : useSystemHosts // ignore: cast_nullable_to_non_nullable
as bool,respectRules: null == respectRules ? _self.respectRules : respectRules // ignore: cast_nullable_to_non_nullable
as bool,ipv6: null == ipv6 ? _self.ipv6 : ipv6 // ignore: cast_nullable_to_non_nullable
as bool,ipv6Timeout: null == ipv6Timeout ? _self.ipv6Timeout : ipv6Timeout // ignore: cast_nullable_to_non_nullable
as int,cacheAlgorithm: null == cacheAlgorithm ? _self.cacheAlgorithm : cacheAlgorithm // ignore: cast_nullable_to_non_nullable
as DnsCacheAlgorithm,cacheMaxSize: null == cacheMaxSize ? _self.cacheMaxSize : cacheMaxSize // ignore: cast_nullable_to_non_nullable
as int,defaultNameserver: null == defaultNameserver ? _self._defaultNameserver : defaultNameserver // ignore: cast_nullable_to_non_nullable
as List<String>,enhancedMode: null == enhancedMode ? _self.enhancedMode : enhancedMode // ignore: cast_nullable_to_non_nullable
as DnsMode,fakeIpRange: null == fakeIpRange ? _self.fakeIpRange : fakeIpRange // ignore: cast_nullable_to_non_nullable
as String,fakeIpRange6: null == fakeIpRange6 ? _self.fakeIpRange6 : fakeIpRange6 // ignore: cast_nullable_to_non_nullable
as String,fakeIpFilter: null == fakeIpFilter ? _self._fakeIpFilter : fakeIpFilter // ignore: cast_nullable_to_non_nullable
as List<String>,fakeIpFilterMode: null == fakeIpFilterMode ? _self.fakeIpFilterMode : fakeIpFilterMode // ignore: cast_nullable_to_non_nullable
as FakeIpFilterMode,fakeIpTtl: null == fakeIpTtl ? _self.fakeIpTtl : fakeIpTtl // ignore: cast_nullable_to_non_nullable
as int,nameserverPolicy: null == nameserverPolicy ? _self._nameserverPolicy : nameserverPolicy // ignore: cast_nullable_to_non_nullable
as Map<String, String>,nameserver: null == nameserver ? _self._nameserver : nameserver // ignore: cast_nullable_to_non_nullable
as List<String>,fallback: null == fallback ? _self._fallback : fallback // ignore: cast_nullable_to_non_nullable
as List<String>,fallbackLazyQuery: null == fallbackLazyQuery ? _self.fallbackLazyQuery : fallbackLazyQuery // ignore: cast_nullable_to_non_nullable
as bool,proxyServerNameserver: null == proxyServerNameserver ? _self._proxyServerNameserver : proxyServerNameserver // ignore: cast_nullable_to_non_nullable
as List<String>,proxyServerNameserverPolicy: null == proxyServerNameserverPolicy ? _self._proxyServerNameserverPolicy : proxyServerNameserverPolicy // ignore: cast_nullable_to_non_nullable
as Map<String, String>,directNameserver: null == directNameserver ? _self._directNameserver : directNameserver // ignore: cast_nullable_to_non_nullable
as List<String>,directNameserverFollowPolicy: null == directNameserverFollowPolicy ? _self.directNameserverFollowPolicy : directNameserverFollowPolicy // ignore: cast_nullable_to_non_nullable
as bool,fallbackFilter: null == fallbackFilter ? _self.fallbackFilter : fallbackFilter // ignore: cast_nullable_to_non_nullable
as FallbackFilter,
  ));
}

/// Create a copy of Dns
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FallbackFilterCopyWith<$Res> get fallbackFilter {
  
  return $FallbackFilterCopyWith<$Res>(_self.fallbackFilter, (value) {
    return _then(_self.copyWith(fallbackFilter: value));
  });
}
}


/// @nodoc
mixin _$Ntp {

 bool get enable; String get server; int get port; int get interval;@JsonKey(name: 'dialer-proxy') String get dialerProxy;@JsonKey(name: 'write-to-system') bool get writeToSystem;
/// Create a copy of Ntp
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NtpCopyWith<Ntp> get copyWith => _$NtpCopyWithImpl<Ntp>(this as Ntp, _$identity);

  /// Serializes this Ntp to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Ntp;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Ntp&&(identical(other.enable, _this.enable) || other.enable == _this.enable)&&(identical(other.server, _this.server) || other.server == _this.server)&&(identical(other.port, _this.port) || other.port == _this.port)&&(identical(other.interval, _this.interval) || other.interval == _this.interval)&&(identical(other.dialerProxy, _this.dialerProxy) || other.dialerProxy == _this.dialerProxy)&&(identical(other.writeToSystem, _this.writeToSystem) || other.writeToSystem == _this.writeToSystem));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Ntp;
  return Object.hash(runtimeType,_this.enable,_this.server,_this.port,_this.interval,_this.dialerProxy,_this.writeToSystem);
}

@override
String toString() {
  final _this = this as Ntp;
  return 'Ntp(enable: ${_this.enable}, server: ${_this.server}, port: ${_this.port}, interval: ${_this.interval}, dialerProxy: ${_this.dialerProxy}, writeToSystem: ${_this.writeToSystem})';
}


}

/// @nodoc
abstract mixin class $NtpCopyWith<$Res>  {
  factory $NtpCopyWith(Ntp value, $Res Function(Ntp) _then) = _$NtpCopyWithImpl;
@useResult
$Res call({
 bool enable, String server, int port, int interval,@JsonKey(name: 'dialer-proxy') String dialerProxy,@JsonKey(name: 'write-to-system') bool writeToSystem
});




}
/// @nodoc
class _$NtpCopyWithImpl<$Res>
    implements $NtpCopyWith<$Res> {
  _$NtpCopyWithImpl(this._self, this._then);

  final Ntp _self;
  final $Res Function(Ntp) _then;

/// Create a copy of Ntp
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? enable = null,Object? server = null,Object? port = null,Object? interval = null,Object? dialerProxy = null,Object? writeToSystem = null,}) {
  return _then(Ntp(
enable: null == enable ? _self.enable : enable // ignore: cast_nullable_to_non_nullable
as bool,server: null == server ? _self.server : server // ignore: cast_nullable_to_non_nullable
as String,port: null == port ? _self.port : port // ignore: cast_nullable_to_non_nullable
as int,interval: null == interval ? _self.interval : interval // ignore: cast_nullable_to_non_nullable
as int,dialerProxy: null == dialerProxy ? _self.dialerProxy : dialerProxy // ignore: cast_nullable_to_non_nullable
as String,writeToSystem: null == writeToSystem ? _self.writeToSystem : writeToSystem // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [Ntp].
extension NtpPatterns on Ntp {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Ntp value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Ntp() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Ntp value)  $default,){
final _that = this;
switch (_that) {
case _Ntp():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Ntp value)?  $default,){
final _that = this;
switch (_that) {
case _Ntp() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool enable,  String server,  int port,  int interval, @JsonKey(name: 'dialer-proxy')  String dialerProxy, @JsonKey(name: 'write-to-system')  bool writeToSystem)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Ntp() when $default != null:
return $default(_that.enable,_that.server,_that.port,_that.interval,_that.dialerProxy,_that.writeToSystem);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool enable,  String server,  int port,  int interval, @JsonKey(name: 'dialer-proxy')  String dialerProxy, @JsonKey(name: 'write-to-system')  bool writeToSystem)  $default,) {final _that = this;
switch (_that) {
case _Ntp():
return $default(_that.enable,_that.server,_that.port,_that.interval,_that.dialerProxy,_that.writeToSystem);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool enable,  String server,  int port,  int interval, @JsonKey(name: 'dialer-proxy')  String dialerProxy, @JsonKey(name: 'write-to-system')  bool writeToSystem)?  $default,) {final _that = this;
switch (_that) {
case _Ntp() when $default != null:
return $default(_that.enable,_that.server,_that.port,_that.interval,_that.dialerProxy,_that.writeToSystem);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Ntp implements Ntp {
  const _Ntp({this.enable = false, this.server = '', this.port = 123, this.interval = 30, @JsonKey(name: 'dialer-proxy') this.dialerProxy = '', @JsonKey(name: 'write-to-system') this.writeToSystem = false});
  factory _Ntp.fromJson(Map<String, dynamic> json) => _$NtpFromJson(json);

@override@JsonKey() final  bool enable;
@override@JsonKey() final  String server;
@override@JsonKey() final  int port;
@override@JsonKey() final  int interval;
@override@JsonKey(name: 'dialer-proxy') final  String dialerProxy;
@override@JsonKey(name: 'write-to-system') final  bool writeToSystem;

/// Create a copy of Ntp
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NtpCopyWith<_Ntp> get copyWith => __$NtpCopyWithImpl<_Ntp>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$NtpToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Ntp&&(identical(other.enable, enable) || other.enable == enable)&&(identical(other.server, server) || other.server == server)&&(identical(other.port, port) || other.port == port)&&(identical(other.interval, interval) || other.interval == interval)&&(identical(other.dialerProxy, dialerProxy) || other.dialerProxy == dialerProxy)&&(identical(other.writeToSystem, writeToSystem) || other.writeToSystem == writeToSystem));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,enable,server,port,interval,dialerProxy,writeToSystem);
}

@override
String toString() {
    return 'Ntp(enable: $enable, server: $server, port: $port, interval: $interval, dialerProxy: $dialerProxy, writeToSystem: $writeToSystem)';
}


}

/// @nodoc
abstract mixin class _$NtpCopyWith<$Res> implements $NtpCopyWith<$Res> {
  factory _$NtpCopyWith(_Ntp value, $Res Function(_Ntp) _then) = __$NtpCopyWithImpl;
@override @useResult
$Res call({
 bool enable, String server, int port, int interval,@JsonKey(name: 'dialer-proxy') String dialerProxy,@JsonKey(name: 'write-to-system') bool writeToSystem
});




}
/// @nodoc
class __$NtpCopyWithImpl<$Res>
    implements _$NtpCopyWith<$Res> {
  __$NtpCopyWithImpl(this._self, this._then);

  final _Ntp _self;
  final $Res Function(_Ntp) _then;

/// Create a copy of Ntp
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? enable = null,Object? server = null,Object? port = null,Object? interval = null,Object? dialerProxy = null,Object? writeToSystem = null,}) {
  return _then(_Ntp(
enable: null == enable ? _self.enable : enable // ignore: cast_nullable_to_non_nullable
as bool,server: null == server ? _self.server : server // ignore: cast_nullable_to_non_nullable
as String,port: null == port ? _self.port : port // ignore: cast_nullable_to_non_nullable
as int,interval: null == interval ? _self.interval : interval // ignore: cast_nullable_to_non_nullable
as int,dialerProxy: null == dialerProxy ? _self.dialerProxy : dialerProxy // ignore: cast_nullable_to_non_nullable
as String,writeToSystem: null == writeToSystem ? _self.writeToSystem : writeToSystem // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$ProfileTun {

@JsonKey(name: 'disable-icmp-forwarding') bool get disableIcmpForwarding;@JsonKey(name: 'exclude-interface') List<String> get excludeInterface;
/// Create a copy of ProfileTun
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProfileTunCopyWith<ProfileTun> get copyWith => _$ProfileTunCopyWithImpl<ProfileTun>(this as ProfileTun, _$identity);

  /// Serializes this ProfileTun to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ProfileTun;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProfileTun&&(identical(other.disableIcmpForwarding, _this.disableIcmpForwarding) || other.disableIcmpForwarding == _this.disableIcmpForwarding)&&const DeepCollectionEquality().equals(other.excludeInterface, _this.excludeInterface));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ProfileTun;
  return Object.hash(runtimeType,_this.disableIcmpForwarding,const DeepCollectionEquality().hash(_this.excludeInterface));
}

@override
String toString() {
  final _this = this as ProfileTun;
  return 'ProfileTun(disableIcmpForwarding: ${_this.disableIcmpForwarding}, excludeInterface: ${_this.excludeInterface})';
}


}

/// @nodoc
abstract mixin class $ProfileTunCopyWith<$Res>  {
  factory $ProfileTunCopyWith(ProfileTun value, $Res Function(ProfileTun) _then) = _$ProfileTunCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'disable-icmp-forwarding') bool disableIcmpForwarding,@JsonKey(name: 'exclude-interface') List<String> excludeInterface
});




}
/// @nodoc
class _$ProfileTunCopyWithImpl<$Res>
    implements $ProfileTunCopyWith<$Res> {
  _$ProfileTunCopyWithImpl(this._self, this._then);

  final ProfileTun _self;
  final $Res Function(ProfileTun) _then;

/// Create a copy of ProfileTun
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? disableIcmpForwarding = null,Object? excludeInterface = null,}) {
  return _then(ProfileTun(
disableIcmpForwarding: null == disableIcmpForwarding ? _self.disableIcmpForwarding : disableIcmpForwarding // ignore: cast_nullable_to_non_nullable
as bool,excludeInterface: null == excludeInterface ? _self.excludeInterface : excludeInterface // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [ProfileTun].
extension ProfileTunPatterns on ProfileTun {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProfileTun value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProfileTun() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProfileTun value)  $default,){
final _that = this;
switch (_that) {
case _ProfileTun():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProfileTun value)?  $default,){
final _that = this;
switch (_that) {
case _ProfileTun() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'disable-icmp-forwarding')  bool disableIcmpForwarding, @JsonKey(name: 'exclude-interface')  List<String> excludeInterface)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProfileTun() when $default != null:
return $default(_that.disableIcmpForwarding,_that.excludeInterface);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'disable-icmp-forwarding')  bool disableIcmpForwarding, @JsonKey(name: 'exclude-interface')  List<String> excludeInterface)  $default,) {final _that = this;
switch (_that) {
case _ProfileTun():
return $default(_that.disableIcmpForwarding,_that.excludeInterface);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'disable-icmp-forwarding')  bool disableIcmpForwarding, @JsonKey(name: 'exclude-interface')  List<String> excludeInterface)?  $default,) {final _that = this;
switch (_that) {
case _ProfileTun() when $default != null:
return $default(_that.disableIcmpForwarding,_that.excludeInterface);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProfileTun implements ProfileTun {
  const _ProfileTun({@JsonKey(name: 'disable-icmp-forwarding') this.disableIcmpForwarding = false, @JsonKey(name: 'exclude-interface')  List<String> excludeInterface = const []}): _excludeInterface = excludeInterface;
  factory _ProfileTun.fromJson(Map<String, dynamic> json) => _$ProfileTunFromJson(json);

@override@JsonKey(name: 'disable-icmp-forwarding') final  bool disableIcmpForwarding;
 final  List<String> _excludeInterface;
@override@JsonKey(name: 'exclude-interface') List<String> get excludeInterface {
  if (_excludeInterface is EqualUnmodifiableListView) return _excludeInterface;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_excludeInterface);
}


/// Create a copy of ProfileTun
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProfileTunCopyWith<_ProfileTun> get copyWith => __$ProfileTunCopyWithImpl<_ProfileTun>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProfileTunToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProfileTun&&(identical(other.disableIcmpForwarding, disableIcmpForwarding) || other.disableIcmpForwarding == disableIcmpForwarding)&&const DeepCollectionEquality().equals(other.excludeInterface, _excludeInterface));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,disableIcmpForwarding,const DeepCollectionEquality().hash(_excludeInterface));
}

@override
String toString() {
    return 'ProfileTun(disableIcmpForwarding: $disableIcmpForwarding, excludeInterface: $excludeInterface)';
}


}

/// @nodoc
abstract mixin class _$ProfileTunCopyWith<$Res> implements $ProfileTunCopyWith<$Res> {
  factory _$ProfileTunCopyWith(_ProfileTun value, $Res Function(_ProfileTun) _then) = __$ProfileTunCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'disable-icmp-forwarding') bool disableIcmpForwarding,@JsonKey(name: 'exclude-interface') List<String> excludeInterface
});




}
/// @nodoc
class __$ProfileTunCopyWithImpl<$Res>
    implements _$ProfileTunCopyWith<$Res> {
  __$ProfileTunCopyWithImpl(this._self, this._then);

  final _ProfileTun _self;
  final $Res Function(_ProfileTun) _then;

/// Create a copy of ProfileTun
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? disableIcmpForwarding = null,Object? excludeInterface = null,}) {
  return _then(_ProfileTun(
disableIcmpForwarding: null == disableIcmpForwarding ? _self.disableIcmpForwarding : disableIcmpForwarding // ignore: cast_nullable_to_non_nullable
as bool,excludeInterface: null == excludeInterface ? _self._excludeInterface : excludeInterface // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}


/// @nodoc
mixin _$ProfileOverrides {

@JsonKey(fromJson: Dns.safeDnsFromJson) Dns get dns;@JsonKey(name: _dnsOverrideKeysJsonKey, fromJson: _dnsOverrideKeysFromJson) Set<DnsOverrideKey> get dnsOverrideKeys;@JsonKey(fromJson: Ntp.safeNtpFromJson) Ntp get ntp;@JsonKey(name: _ntpOverrideKeysJsonKey, fromJson: _ntpOverrideKeysFromJson) Set<NtpOverrideKey> get ntpOverrideKeys;@JsonKey(fromJson: Sniffer.safeSnifferFromJson) Sniffer get sniffer;@JsonKey(name: _snifferOverrideKeysJsonKey, fromJson: _snifferOverrideKeysFromJson) Set<SnifferOverrideKey> get snifferOverrideKeys;@JsonKey(fromJson: ProfileTun.safeFromJson) ProfileTun get tun;@JsonKey(name: _tunOverrideKeysJsonKey, fromJson: _tunOverrideKeysFromJson) Set<TunOverrideKey> get tunOverrideKeys;@JsonKey(name: 'proxy-providers') Map<String, ProxyProviderOptions> get proxyProviders;
/// Create a copy of ProfileOverrides
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProfileOverridesCopyWith<ProfileOverrides> get copyWith => _$ProfileOverridesCopyWithImpl<ProfileOverrides>(this as ProfileOverrides, _$identity);

  /// Serializes this ProfileOverrides to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ProfileOverrides;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProfileOverrides&&(identical(other.dns, _this.dns) || other.dns == _this.dns)&&const DeepCollectionEquality().equals(other.dnsOverrideKeys, _this.dnsOverrideKeys)&&(identical(other.ntp, _this.ntp) || other.ntp == _this.ntp)&&const DeepCollectionEquality().equals(other.ntpOverrideKeys, _this.ntpOverrideKeys)&&(identical(other.sniffer, _this.sniffer) || other.sniffer == _this.sniffer)&&const DeepCollectionEquality().equals(other.snifferOverrideKeys, _this.snifferOverrideKeys)&&(identical(other.tun, _this.tun) || other.tun == _this.tun)&&const DeepCollectionEquality().equals(other.tunOverrideKeys, _this.tunOverrideKeys)&&const DeepCollectionEquality().equals(other.proxyProviders, _this.proxyProviders));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ProfileOverrides;
  return Object.hash(runtimeType,_this.dns,const DeepCollectionEquality().hash(_this.dnsOverrideKeys),_this.ntp,const DeepCollectionEquality().hash(_this.ntpOverrideKeys),_this.sniffer,const DeepCollectionEquality().hash(_this.snifferOverrideKeys),_this.tun,const DeepCollectionEquality().hash(_this.tunOverrideKeys),const DeepCollectionEquality().hash(_this.proxyProviders));
}

@override
String toString() {
  final _this = this as ProfileOverrides;
  return 'ProfileOverrides(dns: ${_this.dns}, dnsOverrideKeys: ${_this.dnsOverrideKeys}, ntp: ${_this.ntp}, ntpOverrideKeys: ${_this.ntpOverrideKeys}, sniffer: ${_this.sniffer}, snifferOverrideKeys: ${_this.snifferOverrideKeys}, tun: ${_this.tun}, tunOverrideKeys: ${_this.tunOverrideKeys}, proxyProviders: ${_this.proxyProviders})';
}


}

/// @nodoc
abstract mixin class $ProfileOverridesCopyWith<$Res>  {
  factory $ProfileOverridesCopyWith(ProfileOverrides value, $Res Function(ProfileOverrides) _then) = _$ProfileOverridesCopyWithImpl;
@useResult
$Res call({
@JsonKey(fromJson: Dns.safeDnsFromJson) Dns dns,@JsonKey(name: _dnsOverrideKeysJsonKey, fromJson: _dnsOverrideKeysFromJson) Set<DnsOverrideKey> dnsOverrideKeys,@JsonKey(fromJson: Ntp.safeNtpFromJson) Ntp ntp,@JsonKey(name: _ntpOverrideKeysJsonKey, fromJson: _ntpOverrideKeysFromJson) Set<NtpOverrideKey> ntpOverrideKeys,@JsonKey(fromJson: Sniffer.safeSnifferFromJson) Sniffer sniffer,@JsonKey(name: _snifferOverrideKeysJsonKey, fromJson: _snifferOverrideKeysFromJson) Set<SnifferOverrideKey> snifferOverrideKeys,@JsonKey(fromJson: ProfileTun.safeFromJson) ProfileTun tun,@JsonKey(name: _tunOverrideKeysJsonKey, fromJson: _tunOverrideKeysFromJson) Set<TunOverrideKey> tunOverrideKeys,@JsonKey(name: 'proxy-providers') Map<String, ProxyProviderOptions> proxyProviders
});


$DnsCopyWith<$Res> get dns;$NtpCopyWith<$Res> get ntp;$SnifferCopyWith<$Res> get sniffer;$ProfileTunCopyWith<$Res> get tun;

}
/// @nodoc
class _$ProfileOverridesCopyWithImpl<$Res>
    implements $ProfileOverridesCopyWith<$Res> {
  _$ProfileOverridesCopyWithImpl(this._self, this._then);

  final ProfileOverrides _self;
  final $Res Function(ProfileOverrides) _then;

/// Create a copy of ProfileOverrides
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? dns = null,Object? dnsOverrideKeys = null,Object? ntp = null,Object? ntpOverrideKeys = null,Object? sniffer = null,Object? snifferOverrideKeys = null,Object? tun = null,Object? tunOverrideKeys = null,Object? proxyProviders = null,}) {
  return _then(ProfileOverrides(
dns: null == dns ? _self.dns : dns // ignore: cast_nullable_to_non_nullable
as Dns,dnsOverrideKeys: null == dnsOverrideKeys ? _self.dnsOverrideKeys : dnsOverrideKeys // ignore: cast_nullable_to_non_nullable
as Set<DnsOverrideKey>,ntp: null == ntp ? _self.ntp : ntp // ignore: cast_nullable_to_non_nullable
as Ntp,ntpOverrideKeys: null == ntpOverrideKeys ? _self.ntpOverrideKeys : ntpOverrideKeys // ignore: cast_nullable_to_non_nullable
as Set<NtpOverrideKey>,sniffer: null == sniffer ? _self.sniffer : sniffer // ignore: cast_nullable_to_non_nullable
as Sniffer,snifferOverrideKeys: null == snifferOverrideKeys ? _self.snifferOverrideKeys : snifferOverrideKeys // ignore: cast_nullable_to_non_nullable
as Set<SnifferOverrideKey>,tun: null == tun ? _self.tun : tun // ignore: cast_nullable_to_non_nullable
as ProfileTun,tunOverrideKeys: null == tunOverrideKeys ? _self.tunOverrideKeys : tunOverrideKeys // ignore: cast_nullable_to_non_nullable
as Set<TunOverrideKey>,proxyProviders: null == proxyProviders ? _self.proxyProviders : proxyProviders // ignore: cast_nullable_to_non_nullable
as Map<String, ProxyProviderOptions>,
  ));
}
/// Create a copy of ProfileOverrides
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DnsCopyWith<$Res> get dns {
  
  return $DnsCopyWith<$Res>(_self.dns, (value) {
    return _then(_self.copyWith(dns: value));
  });
}/// Create a copy of ProfileOverrides
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$NtpCopyWith<$Res> get ntp {
  
  return $NtpCopyWith<$Res>(_self.ntp, (value) {
    return _then(_self.copyWith(ntp: value));
  });
}/// Create a copy of ProfileOverrides
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnifferCopyWith<$Res> get sniffer {
  
  return $SnifferCopyWith<$Res>(_self.sniffer, (value) {
    return _then(_self.copyWith(sniffer: value));
  });
}/// Create a copy of ProfileOverrides
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProfileTunCopyWith<$Res> get tun {
  
  return $ProfileTunCopyWith<$Res>(_self.tun, (value) {
    return _then(_self.copyWith(tun: value));
  });
}
}


/// Adds pattern-matching-related methods to [ProfileOverrides].
extension ProfileOverridesPatterns on ProfileOverrides {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProfileOverrides value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProfileOverrides() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProfileOverrides value)  $default,){
final _that = this;
switch (_that) {
case _ProfileOverrides():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProfileOverrides value)?  $default,){
final _that = this;
switch (_that) {
case _ProfileOverrides() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(fromJson: Dns.safeDnsFromJson)  Dns dns, @JsonKey(name: _dnsOverrideKeysJsonKey, fromJson: _dnsOverrideKeysFromJson)  Set<DnsOverrideKey> dnsOverrideKeys, @JsonKey(fromJson: Ntp.safeNtpFromJson)  Ntp ntp, @JsonKey(name: _ntpOverrideKeysJsonKey, fromJson: _ntpOverrideKeysFromJson)  Set<NtpOverrideKey> ntpOverrideKeys, @JsonKey(fromJson: Sniffer.safeSnifferFromJson)  Sniffer sniffer, @JsonKey(name: _snifferOverrideKeysJsonKey, fromJson: _snifferOverrideKeysFromJson)  Set<SnifferOverrideKey> snifferOverrideKeys, @JsonKey(fromJson: ProfileTun.safeFromJson)  ProfileTun tun, @JsonKey(name: _tunOverrideKeysJsonKey, fromJson: _tunOverrideKeysFromJson)  Set<TunOverrideKey> tunOverrideKeys, @JsonKey(name: 'proxy-providers')  Map<String, ProxyProviderOptions> proxyProviders)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProfileOverrides() when $default != null:
return $default(_that.dns,_that.dnsOverrideKeys,_that.ntp,_that.ntpOverrideKeys,_that.sniffer,_that.snifferOverrideKeys,_that.tun,_that.tunOverrideKeys,_that.proxyProviders);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(fromJson: Dns.safeDnsFromJson)  Dns dns, @JsonKey(name: _dnsOverrideKeysJsonKey, fromJson: _dnsOverrideKeysFromJson)  Set<DnsOverrideKey> dnsOverrideKeys, @JsonKey(fromJson: Ntp.safeNtpFromJson)  Ntp ntp, @JsonKey(name: _ntpOverrideKeysJsonKey, fromJson: _ntpOverrideKeysFromJson)  Set<NtpOverrideKey> ntpOverrideKeys, @JsonKey(fromJson: Sniffer.safeSnifferFromJson)  Sniffer sniffer, @JsonKey(name: _snifferOverrideKeysJsonKey, fromJson: _snifferOverrideKeysFromJson)  Set<SnifferOverrideKey> snifferOverrideKeys, @JsonKey(fromJson: ProfileTun.safeFromJson)  ProfileTun tun, @JsonKey(name: _tunOverrideKeysJsonKey, fromJson: _tunOverrideKeysFromJson)  Set<TunOverrideKey> tunOverrideKeys, @JsonKey(name: 'proxy-providers')  Map<String, ProxyProviderOptions> proxyProviders)  $default,) {final _that = this;
switch (_that) {
case _ProfileOverrides():
return $default(_that.dns,_that.dnsOverrideKeys,_that.ntp,_that.ntpOverrideKeys,_that.sniffer,_that.snifferOverrideKeys,_that.tun,_that.tunOverrideKeys,_that.proxyProviders);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(fromJson: Dns.safeDnsFromJson)  Dns dns, @JsonKey(name: _dnsOverrideKeysJsonKey, fromJson: _dnsOverrideKeysFromJson)  Set<DnsOverrideKey> dnsOverrideKeys, @JsonKey(fromJson: Ntp.safeNtpFromJson)  Ntp ntp, @JsonKey(name: _ntpOverrideKeysJsonKey, fromJson: _ntpOverrideKeysFromJson)  Set<NtpOverrideKey> ntpOverrideKeys, @JsonKey(fromJson: Sniffer.safeSnifferFromJson)  Sniffer sniffer, @JsonKey(name: _snifferOverrideKeysJsonKey, fromJson: _snifferOverrideKeysFromJson)  Set<SnifferOverrideKey> snifferOverrideKeys, @JsonKey(fromJson: ProfileTun.safeFromJson)  ProfileTun tun, @JsonKey(name: _tunOverrideKeysJsonKey, fromJson: _tunOverrideKeysFromJson)  Set<TunOverrideKey> tunOverrideKeys, @JsonKey(name: 'proxy-providers')  Map<String, ProxyProviderOptions> proxyProviders)?  $default,) {final _that = this;
switch (_that) {
case _ProfileOverrides() when $default != null:
return $default(_that.dns,_that.dnsOverrideKeys,_that.ntp,_that.ntpOverrideKeys,_that.sniffer,_that.snifferOverrideKeys,_that.tun,_that.tunOverrideKeys,_that.proxyProviders);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProfileOverrides implements ProfileOverrides {
  const _ProfileOverrides({@JsonKey(fromJson: Dns.safeDnsFromJson) this.dns = defaultDns, @JsonKey(name: _dnsOverrideKeysJsonKey, fromJson: _dnsOverrideKeysFromJson)  Set<DnsOverrideKey> dnsOverrideKeys = const {}, @JsonKey(fromJson: Ntp.safeNtpFromJson) this.ntp = defaultNtp, @JsonKey(name: _ntpOverrideKeysJsonKey, fromJson: _ntpOverrideKeysFromJson)  Set<NtpOverrideKey> ntpOverrideKeys = const {}, @JsonKey(fromJson: Sniffer.safeSnifferFromJson) this.sniffer = defaultSniffer, @JsonKey(name: _snifferOverrideKeysJsonKey, fromJson: _snifferOverrideKeysFromJson)  Set<SnifferOverrideKey> snifferOverrideKeys = const {}, @JsonKey(fromJson: ProfileTun.safeFromJson) this.tun = defaultProfileTun, @JsonKey(name: _tunOverrideKeysJsonKey, fromJson: _tunOverrideKeysFromJson)  Set<TunOverrideKey> tunOverrideKeys = const {}, @JsonKey(name: 'proxy-providers')  Map<String, ProxyProviderOptions> proxyProviders = const {}}): _dnsOverrideKeys = dnsOverrideKeys,_ntpOverrideKeys = ntpOverrideKeys,_snifferOverrideKeys = snifferOverrideKeys,_tunOverrideKeys = tunOverrideKeys,_proxyProviders = proxyProviders;
  factory _ProfileOverrides.fromJson(Map<String, dynamic> json) => _$ProfileOverridesFromJson(json);

@override@JsonKey(fromJson: Dns.safeDnsFromJson) final  Dns dns;
 final  Set<DnsOverrideKey> _dnsOverrideKeys;
@override@JsonKey(name: _dnsOverrideKeysJsonKey, fromJson: _dnsOverrideKeysFromJson) Set<DnsOverrideKey> get dnsOverrideKeys {
  if (_dnsOverrideKeys is EqualUnmodifiableSetView) return _dnsOverrideKeys;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_dnsOverrideKeys);
}

@override@JsonKey(fromJson: Ntp.safeNtpFromJson) final  Ntp ntp;
 final  Set<NtpOverrideKey> _ntpOverrideKeys;
@override@JsonKey(name: _ntpOverrideKeysJsonKey, fromJson: _ntpOverrideKeysFromJson) Set<NtpOverrideKey> get ntpOverrideKeys {
  if (_ntpOverrideKeys is EqualUnmodifiableSetView) return _ntpOverrideKeys;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_ntpOverrideKeys);
}

@override@JsonKey(fromJson: Sniffer.safeSnifferFromJson) final  Sniffer sniffer;
 final  Set<SnifferOverrideKey> _snifferOverrideKeys;
@override@JsonKey(name: _snifferOverrideKeysJsonKey, fromJson: _snifferOverrideKeysFromJson) Set<SnifferOverrideKey> get snifferOverrideKeys {
  if (_snifferOverrideKeys is EqualUnmodifiableSetView) return _snifferOverrideKeys;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_snifferOverrideKeys);
}

@override@JsonKey(fromJson: ProfileTun.safeFromJson) final  ProfileTun tun;
 final  Set<TunOverrideKey> _tunOverrideKeys;
@override@JsonKey(name: _tunOverrideKeysJsonKey, fromJson: _tunOverrideKeysFromJson) Set<TunOverrideKey> get tunOverrideKeys {
  if (_tunOverrideKeys is EqualUnmodifiableSetView) return _tunOverrideKeys;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_tunOverrideKeys);
}

 final  Map<String, ProxyProviderOptions> _proxyProviders;
@override@JsonKey(name: 'proxy-providers') Map<String, ProxyProviderOptions> get proxyProviders {
  if (_proxyProviders is EqualUnmodifiableMapView) return _proxyProviders;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_proxyProviders);
}


/// Create a copy of ProfileOverrides
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProfileOverridesCopyWith<_ProfileOverrides> get copyWith => __$ProfileOverridesCopyWithImpl<_ProfileOverrides>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProfileOverridesToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProfileOverrides&&(identical(other.dns, dns) || other.dns == dns)&&const DeepCollectionEquality().equals(other.dnsOverrideKeys, _dnsOverrideKeys)&&(identical(other.ntp, ntp) || other.ntp == ntp)&&const DeepCollectionEquality().equals(other.ntpOverrideKeys, _ntpOverrideKeys)&&(identical(other.sniffer, sniffer) || other.sniffer == sniffer)&&const DeepCollectionEquality().equals(other.snifferOverrideKeys, _snifferOverrideKeys)&&(identical(other.tun, tun) || other.tun == tun)&&const DeepCollectionEquality().equals(other.tunOverrideKeys, _tunOverrideKeys)&&const DeepCollectionEquality().equals(other.proxyProviders, _proxyProviders));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,dns,const DeepCollectionEquality().hash(_dnsOverrideKeys),ntp,const DeepCollectionEquality().hash(_ntpOverrideKeys),sniffer,const DeepCollectionEquality().hash(_snifferOverrideKeys),tun,const DeepCollectionEquality().hash(_tunOverrideKeys),const DeepCollectionEquality().hash(_proxyProviders));
}

@override
String toString() {
    return 'ProfileOverrides(dns: $dns, dnsOverrideKeys: $dnsOverrideKeys, ntp: $ntp, ntpOverrideKeys: $ntpOverrideKeys, sniffer: $sniffer, snifferOverrideKeys: $snifferOverrideKeys, tun: $tun, tunOverrideKeys: $tunOverrideKeys, proxyProviders: $proxyProviders)';
}


}

/// @nodoc
abstract mixin class _$ProfileOverridesCopyWith<$Res> implements $ProfileOverridesCopyWith<$Res> {
  factory _$ProfileOverridesCopyWith(_ProfileOverrides value, $Res Function(_ProfileOverrides) _then) = __$ProfileOverridesCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(fromJson: Dns.safeDnsFromJson) Dns dns,@JsonKey(name: _dnsOverrideKeysJsonKey, fromJson: _dnsOverrideKeysFromJson) Set<DnsOverrideKey> dnsOverrideKeys,@JsonKey(fromJson: Ntp.safeNtpFromJson) Ntp ntp,@JsonKey(name: _ntpOverrideKeysJsonKey, fromJson: _ntpOverrideKeysFromJson) Set<NtpOverrideKey> ntpOverrideKeys,@JsonKey(fromJson: Sniffer.safeSnifferFromJson) Sniffer sniffer,@JsonKey(name: _snifferOverrideKeysJsonKey, fromJson: _snifferOverrideKeysFromJson) Set<SnifferOverrideKey> snifferOverrideKeys,@JsonKey(fromJson: ProfileTun.safeFromJson) ProfileTun tun,@JsonKey(name: _tunOverrideKeysJsonKey, fromJson: _tunOverrideKeysFromJson) Set<TunOverrideKey> tunOverrideKeys,@JsonKey(name: 'proxy-providers') Map<String, ProxyProviderOptions> proxyProviders
});


@override $DnsCopyWith<$Res> get dns;@override $NtpCopyWith<$Res> get ntp;@override $SnifferCopyWith<$Res> get sniffer;@override $ProfileTunCopyWith<$Res> get tun;

}
/// @nodoc
class __$ProfileOverridesCopyWithImpl<$Res>
    implements _$ProfileOverridesCopyWith<$Res> {
  __$ProfileOverridesCopyWithImpl(this._self, this._then);

  final _ProfileOverrides _self;
  final $Res Function(_ProfileOverrides) _then;

/// Create a copy of ProfileOverrides
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? dns = null,Object? dnsOverrideKeys = null,Object? ntp = null,Object? ntpOverrideKeys = null,Object? sniffer = null,Object? snifferOverrideKeys = null,Object? tun = null,Object? tunOverrideKeys = null,Object? proxyProviders = null,}) {
  return _then(_ProfileOverrides(
dns: null == dns ? _self.dns : dns // ignore: cast_nullable_to_non_nullable
as Dns,dnsOverrideKeys: null == dnsOverrideKeys ? _self._dnsOverrideKeys : dnsOverrideKeys // ignore: cast_nullable_to_non_nullable
as Set<DnsOverrideKey>,ntp: null == ntp ? _self.ntp : ntp // ignore: cast_nullable_to_non_nullable
as Ntp,ntpOverrideKeys: null == ntpOverrideKeys ? _self._ntpOverrideKeys : ntpOverrideKeys // ignore: cast_nullable_to_non_nullable
as Set<NtpOverrideKey>,sniffer: null == sniffer ? _self.sniffer : sniffer // ignore: cast_nullable_to_non_nullable
as Sniffer,snifferOverrideKeys: null == snifferOverrideKeys ? _self._snifferOverrideKeys : snifferOverrideKeys // ignore: cast_nullable_to_non_nullable
as Set<SnifferOverrideKey>,tun: null == tun ? _self.tun : tun // ignore: cast_nullable_to_non_nullable
as ProfileTun,tunOverrideKeys: null == tunOverrideKeys ? _self._tunOverrideKeys : tunOverrideKeys // ignore: cast_nullable_to_non_nullable
as Set<TunOverrideKey>,proxyProviders: null == proxyProviders ? _self._proxyProviders : proxyProviders // ignore: cast_nullable_to_non_nullable
as Map<String, ProxyProviderOptions>,
  ));
}

/// Create a copy of ProfileOverrides
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DnsCopyWith<$Res> get dns {
  
  return $DnsCopyWith<$Res>(_self.dns, (value) {
    return _then(_self.copyWith(dns: value));
  });
}/// Create a copy of ProfileOverrides
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$NtpCopyWith<$Res> get ntp {
  
  return $NtpCopyWith<$Res>(_self.ntp, (value) {
    return _then(_self.copyWith(ntp: value));
  });
}/// Create a copy of ProfileOverrides
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnifferCopyWith<$Res> get sniffer {
  
  return $SnifferCopyWith<$Res>(_self.sniffer, (value) {
    return _then(_self.copyWith(sniffer: value));
  });
}/// Create a copy of ProfileOverrides
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProfileTunCopyWith<$Res> get tun {
  
  return $ProfileTunCopyWith<$Res>(_self.tun, (value) {
    return _then(_self.copyWith(tun: value));
  });
}
}


/// @nodoc
mixin _$ProviderHealthCheck {

 String? get url; int? get interval; int? get timeout; bool? get lazy;@JsonKey(name: 'expected-status') String? get expectedStatus;
/// Create a copy of ProviderHealthCheck
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProviderHealthCheckCopyWith<ProviderHealthCheck> get copyWith => _$ProviderHealthCheckCopyWithImpl<ProviderHealthCheck>(this as ProviderHealthCheck, _$identity);

  /// Serializes this ProviderHealthCheck to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ProviderHealthCheck;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProviderHealthCheck&&(identical(other.url, _this.url) || other.url == _this.url)&&(identical(other.interval, _this.interval) || other.interval == _this.interval)&&(identical(other.timeout, _this.timeout) || other.timeout == _this.timeout)&&(identical(other.lazy, _this.lazy) || other.lazy == _this.lazy)&&(identical(other.expectedStatus, _this.expectedStatus) || other.expectedStatus == _this.expectedStatus));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ProviderHealthCheck;
  return Object.hash(runtimeType,_this.url,_this.interval,_this.timeout,_this.lazy,_this.expectedStatus);
}

@override
String toString() {
  final _this = this as ProviderHealthCheck;
  return 'ProviderHealthCheck(url: ${_this.url}, interval: ${_this.interval}, timeout: ${_this.timeout}, lazy: ${_this.lazy}, expectedStatus: ${_this.expectedStatus})';
}


}

/// @nodoc
abstract mixin class $ProviderHealthCheckCopyWith<$Res>  {
  factory $ProviderHealthCheckCopyWith(ProviderHealthCheck value, $Res Function(ProviderHealthCheck) _then) = _$ProviderHealthCheckCopyWithImpl;
@useResult
$Res call({
 String? url, int? interval, int? timeout, bool? lazy,@JsonKey(name: 'expected-status') String? expectedStatus
});




}
/// @nodoc
class _$ProviderHealthCheckCopyWithImpl<$Res>
    implements $ProviderHealthCheckCopyWith<$Res> {
  _$ProviderHealthCheckCopyWithImpl(this._self, this._then);

  final ProviderHealthCheck _self;
  final $Res Function(ProviderHealthCheck) _then;

/// Create a copy of ProviderHealthCheck
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? url = freezed,Object? interval = freezed,Object? timeout = freezed,Object? lazy = freezed,Object? expectedStatus = freezed,}) {
  return _then(ProviderHealthCheck(
url: freezed == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String?,interval: freezed == interval ? _self.interval : interval // ignore: cast_nullable_to_non_nullable
as int?,timeout: freezed == timeout ? _self.timeout : timeout // ignore: cast_nullable_to_non_nullable
as int?,lazy: freezed == lazy ? _self.lazy : lazy // ignore: cast_nullable_to_non_nullable
as bool?,expectedStatus: freezed == expectedStatus ? _self.expectedStatus : expectedStatus // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ProviderHealthCheck].
extension ProviderHealthCheckPatterns on ProviderHealthCheck {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProviderHealthCheck value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProviderHealthCheck() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProviderHealthCheck value)  $default,){
final _that = this;
switch (_that) {
case _ProviderHealthCheck():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProviderHealthCheck value)?  $default,){
final _that = this;
switch (_that) {
case _ProviderHealthCheck() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? url,  int? interval,  int? timeout,  bool? lazy, @JsonKey(name: 'expected-status')  String? expectedStatus)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProviderHealthCheck() when $default != null:
return $default(_that.url,_that.interval,_that.timeout,_that.lazy,_that.expectedStatus);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? url,  int? interval,  int? timeout,  bool? lazy, @JsonKey(name: 'expected-status')  String? expectedStatus)  $default,) {final _that = this;
switch (_that) {
case _ProviderHealthCheck():
return $default(_that.url,_that.interval,_that.timeout,_that.lazy,_that.expectedStatus);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? url,  int? interval,  int? timeout,  bool? lazy, @JsonKey(name: 'expected-status')  String? expectedStatus)?  $default,) {final _that = this;
switch (_that) {
case _ProviderHealthCheck() when $default != null:
return $default(_that.url,_that.interval,_that.timeout,_that.lazy,_that.expectedStatus);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProviderHealthCheck implements ProviderHealthCheck {
  const _ProviderHealthCheck({this.url, this.interval, this.timeout, this.lazy, @JsonKey(name: 'expected-status') this.expectedStatus});
  factory _ProviderHealthCheck.fromJson(Map<String, dynamic> json) => _$ProviderHealthCheckFromJson(json);

@override final  String? url;
@override final  int? interval;
@override final  int? timeout;
@override final  bool? lazy;
@override@JsonKey(name: 'expected-status') final  String? expectedStatus;

/// Create a copy of ProviderHealthCheck
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProviderHealthCheckCopyWith<_ProviderHealthCheck> get copyWith => __$ProviderHealthCheckCopyWithImpl<_ProviderHealthCheck>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProviderHealthCheckToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProviderHealthCheck&&(identical(other.url, url) || other.url == url)&&(identical(other.interval, interval) || other.interval == interval)&&(identical(other.timeout, timeout) || other.timeout == timeout)&&(identical(other.lazy, lazy) || other.lazy == lazy)&&(identical(other.expectedStatus, expectedStatus) || other.expectedStatus == expectedStatus));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,url,interval,timeout,lazy,expectedStatus);
}

@override
String toString() {
    return 'ProviderHealthCheck(url: $url, interval: $interval, timeout: $timeout, lazy: $lazy, expectedStatus: $expectedStatus)';
}


}

/// @nodoc
abstract mixin class _$ProviderHealthCheckCopyWith<$Res> implements $ProviderHealthCheckCopyWith<$Res> {
  factory _$ProviderHealthCheckCopyWith(_ProviderHealthCheck value, $Res Function(_ProviderHealthCheck) _then) = __$ProviderHealthCheckCopyWithImpl;
@override @useResult
$Res call({
 String? url, int? interval, int? timeout, bool? lazy,@JsonKey(name: 'expected-status') String? expectedStatus
});




}
/// @nodoc
class __$ProviderHealthCheckCopyWithImpl<$Res>
    implements _$ProviderHealthCheckCopyWith<$Res> {
  __$ProviderHealthCheckCopyWithImpl(this._self, this._then);

  final _ProviderHealthCheck _self;
  final $Res Function(_ProviderHealthCheck) _then;

/// Create a copy of ProviderHealthCheck
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? url = freezed,Object? interval = freezed,Object? timeout = freezed,Object? lazy = freezed,Object? expectedStatus = freezed,}) {
  return _then(_ProviderHealthCheck(
url: freezed == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String?,interval: freezed == interval ? _self.interval : interval // ignore: cast_nullable_to_non_nullable
as int?,timeout: freezed == timeout ? _self.timeout : timeout // ignore: cast_nullable_to_non_nullable
as int?,lazy: freezed == lazy ? _self.lazy : lazy // ignore: cast_nullable_to_non_nullable
as bool?,expectedStatus: freezed == expectedStatus ? _self.expectedStatus : expectedStatus // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$ProviderOverride {

@JsonKey(name: 'additional-prefix') String? get additionalPrefix;@JsonKey(name: 'additional-suffix') String? get additionalSuffix; bool? get udp;@JsonKey(name: 'skip-cert-verify') bool? get skipCertVerify;@JsonKey(name: 'ip-version') IpVersion? get ipVersion;
/// Create a copy of ProviderOverride
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProviderOverrideCopyWith<ProviderOverride> get copyWith => _$ProviderOverrideCopyWithImpl<ProviderOverride>(this as ProviderOverride, _$identity);

  /// Serializes this ProviderOverride to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ProviderOverride;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProviderOverride&&(identical(other.additionalPrefix, _this.additionalPrefix) || other.additionalPrefix == _this.additionalPrefix)&&(identical(other.additionalSuffix, _this.additionalSuffix) || other.additionalSuffix == _this.additionalSuffix)&&(identical(other.udp, _this.udp) || other.udp == _this.udp)&&(identical(other.skipCertVerify, _this.skipCertVerify) || other.skipCertVerify == _this.skipCertVerify)&&(identical(other.ipVersion, _this.ipVersion) || other.ipVersion == _this.ipVersion));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ProviderOverride;
  return Object.hash(runtimeType,_this.additionalPrefix,_this.additionalSuffix,_this.udp,_this.skipCertVerify,_this.ipVersion);
}

@override
String toString() {
  final _this = this as ProviderOverride;
  return 'ProviderOverride(additionalPrefix: ${_this.additionalPrefix}, additionalSuffix: ${_this.additionalSuffix}, udp: ${_this.udp}, skipCertVerify: ${_this.skipCertVerify}, ipVersion: ${_this.ipVersion})';
}


}

/// @nodoc
abstract mixin class $ProviderOverrideCopyWith<$Res>  {
  factory $ProviderOverrideCopyWith(ProviderOverride value, $Res Function(ProviderOverride) _then) = _$ProviderOverrideCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'additional-prefix') String? additionalPrefix,@JsonKey(name: 'additional-suffix') String? additionalSuffix, bool? udp,@JsonKey(name: 'skip-cert-verify') bool? skipCertVerify,@JsonKey(name: 'ip-version') IpVersion? ipVersion
});




}
/// @nodoc
class _$ProviderOverrideCopyWithImpl<$Res>
    implements $ProviderOverrideCopyWith<$Res> {
  _$ProviderOverrideCopyWithImpl(this._self, this._then);

  final ProviderOverride _self;
  final $Res Function(ProviderOverride) _then;

/// Create a copy of ProviderOverride
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? additionalPrefix = freezed,Object? additionalSuffix = freezed,Object? udp = freezed,Object? skipCertVerify = freezed,Object? ipVersion = freezed,}) {
  return _then(ProviderOverride(
additionalPrefix: freezed == additionalPrefix ? _self.additionalPrefix : additionalPrefix // ignore: cast_nullable_to_non_nullable
as String?,additionalSuffix: freezed == additionalSuffix ? _self.additionalSuffix : additionalSuffix // ignore: cast_nullable_to_non_nullable
as String?,udp: freezed == udp ? _self.udp : udp // ignore: cast_nullable_to_non_nullable
as bool?,skipCertVerify: freezed == skipCertVerify ? _self.skipCertVerify : skipCertVerify // ignore: cast_nullable_to_non_nullable
as bool?,ipVersion: freezed == ipVersion ? _self.ipVersion : ipVersion // ignore: cast_nullable_to_non_nullable
as IpVersion?,
  ));
}

}


/// Adds pattern-matching-related methods to [ProviderOverride].
extension ProviderOverridePatterns on ProviderOverride {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProviderOverride value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProviderOverride() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProviderOverride value)  $default,){
final _that = this;
switch (_that) {
case _ProviderOverride():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProviderOverride value)?  $default,){
final _that = this;
switch (_that) {
case _ProviderOverride() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'additional-prefix')  String? additionalPrefix, @JsonKey(name: 'additional-suffix')  String? additionalSuffix,  bool? udp, @JsonKey(name: 'skip-cert-verify')  bool? skipCertVerify, @JsonKey(name: 'ip-version')  IpVersion? ipVersion)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProviderOverride() when $default != null:
return $default(_that.additionalPrefix,_that.additionalSuffix,_that.udp,_that.skipCertVerify,_that.ipVersion);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'additional-prefix')  String? additionalPrefix, @JsonKey(name: 'additional-suffix')  String? additionalSuffix,  bool? udp, @JsonKey(name: 'skip-cert-verify')  bool? skipCertVerify, @JsonKey(name: 'ip-version')  IpVersion? ipVersion)  $default,) {final _that = this;
switch (_that) {
case _ProviderOverride():
return $default(_that.additionalPrefix,_that.additionalSuffix,_that.udp,_that.skipCertVerify,_that.ipVersion);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'additional-prefix')  String? additionalPrefix, @JsonKey(name: 'additional-suffix')  String? additionalSuffix,  bool? udp, @JsonKey(name: 'skip-cert-verify')  bool? skipCertVerify, @JsonKey(name: 'ip-version')  IpVersion? ipVersion)?  $default,) {final _that = this;
switch (_that) {
case _ProviderOverride() when $default != null:
return $default(_that.additionalPrefix,_that.additionalSuffix,_that.udp,_that.skipCertVerify,_that.ipVersion);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProviderOverride implements ProviderOverride {
  const _ProviderOverride({@JsonKey(name: 'additional-prefix') this.additionalPrefix, @JsonKey(name: 'additional-suffix') this.additionalSuffix, this.udp, @JsonKey(name: 'skip-cert-verify') this.skipCertVerify, @JsonKey(name: 'ip-version') this.ipVersion});
  factory _ProviderOverride.fromJson(Map<String, dynamic> json) => _$ProviderOverrideFromJson(json);

@override@JsonKey(name: 'additional-prefix') final  String? additionalPrefix;
@override@JsonKey(name: 'additional-suffix') final  String? additionalSuffix;
@override final  bool? udp;
@override@JsonKey(name: 'skip-cert-verify') final  bool? skipCertVerify;
@override@JsonKey(name: 'ip-version') final  IpVersion? ipVersion;

/// Create a copy of ProviderOverride
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProviderOverrideCopyWith<_ProviderOverride> get copyWith => __$ProviderOverrideCopyWithImpl<_ProviderOverride>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProviderOverrideToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProviderOverride&&(identical(other.additionalPrefix, additionalPrefix) || other.additionalPrefix == additionalPrefix)&&(identical(other.additionalSuffix, additionalSuffix) || other.additionalSuffix == additionalSuffix)&&(identical(other.udp, udp) || other.udp == udp)&&(identical(other.skipCertVerify, skipCertVerify) || other.skipCertVerify == skipCertVerify)&&(identical(other.ipVersion, ipVersion) || other.ipVersion == ipVersion));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,additionalPrefix,additionalSuffix,udp,skipCertVerify,ipVersion);
}

@override
String toString() {
    return 'ProviderOverride(additionalPrefix: $additionalPrefix, additionalSuffix: $additionalSuffix, udp: $udp, skipCertVerify: $skipCertVerify, ipVersion: $ipVersion)';
}


}

/// @nodoc
abstract mixin class _$ProviderOverrideCopyWith<$Res> implements $ProviderOverrideCopyWith<$Res> {
  factory _$ProviderOverrideCopyWith(_ProviderOverride value, $Res Function(_ProviderOverride) _then) = __$ProviderOverrideCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'additional-prefix') String? additionalPrefix,@JsonKey(name: 'additional-suffix') String? additionalSuffix, bool? udp,@JsonKey(name: 'skip-cert-verify') bool? skipCertVerify,@JsonKey(name: 'ip-version') IpVersion? ipVersion
});




}
/// @nodoc
class __$ProviderOverrideCopyWithImpl<$Res>
    implements _$ProviderOverrideCopyWith<$Res> {
  __$ProviderOverrideCopyWithImpl(this._self, this._then);

  final _ProviderOverride _self;
  final $Res Function(_ProviderOverride) _then;

/// Create a copy of ProviderOverride
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? additionalPrefix = freezed,Object? additionalSuffix = freezed,Object? udp = freezed,Object? skipCertVerify = freezed,Object? ipVersion = freezed,}) {
  return _then(_ProviderOverride(
additionalPrefix: freezed == additionalPrefix ? _self.additionalPrefix : additionalPrefix // ignore: cast_nullable_to_non_nullable
as String?,additionalSuffix: freezed == additionalSuffix ? _self.additionalSuffix : additionalSuffix // ignore: cast_nullable_to_non_nullable
as String?,udp: freezed == udp ? _self.udp : udp // ignore: cast_nullable_to_non_nullable
as bool?,skipCertVerify: freezed == skipCertVerify ? _self.skipCertVerify : skipCertVerify // ignore: cast_nullable_to_non_nullable
as bool?,ipVersion: freezed == ipVersion ? _self.ipVersion : ipVersion // ignore: cast_nullable_to_non_nullable
as IpVersion?,
  ));
}


}


/// @nodoc
mixin _$ProxyProviderOptions {

@JsonKey(name: 'health-check') ProviderHealthCheck get healthCheck; String? get filter;@JsonKey(name: 'exclude-filter') String? get excludeFilter;@JsonKey(name: 'override') ProviderOverride get proxyOverride;
/// Create a copy of ProxyProviderOptions
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProxyProviderOptionsCopyWith<ProxyProviderOptions> get copyWith => _$ProxyProviderOptionsCopyWithImpl<ProxyProviderOptions>(this as ProxyProviderOptions, _$identity);

  /// Serializes this ProxyProviderOptions to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ProxyProviderOptions;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProxyProviderOptions&&(identical(other.healthCheck, _this.healthCheck) || other.healthCheck == _this.healthCheck)&&(identical(other.filter, _this.filter) || other.filter == _this.filter)&&(identical(other.excludeFilter, _this.excludeFilter) || other.excludeFilter == _this.excludeFilter)&&(identical(other.proxyOverride, _this.proxyOverride) || other.proxyOverride == _this.proxyOverride));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ProxyProviderOptions;
  return Object.hash(runtimeType,_this.healthCheck,_this.filter,_this.excludeFilter,_this.proxyOverride);
}

@override
String toString() {
  final _this = this as ProxyProviderOptions;
  return 'ProxyProviderOptions(healthCheck: ${_this.healthCheck}, filter: ${_this.filter}, excludeFilter: ${_this.excludeFilter}, proxyOverride: ${_this.proxyOverride})';
}


}

/// @nodoc
abstract mixin class $ProxyProviderOptionsCopyWith<$Res>  {
  factory $ProxyProviderOptionsCopyWith(ProxyProviderOptions value, $Res Function(ProxyProviderOptions) _then) = _$ProxyProviderOptionsCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'health-check') ProviderHealthCheck healthCheck, String? filter,@JsonKey(name: 'exclude-filter') String? excludeFilter,@JsonKey(name: 'override') ProviderOverride proxyOverride
});


$ProviderHealthCheckCopyWith<$Res> get healthCheck;$ProviderOverrideCopyWith<$Res> get proxyOverride;

}
/// @nodoc
class _$ProxyProviderOptionsCopyWithImpl<$Res>
    implements $ProxyProviderOptionsCopyWith<$Res> {
  _$ProxyProviderOptionsCopyWithImpl(this._self, this._then);

  final ProxyProviderOptions _self;
  final $Res Function(ProxyProviderOptions) _then;

/// Create a copy of ProxyProviderOptions
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? healthCheck = null,Object? filter = freezed,Object? excludeFilter = freezed,Object? proxyOverride = null,}) {
  return _then(ProxyProviderOptions(
healthCheck: null == healthCheck ? _self.healthCheck : healthCheck // ignore: cast_nullable_to_non_nullable
as ProviderHealthCheck,filter: freezed == filter ? _self.filter : filter // ignore: cast_nullable_to_non_nullable
as String?,excludeFilter: freezed == excludeFilter ? _self.excludeFilter : excludeFilter // ignore: cast_nullable_to_non_nullable
as String?,proxyOverride: null == proxyOverride ? _self.proxyOverride : proxyOverride // ignore: cast_nullable_to_non_nullable
as ProviderOverride,
  ));
}
/// Create a copy of ProxyProviderOptions
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProviderHealthCheckCopyWith<$Res> get healthCheck {
  
  return $ProviderHealthCheckCopyWith<$Res>(_self.healthCheck, (value) {
    return _then(_self.copyWith(healthCheck: value));
  });
}/// Create a copy of ProxyProviderOptions
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProviderOverrideCopyWith<$Res> get proxyOverride {
  
  return $ProviderOverrideCopyWith<$Res>(_self.proxyOverride, (value) {
    return _then(_self.copyWith(proxyOverride: value));
  });
}
}


/// Adds pattern-matching-related methods to [ProxyProviderOptions].
extension ProxyProviderOptionsPatterns on ProxyProviderOptions {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProxyProviderOptions value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProxyProviderOptions() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProxyProviderOptions value)  $default,){
final _that = this;
switch (_that) {
case _ProxyProviderOptions():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProxyProviderOptions value)?  $default,){
final _that = this;
switch (_that) {
case _ProxyProviderOptions() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'health-check')  ProviderHealthCheck healthCheck,  String? filter, @JsonKey(name: 'exclude-filter')  String? excludeFilter, @JsonKey(name: 'override')  ProviderOverride proxyOverride)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProxyProviderOptions() when $default != null:
return $default(_that.healthCheck,_that.filter,_that.excludeFilter,_that.proxyOverride);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'health-check')  ProviderHealthCheck healthCheck,  String? filter, @JsonKey(name: 'exclude-filter')  String? excludeFilter, @JsonKey(name: 'override')  ProviderOverride proxyOverride)  $default,) {final _that = this;
switch (_that) {
case _ProxyProviderOptions():
return $default(_that.healthCheck,_that.filter,_that.excludeFilter,_that.proxyOverride);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'health-check')  ProviderHealthCheck healthCheck,  String? filter, @JsonKey(name: 'exclude-filter')  String? excludeFilter, @JsonKey(name: 'override')  ProviderOverride proxyOverride)?  $default,) {final _that = this;
switch (_that) {
case _ProxyProviderOptions() when $default != null:
return $default(_that.healthCheck,_that.filter,_that.excludeFilter,_that.proxyOverride);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProxyProviderOptions implements ProxyProviderOptions {
  const _ProxyProviderOptions({@JsonKey(name: 'health-check') this.healthCheck = const ProviderHealthCheck(), this.filter, @JsonKey(name: 'exclude-filter') this.excludeFilter, @JsonKey(name: 'override') this.proxyOverride = const ProviderOverride()});
  factory _ProxyProviderOptions.fromJson(Map<String, dynamic> json) => _$ProxyProviderOptionsFromJson(json);

@override@JsonKey(name: 'health-check') final  ProviderHealthCheck healthCheck;
@override final  String? filter;
@override@JsonKey(name: 'exclude-filter') final  String? excludeFilter;
@override@JsonKey(name: 'override') final  ProviderOverride proxyOverride;

/// Create a copy of ProxyProviderOptions
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProxyProviderOptionsCopyWith<_ProxyProviderOptions> get copyWith => __$ProxyProviderOptionsCopyWithImpl<_ProxyProviderOptions>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProxyProviderOptionsToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProxyProviderOptions&&(identical(other.healthCheck, healthCheck) || other.healthCheck == healthCheck)&&(identical(other.filter, filter) || other.filter == filter)&&(identical(other.excludeFilter, excludeFilter) || other.excludeFilter == excludeFilter)&&(identical(other.proxyOverride, proxyOverride) || other.proxyOverride == proxyOverride));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,healthCheck,filter,excludeFilter,proxyOverride);
}

@override
String toString() {
    return 'ProxyProviderOptions(healthCheck: $healthCheck, filter: $filter, excludeFilter: $excludeFilter, proxyOverride: $proxyOverride)';
}


}

/// @nodoc
abstract mixin class _$ProxyProviderOptionsCopyWith<$Res> implements $ProxyProviderOptionsCopyWith<$Res> {
  factory _$ProxyProviderOptionsCopyWith(_ProxyProviderOptions value, $Res Function(_ProxyProviderOptions) _then) = __$ProxyProviderOptionsCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'health-check') ProviderHealthCheck healthCheck, String? filter,@JsonKey(name: 'exclude-filter') String? excludeFilter,@JsonKey(name: 'override') ProviderOverride proxyOverride
});


@override $ProviderHealthCheckCopyWith<$Res> get healthCheck;@override $ProviderOverrideCopyWith<$Res> get proxyOverride;

}
/// @nodoc
class __$ProxyProviderOptionsCopyWithImpl<$Res>
    implements _$ProxyProviderOptionsCopyWith<$Res> {
  __$ProxyProviderOptionsCopyWithImpl(this._self, this._then);

  final _ProxyProviderOptions _self;
  final $Res Function(_ProxyProviderOptions) _then;

/// Create a copy of ProxyProviderOptions
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? healthCheck = null,Object? filter = freezed,Object? excludeFilter = freezed,Object? proxyOverride = null,}) {
  return _then(_ProxyProviderOptions(
healthCheck: null == healthCheck ? _self.healthCheck : healthCheck // ignore: cast_nullable_to_non_nullable
as ProviderHealthCheck,filter: freezed == filter ? _self.filter : filter // ignore: cast_nullable_to_non_nullable
as String?,excludeFilter: freezed == excludeFilter ? _self.excludeFilter : excludeFilter // ignore: cast_nullable_to_non_nullable
as String?,proxyOverride: null == proxyOverride ? _self.proxyOverride : proxyOverride // ignore: cast_nullable_to_non_nullable
as ProviderOverride,
  ));
}

/// Create a copy of ProxyProviderOptions
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProviderHealthCheckCopyWith<$Res> get healthCheck {
  
  return $ProviderHealthCheckCopyWith<$Res>(_self.healthCheck, (value) {
    return _then(_self.copyWith(healthCheck: value));
  });
}/// Create a copy of ProxyProviderOptions
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProviderOverrideCopyWith<$Res> get proxyOverride {
  
  return $ProviderOverrideCopyWith<$Res>(_self.proxyOverride, (value) {
    return _then(_self.copyWith(proxyOverride: value));
  });
}
}


/// @nodoc
mixin _$Rule {

 int get id;@JsonKey(includeFromJson: false, includeToJson: false) int? get profileId; RuleAction get ruleAction; String? get content; String? get ruleTarget; String? get ruleProvider; String? get subRule; bool get noResolve; bool get src; String? get order;
/// Create a copy of Rule
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RuleCopyWith<Rule> get copyWith => _$RuleCopyWithImpl<Rule>(this as Rule, _$identity);

  /// Serializes this Rule to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Rule;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Rule&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.profileId, _this.profileId) || other.profileId == _this.profileId)&&(identical(other.ruleAction, _this.ruleAction) || other.ruleAction == _this.ruleAction)&&(identical(other.content, _this.content) || other.content == _this.content)&&(identical(other.ruleTarget, _this.ruleTarget) || other.ruleTarget == _this.ruleTarget)&&(identical(other.ruleProvider, _this.ruleProvider) || other.ruleProvider == _this.ruleProvider)&&(identical(other.subRule, _this.subRule) || other.subRule == _this.subRule)&&(identical(other.noResolve, _this.noResolve) || other.noResolve == _this.noResolve)&&(identical(other.src, _this.src) || other.src == _this.src)&&(identical(other.order, _this.order) || other.order == _this.order));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Rule;
  return Object.hash(runtimeType,_this.id,_this.profileId,_this.ruleAction,_this.content,_this.ruleTarget,_this.ruleProvider,_this.subRule,_this.noResolve,_this.src,_this.order);
}

@override
String toString() {
  final _this = this as Rule;
  return 'Rule(id: ${_this.id}, profileId: ${_this.profileId}, ruleAction: ${_this.ruleAction}, content: ${_this.content}, ruleTarget: ${_this.ruleTarget}, ruleProvider: ${_this.ruleProvider}, subRule: ${_this.subRule}, noResolve: ${_this.noResolve}, src: ${_this.src}, order: ${_this.order})';
}


}

/// @nodoc
abstract mixin class $RuleCopyWith<$Res>  {
  factory $RuleCopyWith(Rule value, $Res Function(Rule) _then) = _$RuleCopyWithImpl;
@useResult
$Res call({
 int id,@JsonKey(includeFromJson: false, includeToJson: false) int? profileId, RuleAction ruleAction, String? content, String? ruleTarget, String? ruleProvider, String? subRule, bool noResolve, bool src, String? order
});




}
/// @nodoc
class _$RuleCopyWithImpl<$Res>
    implements $RuleCopyWith<$Res> {
  _$RuleCopyWithImpl(this._self, this._then);

  final Rule _self;
  final $Res Function(Rule) _then;

/// Create a copy of Rule
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? profileId = freezed,Object? ruleAction = null,Object? content = freezed,Object? ruleTarget = freezed,Object? ruleProvider = freezed,Object? subRule = freezed,Object? noResolve = null,Object? src = null,Object? order = freezed,}) {
  return _then(Rule(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,profileId: freezed == profileId ? _self.profileId : profileId // ignore: cast_nullable_to_non_nullable
as int?,ruleAction: null == ruleAction ? _self.ruleAction : ruleAction // ignore: cast_nullable_to_non_nullable
as RuleAction,content: freezed == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String?,ruleTarget: freezed == ruleTarget ? _self.ruleTarget : ruleTarget // ignore: cast_nullable_to_non_nullable
as String?,ruleProvider: freezed == ruleProvider ? _self.ruleProvider : ruleProvider // ignore: cast_nullable_to_non_nullable
as String?,subRule: freezed == subRule ? _self.subRule : subRule // ignore: cast_nullable_to_non_nullable
as String?,noResolve: null == noResolve ? _self.noResolve : noResolve // ignore: cast_nullable_to_non_nullable
as bool,src: null == src ? _self.src : src // ignore: cast_nullable_to_non_nullable
as bool,order: freezed == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Rule].
extension RulePatterns on Rule {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Rule value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Rule() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Rule value)  $default,){
final _that = this;
switch (_that) {
case _Rule():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Rule value)?  $default,){
final _that = this;
switch (_that) {
case _Rule() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id, @JsonKey(includeFromJson: false, includeToJson: false)  int? profileId,  RuleAction ruleAction,  String? content,  String? ruleTarget,  String? ruleProvider,  String? subRule,  bool noResolve,  bool src,  String? order)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Rule() when $default != null:
return $default(_that.id,_that.profileId,_that.ruleAction,_that.content,_that.ruleTarget,_that.ruleProvider,_that.subRule,_that.noResolve,_that.src,_that.order);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id, @JsonKey(includeFromJson: false, includeToJson: false)  int? profileId,  RuleAction ruleAction,  String? content,  String? ruleTarget,  String? ruleProvider,  String? subRule,  bool noResolve,  bool src,  String? order)  $default,) {final _that = this;
switch (_that) {
case _Rule():
return $default(_that.id,_that.profileId,_that.ruleAction,_that.content,_that.ruleTarget,_that.ruleProvider,_that.subRule,_that.noResolve,_that.src,_that.order);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id, @JsonKey(includeFromJson: false, includeToJson: false)  int? profileId,  RuleAction ruleAction,  String? content,  String? ruleTarget,  String? ruleProvider,  String? subRule,  bool noResolve,  bool src,  String? order)?  $default,) {final _that = this;
switch (_that) {
case _Rule() when $default != null:
return $default(_that.id,_that.profileId,_that.ruleAction,_that.content,_that.ruleTarget,_that.ruleProvider,_that.subRule,_that.noResolve,_that.src,_that.order);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Rule implements Rule {
  const _Rule({this.id = -1, @JsonKey(includeFromJson: false, includeToJson: false) this.profileId, this.ruleAction = RuleAction.DOMAIN, this.content, this.ruleTarget, this.ruleProvider, this.subRule, this.noResolve = false, this.src = false, this.order});
  factory _Rule.fromJson(Map<String, dynamic> json) => _$RuleFromJson(json);

@override@JsonKey() final  int id;
@override@JsonKey(includeFromJson: false, includeToJson: false) final  int? profileId;
@override@JsonKey() final  RuleAction ruleAction;
@override final  String? content;
@override final  String? ruleTarget;
@override final  String? ruleProvider;
@override final  String? subRule;
@override@JsonKey() final  bool noResolve;
@override@JsonKey() final  bool src;
@override final  String? order;

/// Create a copy of Rule
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RuleCopyWith<_Rule> get copyWith => __$RuleCopyWithImpl<_Rule>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RuleToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Rule&&(identical(other.id, id) || other.id == id)&&(identical(other.profileId, profileId) || other.profileId == profileId)&&(identical(other.ruleAction, ruleAction) || other.ruleAction == ruleAction)&&(identical(other.content, content) || other.content == content)&&(identical(other.ruleTarget, ruleTarget) || other.ruleTarget == ruleTarget)&&(identical(other.ruleProvider, ruleProvider) || other.ruleProvider == ruleProvider)&&(identical(other.subRule, subRule) || other.subRule == subRule)&&(identical(other.noResolve, noResolve) || other.noResolve == noResolve)&&(identical(other.src, src) || other.src == src)&&(identical(other.order, order) || other.order == order));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,profileId,ruleAction,content,ruleTarget,ruleProvider,subRule,noResolve,src,order);
}

@override
String toString() {
    return 'Rule(id: $id, profileId: $profileId, ruleAction: $ruleAction, content: $content, ruleTarget: $ruleTarget, ruleProvider: $ruleProvider, subRule: $subRule, noResolve: $noResolve, src: $src, order: $order)';
}


}

/// @nodoc
abstract mixin class _$RuleCopyWith<$Res> implements $RuleCopyWith<$Res> {
  factory _$RuleCopyWith(_Rule value, $Res Function(_Rule) _then) = __$RuleCopyWithImpl;
@override @useResult
$Res call({
 int id,@JsonKey(includeFromJson: false, includeToJson: false) int? profileId, RuleAction ruleAction, String? content, String? ruleTarget, String? ruleProvider, String? subRule, bool noResolve, bool src, String? order
});




}
/// @nodoc
class __$RuleCopyWithImpl<$Res>
    implements _$RuleCopyWith<$Res> {
  __$RuleCopyWithImpl(this._self, this._then);

  final _Rule _self;
  final $Res Function(_Rule) _then;

/// Create a copy of Rule
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? profileId = freezed,Object? ruleAction = null,Object? content = freezed,Object? ruleTarget = freezed,Object? ruleProvider = freezed,Object? subRule = freezed,Object? noResolve = null,Object? src = null,Object? order = freezed,}) {
  return _then(_Rule(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,profileId: freezed == profileId ? _self.profileId : profileId // ignore: cast_nullable_to_non_nullable
as int?,ruleAction: null == ruleAction ? _self.ruleAction : ruleAction // ignore: cast_nullable_to_non_nullable
as RuleAction,content: freezed == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String?,ruleTarget: freezed == ruleTarget ? _self.ruleTarget : ruleTarget // ignore: cast_nullable_to_non_nullable
as String?,ruleProvider: freezed == ruleProvider ? _self.ruleProvider : ruleProvider // ignore: cast_nullable_to_non_nullable
as String?,subRule: freezed == subRule ? _self.subRule : subRule // ignore: cast_nullable_to_non_nullable
as String?,noResolve: null == noResolve ? _self.noResolve : noResolve // ignore: cast_nullable_to_non_nullable
as bool,src: null == src ? _self.src : src // ignore: cast_nullable_to_non_nullable
as bool,order: freezed == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$ClashConfig {

@JsonKey(name: 'proxy-groups') List<ProxyGroup> get proxyGroups;@JsonKey(fromJson: _genRules) List<Rule> get rules; List<Proxy> get proxies;@JsonKey(name: 'proxy-providers', fromJson: _genList) List<String> get proxyProviders;@JsonKey(name: 'rule-providers', fromJson: _genList) List<String> get ruleProviders;@JsonKey(name: 'sub-rules', fromJson: _genList) List<String> get subRules; Map<String, String> get proxyTypeMap;
/// Create a copy of ClashConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClashConfigCopyWith<ClashConfig> get copyWith => _$ClashConfigCopyWithImpl<ClashConfig>(this as ClashConfig, _$identity);

  /// Serializes this ClashConfig to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ClashConfig;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClashConfig&&const DeepCollectionEquality().equals(other.proxyGroups, _this.proxyGroups)&&const DeepCollectionEquality().equals(other.rules, _this.rules)&&const DeepCollectionEquality().equals(other.proxies, _this.proxies)&&const DeepCollectionEquality().equals(other.proxyProviders, _this.proxyProviders)&&const DeepCollectionEquality().equals(other.ruleProviders, _this.ruleProviders)&&const DeepCollectionEquality().equals(other.subRules, _this.subRules)&&const DeepCollectionEquality().equals(other.proxyTypeMap, _this.proxyTypeMap));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ClashConfig;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.proxyGroups),const DeepCollectionEquality().hash(_this.rules),const DeepCollectionEquality().hash(_this.proxies),const DeepCollectionEquality().hash(_this.proxyProviders),const DeepCollectionEquality().hash(_this.ruleProviders),const DeepCollectionEquality().hash(_this.subRules),const DeepCollectionEquality().hash(_this.proxyTypeMap));
}

@override
String toString() {
  final _this = this as ClashConfig;
  return 'ClashConfig(proxyGroups: ${_this.proxyGroups}, rules: ${_this.rules}, proxies: ${_this.proxies}, proxyProviders: ${_this.proxyProviders}, ruleProviders: ${_this.ruleProviders}, subRules: ${_this.subRules}, proxyTypeMap: ${_this.proxyTypeMap})';
}


}

/// @nodoc
abstract mixin class $ClashConfigCopyWith<$Res>  {
  factory $ClashConfigCopyWith(ClashConfig value, $Res Function(ClashConfig) _then) = _$ClashConfigCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'proxy-groups') List<ProxyGroup> proxyGroups,@JsonKey(fromJson: _genRules) List<Rule> rules, List<Proxy> proxies,@JsonKey(name: 'proxy-providers', fromJson: _genList) List<String> proxyProviders,@JsonKey(name: 'rule-providers', fromJson: _genList) List<String> ruleProviders,@JsonKey(name: 'sub-rules', fromJson: _genList) List<String> subRules, Map<String, String> proxyTypeMap
});




}
/// @nodoc
class _$ClashConfigCopyWithImpl<$Res>
    implements $ClashConfigCopyWith<$Res> {
  _$ClashConfigCopyWithImpl(this._self, this._then);

  final ClashConfig _self;
  final $Res Function(ClashConfig) _then;

/// Create a copy of ClashConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? proxyGroups = null,Object? rules = null,Object? proxies = null,Object? proxyProviders = null,Object? ruleProviders = null,Object? subRules = null,Object? proxyTypeMap = null,}) {
  return _then(ClashConfig(
proxyGroups: null == proxyGroups ? _self.proxyGroups : proxyGroups // ignore: cast_nullable_to_non_nullable
as List<ProxyGroup>,rules: null == rules ? _self.rules : rules // ignore: cast_nullable_to_non_nullable
as List<Rule>,proxies: null == proxies ? _self.proxies : proxies // ignore: cast_nullable_to_non_nullable
as List<Proxy>,proxyProviders: null == proxyProviders ? _self.proxyProviders : proxyProviders // ignore: cast_nullable_to_non_nullable
as List<String>,ruleProviders: null == ruleProviders ? _self.ruleProviders : ruleProviders // ignore: cast_nullable_to_non_nullable
as List<String>,subRules: null == subRules ? _self.subRules : subRules // ignore: cast_nullable_to_non_nullable
as List<String>,proxyTypeMap: null == proxyTypeMap ? _self.proxyTypeMap : proxyTypeMap // ignore: cast_nullable_to_non_nullable
as Map<String, String>,
  ));
}

}


/// Adds pattern-matching-related methods to [ClashConfig].
extension ClashConfigPatterns on ClashConfig {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ClashConfig value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ClashConfig() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ClashConfig value)  $default,){
final _that = this;
switch (_that) {
case _ClashConfig():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ClashConfig value)?  $default,){
final _that = this;
switch (_that) {
case _ClashConfig() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'proxy-groups')  List<ProxyGroup> proxyGroups, @JsonKey(fromJson: _genRules)  List<Rule> rules,  List<Proxy> proxies, @JsonKey(name: 'proxy-providers', fromJson: _genList)  List<String> proxyProviders, @JsonKey(name: 'rule-providers', fromJson: _genList)  List<String> ruleProviders, @JsonKey(name: 'sub-rules', fromJson: _genList)  List<String> subRules,  Map<String, String> proxyTypeMap)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ClashConfig() when $default != null:
return $default(_that.proxyGroups,_that.rules,_that.proxies,_that.proxyProviders,_that.ruleProviders,_that.subRules,_that.proxyTypeMap);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'proxy-groups')  List<ProxyGroup> proxyGroups, @JsonKey(fromJson: _genRules)  List<Rule> rules,  List<Proxy> proxies, @JsonKey(name: 'proxy-providers', fromJson: _genList)  List<String> proxyProviders, @JsonKey(name: 'rule-providers', fromJson: _genList)  List<String> ruleProviders, @JsonKey(name: 'sub-rules', fromJson: _genList)  List<String> subRules,  Map<String, String> proxyTypeMap)  $default,) {final _that = this;
switch (_that) {
case _ClashConfig():
return $default(_that.proxyGroups,_that.rules,_that.proxies,_that.proxyProviders,_that.ruleProviders,_that.subRules,_that.proxyTypeMap);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'proxy-groups')  List<ProxyGroup> proxyGroups, @JsonKey(fromJson: _genRules)  List<Rule> rules,  List<Proxy> proxies, @JsonKey(name: 'proxy-providers', fromJson: _genList)  List<String> proxyProviders, @JsonKey(name: 'rule-providers', fromJson: _genList)  List<String> ruleProviders, @JsonKey(name: 'sub-rules', fromJson: _genList)  List<String> subRules,  Map<String, String> proxyTypeMap)?  $default,) {final _that = this;
switch (_that) {
case _ClashConfig() when $default != null:
return $default(_that.proxyGroups,_that.rules,_that.proxies,_that.proxyProviders,_that.ruleProviders,_that.subRules,_that.proxyTypeMap);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ClashConfig implements ClashConfig {
  const _ClashConfig({@JsonKey(name: 'proxy-groups')  List<ProxyGroup> proxyGroups = const [], @JsonKey(fromJson: _genRules)  List<Rule> rules = const [],  List<Proxy> proxies = const [], @JsonKey(name: 'proxy-providers', fromJson: _genList)  List<String> proxyProviders = const [], @JsonKey(name: 'rule-providers', fromJson: _genList)  List<String> ruleProviders = const [], @JsonKey(name: 'sub-rules', fromJson: _genList)  List<String> subRules = const [],  Map<String, String> proxyTypeMap = const {}}): _proxyGroups = proxyGroups,_rules = rules,_proxies = proxies,_proxyProviders = proxyProviders,_ruleProviders = ruleProviders,_subRules = subRules,_proxyTypeMap = proxyTypeMap;
  factory _ClashConfig.fromJson(Map<String, dynamic> json) => _$ClashConfigFromJson(json);

 final  List<ProxyGroup> _proxyGroups;
@override@JsonKey(name: 'proxy-groups') List<ProxyGroup> get proxyGroups {
  if (_proxyGroups is EqualUnmodifiableListView) return _proxyGroups;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_proxyGroups);
}

 final  List<Rule> _rules;
@override@JsonKey(fromJson: _genRules) List<Rule> get rules {
  if (_rules is EqualUnmodifiableListView) return _rules;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_rules);
}

 final  List<Proxy> _proxies;
@override@JsonKey() List<Proxy> get proxies {
  if (_proxies is EqualUnmodifiableListView) return _proxies;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_proxies);
}

 final  List<String> _proxyProviders;
@override@JsonKey(name: 'proxy-providers', fromJson: _genList) List<String> get proxyProviders {
  if (_proxyProviders is EqualUnmodifiableListView) return _proxyProviders;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_proxyProviders);
}

 final  List<String> _ruleProviders;
@override@JsonKey(name: 'rule-providers', fromJson: _genList) List<String> get ruleProviders {
  if (_ruleProviders is EqualUnmodifiableListView) return _ruleProviders;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_ruleProviders);
}

 final  List<String> _subRules;
@override@JsonKey(name: 'sub-rules', fromJson: _genList) List<String> get subRules {
  if (_subRules is EqualUnmodifiableListView) return _subRules;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_subRules);
}

 final  Map<String, String> _proxyTypeMap;
@override@JsonKey() Map<String, String> get proxyTypeMap {
  if (_proxyTypeMap is EqualUnmodifiableMapView) return _proxyTypeMap;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_proxyTypeMap);
}


/// Create a copy of ClashConfig
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ClashConfigCopyWith<_ClashConfig> get copyWith => __$ClashConfigCopyWithImpl<_ClashConfig>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ClashConfigToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ClashConfig&&const DeepCollectionEquality().equals(other.proxyGroups, _proxyGroups)&&const DeepCollectionEquality().equals(other.rules, _rules)&&const DeepCollectionEquality().equals(other.proxies, _proxies)&&const DeepCollectionEquality().equals(other.proxyProviders, _proxyProviders)&&const DeepCollectionEquality().equals(other.ruleProviders, _ruleProviders)&&const DeepCollectionEquality().equals(other.subRules, _subRules)&&const DeepCollectionEquality().equals(other.proxyTypeMap, _proxyTypeMap));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_proxyGroups),const DeepCollectionEquality().hash(_rules),const DeepCollectionEquality().hash(_proxies),const DeepCollectionEquality().hash(_proxyProviders),const DeepCollectionEquality().hash(_ruleProviders),const DeepCollectionEquality().hash(_subRules),const DeepCollectionEquality().hash(_proxyTypeMap));
}

@override
String toString() {
    return 'ClashConfig(proxyGroups: $proxyGroups, rules: $rules, proxies: $proxies, proxyProviders: $proxyProviders, ruleProviders: $ruleProviders, subRules: $subRules, proxyTypeMap: $proxyTypeMap)';
}


}

/// @nodoc
abstract mixin class _$ClashConfigCopyWith<$Res> implements $ClashConfigCopyWith<$Res> {
  factory _$ClashConfigCopyWith(_ClashConfig value, $Res Function(_ClashConfig) _then) = __$ClashConfigCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'proxy-groups') List<ProxyGroup> proxyGroups,@JsonKey(fromJson: _genRules) List<Rule> rules, List<Proxy> proxies,@JsonKey(name: 'proxy-providers', fromJson: _genList) List<String> proxyProviders,@JsonKey(name: 'rule-providers', fromJson: _genList) List<String> ruleProviders,@JsonKey(name: 'sub-rules', fromJson: _genList) List<String> subRules, Map<String, String> proxyTypeMap
});




}
/// @nodoc
class __$ClashConfigCopyWithImpl<$Res>
    implements _$ClashConfigCopyWith<$Res> {
  __$ClashConfigCopyWithImpl(this._self, this._then);

  final _ClashConfig _self;
  final $Res Function(_ClashConfig) _then;

/// Create a copy of ClashConfig
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? proxyGroups = null,Object? rules = null,Object? proxies = null,Object? proxyProviders = null,Object? ruleProviders = null,Object? subRules = null,Object? proxyTypeMap = null,}) {
  return _then(_ClashConfig(
proxyGroups: null == proxyGroups ? _self._proxyGroups : proxyGroups // ignore: cast_nullable_to_non_nullable
as List<ProxyGroup>,rules: null == rules ? _self._rules : rules // ignore: cast_nullable_to_non_nullable
as List<Rule>,proxies: null == proxies ? _self._proxies : proxies // ignore: cast_nullable_to_non_nullable
as List<Proxy>,proxyProviders: null == proxyProviders ? _self._proxyProviders : proxyProviders // ignore: cast_nullable_to_non_nullable
as List<String>,ruleProviders: null == ruleProviders ? _self._ruleProviders : ruleProviders // ignore: cast_nullable_to_non_nullable
as List<String>,subRules: null == subRules ? _self._subRules : subRules // ignore: cast_nullable_to_non_nullable
as List<String>,proxyTypeMap: null == proxyTypeMap ? _self._proxyTypeMap : proxyTypeMap // ignore: cast_nullable_to_non_nullable
as Map<String, String>,
  ));
}


}


/// @nodoc
mixin _$PatchClashConfig {

@JsonKey(name: 'mixed-port') int get mixedPort;@JsonKey(name: 'socks-port') int get socksPort;@JsonKey(name: 'port') int get port;@JsonKey(name: 'redir-port') int get redirPort;@JsonKey(name: 'tproxy-port') int get tproxyPort; Mode get mode;@JsonKey(name: 'allow-lan') bool get allowLan;@JsonKey(name: 'log-level') LogLevel get logLevel; bool get ipv6;@JsonKey(name: 'find-process-mode', unknownEnumValue: FindProcessMode.off) FindProcessMode get findProcessMode;@JsonKey(name: 'interface-name-mode', unknownEnumValue: InterfaceNameMode.clear) InterfaceNameMode get interfaceNameMode;@JsonKey(name: 'interface-name') String get interfaceName;@JsonKey(name: 'keep-alive-interval') int get keepAliveInterval;@JsonKey(name: 'keep-alive-idle') int get keepAliveIdle;@JsonKey(name: 'disable-keep-alive') bool get disableKeepAlive;@JsonKey(name: 'routing-mark') int get routingMark;@JsonKey(name: 'unified-delay') bool get unifiedDelay;@JsonKey(name: 'tcp-concurrent') bool get tcpConcurrent;@JsonKey(fromJson: Tun.safeFormJson) Tun get tun;@JsonKey(fromJson: Dns.safeDnsFromJson) Dns get dns;@JsonKey(name: _dnsOverrideKeysJsonKey, fromJson: _dnsOverrideKeysFromJson) Set<DnsOverrideKey> get dnsOverrideKeys;@JsonKey(name: 'geox-url', fromJson: _geoXUrlFromJson, toJson: _geoXUrlToJson) Map<GeoResource, String> get geoXUrl;@JsonKey(name: 'geodata-loader') GeodataLoader get geodataLoader;@JsonKey(name: 'global-ua') String? get globalUa;@JsonKey(name: 'external-controller') ExternalControllerStatus get externalController; String get secret; Map<String, String> get hosts;@JsonKey(name: 'geo-auto-update') bool get geoAutoUpdate;@JsonKey(name: 'geo-update-interval') int get geoUpdateInterval;
/// Create a copy of PatchClashConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PatchClashConfigCopyWith<PatchClashConfig> get copyWith => _$PatchClashConfigCopyWithImpl<PatchClashConfig>(this as PatchClashConfig, _$identity);

  /// Serializes this PatchClashConfig to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as PatchClashConfig;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PatchClashConfig&&(identical(other.mixedPort, _this.mixedPort) || other.mixedPort == _this.mixedPort)&&(identical(other.socksPort, _this.socksPort) || other.socksPort == _this.socksPort)&&(identical(other.port, _this.port) || other.port == _this.port)&&(identical(other.redirPort, _this.redirPort) || other.redirPort == _this.redirPort)&&(identical(other.tproxyPort, _this.tproxyPort) || other.tproxyPort == _this.tproxyPort)&&(identical(other.mode, _this.mode) || other.mode == _this.mode)&&(identical(other.allowLan, _this.allowLan) || other.allowLan == _this.allowLan)&&(identical(other.logLevel, _this.logLevel) || other.logLevel == _this.logLevel)&&(identical(other.ipv6, _this.ipv6) || other.ipv6 == _this.ipv6)&&(identical(other.findProcessMode, _this.findProcessMode) || other.findProcessMode == _this.findProcessMode)&&(identical(other.interfaceNameMode, _this.interfaceNameMode) || other.interfaceNameMode == _this.interfaceNameMode)&&(identical(other.interfaceName, _this.interfaceName) || other.interfaceName == _this.interfaceName)&&(identical(other.keepAliveInterval, _this.keepAliveInterval) || other.keepAliveInterval == _this.keepAliveInterval)&&(identical(other.keepAliveIdle, _this.keepAliveIdle) || other.keepAliveIdle == _this.keepAliveIdle)&&(identical(other.disableKeepAlive, _this.disableKeepAlive) || other.disableKeepAlive == _this.disableKeepAlive)&&(identical(other.routingMark, _this.routingMark) || other.routingMark == _this.routingMark)&&(identical(other.unifiedDelay, _this.unifiedDelay) || other.unifiedDelay == _this.unifiedDelay)&&(identical(other.tcpConcurrent, _this.tcpConcurrent) || other.tcpConcurrent == _this.tcpConcurrent)&&(identical(other.tun, _this.tun) || other.tun == _this.tun)&&(identical(other.dns, _this.dns) || other.dns == _this.dns)&&const DeepCollectionEquality().equals(other.dnsOverrideKeys, _this.dnsOverrideKeys)&&const DeepCollectionEquality().equals(other.geoXUrl, _this.geoXUrl)&&(identical(other.geodataLoader, _this.geodataLoader) || other.geodataLoader == _this.geodataLoader)&&(identical(other.globalUa, _this.globalUa) || other.globalUa == _this.globalUa)&&(identical(other.externalController, _this.externalController) || other.externalController == _this.externalController)&&(identical(other.secret, _this.secret) || other.secret == _this.secret)&&const DeepCollectionEquality().equals(other.hosts, _this.hosts)&&(identical(other.geoAutoUpdate, _this.geoAutoUpdate) || other.geoAutoUpdate == _this.geoAutoUpdate)&&(identical(other.geoUpdateInterval, _this.geoUpdateInterval) || other.geoUpdateInterval == _this.geoUpdateInterval));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as PatchClashConfig;
  return Object.hashAll([runtimeType,_this.mixedPort,_this.socksPort,_this.port,_this.redirPort,_this.tproxyPort,_this.mode,_this.allowLan,_this.logLevel,_this.ipv6,_this.findProcessMode,_this.interfaceNameMode,_this.interfaceName,_this.keepAliveInterval,_this.keepAliveIdle,_this.disableKeepAlive,_this.routingMark,_this.unifiedDelay,_this.tcpConcurrent,_this.tun,_this.dns,const DeepCollectionEquality().hash(_this.dnsOverrideKeys),const DeepCollectionEquality().hash(_this.geoXUrl),_this.geodataLoader,_this.globalUa,_this.externalController,_this.secret,const DeepCollectionEquality().hash(_this.hosts),_this.geoAutoUpdate,_this.geoUpdateInterval]);
}

@override
String toString() {
  final _this = this as PatchClashConfig;
  return 'PatchClashConfig(mixedPort: ${_this.mixedPort}, socksPort: ${_this.socksPort}, port: ${_this.port}, redirPort: ${_this.redirPort}, tproxyPort: ${_this.tproxyPort}, mode: ${_this.mode}, allowLan: ${_this.allowLan}, logLevel: ${_this.logLevel}, ipv6: ${_this.ipv6}, findProcessMode: ${_this.findProcessMode}, interfaceNameMode: ${_this.interfaceNameMode}, interfaceName: ${_this.interfaceName}, keepAliveInterval: ${_this.keepAliveInterval}, keepAliveIdle: ${_this.keepAliveIdle}, disableKeepAlive: ${_this.disableKeepAlive}, routingMark: ${_this.routingMark}, unifiedDelay: ${_this.unifiedDelay}, tcpConcurrent: ${_this.tcpConcurrent}, tun: ${_this.tun}, dns: ${_this.dns}, dnsOverrideKeys: ${_this.dnsOverrideKeys}, geoXUrl: ${_this.geoXUrl}, geodataLoader: ${_this.geodataLoader}, globalUa: ${_this.globalUa}, externalController: ${_this.externalController}, secret: ${_this.secret}, hosts: ${_this.hosts}, geoAutoUpdate: ${_this.geoAutoUpdate}, geoUpdateInterval: ${_this.geoUpdateInterval})';
}


}

/// @nodoc
abstract mixin class $PatchClashConfigCopyWith<$Res>  {
  factory $PatchClashConfigCopyWith(PatchClashConfig value, $Res Function(PatchClashConfig) _then) = _$PatchClashConfigCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'mixed-port') int mixedPort,@JsonKey(name: 'socks-port') int socksPort,@JsonKey(name: 'port') int port,@JsonKey(name: 'redir-port') int redirPort,@JsonKey(name: 'tproxy-port') int tproxyPort, Mode mode,@JsonKey(name: 'allow-lan') bool allowLan,@JsonKey(name: 'log-level') LogLevel logLevel, bool ipv6,@JsonKey(name: 'find-process-mode', unknownEnumValue: FindProcessMode.off) FindProcessMode findProcessMode,@JsonKey(name: 'interface-name-mode', unknownEnumValue: InterfaceNameMode.clear) InterfaceNameMode interfaceNameMode,@JsonKey(name: 'interface-name') String interfaceName,@JsonKey(name: 'keep-alive-interval') int keepAliveInterval,@JsonKey(name: 'keep-alive-idle') int keepAliveIdle,@JsonKey(name: 'disable-keep-alive') bool disableKeepAlive,@JsonKey(name: 'routing-mark') int routingMark,@JsonKey(name: 'unified-delay') bool unifiedDelay,@JsonKey(name: 'tcp-concurrent') bool tcpConcurrent,@JsonKey(fromJson: Tun.safeFormJson) Tun tun,@JsonKey(fromJson: Dns.safeDnsFromJson) Dns dns,@JsonKey(name: _dnsOverrideKeysJsonKey, fromJson: _dnsOverrideKeysFromJson) Set<DnsOverrideKey> dnsOverrideKeys,@JsonKey(name: 'geox-url', fromJson: _geoXUrlFromJson, toJson: _geoXUrlToJson) Map<GeoResource, String> geoXUrl,@JsonKey(name: 'geodata-loader') GeodataLoader geodataLoader,@JsonKey(name: 'global-ua') String? globalUa,@JsonKey(name: 'external-controller') ExternalControllerStatus externalController, String secret, Map<String, String> hosts,@JsonKey(name: 'geo-auto-update') bool geoAutoUpdate,@JsonKey(name: 'geo-update-interval') int geoUpdateInterval
});


$TunCopyWith<$Res> get tun;$DnsCopyWith<$Res> get dns;

}
/// @nodoc
class _$PatchClashConfigCopyWithImpl<$Res>
    implements $PatchClashConfigCopyWith<$Res> {
  _$PatchClashConfigCopyWithImpl(this._self, this._then);

  final PatchClashConfig _self;
  final $Res Function(PatchClashConfig) _then;

/// Create a copy of PatchClashConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? mixedPort = null,Object? socksPort = null,Object? port = null,Object? redirPort = null,Object? tproxyPort = null,Object? mode = null,Object? allowLan = null,Object? logLevel = null,Object? ipv6 = null,Object? findProcessMode = null,Object? interfaceNameMode = null,Object? interfaceName = null,Object? keepAliveInterval = null,Object? keepAliveIdle = null,Object? disableKeepAlive = null,Object? routingMark = null,Object? unifiedDelay = null,Object? tcpConcurrent = null,Object? tun = null,Object? dns = null,Object? dnsOverrideKeys = null,Object? geoXUrl = null,Object? geodataLoader = null,Object? globalUa = freezed,Object? externalController = null,Object? secret = null,Object? hosts = null,Object? geoAutoUpdate = null,Object? geoUpdateInterval = null,}) {
  return _then(PatchClashConfig(
mixedPort: null == mixedPort ? _self.mixedPort : mixedPort // ignore: cast_nullable_to_non_nullable
as int,socksPort: null == socksPort ? _self.socksPort : socksPort // ignore: cast_nullable_to_non_nullable
as int,port: null == port ? _self.port : port // ignore: cast_nullable_to_non_nullable
as int,redirPort: null == redirPort ? _self.redirPort : redirPort // ignore: cast_nullable_to_non_nullable
as int,tproxyPort: null == tproxyPort ? _self.tproxyPort : tproxyPort // ignore: cast_nullable_to_non_nullable
as int,mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as Mode,allowLan: null == allowLan ? _self.allowLan : allowLan // ignore: cast_nullable_to_non_nullable
as bool,logLevel: null == logLevel ? _self.logLevel : logLevel // ignore: cast_nullable_to_non_nullable
as LogLevel,ipv6: null == ipv6 ? _self.ipv6 : ipv6 // ignore: cast_nullable_to_non_nullable
as bool,findProcessMode: null == findProcessMode ? _self.findProcessMode : findProcessMode // ignore: cast_nullable_to_non_nullable
as FindProcessMode,interfaceNameMode: null == interfaceNameMode ? _self.interfaceNameMode : interfaceNameMode // ignore: cast_nullable_to_non_nullable
as InterfaceNameMode,interfaceName: null == interfaceName ? _self.interfaceName : interfaceName // ignore: cast_nullable_to_non_nullable
as String,keepAliveInterval: null == keepAliveInterval ? _self.keepAliveInterval : keepAliveInterval // ignore: cast_nullable_to_non_nullable
as int,keepAliveIdle: null == keepAliveIdle ? _self.keepAliveIdle : keepAliveIdle // ignore: cast_nullable_to_non_nullable
as int,disableKeepAlive: null == disableKeepAlive ? _self.disableKeepAlive : disableKeepAlive // ignore: cast_nullable_to_non_nullable
as bool,routingMark: null == routingMark ? _self.routingMark : routingMark // ignore: cast_nullable_to_non_nullable
as int,unifiedDelay: null == unifiedDelay ? _self.unifiedDelay : unifiedDelay // ignore: cast_nullable_to_non_nullable
as bool,tcpConcurrent: null == tcpConcurrent ? _self.tcpConcurrent : tcpConcurrent // ignore: cast_nullable_to_non_nullable
as bool,tun: null == tun ? _self.tun : tun // ignore: cast_nullable_to_non_nullable
as Tun,dns: null == dns ? _self.dns : dns // ignore: cast_nullable_to_non_nullable
as Dns,dnsOverrideKeys: null == dnsOverrideKeys ? _self.dnsOverrideKeys : dnsOverrideKeys // ignore: cast_nullable_to_non_nullable
as Set<DnsOverrideKey>,geoXUrl: null == geoXUrl ? _self.geoXUrl : geoXUrl // ignore: cast_nullable_to_non_nullable
as Map<GeoResource, String>,geodataLoader: null == geodataLoader ? _self.geodataLoader : geodataLoader // ignore: cast_nullable_to_non_nullable
as GeodataLoader,globalUa: freezed == globalUa ? _self.globalUa : globalUa // ignore: cast_nullable_to_non_nullable
as String?,externalController: null == externalController ? _self.externalController : externalController // ignore: cast_nullable_to_non_nullable
as ExternalControllerStatus,secret: null == secret ? _self.secret : secret // ignore: cast_nullable_to_non_nullable
as String,hosts: null == hosts ? _self.hosts : hosts // ignore: cast_nullable_to_non_nullable
as Map<String, String>,geoAutoUpdate: null == geoAutoUpdate ? _self.geoAutoUpdate : geoAutoUpdate // ignore: cast_nullable_to_non_nullable
as bool,geoUpdateInterval: null == geoUpdateInterval ? _self.geoUpdateInterval : geoUpdateInterval // ignore: cast_nullable_to_non_nullable
as int,
  ));
}
/// Create a copy of PatchClashConfig
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TunCopyWith<$Res> get tun {
  
  return $TunCopyWith<$Res>(_self.tun, (value) {
    return _then(_self.copyWith(tun: value));
  });
}/// Create a copy of PatchClashConfig
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DnsCopyWith<$Res> get dns {
  
  return $DnsCopyWith<$Res>(_self.dns, (value) {
    return _then(_self.copyWith(dns: value));
  });
}
}


/// Adds pattern-matching-related methods to [PatchClashConfig].
extension PatchClashConfigPatterns on PatchClashConfig {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PatchClashConfig value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PatchClashConfig() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PatchClashConfig value)  $default,){
final _that = this;
switch (_that) {
case _PatchClashConfig():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PatchClashConfig value)?  $default,){
final _that = this;
switch (_that) {
case _PatchClashConfig() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'mixed-port')  int mixedPort, @JsonKey(name: 'socks-port')  int socksPort, @JsonKey(name: 'port')  int port, @JsonKey(name: 'redir-port')  int redirPort, @JsonKey(name: 'tproxy-port')  int tproxyPort,  Mode mode, @JsonKey(name: 'allow-lan')  bool allowLan, @JsonKey(name: 'log-level')  LogLevel logLevel,  bool ipv6, @JsonKey(name: 'find-process-mode', unknownEnumValue: FindProcessMode.off)  FindProcessMode findProcessMode, @JsonKey(name: 'interface-name-mode', unknownEnumValue: InterfaceNameMode.clear)  InterfaceNameMode interfaceNameMode, @JsonKey(name: 'interface-name')  String interfaceName, @JsonKey(name: 'keep-alive-interval')  int keepAliveInterval, @JsonKey(name: 'keep-alive-idle')  int keepAliveIdle, @JsonKey(name: 'disable-keep-alive')  bool disableKeepAlive, @JsonKey(name: 'routing-mark')  int routingMark, @JsonKey(name: 'unified-delay')  bool unifiedDelay, @JsonKey(name: 'tcp-concurrent')  bool tcpConcurrent, @JsonKey(fromJson: Tun.safeFormJson)  Tun tun, @JsonKey(fromJson: Dns.safeDnsFromJson)  Dns dns, @JsonKey(name: _dnsOverrideKeysJsonKey, fromJson: _dnsOverrideKeysFromJson)  Set<DnsOverrideKey> dnsOverrideKeys, @JsonKey(name: 'geox-url', fromJson: _geoXUrlFromJson, toJson: _geoXUrlToJson)  Map<GeoResource, String> geoXUrl, @JsonKey(name: 'geodata-loader')  GeodataLoader geodataLoader, @JsonKey(name: 'global-ua')  String? globalUa, @JsonKey(name: 'external-controller')  ExternalControllerStatus externalController,  String secret,  Map<String, String> hosts, @JsonKey(name: 'geo-auto-update')  bool geoAutoUpdate, @JsonKey(name: 'geo-update-interval')  int geoUpdateInterval)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PatchClashConfig() when $default != null:
return $default(_that.mixedPort,_that.socksPort,_that.port,_that.redirPort,_that.tproxyPort,_that.mode,_that.allowLan,_that.logLevel,_that.ipv6,_that.findProcessMode,_that.interfaceNameMode,_that.interfaceName,_that.keepAliveInterval,_that.keepAliveIdle,_that.disableKeepAlive,_that.routingMark,_that.unifiedDelay,_that.tcpConcurrent,_that.tun,_that.dns,_that.dnsOverrideKeys,_that.geoXUrl,_that.geodataLoader,_that.globalUa,_that.externalController,_that.secret,_that.hosts,_that.geoAutoUpdate,_that.geoUpdateInterval);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'mixed-port')  int mixedPort, @JsonKey(name: 'socks-port')  int socksPort, @JsonKey(name: 'port')  int port, @JsonKey(name: 'redir-port')  int redirPort, @JsonKey(name: 'tproxy-port')  int tproxyPort,  Mode mode, @JsonKey(name: 'allow-lan')  bool allowLan, @JsonKey(name: 'log-level')  LogLevel logLevel,  bool ipv6, @JsonKey(name: 'find-process-mode', unknownEnumValue: FindProcessMode.off)  FindProcessMode findProcessMode, @JsonKey(name: 'interface-name-mode', unknownEnumValue: InterfaceNameMode.clear)  InterfaceNameMode interfaceNameMode, @JsonKey(name: 'interface-name')  String interfaceName, @JsonKey(name: 'keep-alive-interval')  int keepAliveInterval, @JsonKey(name: 'keep-alive-idle')  int keepAliveIdle, @JsonKey(name: 'disable-keep-alive')  bool disableKeepAlive, @JsonKey(name: 'routing-mark')  int routingMark, @JsonKey(name: 'unified-delay')  bool unifiedDelay, @JsonKey(name: 'tcp-concurrent')  bool tcpConcurrent, @JsonKey(fromJson: Tun.safeFormJson)  Tun tun, @JsonKey(fromJson: Dns.safeDnsFromJson)  Dns dns, @JsonKey(name: _dnsOverrideKeysJsonKey, fromJson: _dnsOverrideKeysFromJson)  Set<DnsOverrideKey> dnsOverrideKeys, @JsonKey(name: 'geox-url', fromJson: _geoXUrlFromJson, toJson: _geoXUrlToJson)  Map<GeoResource, String> geoXUrl, @JsonKey(name: 'geodata-loader')  GeodataLoader geodataLoader, @JsonKey(name: 'global-ua')  String? globalUa, @JsonKey(name: 'external-controller')  ExternalControllerStatus externalController,  String secret,  Map<String, String> hosts, @JsonKey(name: 'geo-auto-update')  bool geoAutoUpdate, @JsonKey(name: 'geo-update-interval')  int geoUpdateInterval)  $default,) {final _that = this;
switch (_that) {
case _PatchClashConfig():
return $default(_that.mixedPort,_that.socksPort,_that.port,_that.redirPort,_that.tproxyPort,_that.mode,_that.allowLan,_that.logLevel,_that.ipv6,_that.findProcessMode,_that.interfaceNameMode,_that.interfaceName,_that.keepAliveInterval,_that.keepAliveIdle,_that.disableKeepAlive,_that.routingMark,_that.unifiedDelay,_that.tcpConcurrent,_that.tun,_that.dns,_that.dnsOverrideKeys,_that.geoXUrl,_that.geodataLoader,_that.globalUa,_that.externalController,_that.secret,_that.hosts,_that.geoAutoUpdate,_that.geoUpdateInterval);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'mixed-port')  int mixedPort, @JsonKey(name: 'socks-port')  int socksPort, @JsonKey(name: 'port')  int port, @JsonKey(name: 'redir-port')  int redirPort, @JsonKey(name: 'tproxy-port')  int tproxyPort,  Mode mode, @JsonKey(name: 'allow-lan')  bool allowLan, @JsonKey(name: 'log-level')  LogLevel logLevel,  bool ipv6, @JsonKey(name: 'find-process-mode', unknownEnumValue: FindProcessMode.off)  FindProcessMode findProcessMode, @JsonKey(name: 'interface-name-mode', unknownEnumValue: InterfaceNameMode.clear)  InterfaceNameMode interfaceNameMode, @JsonKey(name: 'interface-name')  String interfaceName, @JsonKey(name: 'keep-alive-interval')  int keepAliveInterval, @JsonKey(name: 'keep-alive-idle')  int keepAliveIdle, @JsonKey(name: 'disable-keep-alive')  bool disableKeepAlive, @JsonKey(name: 'routing-mark')  int routingMark, @JsonKey(name: 'unified-delay')  bool unifiedDelay, @JsonKey(name: 'tcp-concurrent')  bool tcpConcurrent, @JsonKey(fromJson: Tun.safeFormJson)  Tun tun, @JsonKey(fromJson: Dns.safeDnsFromJson)  Dns dns, @JsonKey(name: _dnsOverrideKeysJsonKey, fromJson: _dnsOverrideKeysFromJson)  Set<DnsOverrideKey> dnsOverrideKeys, @JsonKey(name: 'geox-url', fromJson: _geoXUrlFromJson, toJson: _geoXUrlToJson)  Map<GeoResource, String> geoXUrl, @JsonKey(name: 'geodata-loader')  GeodataLoader geodataLoader, @JsonKey(name: 'global-ua')  String? globalUa, @JsonKey(name: 'external-controller')  ExternalControllerStatus externalController,  String secret,  Map<String, String> hosts, @JsonKey(name: 'geo-auto-update')  bool geoAutoUpdate, @JsonKey(name: 'geo-update-interval')  int geoUpdateInterval)?  $default,) {final _that = this;
switch (_that) {
case _PatchClashConfig() when $default != null:
return $default(_that.mixedPort,_that.socksPort,_that.port,_that.redirPort,_that.tproxyPort,_that.mode,_that.allowLan,_that.logLevel,_that.ipv6,_that.findProcessMode,_that.interfaceNameMode,_that.interfaceName,_that.keepAliveInterval,_that.keepAliveIdle,_that.disableKeepAlive,_that.routingMark,_that.unifiedDelay,_that.tcpConcurrent,_that.tun,_that.dns,_that.dnsOverrideKeys,_that.geoXUrl,_that.geodataLoader,_that.globalUa,_that.externalController,_that.secret,_that.hosts,_that.geoAutoUpdate,_that.geoUpdateInterval);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PatchClashConfig implements PatchClashConfig {
  const _PatchClashConfig({@JsonKey(name: 'mixed-port') this.mixedPort = defaultMixedPort, @JsonKey(name: 'socks-port') this.socksPort = 0, @JsonKey(name: 'port') this.port = 0, @JsonKey(name: 'redir-port') this.redirPort = 0, @JsonKey(name: 'tproxy-port') this.tproxyPort = 0, this.mode = Mode.rule, @JsonKey(name: 'allow-lan') this.allowLan = false, @JsonKey(name: 'log-level') this.logLevel = LogLevel.error, this.ipv6 = false, @JsonKey(name: 'find-process-mode', unknownEnumValue: FindProcessMode.off) this.findProcessMode = FindProcessMode.off, @JsonKey(name: 'interface-name-mode', unknownEnumValue: InterfaceNameMode.clear) this.interfaceNameMode = InterfaceNameMode.clear, @JsonKey(name: 'interface-name') this.interfaceName = '', @JsonKey(name: 'keep-alive-interval') this.keepAliveInterval = defaultKeepAliveInterval, @JsonKey(name: 'keep-alive-idle') this.keepAliveIdle = 15, @JsonKey(name: 'disable-keep-alive') this.disableKeepAlive = false, @JsonKey(name: 'routing-mark') this.routingMark = 0, @JsonKey(name: 'unified-delay') this.unifiedDelay = true, @JsonKey(name: 'tcp-concurrent') this.tcpConcurrent = true, @JsonKey(fromJson: Tun.safeFormJson) this.tun = defaultTun, @JsonKey(fromJson: Dns.safeDnsFromJson) this.dns = defaultDns, @JsonKey(name: _dnsOverrideKeysJsonKey, fromJson: _dnsOverrideKeysFromJson)  Set<DnsOverrideKey> dnsOverrideKeys = const {}, @JsonKey(name: 'geox-url', fromJson: _geoXUrlFromJson, toJson: _geoXUrlToJson)  Map<GeoResource, String> geoXUrl = defaultGeoXUrl, @JsonKey(name: 'geodata-loader') this.geodataLoader = GeodataLoader.memconservative, @JsonKey(name: 'global-ua') this.globalUa, @JsonKey(name: 'external-controller') this.externalController = ExternalControllerStatus.close, this.secret = '',  Map<String, String> hosts = const {}, @JsonKey(name: 'geo-auto-update') this.geoAutoUpdate = false, @JsonKey(name: 'geo-update-interval') this.geoUpdateInterval = 24}): _dnsOverrideKeys = dnsOverrideKeys,_geoXUrl = geoXUrl,_hosts = hosts;
  factory _PatchClashConfig.fromJson(Map<String, dynamic> json) => _$PatchClashConfigFromJson(json);

@override@JsonKey(name: 'mixed-port') final  int mixedPort;
@override@JsonKey(name: 'socks-port') final  int socksPort;
@override@JsonKey(name: 'port') final  int port;
@override@JsonKey(name: 'redir-port') final  int redirPort;
@override@JsonKey(name: 'tproxy-port') final  int tproxyPort;
@override@JsonKey() final  Mode mode;
@override@JsonKey(name: 'allow-lan') final  bool allowLan;
@override@JsonKey(name: 'log-level') final  LogLevel logLevel;
@override@JsonKey() final  bool ipv6;
@override@JsonKey(name: 'find-process-mode', unknownEnumValue: FindProcessMode.off) final  FindProcessMode findProcessMode;
@override@JsonKey(name: 'interface-name-mode', unknownEnumValue: InterfaceNameMode.clear) final  InterfaceNameMode interfaceNameMode;
@override@JsonKey(name: 'interface-name') final  String interfaceName;
@override@JsonKey(name: 'keep-alive-interval') final  int keepAliveInterval;
@override@JsonKey(name: 'keep-alive-idle') final  int keepAliveIdle;
@override@JsonKey(name: 'disable-keep-alive') final  bool disableKeepAlive;
@override@JsonKey(name: 'routing-mark') final  int routingMark;
@override@JsonKey(name: 'unified-delay') final  bool unifiedDelay;
@override@JsonKey(name: 'tcp-concurrent') final  bool tcpConcurrent;
@override@JsonKey(fromJson: Tun.safeFormJson) final  Tun tun;
@override@JsonKey(fromJson: Dns.safeDnsFromJson) final  Dns dns;
 final  Set<DnsOverrideKey> _dnsOverrideKeys;
@override@JsonKey(name: _dnsOverrideKeysJsonKey, fromJson: _dnsOverrideKeysFromJson) Set<DnsOverrideKey> get dnsOverrideKeys {
  if (_dnsOverrideKeys is EqualUnmodifiableSetView) return _dnsOverrideKeys;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_dnsOverrideKeys);
}

 final  Map<GeoResource, String> _geoXUrl;
@override@JsonKey(name: 'geox-url', fromJson: _geoXUrlFromJson, toJson: _geoXUrlToJson) Map<GeoResource, String> get geoXUrl {
  if (_geoXUrl is EqualUnmodifiableMapView) return _geoXUrl;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_geoXUrl);
}

@override@JsonKey(name: 'geodata-loader') final  GeodataLoader geodataLoader;
@override@JsonKey(name: 'global-ua') final  String? globalUa;
@override@JsonKey(name: 'external-controller') final  ExternalControllerStatus externalController;
@override@JsonKey() final  String secret;
 final  Map<String, String> _hosts;
@override@JsonKey() Map<String, String> get hosts {
  if (_hosts is EqualUnmodifiableMapView) return _hosts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_hosts);
}

@override@JsonKey(name: 'geo-auto-update') final  bool geoAutoUpdate;
@override@JsonKey(name: 'geo-update-interval') final  int geoUpdateInterval;

/// Create a copy of PatchClashConfig
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PatchClashConfigCopyWith<_PatchClashConfig> get copyWith => __$PatchClashConfigCopyWithImpl<_PatchClashConfig>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PatchClashConfigToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PatchClashConfig&&(identical(other.mixedPort, mixedPort) || other.mixedPort == mixedPort)&&(identical(other.socksPort, socksPort) || other.socksPort == socksPort)&&(identical(other.port, port) || other.port == port)&&(identical(other.redirPort, redirPort) || other.redirPort == redirPort)&&(identical(other.tproxyPort, tproxyPort) || other.tproxyPort == tproxyPort)&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.allowLan, allowLan) || other.allowLan == allowLan)&&(identical(other.logLevel, logLevel) || other.logLevel == logLevel)&&(identical(other.ipv6, ipv6) || other.ipv6 == ipv6)&&(identical(other.findProcessMode, findProcessMode) || other.findProcessMode == findProcessMode)&&(identical(other.interfaceNameMode, interfaceNameMode) || other.interfaceNameMode == interfaceNameMode)&&(identical(other.interfaceName, interfaceName) || other.interfaceName == interfaceName)&&(identical(other.keepAliveInterval, keepAliveInterval) || other.keepAliveInterval == keepAliveInterval)&&(identical(other.keepAliveIdle, keepAliveIdle) || other.keepAliveIdle == keepAliveIdle)&&(identical(other.disableKeepAlive, disableKeepAlive) || other.disableKeepAlive == disableKeepAlive)&&(identical(other.routingMark, routingMark) || other.routingMark == routingMark)&&(identical(other.unifiedDelay, unifiedDelay) || other.unifiedDelay == unifiedDelay)&&(identical(other.tcpConcurrent, tcpConcurrent) || other.tcpConcurrent == tcpConcurrent)&&(identical(other.tun, tun) || other.tun == tun)&&(identical(other.dns, dns) || other.dns == dns)&&const DeepCollectionEquality().equals(other.dnsOverrideKeys, _dnsOverrideKeys)&&const DeepCollectionEquality().equals(other.geoXUrl, _geoXUrl)&&(identical(other.geodataLoader, geodataLoader) || other.geodataLoader == geodataLoader)&&(identical(other.globalUa, globalUa) || other.globalUa == globalUa)&&(identical(other.externalController, externalController) || other.externalController == externalController)&&(identical(other.secret, secret) || other.secret == secret)&&const DeepCollectionEquality().equals(other.hosts, _hosts)&&(identical(other.geoAutoUpdate, geoAutoUpdate) || other.geoAutoUpdate == geoAutoUpdate)&&(identical(other.geoUpdateInterval, geoUpdateInterval) || other.geoUpdateInterval == geoUpdateInterval));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hashAll([runtimeType,mixedPort,socksPort,port,redirPort,tproxyPort,mode,allowLan,logLevel,ipv6,findProcessMode,interfaceNameMode,interfaceName,keepAliveInterval,keepAliveIdle,disableKeepAlive,routingMark,unifiedDelay,tcpConcurrent,tun,dns,const DeepCollectionEquality().hash(_dnsOverrideKeys),const DeepCollectionEquality().hash(_geoXUrl),geodataLoader,globalUa,externalController,secret,const DeepCollectionEquality().hash(_hosts),geoAutoUpdate,geoUpdateInterval]);
}

@override
String toString() {
    return 'PatchClashConfig(mixedPort: $mixedPort, socksPort: $socksPort, port: $port, redirPort: $redirPort, tproxyPort: $tproxyPort, mode: $mode, allowLan: $allowLan, logLevel: $logLevel, ipv6: $ipv6, findProcessMode: $findProcessMode, interfaceNameMode: $interfaceNameMode, interfaceName: $interfaceName, keepAliveInterval: $keepAliveInterval, keepAliveIdle: $keepAliveIdle, disableKeepAlive: $disableKeepAlive, routingMark: $routingMark, unifiedDelay: $unifiedDelay, tcpConcurrent: $tcpConcurrent, tun: $tun, dns: $dns, dnsOverrideKeys: $dnsOverrideKeys, geoXUrl: $geoXUrl, geodataLoader: $geodataLoader, globalUa: $globalUa, externalController: $externalController, secret: $secret, hosts: $hosts, geoAutoUpdate: $geoAutoUpdate, geoUpdateInterval: $geoUpdateInterval)';
}


}

/// @nodoc
abstract mixin class _$PatchClashConfigCopyWith<$Res> implements $PatchClashConfigCopyWith<$Res> {
  factory _$PatchClashConfigCopyWith(_PatchClashConfig value, $Res Function(_PatchClashConfig) _then) = __$PatchClashConfigCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'mixed-port') int mixedPort,@JsonKey(name: 'socks-port') int socksPort,@JsonKey(name: 'port') int port,@JsonKey(name: 'redir-port') int redirPort,@JsonKey(name: 'tproxy-port') int tproxyPort, Mode mode,@JsonKey(name: 'allow-lan') bool allowLan,@JsonKey(name: 'log-level') LogLevel logLevel, bool ipv6,@JsonKey(name: 'find-process-mode', unknownEnumValue: FindProcessMode.off) FindProcessMode findProcessMode,@JsonKey(name: 'interface-name-mode', unknownEnumValue: InterfaceNameMode.clear) InterfaceNameMode interfaceNameMode,@JsonKey(name: 'interface-name') String interfaceName,@JsonKey(name: 'keep-alive-interval') int keepAliveInterval,@JsonKey(name: 'keep-alive-idle') int keepAliveIdle,@JsonKey(name: 'disable-keep-alive') bool disableKeepAlive,@JsonKey(name: 'routing-mark') int routingMark,@JsonKey(name: 'unified-delay') bool unifiedDelay,@JsonKey(name: 'tcp-concurrent') bool tcpConcurrent,@JsonKey(fromJson: Tun.safeFormJson) Tun tun,@JsonKey(fromJson: Dns.safeDnsFromJson) Dns dns,@JsonKey(name: _dnsOverrideKeysJsonKey, fromJson: _dnsOverrideKeysFromJson) Set<DnsOverrideKey> dnsOverrideKeys,@JsonKey(name: 'geox-url', fromJson: _geoXUrlFromJson, toJson: _geoXUrlToJson) Map<GeoResource, String> geoXUrl,@JsonKey(name: 'geodata-loader') GeodataLoader geodataLoader,@JsonKey(name: 'global-ua') String? globalUa,@JsonKey(name: 'external-controller') ExternalControllerStatus externalController, String secret, Map<String, String> hosts,@JsonKey(name: 'geo-auto-update') bool geoAutoUpdate,@JsonKey(name: 'geo-update-interval') int geoUpdateInterval
});


@override $TunCopyWith<$Res> get tun;@override $DnsCopyWith<$Res> get dns;

}
/// @nodoc
class __$PatchClashConfigCopyWithImpl<$Res>
    implements _$PatchClashConfigCopyWith<$Res> {
  __$PatchClashConfigCopyWithImpl(this._self, this._then);

  final _PatchClashConfig _self;
  final $Res Function(_PatchClashConfig) _then;

/// Create a copy of PatchClashConfig
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? mixedPort = null,Object? socksPort = null,Object? port = null,Object? redirPort = null,Object? tproxyPort = null,Object? mode = null,Object? allowLan = null,Object? logLevel = null,Object? ipv6 = null,Object? findProcessMode = null,Object? interfaceNameMode = null,Object? interfaceName = null,Object? keepAliveInterval = null,Object? keepAliveIdle = null,Object? disableKeepAlive = null,Object? routingMark = null,Object? unifiedDelay = null,Object? tcpConcurrent = null,Object? tun = null,Object? dns = null,Object? dnsOverrideKeys = null,Object? geoXUrl = null,Object? geodataLoader = null,Object? globalUa = freezed,Object? externalController = null,Object? secret = null,Object? hosts = null,Object? geoAutoUpdate = null,Object? geoUpdateInterval = null,}) {
  return _then(_PatchClashConfig(
mixedPort: null == mixedPort ? _self.mixedPort : mixedPort // ignore: cast_nullable_to_non_nullable
as int,socksPort: null == socksPort ? _self.socksPort : socksPort // ignore: cast_nullable_to_non_nullable
as int,port: null == port ? _self.port : port // ignore: cast_nullable_to_non_nullable
as int,redirPort: null == redirPort ? _self.redirPort : redirPort // ignore: cast_nullable_to_non_nullable
as int,tproxyPort: null == tproxyPort ? _self.tproxyPort : tproxyPort // ignore: cast_nullable_to_non_nullable
as int,mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as Mode,allowLan: null == allowLan ? _self.allowLan : allowLan // ignore: cast_nullable_to_non_nullable
as bool,logLevel: null == logLevel ? _self.logLevel : logLevel // ignore: cast_nullable_to_non_nullable
as LogLevel,ipv6: null == ipv6 ? _self.ipv6 : ipv6 // ignore: cast_nullable_to_non_nullable
as bool,findProcessMode: null == findProcessMode ? _self.findProcessMode : findProcessMode // ignore: cast_nullable_to_non_nullable
as FindProcessMode,interfaceNameMode: null == interfaceNameMode ? _self.interfaceNameMode : interfaceNameMode // ignore: cast_nullable_to_non_nullable
as InterfaceNameMode,interfaceName: null == interfaceName ? _self.interfaceName : interfaceName // ignore: cast_nullable_to_non_nullable
as String,keepAliveInterval: null == keepAliveInterval ? _self.keepAliveInterval : keepAliveInterval // ignore: cast_nullable_to_non_nullable
as int,keepAliveIdle: null == keepAliveIdle ? _self.keepAliveIdle : keepAliveIdle // ignore: cast_nullable_to_non_nullable
as int,disableKeepAlive: null == disableKeepAlive ? _self.disableKeepAlive : disableKeepAlive // ignore: cast_nullable_to_non_nullable
as bool,routingMark: null == routingMark ? _self.routingMark : routingMark // ignore: cast_nullable_to_non_nullable
as int,unifiedDelay: null == unifiedDelay ? _self.unifiedDelay : unifiedDelay // ignore: cast_nullable_to_non_nullable
as bool,tcpConcurrent: null == tcpConcurrent ? _self.tcpConcurrent : tcpConcurrent // ignore: cast_nullable_to_non_nullable
as bool,tun: null == tun ? _self.tun : tun // ignore: cast_nullable_to_non_nullable
as Tun,dns: null == dns ? _self.dns : dns // ignore: cast_nullable_to_non_nullable
as Dns,dnsOverrideKeys: null == dnsOverrideKeys ? _self._dnsOverrideKeys : dnsOverrideKeys // ignore: cast_nullable_to_non_nullable
as Set<DnsOverrideKey>,geoXUrl: null == geoXUrl ? _self._geoXUrl : geoXUrl // ignore: cast_nullable_to_non_nullable
as Map<GeoResource, String>,geodataLoader: null == geodataLoader ? _self.geodataLoader : geodataLoader // ignore: cast_nullable_to_non_nullable
as GeodataLoader,globalUa: freezed == globalUa ? _self.globalUa : globalUa // ignore: cast_nullable_to_non_nullable
as String?,externalController: null == externalController ? _self.externalController : externalController // ignore: cast_nullable_to_non_nullable
as ExternalControllerStatus,secret: null == secret ? _self.secret : secret // ignore: cast_nullable_to_non_nullable
as String,hosts: null == hosts ? _self._hosts : hosts // ignore: cast_nullable_to_non_nullable
as Map<String, String>,geoAutoUpdate: null == geoAutoUpdate ? _self.geoAutoUpdate : geoAutoUpdate // ignore: cast_nullable_to_non_nullable
as bool,geoUpdateInterval: null == geoUpdateInterval ? _self.geoUpdateInterval : geoUpdateInterval // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

/// Create a copy of PatchClashConfig
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TunCopyWith<$Res> get tun {
  
  return $TunCopyWith<$Res>(_self.tun, (value) {
    return _then(_self.copyWith(tun: value));
  });
}/// Create a copy of PatchClashConfig
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DnsCopyWith<$Res> get dns {
  
  return $DnsCopyWith<$Res>(_self.dns, (value) {
    return _then(_self.copyWith(dns: value));
  });
}
}

// dart format on
