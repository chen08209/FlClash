// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../profile.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SubscriptionInfo {

 int get upload; int get download; int get total; int get expire;
/// Create a copy of SubscriptionInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SubscriptionInfoCopyWith<SubscriptionInfo> get copyWith => _$SubscriptionInfoCopyWithImpl<SubscriptionInfo>(this as SubscriptionInfo, _$identity);

  /// Serializes this SubscriptionInfo to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SubscriptionInfo;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SubscriptionInfo&&(identical(other.upload, _this.upload) || other.upload == _this.upload)&&(identical(other.download, _this.download) || other.download == _this.download)&&(identical(other.total, _this.total) || other.total == _this.total)&&(identical(other.expire, _this.expire) || other.expire == _this.expire));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SubscriptionInfo;
  return Object.hash(runtimeType,_this.upload,_this.download,_this.total,_this.expire);
}

@override
String toString() {
  final _this = this as SubscriptionInfo;
  return 'SubscriptionInfo(upload: ${_this.upload}, download: ${_this.download}, total: ${_this.total}, expire: ${_this.expire})';
}


}

/// @nodoc
abstract mixin class $SubscriptionInfoCopyWith<$Res>  {
  factory $SubscriptionInfoCopyWith(SubscriptionInfo value, $Res Function(SubscriptionInfo) _then) = _$SubscriptionInfoCopyWithImpl;
@useResult
$Res call({
 int upload, int download, int total, int expire
});




}
/// @nodoc
class _$SubscriptionInfoCopyWithImpl<$Res>
    implements $SubscriptionInfoCopyWith<$Res> {
  _$SubscriptionInfoCopyWithImpl(this._self, this._then);

  final SubscriptionInfo _self;
  final $Res Function(SubscriptionInfo) _then;

/// Create a copy of SubscriptionInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? upload = null,Object? download = null,Object? total = null,Object? expire = null,}) {
  return _then(SubscriptionInfo(
upload: null == upload ? _self.upload : upload // ignore: cast_nullable_to_non_nullable
as int,download: null == download ? _self.download : download // ignore: cast_nullable_to_non_nullable
as int,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,expire: null == expire ? _self.expire : expire // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [SubscriptionInfo].
extension SubscriptionInfoPatterns on SubscriptionInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SubscriptionInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SubscriptionInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SubscriptionInfo value)  $default,){
final _that = this;
switch (_that) {
case _SubscriptionInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SubscriptionInfo value)?  $default,){
final _that = this;
switch (_that) {
case _SubscriptionInfo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int upload,  int download,  int total,  int expire)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SubscriptionInfo() when $default != null:
return $default(_that.upload,_that.download,_that.total,_that.expire);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int upload,  int download,  int total,  int expire)  $default,) {final _that = this;
switch (_that) {
case _SubscriptionInfo():
return $default(_that.upload,_that.download,_that.total,_that.expire);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int upload,  int download,  int total,  int expire)?  $default,) {final _that = this;
switch (_that) {
case _SubscriptionInfo() when $default != null:
return $default(_that.upload,_that.download,_that.total,_that.expire);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SubscriptionInfo implements SubscriptionInfo {
  const _SubscriptionInfo({this.upload = 0, this.download = 0, this.total = 0, this.expire = 0});
  factory _SubscriptionInfo.fromJson(Map<String, dynamic> json) => _$SubscriptionInfoFromJson(json);

@override@JsonKey() final  int upload;
@override@JsonKey() final  int download;
@override@JsonKey() final  int total;
@override@JsonKey() final  int expire;

/// Create a copy of SubscriptionInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SubscriptionInfoCopyWith<_SubscriptionInfo> get copyWith => __$SubscriptionInfoCopyWithImpl<_SubscriptionInfo>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SubscriptionInfoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SubscriptionInfo&&(identical(other.upload, upload) || other.upload == upload)&&(identical(other.download, download) || other.download == download)&&(identical(other.total, total) || other.total == total)&&(identical(other.expire, expire) || other.expire == expire));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,upload,download,total,expire);
}

@override
String toString() {
    return 'SubscriptionInfo(upload: $upload, download: $download, total: $total, expire: $expire)';
}


}

/// @nodoc
abstract mixin class _$SubscriptionInfoCopyWith<$Res> implements $SubscriptionInfoCopyWith<$Res> {
  factory _$SubscriptionInfoCopyWith(_SubscriptionInfo value, $Res Function(_SubscriptionInfo) _then) = __$SubscriptionInfoCopyWithImpl;
@override @useResult
$Res call({
 int upload, int download, int total, int expire
});




}
/// @nodoc
class __$SubscriptionInfoCopyWithImpl<$Res>
    implements _$SubscriptionInfoCopyWith<$Res> {
  __$SubscriptionInfoCopyWithImpl(this._self, this._then);

  final _SubscriptionInfo _self;
  final $Res Function(_SubscriptionInfo) _then;

/// Create a copy of SubscriptionInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? upload = null,Object? download = null,Object? total = null,Object? expire = null,}) {
  return _then(_SubscriptionInfo(
upload: null == upload ? _self.upload : upload // ignore: cast_nullable_to_non_nullable
as int,download: null == download ? _self.download : download // ignore: cast_nullable_to_non_nullable
as int,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,expire: null == expire ? _self.expire : expire // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$Profile {

 int get id; String get label; String? get currentGroupName; String get url; DateTime? get lastUpdateDate; Duration get autoUpdateDuration; SubscriptionInfo? get subscriptionInfo; bool get autoUpdate; Map<String, String> get selectedMap; Set<String> get unfoldSet; OverwriteType get overwriteType; int? get scriptId; String? get matchTarget; int? get order;
/// Create a copy of Profile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProfileCopyWith<Profile> get copyWith => _$ProfileCopyWithImpl<Profile>(this as Profile, _$identity);

  /// Serializes this Profile to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Profile;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Profile&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.label, _this.label) || other.label == _this.label)&&(identical(other.currentGroupName, _this.currentGroupName) || other.currentGroupName == _this.currentGroupName)&&(identical(other.url, _this.url) || other.url == _this.url)&&(identical(other.lastUpdateDate, _this.lastUpdateDate) || other.lastUpdateDate == _this.lastUpdateDate)&&(identical(other.autoUpdateDuration, _this.autoUpdateDuration) || other.autoUpdateDuration == _this.autoUpdateDuration)&&(identical(other.subscriptionInfo, _this.subscriptionInfo) || other.subscriptionInfo == _this.subscriptionInfo)&&(identical(other.autoUpdate, _this.autoUpdate) || other.autoUpdate == _this.autoUpdate)&&const DeepCollectionEquality().equals(other.selectedMap, _this.selectedMap)&&const DeepCollectionEquality().equals(other.unfoldSet, _this.unfoldSet)&&(identical(other.overwriteType, _this.overwriteType) || other.overwriteType == _this.overwriteType)&&(identical(other.scriptId, _this.scriptId) || other.scriptId == _this.scriptId)&&(identical(other.matchTarget, _this.matchTarget) || other.matchTarget == _this.matchTarget)&&(identical(other.order, _this.order) || other.order == _this.order));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Profile;
  return Object.hash(runtimeType,_this.id,_this.label,_this.currentGroupName,_this.url,_this.lastUpdateDate,_this.autoUpdateDuration,_this.subscriptionInfo,_this.autoUpdate,const DeepCollectionEquality().hash(_this.selectedMap),const DeepCollectionEquality().hash(_this.unfoldSet),_this.overwriteType,_this.scriptId,_this.matchTarget,_this.order);
}

@override
String toString() {
  final _this = this as Profile;
  return 'Profile(id: ${_this.id}, label: ${_this.label}, currentGroupName: ${_this.currentGroupName}, url: ${_this.url}, lastUpdateDate: ${_this.lastUpdateDate}, autoUpdateDuration: ${_this.autoUpdateDuration}, subscriptionInfo: ${_this.subscriptionInfo}, autoUpdate: ${_this.autoUpdate}, selectedMap: ${_this.selectedMap}, unfoldSet: ${_this.unfoldSet}, overwriteType: ${_this.overwriteType}, scriptId: ${_this.scriptId}, matchTarget: ${_this.matchTarget}, order: ${_this.order})';
}


}

/// @nodoc
abstract mixin class $ProfileCopyWith<$Res>  {
  factory $ProfileCopyWith(Profile value, $Res Function(Profile) _then) = _$ProfileCopyWithImpl;
@useResult
$Res call({
 int id, String label, String? currentGroupName, String url, DateTime? lastUpdateDate, Duration autoUpdateDuration, SubscriptionInfo? subscriptionInfo, bool autoUpdate, Map<String, String> selectedMap, Set<String> unfoldSet, OverwriteType overwriteType, int? scriptId, String? matchTarget, int? order
});


$SubscriptionInfoCopyWith<$Res>? get subscriptionInfo;

}
/// @nodoc
class _$ProfileCopyWithImpl<$Res>
    implements $ProfileCopyWith<$Res> {
  _$ProfileCopyWithImpl(this._self, this._then);

  final Profile _self;
  final $Res Function(Profile) _then;

/// Create a copy of Profile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? label = null,Object? currentGroupName = freezed,Object? url = null,Object? lastUpdateDate = freezed,Object? autoUpdateDuration = null,Object? subscriptionInfo = freezed,Object? autoUpdate = null,Object? selectedMap = null,Object? unfoldSet = null,Object? overwriteType = null,Object? scriptId = freezed,Object? matchTarget = freezed,Object? order = freezed,}) {
  return _then(Profile(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,currentGroupName: freezed == currentGroupName ? _self.currentGroupName : currentGroupName // ignore: cast_nullable_to_non_nullable
as String?,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,lastUpdateDate: freezed == lastUpdateDate ? _self.lastUpdateDate : lastUpdateDate // ignore: cast_nullable_to_non_nullable
as DateTime?,autoUpdateDuration: null == autoUpdateDuration ? _self.autoUpdateDuration : autoUpdateDuration // ignore: cast_nullable_to_non_nullable
as Duration,subscriptionInfo: freezed == subscriptionInfo ? _self.subscriptionInfo : subscriptionInfo // ignore: cast_nullable_to_non_nullable
as SubscriptionInfo?,autoUpdate: null == autoUpdate ? _self.autoUpdate : autoUpdate // ignore: cast_nullable_to_non_nullable
as bool,selectedMap: null == selectedMap ? _self.selectedMap : selectedMap // ignore: cast_nullable_to_non_nullable
as Map<String, String>,unfoldSet: null == unfoldSet ? _self.unfoldSet : unfoldSet // ignore: cast_nullable_to_non_nullable
as Set<String>,overwriteType: null == overwriteType ? _self.overwriteType : overwriteType // ignore: cast_nullable_to_non_nullable
as OverwriteType,scriptId: freezed == scriptId ? _self.scriptId : scriptId // ignore: cast_nullable_to_non_nullable
as int?,matchTarget: freezed == matchTarget ? _self.matchTarget : matchTarget // ignore: cast_nullable_to_non_nullable
as String?,order: freezed == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}
/// Create a copy of Profile
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SubscriptionInfoCopyWith<$Res>? get subscriptionInfo {
    if (_self.subscriptionInfo == null) {
    return null;
  }

  return $SubscriptionInfoCopyWith<$Res>(_self.subscriptionInfo!, (value) {
    return _then(_self.copyWith(subscriptionInfo: value));
  });
}
}


/// Adds pattern-matching-related methods to [Profile].
extension ProfilePatterns on Profile {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Profile value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Profile() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Profile value)  $default,){
final _that = this;
switch (_that) {
case _Profile():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Profile value)?  $default,){
final _that = this;
switch (_that) {
case _Profile() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String label,  String? currentGroupName,  String url,  DateTime? lastUpdateDate,  Duration autoUpdateDuration,  SubscriptionInfo? subscriptionInfo,  bool autoUpdate,  Map<String, String> selectedMap,  Set<String> unfoldSet,  OverwriteType overwriteType,  int? scriptId,  String? matchTarget,  int? order)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Profile() when $default != null:
return $default(_that.id,_that.label,_that.currentGroupName,_that.url,_that.lastUpdateDate,_that.autoUpdateDuration,_that.subscriptionInfo,_that.autoUpdate,_that.selectedMap,_that.unfoldSet,_that.overwriteType,_that.scriptId,_that.matchTarget,_that.order);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String label,  String? currentGroupName,  String url,  DateTime? lastUpdateDate,  Duration autoUpdateDuration,  SubscriptionInfo? subscriptionInfo,  bool autoUpdate,  Map<String, String> selectedMap,  Set<String> unfoldSet,  OverwriteType overwriteType,  int? scriptId,  String? matchTarget,  int? order)  $default,) {final _that = this;
switch (_that) {
case _Profile():
return $default(_that.id,_that.label,_that.currentGroupName,_that.url,_that.lastUpdateDate,_that.autoUpdateDuration,_that.subscriptionInfo,_that.autoUpdate,_that.selectedMap,_that.unfoldSet,_that.overwriteType,_that.scriptId,_that.matchTarget,_that.order);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String label,  String? currentGroupName,  String url,  DateTime? lastUpdateDate,  Duration autoUpdateDuration,  SubscriptionInfo? subscriptionInfo,  bool autoUpdate,  Map<String, String> selectedMap,  Set<String> unfoldSet,  OverwriteType overwriteType,  int? scriptId,  String? matchTarget,  int? order)?  $default,) {final _that = this;
switch (_that) {
case _Profile() when $default != null:
return $default(_that.id,_that.label,_that.currentGroupName,_that.url,_that.lastUpdateDate,_that.autoUpdateDuration,_that.subscriptionInfo,_that.autoUpdate,_that.selectedMap,_that.unfoldSet,_that.overwriteType,_that.scriptId,_that.matchTarget,_that.order);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Profile implements Profile {
  const _Profile({required this.id, this.label = '', this.currentGroupName, this.url = '', this.lastUpdateDate, required this.autoUpdateDuration, this.subscriptionInfo, this.autoUpdate = true,  Map<String, String> selectedMap = const {},  Set<String> unfoldSet = const {}, this.overwriteType = OverwriteType.standard, this.scriptId, this.matchTarget, this.order}): _selectedMap = selectedMap,_unfoldSet = unfoldSet;
  factory _Profile.fromJson(Map<String, dynamic> json) => _$ProfileFromJson(json);

@override final  int id;
@override@JsonKey() final  String label;
@override final  String? currentGroupName;
@override@JsonKey() final  String url;
@override final  DateTime? lastUpdateDate;
@override final  Duration autoUpdateDuration;
@override final  SubscriptionInfo? subscriptionInfo;
@override@JsonKey() final  bool autoUpdate;
 final  Map<String, String> _selectedMap;
@override@JsonKey() Map<String, String> get selectedMap {
  if (_selectedMap is EqualUnmodifiableMapView) return _selectedMap;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_selectedMap);
}

 final  Set<String> _unfoldSet;
@override@JsonKey() Set<String> get unfoldSet {
  if (_unfoldSet is EqualUnmodifiableSetView) return _unfoldSet;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_unfoldSet);
}

@override@JsonKey() final  OverwriteType overwriteType;
@override final  int? scriptId;
@override final  String? matchTarget;
@override final  int? order;

/// Create a copy of Profile
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProfileCopyWith<_Profile> get copyWith => __$ProfileCopyWithImpl<_Profile>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProfileToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Profile&&(identical(other.id, id) || other.id == id)&&(identical(other.label, label) || other.label == label)&&(identical(other.currentGroupName, currentGroupName) || other.currentGroupName == currentGroupName)&&(identical(other.url, url) || other.url == url)&&(identical(other.lastUpdateDate, lastUpdateDate) || other.lastUpdateDate == lastUpdateDate)&&(identical(other.autoUpdateDuration, autoUpdateDuration) || other.autoUpdateDuration == autoUpdateDuration)&&(identical(other.subscriptionInfo, subscriptionInfo) || other.subscriptionInfo == subscriptionInfo)&&(identical(other.autoUpdate, autoUpdate) || other.autoUpdate == autoUpdate)&&const DeepCollectionEquality().equals(other.selectedMap, _selectedMap)&&const DeepCollectionEquality().equals(other.unfoldSet, _unfoldSet)&&(identical(other.overwriteType, overwriteType) || other.overwriteType == overwriteType)&&(identical(other.scriptId, scriptId) || other.scriptId == scriptId)&&(identical(other.matchTarget, matchTarget) || other.matchTarget == matchTarget)&&(identical(other.order, order) || other.order == order));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,label,currentGroupName,url,lastUpdateDate,autoUpdateDuration,subscriptionInfo,autoUpdate,const DeepCollectionEquality().hash(_selectedMap),const DeepCollectionEquality().hash(_unfoldSet),overwriteType,scriptId,matchTarget,order);
}

