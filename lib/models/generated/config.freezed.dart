// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AppSettingProps {

 String? get locale;@JsonKey(fromJson: dashboardWidgetsSafeFormJson) List<DashboardWidget> get dashboardWidgets; bool get onlyStatisticsProxy; bool get autoLaunch; bool get silentLaunch; bool get autoRun; bool get openLogs; bool get closeConnections; String get testUrl; bool get isAnimateToPage; bool get autoCheckUpdate; bool get showLabel; bool get disclaimerAccepted; bool get crashlyticsTip; bool get crashlytics; bool get minimizeOnExit; bool get hidden; bool get developerMode; RecoveryStrategy get recoveryStrategy; bool get showTrayTitle;
/// Create a copy of AppSettingProps
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppSettingPropsCopyWith<AppSettingProps> get copyWith => _$AppSettingPropsCopyWithImpl<AppSettingProps>(this as AppSettingProps, _$identity);

  /// Serializes this AppSettingProps to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppSettingProps&&(identical(other.locale, locale) || other.locale == locale)&&const DeepCollectionEquality().equals(other.dashboardWidgets, dashboardWidgets)&&(identical(other.onlyStatisticsProxy, onlyStatisticsProxy) || other.onlyStatisticsProxy == onlyStatisticsProxy)&&(identical(other.autoLaunch, autoLaunch) || other.autoLaunch == autoLaunch)&&(identical(other.silentLaunch, silentLaunch) || other.silentLaunch == silentLaunch)&&(identical(other.autoRun, autoRun) || other.autoRun == autoRun)&&(identical(other.openLogs, openLogs) || other.openLogs == openLogs)&&(identical(other.closeConnections, closeConnections) || other.closeConnections == closeConnections)&&(identical(other.testUrl, testUrl) || other.testUrl == testUrl)&&(identical(other.isAnimateToPage, isAnimateToPage) || other.isAnimateToPage == isAnimateToPage)&&(identical(other.autoCheckUpdate, autoCheckUpdate) || other.autoCheckUpdate == autoCheckUpdate)&&(identical(other.showLabel, showLabel) || other.showLabel == showLabel)&&(identical(other.disclaimerAccepted, disclaimerAccepted) || other.disclaimerAccepted == disclaimerAccepted)&&(identical(other.crashlyticsTip, crashlyticsTip) || other.crashlyticsTip == crashlyticsTip)&&(identical(other.crashlytics, crashlytics) || other.crashlytics == crashlytics)&&(identical(other.minimizeOnExit, minimizeOnExit) || other.minimizeOnExit == minimizeOnExit)&&(identical(other.hidden, hidden) || other.hidden == hidden)&&(identical(other.developerMode, developerMode) || other.developerMode == developerMode)&&(identical(other.recoveryStrategy, recoveryStrategy) || other.recoveryStrategy == recoveryStrategy)&&(identical(other.showTrayTitle, showTrayTitle) || other.showTrayTitle == showTrayTitle));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,locale,const DeepCollectionEquality().hash(dashboardWidgets),onlyStatisticsProxy,autoLaunch,silentLaunch,autoRun,openLogs,closeConnections,testUrl,isAnimateToPage,autoCheckUpdate,showLabel,disclaimerAccepted,crashlyticsTip,crashlytics,minimizeOnExit,hidden,developerMode,recoveryStrategy,showTrayTitle]);

@override
String toString() {
  return 'AppSettingProps(locale: $locale, dashboardWidgets: $dashboardWidgets, onlyStatisticsProxy: $onlyStatisticsProxy, autoLaunch: $autoLaunch, silentLaunch: $silentLaunch, autoRun: $autoRun, openLogs: $openLogs, closeConnections: $closeConnections, testUrl: $testUrl, isAnimateToPage: $isAnimateToPage, autoCheckUpdate: $autoCheckUpdate, showLabel: $showLabel, disclaimerAccepted: $disclaimerAccepted, crashlyticsTip: $crashlyticsTip, crashlytics: $crashlytics, minimizeOnExit: $minimizeOnExit, hidden: $hidden, developerMode: $developerMode, recoveryStrategy: $recoveryStrategy, showTrayTitle: $showTrayTitle)';
}


}

/// @nodoc
abstract mixin class $AppSettingPropsCopyWith<$Res>  {
  factory $AppSettingPropsCopyWith(AppSettingProps value, $Res Function(AppSettingProps) _then) = _$AppSettingPropsCopyWithImpl;
@useResult
$Res call({
 String? locale,@JsonKey(fromJson: dashboardWidgetsSafeFormJson) List<DashboardWidget> dashboardWidgets, bool onlyStatisticsProxy, bool autoLaunch, bool silentLaunch, bool autoRun, bool openLogs, bool closeConnections, String testUrl, bool isAnimateToPage, bool autoCheckUpdate, bool showLabel, bool disclaimerAccepted, bool crashlyticsTip, bool crashlytics, bool minimizeOnExit, bool hidden, bool developerMode, RecoveryStrategy recoveryStrategy, bool showTrayTitle
});




}
/// @nodoc
class _$AppSettingPropsCopyWithImpl<$Res>
    implements $AppSettingPropsCopyWith<$Res> {
  _$AppSettingPropsCopyWithImpl(this._self, this._then);

  final AppSettingProps _self;
  final $Res Function(AppSettingProps) _then;

/// Create a copy of AppSettingProps
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? locale = freezed,Object? dashboardWidgets = null,Object? onlyStatisticsProxy = null,Object? autoLaunch = null,Object? silentLaunch = null,Object? autoRun = null,Object? openLogs = null,Object? closeConnections = null,Object? testUrl = null,Object? isAnimateToPage = null,Object? autoCheckUpdate = null,Object? showLabel = null,Object? disclaimerAccepted = null,Object? crashlyticsTip = null,Object? crashlytics = null,Object? minimizeOnExit = null,Object? hidden = null,Object? developerMode = null,Object? recoveryStrategy = null,Object? showTrayTitle = null,}) {
  return _then(_self.copyWith(
locale: freezed == locale ? _self.locale : locale // ignore: cast_nullable_to_non_nullable
as String?,dashboardWidgets: null == dashboardWidgets ? _self.dashboardWidgets : dashboardWidgets // ignore: cast_nullable_to_non_nullable
as List<DashboardWidget>,onlyStatisticsProxy: null == onlyStatisticsProxy ? _self.onlyStatisticsProxy : onlyStatisticsProxy // ignore: cast_nullable_to_non_nullable
as bool,autoLaunch: null == autoLaunch ? _self.autoLaunch : autoLaunch // ignore: cast_nullable_to_non_nullable
as bool,silentLaunch: null == silentLaunch ? _self.silentLaunch : silentLaunch // ignore: cast_nullable_to_non_nullable
as bool,autoRun: null == autoRun ? _self.autoRun : autoRun // ignore: cast_nullable_to_non_nullable
as bool,openLogs: null == openLogs ? _self.openLogs : openLogs // ignore: cast_nullable_to_non_nullable
as bool,closeConnections: null == closeConnections ? _self.closeConnections : closeConnections // ignore: cast_nullable_to_non_nullable
as bool,testUrl: null == testUrl ? _self.testUrl : testUrl // ignore: cast_nullable_to_non_nullable
as String,isAnimateToPage: null == isAnimateToPage ? _self.isAnimateToPage : isAnimateToPage // ignore: cast_nullable_to_non_nullable
as bool,autoCheckUpdate: null == autoCheckUpdate ? _self.autoCheckUpdate : autoCheckUpdate // ignore: cast_nullable_to_non_nullable
as bool,showLabel: null == showLabel ? _self.showLabel : showLabel // ignore: cast_nullable_to_non_nullable
as bool,disclaimerAccepted: null == disclaimerAccepted ? _self.disclaimerAccepted : disclaimerAccepted // ignore: cast_nullable_to_non_nullable
as bool,crashlyticsTip: null == crashlyticsTip ? _self.crashlyticsTip : crashlyticsTip // ignore: cast_nullable_to_non_nullable
as bool,crashlytics: null == crashlytics ? _self.crashlytics : crashlytics // ignore: cast_nullable_to_non_nullable
as bool,minimizeOnExit: null == minimizeOnExit ? _self.minimizeOnExit : minimizeOnExit // ignore: cast_nullable_to_non_nullable
as bool,hidden: null == hidden ? _self.hidden : hidden // ignore: cast_nullable_to_non_nullable
as bool,developerMode: null == developerMode ? _self.developerMode : developerMode // ignore: cast_nullable_to_non_nullable
as bool,recoveryStrategy: null == recoveryStrategy ? _self.recoveryStrategy : recoveryStrategy // ignore: cast_nullable_to_non_nullable
as RecoveryStrategy,showTrayTitle: null == showTrayTitle ? _self.showTrayTitle : showTrayTitle // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [AppSettingProps].
extension AppSettingPropsPatterns on AppSettingProps {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AppSettingProps value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AppSettingProps() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AppSettingProps value)  $default,){
final _that = this;
switch (_that) {
case _AppSettingProps():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AppSettingProps value)?  $default,){
final _that = this;
switch (_that) {
case _AppSettingProps() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? locale, @JsonKey(fromJson: dashboardWidgetsSafeFormJson)  List<DashboardWidget> dashboardWidgets,  bool onlyStatisticsProxy,  bool autoLaunch,  bool silentLaunch,  bool autoRun,  bool openLogs,  bool closeConnections,  String testUrl,  bool isAnimateToPage,  bool autoCheckUpdate,  bool showLabel,  bool disclaimerAccepted,  bool crashlyticsTip,  bool crashlytics,  bool minimizeOnExit,  bool hidden,  bool developerMode,  RecoveryStrategy recoveryStrategy,  bool showTrayTitle)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppSettingProps() when $default != null:
return $default(_that.locale,_that.dashboardWidgets,_that.onlyStatisticsProxy,_that.autoLaunch,_that.silentLaunch,_that.autoRun,_that.openLogs,_that.closeConnections,_that.testUrl,_that.isAnimateToPage,_that.autoCheckUpdate,_that.showLabel,_that.disclaimerAccepted,_that.crashlyticsTip,_that.crashlytics,_that.minimizeOnExit,_that.hidden,_that.developerMode,_that.recoveryStrategy,_that.showTrayTitle);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? locale, @JsonKey(fromJson: dashboardWidgetsSafeFormJson)  List<DashboardWidget> dashboardWidgets,  bool onlyStatisticsProxy,  bool autoLaunch,  bool silentLaunch,  bool autoRun,  bool openLogs,  bool closeConnections,  String testUrl,  bool isAnimateToPage,  bool autoCheckUpdate,  bool showLabel,  bool disclaimerAccepted,  bool crashlyticsTip,  bool crashlytics,  bool minimizeOnExit,  bool hidden,  bool developerMode,  RecoveryStrategy recoveryStrategy,  bool showTrayTitle)  $default,) {final _that = this;
switch (_that) {
case _AppSettingProps():
return $default(_that.locale,_that.dashboardWidgets,_that.onlyStatisticsProxy,_that.autoLaunch,_that.silentLaunch,_that.autoRun,_that.openLogs,_that.closeConnections,_that.testUrl,_that.isAnimateToPage,_that.autoCheckUpdate,_that.showLabel,_that.disclaimerAccepted,_that.crashlyticsTip,_that.crashlytics,_that.minimizeOnExit,_that.hidden,_that.developerMode,_that.recoveryStrategy,_that.showTrayTitle);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? locale, @JsonKey(fromJson: dashboardWidgetsSafeFormJson)  List<DashboardWidget> dashboardWidgets,  bool onlyStatisticsProxy,  bool autoLaunch,  bool silentLaunch,  bool autoRun,  bool openLogs,  bool closeConnections,  String testUrl,  bool isAnimateToPage,  bool autoCheckUpdate,  bool showLabel,  bool disclaimerAccepted,  bool crashlyticsTip,  bool crashlytics,  bool minimizeOnExit,  bool hidden,  bool developerMode,  RecoveryStrategy recoveryStrategy,  bool showTrayTitle)?  $default,) {final _that = this;
switch (_that) {
case _AppSettingProps() when $default != null:
return $default(_that.locale,_that.dashboardWidgets,_that.onlyStatisticsProxy,_that.autoLaunch,_that.silentLaunch,_that.autoRun,_that.openLogs,_that.closeConnections,_that.testUrl,_that.isAnimateToPage,_that.autoCheckUpdate,_that.showLabel,_that.disclaimerAccepted,_that.crashlyticsTip,_that.crashlytics,_that.minimizeOnExit,_that.hidden,_that.developerMode,_that.recoveryStrategy,_that.showTrayTitle);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AppSettingProps implements AppSettingProps {
  const _AppSettingProps({this.locale, @JsonKey(fromJson: dashboardWidgetsSafeFormJson) final  List<DashboardWidget> dashboardWidgets = defaultDashboardWidgets, this.onlyStatisticsProxy = false, this.autoLaunch = false, this.silentLaunch = false, this.autoRun = false, this.openLogs = false, this.closeConnections = true, this.testUrl = defaultTestUrl, this.isAnimateToPage = true, this.autoCheckUpdate = true, this.showLabel = false, this.disclaimerAccepted = false, this.crashlyticsTip = false, this.crashlytics = false, this.minimizeOnExit = true, this.hidden = false, this.developerMode = false, this.recoveryStrategy = RecoveryStrategy.compatible, this.showTrayTitle = true}): _dashboardWidgets = dashboardWidgets;
  factory _AppSettingProps.fromJson(Map<String, dynamic> json) => _$AppSettingPropsFromJson(json);

@override final  String? locale;
 final  List<DashboardWidget> _dashboardWidgets;
@override@JsonKey(fromJson: dashboardWidgetsSafeFormJson) List<DashboardWidget> get dashboardWidgets {
  if (_dashboardWidgets is EqualUnmodifiableListView) return _dashboardWidgets;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_dashboardWidgets);
}

@override@JsonKey() final  bool onlyStatisticsProxy;
@override@JsonKey() final  bool autoLaunch;
@override@JsonKey() final  bool silentLaunch;
@override@JsonKey() final  bool autoRun;
@override@JsonKey() final  bool openLogs;
@override@JsonKey() final  bool closeConnections;
@override@JsonKey() final  String testUrl;
@override@JsonKey() final  bool isAnimateToPage;
@override@JsonKey() final  bool autoCheckUpdate;
@override@JsonKey() final  bool showLabel;
@override@JsonKey() final  bool disclaimerAccepted;
@override@JsonKey() final  bool crashlyticsTip;
@override@JsonKey() final  bool crashlytics;
@override@JsonKey() final  bool minimizeOnExit;
@override@JsonKey() final  bool hidden;
@override@JsonKey() final  bool developerMode;
@override@JsonKey() final  RecoveryStrategy recoveryStrategy;
@override@JsonKey() final  bool showTrayTitle;

/// Create a copy of AppSettingProps
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppSettingPropsCopyWith<_AppSettingProps> get copyWith => __$AppSettingPropsCopyWithImpl<_AppSettingProps>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AppSettingPropsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppSettingProps&&(identical(other.locale, locale) || other.locale == locale)&&const DeepCollectionEquality().equals(other._dashboardWidgets, _dashboardWidgets)&&(identical(other.onlyStatisticsProxy, onlyStatisticsProxy) || other.onlyStatisticsProxy == onlyStatisticsProxy)&&(identical(other.autoLaunch, autoLaunch) || other.autoLaunch == autoLaunch)&&(identical(other.silentLaunch, silentLaunch) || other.silentLaunch == silentLaunch)&&(identical(other.autoRun, autoRun) || other.autoRun == autoRun)&&(identical(other.openLogs, openLogs) || other.openLogs == openLogs)&&(identical(other.closeConnections, closeConnections) || other.closeConnections == closeConnections)&&(identical(other.testUrl, testUrl) || other.testUrl == testUrl)&&(identical(other.isAnimateToPage, isAnimateToPage) || other.isAnimateToPage == isAnimateToPage)&&(identical(other.autoCheckUpdate, autoCheckUpdate) || other.autoCheckUpdate == autoCheckUpdate)&&(identical(other.showLabel, showLabel) || other.showLabel == showLabel)&&(identical(other.disclaimerAccepted, disclaimerAccepted) || other.disclaimerAccepted == disclaimerAccepted)&&(identical(other.crashlyticsTip, crashlyticsTip) || other.crashlyticsTip == crashlyticsTip)&&(identical(other.crashlytics, crashlytics) || other.crashlytics == crashlytics)&&(identical(other.minimizeOnExit, minimizeOnExit) || other.minimizeOnExit == minimizeOnExit)&&(identical(other.hidden, hidden) || other.hidden == hidden)&&(identical(other.developerMode, developerMode) || other.developerMode == developerMode)&&(identical(other.recoveryStrategy, recoveryStrategy) || other.recoveryStrategy == recoveryStrategy)&&(identical(other.showTrayTitle, showTrayTitle) || other.showTrayTitle == showTrayTitle));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,locale,const DeepCollectionEquality().hash(_dashboardWidgets),onlyStatisticsProxy,autoLaunch,silentLaunch,autoRun,openLogs,closeConnections,testUrl,isAnimateToPage,autoCheckUpdate,showLabel,disclaimerAccepted,crashlyticsTip,crashlytics,minimizeOnExit,hidden,developerMode,recoveryStrategy,showTrayTitle]);

