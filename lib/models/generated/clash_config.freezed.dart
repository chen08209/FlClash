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

 String get name;@JsonKey(fromJson: GroupType.parseProfileType) GroupType get type; List<String>? get proxies; List<String>? get use; int? get interval; bool? get lazy; String? get url; int? get timeout;@JsonKey(name: 'max-failed-times') int? get maxFailedTimes; String? get filter;@JsonKey(name: 'expected-filter') String? get excludeFilter;@JsonKey(name: 'exclude-type') String? get excludeType;@JsonKey(name: 'expected-status') dynamic get expectedStatus; bool? get hidden; String? get icon;
/// Create a copy of ProxyGroup
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProxyGroupCopyWith<ProxyGroup> get copyWith => _$ProxyGroupCopyWithImpl<ProxyGroup>(this as ProxyGroup, _$identity);

  /// Serializes this ProxyGroup to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProxyGroup&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&const DeepCollectionEquality().equals(other.proxies, proxies)&&const DeepCollectionEquality().equals(other.use, use)&&(identical(other.interval, interval) || other.interval == interval)&&(identical(other.lazy, lazy) || other.lazy == lazy)&&(identical(other.url, url) || other.url == url)&&(identical(other.timeout, timeout) || other.timeout == timeout)&&(identical(other.maxFailedTimes, maxFailedTimes) || other.maxFailedTimes == maxFailedTimes)&&(identical(other.filter, filter) || other.filter == filter)&&(identical(other.excludeFilter, excludeFilter) || other.excludeFilter == excludeFilter)&&(identical(other.excludeType, excludeType) || other.excludeType == excludeType)&&const DeepCollectionEquality().equals(other.expectedStatus, expectedStatus)&&(identical(other.hidden, hidden) || other.hidden == hidden)&&(identical(other.icon, icon) || other.icon == icon));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,type,const DeepCollectionEquality().hash(proxies),const DeepCollectionEquality().hash(use),interval,lazy,url,timeout,maxFailedTimes,filter,excludeFilter,excludeType,const DeepCollectionEquality().hash(expectedStatus),hidden,icon);

@override
String toString() {
  return 'ProxyGroup(name: $name, type: $type, proxies: $proxies, use: $use, interval: $interval, lazy: $lazy, url: $url, timeout: $timeout, maxFailedTimes: $maxFailedTimes, filter: $filter, excludeFilter: $excludeFilter, excludeType: $excludeType, expectedStatus: $expectedStatus, hidden: $hidden, icon: $icon)';
}


}

/// @nodoc
abstract mixin class $ProxyGroupCopyWith<$Res>  {
  factory $ProxyGroupCopyWith(ProxyGroup value, $Res Function(ProxyGroup) _then) = _$ProxyGroupCopyWithImpl;
@useResult
$Res call({
 String name,@JsonKey(fromJson: GroupType.parseProfileType) GroupType type, List<String>? proxies, List<String>? use, int? interval, bool? lazy, String? url, int? timeout,@JsonKey(name: 'max-failed-times') int? maxFailedTimes, String? filter,@JsonKey(name: 'expected-filter') String? excludeFilter,@JsonKey(name: 'exclude-type') String? excludeType,@JsonKey(name: 'expected-status') dynamic expectedStatus, bool? hidden, String? icon
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
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? type = null,Object? proxies = freezed,Object? use = freezed,Object? interval = freezed,Object? lazy = freezed,Object? url = freezed,Object? timeout = freezed,Object? maxFailedTimes = freezed,Object? filter = freezed,Object? excludeFilter = freezed,Object? excludeType = freezed,Object? expectedStatus = freezed,Object? hidden = freezed,Object? icon = freezed,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as GroupType,proxies: freezed == proxies ? _self.proxies : proxies // ignore: cast_nullable_to_non_nullable
as List<String>?,use: freezed == use ? _self.use : use // ignore: cast_nullable_to_non_nullable
as List<String>?,interval: freezed == interval ? _self.interval : interval // ignore: cast_nullable_to_non_nullable
as int?,lazy: freezed == lazy ? _self.lazy : lazy // ignore: cast_nullable_to_non_nullable
as bool?,url: freezed == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String?,timeout: freezed == timeout ? _self.timeout : timeout // ignore: cast_nullable_to_non_nullable
as int?,maxFailedTimes: freezed == maxFailedTimes ? _self.maxFailedTimes : maxFailedTimes // ignore: cast_nullable_to_non_nullable
as int?,filter: freezed == filter ? _self.filter : filter // ignore: cast_nullable_to_non_nullable
as String?,excludeFilter: freezed == excludeFilter ? _self.excludeFilter : excludeFilter // ignore: cast_nullable_to_non_nullable
as String?,excludeType: freezed == excludeType ? _self.excludeType : excludeType // ignore: cast_nullable_to_non_nullable
as String?,expectedStatus: freezed == expectedStatus ? _self.expectedStatus : expectedStatus // ignore: cast_nullable_to_non_nullable
as dynamic,hidden: freezed == hidden ? _self.hidden : hidden // ignore: cast_nullable_to_non_nullable
as bool?,icon: freezed == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name, @JsonKey(fromJson: GroupType.parseProfileType)  GroupType type,  List<String>? proxies,  List<String>? use,  int? interval,  bool? lazy,  String? url,  int? timeout, @JsonKey(name: 'max-failed-times')  int? maxFailedTimes,  String? filter, @JsonKey(name: 'expected-filter')  String? excludeFilter, @JsonKey(name: 'exclude-type')  String? excludeType, @JsonKey(name: 'expected-status')  dynamic expectedStatus,  bool? hidden,  String? icon)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProxyGroup() when $default != null:
return $default(_that.name,_that.type,_that.proxies,_that.use,_that.interval,_that.lazy,_that.url,_that.timeout,_that.maxFailedTimes,_that.filter,_that.excludeFilter,_that.excludeType,_that.expectedStatus,_that.hidden,_that.icon);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name, @JsonKey(fromJson: GroupType.parseProfileType)  GroupType type,  List<String>? proxies,  List<String>? use,  int? interval,  bool? lazy,  String? url,  int? timeout, @JsonKey(name: 'max-failed-times')  int? maxFailedTimes,  String? filter, @JsonKey(name: 'expected-filter')  String? excludeFilter, @JsonKey(name: 'exclude-type')  String? excludeType, @JsonKey(name: 'expected-status')  dynamic expectedStatus,  bool? hidden,  String? icon)  $default,) {final _that = this;
switch (_that) {
case _ProxyGroup():
return $default(_that.name,_that.type,_that.proxies,_that.use,_that.interval,_that.lazy,_that.url,_that.timeout,_that.maxFailedTimes,_that.filter,_that.excludeFilter,_that.excludeType,_that.expectedStatus,_that.hidden,_that.icon);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name, @JsonKey(fromJson: GroupType.parseProfileType)  GroupType type,  List<String>? proxies,  List<String>? use,  int? interval,  bool? lazy,  String? url,  int? timeout, @JsonKey(name: 'max-failed-times')  int? maxFailedTimes,  String? filter, @JsonKey(name: 'expected-filter')  String? excludeFilter, @JsonKey(name: 'exclude-type')  String? excludeType, @JsonKey(name: 'expected-status')  dynamic expectedStatus,  bool? hidden,  String? icon)?  $default,) {final _that = this;
switch (_that) {
case _ProxyGroup() when $default != null:
return $default(_that.name,_that.type,_that.proxies,_that.use,_that.interval,_that.lazy,_that.url,_that.timeout,_that.maxFailedTimes,_that.filter,_that.excludeFilter,_that.excludeType,_that.expectedStatus,_that.hidden,_that.icon);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProxyGroup implements ProxyGroup {
  const _ProxyGroup({required this.name, @JsonKey(fromJson: GroupType.parseProfileType) required this.type, final  List<String>? proxies, final  List<String>? use, this.interval, this.lazy, this.url, this.timeout, @JsonKey(name: 'max-failed-times') this.maxFailedTimes, this.filter, @JsonKey(name: 'expected-filter') this.excludeFilter, @JsonKey(name: 'exclude-type') this.excludeType, @JsonKey(name: 'expected-status') this.expectedStatus, this.hidden, this.icon}): _proxies = proxies,_use = use;
  factory _ProxyGroup.fromJson(Map<String, dynamic> json) => _$ProxyGroupFromJson(json);

@override final  String name;
@override@JsonKey(fromJson: GroupType.parseProfileType) final  GroupType type;
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
@override final  String? url;
@override final  int? timeout;
@override@JsonKey(name: 'max-failed-times') final  int? maxFailedTimes;
@override final  String? filter;
@override@JsonKey(name: 'expected-filter') final  String? excludeFilter;
@override@JsonKey(name: 'exclude-type') final  String? excludeType;
@override@JsonKey(name: 'expected-status') final  dynamic expectedStatus;
@override final  bool? hidden;
@override final  String? icon;

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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProxyGroup&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&const DeepCollectionEquality().equals(other._proxies, _proxies)&&const DeepCollectionEquality().equals(other._use, _use)&&(identical(other.interval, interval) || other.interval == interval)&&(identical(other.lazy, lazy) || other.lazy == lazy)&&(identical(other.url, url) || other.url == url)&&(identical(other.timeout, timeout) || other.timeout == timeout)&&(identical(other.maxFailedTimes, maxFailedTimes) || other.maxFailedTimes == maxFailedTimes)&&(identical(other.filter, filter) || other.filter == filter)&&(identical(other.excludeFilter, excludeFilter) || other.excludeFilter == excludeFilter)&&(identical(other.excludeType, excludeType) || other.excludeType == excludeType)&&const DeepCollectionEquality().equals(other.expectedStatus, expectedStatus)&&(identical(other.hidden, hidden) || other.hidden == hidden)&&(identical(other.icon, icon) || other.icon == icon));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,type,const DeepCollectionEquality().hash(_proxies),const DeepCollectionEquality().hash(_use),interval,lazy,url,timeout,maxFailedTimes,filter,excludeFilter,excludeType,const DeepCollectionEquality().hash(expectedStatus),hidden,icon);

@override
String toString() {
  return 'ProxyGroup(name: $name, type: $type, proxies: $proxies, use: $use, interval: $interval, lazy: $lazy, url: $url, timeout: $timeout, maxFailedTimes: $maxFailedTimes, filter: $filter, excludeFilter: $excludeFilter, excludeType: $excludeType, expectedStatus: $expectedStatus, hidden: $hidden, icon: $icon)';
}


}

