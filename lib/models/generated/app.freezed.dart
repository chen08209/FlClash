// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../app.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AppState {

 bool get isInit; bool get backBlock; PageLabel get pageLabel; List<Package> get packages; int get sortNum; Size get viewSize; double get sideWidth; DelayMap get delayMap; List<Group> get groups; int get checkIpNum; Brightness get brightness; int? get runTime; List<ExternalProvider> get providers; String? get localIp; FixedList<TrackerInfo> get requests; int get version; FixedList<Log> get logs; FixedList<Traffic> get traffics; Traffic get totalTraffic; bool get realTunEnable; bool get loading; SystemUiOverlayStyle get systemUiOverlayStyle; ProfileOverrideModel? get profileOverrideModel; Map<QueryTag, String> get queryMap; CoreStatus get coreStatus;
/// Create a copy of AppState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppStateCopyWith<AppState> get copyWith => _$AppStateCopyWithImpl<AppState>(this as AppState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppState&&(identical(other.isInit, isInit) || other.isInit == isInit)&&(identical(other.backBlock, backBlock) || other.backBlock == backBlock)&&(identical(other.pageLabel, pageLabel) || other.pageLabel == pageLabel)&&const DeepCollectionEquality().equals(other.packages, packages)&&(identical(other.sortNum, sortNum) || other.sortNum == sortNum)&&(identical(other.viewSize, viewSize) || other.viewSize == viewSize)&&(identical(other.sideWidth, sideWidth) || other.sideWidth == sideWidth)&&const DeepCollectionEquality().equals(other.delayMap, delayMap)&&const DeepCollectionEquality().equals(other.groups, groups)&&(identical(other.checkIpNum, checkIpNum) || other.checkIpNum == checkIpNum)&&(identical(other.brightness, brightness) || other.brightness == brightness)&&(identical(other.runTime, runTime) || other.runTime == runTime)&&const DeepCollectionEquality().equals(other.providers, providers)&&(identical(other.localIp, localIp) || other.localIp == localIp)&&(identical(other.requests, requests) || other.requests == requests)&&(identical(other.version, version) || other.version == version)&&(identical(other.logs, logs) || other.logs == logs)&&(identical(other.traffics, traffics) || other.traffics == traffics)&&(identical(other.totalTraffic, totalTraffic) || other.totalTraffic == totalTraffic)&&(identical(other.realTunEnable, realTunEnable) || other.realTunEnable == realTunEnable)&&(identical(other.loading, loading) || other.loading == loading)&&(identical(other.systemUiOverlayStyle, systemUiOverlayStyle) || other.systemUiOverlayStyle == systemUiOverlayStyle)&&(identical(other.profileOverrideModel, profileOverrideModel) || other.profileOverrideModel == profileOverrideModel)&&const DeepCollectionEquality().equals(other.queryMap, queryMap)&&(identical(other.coreStatus, coreStatus) || other.coreStatus == coreStatus));
}


@override
int get hashCode => Object.hashAll([runtimeType,isInit,backBlock,pageLabel,const DeepCollectionEquality().hash(packages),sortNum,viewSize,sideWidth,const DeepCollectionEquality().hash(delayMap),const DeepCollectionEquality().hash(groups),checkIpNum,brightness,runTime,const DeepCollectionEquality().hash(providers),localIp,requests,version,logs,traffics,totalTraffic,realTunEnable,loading,systemUiOverlayStyle,profileOverrideModel,const DeepCollectionEquality().hash(queryMap),coreStatus]);

@override
String toString() {
  return 'AppState(isInit: $isInit, backBlock: $backBlock, pageLabel: $pageLabel, packages: $packages, sortNum: $sortNum, viewSize: $viewSize, sideWidth: $sideWidth, delayMap: $delayMap, groups: $groups, checkIpNum: $checkIpNum, brightness: $brightness, runTime: $runTime, providers: $providers, localIp: $localIp, requests: $requests, version: $version, logs: $logs, traffics: $traffics, totalTraffic: $totalTraffic, realTunEnable: $realTunEnable, loading: $loading, systemUiOverlayStyle: $systemUiOverlayStyle, profileOverrideModel: $profileOverrideModel, queryMap: $queryMap, coreStatus: $coreStatus)';
}


}