@override
String toString() {
  return 'AppSettingProps(locale: $locale, dashboardWidgets: $dashboardWidgets, onlyStatisticsProxy: $onlyStatisticsProxy, autoLaunch: $autoLaunch, silentLaunch: $silentLaunch, autoRun: $autoRun, openLogs: $openLogs, closeConnections: $closeConnections, testUrl: $testUrl, isAnimateToPage: $isAnimateToPage, autoCheckUpdate: $autoCheckUpdate, showLabel: $showLabel, disclaimerAccepted: $disclaimerAccepted, crashlyticsTip: $crashlyticsTip, crashlytics: $crashlytics, minimizeOnExit: $minimizeOnExit, hidden: $hidden, developerMode: $developerMode, recoveryStrategy: $recoveryStrategy, showTrayTitle: $showTrayTitle)';
}


}

/// @nodoc
abstract mixin class _$AppSettingPropsCopyWith<$Res> implements $AppSettingPropsCopyWith<$Res> {
  factory _$AppSettingPropsCopyWith(_AppSettingProps value, $Res Function(_AppSettingProps) _then) = __$AppSettingPropsCopyWithImpl;
@override @useResult
$Res call({
 String? locale,@JsonKey(fromJson: dashboardWidgetsSafeFormJson) List<DashboardWidget> dashboardWidgets, bool onlyStatisticsProxy, bool autoLaunch, bool silentLaunch, bool autoRun, bool openLogs, bool closeConnections, String testUrl, bool isAnimateToPage, bool autoCheckUpdate, bool showLabel, bool disclaimerAccepted, bool crashlyticsTip, bool crashlytics, bool minimizeOnExit, bool hidden, bool developerMode, RecoveryStrategy recoveryStrategy, bool showTrayTitle
});




}
/// @nodoc
class __$AppSettingPropsCopyWithImpl<$Res>
    implements _$AppSettingPropsCopyWith<$Res> {
  __$AppSettingPropsCopyWithImpl(this._self, this._then);

  final _AppSettingProps _self;
  final $Res Function(_AppSettingProps) _then;

/// Create a copy of AppSettingProps
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? locale = freezed,Object? dashboardWidgets = null,Object? onlyStatisticsProxy = null,Object? autoLaunch = null,Object? silentLaunch = null,Object? autoRun = null,Object? openLogs = null,Object? closeConnections = null,Object? testUrl = null,Object? isAnimateToPage = null,Object? autoCheckUpdate = null,Object? showLabel = null,Object? disclaimerAccepted = null,Object? crashlyticsTip = null,Object? crashlytics = null,Object? minimizeOnExit = null,Object? hidden = null,Object? developerMode = null,Object? recoveryStrategy = null,Object? showTrayTitle = null,}) {
  return _then(_AppSettingProps(
locale: freezed == locale ? _self.locale : locale // ignore: cast_nullable_to_non_nullable
as String?,dashboardWidgets: null == dashboardWidgets ? _self._dashboardWidgets : dashboardWidgets // ignore: cast_nullable_to_non_nullable
as List<DashboardWidget>,onlyStatisticsProxy: null == onlyStatisticsProxy ? _self.onlyStatisticsProxy : onlyStatisticsProxy // ignore: cast_nullable_to_non_nullable
as bool,autoLaunch: null == autoLaunch ? _self.autoLaunch : autoLaunch // ignore: cast_nullable_to_non_nullable
as bool,silentLaunch: null == silentLaunch ? _self.silentLaunch : silentLaunch // ignore: cast_nullable_to_non_nullable
as bool,autoRun: null == autoRun ? _self.autoRun : autoRun // ignore: cast_nullable_to_non_nullable
as bool,openLogs: null == openLogs ? _self.openLogs : openLogs // ignore: cast_nullable_to_non_nullable
as bool,closeConnections: null == closeConnections ? _self.closeConnections : closeConnections // ignore: cast_nullable_to_non_nullable
as bool,testUrl: null == testUrl ? _self.testUrl : testUrl // ignore: cast_nullable_to_non_nullable
as String,isAnimateToPage: null == isAnimateToPage ? _self.isAnimateToPage : isAnimateToPage // ignore: cast_nullable_to_non_nullable
as bool,autoCheckUpdate: null == autoCheckUpdate ? _self.autoCheckUpdate : autoCheckUpdate // ignore: cast_nullable_to_non_nullable
as bool,showLabel: null == showLabel ? _self.showLabel : showLabel // ignore: cast_nullable_to_non_nullable
as bool,disclaimerAccepted: null == disclaimerAccepted ? _self.disclaimerAccepted : disclaimerAccepted // ignore: cast_nullable_to_non_nullable
as bool,crashlyticsTip: null == crashlyticsTip ? _self.crashlyticsTip : crashlyticsTip // ignore: cast_nullable_to_non_nullable
as bool,crashlytics: null == crashlytics ? _self.crashlytics : crashlytics // ignore: cast_nullable_to_non_nullable
as bool,minimizeOnExit: null == minimizeOnExit ? _self.minimizeOnExit : minimizeOnExit // ignore: cast_nullable_to_non_nullable
as bool,hidden: null == hidden ? _self.hidden : hidden // ignore: cast_nullable_to_non_nullable
as bool,developerMode: null == developerMode ? _self.developerMode : developerMode // ignore: cast_nullable_to_non_nullable
as bool,recoveryStrategy: null == recoveryStrategy ? _self.recoveryStrategy : recoveryStrategy // ignore: cast_nullable_to_non_nullable
as RecoveryStrategy,showTrayTitle: null == showTrayTitle ? _self.showTrayTitle : showTrayTitle // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$AccessControl {

 bool get enable; AccessControlMode get mode; List<String> get acceptList; List<String> get rejectList; AccessSortType get sort; bool get isFilterSystemApp; bool get isFilterNonInternetApp;
/// Create a copy of AccessControl
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AccessControlCopyWith<AccessControl> get copyWith => _$AccessControlCopyWithImpl<AccessControl>(this as AccessControl, _$identity);

  /// Serializes this AccessControl to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AccessControl&&(identical(other.enable, enable) || other.enable == enable)&&(identical(other.mode, mode) || other.mode == mode)&&const DeepCollectionEquality().equals(other.acceptList, acceptList)&&const DeepCollectionEquality().equals(other.rejectList, rejectList)&&(identical(other.sort, sort) || other.sort == sort)&&(identical(other.isFilterSystemApp, isFilterSystemApp) || other.isFilterSystemApp == isFilterSystemApp)&&(identical(other.isFilterNonInternetApp, isFilterNonInternetApp) || other.isFilterNonInternetApp == isFilterNonInternetApp));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,enable,mode,const DeepCollectionEquality().hash(acceptList),const DeepCollectionEquality().hash(rejectList),sort,isFilterSystemApp,isFilterNonInternetApp);

@override
String toString() {
  return 'AccessControl(enable: $enable, mode: $mode, acceptList: $acceptList, rejectList: $rejectList, sort: $sort, isFilterSystemApp: $isFilterSystemApp, isFilterNonInternetApp: $isFilterNonInternetApp)';
}


}

/// @nodoc
abstract mixin class $AccessControlCopyWith<$Res>  {
  factory $AccessControlCopyWith(AccessControl value, $Res Function(AccessControl) _then) = _$AccessControlCopyWithImpl;
@useResult
$Res call({
 bool enable, AccessControlMode mode, List<String> acceptList, List<String> rejectList, AccessSortType sort, bool isFilterSystemApp, bool isFilterNonInternetApp
});




}
/// @nodoc
class _$AccessControlCopyWithImpl<$Res>
    implements $AccessControlCopyWith<$Res> {
  _$AccessControlCopyWithImpl(this._self, this._then);

  final AccessControl _self;
  final $Res Function(AccessControl) _then;

/// Create a copy of AccessControl
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? enable = null,Object? mode = null,Object? acceptList = null,Object? rejectList = null,Object? sort = null,Object? isFilterSystemApp = null,Object? isFilterNonInternetApp = null,}) {
  return _then(_self.copyWith(
enable: null == enable ? _self.enable : enable // ignore: cast_nullable_to_non_nullable
as bool,mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as AccessControlMode,acceptList: null == acceptList ? _self.acceptList : acceptList // ignore: cast_nullable_to_non_nullable
as List<String>,rejectList: null == rejectList ? _self.rejectList : rejectList // ignore: cast_nullable_to_non_nullable
as List<String>,sort: null == sort ? _self.sort : sort // ignore: cast_nullable_to_non_nullable
as AccessSortType,isFilterSystemApp: null == isFilterSystemApp ? _self.isFilterSystemApp : isFilterSystemApp // ignore: cast_nullable_to_non_nullable
as bool,isFilterNonInternetApp: null == isFilterNonInternetApp ? _self.isFilterNonInternetApp : isFilterNonInternetApp // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [AccessControl].
extension AccessControlPatterns on AccessControl {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AccessControl value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AccessControl() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AccessControl value)  $default,){
final _that = this;
switch (_that) {
case _AccessControl():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AccessControl value)?  $default,){
final _that = this;
switch (_that) {
case _AccessControl() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool enable,  AccessControlMode mode,  List<String> acceptList,  List<String> rejectList,  AccessSortType sort,  bool isFilterSystemApp,  bool isFilterNonInternetApp)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AccessControl() when $default != null:
return $default(_that.enable,_that.mode,_that.acceptList,_that.rejectList,_that.sort,_that.isFilterSystemApp,_that.isFilterNonInternetApp);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool enable,  AccessControlMode mode,  List<String> acceptList,  List<String> rejectList,  AccessSortType sort,  bool isFilterSystemApp,  bool isFilterNonInternetApp)  $default,) {final _that = this;
switch (_that) {
case _AccessControl():
return $default(_that.enable,_that.mode,_that.acceptList,_that.rejectList,_that.sort,_that.isFilterSystemApp,_that.isFilterNonInternetApp);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool enable,  AccessControlMode mode,  List<String> acceptList,  List<String> rejectList,  AccessSortType sort,  bool isFilterSystemApp,  bool isFilterNonInternetApp)?  $default,) {final _that = this;
switch (_that) {
case _AccessControl() when $default != null:
return $default(_that.enable,_that.mode,_that.acceptList,_that.rejectList,_that.sort,_that.isFilterSystemApp,_that.isFilterNonInternetApp);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AccessControl implements AccessControl {
  const _AccessControl({this.enable = false, this.mode = AccessControlMode.rejectSelected, final  List<String> acceptList = const [], final  List<String> rejectList = const [], this.sort = AccessSortType.none, this.isFilterSystemApp = true, this.isFilterNonInternetApp = true}): _acceptList = acceptList,_rejectList = rejectList;
  factory _AccessControl.fromJson(Map<String, dynamic> json) => _$AccessControlFromJson(json);

@override@JsonKey() final  bool enable;
@override@JsonKey() final  AccessControlMode mode;
 final  List<String> _acceptList;
@override@JsonKey() List<String> get acceptList {
  if (_acceptList is EqualUnmodifiableListView) return _acceptList;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_acceptList);
}

 final  List<String> _rejectList;
@override@JsonKey() List<String> get rejectList {
  if (_rejectList is EqualUnmodifiableListView) return _rejectList;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_rejectList);
}

@override@JsonKey() final  AccessSortType sort;
@override@JsonKey() final  bool isFilterSystemApp;
@override@JsonKey() final  bool isFilterNonInternetApp;

/// Create a copy of AccessControl
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AccessControlCopyWith<_AccessControl> get copyWith => __$AccessControlCopyWithImpl<_AccessControl>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AccessControlToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AccessControl&&(identical(other.enable, enable) || other.enable == enable)&&(identical(other.mode, mode) || other.mode == mode)&&const DeepCollectionEquality().equals(other._acceptList, _acceptList)&&const DeepCollectionEquality().equals(other._rejectList, _rejectList)&&(identical(other.sort, sort) || other.sort == sort)&&(identical(other.isFilterSystemApp, isFilterSystemApp) || other.isFilterSystemApp == isFilterSystemApp)&&(identical(other.isFilterNonInternetApp, isFilterNonInternetApp) || other.isFilterNonInternetApp == isFilterNonInternetApp));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,enable,mode,const DeepCollectionEquality().hash(_acceptList),const DeepCollectionEquality().hash(_rejectList),sort,isFilterSystemApp,isFilterNonInternetApp);

@override
String toString() {
  return 'AccessControl(enable: $enable, mode: $mode, acceptList: $acceptList, rejectList: $rejectList, sort: $sort, isFilterSystemApp: $isFilterSystemApp, isFilterNonInternetApp: $isFilterNonInternetApp)';
}


}