/// @nodoc
abstract mixin class _$ProxyGroupCopyWith<$Res> implements $ProxyGroupCopyWith<$Res> {
  factory _$ProxyGroupCopyWith(_ProxyGroup value, $Res Function(_ProxyGroup) _then) = __$ProxyGroupCopyWithImpl;
@override @useResult
$Res call({
 String name,@JsonKey(fromJson: GroupType.parseProfileType) GroupType type, List<String>? proxies, List<String>? use, int? interval, bool? lazy, String? url, int? timeout,@JsonKey(name: 'max-failed-times') int? maxFailedTimes, String? filter,@JsonKey(name: 'expected-filter') String? excludeFilter,@JsonKey(name: 'exclude-type') String? excludeType,@JsonKey(name: 'expected-status') dynamic expectedStatus, bool? hidden, String? icon
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
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? type = null,Object? proxies = freezed,Object? use = freezed,Object? interval = freezed,Object? lazy = freezed,Object? url = freezed,Object? timeout = freezed,Object? maxFailedTimes = freezed,Object? filter = freezed,Object? excludeFilter = freezed,Object? excludeType = freezed,Object? expectedStatus = freezed,Object? hidden = freezed,Object? icon = freezed,}) {
  return _then(_ProxyGroup(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as GroupType,proxies: freezed == proxies ? _self._proxies : proxies // ignore: cast_nullable_to_non_nullable
as List<String>?,use: freezed == use ? _self._use : use // ignore: cast_nullable_to_non_nullable
as List<String>?,interval: freezed == interval ? _self.interval : interval // ignore: cast_nullable_to_non_nullable
as int?,lazy: freezed == lazy ? _self.lazy : lazy // ignore: cast_nullable_to_non_nullable
as bool?,url: freezed == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String?,timeout: freezed == timeout ? _self.timeout : timeout // ignore: cast_nullable_to_non_nullable
as int?,maxFailedTimes: freezed == maxFailedTimes ? _self.maxFailedTimes : maxFailedTimes // ignore: cast_nullable_to_non_nullable
as int?,filter: freezed == filter ? _self.filter : filter // ignore: cast_nullable_to_non_nullable
as String?,excludeFilter: freezed == excludeFilter ? _self.excludeFilter : excludeFilter // ignore: cast_nullable_to_non_nullable
as String?,excludeType: freezed == excludeType ? _self.excludeType : excludeType // ignore: cast_nullable_to_non_nullable
as String?,expectedStatus: freezed == expectedStatus ? _self.expectedStatus : expectedStatus // ignore: cast_nullable_to_non_nullable
as dynamic,hidden: freezed == hidden ? _self.hidden : hidden // ignore: cast_nullable_to_non_nullable
as bool?,icon: freezed == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String?,
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
  const _FallbackFilter({this.geoip = true, @JsonKey(name: 'geoip-code') this.geoipCode = 'CN', final  List<String> geosite = const ['gfw'], final  List<String> ipcidr = const ['240.0.0.0/4'], final  List<String> domain = const ['+.google.com', '+.facebook.com', '+.youtube.com']}): _geosite = geosite,_ipcidr = ipcidr,_domain = domain;
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
mixin _$GeoXUrl {

 String get mmdb; String get asn; String get geoip; String get geosite;
/// Create a copy of GeoXUrl
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GeoXUrlCopyWith<GeoXUrl> get copyWith => _$GeoXUrlCopyWithImpl<GeoXUrl>(this as GeoXUrl, _$identity);

  /// Serializes this GeoXUrl to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GeoXUrl&&(identical(other.mmdb, mmdb) || other.mmdb == mmdb)&&(identical(other.asn, asn) || other.asn == asn)&&(identical(other.geoip, geoip) || other.geoip == geoip)&&(identical(other.geosite, geosite) || other.geosite == geosite));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,mmdb,asn,geoip,geosite);

@override
String toString() {
  return 'GeoXUrl(mmdb: $mmdb, asn: $asn, geoip: $geoip, geosite: $geosite)';
}


}

/// @nodoc
abstract mixin class $GeoXUrlCopyWith<$Res>  {
  factory $GeoXUrlCopyWith(GeoXUrl value, $Res Function(GeoXUrl) _then) = _$GeoXUrlCopyWithImpl;
@useResult
$Res call({
 String mmdb, String asn, String geoip, String geosite
});




}
/// @nodoc
class _$GeoXUrlCopyWithImpl<$Res>
    implements $GeoXUrlCopyWith<$Res> {
  _$GeoXUrlCopyWithImpl(this._self, this._then);

  final GeoXUrl _self;
  final $Res Function(GeoXUrl) _then;

/// Create a copy of GeoXUrl
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? mmdb = null,Object? asn = null,Object? geoip = null,Object? geosite = null,}) {
  return _then(_self.copyWith(
mmdb: null == mmdb ? _self.mmdb : mmdb // ignore: cast_nullable_to_non_nullable
as String,asn: null == asn ? _self.asn : asn // ignore: cast_nullable_to_non_nullable
as String,geoip: null == geoip ? _self.geoip : geoip // ignore: cast_nullable_to_non_nullable
as String,geosite: null == geosite ? _self.geosite : geosite // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [GeoXUrl].
extension GeoXUrlPatterns on GeoXUrl {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GeoXUrl value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GeoXUrl() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GeoXUrl value)  $default,){
final _that = this;
switch (_that) {
case _GeoXUrl():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GeoXUrl value)?  $default,){
final _that = this;
switch (_that) {
case _GeoXUrl() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String mmdb,  String asn,  String geoip,  String geosite)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GeoXUrl() when $default != null:
return $default(_that.mmdb,_that.asn,_that.geoip,_that.geosite);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String mmdb,  String asn,  String geoip,  String geosite)  $default,) {final _that = this;
switch (_that) {
case _GeoXUrl():
return $default(_that.mmdb,_that.asn,_that.geoip,_that.geosite);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String mmdb,  String asn,  String geoip,  String geosite)?  $default,) {final _that = this;
switch (_that) {
case _GeoXUrl() when $default != null:
return $default(_that.mmdb,_that.asn,_that.geoip,_that.geosite);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GeoXUrl implements GeoXUrl {
  const _GeoXUrl({this.mmdb = 'https://github.com/MetaCubeX/meta-rules-dat/releases/download/latest/geoip.metadb', this.asn = 'https://github.com/MetaCubeX/meta-rules-dat/releases/download/latest/GeoLite2-ASN.mmdb', this.geoip = 'https://github.com/MetaCubeX/meta-rules-dat/releases/download/latest/geoip.dat', this.geosite = 'https://github.com/MetaCubeX/meta-rules-dat/releases/download/latest/geosite.dat'});
  factory _GeoXUrl.fromJson(Map<String, dynamic> json) => _$GeoXUrlFromJson(json);

@override@JsonKey() final  String mmdb;
@override@JsonKey() final  String asn;
@override@JsonKey() final  String geoip;
@override@JsonKey() final  String geosite;

/// Create a copy of GeoXUrl
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GeoXUrlCopyWith<_GeoXUrl> get copyWith => __$GeoXUrlCopyWithImpl<_GeoXUrl>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GeoXUrlToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GeoXUrl&&(identical(other.mmdb, mmdb) || other.mmdb == mmdb)&&(identical(other.asn, asn) || other.asn == asn)&&(identical(other.geoip, geoip) || other.geoip == geoip)&&(identical(other.geosite, geosite) || other.geosite == geosite));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,mmdb,asn,geoip,geosite);

@override
String toString() {
  return 'GeoXUrl(mmdb: $mmdb, asn: $asn, geoip: $geoip, geosite: $geosite)';
}


}

/// @nodoc
abstract mixin class _$GeoXUrlCopyWith<$Res> implements $GeoXUrlCopyWith<$Res> {
  factory _$GeoXUrlCopyWith(_GeoXUrl value, $Res Function(_GeoXUrl) _then) = __$GeoXUrlCopyWithImpl;
@override @useResult
$Res call({
 String mmdb, String asn, String geoip, String geosite
});




}
/// @nodoc
class __$GeoXUrlCopyWithImpl<$Res>
    implements _$GeoXUrlCopyWith<$Res> {
  __$GeoXUrlCopyWithImpl(this._self, this._then);

  final _GeoXUrl _self;
  final $Res Function(_GeoXUrl) _then;

/// Create a copy of GeoXUrl
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? mmdb = null,Object? asn = null,Object? geoip = null,Object? geosite = null,}) {
  return _then(_GeoXUrl(
mmdb: null == mmdb ? _self.mmdb : mmdb // ignore: cast_nullable_to_non_nullable
as String,asn: null == asn ? _self.asn : asn // ignore: cast_nullable_to_non_nullable
as String,geoip: null == geoip ? _self.geoip : geoip // ignore: cast_nullable_to_non_nullable
as String,geosite: null == geosite ? _self.geosite : geosite // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$ParsedRule {

 RuleAction get ruleAction; String? get content; String? get ruleTarget; String? get ruleProvider; String? get subRule; bool get noResolve; bool get src;
/// Create a copy of ParsedRule
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ParsedRuleCopyWith<ParsedRule> get copyWith => _$ParsedRuleCopyWithImpl<ParsedRule>(this as ParsedRule, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ParsedRule&&(identical(other.ruleAction, ruleAction) || other.ruleAction == ruleAction)&&(identical(other.content, content) || other.content == content)&&(identical(other.ruleTarget, ruleTarget) || other.ruleTarget == ruleTarget)&&(identical(other.ruleProvider, ruleProvider) || other.ruleProvider == ruleProvider)&&(identical(other.subRule, subRule) || other.subRule == subRule)&&(identical(other.noResolve, noResolve) || other.noResolve == noResolve)&&(identical(other.src, src) || other.src == src));
}


@override
int get hashCode => Object.hash(runtimeType,ruleAction,content,ruleTarget,ruleProvider,subRule,noResolve,src);

@override
String toString() {
  return 'ParsedRule(ruleAction: $ruleAction, content: $content, ruleTarget: $ruleTarget, ruleProvider: $ruleProvider, subRule: $subRule, noResolve: $noResolve, src: $src)';
}


}

/// @nodoc
abstract mixin class $ParsedRuleCopyWith<$Res>  {
  factory $ParsedRuleCopyWith(ParsedRule value, $Res Function(ParsedRule) _then) = _$ParsedRuleCopyWithImpl;
@useResult
$Res call({
 RuleAction ruleAction, String? content, String? ruleTarget, String? ruleProvider, String? subRule, bool noResolve, bool src
});




}
/// @nodoc
class _$ParsedRuleCopyWithImpl<$Res>
    implements $ParsedRuleCopyWith<$Res> {
  _$ParsedRuleCopyWithImpl(this._self, this._then);

  final ParsedRule _self;
  final $Res Function(ParsedRule) _then;

/// Create a copy of ParsedRule
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? ruleAction = null,Object? content = freezed,Object? ruleTarget = freezed,Object? ruleProvider = freezed,Object? subRule = freezed,Object? noResolve = null,Object? src = null,}) {
  return _then(_self.copyWith(
ruleAction: null == ruleAction ? _self.ruleAction : ruleAction // ignore: cast_nullable_to_non_nullable
as RuleAction,content: freezed == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String?,ruleTarget: freezed == ruleTarget ? _self.ruleTarget : ruleTarget // ignore: cast_nullable_to_non_nullable
as String?,ruleProvider: freezed == ruleProvider ? _self.ruleProvider : ruleProvider // ignore: cast_nullable_to_non_nullable
as String?,subRule: freezed == subRule ? _self.subRule : subRule // ignore: cast_nullable_to_non_nullable
as String?,noResolve: null == noResolve ? _self.noResolve : noResolve // ignore: cast_nullable_to_non_nullable
as bool,src: null == src ? _self.src : src // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [ParsedRule].
extension ParsedRulePatterns on ParsedRule {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ParsedRule value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ParsedRule() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ParsedRule value)  $default,){
final _that = this;
switch (_that) {
case _ParsedRule():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ParsedRule value)?  $default,){
final _that = this;
switch (_that) {
case _ParsedRule() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( RuleAction ruleAction,  String? content,  String? ruleTarget,  String? ruleProvider,  String? subRule,  bool noResolve,  bool src)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ParsedRule() when $default != null:
return $default(_that.ruleAction,_that.content,_that.ruleTarget,_that.ruleProvider,_that.subRule,_that.noResolve,_that.src);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( RuleAction ruleAction,  String? content,  String? ruleTarget,  String? ruleProvider,  String? subRule,  bool noResolve,  bool src)  $default,) {final _that = this;
switch (_that) {
case _ParsedRule():
return $default(_that.ruleAction,_that.content,_that.ruleTarget,_that.ruleProvider,_that.subRule,_that.noResolve,_that.src);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( RuleAction ruleAction,  String? content,  String? ruleTarget,  String? ruleProvider,  String? subRule,  bool noResolve,  bool src)?  $default,) {final _that = this;
switch (_that) {
case _ParsedRule() when $default != null:
return $default(_that.ruleAction,_that.content,_that.ruleTarget,_that.ruleProvider,_that.subRule,_that.noResolve,_that.src);case _:
  return null;

}
}

}

/// @nodoc


class _ParsedRule implements ParsedRule {
  const _ParsedRule({required this.ruleAction, this.content, this.ruleTarget, this.ruleProvider, this.subRule, this.noResolve = false, this.src = false});
  

@override final  RuleAction ruleAction;
@override final  String? content;
@override final  String? ruleTarget;
@override final  String? ruleProvider;
@override final  String? subRule;
@override@JsonKey() final  bool noResolve;
@override@JsonKey() final  bool src;

/// Create a copy of ParsedRule
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ParsedRuleCopyWith<_ParsedRule> get copyWith => __$ParsedRuleCopyWithImpl<_ParsedRule>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ParsedRule&&(identical(other.ruleAction, ruleAction) || other.ruleAction == ruleAction)&&(identical(other.content, content) || other.content == content)&&(identical(other.ruleTarget, ruleTarget) || other.ruleTarget == ruleTarget)&&(identical(other.ruleProvider, ruleProvider) || other.ruleProvider == ruleProvider)&&(identical(other.subRule, subRule) || other.subRule == subRule)&&(identical(other.noResolve, noResolve) || other.noResolve == noResolve)&&(identical(other.src, src) || other.src == src));
}


@override
int get hashCode => Object.hash(runtimeType,ruleAction,content,ruleTarget,ruleProvider,subRule,noResolve,src);

@override
String toString() {
  return 'ParsedRule(ruleAction: $ruleAction, content: $content, ruleTarget: $ruleTarget, ruleProvider: $ruleProvider, subRule: $subRule, noResolve: $noResolve, src: $src)';
}


}

/// @nodoc
abstract mixin class _$ParsedRuleCopyWith<$Res> implements $ParsedRuleCopyWith<$Res> {
  factory _$ParsedRuleCopyWith(_ParsedRule value, $Res Function(_ParsedRule) _then) = __$ParsedRuleCopyWithImpl;
@override @useResult
$Res call({
 RuleAction ruleAction, String? content, String? ruleTarget, String? ruleProvider, String? subRule, bool noResolve, bool src
});




}
/// @nodoc
class __$ParsedRuleCopyWithImpl<$Res>
    implements _$ParsedRuleCopyWith<$Res> {
  __$ParsedRuleCopyWithImpl(this._self, this._then);

  final _ParsedRule _self;
  final $Res Function(_ParsedRule) _then;

/// Create a copy of ParsedRule
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? ruleAction = null,Object? content = freezed,Object? ruleTarget = freezed,Object? ruleProvider = freezed,Object? subRule = freezed,Object? noResolve = null,Object? src = null,}) {
  return _then(_ParsedRule(
ruleAction: null == ruleAction ? _self.ruleAction : ruleAction // ignore: cast_nullable_to_non_nullable
as RuleAction,content: freezed == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String?,ruleTarget: freezed == ruleTarget ? _self.ruleTarget : ruleTarget // ignore: cast_nullable_to_non_nullable
as String?,ruleProvider: freezed == ruleProvider ? _self.ruleProvider : ruleProvider // ignore: cast_nullable_to_non_nullable
as String?,subRule: freezed == subRule ? _self.subRule : subRule // ignore: cast_nullable_to_non_nullable
as String?,noResolve: null == noResolve ? _self.noResolve : noResolve // ignore: cast_nullable_to_non_nullable
as bool,src: null == src ? _self.src : src // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$Rule {

 String get id; String get value;
/// Create a copy of Rule
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RuleCopyWith<Rule> get copyWith => _$RuleCopyWithImpl<Rule>(this as Rule, _$identity);

  /// Serializes this Rule to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Rule&&(identical(other.id, id) || other.id == id)&&(identical(other.value, value) || other.value == value));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,value);

@override
String toString() {
  return 'Rule(id: $id, value: $value)';
}


}

/// @nodoc
abstract mixin class $RuleCopyWith<$Res>  {
  factory $RuleCopyWith(Rule value, $Res Function(Rule) _then) = _$RuleCopyWithImpl;
@useResult
$Res call({
 String id, String value
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
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? value = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String value)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Rule() when $default != null:
return $default(_that.id,_that.value);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String value)  $default,) {final _that = this;
switch (_that) {
case _Rule():
return $default(_that.id,_that.value);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String value)?  $default,) {final _that = this;
switch (_that) {
case _Rule() when $default != null:
return $default(_that.id,_that.value);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Rule implements Rule {
  const _Rule({required this.id, required this.value});
  factory _Rule.fromJson(Map<String, dynamic> json) => _$RuleFromJson(json);

@override final  String id;
@override final  String value;

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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Rule&&(identical(other.id, id) || other.id == id)&&(identical(other.value, value) || other.value == value));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,value);

@override
String toString() {
  return 'Rule(id: $id, value: $value)';
}


}

/// @nodoc
abstract mixin class _$RuleCopyWith<$Res> implements $RuleCopyWith<$Res> {
  factory _$RuleCopyWith(_Rule value, $Res Function(_Rule) _then) = __$RuleCopyWithImpl;
@override @useResult
$Res call({
 String id, String value
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
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? value = null,}) {
  return _then(_Rule(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$SubRule {

 String get name;
/// Create a copy of SubRule
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SubRuleCopyWith<SubRule> get copyWith => _$SubRuleCopyWithImpl<SubRule>(this as SubRule, _$identity);

  /// Serializes this SubRule to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SubRule&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name);

@override
String toString() {
  return 'SubRule(name: $name)';
}


}

/// @nodoc
abstract mixin class $SubRuleCopyWith<$Res>  {
  factory $SubRuleCopyWith(SubRule value, $Res Function(SubRule) _then) = _$SubRuleCopyWithImpl;
@useResult
$Res call({
 String name
});




}
/// @nodoc
class _$SubRuleCopyWithImpl<$Res>
    implements $SubRuleCopyWith<$Res> {
  _$SubRuleCopyWithImpl(this._self, this._then);

  final SubRule _self;
  final $Res Function(SubRule) _then;

/// Create a copy of SubRule
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [SubRule].
extension SubRulePatterns on SubRule {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SubRule value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SubRule() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SubRule value)  $default,){
final _that = this;
switch (_that) {
case _SubRule():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SubRule value)?  $default,){
final _that = this;
switch (_that) {
case _SubRule() when $default != null:
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
case _SubRule() when $default != null:
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
case _SubRule():
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
case _SubRule() when $default != null:
return $default(_that.name);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SubRule implements SubRule {
  const _SubRule({required this.name});
  factory _SubRule.fromJson(Map<String, dynamic> json) => _$SubRuleFromJson(json);

@override final  String name;

/// Create a copy of SubRule
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SubRuleCopyWith<_SubRule> get copyWith => __$SubRuleCopyWithImpl<_SubRule>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SubRuleToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SubRule&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name);

@override
String toString() {
  return 'SubRule(name: $name)';
}


}

/// @nodoc
abstract mixin class _$SubRuleCopyWith<$Res> implements $SubRuleCopyWith<$Res> {
  factory _$SubRuleCopyWith(_SubRule value, $Res Function(_SubRule) _then) = __$SubRuleCopyWithImpl;
@override @useResult
$Res call({
 String name
});




}
/// @nodoc
class __$SubRuleCopyWithImpl<$Res>
    implements _$SubRuleCopyWith<$Res> {
  __$SubRuleCopyWithImpl(this._self, this._then);

  final _SubRule _self;
  final $Res Function(_SubRule) _then;

/// Create a copy of SubRule
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,}) {
  return _then(_SubRule(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$ClashConfigSnippet {

@JsonKey(name: 'proxy-groups') List<ProxyGroup> get proxyGroups;@JsonKey(fromJson: _genRule, name: 'rules') List<Rule> get rule;@JsonKey(name: 'rule-providers', fromJson: _genRuleProviders) List<RuleProvider> get ruleProvider;@JsonKey(name: 'sub-rules', fromJson: _genSubRules) List<SubRule> get subRules;
/// Create a copy of ClashConfigSnippet
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClashConfigSnippetCopyWith<ClashConfigSnippet> get copyWith => _$ClashConfigSnippetCopyWithImpl<ClashConfigSnippet>(this as ClashConfigSnippet, _$identity);

  /// Serializes this ClashConfigSnippet to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClashConfigSnippet&&const DeepCollectionEquality().equals(other.proxyGroups, proxyGroups)&&const DeepCollectionEquality().equals(other.rule, rule)&&const DeepCollectionEquality().equals(other.ruleProvider, ruleProvider)&&const DeepCollectionEquality().equals(other.subRules, subRules));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(proxyGroups),const DeepCollectionEquality().hash(rule),const DeepCollectionEquality().hash(ruleProvider),const DeepCollectionEquality().hash(subRules));

@override
String toString() {
  return 'ClashConfigSnippet(proxyGroups: $proxyGroups, rule: $rule, ruleProvider: $ruleProvider, subRules: $subRules)';
}


}

/// @nodoc
abstract mixin class $ClashConfigSnippetCopyWith<$Res>  {
  factory $ClashConfigSnippetCopyWith(ClashConfigSnippet value, $Res Function(ClashConfigSnippet) _then) = _$ClashConfigSnippetCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'proxy-groups') List<ProxyGroup> proxyGroups,@JsonKey(fromJson: _genRule, name: 'rules') List<Rule> rule,@JsonKey(name: 'rule-providers', fromJson: _genRuleProviders) List<RuleProvider> ruleProvider,@JsonKey(name: 'sub-rules', fromJson: _genSubRules) List<SubRule> subRules
});




}
/// @nodoc
class _$ClashConfigSnippetCopyWithImpl<$Res>
    implements $ClashConfigSnippetCopyWith<$Res> {
  _$ClashConfigSnippetCopyWithImpl(this._self, this._then);

  final ClashConfigSnippet _self;
  final $Res Function(ClashConfigSnippet) _then;

/// Create a copy of ClashConfigSnippet
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? proxyGroups = null,Object? rule = null,Object? ruleProvider = null,Object? subRules = null,}) {
  return _then(_self.copyWith(
proxyGroups: null == proxyGroups ? _self.proxyGroups : proxyGroups // ignore: cast_nullable_to_non_nullable
as List<ProxyGroup>,rule: null == rule ? _self.rule : rule // ignore: cast_nullable_to_non_nullable
as List<Rule>,ruleProvider: null == ruleProvider ? _self.ruleProvider : ruleProvider // ignore: cast_nullable_to_non_nullable
as List<RuleProvider>,subRules: null == subRules ? _self.subRules : subRules // ignore: cast_nullable_to_non_nullable
as List<SubRule>,
  ));
}

}


/// Adds pattern-matching-related methods to [ClashConfigSnippet].
extension ClashConfigSnippetPatterns on ClashConfigSnippet {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ClashConfigSnippet value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ClashConfigSnippet() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ClashConfigSnippet value)  $default,){
final _that = this;
switch (_that) {
case _ClashConfigSnippet():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ClashConfigSnippet value)?  $default,){
final _that = this;
switch (_that) {
case _ClashConfigSnippet() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'proxy-groups')  List<ProxyGroup> proxyGroups, @JsonKey(fromJson: _genRule, name: 'rules')  List<Rule> rule, @JsonKey(name: 'rule-providers', fromJson: _genRuleProviders)  List<RuleProvider> ruleProvider, @JsonKey(name: 'sub-rules', fromJson: _genSubRules)  List<SubRule> subRules)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ClashConfigSnippet() when $default != null:
return $default(_that.proxyGroups,_that.rule,_that.ruleProvider,_that.subRules);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'proxy-groups')  List<ProxyGroup> proxyGroups, @JsonKey(fromJson: _genRule, name: 'rules')  List<Rule> rule, @JsonKey(name: 'rule-providers', fromJson: _genRuleProviders)  List<RuleProvider> ruleProvider, @JsonKey(name: 'sub-rules', fromJson: _genSubRules)  List<SubRule> subRules)  $default,) {final _that = this;
switch (_that) {
case _ClashConfigSnippet():
return $default(_that.proxyGroups,_that.rule,_that.ruleProvider,_that.subRules);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'proxy-groups')  List<ProxyGroup> proxyGroups, @JsonKey(fromJson: _genRule, name: 'rules')  List<Rule> rule, @JsonKey(name: 'rule-providers', fromJson: _genRuleProviders)  List<RuleProvider> ruleProvider, @JsonKey(name: 'sub-rules', fromJson: _genSubRules)  List<SubRule> subRules)?  $default,) {final _that = this;
switch (_that) {
case _ClashConfigSnippet() when $default != null:
return $default(_that.proxyGroups,_that.rule,_that.ruleProvider,_that.subRules);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ClashConfigSnippet implements ClashConfigSnippet {
  const _ClashConfigSnippet({@JsonKey(name: 'proxy-groups') final  List<ProxyGroup> proxyGroups = const [], @JsonKey(fromJson: _genRule, name: 'rules') final  List<Rule> rule = const [], @JsonKey(name: 'rule-providers', fromJson: _genRuleProviders) final  List<RuleProvider> ruleProvider = const [], @JsonKey(name: 'sub-rules', fromJson: _genSubRules) final  List<SubRule> subRules = const []}): _proxyGroups = proxyGroups,_rule = rule,_ruleProvider = ruleProvider,_subRules = subRules;
  factory _ClashConfigSnippet.fromJson(Map<String, dynamic> json) => _$ClashConfigSnippetFromJson(json);

 final  List<ProxyGroup> _proxyGroups;
@override@JsonKey(name: 'proxy-groups') List<ProxyGroup> get proxyGroups {
  if (_proxyGroups is EqualUnmodifiableListView) return _proxyGroups;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_proxyGroups);
}

 final  List<Rule> _rule;
@override@JsonKey(fromJson: _genRule, name: 'rules') List<Rule> get rule {
  if (_rule is EqualUnmodifiableListView) return _rule;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_rule);
}

 final  List<RuleProvider> _ruleProvider;
@override@JsonKey(name: 'rule-providers', fromJson: _genRuleProviders) List<RuleProvider> get ruleProvider {
  if (_ruleProvider is EqualUnmodifiableListView) return _ruleProvider;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_ruleProvider);
}

 final  List<SubRule> _subRules;
@override@JsonKey(name: 'sub-rules', fromJson: _genSubRules) List<SubRule> get subRules {
  if (_subRules is EqualUnmodifiableListView) return _subRules;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_subRules);
}


/// Create a copy of ClashConfigSnippet
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ClashConfigSnippetCopyWith<_ClashConfigSnippet> get copyWith => __$ClashConfigSnippetCopyWithImpl<_ClashConfigSnippet>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ClashConfigSnippetToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ClashConfigSnippet&&const DeepCollectionEquality().equals(other._proxyGroups, _proxyGroups)&&const DeepCollectionEquality().equals(other._rule, _rule)&&const DeepCollectionEquality().equals(other._ruleProvider, _ruleProvider)&&const DeepCollectionEquality().equals(other._subRules, _subRules));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_proxyGroups),const DeepCollectionEquality().hash(_rule),const DeepCollectionEquality().hash(_ruleProvider),const DeepCollectionEquality().hash(_subRules));