/// @nodoc
abstract mixin class $AppStateCopyWith<$Res>  {
  factory $AppStateCopyWith(AppState value, $Res Function(AppState) _then) = _$AppStateCopyWithImpl;
@useResult
$Res call({
 bool isInit, bool backBlock, PageLabel pageLabel, List<Package> packages, int sortNum, Size viewSize, double sideWidth, DelayMap delayMap, List<Group> groups, int checkIpNum, Brightness brightness, int? runTime, List<ExternalProvider> providers, String? localIp, FixedList<TrackerInfo> requests, int version, FixedList<Log> logs, FixedList<Traffic> traffics, Traffic totalTraffic, bool realTunEnable, bool loading, SystemUiOverlayStyle systemUiOverlayStyle, ProfileOverrideModel? profileOverrideModel, Map<QueryTag, String> queryMap, CoreStatus coreStatus
});


$TrafficCopyWith<$Res> get totalTraffic;$ProfileOverrideModelCopyWith<$Res>? get profileOverrideModel;

}
/// @nodoc
class _$AppStateCopyWithImpl<$Res>
    implements $AppStateCopyWith<$Res> {
  _$AppStateCopyWithImpl(this._self, this._then);

  final AppState _self;
  final $Res Function(AppState) _then;

/// Create a copy of AppState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isInit = null,Object? backBlock = null,Object? pageLabel = null,Object? packages = null,Object? sortNum = null,Object? viewSize = null,Object? sideWidth = null,Object? delayMap = null,Object? groups = null,Object? checkIpNum = null,Object? brightness = null,Object? runTime = freezed,Object? providers = null,Object? localIp = freezed,Object? requests = null,Object? version = null,Object? logs = null,Object? traffics = null,Object? totalTraffic = null,Object? realTunEnable = null,Object? loading = null,Object? systemUiOverlayStyle = null,Object? profileOverrideModel = freezed,Object? queryMap = null,Object? coreStatus = null,}) {
  return _then(_self.copyWith(
isInit: null == isInit ? _self.isInit : isInit // ignore: cast_nullable_to_non_nullable
as bool,backBlock: null == backBlock ? _self.backBlock : backBlock // ignore: cast_nullable_to_non_nullable
as bool,pageLabel: null == pageLabel ? _self.pageLabel : pageLabel // ignore: cast_nullable_to_non_nullable
as PageLabel,packages: null == packages ? _self.packages : packages // ignore: cast_nullable_to_non_nullable
as List<Package>,sortNum: null == sortNum ? _self.sortNum : sortNum // ignore: cast_nullable_to_non_nullable
as int,viewSize: null == viewSize ? _self.viewSize : viewSize // ignore: cast_nullable_to_non_nullable
as Size,sideWidth: null == sideWidth ? _self.sideWidth : sideWidth // ignore: cast_nullable_to_non_nullable
as double,delayMap: null == delayMap ? _self.delayMap : delayMap // ignore: cast_nullable_to_non_nullable
as DelayMap,groups: null == groups ? _self.groups : groups // ignore: cast_nullable_to_non_nullable
as List<Group>,checkIpNum: null == checkIpNum ? _self.checkIpNum : checkIpNum // ignore: cast_nullable_to_non_nullable
as int,brightness: null == brightness ? _self.brightness : brightness // ignore: cast_nullable_to_non_nullable
as Brightness,runTime: freezed == runTime ? _self.runTime : runTime // ignore: cast_nullable_to_non_nullable
as int?,providers: null == providers ? _self.providers : providers // ignore: cast_nullable_to_non_nullable
as List<ExternalProvider>,localIp: freezed == localIp ? _self.localIp : localIp // ignore: cast_nullable_to_non_nullable
as String?,requests: null == requests ? _self.requests : requests // ignore: cast_nullable_to_non_nullable
as FixedList<TrackerInfo>,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,logs: null == logs ? _self.logs : logs // ignore: cast_nullable_to_non_nullable
as FixedList<Log>,traffics: null == traffics ? _self.traffics : traffics // ignore: cast_nullable_to_non_nullable
as FixedList<Traffic>,totalTraffic: null == totalTraffic ? _self.totalTraffic : totalTraffic // ignore: cast_nullable_to_non_nullable
as Traffic,realTunEnable: null == realTunEnable ? _self.realTunEnable : realTunEnable // ignore: cast_nullable_to_non_nullable
as bool,loading: null == loading ? _self.loading : loading // ignore: cast_nullable_to_non_nullable
as bool,systemUiOverlayStyle: null == systemUiOverlayStyle ? _self.systemUiOverlayStyle : systemUiOverlayStyle // ignore: cast_nullable_to_non_nullable
as SystemUiOverlayStyle,profileOverrideModel: freezed == profileOverrideModel ? _self.profileOverrideModel : profileOverrideModel // ignore: cast_nullable_to_non_nullable
as ProfileOverrideModel?,queryMap: null == queryMap ? _self.queryMap : queryMap // ignore: cast_nullable_to_non_nullable
as Map<QueryTag, String>,coreStatus: null == coreStatus ? _self.coreStatus : coreStatus // ignore: cast_nullable_to_non_nullable
as CoreStatus,
  ));
}
/// Create a copy of AppState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TrafficCopyWith<$Res> get totalTraffic {
  
  return $TrafficCopyWith<$Res>(_self.totalTraffic, (value) {
    return _then(_self.copyWith(totalTraffic: value));
  });
}/// Create a copy of AppState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProfileOverrideModelCopyWith<$Res>? get profileOverrideModel {
    if (_self.profileOverrideModel == null) {
    return null;
  }

  return $ProfileOverrideModelCopyWith<$Res>(_self.profileOverrideModel!, (value) {
    return _then(_self.copyWith(profileOverrideModel: value));
  });
}
}