/// @nodoc
abstract mixin class _$AccessControlCopyWith<$Res> implements $AccessControlCopyWith<$Res> {
  factory _$AccessControlCopyWith(_AccessControl value, $Res Function(_AccessControl) _then) = __$AccessControlCopyWithImpl;
@override @useResult
$Res call({
 bool enable, AccessControlMode mode, List<String> acceptList, List<String> rejectList, AccessSortType sort, bool isFilterSystemApp, bool isFilterNonInternetApp
});




}
/// @nodoc
class __$AccessControlCopyWithImpl<$Res>
    implements _$AccessControlCopyWith<$Res> {
  __$AccessControlCopyWithImpl(this._self, this._then);

  final _AccessControl _self;
  final $Res Function(_AccessControl) _then;

/// Create a copy of AccessControl
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? enable = null,Object? mode = null,Object? acceptList = null,Object? rejectList = null,Object? sort = null,Object? isFilterSystemApp = null,Object? isFilterNonInternetApp = null,}) {
  return _then(_AccessControl(
enable: null == enable ? _self.enable : enable // ignore: cast_nullable_to_non_nullable
as bool,mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as AccessControlMode,acceptList: null == acceptList ? _self._acceptList : acceptList // ignore: cast_nullable_to_non_nullable
as List<String>,rejectList: null == rejectList ? _self._rejectList : rejectList // ignore: cast_nullable_to_non_nullable
as List<String>,sort: null == sort ? _self.sort : sort // ignore: cast_nullable_to_non_nullable
as AccessSortType,isFilterSystemApp: null == isFilterSystemApp ? _self.isFilterSystemApp : isFilterSystemApp // ignore: cast_nullable_to_non_nullable
as bool,isFilterNonInternetApp: null == isFilterNonInternetApp ? _self.isFilterNonInternetApp : isFilterNonInternetApp // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$WindowProps {

 double get width; double get height; double? get top; double? get left;
/// Create a copy of WindowProps
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WindowPropsCopyWith<WindowProps> get copyWith => _$WindowPropsCopyWithImpl<WindowProps>(this as WindowProps, _$identity);

  /// Serializes this WindowProps to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WindowProps&&(identical(other.width, width) || other.width == width)&&(identical(other.height, height) || other.height == height)&&(identical(other.top, top) || other.top == top)&&(identical(other.left, left) || other.left == left));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,width,height,top,left);

@override
String toString() {
  return 'WindowProps(width: $width, height: $height, top: $top, left: $left)';
}


}

/// @nodoc
abstract mixin class $WindowPropsCopyWith<$Res>  {
  factory $WindowPropsCopyWith(WindowProps value, $Res Function(WindowProps) _then) = _$WindowPropsCopyWithImpl;
@useResult
$Res call({
 double width, double height, double? top, double? left
});




}
/// @nodoc
class _$WindowPropsCopyWithImpl<$Res>
    implements $WindowPropsCopyWith<$Res> {
  _$WindowPropsCopyWithImpl(this._self, this._then);

  final WindowProps _self;
  final $Res Function(WindowProps) _then;

/// Create a copy of WindowProps
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? width = null,Object? height = null,Object? top = freezed,Object? left = freezed,}) {
  return _then(_self.copyWith(
width: null == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as double,height: null == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as double,top: freezed == top ? _self.top : top // ignore: cast_nullable_to_non_nullable
as double?,left: freezed == left ? _self.left : left // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// Adds pattern-matching-related methods to [WindowProps].
extension WindowPropsPatterns on WindowProps {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WindowProps value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WindowProps() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WindowProps value)  $default,){
final _that = this;
switch (_that) {
case _WindowProps():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WindowProps value)?  $default,){
final _that = this;
switch (_that) {
case _WindowProps() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double width,  double height,  double? top,  double? left)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WindowProps() when $default != null:
return $default(_that.width,_that.height,_that.top,_that.left);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double width,  double height,  double? top,  double? left)  $default,) {final _that = this;
switch (_that) {
case _WindowProps():
return $default(_that.width,_that.height,_that.top,_that.left);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double width,  double height,  double? top,  double? left)?  $default,) {final _that = this;
switch (_that) {
case _WindowProps() when $default != null:
return $default(_that.width,_that.height,_that.top,_that.left);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WindowProps implements WindowProps {
  const _WindowProps({this.width = 0, this.height = 0, this.top, this.left});
  factory _WindowProps.fromJson(Map<String, dynamic> json) => _$WindowPropsFromJson(json);

@override@JsonKey() final  double width;
@override@JsonKey() final  double height;
@override final  double? top;
@override final  double? left;

/// Create a copy of WindowProps
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WindowPropsCopyWith<_WindowProps> get copyWith => __$WindowPropsCopyWithImpl<_WindowProps>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WindowPropsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WindowProps&&(identical(other.width, width) || other.width == width)&&(identical(other.height, height) || other.height == height)&&(identical(other.top, top) || other.top == top)&&(identical(other.left, left) || other.left == left));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,width,height,top,left);

@override
String toString() {
  return 'WindowProps(width: $width, height: $height, top: $top, left: $left)';
}


}

/// @nodoc
abstract mixin class _$WindowPropsCopyWith<$Res> implements $WindowPropsCopyWith<$Res> {
  factory _$WindowPropsCopyWith(_WindowProps value, $Res Function(_WindowProps) _then) = __$WindowPropsCopyWithImpl;
@override @useResult
$Res call({
 double width, double height, double? top, double? left
});




}
/// @nodoc
class __$WindowPropsCopyWithImpl<$Res>
    implements _$WindowPropsCopyWith<$Res> {
  __$WindowPropsCopyWithImpl(this._self, this._then);

  final _WindowProps _self;
  final $Res Function(_WindowProps) _then;

/// Create a copy of WindowProps
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? width = null,Object? height = null,Object? top = freezed,Object? left = freezed,}) {
  return _then(_WindowProps(
width: null == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as double,height: null == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as double,top: freezed == top ? _self.top : top // ignore: cast_nullable_to_non_nullable
as double?,left: freezed == left ? _self.left : left // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}


/// @nodoc
mixin _$VpnProps {

 bool get enable; bool get systemProxy; bool get ipv6; bool get allowBypass; bool get dnsHijacking; AccessControl get accessControl;
/// Create a copy of VpnProps
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VpnPropsCopyWith<VpnProps> get copyWith => _$VpnPropsCopyWithImpl<VpnProps>(this as VpnProps, _$identity);

  /// Serializes this VpnProps to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VpnProps&&(identical(other.enable, enable) || other.enable == enable)&&(identical(other.systemProxy, systemProxy) || other.systemProxy == systemProxy)&&(identical(other.ipv6, ipv6) || other.ipv6 == ipv6)&&(identical(other.allowBypass, allowBypass) || other.allowBypass == allowBypass)&&(identical(other.dnsHijacking, dnsHijacking) || other.dnsHijacking == dnsHijacking)&&(identical(other.accessControl, accessControl) || other.accessControl == accessControl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,enable,systemProxy,ipv6,allowBypass,dnsHijacking,accessControl);

@override
String toString() {
  return 'VpnProps(enable: $enable, systemProxy: $systemProxy, ipv6: $ipv6, allowBypass: $allowBypass, dnsHijacking: $dnsHijacking, accessControl: $accessControl)';
}


}

/// @nodoc
abstract mixin class $VpnPropsCopyWith<$Res>  {
  factory $VpnPropsCopyWith(VpnProps value, $Res Function(VpnProps) _then) = _$VpnPropsCopyWithImpl;
@useResult
$Res call({
 bool enable, bool systemProxy, bool ipv6, bool allowBypass, bool dnsHijacking, AccessControl accessControl
});


$AccessControlCopyWith<$Res> get accessControl;

}
/// @nodoc
class _$VpnPropsCopyWithImpl<$Res>
    implements $VpnPropsCopyWith<$Res> {
  _$VpnPropsCopyWithImpl(this._self, this._then);

  final VpnProps _self;
  final $Res Function(VpnProps) _then;

/// Create a copy of VpnProps
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? enable = null,Object? systemProxy = null,Object? ipv6 = null,Object? allowBypass = null,Object? dnsHijacking = null,Object? accessControl = null,}) {
  return _then(_self.copyWith(
enable: null == enable ? _self.enable : enable // ignore: cast_nullable_to_non_nullable
as bool,systemProxy: null == systemProxy ? _self.systemProxy : systemProxy // ignore: cast_nullable_to_non_nullable
as bool,ipv6: null == ipv6 ? _self.ipv6 : ipv6 // ignore: cast_nullable_to_non_nullable
as bool,allowBypass: null == allowBypass ? _self.allowBypass : allowBypass // ignore: cast_nullable_to_non_nullable
as bool,dnsHijacking: null == dnsHijacking ? _self.dnsHijacking : dnsHijacking // ignore: cast_nullable_to_non_nullable
as bool,accessControl: null == accessControl ? _self.accessControl : accessControl // ignore: cast_nullable_to_non_nullable
as AccessControl,
  ));
}
/// Create a copy of VpnProps
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AccessControlCopyWith<$Res> get accessControl {
  
  return $AccessControlCopyWith<$Res>(_self.accessControl, (value) {
    return _then(_self.copyWith(accessControl: value));
  });
}
}


/// Adds pattern-matching-related methods to [VpnProps].
extension VpnPropsPatterns on VpnProps {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VpnProps value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VpnProps() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VpnProps value)  $default,){
final _that = this;
switch (_that) {
case _VpnProps():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VpnProps value)?  $default,){
final _that = this;
switch (_that) {
case _VpnProps() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool enable,  bool systemProxy,  bool ipv6,  bool allowBypass,  bool dnsHijacking,  AccessControl accessControl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VpnProps() when $default != null:
return $default(_that.enable,_that.systemProxy,_that.ipv6,_that.allowBypass,_that.dnsHijacking,_that.accessControl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool enable,  bool systemProxy,  bool ipv6,  bool allowBypass,  bool dnsHijacking,  AccessControl accessControl)  $default,) {final _that = this;
switch (_that) {
case _VpnProps():
return $default(_that.enable,_that.systemProxy,_that.ipv6,_that.allowBypass,_that.dnsHijacking,_that.accessControl);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool enable,  bool systemProxy,  bool ipv6,  bool allowBypass,  bool dnsHijacking,  AccessControl accessControl)?  $default,) {final _that = this;
switch (_that) {
case _VpnProps() when $default != null:
return $default(_that.enable,_that.systemProxy,_that.ipv6,_that.allowBypass,_that.dnsHijacking,_that.accessControl);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _VpnProps implements VpnProps {
  const _VpnProps({this.enable = true, this.systemProxy = true, this.ipv6 = false, this.allowBypass = true, this.dnsHijacking = false, this.accessControl = defaultAccessControl});
  factory _VpnProps.fromJson(Map<String, dynamic> json) => _$VpnPropsFromJson(json);

@override@JsonKey() final  bool enable;
@override@JsonKey() final  bool systemProxy;
@override@JsonKey() final  bool ipv6;
@override@JsonKey() final  bool allowBypass;
@override@JsonKey() final  bool dnsHijacking;
@override@JsonKey() final  AccessControl accessControl;

/// Create a copy of VpnProps
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VpnPropsCopyWith<_VpnProps> get copyWith => __$VpnPropsCopyWithImpl<_VpnProps>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VpnPropsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VpnProps&&(identical(other.enable, enable) || other.enable == enable)&&(identical(other.systemProxy, systemProxy) || other.systemProxy == systemProxy)&&(identical(other.ipv6, ipv6) || other.ipv6 == ipv6)&&(identical(other.allowBypass, allowBypass) || other.allowBypass == allowBypass)&&(identical(other.dnsHijacking, dnsHijacking) || other.dnsHijacking == dnsHijacking)&&(identical(other.accessControl, accessControl) || other.accessControl == accessControl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,enable,systemProxy,ipv6,allowBypass,dnsHijacking,accessControl);

@override
String toString() {
  return 'VpnProps(enable: $enable, systemProxy: $systemProxy, ipv6: $ipv6, allowBypass: $allowBypass, dnsHijacking: $dnsHijacking, accessControl: $accessControl)';
}


}

/// @nodoc
abstract mixin class _$VpnPropsCopyWith<$Res> implements $VpnPropsCopyWith<$Res> {
  factory _$VpnPropsCopyWith(_VpnProps value, $Res Function(_VpnProps) _then) = __$VpnPropsCopyWithImpl;
@override @useResult
$Res call({
 bool enable, bool systemProxy, bool ipv6, bool allowBypass, bool dnsHijacking, AccessControl accessControl
});


@override $AccessControlCopyWith<$Res> get accessControl;

}
/// @nodoc
class __$VpnPropsCopyWithImpl<$Res>
    implements _$VpnPropsCopyWith<$Res> {
  __$VpnPropsCopyWithImpl(this._self, this._then);

  final _VpnProps _self;
  final $Res Function(_VpnProps) _then;

/// Create a copy of VpnProps
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? enable = null,Object? systemProxy = null,Object? ipv6 = null,Object? allowBypass = null,Object? dnsHijacking = null,Object? accessControl = null,}) {
  return _then(_VpnProps(
enable: null == enable ? _self.enable : enable // ignore: cast_nullable_to_non_nullable
as bool,systemProxy: null == systemProxy ? _self.systemProxy : systemProxy // ignore: cast_nullable_to_non_nullable
as bool,ipv6: null == ipv6 ? _self.ipv6 : ipv6 // ignore: cast_nullable_to_non_nullable
as bool,allowBypass: null == allowBypass ? _self.allowBypass : allowBypass // ignore: cast_nullable_to_non_nullable
as bool,dnsHijacking: null == dnsHijacking ? _self.dnsHijacking : dnsHijacking // ignore: cast_nullable_to_non_nullable
as bool,accessControl: null == accessControl ? _self.accessControl : accessControl // ignore: cast_nullable_to_non_nullable
as AccessControl,
  ));
}

/// Create a copy of VpnProps
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AccessControlCopyWith<$Res> get accessControl {
  
  return $AccessControlCopyWith<$Res>(_self.accessControl, (value) {
    return _then(_self.copyWith(accessControl: value));
  });
}
}


/// @nodoc
mixin _$NetworkProps {

 bool get systemProxy; List<String> get bypassDomain; RouteMode get routeMode; bool get autoSetSystemDns; bool get appendSystemDns;
/// Create a copy of NetworkProps
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NetworkPropsCopyWith<NetworkProps> get copyWith => _$NetworkPropsCopyWithImpl<NetworkProps>(this as NetworkProps, _$identity);

  /// Serializes this NetworkProps to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NetworkProps&&(identical(other.systemProxy, systemProxy) || other.systemProxy == systemProxy)&&const DeepCollectionEquality().equals(other.bypassDomain, bypassDomain)&&(identical(other.routeMode, routeMode) || other.routeMode == routeMode)&&(identical(other.autoSetSystemDns, autoSetSystemDns) || other.autoSetSystemDns == autoSetSystemDns)&&(identical(other.appendSystemDns, appendSystemDns) || other.appendSystemDns == appendSystemDns));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,systemProxy,const DeepCollectionEquality().hash(bypassDomain),routeMode,autoSetSystemDns,appendSystemDns);

@override
String toString() {
  return 'NetworkProps(systemProxy: $systemProxy, bypassDomain: $bypassDomain, routeMode: $routeMode, autoSetSystemDns: $autoSetSystemDns, appendSystemDns: $appendSystemDns)';
}


}

/// @nodoc
abstract mixin class $NetworkPropsCopyWith<$Res>  {
  factory $NetworkPropsCopyWith(NetworkProps value, $Res Function(NetworkProps) _then) = _$NetworkPropsCopyWithImpl;
@useResult
$Res call({
 bool systemProxy, List<String> bypassDomain, RouteMode routeMode, bool autoSetSystemDns, bool appendSystemDns
});




}
/// @nodoc
class _$NetworkPropsCopyWithImpl<$Res>
    implements $NetworkPropsCopyWith<$Res> {
  _$NetworkPropsCopyWithImpl(this._self, this._then);

  final NetworkProps _self;
  final $Res Function(NetworkProps) _then;

/// Create a copy of NetworkProps
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? systemProxy = null,Object? bypassDomain = null,Object? routeMode = null,Object? autoSetSystemDns = null,Object? appendSystemDns = null,}) {
  return _then(_self.copyWith(
systemProxy: null == systemProxy ? _self.systemProxy : systemProxy // ignore: cast_nullable_to_non_nullable
as bool,bypassDomain: null == bypassDomain ? _self.bypassDomain : bypassDomain // ignore: cast_nullable_to_non_nullable
as List<String>,routeMode: null == routeMode ? _self.routeMode : routeMode // ignore: cast_nullable_to_non_nullable
as RouteMode,autoSetSystemDns: null == autoSetSystemDns ? _self.autoSetSystemDns : autoSetSystemDns // ignore: cast_nullable_to_non_nullable
as bool,appendSystemDns: null == appendSystemDns ? _self.appendSystemDns : appendSystemDns // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [NetworkProps].
extension NetworkPropsPatterns on NetworkProps {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NetworkProps value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NetworkProps() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NetworkProps value)  $default,){
final _that = this;
switch (_that) {
case _NetworkProps():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NetworkProps value)?  $default,){
final _that = this;
switch (_that) {
case _NetworkProps() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool systemProxy,  List<String> bypassDomain,  RouteMode routeMode,  bool autoSetSystemDns,  bool appendSystemDns)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NetworkProps() when $default != null:
return $default(_that.systemProxy,_that.bypassDomain,_that.routeMode,_that.autoSetSystemDns,_that.appendSystemDns);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool systemProxy,  List<String> bypassDomain,  RouteMode routeMode,  bool autoSetSystemDns,  bool appendSystemDns)  $default,) {final _that = this;
switch (_that) {
case _NetworkProps():
return $default(_that.systemProxy,_that.bypassDomain,_that.routeMode,_that.autoSetSystemDns,_that.appendSystemDns);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool systemProxy,  List<String> bypassDomain,  RouteMode routeMode,  bool autoSetSystemDns,  bool appendSystemDns)?  $default,) {final _that = this;
switch (_that) {
case _NetworkProps() when $default != null:
return $default(_that.systemProxy,_that.bypassDomain,_that.routeMode,_that.autoSetSystemDns,_that.appendSystemDns);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _NetworkProps implements NetworkProps {
  const _NetworkProps({this.systemProxy = true, final  List<String> bypassDomain = defaultBypassDomain, this.routeMode = RouteMode.config, this.autoSetSystemDns = true, this.appendSystemDns = false}): _bypassDomain = bypassDomain;
  factory _NetworkProps.fromJson(Map<String, dynamic> json) => _$NetworkPropsFromJson(json);

@override@JsonKey() final  bool systemProxy;
 final  List<String> _bypassDomain;
@override@JsonKey() List<String> get bypassDomain {
  if (_bypassDomain is EqualUnmodifiableListView) return _bypassDomain;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_bypassDomain);
}

@override@JsonKey() final  RouteMode routeMode;
@override@JsonKey() final  bool autoSetSystemDns;
@override@JsonKey() final  bool appendSystemDns;

/// Create a copy of NetworkProps
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NetworkPropsCopyWith<_NetworkProps> get copyWith => __$NetworkPropsCopyWithImpl<_NetworkProps>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$NetworkPropsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NetworkProps&&(identical(other.systemProxy, systemProxy) || other.systemProxy == systemProxy)&&const DeepCollectionEquality().equals(other._bypassDomain, _bypassDomain)&&(identical(other.routeMode, routeMode) || other.routeMode == routeMode)&&(identical(other.autoSetSystemDns, autoSetSystemDns) || other.autoSetSystemDns == autoSetSystemDns)&&(identical(other.appendSystemDns, appendSystemDns) || other.appendSystemDns == appendSystemDns));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,systemProxy,const DeepCollectionEquality().hash(_bypassDomain),routeMode,autoSetSystemDns,appendSystemDns);

@override
String toString() {
  return 'NetworkProps(systemProxy: $systemProxy, bypassDomain: $bypassDomain, routeMode: $routeMode, autoSetSystemDns: $autoSetSystemDns, appendSystemDns: $appendSystemDns)';
}


}

/// @nodoc
abstract mixin class _$NetworkPropsCopyWith<$Res> implements $NetworkPropsCopyWith<$Res> {
  factory _$NetworkPropsCopyWith(_NetworkProps value, $Res Function(_NetworkProps) _then) = __$NetworkPropsCopyWithImpl;
@override @useResult
$Res call({
 bool systemProxy, List<String> bypassDomain, RouteMode routeMode, bool autoSetSystemDns, bool appendSystemDns
});




}
/// @nodoc
class __$NetworkPropsCopyWithImpl<$Res>
    implements _$NetworkPropsCopyWith<$Res> {
  __$NetworkPropsCopyWithImpl(this._self, this._then);

  final _NetworkProps _self;
  final $Res Function(_NetworkProps) _then;

/// Create a copy of NetworkProps
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? systemProxy = null,Object? bypassDomain = null,Object? routeMode = null,Object? autoSetSystemDns = null,Object? appendSystemDns = null,}) {
  return _then(_NetworkProps(
systemProxy: null == systemProxy ? _self.systemProxy : systemProxy // ignore: cast_nullable_to_non_nullable
as bool,bypassDomain: null == bypassDomain ? _self._bypassDomain : bypassDomain // ignore: cast_nullable_to_non_nullable
as List<String>,routeMode: null == routeMode ? _self.routeMode : routeMode // ignore: cast_nullable_to_non_nullable
as RouteMode,autoSetSystemDns: null == autoSetSystemDns ? _self.autoSetSystemDns : autoSetSystemDns // ignore: cast_nullable_to_non_nullable
as bool,appendSystemDns: null == appendSystemDns ? _self.appendSystemDns : appendSystemDns // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$ProxiesStyle {

 ProxiesType get type; ProxiesSortType get sortType; ProxiesLayout get layout; ProxiesIconStyle get iconStyle; ProxyCardType get cardType;
/// Create a copy of ProxiesStyle
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProxiesStyleCopyWith<ProxiesStyle> get copyWith => _$ProxiesStyleCopyWithImpl<ProxiesStyle>(this as ProxiesStyle, _$identity);

  /// Serializes this ProxiesStyle to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProxiesStyle&&(identical(other.type, type) || other.type == type)&&(identical(other.sortType, sortType) || other.sortType == sortType)&&(identical(other.layout, layout) || other.layout == layout)&&(identical(other.iconStyle, iconStyle) || other.iconStyle == iconStyle)&&(identical(other.cardType, cardType) || other.cardType == cardType));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,sortType,layout,iconStyle,cardType);

@override
String toString() {
  return 'ProxiesStyle(type: $type, sortType: $sortType, layout: $layout, iconStyle: $iconStyle, cardType: $cardType)';
}


}

/// @nodoc
abstract mixin class $ProxiesStyleCopyWith<$Res>  {
  factory $ProxiesStyleCopyWith(ProxiesStyle value, $Res Function(ProxiesStyle) _then) = _$ProxiesStyleCopyWithImpl;
@useResult
$Res call({
 ProxiesType type, ProxiesSortType sortType, ProxiesLayout layout, ProxiesIconStyle iconStyle, ProxyCardType cardType
});




}
/// @nodoc
class _$ProxiesStyleCopyWithImpl<$Res>
    implements $ProxiesStyleCopyWith<$Res> {
  _$ProxiesStyleCopyWithImpl(this._self, this._then);

  final ProxiesStyle _self;
  final $Res Function(ProxiesStyle) _then;

/// Create a copy of ProxiesStyle
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = null,Object? sortType = null,Object? layout = null,Object? iconStyle = null,Object? cardType = null,}) {
  return _then(_self.copyWith(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ProxiesType,sortType: null == sortType ? _self.sortType : sortType // ignore: cast_nullable_to_non_nullable
as ProxiesSortType,layout: null == layout ? _self.layout : layout // ignore: cast_nullable_to_non_nullable
as ProxiesLayout,iconStyle: null == iconStyle ? _self.iconStyle : iconStyle // ignore: cast_nullable_to_non_nullable
as ProxiesIconStyle,cardType: null == cardType ? _self.cardType : cardType // ignore: cast_nullable_to_non_nullable
as ProxyCardType,
  ));
}

}