@override
String toString() {
  return 'ClashConfigSnippet(proxyGroups: $proxyGroups, rule: $rule, ruleProvider: $ruleProvider, subRules: $subRules)';
}


}

/// @nodoc
abstract mixin class _$ClashConfigSnippetCopyWith<$Res> implements $ClashConfigSnippetCopyWith<$Res> {
  factory _$ClashConfigSnippetCopyWith(_ClashConfigSnippet value, $Res Function(_ClashConfigSnippet) _then) = __$ClashConfigSnippetCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'proxy-groups') List<ProxyGroup> proxyGroups,@JsonKey(fromJson: _genRule, name: 'rules') List<Rule> rule,@JsonKey(name: 'rule-providers', fromJson: _genRuleProviders) List<RuleProvider> ruleProvider,@JsonKey(name: 'sub-rules', fromJson: _genSubRules) List<SubRule> subRules
});




}
/// @nodoc
class __$ClashConfigSnippetCopyWithImpl<$Res>
    implements _$ClashConfigSnippetCopyWith<$Res> {
  __$ClashConfigSnippetCopyWithImpl(this._self, this._then);

  final _ClashConfigSnippet _self;
  final $Res Function(_ClashConfigSnippet) _then;

/// Create a copy of ClashConfigSnippet
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? proxyGroups = null,Object? rule = null,Object? ruleProvider = null,Object? subRules = null,}) {
  return _then(_ClashConfigSnippet(
proxyGroups: null == proxyGroups ? _self._proxyGroups : proxyGroups // ignore: cast_nullable_to_non_nullable
as List<ProxyGroup>,rule: null == rule ? _self._rule : rule // ignore: cast_nullable_to_non_nullable
as List<Rule>,ruleProvider: null == ruleProvider ? _self._ruleProvider : ruleProvider // ignore: cast_nullable_to_non_nullable
as List<RuleProvider>,subRules: null == subRules ? _self._subRules : subRules // ignore: cast_nullable_to_non_nullable
as List<SubRule>,
  ));
}


}