/// Adds pattern-matching-related methods to [AppState].
extension AppStatePatterns on AppState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AppState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AppState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AppState value)  $default,){
final _that = this;
switch (_that) {
case _AppState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AppState value)?  $default,){
final _that = this;
switch (_that) {
case _AppState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isInit,  bool backBlock,  PageLabel pageLabel,  List<Package> packages,  int sortNum,  Size viewSize,  double sideWidth,  DelayMap delayMap,  List<Group> groups,  int checkIpNum,  Brightness brightness,  int? runTime,  List<ExternalProvider> providers,  String? localIp,  FixedList<TrackerInfo> requests,  int version,  FixedList<Log> logs,  FixedList<Traffic> traffics,  Traffic totalTraffic,  bool realTunEnable,  bool loading,  SystemUiOverlayStyle systemUiOverlayStyle,  ProfileOverrideModel? profileOverrideModel,  Map<QueryTag, String> queryMap,  CoreStatus coreStatus)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppState() when $default != null:
return $default(_that.isInit,_that.backBlock,_that.pageLabel,_that.packages,_that.sortNum,_that.viewSize,_that.sideWidth,_that.delayMap,_that.groups,_that.checkIpNum,_that.brightness,_that.runTime,_that.providers,_that.localIp,_that.requests,_that.version,_that.logs,_that.traffics,_that.totalTraffic,_that.realTunEnable,_that.loading,_that.systemUiOverlayStyle,_that.profileOverrideModel,_that.queryMap,_that.coreStatus);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isInit,  bool backBlock,  PageLabel pageLabel,  List<Package> packages,  int sortNum,  Size viewSize,  double sideWidth,  DelayMap delayMap,  List<Group> groups,  int checkIpNum,  Brightness brightness,  int? runTime,  List<ExternalProvider> providers,  String? localIp,  FixedList<TrackerInfo> requests,  int version,  FixedList<Log> logs,  FixedList<Traffic> traffics,  Traffic totalTraffic,  bool realTunEnable,  bool loading,  SystemUiOverlayStyle systemUiOverlayStyle,  ProfileOverrideModel? profileOverrideModel,  Map<QueryTag, String> queryMap,  CoreStatus coreStatus)  $default,) {final _that = this;
switch (_that) {
case _AppState():
return $default(_that.isInit,_that.backBlock,_that.pageLabel,_that.packages,_that.sortNum,_that.viewSize,_that.sideWidth,_that.delayMap,_that.groups,_that.checkIpNum,_that.brightness,_that.runTime,_that.providers,_that.localIp,_that.requests,_that.version,_that.logs,_that.traffics,_that.totalTraffic,_that.realTunEnable,_that.loading,_that.systemUiOverlayStyle,_that.profileOverrideModel,_that.queryMap,_that.coreStatus);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isInit,  bool backBlock,  PageLabel pageLabel,  List<Package> packages,  int sortNum,  Size viewSize,  double sideWidth,  DelayMap delayMap,  List<Group> groups,  int checkIpNum,  Brightness brightness,  int? runTime,  List<ExternalProvider> providers,  String? localIp,  FixedList<TrackerInfo> requests,  int version,  FixedList<Log> logs,  FixedList<Traffic> traffics,  Traffic totalTraffic,  bool realTunEnable,  bool loading,  SystemUiOverlayStyle systemUiOverlayStyle,  ProfileOverrideModel? profileOverrideModel,  Map<QueryTag, String> queryMap,  CoreStatus coreStatus)?  $default,) {final _that = this;
switch (_that) {
case _AppState() when $default != null:
return $default(_that.isInit,_that.backBlock,_that.pageLabel,_that.packages,_that.sortNum,_that.viewSize,_that.sideWidth,_that.delayMap,_that.groups,_that.checkIpNum,_that.brightness,_that.runTime,_that.providers,_that.localIp,_that.requests,_that.version,_that.logs,_that.traffics,_that.totalTraffic,_that.realTunEnable,_that.loading,_that.systemUiOverlayStyle,_that.profileOverrideModel,_that.queryMap,_that.coreStatus);case _:
  return null;

}
}

}