@override
String toString() {
    return 'Profile(id: $id, label: $label, currentGroupName: $currentGroupName, url: $url, lastUpdateDate: $lastUpdateDate, autoUpdateDuration: $autoUpdateDuration, subscriptionInfo: $subscriptionInfo, autoUpdate: $autoUpdate, selectedMap: $selectedMap, unfoldSet: $unfoldSet, overwriteType: $overwriteType, scriptId: $scriptId, matchTarget: $matchTarget, order: $order)';
}


}

/// @nodoc
abstract mixin class _$ProfileCopyWith<$Res> implements $ProfileCopyWith<$Res> {
  factory _$ProfileCopyWith(_Profile value, $Res Function(_Profile) _then) = __$ProfileCopyWithImpl;
@override @useResult
$Res call({
 int id, String label, String? currentGroupName, String url, DateTime? lastUpdateDate, Duration autoUpdateDuration, SubscriptionInfo? subscriptionInfo, bool autoUpdate, Map<String, String> selectedMap, Set<String> unfoldSet, OverwriteType overwriteType, int? scriptId, String? matchTarget, int? order
});


@override $SubscriptionInfoCopyWith<$Res>? get subscriptionInfo;

}
/// @nodoc
class __$ProfileCopyWithImpl<$Res>
    implements _$ProfileCopyWith<$Res> {
  __$ProfileCopyWithImpl(this._self, this._then);

  final _Profile _self;
  final $Res Function(_Profile) _then;

/// Create a copy of Profile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? label = null,Object? currentGroupName = freezed,Object? url = null,Object? lastUpdateDate = freezed,Object? autoUpdateDuration = null,Object? subscriptionInfo = freezed,Object? autoUpdate = null,Object? selectedMap = null,Object? unfoldSet = null,Object? overwriteType = null,Object? scriptId = freezed,Object? matchTarget = freezed,Object? order = freezed,}) {
  return _then(_Profile(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,currentGroupName: freezed == currentGroupName ? _self.currentGroupName : currentGroupName // ignore: cast_nullable_to_non_nullable
as String?,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,lastUpdateDate: freezed == lastUpdateDate ? _self.lastUpdateDate : lastUpdateDate // ignore: cast_nullable_to_non_nullable
as DateTime?,autoUpdateDuration: null == autoUpdateDuration ? _self.autoUpdateDuration : autoUpdateDuration // ignore: cast_nullable_to_non_nullable
as Duration,subscriptionInfo: freezed == subscriptionInfo ? _self.subscriptionInfo : subscriptionInfo // ignore: cast_nullable_to_non_nullable
as SubscriptionInfo?,autoUpdate: null == autoUpdate ? _self.autoUpdate : autoUpdate // ignore: cast_nullable_to_non_nullable
as bool,selectedMap: null == selectedMap ? _self._selectedMap : selectedMap // ignore: cast_nullable_to_non_nullable
as Map<String, String>,unfoldSet: null == unfoldSet ? _self._unfoldSet : unfoldSet // ignore: cast_nullable_to_non_nullable
as Set<String>,overwriteType: null == overwriteType ? _self.overwriteType : overwriteType // ignore: cast_nullable_to_non_nullable
as OverwriteType,scriptId: freezed == scriptId ? _self.scriptId : scriptId // ignore: cast_nullable_to_non_nullable
as int?,matchTarget: freezed == matchTarget ? _self.matchTarget : matchTarget // ignore: cast_nullable_to_non_nullable
as String?,order: freezed == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

/// Create a copy of Profile
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SubscriptionInfoCopyWith<$Res>? get subscriptionInfo {
    if (_self.subscriptionInfo == null) {
    return null;
  }

  return $SubscriptionInfoCopyWith<$Res>(_self.subscriptionInfo!, (value) {
    return _then(_self.copyWith(subscriptionInfo: value));
  });
}
}

/// @nodoc
mixin _$ProfileRuleLink {

 int? get profileId; int get ruleId; RuleScene? get scene; String? get order;
/// Create a copy of ProfileRuleLink
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProfileRuleLinkCopyWith<ProfileRuleLink> get copyWith => _$ProfileRuleLinkCopyWithImpl<ProfileRuleLink>(this as ProfileRuleLink, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ProfileRuleLink;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProfileRuleLink&&(identical(other.profileId, _this.profileId) || other.profileId == _this.profileId)&&(identical(other.ruleId, _this.ruleId) || other.ruleId == _this.ruleId)&&(identical(other.scene, _this.scene) || other.scene == _this.scene)&&(identical(other.order, _this.order) || other.order == _this.order));
}


@override
int get hashCode {
  final _this = this as ProfileRuleLink;
  return Object.hash(runtimeType,_this.profileId,_this.ruleId,_this.scene,_this.order);
}

@override
String toString() {
  final _this = this as ProfileRuleLink;
  return 'ProfileRuleLink(profileId: ${_this.profileId}, ruleId: ${_this.ruleId}, scene: ${_this.scene}, order: ${_this.order})';
}


}

/// @nodoc
abstract mixin class $ProfileRuleLinkCopyWith<$Res>  {
  factory $ProfileRuleLinkCopyWith(ProfileRuleLink value, $Res Function(ProfileRuleLink) _then) = _$ProfileRuleLinkCopyWithImpl;
@useResult
$Res call({
 int? profileId, int ruleId, RuleScene? scene, String? order
});




}
/// @nodoc
class _$ProfileRuleLinkCopyWithImpl<$Res>
    implements $ProfileRuleLinkCopyWith<$Res> {
  _$ProfileRuleLinkCopyWithImpl(this._self, this._then);

  final ProfileRuleLink _self;
  final $Res Function(ProfileRuleLink) _then;

/// Create a copy of ProfileRuleLink
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? profileId = freezed,Object? ruleId = null,Object? scene = freezed,Object? order = freezed,}) {
  return _then(ProfileRuleLink(
profileId: freezed == profileId ? _self.profileId : profileId // ignore: cast_nullable_to_non_nullable
as int?,ruleId: null == ruleId ? _self.ruleId : ruleId // ignore: cast_nullable_to_non_nullable
as int,scene: freezed == scene ? _self.scene : scene // ignore: cast_nullable_to_non_nullable
as RuleScene?,order: freezed == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ProfileRuleLink].
extension ProfileRuleLinkPatterns on ProfileRuleLink {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProfileRuleLink value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProfileRuleLink() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProfileRuleLink value)  $default,){
final _that = this;
switch (_that) {
case _ProfileRuleLink():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProfileRuleLink value)?  $default,){
final _that = this;
switch (_that) {
case _ProfileRuleLink() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? profileId,  int ruleId,  RuleScene? scene,  String? order)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProfileRuleLink() when $default != null:
return $default(_that.profileId,_that.ruleId,_that.scene,_that.order);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? profileId,  int ruleId,  RuleScene? scene,  String? order)  $default,) {final _that = this;
switch (_that) {
case _ProfileRuleLink():
return $default(_that.profileId,_that.ruleId,_that.scene,_that.order);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? profileId,  int ruleId,  RuleScene? scene,  String? order)?  $default,) {final _that = this;
switch (_that) {
case _ProfileRuleLink() when $default != null:
return $default(_that.profileId,_that.ruleId,_that.scene,_that.order);case _:
  return null;

}
}

}