/// @nodoc
mixin _$ClashConfig {

@JsonKey(name: 'mixed-port') int get mixedPort;@JsonKey(name: 'socks-port') int get socksPort;@JsonKey(name: 'port') int get port;@JsonKey(name: 'redir-port') int get redirPort;@JsonKey(name: 'tproxy-port') int get tproxyPort; Mode get mode;@JsonKey(name: 'allow-lan') bool get allowLan;@JsonKey(name: 'log-level') LogLevel get logLevel; bool get ipv6;@JsonKey(name: 'find-process-mode', unknownEnumValue: FindProcessMode.always) FindProcessMode get findProcessMode;@JsonKey(name: 'keep-alive-interval') int get keepAliveInterval;@JsonKey(name: 'unified-delay') bool get unifiedDelay;@JsonKey(name: 'tcp-concurrent') bool get tcpConcurrent;@JsonKey(fromJson: Tun.safeFormJson) Tun get tun;@JsonKey(fromJson: Dns.safeDnsFromJson) Dns get dns;@JsonKey(name: 'geox-url', fromJson: GeoXUrl.safeFormJson) GeoXUrl get geoXUrl;@JsonKey(name: 'geodata-loader') GeodataLoader get geodataLoader;@JsonKey(name: 'proxy-groups') List<ProxyGroup> get proxyGroups; List<String> get rule;@JsonKey(name: 'global-ua') String? get globalUa;@JsonKey(name: 'external-controller') ExternalControllerStatus get externalController; Map<String, String> get hosts;
/// Create a copy of ClashConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClashConfigCopyWith<ClashConfig> get copyWith => _$ClashConfigCopyWithImpl<ClashConfig>(this as ClashConfig, _$identity);

  /// Serializes this ClashConfig to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClashConfig&&(identical(other.mixedPort, mixedPort) || other.mixedPort == mixedPort)&&(identical(other.socksPort, socksPort) || other.socksPort == socksPort)&&(identical(other.port, port) || other.port == port)&&(identical(other.redirPort, redirPort) || other.redirPort == redirPort)&&(identical(other.tproxyPort, tproxyPort) || other.tproxyPort == tproxyPort)&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.allowLan, allowLan) || other.allowLan == allowLan)&&(identical(other.logLevel, logLevel) || other.logLevel == logLevel)&&(identical(other.ipv6, ipv6) || other.ipv6 == ipv6)&&(identical(other.findProcessMode, findProcessMode) || other.findProcessMode == findProcessMode)&&(identical(other.keepAliveInterval, keepAliveInterval) || other.keepAliveInterval == keepAliveInterval)&&(identical(other.unifiedDelay, unifiedDelay) || other.unifiedDelay == unifiedDelay)&&(identical(other.tcpConcurrent, tcpConcurrent) || other.tcpConcurrent == tcpConcurrent)&&(identical(other.tun, tun) || other.tun == tun)&&(identical(other.dns, dns) || other.dns == dns)&&(identical(other.geoXUrl, geoXUrl) || other.geoXUrl == geoXUrl)&&(identical(other.geodataLoader, geodataLoader) || other.geodataLoader == geodataLoader)&&const DeepCollectionEquality().equals(other.proxyGroups, proxyGroups)&&const DeepCollectionEquality().equals(other.rule, rule)&&(identical(other.globalUa, globalUa) || other.globalUa == globalUa)&&(identical(other.externalController, externalController) || other.externalController == externalController)&&const DeepCollectionEquality().equals(other.hosts, hosts));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,mixedPort,socksPort,port,redirPort,tproxyPort,mode,allowLan,logLevel,ipv6,findProcessMode,keepAliveInterval,unifiedDelay,tcpConcurrent,tun,dns,geoXUrl,geodataLoader,const DeepCollectionEquality().hash(proxyGroups),const DeepCollectionEquality().hash(rule),globalUa,externalController,const DeepCollectionEquality().hash(hosts)]);

@override
String toString() {
  return 'ClashConfig(mixedPort: $mixedPort, socksPort: $socksPort, port: $port, redirPort: $redirPort, tproxyPort: $tproxyPort, mode: $mode, allowLan: $allowLan, logLevel: $logLevel, ipv6: $ipv6, findProcessMode: $findProcessMode, keepAliveInterval: $keepAliveInterval, unifiedDelay: $unifiedDelay, tcpConcurrent: $tcpConcurrent, tun: $tun, dns: $dns, geoXUrl: $geoXUrl, geodataLoader: $geodataLoader, proxyGroups: $proxyGroups, rule: $rule, globalUa: $globalUa, externalController: $externalController, hosts: $hosts)';
}


}