/// Adds pattern-matching-related methods to [ProxiesStyle].
extension ProxiesStylePatterns on ProxiesStyle {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProxiesStyle value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProxiesStyle() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProxiesStyle value)  $default,){
final _that = this;
switch (_that) {
case _ProxiesStyle():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProxiesStyle value)?  $default,){
final _that = this;
switch (_that) {
case _ProxiesStyle() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ProxiesType type,  ProxiesSortType sortType,  ProxiesLayout layout,  ProxiesIconStyle iconStyle,  ProxyCardType cardType)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProxiesStyle() when $default != null:
return $default(_that.type,_that.sortType,_that.layout,_that.iconStyle,_that.cardType);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ProxiesType type,  ProxiesSortType sortType,  ProxiesLayout layout,  ProxiesIconStyle iconStyle,  ProxyCardType cardType)  $default,) {final _that = this;
switch (_that) {
case _ProxiesStyle():
return $default(_that.type,_that.sortType,_that.layout,_that.iconStyle,_that.cardType);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ProxiesType type,  ProxiesSortType sortType,  ProxiesLayout layout,  ProxiesIconStyle iconStyle,  ProxyCardType cardType)?  $default,) {final _that = this;
switch (_that) {
case _ProxiesStyle() when $default != null:
return $default(_that.type,_that.sortType,_that.layout,_that.iconStyle,_that.cardType);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProxiesStyle implements ProxiesStyle {
  const _ProxiesStyle({this.type = ProxiesType.tab, this.sortType = ProxiesSortType.none, this.layout = ProxiesLayout.standard, this.iconStyle = ProxiesIconStyle.standard, this.cardType = ProxyCardType.expand});
  factory _ProxiesStyle.fromJson(Map<String, dynamic> json) => _$ProxiesStyleFromJson(json);

@override@JsonKey() final  ProxiesType type;
@override@JsonKey() final  ProxiesSortType sortType;
@override@JsonKey() final  ProxiesLayout layout;
@override@JsonKey() final  ProxiesIconStyle iconStyle;
@override@JsonKey() final  ProxyCardType cardType;

/// Create a copy of ProxiesStyle
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProxiesStyleCopyWith<_ProxiesStyle> get copyWith => __$ProxiesStyleCopyWithImpl<_ProxiesStyle>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProxiesStyleToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProxiesStyle&&(identical(other.type, type) || other.type == type)&&(identical(other.sortType, sortType) || other.sortType == sortType)&&(identical(other.layout, layout) || other.layout == layout)&&(identical(other.iconStyle, iconStyle) || other.iconStyle == iconStyle)&&(identical(other.cardType, cardType) || other.cardType == cardType));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,sortType,layout,iconStyle,cardType);

@override
String toString() {
  return 'ProxiesStyle(type: $type, sortType: $sortType, layout: $layout, iconStyle: $iconStyle, cardType: $cardType)';
}


}