/// @nodoc


class _ProfileRuleLink implements ProfileRuleLink {
  const _ProfileRuleLink({this.profileId, required this.ruleId, this.scene, this.order});
  

@override final  int? profileId;
@override final  int ruleId;
@override final  RuleScene? scene;
@override final  String? order;

/// Create a copy of ProfileRuleLink
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProfileRuleLinkCopyWith<_ProfileRuleLink> get copyWith => __$ProfileRuleLinkCopyWithImpl<_ProfileRuleLink>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProfileRuleLink&&(identical(other.profileId, profileId) || other.profileId == profileId)&&(identical(other.ruleId, ruleId) || other.ruleId == ruleId)&&(identical(other.scene, scene) || other.scene == scene)&&(identical(other.order, order) || other.order == order));
}


@override
int get hashCode {
    return Object.hash(runtimeType,profileId,ruleId,scene,order);
}

@override
String toString() {
    return 'ProfileRuleLink(profileId: $profileId, ruleId: $ruleId, scene: $scene, order: $order)';
}


}

/// @nodoc
abstract mixin class _$ProfileRuleLinkCopyWith<$Res> implements $ProfileRuleLinkCopyWith<$Res> {
  factory _$ProfileRuleLinkCopyWith(_ProfileRuleLink value, $Res Function(_ProfileRuleLink) _then) = __$ProfileRuleLinkCopyWithImpl;
@override @useResult
$Res call({
 int? profileId, int ruleId, RuleScene? scene, String? order
});




}
/// @nodoc
class __$ProfileRuleLinkCopyWithImpl<$Res>
    implements _$ProfileRuleLinkCopyWith<$Res> {
  __$ProfileRuleLinkCopyWithImpl(this._self, this._then);

  final _ProfileRuleLink _self;
  final $Res Function(_ProfileRuleLink) _then;

/// Create a copy of ProfileRuleLink
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? profileId = freezed,Object? ruleId = null,Object? scene = freezed,Object? order = freezed,}) {
  return _then(_ProfileRuleLink(
profileId: freezed == profileId ? _self.profileId : profileId // ignore: cast_nullable_to_non_nullable
as int?,ruleId: null == ruleId ? _self.ruleId : ruleId // ignore: cast_nullable_to_non_nullable
as int,scene: freezed == scene ? _self.scene : scene // ignore: cast_nullable_to_non_nullable
as RuleScene?,order: freezed == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$StandardOverwrite {

 List<Rule> get addedRules; List<int> get disabledRuleIds;
/// Create a copy of StandardOverwrite
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StandardOverwriteCopyWith<StandardOverwrite> get copyWith => _$StandardOverwriteCopyWithImpl<StandardOverwrite>(this as StandardOverwrite, _$identity);

  /// Serializes this StandardOverwrite to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as StandardOverwrite;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StandardOverwrite&&const DeepCollectionEquality().equals(other.addedRules, _this.addedRules)&&const DeepCollectionEquality().equals(other.disabledRuleIds, _this.disabledRuleIds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as StandardOverwrite;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.addedRules),const DeepCollectionEquality().hash(_this.disabledRuleIds));
}

@override
String toString() {
  final _this = this as StandardOverwrite;
  return 'StandardOverwrite(addedRules: ${_this.addedRules}, disabledRuleIds: ${_this.disabledRuleIds})';
}


}

/// @nodoc
abstract mixin class $StandardOverwriteCopyWith<$Res>  {
  factory $StandardOverwriteCopyWith(StandardOverwrite value, $Res Function(StandardOverwrite) _then) = _$StandardOverwriteCopyWithImpl;
@useResult
$Res call({
 List<Rule> addedRules, List<int> disabledRuleIds
});




}
/// @nodoc
class _$StandardOverwriteCopyWithImpl<$Res>
    implements $StandardOverwriteCopyWith<$Res> {
  _$StandardOverwriteCopyWithImpl(this._self, this._then);

  final StandardOverwrite _self;
  final $Res Function(StandardOverwrite) _then;

/// Create a copy of StandardOverwrite
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? addedRules = null,Object? disabledRuleIds = null,}) {
  return _then(StandardOverwrite(
addedRules: null == addedRules ? _self.addedRules : addedRules // ignore: cast_nullable_to_non_nullable
as List<Rule>,disabledRuleIds: null == disabledRuleIds ? _self.disabledRuleIds : disabledRuleIds // ignore: cast_nullable_to_non_nullable
as List<int>,
  ));
}

}