/// @nodoc
abstract mixin class $ClashConfigCopyWith<$Res>  {
  factory $ClashConfigCopyWith(ClashConfig value, $Res Function(ClashConfig) _then) = _$ClashConfigCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'mixed-port') int mixedPort,@JsonKey(name: 'socks-port') int socksPort,@JsonKey(name: 'port') int port,@JsonKey(name: 'redir-port') int redirPort,@JsonKey(name: 'tproxy-port') int tproxyPort, Mode mode,@JsonKey(name: 'allow-lan') bool allowLan,@JsonKey(name: 'log-level') LogLevel logLevel, bool ipv6,@JsonKey(name: 'find-process-mode', unknownEnumValue: FindProcessMode.always) FindProcessMode findProcessMode,@JsonKey(name: 'keep-alive-interval') int keepAliveInterval,@JsonKey(name: 'unified-delay') bool unifiedDelay,@JsonKey(name: 'tcp-concurrent') bool tcpConcurrent,@JsonKey(fromJson: Tun.safeFormJson) Tun tun,@JsonKey(fromJson: Dns.safeDnsFromJson) Dns dns,@JsonKey(name: 'geox-url', fromJson: GeoXUrl.safeFormJson) GeoXUrl geoXUrl,@JsonKey(name: 'geodata-loader') GeodataLoader geodataLoader,@JsonKey(name: 'proxy-groups') List<ProxyGroup> proxyGroups, List<String> rule,@JsonKey(name: 'global-ua') String? globalUa,@JsonKey(name: 'external-controller') ExternalControllerStatus externalController, Map<String, String> hosts
});