/// @nodoc
abstract mixin class _$ProxiesStyleCopyWith<$Res> implements $ProxiesStyleCopyWith<$Res> {
  factory _$ProxiesStyleCopyWith(_ProxiesStyle value, $Res Function(_ProxiesStyle) _then) = __$ProxiesStyleCopyWithImpl;
@override @useResult
$Res call({
 ProxiesType type, ProxiesSortType sortType, ProxiesLayout layout, ProxiesIconStyle iconStyle, ProxyCardType cardType
});




}
/// @nodoc
class __$ProxiesStyleCopyWithImpl<$Res>
    implements _$ProxiesStyleCopyWith<$Res> {
  __$ProxiesStyleCopyWithImpl(this._self, this._then);

  final _ProxiesStyle _self;
  final $Res Function(_ProxiesStyle) _then;

/// Create a copy of ProxiesStyle
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = null,Object? sortType = null,Object? layout = null,Object? iconStyle = null,Object? cardType = null,}) {
  return _then(_ProxiesStyle(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ProxiesType,sortType: null == sortType ? _self.sortType : sortType // ignore: cast_nullable_to_non_nullable
as ProxiesSortType,layout: null == layout ? _self.layout : layout // ignore: cast_nullable_to_non_nullable
as ProxiesLayout,iconStyle: null == iconStyle ? _self.iconStyle : iconStyle // ignore: cast_nullable_to_non_nullable
as ProxiesIconStyle,cardType: null == cardType ? _self.cardType : cardType // ignore: cast_nullable_to_non_nullable
as ProxyCardType,
  ));
}


}


/// @nodoc
mixin _$TextScale {

 bool get enable; double get scale;
/// Create a copy of TextScale
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TextScaleCopyWith<TextScale> get copyWith => _$TextScaleCopyWithImpl<TextScale>(this as TextScale, _$identity);

  /// Serializes this TextScale to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TextScale&&(identical(other.enable, enable) || other.enable == enable)&&(identical(other.scale, scale) || other.scale == scale));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,enable,scale);

@override
String toString() {
  return 'TextScale(enable: $enable, scale: $scale)';
}


}

