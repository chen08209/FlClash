// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../clash_config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ProxyGroup {

 int? get profileId;@JsonKey(fromJson: Snowflake.buildId) int get id; String get name; GroupType get type; List<String>? get proxies; List<String>? get use; int? get interval; bool? get lazy;@JsonKey(name: 'disable-udp') bool? get disableUDP; String? get url; int? get timeout;@JsonKey(name: 'max-failed-times') int? get maxFailedTimes; String? get filter;@JsonKey(name: 'exclude-filter') String? get excludeFilter;@JsonKey(name: 'exclude-type') String? get excludeType;@JsonKey(name: 'expected-status') String? get expectedStatus;@JsonKey(name: 'include-all') bool? get includeAll;@JsonKey(name: 'include-all-proxies') bool? get includeAllProxies;@JsonKey(name: 'include-all-providers') bool? get includeAllProviders; bool? get hidden; String? get icon; String? get order;
/// Create a copy of ProxyGroup
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProxyGroupCopyWith<ProxyGroup> get copyWith => _$ProxyGroupCopyWithImpl<ProxyGroup>(this as ProxyGroup, _$identity);

  /// Serializes this ProxyGroup to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProxyGroup&&(identical(other.profileId, profileId) || other.profileId == profileId)&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&const DeepCollectionEquality().equals(other.proxies, proxies)&&const DeepCollectionEquality().equals(other.use, use)&&(identical(other.interval, interval) || other.interval == interval)&&(identical(other.lazy, lazy) || other.lazy == lazy)&&(identical(other.disableUDP, disableUDP) || other.disableUDP == disableUDP)&&(identical(other.url, url) || other.url == url)&&(identical(other.timeout, timeout) || other.timeout == timeout)&&(identical(other.maxFailedTimes, maxFailedTimes) || other.maxFailedTimes == maxFailedTimes)&&(identical(other.filter, filter) || other.filter == filter)&&(identical(other.excludeFilter, excludeFilter) || other.excludeFilter == excludeFilter)&&(identical(other.excludeType, excludeType) || other.excludeType == excludeType)&&(identical(other.expectedStatus, expectedStatus) || other.expectedStatus == expectedStatus)&&(identical(other.includeAll, includeAll) || other.includeAll == includeAll)&&(identical(other.includeAllProxies, includeAllProxies) || other.includeAllProxies == includeAllProxies)&&(identical(other.includeAllProviders, includeAllProviders) || other.includeAllProviders == includeAllProviders)&&(identical(other.hidden, hidden) || other.hidden == hidden)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.order, order) || other.order == order));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,profileId,id,name,type,const DeepCollectionEquality().hash(proxies),const DeepCollectionEquality().hash(use),interval,lazy,disableUDP,url,timeout,maxFailedTimes,filter,excludeFilter,excludeType,expectedStatus,includeAll,includeAllProxies,includeAllProviders,hidden,icon,order]);

@override
String toString() {
  return 'ProxyGroup(profileId: $profileId, id: $id, name: $name, type: $type, proxies: $proxies, use: $use, interval: $interval, lazy: $lazy, disableUDP: $disableUDP, url: $url, timeout: $timeout, maxFailedTimes: $maxFailedTimes, filter: $filter, excludeFilter: $excludeFilter, excludeType: $excludeType, expectedStatus: $expectedStatus, includeAll: $includeAll, includeAllProxies: $includeAllProxies, includeAllProviders: $includeAllProviders, hidden: $hidden, icon: $icon, order: $order)';
}


}

/// @nodoc
abstract mixin class $ProxyGroupCopyWith<$Res>  {
  factory $ProxyGroupCopyWith(ProxyGroup value, $Res Function(ProxyGroup) _then) = _$ProxyGroupCopyWithImpl;
@useResult
$Res call({
 int? profileId,@JsonKey(fromJson: Snowflake.buildId) int id, String name, GroupType type, List<String>? proxies, List<String>? use, int? interval, bool? lazy,@JsonKey(name: 'disable-udp') bool? disableUDP, String? url, int? timeout,@JsonKey(name: 'max-failed-times') int? maxFailedTimes, String? filter,@JsonKey(name: 'exclude-filter') String? excludeFilter,@JsonKey(name: 'exclude-type') String? excludeType,@JsonKey(name: 'expected-status') String? expectedStatus,@JsonKey(name: 'include-all') bool? includeAll,@JsonKey(name: 'include-all-proxies') bool? includeAllProxies,@JsonKey(name: 'include-all-providers') bool? includeAllProviders, bool? hidden, String? icon, String? order
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
@pragma('vm:prefer-inline') @override $Res call({Object? profileId = freezed,Object? id = null,Object? name = null,Object? type = null,Object? proxies = freezed,Object? use = freezed,Object? interval = freezed,Object? lazy = freezed,Object? disableUDP = freezed,Object? url = freezed,Object? timeout = freezed,Object? maxFailedTimes = freezed,Object? filter = freezed,Object? excludeFilter = freezed,Object? excludeType = freezed,Object? expectedStatus = freezed,Object? includeAll = freezed,Object? includeAllProxies = freezed,Object? includeAllProviders = freezed,Object? hidden = freezed,Object? icon = freezed,Object? order = freezed,}) {
  return _then(_self.copyWith(
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? profileId, @JsonKey(fromJson: Snowflake.buildId)  int id,  String name,  GroupType type,  List<String>? proxies,  List<String>? use,  int? interval,  bool? lazy, @JsonKey(name: 'disable-udp')  bool? disableUDP,  String? url,  int? timeout, @JsonKey(name: 'max-failed-times')  int? maxFailedTimes,  String? filter, @JsonKey(name: 'exclude-filter')  String? excludeFilter, @JsonKey(name: 'exclude-type')  String? excludeType, @JsonKey(name: 'expected-status')  String? expectedStatus, @JsonKey(name: 'include-all')  bool? includeAll, @JsonKey(name: 'include-all-proxies')  bool? includeAllProxies, @JsonKey(name: 'include-all-providers')  bool? includeAllProviders,  bool? hidden,  String? icon,  String? order)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProxyGroup() when $default != null:
return $default(_that.profileId,_that.id,_that.name,_that.type,_that.proxies,_that.use,_that.interval,_that.lazy,_that.disableUDP,_that.url,_that.timeout,_that.maxFailedTimes,_that.filter,_that.excludeFilter,_that.excludeType,_that.expectedStatus,_that.includeAll,_that.includeAllProxies,_that.includeAllProviders,_that.hidden,_that.icon,_that.order);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? profileId, @JsonKey(fromJson: Snowflake.buildId)  int id,  String name,  GroupType type,  List<String>? proxies,  List<String>? use,  int? interval,  bool? lazy, @JsonKey(name: 'disable-udp')  bool? disableUDP,  String? url,  int? timeout, @JsonKey(name: 'max-failed-times')  int? maxFailedTimes,  String? filter, @JsonKey(name: 'exclude-filter')  String? excludeFilter, @JsonKey(name: 'exclude-type')  String? excludeType, @JsonKey(name: 'expected-status')  String? expectedStatus, @JsonKey(name: 'include-all')  bool? includeAll, @JsonKey(name: 'include-all-proxies')  bool? includeAllProxies, @JsonKey(name: 'include-all-providers')  bool? includeAllProviders,  bool? hidden,  String? icon,  String? order)  $default,) {final _that = this;
switch (_that) {
case _ProxyGroup():
return $default(_that.profileId,_that.id,_that.name,_that.type,_that.proxies,_that.use,_that.interval,_that.lazy,_that.disableUDP,_that.url,_that.timeout,_that.maxFailedTimes,_that.filter,_that.excludeFilter,_that.excludeType,_that.expectedStatus,_that.includeAll,_that.includeAllProxies,_that.includeAllProviders,_that.hidden,_that.icon,_that.order);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? profileId, @JsonKey(fromJson: Snowflake.buildId)  int id,  String name,  GroupType type,  List<String>? proxies,  List<String>? use,  int? interval,  bool? lazy, @JsonKey(name: 'disable-udp')  bool? disableUDP,  String? url,  int? timeout, @JsonKey(name: 'max-failed-times')  int? maxFailedTimes,  String? filter, @JsonKey(name: 'exclude-filter')  String? excludeFilter, @JsonKey(name: 'exclude-type')  String? excludeType, @JsonKey(name: 'expected-status')  String? expectedStatus, @JsonKey(name: 'include-all')  bool? includeAll, @JsonKey(name: 'include-all-proxies')  bool? includeAllProxies, @JsonKey(name: 'include-all-providers')  bool? includeAllProviders,  bool? hidden,  String? icon,  String? order)?  $default,) {final _that = this;
switch (_that) {
case _ProxyGroup() when $default != null:
return $default(_that.profileId,_that.id,_that.name,_that.type,_that.proxies,_that.use,_that.interval,_that.lazy,_that.disableUDP,_that.url,_that.timeout,_that.maxFailedTimes,_that.filter,_that.excludeFilter,_that.excludeType,_that.expectedStatus,_that.includeAll,_that.includeAllProxies,_that.includeAllProviders,_that.hidden,_that.icon,_that.order);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProxyGroup implements ProxyGroup {
  const _ProxyGroup({this.profileId, @JsonKey(fromJson: Snowflake.buildId) required this.id, required this.name, required this.type, final  List<String>? proxies, final  List<String>? use, this.interval, this.lazy, @JsonKey(name: 'disable-udp') this.disableUDP, this.url, this.timeout, @JsonKey(name: 'max-failed-times') this.maxFailedTimes, this.filter, @JsonKey(name: 'exclude-filter') this.excludeFilter, @JsonKey(name: 'exclude-type') this.excludeType, @JsonKey(name: 'expected-status') this.expectedStatus, @JsonKey(name: 'include-all') this.includeAll, @JsonKey(name: 'include-all-proxies') this.includeAllProxies, @JsonKey(name: 'include-all-providers') this.includeAllProviders, this.hidden, this.icon, this.order}): _proxies = proxies,_use = use;
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProxyGroup&&(identical(other.profileId, profileId) || other.profileId == profileId)&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&const DeepCollectionEquality().equals(other._proxies, _proxies)&&const DeepCollectionEquality().equals(other._use, _use)&&(identical(other.interval, interval) || other.interval == interval)&&(identical(other.lazy, lazy) || other.lazy == lazy)&&(identical(other.disableUDP, disableUDP) || other.disableUDP == disableUDP)&&(identical(other.url, url) || other.url == url)&&(identical(other.timeout, timeout) || other.timeout == timeout)&&(identical(other.maxFailedTimes, maxFailedTimes) || other.maxFailedTimes == maxFailedTimes)&&(identical(other.filter, filter) || other.filter == filter)&&(identical(other.excludeFilter, excludeFilter) || other.excludeFilter == excludeFilter)&&(identical(other.excludeType, excludeType) || other.excludeType == excludeType)&&(identical(other.expectedStatus, expectedStatus) || other.expectedStatus == expectedStatus)&&(identical(other.includeAll, includeAll) || other.includeAll == includeAll)&&(identical(other.includeAllProxies, includeAllProxies) || other.includeAllProxies == includeAllProxies)&&(identical(other.includeAllProviders, includeAllProviders) || other.includeAllProviders == includeAllProviders)&&(identical(other.hidden, hidden) || other.hidden == hidden)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.order, order) || other.order == order));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,profileId,id,name,type,const DeepCollectionEquality().hash(_proxies),const DeepCollectionEquality().hash(_use),interval,lazy,disableUDP,url,timeout,maxFailedTimes,filter,excludeFilter,excludeType,expectedStatus,includeAll,includeAllProxies,includeAllProviders,hidden,icon,order]);

@override
String toString() {
  return 'ProxyGroup(profileId: $profileId, id: $id, name: $name, type: $type, proxies: $proxies, use: $use, interval: $interval, lazy: $lazy, disableUDP: $disableUDP, url: $url, timeout: $timeout, maxFailedTimes: $maxFailedTimes, filter: $filter, excludeFilter: $excludeFilter, excludeType: $excludeType, expectedStatus: $expectedStatus, includeAll: $includeAll, includeAllProxies: $includeAllProxies, includeAllProviders: $includeAllProviders, hidden: $hidden, icon: $icon, order: $order)';
}


}