$TunCopyWith<$Res> get tun;$DnsCopyWith<$Res> get dns;$GeoXUrlCopyWith<$Res> get geoXUrl;

}
/// @nodoc
class _$ClashConfigCopyWithImpl<$Res>
    implements $ClashConfigCopyWith<$Res> {
  _$ClashConfigCopyWithImpl(this._self, this._then);

  final ClashConfig _self;
  final $Res Function(ClashConfig) _then;

/// Create a copy of ClashConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? mixedPort = null,Object? socksPort = null,Object? port = null,Object? redirPort = null,Object? tproxyPort = null,Object? mode = null,Object? allowLan = null,Object? logLevel = null,Object? ipv6 = null,Object? findProcessMode = null,Object? keepAliveInterval = null,Object? unifiedDelay = null,Object? tcpConcurrent = null,Object? tun = null,Object? dns = null,Object? geoXUrl = null,Object? geodataLoader = null,Object? proxyGroups = null,Object? rule = null,Object? globalUa = freezed,Object? externalController = null,Object? hosts = null,}) {
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
as GeoXUrl,geodataLoader: null == geodataLoader ? _self.geodataLoader : geodataLoader // ignore: cast_nullable_to_non_nullable
as GeodataLoader,proxyGroups: null == proxyGroups ? _self.proxyGroups : proxyGroups // ignore: cast_nullable_to_non_nullable
as List<ProxyGroup>,rule: null == rule ? _self.rule : rule // ignore: cast_nullable_to_non_nullable
as List<String>,globalUa: freezed == globalUa ? _self.globalUa : globalUa // ignore: cast_nullable_to_non_nullable
as String?,externalController: null == externalController ? _self.externalController : externalController // ignore: cast_nullable_to_non_nullable
as ExternalControllerStatus,hosts: null == hosts ? _self.hosts : hosts // ignore: cast_nullable_to_non_nullable
as Map<String, String>,
  ));
}
/// Create a copy of ClashConfig
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TunCopyWith<$Res> get tun {
  
  return $TunCopyWith<$Res>(_self.tun, (value) {
    return _then(_self.copyWith(tun: value));
  });
}/// Create a copy of ClashConfig
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DnsCopyWith<$Res> get dns {
  
  return $DnsCopyWith<$Res>(_self.dns, (value) {
    return _then(_self.copyWith(dns: value));
  });
}/// Create a copy of ClashConfig
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GeoXUrlCopyWith<$Res> get geoXUrl {
  
  return $GeoXUrlCopyWith<$Res>(_self.geoXUrl, (value) {
    return _then(_self.copyWith(geoXUrl: value));
  });
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'mixed-port')  int mixedPort, @JsonKey(name: 'socks-port')  int socksPort, @JsonKey(name: 'port')  int port, @JsonKey(name: 'redir-port')  int redirPort, @JsonKey(name: 'tproxy-port')  int tproxyPort,  Mode mode, @JsonKey(name: 'allow-lan')  bool allowLan, @JsonKey(name: 'log-level')  LogLevel logLevel,  bool ipv6, @JsonKey(name: 'find-process-mode', unknownEnumValue: FindProcessMode.always)  FindProcessMode findProcessMode, @JsonKey(name: 'keep-alive-interval')  int keepAliveInterval, @JsonKey(name: 'unified-delay')  bool unifiedDelay, @JsonKey(name: 'tcp-concurrent')  bool tcpConcurrent, @JsonKey(fromJson: Tun.safeFormJson)  Tun tun, @JsonKey(fromJson: Dns.safeDnsFromJson)  Dns dns, @JsonKey(name: 'geox-url', fromJson: GeoXUrl.safeFormJson)  GeoXUrl geoXUrl, @JsonKey(name: 'geodata-loader')  GeodataLoader geodataLoader, @JsonKey(name: 'proxy-groups')  List<ProxyGroup> proxyGroups,  List<String> rule, @JsonKey(name: 'global-ua')  String? globalUa, @JsonKey(name: 'external-controller')  ExternalControllerStatus externalController,  Map<String, String> hosts)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ClashConfig() when $default != null:
return $default(_that.mixedPort,_that.socksPort,_that.port,_that.redirPort,_that.tproxyPort,_that.mode,_that.allowLan,_that.logLevel,_that.ipv6,_that.findProcessMode,_that.keepAliveInterval,_that.unifiedDelay,_that.tcpConcurrent,_that.tun,_that.dns,_that.geoXUrl,_that.geodataLoader,_that.proxyGroups,_that.rule,_that.globalUa,_that.externalController,_that.hosts);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'mixed-port')  int mixedPort, @JsonKey(name: 'socks-port')  int socksPort, @JsonKey(name: 'port')  int port, @JsonKey(name: 'redir-port')  int redirPort, @JsonKey(name: 'tproxy-port')  int tproxyPort,  Mode mode, @JsonKey(name: 'allow-lan')  bool allowLan, @JsonKey(name: 'log-level')  LogLevel logLevel,  bool ipv6, @JsonKey(name: 'find-process-mode', unknownEnumValue: FindProcessMode.always)  FindProcessMode findProcessMode, @JsonKey(name: 'keep-alive-interval')  int keepAliveInterval, @JsonKey(name: 'unified-delay')  bool unifiedDelay, @JsonKey(name: 'tcp-concurrent')  bool tcpConcurrent, @JsonKey(fromJson: Tun.safeFormJson)  Tun tun, @JsonKey(fromJson: Dns.safeDnsFromJson)  Dns dns, @JsonKey(name: 'geox-url', fromJson: GeoXUrl.safeFormJson)  GeoXUrl geoXUrl, @JsonKey(name: 'geodata-loader')  GeodataLoader geodataLoader, @JsonKey(name: 'proxy-groups')  List<ProxyGroup> proxyGroups,  List<String> rule, @JsonKey(name: 'global-ua')  String? globalUa, @JsonKey(name: 'external-controller')  ExternalControllerStatus externalController,  Map<String, String> hosts)  $default,) {final _that = this;
switch (_that) {
case _ClashConfig():
return $default(_that.mixedPort,_that.socksPort,_that.port,_that.redirPort,_that.tproxyPort,_that.mode,_that.allowLan,_that.logLevel,_that.ipv6,_that.findProcessMode,_that.keepAliveInterval,_that.unifiedDelay,_that.tcpConcurrent,_that.tun,_that.dns,_that.geoXUrl,_that.geodataLoader,_that.proxyGroups,_that.rule,_that.globalUa,_that.externalController,_that.hosts);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'mixed-port')  int mixedPort, @JsonKey(name: 'socks-port')  int socksPort, @JsonKey(name: 'port')  int port, @JsonKey(name: 'redir-port')  int redirPort, @JsonKey(name: 'tproxy-port')  int tproxyPort,  Mode mode, @JsonKey(name: 'allow-lan')  bool allowLan, @JsonKey(name: 'log-level')  LogLevel logLevel,  bool ipv6, @JsonKey(name: 'find-process-mode', unknownEnumValue: FindProcessMode.always)  FindProcessMode findProcessMode, @JsonKey(name: 'keep-alive-interval')  int keepAliveInterval, @JsonKey(name: 'unified-delay')  bool unifiedDelay, @JsonKey(name: 'tcp-concurrent')  bool tcpConcurrent, @JsonKey(fromJson: Tun.safeFormJson)  Tun tun, @JsonKey(fromJson: Dns.safeDnsFromJson)  Dns dns, @JsonKey(name: 'geox-url', fromJson: GeoXUrl.safeFormJson)  GeoXUrl geoXUrl, @JsonKey(name: 'geodata-loader')  GeodataLoader geodataLoader, @JsonKey(name: 'proxy-groups')  List<ProxyGroup> proxyGroups,  List<String> rule, @JsonKey(name: 'global-ua')  String? globalUa, @JsonKey(name: 'external-controller')  ExternalControllerStatus externalController,  Map<String, String> hosts)?  $default,) {final _that = this;
switch (_that) {
case _ClashConfig() when $default != null:
return $default(_that.mixedPort,_that.socksPort,_that.port,_that.redirPort,_that.tproxyPort,_that.mode,_that.allowLan,_that.logLevel,_that.ipv6,_that.findProcessMode,_that.keepAliveInterval,_that.unifiedDelay,_that.tcpConcurrent,_that.tun,_that.dns,_that.geoXUrl,_that.geodataLoader,_that.proxyGroups,_that.rule,_that.globalUa,_that.externalController,_that.hosts);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ClashConfig implements ClashConfig {
  const _ClashConfig({@JsonKey(name: 'mixed-port') this.mixedPort = defaultMixedPort, @JsonKey(name: 'socks-port') this.socksPort = 0, @JsonKey(name: 'port') this.port = 0, @JsonKey(name: 'redir-port') this.redirPort = 0, @JsonKey(name: 'tproxy-port') this.tproxyPort = 0, this.mode = Mode.rule, @JsonKey(name: 'allow-lan') this.allowLan = false, @JsonKey(name: 'log-level') this.logLevel = LogLevel.error, this.ipv6 = false, @JsonKey(name: 'find-process-mode', unknownEnumValue: FindProcessMode.always) this.findProcessMode = FindProcessMode.always, @JsonKey(name: 'keep-alive-interval') this.keepAliveInterval = defaultKeepAliveInterval, @JsonKey(name: 'unified-delay') this.unifiedDelay = true, @JsonKey(name: 'tcp-concurrent') this.tcpConcurrent = true, @JsonKey(fromJson: Tun.safeFormJson) this.tun = defaultTun, @JsonKey(fromJson: Dns.safeDnsFromJson) this.dns = defaultDns, @JsonKey(name: 'geox-url', fromJson: GeoXUrl.safeFormJson) this.geoXUrl = defaultGeoXUrl, @JsonKey(name: 'geodata-loader') this.geodataLoader = GeodataLoader.memconservative, @JsonKey(name: 'proxy-groups') final  List<ProxyGroup> proxyGroups = const [], final  List<String> rule = const [], @JsonKey(name: 'global-ua') this.globalUa, @JsonKey(name: 'external-controller') this.externalController = ExternalControllerStatus.close, final  Map<String, String> hosts = const {}}): _proxyGroups = proxyGroups,_rule = rule,_hosts = hosts;
  factory _ClashConfig.fromJson(Map<String, dynamic> json) => _$ClashConfigFromJson(json);

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
@override@JsonKey(name: 'geox-url', fromJson: GeoXUrl.safeFormJson) final  GeoXUrl geoXUrl;
@override@JsonKey(name: 'geodata-loader') final  GeodataLoader geodataLoader;
 final  List<ProxyGroup> _proxyGroups;
@override@JsonKey(name: 'proxy-groups') List<ProxyGroup> get proxyGroups {
  if (_proxyGroups is EqualUnmodifiableListView) return _proxyGroups;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_proxyGroups);
}

 final  List<String> _rule;
@override@JsonKey() List<String> get rule {
  if (_rule is EqualUnmodifiableListView) return _rule;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_rule);
}

@override@JsonKey(name: 'global-ua') final  String? globalUa;
@override@JsonKey(name: 'external-controller') final  ExternalControllerStatus externalController;
 final  Map<String, String> _hosts;
@override@JsonKey() Map<String, String> get hosts {
  if (_hosts is EqualUnmodifiableMapView) return _hosts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_hosts);
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ClashConfig&&(identical(other.mixedPort, mixedPort) || other.mixedPort == mixedPort)&&(identical(other.socksPort, socksPort) || other.socksPort == socksPort)&&(identical(other.port, port) || other.port == port)&&(identical(other.redirPort, redirPort) || other.redirPort == redirPort)&&(identical(other.tproxyPort, tproxyPort) || other.tproxyPort == tproxyPort)&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.allowLan, allowLan) || other.allowLan == allowLan)&&(identical(other.logLevel, logLevel) || other.logLevel == logLevel)&&(identical(other.ipv6, ipv6) || other.ipv6 == ipv6)&&(identical(other.findProcessMode, findProcessMode) || other.findProcessMode == findProcessMode)&&(identical(other.keepAliveInterval, keepAliveInterval) || other.keepAliveInterval == keepAliveInterval)&&(identical(other.unifiedDelay, unifiedDelay) || other.unifiedDelay == unifiedDelay)&&(identical(other.tcpConcurrent, tcpConcurrent) || other.tcpConcurrent == tcpConcurrent)&&(identical(other.tun, tun) || other.tun == tun)&&(identical(other.dns, dns) || other.dns == dns)&&(identical(other.geoXUrl, geoXUrl) || other.geoXUrl == geoXUrl)&&(identical(other.geodataLoader, geodataLoader) || other.geodataLoader == geodataLoader)&&const DeepCollectionEquality().equals(other._proxyGroups, _proxyGroups)&&const DeepCollectionEquality().equals(other._rule, _rule)&&(identical(other.globalUa, globalUa) || other.globalUa == globalUa)&&(identical(other.externalController, externalController) || other.externalController == externalController)&&const DeepCollectionEquality().equals(other._hosts, _hosts));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,mixedPort,socksPort,port,redirPort,tproxyPort,mode,allowLan,logLevel,ipv6,findProcessMode,keepAliveInterval,unifiedDelay,tcpConcurrent,tun,dns,geoXUrl,geodataLoader,const DeepCollectionEquality().hash(_proxyGroups),const DeepCollectionEquality().hash(_rule),globalUa,externalController,const DeepCollectionEquality().hash(_hosts)]);