/// @nodoc


class _AppState implements AppState {
  const _AppState({this.isInit = false, this.backBlock = false, this.pageLabel = PageLabel.dashboard, final  List<Package> packages = const [], this.sortNum = 0, required this.viewSize, this.sideWidth = 0, final  DelayMap delayMap = const {}, final  List<Group> groups = const [], this.checkIpNum = 0, required this.brightness, this.runTime, final  List<ExternalProvider> providers = const [], this.localIp, required this.requests, required this.version, required this.logs, required this.traffics, required this.totalTraffic, this.realTunEnable = false, this.loading = false, required this.systemUiOverlayStyle, this.profileOverrideModel, final  Map<QueryTag, String> queryMap = const {}, this.coreStatus = CoreStatus.connecting}): _packages = packages,_delayMap = delayMap,_groups = groups,_providers = providers,_queryMap = queryMap;
  

@override@JsonKey() final  bool isInit;
@override@JsonKey() final  bool backBlock;
@override@JsonKey() final  PageLabel pageLabel;
 final  List<Package> _packages;
@override@JsonKey() List<Package> get packages {
  if (_packages is EqualUnmodifiableListView) return _packages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_packages);
}

@override@JsonKey() final  int sortNum;
@override final  Size viewSize;
@override@JsonKey() final  double sideWidth;
 final  DelayMap _delayMap;
@override@JsonKey() DelayMap get delayMap {
  if (_delayMap is EqualUnmodifiableMapView) return _delayMap;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_delayMap);
}

 final  List<Group> _groups;
@override@JsonKey() List<Group> get groups {
  if (_groups is EqualUnmodifiableListView) return _groups;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_groups);
}

@override@JsonKey() final  int checkIpNum;
@override final  Brightness brightness;
@override final  int? runTime;
 final  List<ExternalProvider> _providers;
@override@JsonKey() List<ExternalProvider> get providers {
  if (_providers is EqualUnmodifiableListView) return _providers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_providers);
}

@override final  String? localIp;
@override final  FixedList<TrackerInfo> requests;
@override final  int version;
@override final  FixedList<Log> logs;
@override final  FixedList<Traffic> traffics;
@override final  Traffic totalTraffic;
@override@JsonKey() final  bool realTunEnable;
@override@JsonKey() final  bool loading;
@override final  SystemUiOverlayStyle systemUiOverlayStyle;
@override final  ProfileOverrideModel? profileOverrideModel;
 final  Map<QueryTag, String> _queryMap;
@override@JsonKey() Map<QueryTag, String> get queryMap {
  if (_queryMap is EqualUnmodifiableMapView) return _queryMap;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_queryMap);
}

@override@JsonKey() final  CoreStatus coreStatus;