/// @nodoc
abstract mixin class _$ProxyGroupCopyWith<$Res> implements $ProxyGroupCopyWith<$Res> {
  factory _$ProxyGroupCopyWith(_ProxyGroup value, $Res Function(_ProxyGroup) _then) = __$ProxyGroupCopyWithImpl;
@override @useResult
$Res call({
 int? profileId,@JsonKey(fromJson: Snowflake.buildId) int id, String name, GroupType type, List<String>? proxies, List<String>? use, int? interval, bool? lazy,@JsonKey(name: 'disable-udp') bool? disableUDP, String? url, int? timeout,@JsonKey(name: 'max-failed-times') int? maxFailedTimes, String? filter,@JsonKey(name: 'exclude-filter') String? excludeFilter,@JsonKey(name: 'exclude-type') String? excludeType,@JsonKey(name: 'expected-status') String? expectedStatus,@JsonKey(name: 'include-all') bool? includeAll,@JsonKey(name: 'include-all-proxies') bool? includeAllProxies,@JsonKey(name: 'include-all-providers') bool? includeAllProviders, bool? hidden, String? icon, String? order
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
@override @pragma('vm:prefer-inline') $Res call({Object? profileId = freezed,Object? id = null,Object? name = null,Object? type = null,Object? proxies = freezed,Object? use = freezed,Object? interval = freezed,Object? lazy = freezed,Object? disableUDP = freezed,Object? url = freezed,Object? timeout = freezed,Object? maxFailedTimes = freezed,Object? filter = freezed,Object? excludeFilter = freezed,Object? excludeType = freezed,Object? expectedStatus = freezed,Object? includeAll = freezed,Object? includeAllProxies = freezed,Object? includeAllProviders = freezed,Object? hidden = freezed,Object? icon = freezed,Object? order = freezed,}) {
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Proxy&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&(identical(other.now, now) || other.now == now));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,type,now);

@override
String toString() {
  return 'Proxy(name: $name, type: $type, now: $now)';
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
  return _then(_self.copyWith(
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
int get hashCode => Object.hash(runtimeType,name,type,now);

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
mixin _$CustomOverwriteDate {

 List<Proxy> get proxies; List<ProxyGroup> get proxyGroups; Set<String> get proxyProviders; Set<String> get ruleTargets; Set<String> get subRules;
/// Create a copy of CustomOverwriteDate
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CustomOverwriteDateCopyWith<CustomOverwriteDate> get copyWith => _$CustomOverwriteDateCopyWithImpl<CustomOverwriteDate>(this as CustomOverwriteDate, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CustomOverwriteDate&&const DeepCollectionEquality().equals(other.proxies, proxies)&&const DeepCollectionEquality().equals(other.proxyGroups, proxyGroups)&&const DeepCollectionEquality().equals(other.proxyProviders, proxyProviders)&&const DeepCollectionEquality().equals(other.ruleTargets, ruleTargets)&&const DeepCollectionEquality().equals(other.subRules, subRules));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(proxies),const DeepCollectionEquality().hash(proxyGroups),const DeepCollectionEquality().hash(proxyProviders),const DeepCollectionEquality().hash(ruleTargets),const DeepCollectionEquality().hash(subRules));

@override
String toString() {
  return 'CustomOverwriteDate(proxies: $proxies, proxyGroups: $proxyGroups, proxyProviders: $proxyProviders, ruleTargets: $ruleTargets, subRules: $subRules)';
}


}

/// @nodoc
abstract mixin class $CustomOverwriteDateCopyWith<$Res>  {
  factory $CustomOverwriteDateCopyWith(CustomOverwriteDate value, $Res Function(CustomOverwriteDate) _then) = _$CustomOverwriteDateCopyWithImpl;
@useResult
$Res call({
 List<Proxy> proxies, List<ProxyGroup> proxyGroups, Set<String> proxyProviders, Set<String> ruleTargets, Set<String> subRules
});




}
/// @nodoc
class _$CustomOverwriteDateCopyWithImpl<$Res>
    implements $CustomOverwriteDateCopyWith<$Res> {
  _$CustomOverwriteDateCopyWithImpl(this._self, this._then);

  final CustomOverwriteDate _self;
  final $Res Function(CustomOverwriteDate) _then;

/// Create a copy of CustomOverwriteDate
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? proxies = null,Object? proxyGroups = null,Object? proxyProviders = null,Object? ruleTargets = null,Object? subRules = null,}) {
  return _then(_self.copyWith(
proxies: null == proxies ? _self.proxies : proxies // ignore: cast_nullable_to_non_nullable
as List<Proxy>,proxyGroups: null == proxyGroups ? _self.proxyGroups : proxyGroups // ignore: cast_nullable_to_non_nullable
as List<ProxyGroup>,proxyProviders: null == proxyProviders ? _self.proxyProviders : proxyProviders // ignore: cast_nullable_to_non_nullable
as Set<String>,ruleTargets: null == ruleTargets ? _self.ruleTargets : ruleTargets // ignore: cast_nullable_to_non_nullable
as Set<String>,subRules: null == subRules ? _self.subRules : subRules // ignore: cast_nullable_to_non_nullable
as Set<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [CustomOverwriteDate].
extension CustomOverwriteDatePatterns on CustomOverwriteDate {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CustomOverwriteDate value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CustomOverwriteDate() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CustomOverwriteDate value)  $default,){
final _that = this;
switch (_that) {
case _CustomOverwriteDate():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CustomOverwriteDate value)?  $default,){
final _that = this;
switch (_that) {
case _CustomOverwriteDate() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<Proxy> proxies,  List<ProxyGroup> proxyGroups,  Set<String> proxyProviders,  Set<String> ruleTargets,  Set<String> subRules)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CustomOverwriteDate() when $default != null:
return $default(_that.proxies,_that.proxyGroups,_that.proxyProviders,_that.ruleTargets,_that.subRules);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<Proxy> proxies,  List<ProxyGroup> proxyGroups,  Set<String> proxyProviders,  Set<String> ruleTargets,  Set<String> subRules)  $default,) {final _that = this;
switch (_that) {
case _CustomOverwriteDate():
return $default(_that.proxies,_that.proxyGroups,_that.proxyProviders,_that.ruleTargets,_that.subRules);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<Proxy> proxies,  List<ProxyGroup> proxyGroups,  Set<String> proxyProviders,  Set<String> ruleTargets,  Set<String> subRules)?  $default,) {final _that = this;
switch (_that) {
case _CustomOverwriteDate() when $default != null:
return $default(_that.proxies,_that.proxyGroups,_that.proxyProviders,_that.ruleTargets,_that.subRules);case _:
  return null;

}
}

}

/// @nodoc


class _CustomOverwriteDate implements CustomOverwriteDate {
  const _CustomOverwriteDate({final  List<Proxy> proxies = const [], final  List<ProxyGroup> proxyGroups = const [], final  Set<String> proxyProviders = const {}, final  Set<String> ruleTargets = const {}, final  Set<String> subRules = const {}}): _proxies = proxies,_proxyGroups = proxyGroups,_proxyProviders = proxyProviders,_ruleTargets = ruleTargets,_subRules = subRules;
  

 final  List<Proxy> _proxies;
@override@JsonKey() List<Proxy> get proxies {
  if (_proxies is EqualUnmodifiableListView) return _proxies;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_proxies);
}

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

 final  Set<String> _ruleTargets;
@override@JsonKey() Set<String> get ruleTargets {
  if (_ruleTargets is EqualUnmodifiableSetView) return _ruleTargets;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_ruleTargets);
}

 final  Set<String> _subRules;
@override@JsonKey() Set<String> get subRules {
  if (_subRules is EqualUnmodifiableSetView) return _subRules;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_subRules);
}


/// Create a copy of CustomOverwriteDate
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CustomOverwriteDateCopyWith<_CustomOverwriteDate> get copyWith => __$CustomOverwriteDateCopyWithImpl<_CustomOverwriteDate>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CustomOverwriteDate&&const DeepCollectionEquality().equals(other._proxies, _proxies)&&const DeepCollectionEquality().equals(other._proxyGroups, _proxyGroups)&&const DeepCollectionEquality().equals(other._proxyProviders, _proxyProviders)&&const DeepCollectionEquality().equals(other._ruleTargets, _ruleTargets)&&const DeepCollectionEquality().equals(other._subRules, _subRules));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_proxies),const DeepCollectionEquality().hash(_proxyGroups),const DeepCollectionEquality().hash(_proxyProviders),const DeepCollectionEquality().hash(_ruleTargets),const DeepCollectionEquality().hash(_subRules));

@override
String toString() {
  return 'CustomOverwriteDate(proxies: $proxies, proxyGroups: $proxyGroups, proxyProviders: $proxyProviders, ruleTargets: $ruleTargets, subRules: $subRules)';
}


}