/// @nodoc
abstract mixin class $TextScaleCopyWith<$Res>  {
  factory $TextScaleCopyWith(TextScale value, $Res Function(TextScale) _then) = _$TextScaleCopyWithImpl;
@useResult
$Res call({
 bool enable, double scale
});




}
/// @nodoc
class _$TextScaleCopyWithImpl<$Res>
    implements $TextScaleCopyWith<$Res> {
  _$TextScaleCopyWithImpl(this._self, this._then);

  final TextScale _self;
  final $Res Function(TextScale) _then;

/// Create a copy of TextScale
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? enable = null,Object? scale = null,}) {
  return _then(_self.copyWith(
enable: null == enable ? _self.enable : enable // ignore: cast_nullable_to_non_nullable
as bool,scale: null == scale ? _self.scale : scale // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [TextScale].
extension TextScalePatterns on TextScale {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TextScale value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TextScale() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TextScale value)  $default,){
final _that = this;
switch (_that) {
case _TextScale():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TextScale value)?  $default,){
final _that = this;
switch (_that) {
case _TextScale() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool enable,  double scale)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TextScale() when $default != null:
return $default(_that.enable,_that.scale);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool enable,  double scale)  $default,) {final _that = this;
switch (_that) {
case _TextScale():
return $default(_that.enable,_that.scale);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool enable,  double scale)?  $default,) {final _that = this;
switch (_that) {
case _TextScale() when $default != null:
return $default(_that.enable,_that.scale);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TextScale implements TextScale {
  const _TextScale({this.enable = false, this.scale = 1.0});
  factory _TextScale.fromJson(Map<String, dynamic> json) => _$TextScaleFromJson(json);

@override@JsonKey() final  bool enable;
@override@JsonKey() final  double scale;

/// Create a copy of TextScale
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TextScaleCopyWith<_TextScale> get copyWith => __$TextScaleCopyWithImpl<_TextScale>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TextScaleToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TextScale&&(identical(other.enable, enable) || other.enable == enable)&&(identical(other.scale, scale) || other.scale == scale));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,enable,scale);

@override
String toString() {
  return 'TextScale(enable: $enable, scale: $scale)';
}


}

/// @nodoc
abstract mixin class _$TextScaleCopyWith<$Res> implements $TextScaleCopyWith<$Res> {
  factory _$TextScaleCopyWith(_TextScale value, $Res Function(_TextScale) _then) = __$TextScaleCopyWithImpl;
@override @useResult
$Res call({
 bool enable, double scale
});




}
/// @nodoc
class __$TextScaleCopyWithImpl<$Res>
    implements _$TextScaleCopyWith<$Res> {
  __$TextScaleCopyWithImpl(this._self, this._then);

  final _TextScale _self;
  final $Res Function(_TextScale) _then;

/// Create a copy of TextScale
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? enable = null,Object? scale = null,}) {
  return _then(_TextScale(
enable: null == enable ? _self.enable : enable // ignore: cast_nullable_to_non_nullable
as bool,scale: null == scale ? _self.scale : scale // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}


/// @nodoc
mixin _$ThemeProps {

 int? get primaryColor; List<int> get primaryColors; ThemeMode get themeMode; DynamicSchemeVariant get schemeVariant; bool get pureBlack; TextScale get textScale;
/// Create a copy of ThemeProps
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ThemePropsCopyWith<ThemeProps> get copyWith => _$ThemePropsCopyWithImpl<ThemeProps>(this as ThemeProps, _$identity);

  /// Serializes this ThemeProps to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ThemeProps&&(identical(other.primaryColor, primaryColor) || other.primaryColor == primaryColor)&&const DeepCollectionEquality().equals(other.primaryColors, primaryColors)&&(identical(other.themeMode, themeMode) || other.themeMode == themeMode)&&(identical(other.schemeVariant, schemeVariant) || other.schemeVariant == schemeVariant)&&(identical(other.pureBlack, pureBlack) || other.pureBlack == pureBlack)&&(identical(other.textScale, textScale) || other.textScale == textScale));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,primaryColor,const DeepCollectionEquality().hash(primaryColors),themeMode,schemeVariant,pureBlack,textScale);

@override
String toString() {
  return 'ThemeProps(primaryColor: $primaryColor, primaryColors: $primaryColors, themeMode: $themeMode, schemeVariant: $schemeVariant, pureBlack: $pureBlack, textScale: $textScale)';
}


}

/// @nodoc
abstract mixin class $ThemePropsCopyWith<$Res>  {
  factory $ThemePropsCopyWith(ThemeProps value, $Res Function(ThemeProps) _then) = _$ThemePropsCopyWithImpl;
@useResult
$Res call({
 int? primaryColor, List<int> primaryColors, ThemeMode themeMode, DynamicSchemeVariant schemeVariant, bool pureBlack, TextScale textScale
});


$TextScaleCopyWith<$Res> get textScale;

}
/// @nodoc
class _$ThemePropsCopyWithImpl<$Res>
    implements $ThemePropsCopyWith<$Res> {
  _$ThemePropsCopyWithImpl(this._self, this._then);

  final ThemeProps _self;
  final $Res Function(ThemeProps) _then;

/// Create a copy of ThemeProps
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? primaryColor = freezed,Object? primaryColors = null,Object? themeMode = null,Object? schemeVariant = null,Object? pureBlack = null,Object? textScale = null,}) {
  return _then(_self.copyWith(
primaryColor: freezed == primaryColor ? _self.primaryColor : primaryColor // ignore: cast_nullable_to_non_nullable
as int?,primaryColors: null == primaryColors ? _self.primaryColors : primaryColors // ignore: cast_nullable_to_non_nullable
as List<int>,themeMode: null == themeMode ? _self.themeMode : themeMode // ignore: cast_nullable_to_non_nullable
as ThemeMode,schemeVariant: null == schemeVariant ? _self.schemeVariant : schemeVariant // ignore: cast_nullable_to_non_nullable
as DynamicSchemeVariant,pureBlack: null == pureBlack ? _self.pureBlack : pureBlack // ignore: cast_nullable_to_non_nullable
as bool,textScale: null == textScale ? _self.textScale : textScale // ignore: cast_nullable_to_non_nullable
as TextScale,
  ));
}
/// Create a copy of ThemeProps
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TextScaleCopyWith<$Res> get textScale {
  
  return $TextScaleCopyWith<$Res>(_self.textScale, (value) {
    return _then(_self.copyWith(textScale: value));
  });
}
}


/// Adds pattern-matching-related methods to [ThemeProps].
extension ThemePropsPatterns on ThemeProps {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ThemeProps value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ThemeProps() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ThemeProps value)  $default,){
final _that = this;
switch (_that) {
case _ThemeProps():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ThemeProps value)?  $default,){
final _that = this;
switch (_that) {
case _ThemeProps() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? primaryColor,  List<int> primaryColors,  ThemeMode themeMode,  DynamicSchemeVariant schemeVariant,  bool pureBlack,  TextScale textScale)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ThemeProps() when $default != null:
return $default(_that.primaryColor,_that.primaryColors,_that.themeMode,_that.schemeVariant,_that.pureBlack,_that.textScale);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? primaryColor,  List<int> primaryColors,  ThemeMode themeMode,  DynamicSchemeVariant schemeVariant,  bool pureBlack,  TextScale textScale)  $default,) {final _that = this;
switch (_that) {
case _ThemeProps():
return $default(_that.primaryColor,_that.primaryColors,_that.themeMode,_that.schemeVariant,_that.pureBlack,_that.textScale);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? primaryColor,  List<int> primaryColors,  ThemeMode themeMode,  DynamicSchemeVariant schemeVariant,  bool pureBlack,  TextScale textScale)?  $default,) {final _that = this;
switch (_that) {
case _ThemeProps() when $default != null:
return $default(_that.primaryColor,_that.primaryColors,_that.themeMode,_that.schemeVariant,_that.pureBlack,_that.textScale);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ThemeProps implements ThemeProps {
  const _ThemeProps({this.primaryColor, final  List<int> primaryColors = defaultPrimaryColors, this.themeMode = ThemeMode.dark, this.schemeVariant = DynamicSchemeVariant.content, this.pureBlack = false, this.textScale = const TextScale()}): _primaryColors = primaryColors;
  factory _ThemeProps.fromJson(Map<String, dynamic> json) => _$ThemePropsFromJson(json);

@override final  int? primaryColor;
 final  List<int> _primaryColors;
@override@JsonKey() List<int> get primaryColors {
  if (_primaryColors is EqualUnmodifiableListView) return _primaryColors;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_primaryColors);
}

@override@JsonKey() final  ThemeMode themeMode;
@override@JsonKey() final  DynamicSchemeVariant schemeVariant;
@override@JsonKey() final  bool pureBlack;
@override@JsonKey() final  TextScale textScale;

/// Create a copy of ThemeProps
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ThemePropsCopyWith<_ThemeProps> get copyWith => __$ThemePropsCopyWithImpl<_ThemeProps>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ThemePropsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ThemeProps&&(identical(other.primaryColor, primaryColor) || other.primaryColor == primaryColor)&&const DeepCollectionEquality().equals(other._primaryColors, _primaryColors)&&(identical(other.themeMode, themeMode) || other.themeMode == themeMode)&&(identical(other.schemeVariant, schemeVariant) || other.schemeVariant == schemeVariant)&&(identical(other.pureBlack, pureBlack) || other.pureBlack == pureBlack)&&(identical(other.textScale, textScale) || other.textScale == textScale));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,primaryColor,const DeepCollectionEquality().hash(_primaryColors),themeMode,schemeVariant,pureBlack,textScale);

@override
String toString() {
  return 'ThemeProps(primaryColor: $primaryColor, primaryColors: $primaryColors, themeMode: $themeMode, schemeVariant: $schemeVariant, pureBlack: $pureBlack, textScale: $textScale)';
}


}

/// @nodoc
abstract mixin class _$ThemePropsCopyWith<$Res> implements $ThemePropsCopyWith<$Res> {
  factory _$ThemePropsCopyWith(_ThemeProps value, $Res Function(_ThemeProps) _then) = __$ThemePropsCopyWithImpl;
@override @useResult
$Res call({
 int? primaryColor, List<int> primaryColors, ThemeMode themeMode, DynamicSchemeVariant schemeVariant, bool pureBlack, TextScale textScale
});


@override $TextScaleCopyWith<$Res> get textScale;

}
/// @nodoc
class __$ThemePropsCopyWithImpl<$Res>
    implements _$ThemePropsCopyWith<$Res> {
  __$ThemePropsCopyWithImpl(this._self, this._then);

  final _ThemeProps _self;
  final $Res Function(_ThemeProps) _then;

/// Create a copy of ThemeProps
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? primaryColor = freezed,Object? primaryColors = null,Object? themeMode = null,Object? schemeVariant = null,Object? pureBlack = null,Object? textScale = null,}) {
  return _then(_ThemeProps(
primaryColor: freezed == primaryColor ? _self.primaryColor : primaryColor // ignore: cast_nullable_to_non_nullable
as int?,primaryColors: null == primaryColors ? _self._primaryColors : primaryColors // ignore: cast_nullable_to_non_nullable
as List<int>,themeMode: null == themeMode ? _self.themeMode : themeMode // ignore: cast_nullable_to_non_nullable
as ThemeMode,schemeVariant: null == schemeVariant ? _self.schemeVariant : schemeVariant // ignore: cast_nullable_to_non_nullable
as DynamicSchemeVariant,pureBlack: null == pureBlack ? _self.pureBlack : pureBlack // ignore: cast_nullable_to_non_nullable
as bool,textScale: null == textScale ? _self.textScale : textScale // ignore: cast_nullable_to_non_nullable
as TextScale,
  ));
}

/// Create a copy of ThemeProps
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TextScaleCopyWith<$Res> get textScale {
  
  return $TextScaleCopyWith<$Res>(_self.textScale, (value) {
    return _then(_self.copyWith(textScale: value));
  });
}
}


/// @nodoc
mixin _$ScriptProps {

 String? get currentId; List<Script> get scripts;
/// Create a copy of ScriptProps
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ScriptPropsCopyWith<ScriptProps> get copyWith => _$ScriptPropsCopyWithImpl<ScriptProps>(this as ScriptProps, _$identity);

  /// Serializes this ScriptProps to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ScriptProps&&(identical(other.currentId, currentId) || other.currentId == currentId)&&const DeepCollectionEquality().equals(other.scripts, scripts));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,currentId,const DeepCollectionEquality().hash(scripts));

@override
String toString() {
  return 'ScriptProps(currentId: $currentId, scripts: $scripts)';
}


}

/// @nodoc
abstract mixin class $ScriptPropsCopyWith<$Res>  {
  factory $ScriptPropsCopyWith(ScriptProps value, $Res Function(ScriptProps) _then) = _$ScriptPropsCopyWithImpl;
@useResult
$Res call({
 String? currentId, List<Script> scripts
});




}
/// @nodoc
class _$ScriptPropsCopyWithImpl<$Res>
    implements $ScriptPropsCopyWith<$Res> {
  _$ScriptPropsCopyWithImpl(this._self, this._then);

  final ScriptProps _self;
  final $Res Function(ScriptProps) _then;

/// Create a copy of ScriptProps
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? currentId = freezed,Object? scripts = null,}) {
  return _then(_self.copyWith(
currentId: freezed == currentId ? _self.currentId : currentId // ignore: cast_nullable_to_non_nullable
as String?,scripts: null == scripts ? _self.scripts : scripts // ignore: cast_nullable_to_non_nullable
as List<Script>,
  ));
}

}