/// Adds pattern-matching-related methods to [StandardOverwrite].
extension StandardOverwritePatterns on StandardOverwrite {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StandardOverwrite value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StandardOverwrite() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StandardOverwrite value)  $default,){
final _that = this;
switch (_that) {
case _StandardOverwrite():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StandardOverwrite value)?  $default,){
final _that = this;
switch (_that) {
case _StandardOverwrite() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<Rule> addedRules,  List<int> disabledRuleIds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StandardOverwrite() when $default != null:
return $default(_that.addedRules,_that.disabledRuleIds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<Rule> addedRules,  List<int> disabledRuleIds)  $default,) {final _that = this;
switch (_that) {
case _StandardOverwrite():
return $default(_that.addedRules,_that.disabledRuleIds);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<Rule> addedRules,  List<int> disabledRuleIds)?  $default,) {final _that = this;
switch (_that) {
case _StandardOverwrite() when $default != null:
return $default(_that.addedRules,_that.disabledRuleIds);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StandardOverwrite implements StandardOverwrite {
  const _StandardOverwrite({ List<Rule> addedRules = const [],  List<int> disabledRuleIds = const []}): _addedRules = addedRules,_disabledRuleIds = disabledRuleIds;
  factory _StandardOverwrite.fromJson(Map<String, dynamic> json) => _$StandardOverwriteFromJson(json);

 final  List<Rule> _addedRules;
@override@JsonKey() List<Rule> get addedRules {
  if (_addedRules is EqualUnmodifiableListView) return _addedRules;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_addedRules);
}

 final  List<int> _disabledRuleIds;
@override@JsonKey() List<int> get disabledRuleIds {
  if (_disabledRuleIds is EqualUnmodifiableListView) return _disabledRuleIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_disabledRuleIds);
}


/// Create a copy of StandardOverwrite
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StandardOverwriteCopyWith<_StandardOverwrite> get copyWith => __$StandardOverwriteCopyWithImpl<_StandardOverwrite>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StandardOverwriteToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _StandardOverwrite&&const DeepCollectionEquality().equals(other.addedRules, _addedRules)&&const DeepCollectionEquality().equals(other.disabledRuleIds, _disabledRuleIds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_addedRules),const DeepCollectionEquality().hash(_disabledRuleIds));
}