@override
String toString() {
  return 'ClashConfig(mixedPort: $mixedPort, socksPort: $socksPort, port: $port, redirPort: $redirPort, tproxyPort: $tproxyPort, mode: $mode, allowLan: $allowLan, logLevel: $logLevel, ipv6: $ipv6, findProcessMode: $findProcessMode, keepAliveInterval: $keepAliveInterval, unifiedDelay: $unifiedDelay, tcpConcurrent: $tcpConcurrent, tun: $tun, dns: $dns, geoXUrl: $geoXUrl, geodataLoader: $geodataLoader, proxyGroups: $proxyGroups, rule: $rule, globalUa: $globalUa, externalController: $externalController, hosts: $hosts)';
}


}

/// @nodoc
abstract mixin class _$ClashConfigCopyWith<$Res> implements $ClashConfigCopyWith<$Res> {
  factory _$ClashConfigCopyWith(_ClashConfig value, $Res Function(_ClashConfig) _then) = __$ClashConfigCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'mixed-port') int mixedPort,@JsonKey(name: 'socks-port') int socksPort,@JsonKey(name: 'port') int port,@JsonKey(name: 'redir-port') int redirPort,@JsonKey(name: 'tproxy-port') int tproxyPort, Mode mode,@JsonKey(name: 'allow-lan') bool allowLan,@JsonKey(name: 'log-level') LogLevel logLevel, bool ipv6,@JsonKey(name: 'find-process-mode', unknownEnumValue: FindProcessMode.always) FindProcessMode findProcessMode,@JsonKey(name: 'keep-alive-interval') int keepAliveInterval,@JsonKey(name: 'unified-delay') bool unifiedDelay,@JsonKey(name: 'tcp-concurrent') bool tcpConcurrent,@JsonKey(fromJson: Tun.safeFormJson) Tun tun,@JsonKey(fromJson: Dns.safeDnsFromJson) Dns dns,@JsonKey(name: 'geox-url', fromJson: GeoXUrl.safeFormJson) GeoXUrl geoXUrl,@JsonKey(name: 'geodata-loader') GeodataLoader geodataLoader,@JsonKey(name: 'proxy-groups') List<ProxyGroup> proxyGroups, List<String> rule,@JsonKey(name: 'global-ua') String? globalUa,@JsonKey(name: 'external-controller') ExternalControllerStatus externalController, Map<String, String> hosts
});