/// Adds pattern-matching-related methods to [ScriptProps].
extension ScriptPropsPatterns on ScriptProps {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ScriptProps value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ScriptProps() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ScriptProps value)  $default,){
final _that = this;
switch (_that) {
case _ScriptProps():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ScriptProps value)?  $default,){
final _that = this;
switch (_that) {
case _ScriptProps() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? currentId,  List<Script> scripts)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ScriptProps() when $default != null:
return $default(_that.currentId,_that.scripts);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? currentId,  List<Script> scripts)  $default,) {final _that = this;
switch (_that) {
case _ScriptProps():
return $default(_that.currentId,_that.scripts);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? currentId,  List<Script> scripts)?  $default,) {final _that = this;
switch (_that) {
case _ScriptProps() when $default != null:
return $default(_that.currentId,_that.scripts);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ScriptProps implements ScriptProps {
  const _ScriptProps({this.currentId, final  List<Script> scripts = const []}): _scripts = scripts;
  factory _ScriptProps.fromJson(Map<String, dynamic> json) => _$ScriptPropsFromJson(json);

@override final  String? currentId;
 final  List<Script> _scripts;
@override@JsonKey() List<Script> get scripts {
  if (_scripts is EqualUnmodifiableListView) return _scripts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_scripts);
}


/// Create a copy of ScriptProps
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ScriptPropsCopyWith<_ScriptProps> get copyWith => __$ScriptPropsCopyWithImpl<_ScriptProps>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ScriptPropsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ScriptProps&&(identical(other.currentId, currentId) || other.currentId == currentId)&&const DeepCollectionEquality().equals(other._scripts, _scripts));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,currentId,const DeepCollectionEquality().hash(_scripts));

@override
String toString() {
  return 'ScriptProps(currentId: $currentId, scripts: $scripts)';
}


}

/// @nodoc
abstract mixin class _$ScriptPropsCopyWith<$Res> implements $ScriptPropsCopyWith<$Res> {
  factory _$ScriptPropsCopyWith(_ScriptProps value, $Res Function(_ScriptProps) _then) = __$ScriptPropsCopyWithImpl;
@override @useResult
$Res call({
 String? currentId, List<Script> scripts
});




}
/// @nodoc
class __$ScriptPropsCopyWithImpl<$Res>
    implements _$ScriptPropsCopyWith<$Res> {
  __$ScriptPropsCopyWithImpl(this._self, this._then);

  final _ScriptProps _self;
  final $Res Function(_ScriptProps) _then;

/// Create a copy of ScriptProps
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? currentId = freezed,Object? scripts = null,}) {
  return _then(_ScriptProps(
currentId: freezed == currentId ? _self.currentId : currentId // ignore: cast_nullable_to_non_nullable
as String?,scripts: null == scripts ? _self._scripts : scripts // ignore: cast_nullable_to_non_nullable
as List<Script>,
  ));
}


}


/// @nodoc
mixin _$Config {

@JsonKey(fromJson: AppSettingProps.safeFromJson) AppSettingProps get appSetting; List<Profile> get profiles; List<HotKeyAction> get hotKeyActions; String? get currentProfileId; bool get overrideDns; DAV? get dav; NetworkProps get networkProps; VpnProps get vpnProps;@JsonKey(fromJson: ThemeProps.safeFromJson) ThemeProps get themeProps; ProxiesStyle get proxiesStyle; WindowProps get windowProps; ClashConfig get patchClashConfig; List<Script> get scripts; List<Rule> get rules;
/// Create a copy of Config
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ConfigCopyWith<Config> get copyWith => _$ConfigCopyWithImpl<Config>(this as Config, _$identity);

  /// Serializes this Config to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Config&&(identical(other.appSetting, appSetting) || other.appSetting == appSetting)&&const DeepCollectionEquality().equals(other.profiles, profiles)&&const DeepCollectionEquality().equals(other.hotKeyActions, hotKeyActions)&&(identical(other.currentProfileId, currentProfileId) || other.currentProfileId == currentProfileId)&&(identical(other.overrideDns, overrideDns) || other.overrideDns == overrideDns)&&(identical(other.dav, dav) || other.dav == dav)&&(identical(other.networkProps, networkProps) || other.networkProps == networkProps)&&(identical(other.vpnProps, vpnProps) || other.vpnProps == vpnProps)&&(identical(other.themeProps, themeProps) || other.themeProps == themeProps)&&(identical(other.proxiesStyle, proxiesStyle) || other.proxiesStyle == proxiesStyle)&&(identical(other.windowProps, windowProps) || other.windowProps == windowProps)&&(identical(other.patchClashConfig, patchClashConfig) || other.patchClashConfig == patchClashConfig)&&const DeepCollectionEquality().equals(other.scripts, scripts)&&const DeepCollectionEquality().equals(other.rules, rules));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,appSetting,const DeepCollectionEquality().hash(profiles),const DeepCollectionEquality().hash(hotKeyActions),currentProfileId,overrideDns,dav,networkProps,vpnProps,themeProps,proxiesStyle,windowProps,patchClashConfig,const DeepCollectionEquality().hash(scripts),const DeepCollectionEquality().hash(rules));

@override
String toString() {
  return 'Config(appSetting: $appSetting, profiles: $profiles, hotKeyActions: $hotKeyActions, currentProfileId: $currentProfileId, overrideDns: $overrideDns, dav: $dav, networkProps: $networkProps, vpnProps: $vpnProps, themeProps: $themeProps, proxiesStyle: $proxiesStyle, windowProps: $windowProps, patchClashConfig: $patchClashConfig, scripts: $scripts, rules: $rules)';
}


}

/// @nodoc
abstract mixin class $ConfigCopyWith<$Res>  {
  factory $ConfigCopyWith(Config value, $Res Function(Config) _then) = _$ConfigCopyWithImpl;
@useResult
$Res call({
@JsonKey(fromJson: AppSettingProps.safeFromJson) AppSettingProps appSetting, List<Profile> profiles, List<HotKeyAction> hotKeyActions, String? currentProfileId, bool overrideDns, DAV? dav, NetworkProps networkProps, VpnProps vpnProps,@JsonKey(fromJson: ThemeProps.safeFromJson) ThemeProps themeProps, ProxiesStyle proxiesStyle, WindowProps windowProps, ClashConfig patchClashConfig, List<Script> scripts, List<Rule> rules
});


$AppSettingPropsCopyWith<$Res> get appSetting;$DAVCopyWith<$Res>? get dav;$NetworkPropsCopyWith<$Res> get networkProps;$VpnPropsCopyWith<$Res> get vpnProps;$ThemePropsCopyWith<$Res> get themeProps;$ProxiesStyleCopyWith<$Res> get proxiesStyle;$WindowPropsCopyWith<$Res> get windowProps;$ClashConfigCopyWith<$Res> get patchClashConfig;

}
/// @nodoc
class _$ConfigCopyWithImpl<$Res>
    implements $ConfigCopyWith<$Res> {
  _$ConfigCopyWithImpl(this._self, this._then);

  final Config _self;
  final $Res Function(Config) _then;

/// Create a copy of Config
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? appSetting = null,Object? profiles = null,Object? hotKeyActions = null,Object? currentProfileId = freezed,Object? overrideDns = null,Object? dav = freezed,Object? networkProps = null,Object? vpnProps = null,Object? themeProps = null,Object? proxiesStyle = null,Object? windowProps = null,Object? patchClashConfig = null,Object? scripts = null,Object? rules = null,}) {
  return _then(_self.copyWith(
appSetting: null == appSetting ? _self.appSetting : appSetting // ignore: cast_nullable_to_non_nullable
as AppSettingProps,profiles: null == profiles ? _self.profiles : profiles // ignore: cast_nullable_to_non_nullable
as List<Profile>,hotKeyActions: null == hotKeyActions ? _self.hotKeyActions : hotKeyActions // ignore: cast_nullable_to_non_nullable
as List<HotKeyAction>,currentProfileId: freezed == currentProfileId ? _self.currentProfileId : currentProfileId // ignore: cast_nullable_to_non_nullable
as String?,overrideDns: null == overrideDns ? _self.overrideDns : overrideDns // ignore: cast_nullable_to_non_nullable
as bool,dav: freezed == dav ? _self.dav : dav // ignore: cast_nullable_to_non_nullable
as DAV?,networkProps: null == networkProps ? _self.networkProps : networkProps // ignore: cast_nullable_to_non_nullable
as NetworkProps,vpnProps: null == vpnProps ? _self.vpnProps : vpnProps // ignore: cast_nullable_to_non_nullable
as VpnProps,themeProps: null == themeProps ? _self.themeProps : themeProps // ignore: cast_nullable_to_non_nullable
as ThemeProps,proxiesStyle: null == proxiesStyle ? _self.proxiesStyle : proxiesStyle // ignore: cast_nullable_to_non_nullable
as ProxiesStyle,windowProps: null == windowProps ? _self.windowProps : windowProps // ignore: cast_nullable_to_non_nullable
as WindowProps,patchClashConfig: null == patchClashConfig ? _self.patchClashConfig : patchClashConfig // ignore: cast_nullable_to_non_nullable
as ClashConfig,scripts: null == scripts ? _self.scripts : scripts // ignore: cast_nullable_to_non_nullable
as List<Script>,rules: null == rules ? _self.rules : rules // ignore: cast_nullable_to_non_nullable
as List<Rule>,
  ));
}
/// Create a copy of Config
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AppSettingPropsCopyWith<$Res> get appSetting {
  
  return $AppSettingPropsCopyWith<$Res>(_self.appSetting, (value) {
    return _then(_self.copyWith(appSetting: value));
  });
}/// Create a copy of Config
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DAVCopyWith<$Res>? get dav {
    if (_self.dav == null) {
    return null;
  }

  return $DAVCopyWith<$Res>(_self.dav!, (value) {
    return _then(_self.copyWith(dav: value));
  });
}/// Create a copy of Config
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$NetworkPropsCopyWith<$Res> get networkProps {
  
  return $NetworkPropsCopyWith<$Res>(_self.networkProps, (value) {
    return _then(_self.copyWith(networkProps: value));
  });
}/// Create a copy of Config
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$VpnPropsCopyWith<$Res> get vpnProps {
  
  return $VpnPropsCopyWith<$Res>(_self.vpnProps, (value) {
    return _then(_self.copyWith(vpnProps: value));
  });
}/// Create a copy of Config
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ThemePropsCopyWith<$Res> get themeProps {
  
  return $ThemePropsCopyWith<$Res>(_self.themeProps, (value) {
    return _then(_self.copyWith(themeProps: value));
  });
}/// Create a copy of Config
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProxiesStyleCopyWith<$Res> get proxiesStyle {
  
  return $ProxiesStyleCopyWith<$Res>(_self.proxiesStyle, (value) {
    return _then(_self.copyWith(proxiesStyle: value));
  });
}/// Create a copy of Config
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$WindowPropsCopyWith<$Res> get windowProps {
  
  return $WindowPropsCopyWith<$Res>(_self.windowProps, (value) {
    return _then(_self.copyWith(windowProps: value));
  });
}/// Create a copy of Config
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ClashConfigCopyWith<$Res> get patchClashConfig {
  
  return $ClashConfigCopyWith<$Res>(_self.patchClashConfig, (value) {
    return _then(_self.copyWith(patchClashConfig: value));
  });
}
}