@override
String toString() {
    return 'StandardOverwrite(addedRules: $addedRules, disabledRuleIds: $disabledRuleIds)';
}


}

/// @nodoc
abstract mixin class _$StandardOverwriteCopyWith<$Res> implements $StandardOverwriteCopyWith<$Res> {
  factory _$StandardOverwriteCopyWith(_StandardOverwrite value, $Res Function(_StandardOverwrite) _then) = __$StandardOverwriteCopyWithImpl;
@override @useResult
$Res call({
 List<Rule> addedRules, List<int> disabledRuleIds
});




}
/// @nodoc
class __$StandardOverwriteCopyWithImpl<$Res>
    implements _$StandardOverwriteCopyWith<$Res> {
  __$StandardOverwriteCopyWithImpl(this._self, this._then);

  final _StandardOverwrite _self;
  final $Res Function(_StandardOverwrite) _then;

/// Create a copy of StandardOverwrite
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? addedRules = null,Object? disabledRuleIds = null,}) {
  return _then(_StandardOverwrite(
addedRules: null == addedRules ? _self._addedRules : addedRules // ignore: cast_nullable_to_non_nullable
as List<Rule>,disabledRuleIds: null == disabledRuleIds ? _self._disabledRuleIds : disabledRuleIds // ignore: cast_nullable_to_non_nullable
as List<int>,
  ));
}


}