/// @nodoc
abstract mixin class _$CustomOverwriteDateCopyWith<$Res> implements $CustomOverwriteDateCopyWith<$Res> {
  factory _$CustomOverwriteDateCopyWith(_CustomOverwriteDate value, $Res Function(_CustomOverwriteDate) _then) = __$CustomOverwriteDateCopyWithImpl;
@override @useResult
$Res call({
 List<Proxy> proxies, List<ProxyGroup> proxyGroups, Set<String> proxyProviders, Set<String> ruleTargets, Set<String> subRules
});




}
/// @nodoc
class __$CustomOverwriteDateCopyWithImpl<$Res>
    implements _$CustomOverwriteDateCopyWith<$Res> {
  __$CustomOverwriteDateCopyWithImpl(this._self, this._then);

  final _CustomOverwriteDate _self;
  final $Res Function(_CustomOverwriteDate) _then;

/// Create a copy of CustomOverwriteDate
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? proxies = null,Object? proxyGroups = null,Object? proxyProviders = null,Object? ruleTargets = null,Object? subRules = null,}) {
  return _then(_CustomOverwriteDate(
proxies: null == proxies ? _self._proxies : proxies // ignore: cast_nullable_to_non_nullable
as List<Proxy>,proxyGroups: null == proxyGroups ? _self._proxyGroups : proxyGroups // ignore: cast_nullable_to_non_nullable
as List<ProxyGroup>,proxyProviders: null == proxyProviders ? _self._proxyProviders : proxyProviders // ignore: cast_nullable_to_non_nullable
as Set<String>,ruleTargets: null == ruleTargets ? _self._ruleTargets : ruleTargets // ignore: cast_nullable_to_non_nullable
as Set<String>,subRules: null == subRules ? _self._subRules : subRules // ignore: cast_nullable_to_non_nullable
as Set<String>,
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RuleProvider&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name);

@override
String toString() {
  return 'RuleProvider(name: $name)';
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
  return _then(_self.copyWith(
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
int get hashCode => Object.hash(runtimeType,name);

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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProxyProvider&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name);

@override
String toString() {
  return 'ProxyProvider(name: $name)';
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
  return _then(_self.copyWith(
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
int get hashCode => Object.hash(runtimeType,name);

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

 bool get enable;@JsonKey(name: 'override-destination') bool get overrideDest; List<String> get sniffing;@JsonKey(name: 'force-domain') List<String> get forceDomain;@JsonKey(name: 'skip-src-address') List<String> get skipSrcAddress;@JsonKey(name: 'skip-dst-address') List<String> get skipDstAddress;@JsonKey(name: 'skip-domain') List<String> get skipDomain;@JsonKey(name: 'port-whitelist') List<String> get port;@JsonKey(name: 'force-dns-mapping') bool get forceDnsMapping;@JsonKey(name: 'parse-pure-ip') bool get parsePureIp; Map<String, SnifferConfig> get sniff;
/// Create a copy of Sniffer
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnifferCopyWith<Sniffer> get copyWith => _$SnifferCopyWithImpl<Sniffer>(this as Sniffer, _$identity);

  /// Serializes this Sniffer to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Sniffer&&(identical(other.enable, enable) || other.enable == enable)&&(identical(other.overrideDest, overrideDest) || other.overrideDest == overrideDest)&&const DeepCollectionEquality().equals(other.sniffing, sniffing)&&const DeepCollectionEquality().equals(other.forceDomain, forceDomain)&&const DeepCollectionEquality().equals(other.skipSrcAddress, skipSrcAddress)&&const DeepCollectionEquality().equals(other.skipDstAddress, skipDstAddress)&&const DeepCollectionEquality().equals(other.skipDomain, skipDomain)&&const DeepCollectionEquality().equals(other.port, port)&&(identical(other.forceDnsMapping, forceDnsMapping) || other.forceDnsMapping == forceDnsMapping)&&(identical(other.parsePureIp, parsePureIp) || other.parsePureIp == parsePureIp)&&const DeepCollectionEquality().equals(other.sniff, sniff));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,enable,overrideDest,const DeepCollectionEquality().hash(sniffing),const DeepCollectionEquality().hash(forceDomain),const DeepCollectionEquality().hash(skipSrcAddress),const DeepCollectionEquality().hash(skipDstAddress),const DeepCollectionEquality().hash(skipDomain),const DeepCollectionEquality().hash(port),forceDnsMapping,parsePureIp,const DeepCollectionEquality().hash(sniff));

@override
String toString() {
  return 'Sniffer(enable: $enable, overrideDest: $overrideDest, sniffing: $sniffing, forceDomain: $forceDomain, skipSrcAddress: $skipSrcAddress, skipDstAddress: $skipDstAddress, skipDomain: $skipDomain, port: $port, forceDnsMapping: $forceDnsMapping, parsePureIp: $parsePureIp, sniff: $sniff)';
}


}

/// @nodoc
abstract mixin class $SnifferCopyWith<$Res>  {
  factory $SnifferCopyWith(Sniffer value, $Res Function(Sniffer) _then) = _$SnifferCopyWithImpl;
@useResult
$Res call({
 bool enable,@JsonKey(name: 'override-destination') bool overrideDest, List<String> sniffing,@JsonKey(name: 'force-domain') List<String> forceDomain,@JsonKey(name: 'skip-src-address') List<String> skipSrcAddress,@JsonKey(name: 'skip-dst-address') List<String> skipDstAddress,@JsonKey(name: 'skip-domain') List<String> skipDomain,@JsonKey(name: 'port-whitelist') List<String> port,@JsonKey(name: 'force-dns-mapping') bool forceDnsMapping,@JsonKey(name: 'parse-pure-ip') bool parsePureIp, Map<String, SnifferConfig> sniff
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
@pragma('vm:prefer-inline') @override $Res call({Object? enable = null,Object? overrideDest = null,Object? sniffing = null,Object? forceDomain = null,Object? skipSrcAddress = null,Object? skipDstAddress = null,Object? skipDomain = null,Object? port = null,Object? forceDnsMapping = null,Object? parsePureIp = null,Object? sniff = null,}) {
  return _then(_self.copyWith(
enable: null == enable ? _self.enable : enable // ignore: cast_nullable_to_non_nullable
as bool,overrideDest: null == overrideDest ? _self.overrideDest : overrideDest // ignore: cast_nullable_to_non_nullable
as bool,sniffing: null == sniffing ? _self.sniffing : sniffing // ignore: cast_nullable_to_non_nullable
as List<String>,forceDomain: null == forceDomain ? _self.forceDomain : forceDomain // ignore: cast_nullable_to_non_nullable
as List<String>,skipSrcAddress: null == skipSrcAddress ? _self.skipSrcAddress : skipSrcAddress // ignore: cast_nullable_to_non_nullable
as List<String>,skipDstAddress: null == skipDstAddress ? _self.skipDstAddress : skipDstAddress // ignore: cast_nullable_to_non_nullable
as List<String>,skipDomain: null == skipDomain ? _self.skipDomain : skipDomain // ignore: cast_nullable_to_non_nullable
as List<String>,port: null == port ? _self.port : port // ignore: cast_nullable_to_non_nullable
as List<String>,forceDnsMapping: null == forceDnsMapping ? _self.forceDnsMapping : forceDnsMapping // ignore: cast_nullable_to_non_nullable
as bool,parsePureIp: null == parsePureIp ? _self.parsePureIp : parsePureIp // ignore: cast_nullable_to_non_nullable
as bool,sniff: null == sniff ? _self.sniff : sniff // ignore: cast_nullable_to_non_nullable
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool enable, @JsonKey(name: 'override-destination')  bool overrideDest,  List<String> sniffing, @JsonKey(name: 'force-domain')  List<String> forceDomain, @JsonKey(name: 'skip-src-address')  List<String> skipSrcAddress, @JsonKey(name: 'skip-dst-address')  List<String> skipDstAddress, @JsonKey(name: 'skip-domain')  List<String> skipDomain, @JsonKey(name: 'port-whitelist')  List<String> port, @JsonKey(name: 'force-dns-mapping')  bool forceDnsMapping, @JsonKey(name: 'parse-pure-ip')  bool parsePureIp,  Map<String, SnifferConfig> sniff)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Sniffer() when $default != null:
return $default(_that.enable,_that.overrideDest,_that.sniffing,_that.forceDomain,_that.skipSrcAddress,_that.skipDstAddress,_that.skipDomain,_that.port,_that.forceDnsMapping,_that.parsePureIp,_that.sniff);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool enable, @JsonKey(name: 'override-destination')  bool overrideDest,  List<String> sniffing, @JsonKey(name: 'force-domain')  List<String> forceDomain, @JsonKey(name: 'skip-src-address')  List<String> skipSrcAddress, @JsonKey(name: 'skip-dst-address')  List<String> skipDstAddress, @JsonKey(name: 'skip-domain')  List<String> skipDomain, @JsonKey(name: 'port-whitelist')  List<String> port, @JsonKey(name: 'force-dns-mapping')  bool forceDnsMapping, @JsonKey(name: 'parse-pure-ip')  bool parsePureIp,  Map<String, SnifferConfig> sniff)  $default,) {final _that = this;
switch (_that) {
case _Sniffer():
return $default(_that.enable,_that.overrideDest,_that.sniffing,_that.forceDomain,_that.skipSrcAddress,_that.skipDstAddress,_that.skipDomain,_that.port,_that.forceDnsMapping,_that.parsePureIp,_that.sniff);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool enable, @JsonKey(name: 'override-destination')  bool overrideDest,  List<String> sniffing, @JsonKey(name: 'force-domain')  List<String> forceDomain, @JsonKey(name: 'skip-src-address')  List<String> skipSrcAddress, @JsonKey(name: 'skip-dst-address')  List<String> skipDstAddress, @JsonKey(name: 'skip-domain')  List<String> skipDomain, @JsonKey(name: 'port-whitelist')  List<String> port, @JsonKey(name: 'force-dns-mapping')  bool forceDnsMapping, @JsonKey(name: 'parse-pure-ip')  bool parsePureIp,  Map<String, SnifferConfig> sniff)?  $default,) {final _that = this;
switch (_that) {
case _Sniffer() when $default != null:
return $default(_that.enable,_that.overrideDest,_that.sniffing,_that.forceDomain,_that.skipSrcAddress,_that.skipDstAddress,_that.skipDomain,_that.port,_that.forceDnsMapping,_that.parsePureIp,_that.sniff);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Sniffer implements Sniffer {
  const _Sniffer({this.enable = false, @JsonKey(name: 'override-destination') this.overrideDest = true, final  List<String> sniffing = const [], @JsonKey(name: 'force-domain') final  List<String> forceDomain = const [], @JsonKey(name: 'skip-src-address') final  List<String> skipSrcAddress = const [], @JsonKey(name: 'skip-dst-address') final  List<String> skipDstAddress = const [], @JsonKey(name: 'skip-domain') final  List<String> skipDomain = const [], @JsonKey(name: 'port-whitelist') final  List<String> port = const [], @JsonKey(name: 'force-dns-mapping') this.forceDnsMapping = true, @JsonKey(name: 'parse-pure-ip') this.parsePureIp = true, final  Map<String, SnifferConfig> sniff = const {}}): _sniffing = sniffing,_forceDomain = forceDomain,_skipSrcAddress = skipSrcAddress,_skipDstAddress = skipDstAddress,_skipDomain = skipDomain,_port = port,_sniff = sniff;
  factory _Sniffer.fromJson(Map<String, dynamic> json) => _$SnifferFromJson(json);

@override@JsonKey() final  bool enable;
@override@JsonKey(name: 'override-destination') final  bool overrideDest;
 final  List<String> _sniffing;
@override@JsonKey() List<String> get sniffing {
  if (_sniffing is EqualUnmodifiableListView) return _sniffing;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_sniffing);
}

 final  List<String> _forceDomain;
@override@JsonKey(name: 'force-domain') List<String> get forceDomain {
  if (_forceDomain is EqualUnmodifiableListView) return _forceDomain;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_forceDomain);
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

 final  List<String> _skipDomain;
@override@JsonKey(name: 'skip-domain') List<String> get skipDomain {
  if (_skipDomain is EqualUnmodifiableListView) return _skipDomain;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_skipDomain);
}

 final  List<String> _port;
@override@JsonKey(name: 'port-whitelist') List<String> get port {
  if (_port is EqualUnmodifiableListView) return _port;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_port);
}

@override@JsonKey(name: 'force-dns-mapping') final  bool forceDnsMapping;
@override@JsonKey(name: 'parse-pure-ip') final  bool parsePureIp;
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Sniffer&&(identical(other.enable, enable) || other.enable == enable)&&(identical(other.overrideDest, overrideDest) || other.overrideDest == overrideDest)&&const DeepCollectionEquality().equals(other._sniffing, _sniffing)&&const DeepCollectionEquality().equals(other._forceDomain, _forceDomain)&&const DeepCollectionEquality().equals(other._skipSrcAddress, _skipSrcAddress)&&const DeepCollectionEquality().equals(other._skipDstAddress, _skipDstAddress)&&const DeepCollectionEquality().equals(other._skipDomain, _skipDomain)&&const DeepCollectionEquality().equals(other._port, _port)&&(identical(other.forceDnsMapping, forceDnsMapping) || other.forceDnsMapping == forceDnsMapping)&&(identical(other.parsePureIp, parsePureIp) || other.parsePureIp == parsePureIp)&&const DeepCollectionEquality().equals(other._sniff, _sniff));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,enable,overrideDest,const DeepCollectionEquality().hash(_sniffing),const DeepCollectionEquality().hash(_forceDomain),const DeepCollectionEquality().hash(_skipSrcAddress),const DeepCollectionEquality().hash(_skipDstAddress),const DeepCollectionEquality().hash(_skipDomain),const DeepCollectionEquality().hash(_port),forceDnsMapping,parsePureIp,const DeepCollectionEquality().hash(_sniff));

@override
String toString() {
  return 'Sniffer(enable: $enable, overrideDest: $overrideDest, sniffing: $sniffing, forceDomain: $forceDomain, skipSrcAddress: $skipSrcAddress, skipDstAddress: $skipDstAddress, skipDomain: $skipDomain, port: $port, forceDnsMapping: $forceDnsMapping, parsePureIp: $parsePureIp, sniff: $sniff)';
}


}

/// @nodoc
abstract mixin class _$SnifferCopyWith<$Res> implements $SnifferCopyWith<$Res> {
  factory _$SnifferCopyWith(_Sniffer value, $Res Function(_Sniffer) _then) = __$SnifferCopyWithImpl;
@override @useResult
$Res call({
 bool enable,@JsonKey(name: 'override-destination') bool overrideDest, List<String> sniffing,@JsonKey(name: 'force-domain') List<String> forceDomain,@JsonKey(name: 'skip-src-address') List<String> skipSrcAddress,@JsonKey(name: 'skip-dst-address') List<String> skipDstAddress,@JsonKey(name: 'skip-domain') List<String> skipDomain,@JsonKey(name: 'port-whitelist') List<String> port,@JsonKey(name: 'force-dns-mapping') bool forceDnsMapping,@JsonKey(name: 'parse-pure-ip') bool parsePureIp, Map<String, SnifferConfig> sniff
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
@override @pragma('vm:prefer-inline') $Res call({Object? enable = null,Object? overrideDest = null,Object? sniffing = null,Object? forceDomain = null,Object? skipSrcAddress = null,Object? skipDstAddress = null,Object? skipDomain = null,Object? port = null,Object? forceDnsMapping = null,Object? parsePureIp = null,Object? sniff = null,}) {
  return _then(_Sniffer(
enable: null == enable ? _self.enable : enable // ignore: cast_nullable_to_non_nullable
as bool,overrideDest: null == overrideDest ? _self.overrideDest : overrideDest // ignore: cast_nullable_to_non_nullable
as bool,sniffing: null == sniffing ? _self._sniffing : sniffing // ignore: cast_nullable_to_non_nullable
as List<String>,forceDomain: null == forceDomain ? _self._forceDomain : forceDomain // ignore: cast_nullable_to_non_nullable
as List<String>,skipSrcAddress: null == skipSrcAddress ? _self._skipSrcAddress : skipSrcAddress // ignore: cast_nullable_to_non_nullable
as List<String>,skipDstAddress: null == skipDstAddress ? _self._skipDstAddress : skipDstAddress // ignore: cast_nullable_to_non_nullable
as List<String>,skipDomain: null == skipDomain ? _self._skipDomain : skipDomain // ignore: cast_nullable_to_non_nullable
as List<String>,port: null == port ? _self._port : port // ignore: cast_nullable_to_non_nullable
as List<String>,forceDnsMapping: null == forceDnsMapping ? _self.forceDnsMapping : forceDnsMapping // ignore: cast_nullable_to_non_nullable
as bool,parsePureIp: null == parsePureIp ? _self.parsePureIp : parsePureIp // ignore: cast_nullable_to_non_nullable
as bool,sniff: null == sniff ? _self._sniff : sniff // ignore: cast_nullable_to_non_nullable
as Map<String, SnifferConfig>,
  ));
}


}


/// @nodoc
mixin _$SnifferConfig {

@JsonKey(fromJson: _formJsonPorts) List<String> get ports;@JsonKey(name: 'override-destination') bool? get overrideDest;
/// Create a copy of SnifferConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnifferConfigCopyWith<SnifferConfig> get copyWith => _$SnifferConfigCopyWithImpl<SnifferConfig>(this as SnifferConfig, _$identity);

  /// Serializes this SnifferConfig to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnifferConfig&&const DeepCollectionEquality().equals(other.ports, ports)&&(identical(other.overrideDest, overrideDest) || other.overrideDest == overrideDest));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(ports),overrideDest);

@override
String toString() {
  return 'SnifferConfig(ports: $ports, overrideDest: $overrideDest)';
}


}

/// @nodoc
abstract mixin class $SnifferConfigCopyWith<$Res>  {
  factory $SnifferConfigCopyWith(SnifferConfig value, $Res Function(SnifferConfig) _then) = _$SnifferConfigCopyWithImpl;
@useResult
$Res call({
@JsonKey(fromJson: _formJsonPorts) List<String> ports,@JsonKey(name: 'override-destination') bool? overrideDest
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
  return _then(_self.copyWith(
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(fromJson: _formJsonPorts)  List<String> ports, @JsonKey(name: 'override-destination')  bool? overrideDest)?  $default,{required TResult orElse(),}) {final _that = this;
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(fromJson: _formJsonPorts)  List<String> ports, @JsonKey(name: 'override-destination')  bool? overrideDest)  $default,) {final _that = this;
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(fromJson: _formJsonPorts)  List<String> ports, @JsonKey(name: 'override-destination')  bool? overrideDest)?  $default,) {final _that = this;
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
  const _SnifferConfig({@JsonKey(fromJson: _formJsonPorts) final  List<String> ports = const [], @JsonKey(name: 'override-destination') this.overrideDest}): _ports = ports;
  factory _SnifferConfig.fromJson(Map<String, dynamic> json) => _$SnifferConfigFromJson(json);

 final  List<String> _ports;
@override@JsonKey(fromJson: _formJsonPorts) List<String> get ports {
  if (_ports is EqualUnmodifiableListView) return _ports;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_ports);
}

@override@JsonKey(name: 'override-destination') final  bool? overrideDest;

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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnifferConfig&&const DeepCollectionEquality().equals(other._ports, _ports)&&(identical(other.overrideDest, overrideDest) || other.overrideDest == overrideDest));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_ports),overrideDest);

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
@JsonKey(fromJson: _formJsonPorts) List<String> ports,@JsonKey(name: 'override-destination') bool? overrideDest
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

 bool get enable; String get device;@JsonKey(name: 'auto-route') bool get autoRoute; TunStack get stack;@JsonKey(name: 'dns-hijack') List<String> get dnsHijack;@JsonKey(name: 'route-address') List<String> get routeAddress;
/// Create a copy of Tun
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TunCopyWith<Tun> get copyWith => _$TunCopyWithImpl<Tun>(this as Tun, _$identity);

  /// Serializes this Tun to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Tun&&(identical(other.enable, enable) || other.enable == enable)&&(identical(other.device, device) || other.device == device)&&(identical(other.autoRoute, autoRoute) || other.autoRoute == autoRoute)&&(identical(other.stack, stack) || other.stack == stack)&&const DeepCollectionEquality().equals(other.dnsHijack, dnsHijack)&&const DeepCollectionEquality().equals(other.routeAddress, routeAddress));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,enable,device,autoRoute,stack,const DeepCollectionEquality().hash(dnsHijack),const DeepCollectionEquality().hash(routeAddress));

@override
String toString() {
  return 'Tun(enable: $enable, device: $device, autoRoute: $autoRoute, stack: $stack, dnsHijack: $dnsHijack, routeAddress: $routeAddress)';
}


}

/// @nodoc
abstract mixin class $TunCopyWith<$Res>  {
  factory $TunCopyWith(Tun value, $Res Function(Tun) _then) = _$TunCopyWithImpl;
@useResult
$Res call({
 bool enable, String device,@JsonKey(name: 'auto-route') bool autoRoute, TunStack stack,@JsonKey(name: 'dns-hijack') List<String> dnsHijack,@JsonKey(name: 'route-address') List<String> routeAddress
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
@pragma('vm:prefer-inline') @override $Res call({Object? enable = null,Object? device = null,Object? autoRoute = null,Object? stack = null,Object? dnsHijack = null,Object? routeAddress = null,}) {
  return _then(_self.copyWith(
enable: null == enable ? _self.enable : enable // ignore: cast_nullable_to_non_nullable
as bool,device: null == device ? _self.device : device // ignore: cast_nullable_to_non_nullable
as String,autoRoute: null == autoRoute ? _self.autoRoute : autoRoute // ignore: cast_nullable_to_non_nullable
as bool,stack: null == stack ? _self.stack : stack // ignore: cast_nullable_to_non_nullable
as TunStack,dnsHijack: null == dnsHijack ? _self.dnsHijack : dnsHijack // ignore: cast_nullable_to_non_nullable
as List<String>,routeAddress: null == routeAddress ? _self.routeAddress : routeAddress // ignore: cast_nullable_to_non_nullable
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool enable,  String device, @JsonKey(name: 'auto-route')  bool autoRoute,  TunStack stack, @JsonKey(name: 'dns-hijack')  List<String> dnsHijack, @JsonKey(name: 'route-address')  List<String> routeAddress)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Tun() when $default != null:
return $default(_that.enable,_that.device,_that.autoRoute,_that.stack,_that.dnsHijack,_that.routeAddress);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool enable,  String device, @JsonKey(name: 'auto-route')  bool autoRoute,  TunStack stack, @JsonKey(name: 'dns-hijack')  List<String> dnsHijack, @JsonKey(name: 'route-address')  List<String> routeAddress)  $default,) {final _that = this;
switch (_that) {
case _Tun():
return $default(_that.enable,_that.device,_that.autoRoute,_that.stack,_that.dnsHijack,_that.routeAddress);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool enable,  String device, @JsonKey(name: 'auto-route')  bool autoRoute,  TunStack stack, @JsonKey(name: 'dns-hijack')  List<String> dnsHijack, @JsonKey(name: 'route-address')  List<String> routeAddress)?  $default,) {final _that = this;
switch (_that) {
case _Tun() when $default != null:
return $default(_that.enable,_that.device,_that.autoRoute,_that.stack,_that.dnsHijack,_that.routeAddress);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Tun implements Tun {
  const _Tun({this.enable = false, this.device = appName, @JsonKey(name: 'auto-route') this.autoRoute = false, this.stack = TunStack.mixed, @JsonKey(name: 'dns-hijack') final  List<String> dnsHijack = const ['any:53'], @JsonKey(name: 'route-address') final  List<String> routeAddress = const []}): _dnsHijack = dnsHijack,_routeAddress = routeAddress;
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Tun&&(identical(other.enable, enable) || other.enable == enable)&&(identical(other.device, device) || other.device == device)&&(identical(other.autoRoute, autoRoute) || other.autoRoute == autoRoute)&&(identical(other.stack, stack) || other.stack == stack)&&const DeepCollectionEquality().equals(other._dnsHijack, _dnsHijack)&&const DeepCollectionEquality().equals(other._routeAddress, _routeAddress));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,enable,device,autoRoute,stack,const DeepCollectionEquality().hash(_dnsHijack),const DeepCollectionEquality().hash(_routeAddress));

@override
String toString() {
  return 'Tun(enable: $enable, device: $device, autoRoute: $autoRoute, stack: $stack, dnsHijack: $dnsHijack, routeAddress: $routeAddress)';
}


}

/// @nodoc
abstract mixin class _$TunCopyWith<$Res> implements $TunCopyWith<$Res> {
  factory _$TunCopyWith(_Tun value, $Res Function(_Tun) _then) = __$TunCopyWithImpl;
@override @useResult
$Res call({
 bool enable, String device,@JsonKey(name: 'auto-route') bool autoRoute, TunStack stack,@JsonKey(name: 'dns-hijack') List<String> dnsHijack,@JsonKey(name: 'route-address') List<String> routeAddress
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
@override @pragma('vm:prefer-inline') $Res call({Object? enable = null,Object? device = null,Object? autoRoute = null,Object? stack = null,Object? dnsHijack = null,Object? routeAddress = null,}) {
  return _then(_Tun(
enable: null == enable ? _self.enable : enable // ignore: cast_nullable_to_non_nullable
as bool,device: null == device ? _self.device : device // ignore: cast_nullable_to_non_nullable
as String,autoRoute: null == autoRoute ? _self.autoRoute : autoRoute // ignore: cast_nullable_to_non_nullable
as bool,stack: null == stack ? _self.stack : stack // ignore: cast_nullable_to_non_nullable
as TunStack,dnsHijack: null == dnsHijack ? _self._dnsHijack : dnsHijack // ignore: cast_nullable_to_non_nullable
as List<String>,routeAddress: null == routeAddress ? _self._routeAddress : routeAddress // ignore: cast_nullable_to_non_nullable
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FallbackFilter&&(identical(other.geoip, geoip) || other.geoip == geoip)&&(identical(other.geoipCode, geoipCode) || other.geoipCode == geoipCode)&&const DeepCollectionEquality().equals(other.geosite, geosite)&&const DeepCollectionEquality().equals(other.ipcidr, ipcidr)&&const DeepCollectionEquality().equals(other.domain, domain));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,geoip,geoipCode,const DeepCollectionEquality().hash(geosite),const DeepCollectionEquality().hash(ipcidr),const DeepCollectionEquality().hash(domain));

@override
String toString() {
  return 'FallbackFilter(geoip: $geoip, geoipCode: $geoipCode, geosite: $geosite, ipcidr: $ipcidr, domain: $domain)';
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
  return _then(_self.copyWith(
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
  const _FallbackFilter({this.geoip = true, @JsonKey(name: 'geoip-code') this.geoipCode = 'CN', final  List<String> geosite = const [], final  List<String> ipcidr = const ['240.0.0.0/4'], final  List<String> domain = const ['+.google.com', '+.facebook.com', '+.youtube.com']}): _geosite = geosite,_ipcidr = ipcidr,_domain = domain;
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FallbackFilter&&(identical(other.geoip, geoip) || other.geoip == geoip)&&(identical(other.geoipCode, geoipCode) || other.geoipCode == geoipCode)&&const DeepCollectionEquality().equals(other._geosite, _geosite)&&const DeepCollectionEquality().equals(other._ipcidr, _ipcidr)&&const DeepCollectionEquality().equals(other._domain, _domain));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,geoip,geoipCode,const DeepCollectionEquality().hash(_geosite),const DeepCollectionEquality().hash(_ipcidr),const DeepCollectionEquality().hash(_domain));

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

 bool get enable; String get listen;@JsonKey(name: 'prefer-h3') bool get preferH3;@JsonKey(name: 'use-hosts') bool get useHosts;@JsonKey(name: 'use-system-hosts') bool get useSystemHosts;@JsonKey(name: 'respect-rules') bool get respectRules; bool get ipv6;@JsonKey(name: 'default-nameserver') List<String> get defaultNameserver;@JsonKey(name: 'enhanced-mode') DnsMode get enhancedMode;@JsonKey(name: 'fake-ip-range') String get fakeIpRange;@JsonKey(name: 'fake-ip-filter') List<String> get fakeIpFilter;@JsonKey(name: 'nameserver-policy') Map<String, String> get nameserverPolicy; List<String> get nameserver; List<String> get fallback;@JsonKey(name: 'proxy-server-nameserver') List<String> get proxyServerNameserver;@JsonKey(name: 'fallback-filter') FallbackFilter get fallbackFilter;
/// Create a copy of Dns
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DnsCopyWith<Dns> get copyWith => _$DnsCopyWithImpl<Dns>(this as Dns, _$identity);

  /// Serializes this Dns to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Dns&&(identical(other.enable, enable) || other.enable == enable)&&(identical(other.listen, listen) || other.listen == listen)&&(identical(other.preferH3, preferH3) || other.preferH3 == preferH3)&&(identical(other.useHosts, useHosts) || other.useHosts == useHosts)&&(identical(other.useSystemHosts, useSystemHosts) || other.useSystemHosts == useSystemHosts)&&(identical(other.respectRules, respectRules) || other.respectRules == respectRules)&&(identical(other.ipv6, ipv6) || other.ipv6 == ipv6)&&const DeepCollectionEquality().equals(other.defaultNameserver, defaultNameserver)&&(identical(other.enhancedMode, enhancedMode) || other.enhancedMode == enhancedMode)&&(identical(other.fakeIpRange, fakeIpRange) || other.fakeIpRange == fakeIpRange)&&const DeepCollectionEquality().equals(other.fakeIpFilter, fakeIpFilter)&&const DeepCollectionEquality().equals(other.nameserverPolicy, nameserverPolicy)&&const DeepCollectionEquality().equals(other.nameserver, nameserver)&&const DeepCollectionEquality().equals(other.fallback, fallback)&&const DeepCollectionEquality().equals(other.proxyServerNameserver, proxyServerNameserver)&&(identical(other.fallbackFilter, fallbackFilter) || other.fallbackFilter == fallbackFilter));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,enable,listen,preferH3,useHosts,useSystemHosts,respectRules,ipv6,const DeepCollectionEquality().hash(defaultNameserver),enhancedMode,fakeIpRange,const DeepCollectionEquality().hash(fakeIpFilter),const DeepCollectionEquality().hash(nameserverPolicy),const DeepCollectionEquality().hash(nameserver),const DeepCollectionEquality().hash(fallback),const DeepCollectionEquality().hash(proxyServerNameserver),fallbackFilter);

@override
String toString() {
  return 'Dns(enable: $enable, listen: $listen, preferH3: $preferH3, useHosts: $useHosts, useSystemHosts: $useSystemHosts, respectRules: $respectRules, ipv6: $ipv6, defaultNameserver: $defaultNameserver, enhancedMode: $enhancedMode, fakeIpRange: $fakeIpRange, fakeIpFilter: $fakeIpFilter, nameserverPolicy: $nameserverPolicy, nameserver: $nameserver, fallback: $fallback, proxyServerNameserver: $proxyServerNameserver, fallbackFilter: $fallbackFilter)';
}


}

/// @nodoc
abstract mixin class $DnsCopyWith<$Res>  {
  factory $DnsCopyWith(Dns value, $Res Function(Dns) _then) = _$DnsCopyWithImpl;
@useResult
$Res call({
 bool enable, String listen,@JsonKey(name: 'prefer-h3') bool preferH3,@JsonKey(name: 'use-hosts') bool useHosts,@JsonKey(name: 'use-system-hosts') bool useSystemHosts,@JsonKey(name: 'respect-rules') bool respectRules, bool ipv6,@JsonKey(name: 'default-nameserver') List<String> defaultNameserver,@JsonKey(name: 'enhanced-mode') DnsMode enhancedMode,@JsonKey(name: 'fake-ip-range') String fakeIpRange,@JsonKey(name: 'fake-ip-filter') List<String> fakeIpFilter,@JsonKey(name: 'nameserver-policy') Map<String, String> nameserverPolicy, List<String> nameserver, List<String> fallback,@JsonKey(name: 'proxy-server-nameserver') List<String> proxyServerNameserver,@JsonKey(name: 'fallback-filter') FallbackFilter fallbackFilter
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
@pragma('vm:prefer-inline') @override $Res call({Object? enable = null,Object? listen = null,Object? preferH3 = null,Object? useHosts = null,Object? useSystemHosts = null,Object? respectRules = null,Object? ipv6 = null,Object? defaultNameserver = null,Object? enhancedMode = null,Object? fakeIpRange = null,Object? fakeIpFilter = null,Object? nameserverPolicy = null,Object? nameserver = null,Object? fallback = null,Object? proxyServerNameserver = null,Object? fallbackFilter = null,}) {
  return _then(_self.copyWith(
enable: null == enable ? _self.enable : enable // ignore: cast_nullable_to_non_nullable
as bool,listen: null == listen ? _self.listen : listen // ignore: cast_nullable_to_non_nullable
as String,preferH3: null == preferH3 ? _self.preferH3 : preferH3 // ignore: cast_nullable_to_non_nullable
as bool,useHosts: null == useHosts ? _self.useHosts : useHosts // ignore: cast_nullable_to_non_nullable
as bool,useSystemHosts: null == useSystemHosts ? _self.useSystemHosts : useSystemHosts // ignore: cast_nullable_to_non_nullable
as bool,respectRules: null == respectRules ? _self.respectRules : respectRules // ignore: cast_nullable_to_non_nullable
as bool,ipv6: null == ipv6 ? _self.ipv6 : ipv6 // ignore: cast_nullable_to_non_nullable
as bool,defaultNameserver: null == defaultNameserver ? _self.defaultNameserver : defaultNameserver // ignore: cast_nullable_to_non_nullable
as List<String>,enhancedMode: null == enhancedMode ? _self.enhancedMode : enhancedMode // ignore: cast_nullable_to_non_nullable
as DnsMode,fakeIpRange: null == fakeIpRange ? _self.fakeIpRange : fakeIpRange // ignore: cast_nullable_to_non_nullable
as String,fakeIpFilter: null == fakeIpFilter ? _self.fakeIpFilter : fakeIpFilter // ignore: cast_nullable_to_non_nullable
as List<String>,nameserverPolicy: null == nameserverPolicy ? _self.nameserverPolicy : nameserverPolicy // ignore: cast_nullable_to_non_nullable
as Map<String, String>,nameserver: null == nameserver ? _self.nameserver : nameserver // ignore: cast_nullable_to_non_nullable
as List<String>,fallback: null == fallback ? _self.fallback : fallback // ignore: cast_nullable_to_non_nullable
as List<String>,proxyServerNameserver: null == proxyServerNameserver ? _self.proxyServerNameserver : proxyServerNameserver // ignore: cast_nullable_to_non_nullable
as List<String>,fallbackFilter: null == fallbackFilter ? _self.fallbackFilter : fallbackFilter // ignore: cast_nullable_to_non_nullable
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool enable,  String listen, @JsonKey(name: 'prefer-h3')  bool preferH3, @JsonKey(name: 'use-hosts')  bool useHosts, @JsonKey(name: 'use-system-hosts')  bool useSystemHosts, @JsonKey(name: 'respect-rules')  bool respectRules,  bool ipv6, @JsonKey(name: 'default-nameserver')  List<String> defaultNameserver, @JsonKey(name: 'enhanced-mode')  DnsMode enhancedMode, @JsonKey(name: 'fake-ip-range')  String fakeIpRange, @JsonKey(name: 'fake-ip-filter')  List<String> fakeIpFilter, @JsonKey(name: 'nameserver-policy')  Map<String, String> nameserverPolicy,  List<String> nameserver,  List<String> fallback, @JsonKey(name: 'proxy-server-nameserver')  List<String> proxyServerNameserver, @JsonKey(name: 'fallback-filter')  FallbackFilter fallbackFilter)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Dns() when $default != null:
return $default(_that.enable,_that.listen,_that.preferH3,_that.useHosts,_that.useSystemHosts,_that.respectRules,_that.ipv6,_that.defaultNameserver,_that.enhancedMode,_that.fakeIpRange,_that.fakeIpFilter,_that.nameserverPolicy,_that.nameserver,_that.fallback,_that.proxyServerNameserver,_that.fallbackFilter);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool enable,  String listen, @JsonKey(name: 'prefer-h3')  bool preferH3, @JsonKey(name: 'use-hosts')  bool useHosts, @JsonKey(name: 'use-system-hosts')  bool useSystemHosts, @JsonKey(name: 'respect-rules')  bool respectRules,  bool ipv6, @JsonKey(name: 'default-nameserver')  List<String> defaultNameserver, @JsonKey(name: 'enhanced-mode')  DnsMode enhancedMode, @JsonKey(name: 'fake-ip-range')  String fakeIpRange, @JsonKey(name: 'fake-ip-filter')  List<String> fakeIpFilter, @JsonKey(name: 'nameserver-policy')  Map<String, String> nameserverPolicy,  List<String> nameserver,  List<String> fallback, @JsonKey(name: 'proxy-server-nameserver')  List<String> proxyServerNameserver, @JsonKey(name: 'fallback-filter')  FallbackFilter fallbackFilter)  $default,) {final _that = this;
switch (_that) {
case _Dns():
return $default(_that.enable,_that.listen,_that.preferH3,_that.useHosts,_that.useSystemHosts,_that.respectRules,_that.ipv6,_that.defaultNameserver,_that.enhancedMode,_that.fakeIpRange,_that.fakeIpFilter,_that.nameserverPolicy,_that.nameserver,_that.fallback,_that.proxyServerNameserver,_that.fallbackFilter);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool enable,  String listen, @JsonKey(name: 'prefer-h3')  bool preferH3, @JsonKey(name: 'use-hosts')  bool useHosts, @JsonKey(name: 'use-system-hosts')  bool useSystemHosts, @JsonKey(name: 'respect-rules')  bool respectRules,  bool ipv6, @JsonKey(name: 'default-nameserver')  List<String> defaultNameserver, @JsonKey(name: 'enhanced-mode')  DnsMode enhancedMode, @JsonKey(name: 'fake-ip-range')  String fakeIpRange, @JsonKey(name: 'fake-ip-filter')  List<String> fakeIpFilter, @JsonKey(name: 'nameserver-policy')  Map<String, String> nameserverPolicy,  List<String> nameserver,  List<String> fallback, @JsonKey(name: 'proxy-server-nameserver')  List<String> proxyServerNameserver, @JsonKey(name: 'fallback-filter')  FallbackFilter fallbackFilter)?  $default,) {final _that = this;
switch (_that) {
case _Dns() when $default != null:
return $default(_that.enable,_that.listen,_that.preferH3,_that.useHosts,_that.useSystemHosts,_that.respectRules,_that.ipv6,_that.defaultNameserver,_that.enhancedMode,_that.fakeIpRange,_that.fakeIpFilter,_that.nameserverPolicy,_that.nameserver,_that.fallback,_that.proxyServerNameserver,_that.fallbackFilter);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Dns implements Dns {
  const _Dns({this.enable = true, this.listen = '0.0.0.0:1053', @JsonKey(name: 'prefer-h3') this.preferH3 = false, @JsonKey(name: 'use-hosts') this.useHosts = true, @JsonKey(name: 'use-system-hosts') this.useSystemHosts = true, @JsonKey(name: 'respect-rules') this.respectRules = false, this.ipv6 = false, @JsonKey(name: 'default-nameserver') final  List<String> defaultNameserver = const ['223.5.5.5'], @JsonKey(name: 'enhanced-mode') this.enhancedMode = DnsMode.fakeIp, @JsonKey(name: 'fake-ip-range') this.fakeIpRange = '198.18.0.1/16', @JsonKey(name: 'fake-ip-filter') final  List<String> fakeIpFilter = const ['*.lan', 'localhost.ptlogin2.qq.com'], @JsonKey(name: 'nameserver-policy') final  Map<String, String> nameserverPolicy = const {'www.baidu.com' : '114.114.114.114', '+.internal.crop.com' : '10.0.0.1', 'geosite:cn' : 'https://doh.pub/dns-query'}, final  List<String> nameserver = const ['https://doh.pub/dns-query', 'https://dns.alidns.com/dns-query'], final  List<String> fallback = const ['tls://8.8.4.4', 'tls://1.1.1.1'], @JsonKey(name: 'proxy-server-nameserver') final  List<String> proxyServerNameserver = const ['https://doh.pub/dns-query'], @JsonKey(name: 'fallback-filter') this.fallbackFilter = const FallbackFilter()}): _defaultNameserver = defaultNameserver,_fakeIpFilter = fakeIpFilter,_nameserverPolicy = nameserverPolicy,_nameserver = nameserver,_fallback = fallback,_proxyServerNameserver = proxyServerNameserver;
  factory _Dns.fromJson(Map<String, dynamic> json) => _$DnsFromJson(json);

@override@JsonKey() final  bool enable;
@override@JsonKey() final  String listen;
@override@JsonKey(name: 'prefer-h3') final  bool preferH3;
@override@JsonKey(name: 'use-hosts') final  bool useHosts;
@override@JsonKey(name: 'use-system-hosts') final  bool useSystemHosts;
@override@JsonKey(name: 'respect-rules') final  bool respectRules;
@override@JsonKey() final  bool ipv6;
 final  List<String> _defaultNameserver;
@override@JsonKey(name: 'default-nameserver') List<String> get defaultNameserver {
  if (_defaultNameserver is EqualUnmodifiableListView) return _defaultNameserver;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_defaultNameserver);
}

@override@JsonKey(name: 'enhanced-mode') final  DnsMode enhancedMode;
@override@JsonKey(name: 'fake-ip-range') final  String fakeIpRange;
 final  List<String> _fakeIpFilter;
@override@JsonKey(name: 'fake-ip-filter') List<String> get fakeIpFilter {
  if (_fakeIpFilter is EqualUnmodifiableListView) return _fakeIpFilter;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_fakeIpFilter);
}

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

 final  List<String> _proxyServerNameserver;
@override@JsonKey(name: 'proxy-server-nameserver') List<String> get proxyServerNameserver {
  if (_proxyServerNameserver is EqualUnmodifiableListView) return _proxyServerNameserver;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_proxyServerNameserver);
}

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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Dns&&(identical(other.enable, enable) || other.enable == enable)&&(identical(other.listen, listen) || other.listen == listen)&&(identical(other.preferH3, preferH3) || other.preferH3 == preferH3)&&(identical(other.useHosts, useHosts) || other.useHosts == useHosts)&&(identical(other.useSystemHosts, useSystemHosts) || other.useSystemHosts == useSystemHosts)&&(identical(other.respectRules, respectRules) || other.respectRules == respectRules)&&(identical(other.ipv6, ipv6) || other.ipv6 == ipv6)&&const DeepCollectionEquality().equals(other._defaultNameserver, _defaultNameserver)&&(identical(other.enhancedMode, enhancedMode) || other.enhancedMode == enhancedMode)&&(identical(other.fakeIpRange, fakeIpRange) || other.fakeIpRange == fakeIpRange)&&const DeepCollectionEquality().equals(other._fakeIpFilter, _fakeIpFilter)&&const DeepCollectionEquality().equals(other._nameserverPolicy, _nameserverPolicy)&&const DeepCollectionEquality().equals(other._nameserver, _nameserver)&&const DeepCollectionEquality().equals(other._fallback, _fallback)&&const DeepCollectionEquality().equals(other._proxyServerNameserver, _proxyServerNameserver)&&(identical(other.fallbackFilter, fallbackFilter) || other.fallbackFilter == fallbackFilter));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,enable,listen,preferH3,useHosts,useSystemHosts,respectRules,ipv6,const DeepCollectionEquality().hash(_defaultNameserver),enhancedMode,fakeIpRange,const DeepCollectionEquality().hash(_fakeIpFilter),const DeepCollectionEquality().hash(_nameserverPolicy),const DeepCollectionEquality().hash(_nameserver),const DeepCollectionEquality().hash(_fallback),const DeepCollectionEquality().hash(_proxyServerNameserver),fallbackFilter);

@override
String toString() {
  return 'Dns(enable: $enable, listen: $listen, preferH3: $preferH3, useHosts: $useHosts, useSystemHosts: $useSystemHosts, respectRules: $respectRules, ipv6: $ipv6, defaultNameserver: $defaultNameserver, enhancedMode: $enhancedMode, fakeIpRange: $fakeIpRange, fakeIpFilter: $fakeIpFilter, nameserverPolicy: $nameserverPolicy, nameserver: $nameserver, fallback: $fallback, proxyServerNameserver: $proxyServerNameserver, fallbackFilter: $fallbackFilter)';
}


}

/// @nodoc
abstract mixin class _$DnsCopyWith<$Res> implements $DnsCopyWith<$Res> {
  factory _$DnsCopyWith(_Dns value, $Res Function(_Dns) _then) = __$DnsCopyWithImpl;
@override @useResult
$Res call({
 bool enable, String listen,@JsonKey(name: 'prefer-h3') bool preferH3,@JsonKey(name: 'use-hosts') bool useHosts,@JsonKey(name: 'use-system-hosts') bool useSystemHosts,@JsonKey(name: 'respect-rules') bool respectRules, bool ipv6,@JsonKey(name: 'default-nameserver') List<String> defaultNameserver,@JsonKey(name: 'enhanced-mode') DnsMode enhancedMode,@JsonKey(name: 'fake-ip-range') String fakeIpRange,@JsonKey(name: 'fake-ip-filter') List<String> fakeIpFilter,@JsonKey(name: 'nameserver-policy') Map<String, String> nameserverPolicy, List<String> nameserver, List<String> fallback,@JsonKey(name: 'proxy-server-nameserver') List<String> proxyServerNameserver,@JsonKey(name: 'fallback-filter') FallbackFilter fallbackFilter
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
@override @pragma('vm:prefer-inline') $Res call({Object? enable = null,Object? listen = null,Object? preferH3 = null,Object? useHosts = null,Object? useSystemHosts = null,Object? respectRules = null,Object? ipv6 = null,Object? defaultNameserver = null,Object? enhancedMode = null,Object? fakeIpRange = null,Object? fakeIpFilter = null,Object? nameserverPolicy = null,Object? nameserver = null,Object? fallback = null,Object? proxyServerNameserver = null,Object? fallbackFilter = null,}) {
  return _then(_Dns(
enable: null == enable ? _self.enable : enable // ignore: cast_nullable_to_non_nullable
as bool,listen: null == listen ? _self.listen : listen // ignore: cast_nullable_to_non_nullable
as String,preferH3: null == preferH3 ? _self.preferH3 : preferH3 // ignore: cast_nullable_to_non_nullable
as bool,useHosts: null == useHosts ? _self.useHosts : useHosts // ignore: cast_nullable_to_non_nullable
as bool,useSystemHosts: null == useSystemHosts ? _self.useSystemHosts : useSystemHosts // ignore: cast_nullable_to_non_nullable
as bool,respectRules: null == respectRules ? _self.respectRules : respectRules // ignore: cast_nullable_to_non_nullable
as bool,ipv6: null == ipv6 ? _self.ipv6 : ipv6 // ignore: cast_nullable_to_non_nullable
as bool,defaultNameserver: null == defaultNameserver ? _self._defaultNameserver : defaultNameserver // ignore: cast_nullable_to_non_nullable
as List<String>,enhancedMode: null == enhancedMode ? _self.enhancedMode : enhancedMode // ignore: cast_nullable_to_non_nullable
as DnsMode,fakeIpRange: null == fakeIpRange ? _self.fakeIpRange : fakeIpRange // ignore: cast_nullable_to_non_nullable
as String,fakeIpFilter: null == fakeIpFilter ? _self._fakeIpFilter : fakeIpFilter // ignore: cast_nullable_to_non_nullable
as List<String>,nameserverPolicy: null == nameserverPolicy ? _self._nameserverPolicy : nameserverPolicy // ignore: cast_nullable_to_non_nullable
as Map<String, String>,nameserver: null == nameserver ? _self._nameserver : nameserver // ignore: cast_nullable_to_non_nullable
as List<String>,fallback: null == fallback ? _self._fallback : fallback // ignore: cast_nullable_to_non_nullable
as List<String>,proxyServerNameserver: null == proxyServerNameserver ? _self._proxyServerNameserver : proxyServerNameserver // ignore: cast_nullable_to_non_nullable
as List<String>,fallbackFilter: null == fallbackFilter ? _self.fallbackFilter : fallbackFilter // ignore: cast_nullable_to_non_nullable
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
mixin _$Rule {

 int get id; RuleAction get ruleAction; String? get content; String? get ruleTarget; String? get ruleProvider; String? get subRule; bool get noResolve; bool get src; String? get order;
/// Create a copy of Rule
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RuleCopyWith<Rule> get copyWith => _$RuleCopyWithImpl<Rule>(this as Rule, _$identity);

  /// Serializes this Rule to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Rule&&(identical(other.id, id) || other.id == id)&&(identical(other.ruleAction, ruleAction) || other.ruleAction == ruleAction)&&(identical(other.content, content) || other.content == content)&&(identical(other.ruleTarget, ruleTarget) || other.ruleTarget == ruleTarget)&&(identical(other.ruleProvider, ruleProvider) || other.ruleProvider == ruleProvider)&&(identical(other.subRule, subRule) || other.subRule == subRule)&&(identical(other.noResolve, noResolve) || other.noResolve == noResolve)&&(identical(other.src, src) || other.src == src)&&(identical(other.order, order) || other.order == order));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,ruleAction,content,ruleTarget,ruleProvider,subRule,noResolve,src,order);

@override
String toString() {
  return 'Rule(id: $id, ruleAction: $ruleAction, content: $content, ruleTarget: $ruleTarget, ruleProvider: $ruleProvider, subRule: $subRule, noResolve: $noResolve, src: $src, order: $order)';
}


}

/// @nodoc
abstract mixin class $RuleCopyWith<$Res>  {
  factory $RuleCopyWith(Rule value, $Res Function(Rule) _then) = _$RuleCopyWithImpl;
@useResult
$Res call({
 int id, RuleAction ruleAction, String? content, String? ruleTarget, String? ruleProvider, String? subRule, bool noResolve, bool src, String? order
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
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? ruleAction = null,Object? content = freezed,Object? ruleTarget = freezed,Object? ruleProvider = freezed,Object? subRule = freezed,Object? noResolve = null,Object? src = null,Object? order = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,ruleAction: null == ruleAction ? _self.ruleAction : ruleAction // ignore: cast_nullable_to_non_nullable
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  RuleAction ruleAction,  String? content,  String? ruleTarget,  String? ruleProvider,  String? subRule,  bool noResolve,  bool src,  String? order)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Rule() when $default != null:
return $default(_that.id,_that.ruleAction,_that.content,_that.ruleTarget,_that.ruleProvider,_that.subRule,_that.noResolve,_that.src,_that.order);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  RuleAction ruleAction,  String? content,  String? ruleTarget,  String? ruleProvider,  String? subRule,  bool noResolve,  bool src,  String? order)  $default,) {final _that = this;
switch (_that) {
case _Rule():
return $default(_that.id,_that.ruleAction,_that.content,_that.ruleTarget,_that.ruleProvider,_that.subRule,_that.noResolve,_that.src,_that.order);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  RuleAction ruleAction,  String? content,  String? ruleTarget,  String? ruleProvider,  String? subRule,  bool noResolve,  bool src,  String? order)?  $default,) {final _that = this;
switch (_that) {
case _Rule() when $default != null:
return $default(_that.id,_that.ruleAction,_that.content,_that.ruleTarget,_that.ruleProvider,_that.subRule,_that.noResolve,_that.src,_that.order);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Rule implements Rule {
  const _Rule({this.id = -1, this.ruleAction = RuleAction.DOMAIN, this.content, this.ruleTarget, this.ruleProvider, this.subRule, this.noResolve = false, this.src = false, this.order});
  factory _Rule.fromJson(Map<String, dynamic> json) => _$RuleFromJson(json);

@override@JsonKey() final  int id;
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Rule&&(identical(other.id, id) || other.id == id)&&(identical(other.ruleAction, ruleAction) || other.ruleAction == ruleAction)&&(identical(other.content, content) || other.content == content)&&(identical(other.ruleTarget, ruleTarget) || other.ruleTarget == ruleTarget)&&(identical(other.ruleProvider, ruleProvider) || other.ruleProvider == ruleProvider)&&(identical(other.subRule, subRule) || other.subRule == subRule)&&(identical(other.noResolve, noResolve) || other.noResolve == noResolve)&&(identical(other.src, src) || other.src == src)&&(identical(other.order, order) || other.order == order));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,ruleAction,content,ruleTarget,ruleProvider,subRule,noResolve,src,order);

@override
String toString() {
  return 'Rule(id: $id, ruleAction: $ruleAction, content: $content, ruleTarget: $ruleTarget, ruleProvider: $ruleProvider, subRule: $subRule, noResolve: $noResolve, src: $src, order: $order)';
}


}

/// @nodoc
abstract mixin class _$RuleCopyWith<$Res> implements $RuleCopyWith<$Res> {
  factory _$RuleCopyWith(_Rule value, $Res Function(_Rule) _then) = __$RuleCopyWithImpl;
@override @useResult
$Res call({
 int id, RuleAction ruleAction, String? content, String? ruleTarget, String? ruleProvider, String? subRule, bool noResolve, bool src, String? order
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
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? ruleAction = null,Object? content = freezed,Object? ruleTarget = freezed,Object? ruleProvider = freezed,Object? subRule = freezed,Object? noResolve = null,Object? src = null,Object? order = freezed,}) {
  return _then(_Rule(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,ruleAction: null == ruleAction ? _self.ruleAction : ruleAction // ignore: cast_nullable_to_non_nullable
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClashConfig&&const DeepCollectionEquality().equals(other.proxyGroups, proxyGroups)&&const DeepCollectionEquality().equals(other.rules, rules)&&const DeepCollectionEquality().equals(other.proxies, proxies)&&const DeepCollectionEquality().equals(other.proxyProviders, proxyProviders)&&const DeepCollectionEquality().equals(other.ruleProviders, ruleProviders)&&const DeepCollectionEquality().equals(other.subRules, subRules)&&const DeepCollectionEquality().equals(other.proxyTypeMap, proxyTypeMap));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(proxyGroups),const DeepCollectionEquality().hash(rules),const DeepCollectionEquality().hash(proxies),const DeepCollectionEquality().hash(proxyProviders),const DeepCollectionEquality().hash(ruleProviders),const DeepCollectionEquality().hash(subRules),const DeepCollectionEquality().hash(proxyTypeMap));

@override
String toString() {
  return 'ClashConfig(proxyGroups: $proxyGroups, rules: $rules, proxies: $proxies, proxyProviders: $proxyProviders, ruleProviders: $ruleProviders, subRules: $subRules, proxyTypeMap: $proxyTypeMap)';
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
  return _then(_self.copyWith(
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
  const _ClashConfig({@JsonKey(name: 'proxy-groups') final  List<ProxyGroup> proxyGroups = const [], @JsonKey(fromJson: _genRules) final  List<Rule> rules = const [], final  List<Proxy> proxies = const [], @JsonKey(name: 'proxy-providers', fromJson: _genList) final  List<String> proxyProviders = const [], @JsonKey(name: 'rule-providers', fromJson: _genList) final  List<String> ruleProviders = const [], @JsonKey(name: 'sub-rules', fromJson: _genList) final  List<String> subRules = const [], final  Map<String, String> proxyTypeMap = const {}}): _proxyGroups = proxyGroups,_rules = rules,_proxies = proxies,_proxyProviders = proxyProviders,_ruleProviders = ruleProviders,_subRules = subRules,_proxyTypeMap = proxyTypeMap;
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ClashConfig&&const DeepCollectionEquality().equals(other._proxyGroups, _proxyGroups)&&const DeepCollectionEquality().equals(other._rules, _rules)&&const DeepCollectionEquality().equals(other._proxies, _proxies)&&const DeepCollectionEquality().equals(other._proxyProviders, _proxyProviders)&&const DeepCollectionEquality().equals(other._ruleProviders, _ruleProviders)&&const DeepCollectionEquality().equals(other._subRules, _subRules)&&const DeepCollectionEquality().equals(other._proxyTypeMap, _proxyTypeMap));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_proxyGroups),const DeepCollectionEquality().hash(_rules),const DeepCollectionEquality().hash(_proxies),const DeepCollectionEquality().hash(_proxyProviders),const DeepCollectionEquality().hash(_ruleProviders),const DeepCollectionEquality().hash(_subRules),const DeepCollectionEquality().hash(_proxyTypeMap));

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

@JsonKey(name: 'mixed-port') int get mixedPort;@JsonKey(name: 'socks-port') int get socksPort;@JsonKey(name: 'port') int get port;@JsonKey(name: 'redir-port') int get redirPort;@JsonKey(name: 'tproxy-port') int get tproxyPort; Mode get mode;@JsonKey(name: 'allow-lan') bool get allowLan;@JsonKey(name: 'log-level') LogLevel get logLevel; bool get ipv6;@JsonKey(name: 'find-process-mode', unknownEnumValue: FindProcessMode.always) FindProcessMode get findProcessMode;@JsonKey(name: 'keep-alive-interval') int get keepAliveInterval;@JsonKey(name: 'unified-delay') bool get unifiedDelay;@JsonKey(name: 'tcp-concurrent') bool get tcpConcurrent;@JsonKey(fromJson: Tun.safeFormJson) Tun get tun;@JsonKey(fromJson: Dns.safeDnsFromJson) Dns get dns;@JsonKey(name: 'geox-url', fromJson: _geoXUrlFromJson, toJson: _geoXUrlToJson) Map<GeoResource, String> get geoXUrl;@JsonKey(name: 'geodata-loader') GeodataLoader get geodataLoader;@JsonKey(name: 'global-ua') String? get globalUa;@JsonKey(name: 'external-controller') ExternalControllerStatus get externalController; Map<String, String> get hosts;@JsonKey(name: 'geo-auto-update') bool get geoAutoUpdate;@JsonKey(name: 'geo-update-interval') int get geoUpdateInterval;
/// Create a copy of PatchClashConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PatchClashConfigCopyWith<PatchClashConfig> get copyWith => _$PatchClashConfigCopyWithImpl<PatchClashConfig>(this as PatchClashConfig, _$identity);

  /// Serializes this PatchClashConfig to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PatchClashConfig&&(identical(other.mixedPort, mixedPort) || other.mixedPort == mixedPort)&&(identical(other.socksPort, socksPort) || other.socksPort == socksPort)&&(identical(other.port, port) || other.port == port)&&(identical(other.redirPort, redirPort) || other.redirPort == redirPort)&&(identical(other.tproxyPort, tproxyPort) || other.tproxyPort == tproxyPort)&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.allowLan, allowLan) || other.allowLan == allowLan)&&(identical(other.logLevel, logLevel) || other.logLevel == logLevel)&&(identical(other.ipv6, ipv6) || other.ipv6 == ipv6)&&(identical(other.findProcessMode, findProcessMode) || other.findProcessMode == findProcessMode)&&(identical(other.keepAliveInterval, keepAliveInterval) || other.keepAliveInterval == keepAliveInterval)&&(identical(other.unifiedDelay, unifiedDelay) || other.unifiedDelay == unifiedDelay)&&(identical(other.tcpConcurrent, tcpConcurrent) || other.tcpConcurrent == tcpConcurrent)&&(identical(other.tun, tun) || other.tun == tun)&&(identical(other.dns, dns) || other.dns == dns)&&const DeepCollectionEquality().equals(other.geoXUrl, geoXUrl)&&(identical(other.geodataLoader, geodataLoader) || other.geodataLoader == geodataLoader)&&(identical(other.globalUa, globalUa) || other.globalUa == globalUa)&&(identical(other.externalController, externalController) || other.externalController == externalController)&&const DeepCollectionEquality().equals(other.hosts, hosts)&&(identical(other.geoAutoUpdate, geoAutoUpdate) || other.geoAutoUpdate == geoAutoUpdate)&&(identical(other.geoUpdateInterval, geoUpdateInterval) || other.geoUpdateInterval == geoUpdateInterval));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,mixedPort,socksPort,port,redirPort,tproxyPort,mode,allowLan,logLevel,ipv6,findProcessMode,keepAliveInterval,unifiedDelay,tcpConcurrent,tun,dns,const DeepCollectionEquality().hash(geoXUrl),geodataLoader,globalUa,externalController,const DeepCollectionEquality().hash(hosts),geoAutoUpdate,geoUpdateInterval]);

@override
String toString() {
  return 'PatchClashConfig(mixedPort: $mixedPort, socksPort: $socksPort, port: $port, redirPort: $redirPort, tproxyPort: $tproxyPort, mode: $mode, allowLan: $allowLan, logLevel: $logLevel, ipv6: $ipv6, findProcessMode: $findProcessMode, keepAliveInterval: $keepAliveInterval, unifiedDelay: $unifiedDelay, tcpConcurrent: $tcpConcurrent, tun: $tun, dns: $dns, geoXUrl: $geoXUrl, geodataLoader: $geodataLoader, globalUa: $globalUa, externalController: $externalController, hosts: $hosts, geoAutoUpdate: $geoAutoUpdate, geoUpdateInterval: $geoUpdateInterval)';
}


}

/// @nodoc
abstract mixin class $PatchClashConfigCopyWith<$Res>  {
  factory $PatchClashConfigCopyWith(PatchClashConfig value, $Res Function(PatchClashConfig) _then) = _$PatchClashConfigCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'mixed-port') int mixedPort,@JsonKey(name: 'socks-port') int socksPort,@JsonKey(name: 'port') int port,@JsonKey(name: 'redir-port') int redirPort,@JsonKey(name: 'tproxy-port') int tproxyPort, Mode mode,@JsonKey(name: 'allow-lan') bool allowLan,@JsonKey(name: 'log-level') LogLevel logLevel, bool ipv6,@JsonKey(name: 'find-process-mode', unknownEnumValue: FindProcessMode.always) FindProcessMode findProcessMode,@JsonKey(name: 'keep-alive-interval') int keepAliveInterval,@JsonKey(name: 'unified-delay') bool unifiedDelay,@JsonKey(name: 'tcp-concurrent') bool tcpConcurrent,@JsonKey(fromJson: Tun.safeFormJson) Tun tun,@JsonKey(fromJson: Dns.safeDnsFromJson) Dns dns,@JsonKey(name: 'geox-url', fromJson: _geoXUrlFromJson, toJson: _geoXUrlToJson) Map<GeoResource, String> geoXUrl,@JsonKey(name: 'geodata-loader') GeodataLoader geodataLoader,@JsonKey(name: 'global-ua') String? globalUa,@JsonKey(name: 'external-controller') ExternalControllerStatus externalController, Map<String, String> hosts,@JsonKey(name: 'geo-auto-update') bool geoAutoUpdate,@JsonKey(name: 'geo-update-interval') int geoUpdateInterval
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
@pragma('vm:prefer-inline') @override $Res call({Object? mixedPort = null,Object? socksPort = null,Object? port = null,Object? redirPort = null,Object? tproxyPort = null,Object? mode = null,Object? allowLan = null,Object? logLevel = null,Object? ipv6 = null,Object? findProcessMode = null,Object? keepAliveInterval = null,Object? unifiedDelay = null,Object? tcpConcurrent = null,Object? tun = null,Object? dns = null,Object? geoXUrl = null,Object? geodataLoader = null,Object? globalUa = freezed,Object? externalController = null,Object? hosts = null,Object? geoAutoUpdate = null,Object? geoUpdateInterval = null,}) {
  return _then(_self.copyWith(
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
as FindProcessMode,keepAliveInterval: null == keepAliveInterval ? _self.keepAliveInterval : keepAliveInterval // ignore: cast_nullable_to_non_nullable
as int,unifiedDelay: null == unifiedDelay ? _self.unifiedDelay : unifiedDelay // ignore: cast_nullable_to_non_nullable
as bool,tcpConcurrent: null == tcpConcurrent ? _self.tcpConcurrent : tcpConcurrent // ignore: cast_nullable_to_non_nullable
as bool,tun: null == tun ? _self.tun : tun // ignore: cast_nullable_to_non_nullable
as Tun,dns: null == dns ? _self.dns : dns // ignore: cast_nullable_to_non_nullable
as Dns,geoXUrl: null == geoXUrl ? _self.geoXUrl : geoXUrl // ignore: cast_nullable_to_non_nullable
as Map<GeoResource, String>,geodataLoader: null == geodataLoader ? _self.geodataLoader : geodataLoader // ignore: cast_nullable_to_non_nullable
as GeodataLoader,globalUa: freezed == globalUa ? _self.globalUa : globalUa // ignore: cast_nullable_to_non_nullable
as String?,externalController: null == externalController ? _self.externalController : externalController // ignore: cast_nullable_to_non_nullable
as ExternalControllerStatus,hosts: null == hosts ? _self.hosts : hosts // ignore: cast_nullable_to_non_nullable
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'mixed-port')  int mixedPort, @JsonKey(name: 'socks-port')  int socksPort, @JsonKey(name: 'port')  int port, @JsonKey(name: 'redir-port')  int redirPort, @JsonKey(name: 'tproxy-port')  int tproxyPort,  Mode mode, @JsonKey(name: 'allow-lan')  bool allowLan, @JsonKey(name: 'log-level')  LogLevel logLevel,  bool ipv6, @JsonKey(name: 'find-process-mode', unknownEnumValue: FindProcessMode.always)  FindProcessMode findProcessMode, @JsonKey(name: 'keep-alive-interval')  int keepAliveInterval, @JsonKey(name: 'unified-delay')  bool unifiedDelay, @JsonKey(name: 'tcp-concurrent')  bool tcpConcurrent, @JsonKey(fromJson: Tun.safeFormJson)  Tun tun, @JsonKey(fromJson: Dns.safeDnsFromJson)  Dns dns, @JsonKey(name: 'geox-url', fromJson: _geoXUrlFromJson, toJson: _geoXUrlToJson)  Map<GeoResource, String> geoXUrl, @JsonKey(name: 'geodata-loader')  GeodataLoader geodataLoader, @JsonKey(name: 'global-ua')  String? globalUa, @JsonKey(name: 'external-controller')  ExternalControllerStatus externalController,  Map<String, String> hosts, @JsonKey(name: 'geo-auto-update')  bool geoAutoUpdate, @JsonKey(name: 'geo-update-interval')  int geoUpdateInterval)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PatchClashConfig() when $default != null:
return $default(_that.mixedPort,_that.socksPort,_that.port,_that.redirPort,_that.tproxyPort,_that.mode,_that.allowLan,_that.logLevel,_that.ipv6,_that.findProcessMode,_that.keepAliveInterval,_that.unifiedDelay,_that.tcpConcurrent,_that.tun,_that.dns,_that.geoXUrl,_that.geodataLoader,_that.globalUa,_that.externalController,_that.hosts,_that.geoAutoUpdate,_that.geoUpdateInterval);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'mixed-port')  int mixedPort, @JsonKey(name: 'socks-port')  int socksPort, @JsonKey(name: 'port')  int port, @JsonKey(name: 'redir-port')  int redirPort, @JsonKey(name: 'tproxy-port')  int tproxyPort,  Mode mode, @JsonKey(name: 'allow-lan')  bool allowLan, @JsonKey(name: 'log-level')  LogLevel logLevel,  bool ipv6, @JsonKey(name: 'find-process-mode', unknownEnumValue: FindProcessMode.always)  FindProcessMode findProcessMode, @JsonKey(name: 'keep-alive-interval')  int keepAliveInterval, @JsonKey(name: 'unified-delay')  bool unifiedDelay, @JsonKey(name: 'tcp-concurrent')  bool tcpConcurrent, @JsonKey(fromJson: Tun.safeFormJson)  Tun tun, @JsonKey(fromJson: Dns.safeDnsFromJson)  Dns dns, @JsonKey(name: 'geox-url', fromJson: _geoXUrlFromJson, toJson: _geoXUrlToJson)  Map<GeoResource, String> geoXUrl, @JsonKey(name: 'geodata-loader')  GeodataLoader geodataLoader, @JsonKey(name: 'global-ua')  String? globalUa, @JsonKey(name: 'external-controller')  ExternalControllerStatus externalController,  Map<String, String> hosts, @JsonKey(name: 'geo-auto-update')  bool geoAutoUpdate, @JsonKey(name: 'geo-update-interval')  int geoUpdateInterval)  $default,) {final _that = this;
switch (_that) {
case _PatchClashConfig():
return $default(_that.mixedPort,_that.socksPort,_that.port,_that.redirPort,_that.tproxyPort,_that.mode,_that.allowLan,_that.logLevel,_that.ipv6,_that.findProcessMode,_that.keepAliveInterval,_that.unifiedDelay,_that.tcpConcurrent,_that.tun,_that.dns,_that.geoXUrl,_that.geodataLoader,_that.globalUa,_that.externalController,_that.hosts,_that.geoAutoUpdate,_that.geoUpdateInterval);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'mixed-port')  int mixedPort, @JsonKey(name: 'socks-port')  int socksPort, @JsonKey(name: 'port')  int port, @JsonKey(name: 'redir-port')  int redirPort, @JsonKey(name: 'tproxy-port')  int tproxyPort,  Mode mode, @JsonKey(name: 'allow-lan')  bool allowLan, @JsonKey(name: 'log-level')  LogLevel logLevel,  bool ipv6, @JsonKey(name: 'find-process-mode', unknownEnumValue: FindProcessMode.always)  FindProcessMode findProcessMode, @JsonKey(name: 'keep-alive-interval')  int keepAliveInterval, @JsonKey(name: 'unified-delay')  bool unifiedDelay, @JsonKey(name: 'tcp-concurrent')  bool tcpConcurrent, @JsonKey(fromJson: Tun.safeFormJson)  Tun tun, @JsonKey(fromJson: Dns.safeDnsFromJson)  Dns dns, @JsonKey(name: 'geox-url', fromJson: _geoXUrlFromJson, toJson: _geoXUrlToJson)  Map<GeoResource, String> geoXUrl, @JsonKey(name: 'geodata-loader')  GeodataLoader geodataLoader, @JsonKey(name: 'global-ua')  String? globalUa, @JsonKey(name: 'external-controller')  ExternalControllerStatus externalController,  Map<String, String> hosts, @JsonKey(name: 'geo-auto-update')  bool geoAutoUpdate, @JsonKey(name: 'geo-update-interval')  int geoUpdateInterval)?  $default,) {final _that = this;
switch (_that) {
case _PatchClashConfig() when $default != null:
return $default(_that.mixedPort,_that.socksPort,_that.port,_that.redirPort,_that.tproxyPort,_that.mode,_that.allowLan,_that.logLevel,_that.ipv6,_that.findProcessMode,_that.keepAliveInterval,_that.unifiedDelay,_that.tcpConcurrent,_that.tun,_that.dns,_that.geoXUrl,_that.geodataLoader,_that.globalUa,_that.externalController,_that.hosts,_that.geoAutoUpdate,_that.geoUpdateInterval);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PatchClashConfig implements PatchClashConfig {
  const _PatchClashConfig({@JsonKey(name: 'mixed-port') this.mixedPort = defaultMixedPort, @JsonKey(name: 'socks-port') this.socksPort = 0, @JsonKey(name: 'port') this.port = 0, @JsonKey(name: 'redir-port') this.redirPort = 0, @JsonKey(name: 'tproxy-port') this.tproxyPort = 0, this.mode = Mode.rule, @JsonKey(name: 'allow-lan') this.allowLan = false, @JsonKey(name: 'log-level') this.logLevel = LogLevel.error, this.ipv6 = false, @JsonKey(name: 'find-process-mode', unknownEnumValue: FindProcessMode.always) this.findProcessMode = FindProcessMode.always, @JsonKey(name: 'keep-alive-interval') this.keepAliveInterval = defaultKeepAliveInterval, @JsonKey(name: 'unified-delay') this.unifiedDelay = true, @JsonKey(name: 'tcp-concurrent') this.tcpConcurrent = true, @JsonKey(fromJson: Tun.safeFormJson) this.tun = defaultTun, @JsonKey(fromJson: Dns.safeDnsFromJson) this.dns = defaultDns, @JsonKey(name: 'geox-url', fromJson: _geoXUrlFromJson, toJson: _geoXUrlToJson) final  Map<GeoResource, String> geoXUrl = defaultGeoXUrl, @JsonKey(name: 'geodata-loader') this.geodataLoader = GeodataLoader.memconservative, @JsonKey(name: 'global-ua') this.globalUa, @JsonKey(name: 'external-controller') this.externalController = ExternalControllerStatus.close, final  Map<String, String> hosts = const {}, @JsonKey(name: 'geo-auto-update') this.geoAutoUpdate = false, @JsonKey(name: 'geo-update-interval') this.geoUpdateInterval = 24}): _geoXUrl = geoXUrl,_hosts = hosts;
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
@override@JsonKey(name: 'find-process-mode', unknownEnumValue: FindProcessMode.always) final  FindProcessMode findProcessMode;
@override@JsonKey(name: 'keep-alive-interval') final  int keepAliveInterval;
@override@JsonKey(name: 'unified-delay') final  bool unifiedDelay;
@override@JsonKey(name: 'tcp-concurrent') final  bool tcpConcurrent;
@override@JsonKey(fromJson: Tun.safeFormJson) final  Tun tun;
@override@JsonKey(fromJson: Dns.safeDnsFromJson) final  Dns dns;
 final  Map<GeoResource, String> _geoXUrl;
@override@JsonKey(name: 'geox-url', fromJson: _geoXUrlFromJson, toJson: _geoXUrlToJson) Map<GeoResource, String> get geoXUrl {
  if (_geoXUrl is EqualUnmodifiableMapView) return _geoXUrl;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_geoXUrl);
}

@override@JsonKey(name: 'geodata-loader') final  GeodataLoader geodataLoader;
@override@JsonKey(name: 'global-ua') final  String? globalUa;
@override@JsonKey(name: 'external-controller') final  ExternalControllerStatus externalController;
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PatchClashConfig&&(identical(other.mixedPort, mixedPort) || other.mixedPort == mixedPort)&&(identical(other.socksPort, socksPort) || other.socksPort == socksPort)&&(identical(other.port, port) || other.port == port)&&(identical(other.redirPort, redirPort) || other.redirPort == redirPort)&&(identical(other.tproxyPort, tproxyPort) || other.tproxyPort == tproxyPort)&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.allowLan, allowLan) || other.allowLan == allowLan)&&(identical(other.logLevel, logLevel) || other.logLevel == logLevel)&&(identical(other.ipv6, ipv6) || other.ipv6 == ipv6)&&(identical(other.findProcessMode, findProcessMode) || other.findProcessMode == findProcessMode)&&(identical(other.keepAliveInterval, keepAliveInterval) || other.keepAliveInterval == keepAliveInterval)&&(identical(other.unifiedDelay, unifiedDelay) || other.unifiedDelay == unifiedDelay)&&(identical(other.tcpConcurrent, tcpConcurrent) || other.tcpConcurrent == tcpConcurrent)&&(identical(other.tun, tun) || other.tun == tun)&&(identical(other.dns, dns) || other.dns == dns)&&const DeepCollectionEquality().equals(other._geoXUrl, _geoXUrl)&&(identical(other.geodataLoader, geodataLoader) || other.geodataLoader == geodataLoader)&&(identical(other.globalUa, globalUa) || other.globalUa == globalUa)&&(identical(other.externalController, externalController) || other.externalController == externalController)&&const DeepCollectionEquality().equals(other._hosts, _hosts)&&(identical(other.geoAutoUpdate, geoAutoUpdate) || other.geoAutoUpdate == geoAutoUpdate)&&(identical(other.geoUpdateInterval, geoUpdateInterval) || other.geoUpdateInterval == geoUpdateInterval));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,mixedPort,socksPort,port,redirPort,tproxyPort,mode,allowLan,logLevel,ipv6,findProcessMode,keepAliveInterval,unifiedDelay,tcpConcurrent,tun,dns,const DeepCollectionEquality().hash(_geoXUrl),geodataLoader,globalUa,externalController,const DeepCollectionEquality().hash(_hosts),geoAutoUpdate,geoUpdateInterval]);

@override
String toString() {
  return 'PatchClashConfig(mixedPort: $mixedPort, socksPort: $socksPort, port: $port, redirPort: $redirPort, tproxyPort: $tproxyPort, mode: $mode, allowLan: $allowLan, logLevel: $logLevel, ipv6: $ipv6, findProcessMode: $findProcessMode, keepAliveInterval: $keepAliveInterval, unifiedDelay: $unifiedDelay, tcpConcurrent: $tcpConcurrent, tun: $tun, dns: $dns, geoXUrl: $geoXUrl, geodataLoader: $geodataLoader, globalUa: $globalUa, externalController: $externalController, hosts: $hosts, geoAutoUpdate: $geoAutoUpdate, geoUpdateInterval: $geoUpdateInterval)';
}


}

/// @nodoc
abstract mixin class _$PatchClashConfigCopyWith<$Res> implements $PatchClashConfigCopyWith<$Res> {
  factory _$PatchClashConfigCopyWith(_PatchClashConfig value, $Res Function(_PatchClashConfig) _then) = __$PatchClashConfigCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'mixed-port') int mixedPort,@JsonKey(name: 'socks-port') int socksPort,@JsonKey(name: 'port') int port,@JsonKey(name: 'redir-port') int redirPort,@JsonKey(name: 'tproxy-port') int tproxyPort, Mode mode,@JsonKey(name: 'allow-lan') bool allowLan,@JsonKey(name: 'log-level') LogLevel logLevel, bool ipv6,@JsonKey(name: 'find-process-mode', unknownEnumValue: FindProcessMode.always) FindProcessMode findProcessMode,@JsonKey(name: 'keep-alive-interval') int keepAliveInterval,@JsonKey(name: 'unified-delay') bool unifiedDelay,@JsonKey(name: 'tcp-concurrent') bool tcpConcurrent,@JsonKey(fromJson: Tun.safeFormJson) Tun tun,@JsonKey(fromJson: Dns.safeDnsFromJson) Dns dns,@JsonKey(name: 'geox-url', fromJson: _geoXUrlFromJson, toJson: _geoXUrlToJson) Map<GeoResource, String> geoXUrl,@JsonKey(name: 'geodata-loader') GeodataLoader geodataLoader,@JsonKey(name: 'global-ua') String? globalUa,@JsonKey(name: 'external-controller') ExternalControllerStatus externalController, Map<String, String> hosts,@JsonKey(name: 'geo-auto-update') bool geoAutoUpdate,@JsonKey(name: 'geo-update-interval') int geoUpdateInterval
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
@override @pragma('vm:prefer-inline') $Res call({Object? mixedPort = null,Object? socksPort = null,Object? port = null,Object? redirPort = null,Object? tproxyPort = null,Object? mode = null,Object? allowLan = null,Object? logLevel = null,Object? ipv6 = null,Object? findProcessMode = null,Object? keepAliveInterval = null,Object? unifiedDelay = null,Object? tcpConcurrent = null,Object? tun = null,Object? dns = null,Object? geoXUrl = null,Object? geodataLoader = null,Object? globalUa = freezed,Object? externalController = null,Object? hosts = null,Object? geoAutoUpdate = null,Object? geoUpdateInterval = null,}) {
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
as FindProcessMode,keepAliveInterval: null == keepAliveInterval ? _self.keepAliveInterval : keepAliveInterval // ignore: cast_nullable_to_non_nullable
as int,unifiedDelay: null == unifiedDelay ? _self.unifiedDelay : unifiedDelay // ignore: cast_nullable_to_non_nullable
as bool,tcpConcurrent: null == tcpConcurrent ? _self.tcpConcurrent : tcpConcurrent // ignore: cast_nullable_to_non_nullable
as bool,tun: null == tun ? _self.tun : tun // ignore: cast_nullable_to_non_nullable
as Tun,dns: null == dns ? _self.dns : dns // ignore: cast_nullable_to_non_nullable
as Dns,geoXUrl: null == geoXUrl ? _self._geoXUrl : geoXUrl // ignore: cast_nullable_to_non_nullable
as Map<GeoResource, String>,geodataLoader: null == geodataLoader ? _self.geodataLoader : geodataLoader // ignore: cast_nullable_to_non_nullable
as GeodataLoader,globalUa: freezed == globalUa ? _self.globalUa : globalUa // ignore: cast_nullable_to_non_nullable
as String?,externalController: null == externalController ? _self.externalController : externalController // ignore: cast_nullable_to_non_nullable
as ExternalControllerStatus,hosts: null == hosts ? _self._hosts : hosts // ignore: cast_nullable_to_non_nullable
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