/// Create a copy of AppState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppStateCopyWith<_AppState> get copyWith => __$AppStateCopyWithImpl<_AppState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppState&&(identical(other.isInit, isInit) || other.isInit == isInit)&&(identical(other.backBlock, backBlock) || other.backBlock == backBlock)&&(identical(other.pageLabel, pageLabel) || other.pageLabel == pageLabel)&&const DeepCollectionEquality().equals(other._packages, _packages)&&(identical(other.sortNum, sortNum) || other.sortNum == sortNum)&&(identical(other.viewSize, viewSize) || other.viewSize == viewSize)&&(identical(other.sideWidth, sideWidth) || other.sideWidth == sideWidth)&&const DeepCollectionEquality().equals(other._delayMap, _delayMap)&&const DeepCollectionEquality().equals(other._groups, _groups)&&(identical(other.checkIpNum, checkIpNum) || other.checkIpNum == checkIpNum)&&(identical(other.brightness, brightness) || other.brightness == brightness)&&(identical(other.runTime, runTime) || other.runTime == runTime)&&const DeepCollectionEquality().equals(other._providers, _providers)&&(identical(other.localIp, localIp) || other.localIp == localIp)&&(identical(other.requests, requests) || other.requests == requests)&&(identical(other.version, version) || other.version == version)&&(identical(other.logs, logs) || other.logs == logs)&&(identical(other.traffics, traffics) || other.traffics == traffics)&&(identical(other.totalTraffic, totalTraffic) || other.totalTraffic == totalTraffic)&&(identical(other.realTunEnable, realTunEnable) || other.realTunEnable == realTunEnable)&&(identical(other.loading, loading) || other.loading == loading)&&(identical(other.systemUiOverlayStyle, systemUiOverlayStyle) || other.systemUiOverlayStyle == systemUiOverlayStyle)&&(identical(other.profileOverrideModel, profileOverrideModel) || other.profileOverrideModel == profileOverrideModel)&&const DeepCollectionEquality().equals(other._queryMap, _queryMap)&&(identical(other.coreStatus, coreStatus) || other.coreStatus == coreStatus));
}


@override
int get hashCode => Object.hashAll([runtimeType,isInit,backBlock,pageLabel,const DeepCollectionEquality().hash(_packages),sortNum,viewSize,sideWidth,const DeepCollectionEquality().hash(_delayMap),const DeepCollectionEquality().hash(_groups),checkIpNum,brightness,runTime,const DeepCollectionEquality().hash(_providers),localIp,requests,version,logs,traffics,totalTraffic,realTunEnable,loading,systemUiOverlayStyle,profileOverrideModel,const DeepCollectionEquality().hash(_queryMap),coreStatus]);

@override
String toString() {
  return 'AppState(isInit: $isInit, backBlock: $backBlock, pageLabel: $pageLabel, packages: $packages, sortNum: $sortNum, viewSize: $viewSize, sideWidth: $sideWidth, delayMap: $delayMap, groups: $groups, checkIpNum: $checkIpNum, brightness: $brightness, runTime: $runTime, providers: $providers, localIp: $localIp, requests: $requests, version: $version, logs: $logs, traffics: $traffics, totalTraffic: $totalTraffic, realTunEnable: $realTunEnable, loading: $loading, systemUiOverlayStyle: $systemUiOverlayStyle, profileOverrideModel: $profileOverrideModel, queryMap: $queryMap, coreStatus: $coreStatus)';
}


}