/// @nodoc
mixin _$ScriptOverwrite {

 int? get scriptId;
/// Create a copy of ScriptOverwrite
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ScriptOverwriteCopyWith<ScriptOverwrite> get copyWith => _$ScriptOverwriteCopyWithImpl<ScriptOverwrite>(this as ScriptOverwrite, _$identity);

  /// Serializes this ScriptOverwrite to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ScriptOverwrite;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ScriptOverwrite&&(identical(other.scriptId, _this.scriptId) || other.scriptId == _this.scriptId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ScriptOverwrite;
  return Object.hash(runtimeType,_this.scriptId);
}

@override
String toString() {
  final _this = this as ScriptOverwrite;
  return 'ScriptOverwrite(scriptId: ${_this.scriptId})';
}


}

/// @nodoc
abstract mixin class $ScriptOverwriteCopyWith<$Res>  {
  factory $ScriptOverwriteCopyWith(ScriptOverwrite value, $Res Function(ScriptOverwrite) _then) = _$ScriptOverwriteCopyWithImpl;
@useResult
$Res call({
 int? scriptId
});




}
/// @nodoc
class _$ScriptOverwriteCopyWithImpl<$Res>
    implements $ScriptOverwriteCopyWith<$Res> {
  _$ScriptOverwriteCopyWithImpl(this._self, this._then);

  final ScriptOverwrite _self;
  final $Res Function(ScriptOverwrite) _then;

/// Create a copy of ScriptOverwrite
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? scriptId = freezed,}) {
  return _then(ScriptOverwrite(
scriptId: freezed == scriptId ? _self.scriptId : scriptId // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [ScriptOverwrite].
extension ScriptOverwritePatterns on ScriptOverwrite {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ScriptOverwrite value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ScriptOverwrite() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ScriptOverwrite value)  $default,){
final _that = this;
switch (_that) {
case _ScriptOverwrite():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ScriptOverwrite value)?  $default,){
final _that = this;
switch (_that) {
case _ScriptOverwrite() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? scriptId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ScriptOverwrite() when $default != null:
return $default(_that.scriptId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? scriptId)  $default,) {final _that = this;
switch (_that) {
case _ScriptOverwrite():
return $default(_that.scriptId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? scriptId)?  $default,) {final _that = this;
switch (_that) {
case _ScriptOverwrite() when $default != null:
return $default(_that.scriptId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ScriptOverwrite implements ScriptOverwrite {
  const _ScriptOverwrite({this.scriptId});
  factory _ScriptOverwrite.fromJson(Map<String, dynamic> json) => _$ScriptOverwriteFromJson(json);

@override final  int? scriptId;

/// Create a copy of ScriptOverwrite
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ScriptOverwriteCopyWith<_ScriptOverwrite> get copyWith => __$ScriptOverwriteCopyWithImpl<_ScriptOverwrite>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ScriptOverwriteToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ScriptOverwrite&&(identical(other.scriptId, scriptId) || other.scriptId == scriptId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,scriptId);
}

@override
String toString() {
    return 'ScriptOverwrite(scriptId: $scriptId)';
}


}

/// @nodoc
abstract mixin class _$ScriptOverwriteCopyWith<$Res> implements $ScriptOverwriteCopyWith<$Res> {
  factory _$ScriptOverwriteCopyWith(_ScriptOverwrite value, $Res Function(_ScriptOverwrite) _then) = __$ScriptOverwriteCopyWithImpl;
@override @useResult
$Res call({
 int? scriptId
});




}
/// @nodoc
class __$ScriptOverwriteCopyWithImpl<$Res>
    implements _$ScriptOverwriteCopyWith<$Res> {
  __$ScriptOverwriteCopyWithImpl(this._self, this._then);

  final _ScriptOverwrite _self;
  final $Res Function(_ScriptOverwrite) _then;

/// Create a copy of ScriptOverwrite
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? scriptId = freezed,}) {
  return _then(_ScriptOverwrite(
scriptId: freezed == scriptId ? _self.scriptId : scriptId // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