/// Adds pattern-matching-related methods to [Config].
extension ConfigPatterns on Config {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Config value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Config() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Config value)  $default,){
final _that = this;
switch (_that) {
case _Config():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Config value)?  $default,){
final _that = this;
switch (_that) {
case _Config() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(fromJson: AppSettingProps.safeFromJson)  AppSettingProps appSetting,  List<Profile> profiles,  List<HotKeyAction> hotKeyActions,  String? currentProfileId,  bool overrideDns,  DAV? dav,  NetworkProps networkProps,  VpnProps vpnProps, @JsonKey(fromJson: ThemeProps.safeFromJson)  ThemeProps themeProps,  ProxiesStyle proxiesStyle,  WindowProps windowProps,  ClashConfig patchClashConfig,  List<Script> scripts,  List<Rule> rules)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Config() when $default != null:
return $default(_that.appSetting,_that.profiles,_that.hotKeyActions,_that.currentProfileId,_that.overrideDns,_that.dav,_that.networkProps,_that.vpnProps,_that.themeProps,_that.proxiesStyle,_that.windowProps,_that.patchClashConfig,_that.scripts,_that.rules);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(fromJson: AppSettingProps.safeFromJson)  AppSettingProps appSetting,  List<Profile> profiles,  List<HotKeyAction> hotKeyActions,  String? currentProfileId,  bool overrideDns,  DAV? dav,  NetworkProps networkProps,  VpnProps vpnProps, @JsonKey(fromJson: ThemeProps.safeFromJson)  ThemeProps themeProps,  ProxiesStyle proxiesStyle,  WindowProps windowProps,  ClashConfig patchClashConfig,  List<Script> scripts,  List<Rule> rules)  $default,) {final _that = this;
switch (_that) {
case _Config():
return $default(_that.appSetting,_that.profiles,_that.hotKeyActions,_that.currentProfileId,_that.overrideDns,_that.dav,_that.networkProps,_that.vpnProps,_that.themeProps,_that.proxiesStyle,_that.windowProps,_that.patchClashConfig,_that.scripts,_that.rules);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(fromJson: AppSettingProps.safeFromJson)  AppSettingProps appSetting,  List<Profile> profiles,  List<HotKeyAction> hotKeyActions,  String? currentProfileId,  bool overrideDns,  DAV? dav,  NetworkProps networkProps,  VpnProps vpnProps, @JsonKey(fromJson: ThemeProps.safeFromJson)  ThemeProps themeProps,  ProxiesStyle proxiesStyle,  WindowProps windowProps,  ClashConfig patchClashConfig,  List<Script> scripts,  List<Rule> rules)?  $default,) {final _that = this;
switch (_that) {
case _Config() when $default != null:
return $default(_that.appSetting,_that.profiles,_that.hotKeyActions,_that.currentProfileId,_that.overrideDns,_that.dav,_that.networkProps,_that.vpnProps,_that.themeProps,_that.proxiesStyle,_that.windowProps,_that.patchClashConfig,_that.scripts,_that.rules);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Config implements Config {
  const _Config({@JsonKey(fromJson: AppSettingProps.safeFromJson) this.appSetting = defaultAppSettingProps, final  List<Profile> profiles = const [], final  List<HotKeyAction> hotKeyActions = const [], this.currentProfileId, this.overrideDns = false, this.dav, this.networkProps = defaultNetworkProps, this.vpnProps = defaultVpnProps, @JsonKey(fromJson: ThemeProps.safeFromJson) required this.themeProps, this.proxiesStyle = defaultProxiesStyle, this.windowProps = defaultWindowProps, this.patchClashConfig = defaultClashConfig, final  List<Script> scripts = const [], final  List<Rule> rules = const []}): _profiles = profiles,_hotKeyActions = hotKeyActions,_scripts = scripts,_rules = rules;
  factory _Config.fromJson(Map<String, dynamic> json) => _$ConfigFromJson(json);

@override@JsonKey(fromJson: AppSettingProps.safeFromJson) final  AppSettingProps appSetting;
 final  List<Profile> _profiles;
@override@JsonKey() List<Profile> get profiles {
  if (_profiles is EqualUnmodifiableListView) return _profiles;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_profiles);
}

 final  List<HotKeyAction> _hotKeyActions;
@override@JsonKey() List<HotKeyAction> get hotKeyActions {
  if (_hotKeyActions is EqualUnmodifiableListView) return _hotKeyActions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_hotKeyActions);
}

@override final  String? currentProfileId;
@override@JsonKey() final  bool overrideDns;
@override final  DAV? dav;
@override@JsonKey() final  NetworkProps networkProps;
@override@JsonKey() final  VpnProps vpnProps;
@override@JsonKey(fromJson: ThemeProps.safeFromJson) final  ThemeProps themeProps;
@override@JsonKey() final  ProxiesStyle proxiesStyle;
@override@JsonKey() final  WindowProps windowProps;
@override@JsonKey() final  ClashConfig patchClashConfig;
 final  List<Script> _scripts;
@override@JsonKey() List<Script> get scripts {
  if (_scripts is EqualUnmodifiableListView) return _scripts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_scripts);
}

 final  List<Rule> _rules;
@override@JsonKey() List<Rule> get rules {
  if (_rules is EqualUnmodifiableListView) return _rules;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_rules);
}


/// Create a copy of Config
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ConfigCopyWith<_Config> get copyWith => __$ConfigCopyWithImpl<_Config>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ConfigToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Config&&(identical(other.appSetting, appSetting) || other.appSetting == appSetting)&&const DeepCollectionEquality().equals(other._profiles, _profiles)&&const DeepCollectionEquality().equals(other._hotKeyActions, _hotKeyActions)&&(identical(other.currentProfileId, currentProfileId) || other.currentProfileId == currentProfileId)&&(identical(other.overrideDns, overrideDns) || other.overrideDns == overrideDns)&&(identical(other.dav, dav) || other.dav == dav)&&(identical(other.networkProps, networkProps) || other.networkProps == networkProps)&&(identical(other.vpnProps, vpnProps) || other.vpnProps == vpnProps)&&(identical(other.themeProps, themeProps) || other.themeProps == themeProps)&&(identical(other.proxiesStyle, proxiesStyle) || other.proxiesStyle == proxiesStyle)&&(identical(other.windowProps, windowProps) || other.windowProps == windowProps)&&(identical(other.patchClashConfig, patchClashConfig) || other.patchClashConfig == patchClashConfig)&&const DeepCollectionEquality().equals(other._scripts, _scripts)&&const DeepCollectionEquality().equals(other._rules, _rules));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,appSetting,const DeepCollectionEquality().hash(_profiles),const DeepCollectionEquality().hash(_hotKeyActions),currentProfileId,overrideDns,dav,networkProps,vpnProps,themeProps,proxiesStyle,windowProps,patchClashConfig,const DeepCollectionEquality().hash(_scripts),const DeepCollectionEquality().hash(_rules));

@override
String toString() {
  return 'Config(appSetting: $appSetting, profiles: $profiles, hotKeyActions: $hotKeyActions, currentProfileId: $currentProfileId, overrideDns: $overrideDns, dav: $dav, networkProps: $networkProps, vpnProps: $vpnProps, themeProps: $themeProps, proxiesStyle: $proxiesStyle, windowProps: $windowProps, patchClashConfig: $patchClashConfig, scripts: $scripts, rules: $rules)';
}


}

/// @nodoc
abstract mixin class _$ConfigCopyWith<$Res> implements $ConfigCopyWith<$Res> {
  factory _$ConfigCopyWith(_Config value, $Res Function(_Config) _then) = __$ConfigCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(fromJson: AppSettingProps.safeFromJson) AppSettingProps appSetting, List<Profile> profiles, List<HotKeyAction> hotKeyActions, String? currentProfileId, bool overrideDns, DAV? dav, NetworkProps networkProps, VpnProps vpnProps,@JsonKey(fromJson: ThemeProps.safeFromJson) ThemeProps themeProps, ProxiesStyle proxiesStyle, WindowProps windowProps, ClashConfig patchClashConfig, List<Script> scripts, List<Rule> rules
});


@override $AppSettingPropsCopyWith<$Res> get appSetting;@override $DAVCopyWith<$Res>? get dav;@override $NetworkPropsCopyWith<$Res> get networkProps;@override $VpnPropsCopyWith<$Res> get vpnProps;@override $ThemePropsCopyWith<$Res> get themeProps;@override $ProxiesStyleCopyWith<$Res> get proxiesStyle;@override $WindowPropsCopyWith<$Res> get windowProps;@override $ClashConfigCopyWith<$Res> get patchClashConfig;

}
/// @nodoc
class __$ConfigCopyWithImpl<$Res>
    implements _$ConfigCopyWith<$Res> {
  __$ConfigCopyWithImpl(this._self, this._then);

  final _Config _self;
  final $Res Function(_Config) _then;

/// Create a copy of Config
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? appSetting = null,Object? profiles = null,Object? hotKeyActions = null,Object? currentProfileId = freezed,Object? overrideDns = null,Object? dav = freezed,Object? networkProps = null,Object? vpnProps = null,Object? themeProps = null,Object? proxiesStyle = null,Object? windowProps = null,Object? patchClashConfig = null,Object? scripts = null,Object? rules = null,}) {
  return _then(_Config(
appSetting: null == appSetting ? _self.appSetting : appSetting // ignore: cast_nullable_to_non_nullable
as AppSettingProps,profiles: null == profiles ? _self._profiles : profiles // ignore: cast_nullable_to_non_nullable
as List<Profile>,hotKeyActions: null == hotKeyActions ? _self._hotKeyActions : hotKeyActions // ignore: cast_nullable_to_non_nullable
as List<HotKeyAction>,currentProfileId: freezed == currentProfileId ? _self.currentProfileId : currentProfileId // ignore: cast_nullable_to_non_nullable
as String?,overrideDns: null == overrideDns ? _self.overrideDns : overrideDns // ignore: cast_nullable_to_non_nullable
as bool,dav: freezed == dav ? _self.dav : dav // ignore: cast_nullable_to_non_nullable
as DAV?,networkProps: null == networkProps ? _self.networkProps : networkProps // ignore: cast_nullable_to_non_nullable
as NetworkProps,vpnProps: null == vpnProps ? _self.vpnProps : vpnProps // ignore: cast_nullable_to_non_nullable
as VpnProps,themeProps: null == themeProps ? _self.themeProps : themeProps // ignore: cast_nullable_to_non_nullable
as ThemeProps,proxiesStyle: null == proxiesStyle ? _self.proxiesStyle : proxiesStyle // ignore: cast_nullable_to_non_nullable
as ProxiesStyle,windowProps: null == windowProps ? _self.windowProps : windowProps // ignore: cast_nullable_to_non_nullable
as WindowProps,patchClashConfig: null == patchClashConfig ? _self.patchClashConfig : patchClashConfig // ignore: cast_nullable_to_non_nullable
as ClashConfig,scripts: null == scripts ? _self._scripts : scripts // ignore: cast_nullable_to_non_nullable
as List<Script>,rules: null == rules ? _self._rules : rules // ignore: cast_nullable_to_non_nullable
as List<Rule>,
  ));
}

/// Create a copy of Config
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AppSettingPropsCopyWith<$Res> get appSetting {
  
  return $AppSettingPropsCopyWith<$Res>(_self.appSetting, (value) {
    return _then(_self.copyWith(appSetting: value));
  });
}/// Create a copy of Config
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DAVCopyWith<$Res>? get dav {
    if (_self.dav == null) {
    return null;
  }

  return $DAVCopyWith<$Res>(_self.dav!, (value) {
    return _then(_self.copyWith(dav: value));
  });
}/// Create a copy of Config
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$NetworkPropsCopyWith<$Res> get networkProps {
  
  return $NetworkPropsCopyWith<$Res>(_self.networkProps, (value) {
    return _then(_self.copyWith(networkProps: value));
  });
}/// Create a copy of Config
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$VpnPropsCopyWith<$Res> get vpnProps {
  
  return $VpnPropsCopyWith<$Res>(_self.vpnProps, (value) {
    return _then(_self.copyWith(vpnProps: value));
  });
}/// Create a copy of Config
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ThemePropsCopyWith<$Res> get themeProps {
  
  return $ThemePropsCopyWith<$Res>(_self.themeProps, (value) {
    return _then(_self.copyWith(themeProps: value));
  });
}/// Create a copy of Config
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProxiesStyleCopyWith<$Res> get proxiesStyle {
  
  return $ProxiesStyleCopyWith<$Res>(_self.proxiesStyle, (value) {
    return _then(_self.copyWith(proxiesStyle: value));
  });
}/// Create a copy of Config
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$WindowPropsCopyWith<$Res> get windowProps {
  
  return $WindowPropsCopyWith<$Res>(_self.windowProps, (value) {
    return _then(_self.copyWith(windowProps: value));
  });
}/// Create a copy of Config
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ClashConfigCopyWith<$Res> get patchClashConfig {
  
  return $ClashConfigCopyWith<$Res>(_self.patchClashConfig, (value) {
    return _then(_self.copyWith(patchClashConfig: value));
  });
}
}

// dart format on