/// @nodoc
abstract mixin class _$AppStateCopyWith<$Res> implements $AppStateCopyWith<$Res> {
  factory _$AppStateCopyWith(_AppState value, $Res Function(_AppState) _then) = __$AppStateCopyWithImpl;
@override @useResult
$Res call({
 bool isInit, bool backBlock, PageLabel pageLabel, List<Package> packages, int sortNum, Size viewSize, double sideWidth, DelayMap delayMap, List<Group> groups, int checkIpNum, Brightness brightness, int? runTime, List<ExternalProvider> providers, String? localIp, FixedList<TrackerInfo> requests, int version, FixedList<Log> logs, FixedList<Traffic> traffics, Traffic totalTraffic, bool realTunEnable, bool loading, SystemUiOverlayStyle systemUiOverlayStyle, ProfileOverrideModel? profileOverrideModel, Map<QueryTag, String> queryMap, CoreStatus coreStatus
});


@override $TrafficCopyWith<$Res> get totalTraffic;@override $ProfileOverrideModelCopyWith<$Res>? get profileOverrideModel;

}
/// @nodoc
class __$AppStateCopyWithImpl<$Res>
    implements _$AppStateCopyWith<$Res> {
  __$AppStateCopyWithImpl(this._self, this._then);

  final _AppState _self;
  final $Res Function(_AppState) _then;

/// Create a copy of AppState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isInit = null,Object? backBlock = null,Object? pageLabel = null,Object? packages = null,Object? sortNum = null,Object? viewSize = null,Object? sideWidth = null,Object? delayMap = null,Object? groups = null,Object? checkIpNum = null,Object? brightness = null,Object? runTime = freezed,Object? providers = null,Object? localIp = freezed,Object? requests = null,Object? version = null,Object? logs = null,Object? traffics = null,Object? totalTraffic = null,Object? realTunEnable = null,Object? loading = null,Object? systemUiOverlayStyle = null,Object? profileOverrideModel = freezed,Object? queryMap = null,Object? coreStatus = null,}) {
  return _then(_AppState(
isInit: null == isInit ? _self.isInit : isInit // ignore: cast_nullable_to_non_nullable
as bool,backBlock: null == backBlock ? _self.backBlock : backBlock // ignore: cast_nullable_to_non_nullable
as bool,pageLabel: null == pageLabel ? _self.pageLabel : pageLabel // ignore: cast_nullable_to_non_nullable
as PageLabel,packages: null == packages ? _self._packages : packages // ignore: cast_nullable_to_non_nullable
as List<Package>,sortNum: null == sortNum ? _self.sortNum : sortNum // ignore: cast_nullable_to_non_nullable
as int,viewSize: null == viewSize ? _self.viewSize : viewSize // ignore: cast_nullable_to_non_nullable
as Size,sideWidth: null == sideWidth ? _self.sideWidth : sideWidth // ignore: cast_nullable_to_non_nullable
as double,delayMap: null == delayMap ? _self._delayMap : delayMap // ignore: cast_nullable_to_non_nullable
as DelayMap,groups: null == groups ? _self._groups : groups // ignore: cast_nullable_to_non_nullable
as List<Group>,checkIpNum: null == checkIpNum ? _self.checkIpNum : checkIpNum // ignore: cast_nullable_to_non_nullable
as int,brightness: null == brightness ? _self.brightness : brightness // ignore: cast_nullable_to_non_nullable
as Brightness,runTime: freezed == runTime ? _self.runTime : runTime // ignore: cast_nullable_to_non_nullable
as int?,providers: null == providers ? _self._providers : providers // ignore: cast_nullable_to_non_nullable
as List<ExternalProvider>,localIp: freezed == localIp ? _self.localIp : localIp // ignore: cast_nullable_to_non_nullable
as String?,requests: null == requests ? _self.requests : requests // ignore: cast_nullable_to_non_nullable
as FixedList<TrackerInfo>,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,logs: null == logs ? _self.logs : logs // ignore: cast_nullable_to_non_nullable
as FixedList<Log>,traffics: null == traffics ? _self.traffics : traffics // ignore: cast_nullable_to_non_nullable
as FixedList<Traffic>,totalTraffic: null == totalTraffic ? _self.totalTraffic : totalTraffic // ignore: cast_nullable_to_non_nullable
as Traffic,realTunEnable: null == realTunEnable ? _self.realTunEnable : realTunEnable // ignore: cast_nullable_to_non_nullable
as bool,loading: null == loading ? _self.loading : loading // ignore: cast_nullable_to_non_nullable
as bool,systemUiOverlayStyle: null == systemUiOverlayStyle ? _self.systemUiOverlayStyle : systemUiOverlayStyle // ignore: cast_nullable_to_non_nullable
as SystemUiOverlayStyle,profileOverrideModel: freezed == profileOverrideModel ? _self.profileOverrideModel : profileOverrideModel // ignore: cast_nullable_to_non_nullable
as ProfileOverrideModel?,queryMap: null == queryMap ? _self._queryMap : queryMap // ignore: cast_nullable_to_non_nullable
as Map<QueryTag, String>,coreStatus: null == coreStatus ? _self.coreStatus : coreStatus // ignore: cast_nullable_to_non_nullable
as CoreStatus,
  ));
}

/// Create a copy of AppState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TrafficCopyWith<$Res> get totalTraffic {
  
  return $TrafficCopyWith<$Res>(_self.totalTraffic, (value) {
    return _then(_self.copyWith(totalTraffic: value));
  });
}/// Create a copy of AppState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProfileOverrideModelCopyWith<$Res>? get profileOverrideModel {
    if (_self.profileOverrideModel == null) {
    return null;
  }

  return $ProfileOverrideModelCopyWith<$Res>(_self.profileOverrideModel!, (value) {
    return _then(_self.copyWith(profileOverrideModel: value));
  });
}
}

// dart format on