@override $TunCopyWith<$Res> get tun;@override $DnsCopyWith<$Res> get dns;@override $GeoXUrlCopyWith<$Res> get geoXUrl;

}
/// @nodoc
class __$ClashConfigCopyWithImpl<$Res>
    implements _$ClashConfigCopyWith<$Res> {
  __$ClashConfigCopyWithImpl(this._self, this._then);

  final _ClashConfig _self;
  final $Res Function(_ClashConfig) _then;

/// Create a copy of ClashConfig
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? mixedPort = null,Object? socksPort = null,Object? port = null,Object? redirPort = null,Object? tproxyPort = null,Object? mode = null,Object? allowLan = null,Object? logLevel = null,Object? ipv6 = null,Object? findProcessMode = null,Object? keepAliveInterval = null,Object? unifiedDelay = null,Object? tcpConcurrent = null,Object? tun = null,Object? dns = null,Object? geoXUrl = null,Object? geodataLoader = null,Object? proxyGroups = null,Object? rule = null,Object? globalUa = freezed,Object? externalController = null,Object? hosts = null,}) {
  return _then(_ClashConfig(
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
as GeoXUrl,geodataLoader: null == geodataLoader ? _self.geodataLoader : geodataLoader // ignore: cast_nullable_to_non_nullable
as GeodataLoader,proxyGroups: null == proxyGroups ? _self._proxyGroups : proxyGroups // ignore: cast_nullable_to_non_nullable
as List<ProxyGroup>,rule: null == rule ? _self._rule : rule // ignore: cast_nullable_to_non_nullable
as List<String>,globalUa: freezed == globalUa ? _self.globalUa : globalUa // ignore: cast_nullable_to_non_nullable
as String?,externalController: null == externalController ? _self.externalController : externalController // ignore: cast_nullable_to_non_nullable
as ExternalControllerStatus,hosts: null == hosts ? _self._hosts : hosts // ignore: cast_nullable_to_non_nullable
as Map<String, String>,
  ));
}

/// Create a copy of ClashConfig
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TunCopyWith<$Res> get tun {
  
  return $TunCopyWith<$Res>(_self.tun, (value) {
    return _then(_self.copyWith(tun: value));
  });
}/// Create a copy of ClashConfig
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DnsCopyWith<$Res> get dns {
  
  return $DnsCopyWith<$Res>(_self.dns, (value) {
    return _then(_self.copyWith(dns: value));
  });
}/// Create a copy of ClashConfig
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GeoXUrlCopyWith<$Res> get geoXUrl {
  
  return $GeoXUrlCopyWith<$Res>(_self.geoXUrl, (value) {
    return _then(_self.copyWith(geoXUrl: value));
  });
}
}

// dart format on
