// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

AppSettingProps _$AppSettingPropsFromJson(Map<String, dynamic> json) {
  return _AppSettingProps.fromJson(json);
}

/// @nodoc
mixin _$AppSettingProps {
  String? get locale => throw _privateConstructorUsedError;
  @JsonKey(fromJson: dashboardWidgetsSafeFormJson)
  List<DashboardWidget> get dashboardWidgets =>
      throw _privateConstructorUsedError;
  bool get onlyStatisticsProxy => throw _privateConstructorUsedError;
  bool get autoLaunch => throw _privateConstructorUsedError;
  bool get silentLaunch => throw _privateConstructorUsedError;
  bool get autoRun => throw _privateConstructorUsedError;
  bool get openLogs => throw _privateConstructorUsedError;
  bool get closeConnections => throw _privateConstructorUsedError;
  String get testUrl => throw _privateConstructorUsedError;
  bool get isAnimateToPage => throw _privateConstructorUsedError;
  bool get autoCheckUpdate => throw _privateConstructorUsedError;
  bool get showLabel => throw _privateConstructorUsedError;
  bool get disclaimerAccepted => throw _privateConstructorUsedError;
  bool get minimizeOnExit => throw _privateConstructorUsedError;
  bool get hidden => throw _privateConstructorUsedError;
  bool get developerMode => throw _privateConstructorUsedError;
  RecoveryStrategy get recoveryStrategy => throw _privateConstructorUsedError;

  /// Serializes this AppSettingProps to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AppSettingProps
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AppSettingPropsCopyWith<AppSettingProps> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AppSettingPropsCopyWith<$Res> {
  factory $AppSettingPropsCopyWith(
          AppSettingProps value, $Res Function(AppSettingProps) then) =
      _$AppSettingPropsCopyWithImpl<$Res, AppSettingProps>;
  @useResult
  $Res call(
      {String? locale,
      @JsonKey(fromJson: dashboardWidgetsSafeFormJson)
      List<DashboardWidget> dashboardWidgets,
      bool onlyStatisticsProxy,
      bool autoLaunch,
      bool silentLaunch,
      bool autoRun,
      bool openLogs,
      bool closeConnections,
      String testUrl,
      bool isAnimateToPage,
      bool autoCheckUpdate,
      bool showLabel,
      bool disclaimerAccepted,
      bool minimizeOnExit,
      bool hidden,
      bool developerMode,
      RecoveryStrategy recoveryStrategy});
}

/// @nodoc
class _$AppSettingPropsCopyWithImpl<$Res, $Val extends AppSettingProps>
    implements $AppSettingPropsCopyWith<$Res> {
  _$AppSettingPropsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AppSettingProps
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? locale = freezed,
    Object? dashboardWidgets = null,
    Object? onlyStatisticsProxy = null,
    Object? autoLaunch = null,
    Object? silentLaunch = null,
    Object? autoRun = null,
    Object? openLogs = null,
    Object? closeConnections = null,
    Object? testUrl = null,
    Object? isAnimateToPage = null,
    Object? autoCheckUpdate = null,
    Object? showLabel = null,
    Object? disclaimerAccepted = null,
    Object? minimizeOnExit = null,
    Object? hidden = null,
    Object? developerMode = null,
    Object? recoveryStrategy = null,
  }) {
    return _then(_value.copyWith(
      locale: freezed == locale
          ? _value.locale
          : locale // ignore: cast_nullable_to_non_nullable
              as String?,
      dashboardWidgets: null == dashboardWidgets
          ? _value.dashboardWidgets
          : dashboardWidgets // ignore: cast_nullable_to_non_nullable
              as List<DashboardWidget>,
      onlyStatisticsProxy: null == onlyStatisticsProxy
          ? _value.onlyStatisticsProxy
          : onlyStatisticsProxy // ignore: cast_nullable_to_non_nullable
              as bool,
      autoLaunch: null == autoLaunch
          ? _value.autoLaunch
          : autoLaunch // ignore: cast_nullable_to_non_nullable
              as bool,
      silentLaunch: null == silentLaunch
          ? _value.silentLaunch
          : silentLaunch // ignore: cast_nullable_to_non_nullable
              as bool,
      autoRun: null == autoRun
          ? _value.autoRun
          : autoRun // ignore: cast_nullable_to_non_nullable
              as bool,
      openLogs: null == openLogs
          ? _value.openLogs
          : openLogs // ignore: cast_nullable_to_non_nullable
              as bool,
      closeConnections: null == closeConnections
          ? _value.closeConnections
          : closeConnections // ignore: cast_nullable_to_non_nullable
              as bool,
      testUrl: null == testUrl
          ? _value.testUrl
          : testUrl // ignore: cast_nullable_to_non_nullable
              as String,
      isAnimateToPage: null == isAnimateToPage
          ? _value.isAnimateToPage
          : isAnimateToPage // ignore: cast_nullable_to_non_nullable
              as bool,
      autoCheckUpdate: null == autoCheckUpdate
          ? _value.autoCheckUpdate
          : autoCheckUpdate // ignore: cast_nullable_to_non_nullable
              as bool,
      showLabel: null == showLabel
          ? _value.showLabel
          : showLabel // ignore: cast_nullable_to_non_nullable
              as bool,
      disclaimerAccepted: null == disclaimerAccepted
          ? _value.disclaimerAccepted
          : disclaimerAccepted // ignore: cast_nullable_to_non_nullable
              as bool,
      minimizeOnExit: null == minimizeOnExit
          ? _value.minimizeOnExit
          : minimizeOnExit // ignore: cast_nullable_to_non_nullable
              as bool,
      hidden: null == hidden
          ? _value.hidden
          : hidden // ignore: cast_nullable_to_non_nullable
              as bool,
      developerMode: null == developerMode
          ? _value.developerMode
          : developerMode // ignore: cast_nullable_to_non_nullable
              as bool,
      recoveryStrategy: null == recoveryStrategy
          ? _value.recoveryStrategy
          : recoveryStrategy // ignore: cast_nullable_to_non_nullable
              as RecoveryStrategy,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AppSettingPropsImplCopyWith<$Res>
    implements $AppSettingPropsCopyWith<$Res> {
  factory _$$AppSettingPropsImplCopyWith(_$AppSettingPropsImpl value,
          $Res Function(_$AppSettingPropsImpl) then) =
      __$$AppSettingPropsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? locale,
      @JsonKey(fromJson: dashboardWidgetsSafeFormJson)
      List<DashboardWidget> dashboardWidgets,
      bool onlyStatisticsProxy,
      bool autoLaunch,
      bool silentLaunch,
      bool autoRun,
      bool openLogs,
      bool closeConnections,
      String testUrl,
      bool isAnimateToPage,
      bool autoCheckUpdate,
      bool showLabel,
      bool disclaimerAccepted,
      bool minimizeOnExit,
      bool hidden,
      bool developerMode,
      RecoveryStrategy recoveryStrategy});
}

/// @nodoc
class __$$AppSettingPropsImplCopyWithImpl<$Res>
    extends _$AppSettingPropsCopyWithImpl<$Res, _$AppSettingPropsImpl>
    implements _$$AppSettingPropsImplCopyWith<$Res> {
  __$$AppSettingPropsImplCopyWithImpl(
      _$AppSettingPropsImpl _value, $Res Function(_$AppSettingPropsImpl) _then)
      : super(_value, _then);

  /// Create a copy of AppSettingProps
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? locale = freezed,
    Object? dashboardWidgets = null,
    Object? onlyStatisticsProxy = null,
    Object? autoLaunch = null,
    Object? silentLaunch = null,
    Object? autoRun = null,
    Object? openLogs = null,
    Object? closeConnections = null,
    Object? testUrl = null,
    Object? isAnimateToPage = null,
    Object? autoCheckUpdate = null,
    Object? showLabel = null,
    Object? disclaimerAccepted = null,
    Object? minimizeOnExit = null,
    Object? hidden = null,
    Object? developerMode = null,
    Object? recoveryStrategy = null,
  }) {
    return _then(_$AppSettingPropsImpl(
      locale: freezed == locale
          ? _value.locale
          : locale // ignore: cast_nullable_to_non_nullable
              as String?,
      dashboardWidgets: null == dashboardWidgets
          ? _value._dashboardWidgets
          : dashboardWidgets // ignore: cast_nullable_to_non_nullable
              as List<DashboardWidget>,
      onlyStatisticsProxy: null == onlyStatisticsProxy
          ? _value.onlyStatisticsProxy
          : onlyStatisticsProxy // ignore: cast_nullable_to_non_nullable
              as bool,
      autoLaunch: null == autoLaunch
          ? _value.autoLaunch
          : autoLaunch // ignore: cast_nullable_to_non_nullable
              as bool,
      silentLaunch: null == silentLaunch
          ? _value.silentLaunch
          : silentLaunch // ignore: cast_nullable_to_non_nullable
              as bool,
      autoRun: null == autoRun
          ? _value.autoRun
          : autoRun // ignore: cast_nullable_to_non_nullable
              as bool,
      openLogs: null == openLogs
          ? _value.openLogs
          : openLogs // ignore: cast_nullable_to_non_nullable
              as bool,
      closeConnections: null == closeConnections
          ? _value.closeConnections
          : closeConnections // ignore: cast_nullable_to_non_nullable
              as bool,
      testUrl: null == testUrl
          ? _value.testUrl
          : testUrl // ignore: cast_nullable_to_non_nullable
              as String,
      isAnimateToPage: null == isAnimateToPage
          ? _value.isAnimateToPage
          : isAnimateToPage // ignore: cast_nullable_to_non_nullable
              as bool,
      autoCheckUpdate: null == autoCheckUpdate
          ? _value.autoCheckUpdate
          : autoCheckUpdate // ignore: cast_nullable_to_non_nullable
              as bool,
      showLabel: null == showLabel
          ? _value.showLabel
          : showLabel // ignore: cast_nullable_to_non_nullable
              as bool,
      disclaimerAccepted: null == disclaimerAccepted
          ? _value.disclaimerAccepted
          : disclaimerAccepted // ignore: cast_nullable_to_non_nullable
              as bool,
      minimizeOnExit: null == minimizeOnExit
          ? _value.minimizeOnExit
          : minimizeOnExit // ignore: cast_nullable_to_non_nullable
              as bool,
      hidden: null == hidden
          ? _value.hidden
          : hidden // ignore: cast_nullable_to_non_nullable
              as bool,
      developerMode: null == developerMode
          ? _value.developerMode
          : developerMode // ignore: cast_nullable_to_non_nullable
              as bool,
      recoveryStrategy: null == recoveryStrategy
          ? _value.recoveryStrategy
          : recoveryStrategy // ignore: cast_nullable_to_non_nullable
              as RecoveryStrategy,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AppSettingPropsImpl implements _AppSettingProps {
  const _$AppSettingPropsImpl(
      {this.locale,
      @JsonKey(fromJson: dashboardWidgetsSafeFormJson)
      final List<DashboardWidget> dashboardWidgets = defaultDashboardWidgets,
      this.onlyStatisticsProxy = false,
      this.autoLaunch = false,
      this.silentLaunch = false,
      this.autoRun = false,
      this.openLogs = false,
      this.closeConnections = true,
      this.testUrl = defaultTestUrl,
      this.isAnimateToPage = true,
      this.autoCheckUpdate = true,
      this.showLabel = false,
      this.disclaimerAccepted = false,
      this.minimizeOnExit = true,
      this.hidden = false,
      this.developerMode = false,
      this.recoveryStrategy = RecoveryStrategy.compatible})
      : _dashboardWidgets = dashboardWidgets;

  factory _$AppSettingPropsImpl.fromJson(Map<String, dynamic> json) =>
      _$$AppSettingPropsImplFromJson(json);

  @override
  final String? locale;
  final List<DashboardWidget> _dashboardWidgets;
  @override
  @JsonKey(fromJson: dashboardWidgetsSafeFormJson)
  List<DashboardWidget> get dashboardWidgets {
    if (_dashboardWidgets is EqualUnmodifiableListView)
      return _dashboardWidgets;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_dashboardWidgets);
  }

  @override
  @JsonKey()
  final bool onlyStatisticsProxy;
  @override
  @JsonKey()
  final bool autoLaunch;
  @override
  @JsonKey()
  final bool silentLaunch;
  @override
  @JsonKey()
  final bool autoRun;
  @override
  @JsonKey()
  final bool openLogs;
  @override
  @JsonKey()
  final bool closeConnections;
  @override
  @JsonKey()
  final String testUrl;
  @override
  @JsonKey()
  final bool isAnimateToPage;
  @override
  @JsonKey()
  final bool autoCheckUpdate;
  @override
  @JsonKey()
  final bool showLabel;
  @override
  @JsonKey()
  final bool disclaimerAccepted;
  @override
  @JsonKey()
  final bool minimizeOnExit;
  @override
  @JsonKey()
  final bool hidden;
  @override
  @JsonKey()
  final bool developerMode;
  @override
  @JsonKey()
  final RecoveryStrategy recoveryStrategy;

  @override
  String toString() {
    return 'AppSettingProps(locale: $locale, dashboardWidgets: $dashboardWidgets, onlyStatisticsProxy: $onlyStatisticsProxy, autoLaunch: $autoLaunch, silentLaunch: $silentLaunch, autoRun: $autoRun, openLogs: $openLogs, closeConnections: $closeConnections, testUrl: $testUrl, isAnimateToPage: $isAnimateToPage, autoCheckUpdate: $autoCheckUpdate, showLabel: $showLabel, disclaimerAccepted: $disclaimerAccepted, minimizeOnExit: $minimizeOnExit, hidden: $hidden, developerMode: $developerMode, recoveryStrategy: $recoveryStrategy)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AppSettingPropsImpl &&
            (identical(other.locale, locale) || other.locale == locale) &&
            const DeepCollectionEquality()
                .equals(other._dashboardWidgets, _dashboardWidgets) &&
            (identical(other.onlyStatisticsProxy, onlyStatisticsProxy) ||
                other.onlyStatisticsProxy == onlyStatisticsProxy) &&
            (identical(other.autoLaunch, autoLaunch) ||
                other.autoLaunch == autoLaunch) &&
            (identical(other.silentLaunch, silentLaunch) ||
                other.silentLaunch == silentLaunch) &&
            (identical(other.autoRun, autoRun) || other.autoRun == autoRun) &&
            (identical(other.openLogs, openLogs) ||
                other.openLogs == openLogs) &&
            (identical(other.closeConnections, closeConnections) ||
                other.closeConnections == closeConnections) &&
            (identical(other.testUrl, testUrl) || other.testUrl == testUrl) &&
            (identical(other.isAnimateToPage, isAnimateToPage) ||
                other.isAnimateToPage == isAnimateToPage) &&
            (identical(other.autoCheckUpdate, autoCheckUpdate) ||
                other.autoCheckUpdate == autoCheckUpdate) &&
            (identical(other.showLabel, showLabel) ||
                other.showLabel == showLabel) &&
            (identical(other.disclaimerAccepted, disclaimerAccepted) ||
                other.disclaimerAccepted == disclaimerAccepted) &&
            (identical(other.minimizeOnExit, minimizeOnExit) ||
                other.minimizeOnExit == minimizeOnExit) &&
            (identical(other.hidden, hidden) || other.hidden == hidden) &&
            (identical(other.developerMode, developerMode) ||
                other.developerMode == developerMode) &&
            (identical(other.recoveryStrategy, recoveryStrategy) ||
                other.recoveryStrategy == recoveryStrategy));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      locale,
      const DeepCollectionEquality().hash(_dashboardWidgets),
      onlyStatisticsProxy,
      autoLaunch,
      silentLaunch,
      autoRun,
      openLogs,
      closeConnections,
      testUrl,
      isAnimateToPage,
      autoCheckUpdate,
      showLabel,
      disclaimerAccepted,
      minimizeOnExit,
      hidden,
      developerMode,
      recoveryStrategy);

  /// Create a copy of AppSettingProps
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AppSettingPropsImplCopyWith<_$AppSettingPropsImpl> get copyWith =>
      __$$AppSettingPropsImplCopyWithImpl<_$AppSettingPropsImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AppSettingPropsImplToJson(
      this,
    );
  }
}

abstract class _AppSettingProps implements AppSettingProps {
  const factory _AppSettingProps(
      {final String? locale,
      @JsonKey(fromJson: dashboardWidgetsSafeFormJson)
      final List<DashboardWidget> dashboardWidgets,
      final bool onlyStatisticsProxy,
      final bool autoLaunch,
      final bool silentLaunch,
      final bool autoRun,
      final bool openLogs,
      final bool closeConnections,
      final String testUrl,
      final bool isAnimateToPage,
      final bool autoCheckUpdate,
      final bool showLabel,
      final bool disclaimerAccepted,
      final bool minimizeOnExit,
      final bool hidden,
      final bool developerMode,
      final RecoveryStrategy recoveryStrategy}) = _$AppSettingPropsImpl;

  factory _AppSettingProps.fromJson(Map<String, dynamic> json) =
      _$AppSettingPropsImpl.fromJson;

  @override
  String? get locale;
  @override
  @JsonKey(fromJson: dashboardWidgetsSafeFormJson)
  List<DashboardWidget> get dashboardWidgets;
  @override
  bool get onlyStatisticsProxy;
  @override
  bool get autoLaunch;
  @override
  bool get silentLaunch;
  @override
  bool get autoRun;
  @override
  bool get openLogs;
  @override
  bool get closeConnections;
  @override
  String get testUrl;
  @override
  bool get isAnimateToPage;
  @override
  bool get autoCheckUpdate;
  @override
  bool get showLabel;
  @override
  bool get disclaimerAccepted;
  @override
  bool get minimizeOnExit;
  @override
  bool get hidden;
  @override
  bool get developerMode;
  @override
  RecoveryStrategy get recoveryStrategy;

  /// Create a copy of AppSettingProps
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AppSettingPropsImplCopyWith<_$AppSettingPropsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AccessControl _$AccessControlFromJson(Map<String, dynamic> json) {
  return _AccessControl.fromJson(json);
}

/// @nodoc
mixin _$AccessControl {
  bool get enable => throw _privateConstructorUsedError;
  AccessControlMode get mode => throw _privateConstructorUsedError;
  List<String> get acceptList => throw _privateConstructorUsedError;
  List<String> get rejectList => throw _privateConstructorUsedError;
  AccessSortType get sort => throw _privateConstructorUsedError;
  bool get isFilterSystemApp => throw _privateConstructorUsedError;
  bool get isFilterNonInternetApp => throw _privateConstructorUsedError;

  /// Serializes this AccessControl to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AccessControl
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AccessControlCopyWith<AccessControl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AccessControlCopyWith<$Res> {
  factory $AccessControlCopyWith(
          AccessControl value, $Res Function(AccessControl) then) =
      _$AccessControlCopyWithImpl<$Res, AccessControl>;
  @useResult
  $Res call(
      {bool enable,
      AccessControlMode mode,
      List<String> acceptList,
      List<String> rejectList,
      AccessSortType sort,
      bool isFilterSystemApp,
      bool isFilterNonInternetApp});
}

/// @nodoc
class _$AccessControlCopyWithImpl<$Res, $Val extends AccessControl>
    implements $AccessControlCopyWith<$Res> {
  _$AccessControlCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AccessControl
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? enable = null,
    Object? mode = null,
    Object? acceptList = null,
    Object? rejectList = null,
    Object? sort = null,
    Object? isFilterSystemApp = null,
    Object? isFilterNonInternetApp = null,
  }) {
    return _then(_value.copyWith(
      enable: null == enable
          ? _value.enable
          : enable // ignore: cast_nullable_to_non_nullable
              as bool,
      mode: null == mode
          ? _value.mode
          : mode // ignore: cast_nullable_to_non_nullable
              as AccessControlMode,
      acceptList: null == acceptList
          ? _value.acceptList
          : acceptList // ignore: cast_nullable_to_non_nullable
              as List<String>,
      rejectList: null == rejectList
          ? _value.rejectList
          : rejectList // ignore: cast_nullable_to_non_nullable
              as List<String>,
      sort: null == sort
          ? _value.sort
          : sort // ignore: cast_nullable_to_non_nullable
              as AccessSortType,
      isFilterSystemApp: null == isFilterSystemApp
          ? _value.isFilterSystemApp
          : isFilterSystemApp // ignore: cast_nullable_to_non_nullable
              as bool,
      isFilterNonInternetApp: null == isFilterNonInternetApp
          ? _value.isFilterNonInternetApp
          : isFilterNonInternetApp // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AccessControlImplCopyWith<$Res>
    implements $AccessControlCopyWith<$Res> {
  factory _$$AccessControlImplCopyWith(
          _$AccessControlImpl value, $Res Function(_$AccessControlImpl) then) =
      __$$AccessControlImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool enable,
      AccessControlMode mode,
      List<String> acceptList,
      List<String> rejectList,
      AccessSortType sort,
      bool isFilterSystemApp,
      bool isFilterNonInternetApp});
}

/// @nodoc
class __$$AccessControlImplCopyWithImpl<$Res>
    extends _$AccessControlCopyWithImpl<$Res, _$AccessControlImpl>
    implements _$$AccessControlImplCopyWith<$Res> {
  __$$AccessControlImplCopyWithImpl(
      _$AccessControlImpl _value, $Res Function(_$AccessControlImpl) _then)
      : super(_value, _then);

  /// Create a copy of AccessControl
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? enable = null,
    Object? mode = null,
    Object? acceptList = null,
    Object? rejectList = null,
    Object? sort = null,
    Object? isFilterSystemApp = null,
    Object? isFilterNonInternetApp = null,
  }) {
    return _then(_$AccessControlImpl(
      enable: null == enable
          ? _value.enable
          : enable // ignore: cast_nullable_to_non_nullable
              as bool,
      mode: null == mode
          ? _value.mode
          : mode // ignore: cast_nullable_to_non_nullable
              as AccessControlMode,
      acceptList: null == acceptList
          ? _value._acceptList
          : acceptList // ignore: cast_nullable_to_non_nullable
              as List<String>,
      rejectList: null == rejectList
          ? _value._rejectList
          : rejectList // ignore: cast_nullable_to_non_nullable
              as List<String>,
      sort: null == sort
          ? _value.sort
          : sort // ignore: cast_nullable_to_non_nullable
              as AccessSortType,
      isFilterSystemApp: null == isFilterSystemApp
          ? _value.isFilterSystemApp
          : isFilterSystemApp // ignore: cast_nullable_to_non_nullable
              as bool,
      isFilterNonInternetApp: null == isFilterNonInternetApp
          ? _value.isFilterNonInternetApp
          : isFilterNonInternetApp // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AccessControlImpl implements _AccessControl {
  const _$AccessControlImpl(
      {this.enable = false,
      this.mode = AccessControlMode.rejectSelected,
      final List<String> acceptList = const [],
      final List<String> rejectList = const [],
      this.sort = AccessSortType.none,
      this.isFilterSystemApp = true,
      this.isFilterNonInternetApp = true})
      : _acceptList = acceptList,
        _rejectList = rejectList;

  factory _$AccessControlImpl.fromJson(Map<String, dynamic> json) =>
      _$$AccessControlImplFromJson(json);

  @override
  @JsonKey()
  final bool enable;
  @override
  @JsonKey()
  final AccessControlMode mode;
  final List<String> _acceptList;
  @override
  @JsonKey()
  List<String> get acceptList {
    if (_acceptList is EqualUnmodifiableListView) return _acceptList;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_acceptList);
  }

  final List<String> _rejectList;
  @override
  @JsonKey()
  List<String> get rejectList {
    if (_rejectList is EqualUnmodifiableListView) return _rejectList;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_rejectList);
  }

  @override
  @JsonKey()
  final AccessSortType sort;
  @override
  @JsonKey()
  final bool isFilterSystemApp;
  @override
  @JsonKey()
  final bool isFilterNonInternetApp;

  @override
  String toString() {
    return 'AccessControl(enable: $enable, mode: $mode, acceptList: $acceptList, rejectList: $rejectList, sort: $sort, isFilterSystemApp: $isFilterSystemApp, isFilterNonInternetApp: $isFilterNonInternetApp)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AccessControlImpl &&
            (identical(other.enable, enable) || other.enable == enable) &&
            (identical(other.mode, mode) || other.mode == mode) &&
            const DeepCollectionEquality()
                .equals(other._acceptList, _acceptList) &&
            const DeepCollectionEquality()
                .equals(other._rejectList, _rejectList) &&
            (identical(other.sort, sort) || other.sort == sort) &&
            (identical(other.isFilterSystemApp, isFilterSystemApp) ||
                other.isFilterSystemApp == isFilterSystemApp) &&
            (identical(other.isFilterNonInternetApp, isFilterNonInternetApp) ||
                other.isFilterNonInternetApp == isFilterNonInternetApp));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      enable,
      mode,
      const DeepCollectionEquality().hash(_acceptList),
      const DeepCollectionEquality().hash(_rejectList),
      sort,
      isFilterSystemApp,
      isFilterNonInternetApp);

  /// Create a copy of AccessControl
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AccessControlImplCopyWith<_$AccessControlImpl> get copyWith =>
      __$$AccessControlImplCopyWithImpl<_$AccessControlImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AccessControlImplToJson(
      this,
    );
  }
}

abstract class _AccessControl implements AccessControl {
  const factory _AccessControl(
      {final bool enable,
      final AccessControlMode mode,
      final List<String> acceptList,
      final List<String> rejectList,
      final AccessSortType sort,
      final bool isFilterSystemApp,
      final bool isFilterNonInternetApp}) = _$AccessControlImpl;

  factory _AccessControl.fromJson(Map<String, dynamic> json) =
      _$AccessControlImpl.fromJson;

  @override
  bool get enable;
  @override
  AccessControlMode get mode;
  @override
  List<String> get acceptList;
  @override
  List<String> get rejectList;
  @override
  AccessSortType get sort;
  @override
  bool get isFilterSystemApp;
  @override
  bool get isFilterNonInternetApp;

  /// Create a copy of AccessControl
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AccessControlImplCopyWith<_$AccessControlImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

WindowProps _$WindowPropsFromJson(Map<String, dynamic> json) {
  return _WindowProps.fromJson(json);
}

/// @nodoc
mixin _$WindowProps {
  double get width => throw _privateConstructorUsedError;
  double get height => throw _privateConstructorUsedError;
  double? get top => throw _privateConstructorUsedError;
  double? get left => throw _privateConstructorUsedError;

  /// Serializes this WindowProps to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WindowProps
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WindowPropsCopyWith<WindowProps> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WindowPropsCopyWith<$Res> {
  factory $WindowPropsCopyWith(
          WindowProps value, $Res Function(WindowProps) then) =
      _$WindowPropsCopyWithImpl<$Res, WindowProps>;
  @useResult
  $Res call({double width, double height, double? top, double? left});
}

/// @nodoc
class _$WindowPropsCopyWithImpl<$Res, $Val extends WindowProps>
    implements $WindowPropsCopyWith<$Res> {
  _$WindowPropsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WindowProps
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? width = null,
    Object? height = null,
    Object? top = freezed,
    Object? left = freezed,
  }) {
    return _then(_value.copyWith(
      width: null == width
          ? _value.width
          : width // ignore: cast_nullable_to_non_nullable
              as double,
      height: null == height
          ? _value.height
          : height // ignore: cast_nullable_to_non_nullable
              as double,
      top: freezed == top
          ? _value.top
          : top // ignore: cast_nullable_to_non_nullable
              as double?,
      left: freezed == left
          ? _value.left
          : left // ignore: cast_nullable_to_non_nullable
              as double?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$WindowPropsImplCopyWith<$Res>
    implements $WindowPropsCopyWith<$Res> {
  factory _$$WindowPropsImplCopyWith(
          _$WindowPropsImpl value, $Res Function(_$WindowPropsImpl) then) =
      __$$WindowPropsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({double width, double height, double? top, double? left});
}

/// @nodoc
class __$$WindowPropsImplCopyWithImpl<$Res>
    extends _$WindowPropsCopyWithImpl<$Res, _$WindowPropsImpl>
    implements _$$WindowPropsImplCopyWith<$Res> {
  __$$WindowPropsImplCopyWithImpl(
      _$WindowPropsImpl _value, $Res Function(_$WindowPropsImpl) _then)
      : super(_value, _then);

  /// Create a copy of WindowProps
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? width = null,
    Object? height = null,
    Object? top = freezed,
    Object? left = freezed,
  }) {
    return _then(_$WindowPropsImpl(
      width: null == width
          ? _value.width
          : width // ignore: cast_nullable_to_non_nullable
              as double,
      height: null == height
          ? _value.height
          : height // ignore: cast_nullable_to_non_nullable
              as double,
      top: freezed == top
          ? _value.top
          : top // ignore: cast_nullable_to_non_nullable
              as double?,
      left: freezed == left
          ? _value.left
          : left // ignore: cast_nullable_to_non_nullable
              as double?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$WindowPropsImpl implements _WindowProps {
  const _$WindowPropsImpl(
      {this.width = 750, this.height = 600, this.top, this.left});

  factory _$WindowPropsImpl.fromJson(Map<String, dynamic> json) =>
      _$$WindowPropsImplFromJson(json);

  @override
  @JsonKey()
  final double width;
  @override
  @JsonKey()
  final double height;
  @override
  final double? top;
  @override
  final double? left;

  @override
  String toString() {
    return 'WindowProps(width: $width, height: $height, top: $top, left: $left)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WindowPropsImpl &&
            (identical(other.width, width) || other.width == width) &&
            (identical(other.height, height) || other.height == height) &&
            (identical(other.top, top) || other.top == top) &&
            (identical(other.left, left) || other.left == left));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, width, height, top, left);

  /// Create a copy of WindowProps
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WindowPropsImplCopyWith<_$WindowPropsImpl> get copyWith =>
      __$$WindowPropsImplCopyWithImpl<_$WindowPropsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WindowPropsImplToJson(
      this,
    );
  }
}

abstract class _WindowProps implements WindowProps {
  const factory _WindowProps(
      {final double width,
      final double height,
      final double? top,
      final double? left}) = _$WindowPropsImpl;

  factory _WindowProps.fromJson(Map<String, dynamic> json) =
      _$WindowPropsImpl.fromJson;

  @override
  double get width;
  @override
  double get height;
  @override
  double? get top;
  @override
  double? get left;

  /// Create a copy of WindowProps
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WindowPropsImplCopyWith<_$WindowPropsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

VpnProps _$VpnPropsFromJson(Map<String, dynamic> json) {
  return _VpnProps.fromJson(json);
}

/// @nodoc
mixin _$VpnProps {
  bool get enable => throw _privateConstructorUsedError;
  bool get systemProxy => throw _privateConstructorUsedError;
  bool get ipv6 => throw _privateConstructorUsedError;
  bool get allowBypass => throw _privateConstructorUsedError;
  AccessControl get accessControl => throw _privateConstructorUsedError;

  /// Serializes this VpnProps to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of VpnProps
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VpnPropsCopyWith<VpnProps> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VpnPropsCopyWith<$Res> {
  factory $VpnPropsCopyWith(VpnProps value, $Res Function(VpnProps) then) =
      _$VpnPropsCopyWithImpl<$Res, VpnProps>;
  @useResult
  $Res call(
      {bool enable,
      bool systemProxy,
      bool ipv6,
      bool allowBypass,
      AccessControl accessControl});

  $AccessControlCopyWith<$Res> get accessControl;
}

/// @nodoc
class _$VpnPropsCopyWithImpl<$Res, $Val extends VpnProps>
    implements $VpnPropsCopyWith<$Res> {
  _$VpnPropsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of VpnProps
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? enable = null,
    Object? systemProxy = null,
    Object? ipv6 = null,
    Object? allowBypass = null,
    Object? accessControl = null,
  }) {
    return _then(_value.copyWith(
      enable: null == enable
          ? _value.enable
          : enable // ignore: cast_nullable_to_non_nullable
              as bool,
      systemProxy: null == systemProxy
          ? _value.systemProxy
          : systemProxy // ignore: cast_nullable_to_non_nullable
              as bool,
      ipv6: null == ipv6
          ? _value.ipv6
          : ipv6 // ignore: cast_nullable_to_non_nullable
              as bool,
      allowBypass: null == allowBypass
          ? _value.allowBypass
          : allowBypass // ignore: cast_nullable_to_non_nullable
              as bool,
      accessControl: null == accessControl
          ? _value.accessControl
          : accessControl // ignore: cast_nullable_to_non_nullable
              as AccessControl,
    ) as $Val);
  }

  /// Create a copy of VpnProps
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AccessControlCopyWith<$Res> get accessControl {
    return $AccessControlCopyWith<$Res>(_value.accessControl, (value) {
      return _then(_value.copyWith(accessControl: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$VpnPropsImplCopyWith<$Res>
    implements $VpnPropsCopyWith<$Res> {
  factory _$$VpnPropsImplCopyWith(
          _$VpnPropsImpl value, $Res Function(_$VpnPropsImpl) then) =
      __$$VpnPropsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool enable,
      bool systemProxy,
      bool ipv6,
      bool allowBypass,
      AccessControl accessControl});

  @override
  $AccessControlCopyWith<$Res> get accessControl;
}

/// @nodoc
class __$$VpnPropsImplCopyWithImpl<$Res>
    extends _$VpnPropsCopyWithImpl<$Res, _$VpnPropsImpl>
    implements _$$VpnPropsImplCopyWith<$Res> {
  __$$VpnPropsImplCopyWithImpl(
      _$VpnPropsImpl _value, $Res Function(_$VpnPropsImpl) _then)
      : super(_value, _then);

  /// Create a copy of VpnProps
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? enable = null,
    Object? systemProxy = null,
    Object? ipv6 = null,
    Object? allowBypass = null,
    Object? accessControl = null,
  }) {
    return _then(_$VpnPropsImpl(
      enable: null == enable
          ? _value.enable
          : enable // ignore: cast_nullable_to_non_nullable
              as bool,
      systemProxy: null == systemProxy
          ? _value.systemProxy
          : systemProxy // ignore: cast_nullable_to_non_nullable
              as bool,
      ipv6: null == ipv6
          ? _value.ipv6
          : ipv6 // ignore: cast_nullable_to_non_nullable
              as bool,
      allowBypass: null == allowBypass
          ? _value.allowBypass
          : allowBypass // ignore: cast_nullable_to_non_nullable
              as bool,
      accessControl: null == accessControl
          ? _value.accessControl
          : accessControl // ignore: cast_nullable_to_non_nullable
              as AccessControl,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$VpnPropsImpl implements _VpnProps {
  const _$VpnPropsImpl(
      {this.enable = true,
      this.systemProxy = true,
      this.ipv6 = false,
      this.allowBypass = true,
      this.accessControl = defaultAccessControl});

  factory _$VpnPropsImpl.fromJson(Map<String, dynamic> json) =>
      _$$VpnPropsImplFromJson(json);

  @override
  @JsonKey()
  final bool enable;
  @override
  @JsonKey()
  final bool systemProxy;
  @override
  @JsonKey()
  final bool ipv6;
  @override
  @JsonKey()
  final bool allowBypass;
  @override
  @JsonKey()
  final AccessControl accessControl;

  @override
  String toString() {
    return 'VpnProps(enable: $enable, systemProxy: $systemProxy, ipv6: $ipv6, allowBypass: $allowBypass, accessControl: $accessControl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VpnPropsImpl &&
            (identical(other.enable, enable) || other.enable == enable) &&
            (identical(other.systemProxy, systemProxy) ||
                other.systemProxy == systemProxy) &&
            (identical(other.ipv6, ipv6) || other.ipv6 == ipv6) &&
            (identical(other.allowBypass, allowBypass) ||
                other.allowBypass == allowBypass) &&
            (identical(other.accessControl, accessControl) ||
                other.accessControl == accessControl));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, enable, systemProxy, ipv6, allowBypass, accessControl);

  /// Create a copy of VpnProps
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VpnPropsImplCopyWith<_$VpnPropsImpl> get copyWith =>
      __$$VpnPropsImplCopyWithImpl<_$VpnPropsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$VpnPropsImplToJson(
      this,
    );
  }
}

abstract class _VpnProps implements VpnProps {
  const factory _VpnProps(
      {final bool enable,
      final bool systemProxy,
      final bool ipv6,
      final bool allowBypass,
      final AccessControl accessControl}) = _$VpnPropsImpl;

  factory _VpnProps.fromJson(Map<String, dynamic> json) =
      _$VpnPropsImpl.fromJson;

  @override
  bool get enable;
  @override
  bool get systemProxy;
  @override
  bool get ipv6;
  @override
  bool get allowBypass;
  @override
  AccessControl get accessControl;

  /// Create a copy of VpnProps
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VpnPropsImplCopyWith<_$VpnPropsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

NetworkProps _$NetworkPropsFromJson(Map<String, dynamic> json) {
  return _NetworkProps.fromJson(json);
}

/// @nodoc
mixin _$NetworkProps {
  bool get systemProxy => throw _privateConstructorUsedError;
  List<String> get bypassDomain => throw _privateConstructorUsedError;
  RouteMode get routeMode => throw _privateConstructorUsedError;
  bool get autoSetSystemDns => throw _privateConstructorUsedError;

  /// Serializes this NetworkProps to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of NetworkProps
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $NetworkPropsCopyWith<NetworkProps> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NetworkPropsCopyWith<$Res> {
  factory $NetworkPropsCopyWith(
          NetworkProps value, $Res Function(NetworkProps) then) =
      _$NetworkPropsCopyWithImpl<$Res, NetworkProps>;
  @useResult
  $Res call(
      {bool systemProxy,
      List<String> bypassDomain,
      RouteMode routeMode,
      bool autoSetSystemDns});
}

/// @nodoc
class _$NetworkPropsCopyWithImpl<$Res, $Val extends NetworkProps>
    implements $NetworkPropsCopyWith<$Res> {
  _$NetworkPropsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of NetworkProps
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? systemProxy = null,
    Object? bypassDomain = null,
    Object? routeMode = null,
    Object? autoSetSystemDns = null,
  }) {
    return _then(_value.copyWith(
      systemProxy: null == systemProxy
          ? _value.systemProxy
          : systemProxy // ignore: cast_nullable_to_non_nullable
              as bool,
      bypassDomain: null == bypassDomain
          ? _value.bypassDomain
          : bypassDomain // ignore: cast_nullable_to_non_nullable
              as List<String>,
      routeMode: null == routeMode
          ? _value.routeMode
          : routeMode // ignore: cast_nullable_to_non_nullable
              as RouteMode,
      autoSetSystemDns: null == autoSetSystemDns
          ? _value.autoSetSystemDns
          : autoSetSystemDns // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$NetworkPropsImplCopyWith<$Res>
    implements $NetworkPropsCopyWith<$Res> {
  factory _$$NetworkPropsImplCopyWith(
          _$NetworkPropsImpl value, $Res Function(_$NetworkPropsImpl) then) =
      __$$NetworkPropsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool systemProxy,
      List<String> bypassDomain,
      RouteMode routeMode,
      bool autoSetSystemDns});
}

/// @nodoc
class __$$NetworkPropsImplCopyWithImpl<$Res>
    extends _$NetworkPropsCopyWithImpl<$Res, _$NetworkPropsImpl>
    implements _$$NetworkPropsImplCopyWith<$Res> {
  __$$NetworkPropsImplCopyWithImpl(
      _$NetworkPropsImpl _value, $Res Function(_$NetworkPropsImpl) _then)
      : super(_value, _then);

  /// Create a copy of NetworkProps
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? systemProxy = null,
    Object? bypassDomain = null,
    Object? routeMode = null,
    Object? autoSetSystemDns = null,
  }) {
    return _then(_$NetworkPropsImpl(
      systemProxy: null == systemProxy
          ? _value.systemProxy
          : systemProxy // ignore: cast_nullable_to_non_nullable
              as bool,
      bypassDomain: null == bypassDomain
          ? _value._bypassDomain
          : bypassDomain // ignore: cast_nullable_to_non_nullable
              as List<String>,
      routeMode: null == routeMode
          ? _value.routeMode
          : routeMode // ignore: cast_nullable_to_non_nullable
              as RouteMode,
      autoSetSystemDns: null == autoSetSystemDns
          ? _value.autoSetSystemDns
          : autoSetSystemDns // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$NetworkPropsImpl implements _NetworkProps {
  const _$NetworkPropsImpl(
      {this.systemProxy = true,
      final List<String> bypassDomain = defaultBypassDomain,
      this.routeMode = RouteMode.config,
      this.autoSetSystemDns = true})
      : _bypassDomain = bypassDomain;

  factory _$NetworkPropsImpl.fromJson(Map<String, dynamic> json) =>
      _$$NetworkPropsImplFromJson(json);

  @override
  @JsonKey()
  final bool systemProxy;
  final List<String> _bypassDomain;
  @override
  @JsonKey()
  List<String> get bypassDomain {
    if (_bypassDomain is EqualUnmodifiableListView) return _bypassDomain;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_bypassDomain);
  }

  @override
  @JsonKey()
  final RouteMode routeMode;
  @override
  @JsonKey()
  final bool autoSetSystemDns;

  @override
  String toString() {
    return 'NetworkProps(systemProxy: $systemProxy, bypassDomain: $bypassDomain, routeMode: $routeMode, autoSetSystemDns: $autoSetSystemDns)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NetworkPropsImpl &&
            (identical(other.systemProxy, systemProxy) ||
                other.systemProxy == systemProxy) &&
            const DeepCollectionEquality()
                .equals(other._bypassDomain, _bypassDomain) &&
            (identical(other.routeMode, routeMode) ||
                other.routeMode == routeMode) &&
            (identical(other.autoSetSystemDns, autoSetSystemDns) ||
                other.autoSetSystemDns == autoSetSystemDns));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      systemProxy,
      const DeepCollectionEquality().hash(_bypassDomain),
      routeMode,
      autoSetSystemDns);

  /// Create a copy of NetworkProps
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NetworkPropsImplCopyWith<_$NetworkPropsImpl> get copyWith =>
      __$$NetworkPropsImplCopyWithImpl<_$NetworkPropsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$NetworkPropsImplToJson(
      this,
    );
  }
}

abstract class _NetworkProps implements NetworkProps {
  const factory _NetworkProps(
      {final bool systemProxy,
      final List<String> bypassDomain,
      final RouteMode routeMode,
      final bool autoSetSystemDns}) = _$NetworkPropsImpl;

  factory _NetworkProps.fromJson(Map<String, dynamic> json) =
      _$NetworkPropsImpl.fromJson;

  @override
  bool get systemProxy;
  @override
  List<String> get bypassDomain;
  @override
  RouteMode get routeMode;
  @override
  bool get autoSetSystemDns;

  /// Create a copy of NetworkProps
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NetworkPropsImplCopyWith<_$NetworkPropsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ProxiesStyle _$ProxiesStyleFromJson(Map<String, dynamic> json) {
  return _ProxiesStyle.fromJson(json);
}

/// @nodoc
mixin _$ProxiesStyle {
  ProxiesType get type => throw _privateConstructorUsedError;
  ProxiesSortType get sortType => throw _privateConstructorUsedError;
  ProxiesLayout get layout => throw _privateConstructorUsedError;
  ProxiesIconStyle get iconStyle => throw _privateConstructorUsedError;
  ProxyCardType get cardType => throw _privateConstructorUsedError;
  Map<String, String> get iconMap => throw _privateConstructorUsedError;

  /// Serializes this ProxiesStyle to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ProxiesStyle
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProxiesStyleCopyWith<ProxiesStyle> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProxiesStyleCopyWith<$Res> {
  factory $ProxiesStyleCopyWith(
          ProxiesStyle value, $Res Function(ProxiesStyle) then) =
      _$ProxiesStyleCopyWithImpl<$Res, ProxiesStyle>;
  @useResult
  $Res call(
      {ProxiesType type,
      ProxiesSortType sortType,
      ProxiesLayout layout,
      ProxiesIconStyle iconStyle,
      ProxyCardType cardType,
      Map<String, String> iconMap});
}

/// @nodoc
class _$ProxiesStyleCopyWithImpl<$Res, $Val extends ProxiesStyle>
    implements $ProxiesStyleCopyWith<$Res> {
  _$ProxiesStyleCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProxiesStyle
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? sortType = null,
    Object? layout = null,
    Object? iconStyle = null,
    Object? cardType = null,
    Object? iconMap = null,
  }) {
    return _then(_value.copyWith(
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as ProxiesType,
      sortType: null == sortType
          ? _value.sortType
          : sortType // ignore: cast_nullable_to_non_nullable
              as ProxiesSortType,
      layout: null == layout
          ? _value.layout
          : layout // ignore: cast_nullable_to_non_nullable
              as ProxiesLayout,
      iconStyle: null == iconStyle
          ? _value.iconStyle
          : iconStyle // ignore: cast_nullable_to_non_nullable
              as ProxiesIconStyle,
      cardType: null == cardType
          ? _value.cardType
          : cardType // ignore: cast_nullable_to_non_nullable
              as ProxyCardType,
      iconMap: null == iconMap
          ? _value.iconMap
          : iconMap // ignore: cast_nullable_to_non_nullable
              as Map<String, String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ProxiesStyleImplCopyWith<$Res>
    implements $ProxiesStyleCopyWith<$Res> {
  factory _$$ProxiesStyleImplCopyWith(
          _$ProxiesStyleImpl value, $Res Function(_$ProxiesStyleImpl) then) =
      __$$ProxiesStyleImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {ProxiesType type,
      ProxiesSortType sortType,
      ProxiesLayout layout,
      ProxiesIconStyle iconStyle,
      ProxyCardType cardType,
      Map<String, String> iconMap});
}

/// @nodoc
class __$$ProxiesStyleImplCopyWithImpl<$Res>
    extends _$ProxiesStyleCopyWithImpl<$Res, _$ProxiesStyleImpl>
    implements _$$ProxiesStyleImplCopyWith<$Res> {
  __$$ProxiesStyleImplCopyWithImpl(
      _$ProxiesStyleImpl _value, $Res Function(_$ProxiesStyleImpl) _then)
      : super(_value, _then);

  /// Create a copy of ProxiesStyle
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? sortType = null,
    Object? layout = null,
    Object? iconStyle = null,
    Object? cardType = null,
    Object? iconMap = null,
  }) {
    return _then(_$ProxiesStyleImpl(
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as ProxiesType,
      sortType: null == sortType
          ? _value.sortType
          : sortType // ignore: cast_nullable_to_non_nullable
              as ProxiesSortType,
      layout: null == layout
          ? _value.layout
          : layout // ignore: cast_nullable_to_non_nullable
              as ProxiesLayout,
      iconStyle: null == iconStyle
          ? _value.iconStyle
          : iconStyle // ignore: cast_nullable_to_non_nullable
              as ProxiesIconStyle,
      cardType: null == cardType
          ? _value.cardType
          : cardType // ignore: cast_nullable_to_non_nullable
              as ProxyCardType,
      iconMap: null == iconMap
          ? _value._iconMap
          : iconMap // ignore: cast_nullable_to_non_nullable
              as Map<String, String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ProxiesStyleImpl implements _ProxiesStyle {
  const _$ProxiesStyleImpl(
      {this.type = ProxiesType.tab,
      this.sortType = ProxiesSortType.none,
      this.layout = ProxiesLayout.standard,
      this.iconStyle = ProxiesIconStyle.standard,
      this.cardType = ProxyCardType.expand,
      final Map<String, String> iconMap = const {}})
      : _iconMap = iconMap;

  factory _$ProxiesStyleImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProxiesStyleImplFromJson(json);

  @override
  @JsonKey()
  final ProxiesType type;
  @override
  @JsonKey()
  final ProxiesSortType sortType;
  @override
  @JsonKey()
  final ProxiesLayout layout;
  @override
  @JsonKey()
  final ProxiesIconStyle iconStyle;
  @override
  @JsonKey()
  final ProxyCardType cardType;
  final Map<String, String> _iconMap;
  @override
  @JsonKey()
  Map<String, String> get iconMap {
    if (_iconMap is EqualUnmodifiableMapView) return _iconMap;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_iconMap);
  }

  @override
  String toString() {
    return 'ProxiesStyle(type: $type, sortType: $sortType, layout: $layout, iconStyle: $iconStyle, cardType: $cardType, iconMap: $iconMap)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProxiesStyleImpl &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.sortType, sortType) ||
                other.sortType == sortType) &&
            (identical(other.layout, layout) || other.layout == layout) &&
            (identical(other.iconStyle, iconStyle) ||
                other.iconStyle == iconStyle) &&
            (identical(other.cardType, cardType) ||
                other.cardType == cardType) &&
            const DeepCollectionEquality().equals(other._iconMap, _iconMap));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, type, sortType, layout,
      iconStyle, cardType, const DeepCollectionEquality().hash(_iconMap));

  /// Create a copy of ProxiesStyle
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProxiesStyleImplCopyWith<_$ProxiesStyleImpl> get copyWith =>
      __$$ProxiesStyleImplCopyWithImpl<_$ProxiesStyleImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ProxiesStyleImplToJson(
      this,
    );
  }
}

abstract class _ProxiesStyle implements ProxiesStyle {
  const factory _ProxiesStyle(
      {final ProxiesType type,
      final ProxiesSortType sortType,
      final ProxiesLayout layout,
      final ProxiesIconStyle iconStyle,
      final ProxyCardType cardType,
      final Map<String, String> iconMap}) = _$ProxiesStyleImpl;

  factory _ProxiesStyle.fromJson(Map<String, dynamic> json) =
      _$ProxiesStyleImpl.fromJson;

  @override
  ProxiesType get type;
  @override
  ProxiesSortType get sortType;
  @override
  ProxiesLayout get layout;
  @override
  ProxiesIconStyle get iconStyle;
  @override
  ProxyCardType get cardType;
  @override
  Map<String, String> get iconMap;

  /// Create a copy of ProxiesStyle
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProxiesStyleImplCopyWith<_$ProxiesStyleImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TextScale _$TextScaleFromJson(Map<String, dynamic> json) {
  return _TextScale.fromJson(json);
}

/// @nodoc
mixin _$TextScale {
  bool get enable => throw _privateConstructorUsedError;
  double get scale => throw _privateConstructorUsedError;

  /// Serializes this TextScale to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TextScale
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TextScaleCopyWith<TextScale> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TextScaleCopyWith<$Res> {
  factory $TextScaleCopyWith(TextScale value, $Res Function(TextScale) then) =
      _$TextScaleCopyWithImpl<$Res, TextScale>;
  @useResult
  $Res call({bool enable, double scale});
}

/// @nodoc
class _$TextScaleCopyWithImpl<$Res, $Val extends TextScale>
    implements $TextScaleCopyWith<$Res> {
  _$TextScaleCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TextScale
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? enable = null,
    Object? scale = null,
  }) {
    return _then(_value.copyWith(
      enable: null == enable
          ? _value.enable
          : enable // ignore: cast_nullable_to_non_nullable
              as bool,
      scale: null == scale
          ? _value.scale
          : scale // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TextScaleImplCopyWith<$Res>
    implements $TextScaleCopyWith<$Res> {
  factory _$$TextScaleImplCopyWith(
          _$TextScaleImpl value, $Res Function(_$TextScaleImpl) then) =
      __$$TextScaleImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool enable, double scale});
}

/// @nodoc
class __$$TextScaleImplCopyWithImpl<$Res>
    extends _$TextScaleCopyWithImpl<$Res, _$TextScaleImpl>
    implements _$$TextScaleImplCopyWith<$Res> {
  __$$TextScaleImplCopyWithImpl(
      _$TextScaleImpl _value, $Res Function(_$TextScaleImpl) _then)
      : super(_value, _then);

  /// Create a copy of TextScale
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? enable = null,
    Object? scale = null,
  }) {
    return _then(_$TextScaleImpl(
      enable: null == enable
          ? _value.enable
          : enable // ignore: cast_nullable_to_non_nullable
              as bool,
      scale: null == scale
          ? _value.scale
          : scale // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TextScaleImpl implements _TextScale {
  const _$TextScaleImpl({this.enable = false, this.scale = 1.0});

  factory _$TextScaleImpl.fromJson(Map<String, dynamic> json) =>
      _$$TextScaleImplFromJson(json);

  @override
  @JsonKey()
  final bool enable;
  @override
  @JsonKey()
  final double scale;

  @override
  String toString() {
    return 'TextScale(enable: $enable, scale: $scale)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TextScaleImpl &&
            (identical(other.enable, enable) || other.enable == enable) &&
            (identical(other.scale, scale) || other.scale == scale));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, enable, scale);

  /// Create a copy of TextScale
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TextScaleImplCopyWith<_$TextScaleImpl> get copyWith =>
      __$$TextScaleImplCopyWithImpl<_$TextScaleImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TextScaleImplToJson(
      this,
    );
  }
}

abstract class _TextScale implements TextScale {
  const factory _TextScale({final bool enable, final double scale}) =
      _$TextScaleImpl;

  factory _TextScale.fromJson(Map<String, dynamic> json) =
      _$TextScaleImpl.fromJson;

  @override
  bool get enable;
  @override
  double get scale;

  /// Create a copy of TextScale
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TextScaleImplCopyWith<_$TextScaleImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ThemeProps _$ThemePropsFromJson(Map<String, dynamic> json) {
  return _ThemeProps.fromJson(json);
}

/// @nodoc
mixin _$ThemeProps {
  int? get primaryColor => throw _privateConstructorUsedError;
  List<int> get primaryColors => throw _privateConstructorUsedError;
  ThemeMode get themeMode => throw _privateConstructorUsedError;
  DynamicSchemeVariant get schemeVariant => throw _privateConstructorUsedError;
  bool get pureBlack => throw _privateConstructorUsedError;
  TextScale get textScale => throw _privateConstructorUsedError;

  /// Serializes this ThemeProps to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ThemeProps
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ThemePropsCopyWith<ThemeProps> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ThemePropsCopyWith<$Res> {
  factory $ThemePropsCopyWith(
          ThemeProps value, $Res Function(ThemeProps) then) =
      _$ThemePropsCopyWithImpl<$Res, ThemeProps>;
  @useResult
  $Res call(
      {int? primaryColor,
      List<int> primaryColors,
      ThemeMode themeMode,
      DynamicSchemeVariant schemeVariant,
      bool pureBlack,
      TextScale textScale});

  $TextScaleCopyWith<$Res> get textScale;
}

/// @nodoc
class _$ThemePropsCopyWithImpl<$Res, $Val extends ThemeProps>
    implements $ThemePropsCopyWith<$Res> {
  _$ThemePropsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ThemeProps
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? primaryColor = freezed,
    Object? primaryColors = null,
    Object? themeMode = null,
    Object? schemeVariant = null,
    Object? pureBlack = null,
    Object? textScale = null,
  }) {
    return _then(_value.copyWith(
      primaryColor: freezed == primaryColor
          ? _value.primaryColor
          : primaryColor // ignore: cast_nullable_to_non_nullable
              as int?,
      primaryColors: null == primaryColors
          ? _value.primaryColors
          : primaryColors // ignore: cast_nullable_to_non_nullable
              as List<int>,
      themeMode: null == themeMode
          ? _value.themeMode
          : themeMode // ignore: cast_nullable_to_non_nullable
              as ThemeMode,
      schemeVariant: null == schemeVariant
          ? _value.schemeVariant
          : schemeVariant // ignore: cast_nullable_to_non_nullable
              as DynamicSchemeVariant,
      pureBlack: null == pureBlack
          ? _value.pureBlack
          : pureBlack // ignore: cast_nullable_to_non_nullable
              as bool,
      textScale: null == textScale
          ? _value.textScale
          : textScale // ignore: cast_nullable_to_non_nullable
              as TextScale,
    ) as $Val);
  }

  /// Create a copy of ThemeProps
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TextScaleCopyWith<$Res> get textScale {
    return $TextScaleCopyWith<$Res>(_value.textScale, (value) {
      return _then(_value.copyWith(textScale: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ThemePropsImplCopyWith<$Res>
    implements $ThemePropsCopyWith<$Res> {
  factory _$$ThemePropsImplCopyWith(
          _$ThemePropsImpl value, $Res Function(_$ThemePropsImpl) then) =
      __$$ThemePropsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int? primaryColor,
      List<int> primaryColors,
      ThemeMode themeMode,
      DynamicSchemeVariant schemeVariant,
      bool pureBlack,
      TextScale textScale});

  @override
  $TextScaleCopyWith<$Res> get textScale;
}

/// @nodoc
class __$$ThemePropsImplCopyWithImpl<$Res>
    extends _$ThemePropsCopyWithImpl<$Res, _$ThemePropsImpl>
    implements _$$ThemePropsImplCopyWith<$Res> {
  __$$ThemePropsImplCopyWithImpl(
      _$ThemePropsImpl _value, $Res Function(_$ThemePropsImpl) _then)
      : super(_value, _then);

  /// Create a copy of ThemeProps
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? primaryColor = freezed,
    Object? primaryColors = null,
    Object? themeMode = null,
    Object? schemeVariant = null,
    Object? pureBlack = null,
    Object? textScale = null,
  }) {
    return _then(_$ThemePropsImpl(
      primaryColor: freezed == primaryColor
          ? _value.primaryColor
          : primaryColor // ignore: cast_nullable_to_non_nullable
              as int?,
      primaryColors: null == primaryColors
          ? _value._primaryColors
          : primaryColors // ignore: cast_nullable_to_non_nullable
              as List<int>,
      themeMode: null == themeMode
          ? _value.themeMode
          : themeMode // ignore: cast_nullable_to_non_nullable
              as ThemeMode,
      schemeVariant: null == schemeVariant
          ? _value.schemeVariant
          : schemeVariant // ignore: cast_nullable_to_non_nullable
              as DynamicSchemeVariant,
      pureBlack: null == pureBlack
          ? _value.pureBlack
          : pureBlack // ignore: cast_nullable_to_non_nullable
              as bool,
      textScale: null == textScale
          ? _value.textScale
          : textScale // ignore: cast_nullable_to_non_nullable
              as TextScale,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ThemePropsImpl implements _ThemeProps {
  const _$ThemePropsImpl(
      {this.primaryColor,
      final List<int> primaryColors = defaultPrimaryColors,
      this.themeMode = ThemeMode.dark,
      this.schemeVariant = DynamicSchemeVariant.content,
      this.pureBlack = false,
      this.textScale = const TextScale()})
      : _primaryColors = primaryColors;

  factory _$ThemePropsImpl.fromJson(Map<String, dynamic> json) =>
      _$$ThemePropsImplFromJson(json);

  @override
  final int? primaryColor;
  final List<int> _primaryColors;
  @override
  @JsonKey()
  List<int> get primaryColors {
    if (_primaryColors is EqualUnmodifiableListView) return _primaryColors;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_primaryColors);
  }

  @override
  @JsonKey()
  final ThemeMode themeMode;
  @override
  @JsonKey()
  final DynamicSchemeVariant schemeVariant;
  @override
  @JsonKey()
  final bool pureBlack;
  @override
  @JsonKey()
  final TextScale textScale;

  @override
  String toString() {
    return 'ThemeProps(primaryColor: $primaryColor, primaryColors: $primaryColors, themeMode: $themeMode, schemeVariant: $schemeVariant, pureBlack: $pureBlack, textScale: $textScale)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ThemePropsImpl &&
            (identical(other.primaryColor, primaryColor) ||
                other.primaryColor == primaryColor) &&
            const DeepCollectionEquality()
                .equals(other._primaryColors, _primaryColors) &&
            (identical(other.themeMode, themeMode) ||
                other.themeMode == themeMode) &&
            (identical(other.schemeVariant, schemeVariant) ||
                other.schemeVariant == schemeVariant) &&
            (identical(other.pureBlack, pureBlack) ||
                other.pureBlack == pureBlack) &&
            (identical(other.textScale, textScale) ||
                other.textScale == textScale));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      primaryColor,
      const DeepCollectionEquality().hash(_primaryColors),
      themeMode,
      schemeVariant,
      pureBlack,
      textScale);

  /// Create a copy of ThemeProps
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ThemePropsImplCopyWith<_$ThemePropsImpl> get copyWith =>
      __$$ThemePropsImplCopyWithImpl<_$ThemePropsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ThemePropsImplToJson(
      this,
    );
  }
}

abstract class _ThemeProps implements ThemeProps {
  const factory _ThemeProps(
      {final int? primaryColor,
      final List<int> primaryColors,
      final ThemeMode themeMode,
      final DynamicSchemeVariant schemeVariant,
      final bool pureBlack,
      final TextScale textScale}) = _$ThemePropsImpl;

  factory _ThemeProps.fromJson(Map<String, dynamic> json) =
      _$ThemePropsImpl.fromJson;

  @override
  int? get primaryColor;
  @override
  List<int> get primaryColors;
  @override
  ThemeMode get themeMode;
  @override
  DynamicSchemeVariant get schemeVariant;
  @override
  bool get pureBlack;
  @override
  TextScale get textScale;

  /// Create a copy of ThemeProps
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ThemePropsImplCopyWith<_$ThemePropsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ScriptProps _$ScriptPropsFromJson(Map<String, dynamic> json) {
  return _ScriptProps.fromJson(json);
}

/// @nodoc
mixin _$ScriptProps {
  String? get currentId => throw _privateConstructorUsedError;
  List<Script> get scripts => throw _privateConstructorUsedError;

  /// Serializes this ScriptProps to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ScriptProps
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ScriptPropsCopyWith<ScriptProps> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ScriptPropsCopyWith<$Res> {
  factory $ScriptPropsCopyWith(
          ScriptProps value, $Res Function(ScriptProps) then) =
      _$ScriptPropsCopyWithImpl<$Res, ScriptProps>;
  @useResult
  $Res call({String? currentId, List<Script> scripts});
}

/// @nodoc
class _$ScriptPropsCopyWithImpl<$Res, $Val extends ScriptProps>
    implements $ScriptPropsCopyWith<$Res> {
  _$ScriptPropsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ScriptProps
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentId = freezed,
    Object? scripts = null,
  }) {
    return _then(_value.copyWith(
      currentId: freezed == currentId
          ? _value.currentId
          : currentId // ignore: cast_nullable_to_non_nullable
              as String?,
      scripts: null == scripts
          ? _value.scripts
          : scripts // ignore: cast_nullable_to_non_nullable
              as List<Script>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ScriptPropsImplCopyWith<$Res>
    implements $ScriptPropsCopyWith<$Res> {
  factory _$$ScriptPropsImplCopyWith(
          _$ScriptPropsImpl value, $Res Function(_$ScriptPropsImpl) then) =
      __$$ScriptPropsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String? currentId, List<Script> scripts});
}

/// @nodoc
class __$$ScriptPropsImplCopyWithImpl<$Res>
    extends _$ScriptPropsCopyWithImpl<$Res, _$ScriptPropsImpl>
    implements _$$ScriptPropsImplCopyWith<$Res> {
  __$$ScriptPropsImplCopyWithImpl(
      _$ScriptPropsImpl _value, $Res Function(_$ScriptPropsImpl) _then)
      : super(_value, _then);

  /// Create a copy of ScriptProps
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentId = freezed,
    Object? scripts = null,
  }) {
    return _then(_$ScriptPropsImpl(
      currentId: freezed == currentId
          ? _value.currentId
          : currentId // ignore: cast_nullable_to_non_nullable
              as String?,
      scripts: null == scripts
          ? _value._scripts
          : scripts // ignore: cast_nullable_to_non_nullable
              as List<Script>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ScriptPropsImpl implements _ScriptProps {
  const _$ScriptPropsImpl(
      {this.currentId, final List<Script> scripts = const []})
      : _scripts = scripts;

  factory _$ScriptPropsImpl.fromJson(Map<String, dynamic> json) =>
      _$$ScriptPropsImplFromJson(json);

  @override
  final String? currentId;
  final List<Script> _scripts;
  @override
  @JsonKey()
  List<Script> get scripts {
    if (_scripts is EqualUnmodifiableListView) return _scripts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_scripts);
  }

  @override
  String toString() {
    return 'ScriptProps(currentId: $currentId, scripts: $scripts)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ScriptPropsImpl &&
            (identical(other.currentId, currentId) ||
                other.currentId == currentId) &&
            const DeepCollectionEquality().equals(other._scripts, _scripts));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, currentId, const DeepCollectionEquality().hash(_scripts));

  /// Create a copy of ScriptProps
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ScriptPropsImplCopyWith<_$ScriptPropsImpl> get copyWith =>
      __$$ScriptPropsImplCopyWithImpl<_$ScriptPropsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ScriptPropsImplToJson(
      this,
    );
  }
}

abstract class _ScriptProps implements ScriptProps {
  const factory _ScriptProps(
      {final String? currentId,
      final List<Script> scripts}) = _$ScriptPropsImpl;

  factory _ScriptProps.fromJson(Map<String, dynamic> json) =
      _$ScriptPropsImpl.fromJson;

  @override
  String? get currentId;
  @override
  List<Script> get scripts;

  /// Create a copy of ScriptProps
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ScriptPropsImplCopyWith<_$ScriptPropsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Config _$ConfigFromJson(Map<String, dynamic> json) {
  return _Config.fromJson(json);
}

/// @nodoc
mixin _$Config {
  @JsonKey(fromJson: AppSettingProps.safeFromJson)
  AppSettingProps get appSetting => throw _privateConstructorUsedError;
  List<Profile> get profiles => throw _privateConstructorUsedError;
  List<HotKeyAction> get hotKeyActions => throw _privateConstructorUsedError;
  String? get currentProfileId => throw _privateConstructorUsedError;
  bool get overrideDns => throw _privateConstructorUsedError;
  DAV? get dav => throw _privateConstructorUsedError;
  NetworkProps get networkProps => throw _privateConstructorUsedError;
  VpnProps get vpnProps => throw _privateConstructorUsedError;
  @JsonKey(fromJson: ThemeProps.safeFromJson)
  ThemeProps get themeProps => throw _privateConstructorUsedError;
  ProxiesStyle get proxiesStyle => throw _privateConstructorUsedError;
  WindowProps get windowProps => throw _privateConstructorUsedError;
  ClashConfig get patchClashConfig => throw _privateConstructorUsedError;
  ScriptProps get scriptProps => throw _privateConstructorUsedError;

  /// Serializes this Config to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Config
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ConfigCopyWith<Config> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ConfigCopyWith<$Res> {
  factory $ConfigCopyWith(Config value, $Res Function(Config) then) =
      _$ConfigCopyWithImpl<$Res, Config>;
  @useResult
  $Res call(
      {@JsonKey(fromJson: AppSettingProps.safeFromJson)
      AppSettingProps appSetting,
      List<Profile> profiles,
      List<HotKeyAction> hotKeyActions,
      String? currentProfileId,
      bool overrideDns,
      DAV? dav,
      NetworkProps networkProps,
      VpnProps vpnProps,
      @JsonKey(fromJson: ThemeProps.safeFromJson) ThemeProps themeProps,
      ProxiesStyle proxiesStyle,
      WindowProps windowProps,
      ClashConfig patchClashConfig,
      ScriptProps scriptProps});

  $AppSettingPropsCopyWith<$Res> get appSetting;
  $DAVCopyWith<$Res>? get dav;
  $NetworkPropsCopyWith<$Res> get networkProps;
  $VpnPropsCopyWith<$Res> get vpnProps;
  $ThemePropsCopyWith<$Res> get themeProps;
  $ProxiesStyleCopyWith<$Res> get proxiesStyle;
  $WindowPropsCopyWith<$Res> get windowProps;
  $ClashConfigCopyWith<$Res> get patchClashConfig;
  $ScriptPropsCopyWith<$Res> get scriptProps;
}

/// @nodoc
class _$ConfigCopyWithImpl<$Res, $Val extends Config>
    implements $ConfigCopyWith<$Res> {
  _$ConfigCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Config
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? appSetting = null,
    Object? profiles = null,
    Object? hotKeyActions = null,
    Object? currentProfileId = freezed,
    Object? overrideDns = null,
    Object? dav = freezed,
    Object? networkProps = null,
    Object? vpnProps = null,
    Object? themeProps = null,
    Object? proxiesStyle = null,
    Object? windowProps = null,
    Object? patchClashConfig = null,
    Object? scriptProps = null,
  }) {
    return _then(_value.copyWith(
      appSetting: null == appSetting
          ? _value.appSetting
          : appSetting // ignore: cast_nullable_to_non_nullable
              as AppSettingProps,
      profiles: null == profiles
          ? _value.profiles
          : profiles // ignore: cast_nullable_to_non_nullable
              as List<Profile>,
      hotKeyActions: null == hotKeyActions
          ? _value.hotKeyActions
          : hotKeyActions // ignore: cast_nullable_to_non_nullable
              as List<HotKeyAction>,
      currentProfileId: freezed == currentProfileId
          ? _value.currentProfileId
          : currentProfileId // ignore: cast_nullable_to_non_nullable
              as String?,
      overrideDns: null == overrideDns
          ? _value.overrideDns
          : overrideDns // ignore: cast_nullable_to_non_nullable
              as bool,
      dav: freezed == dav
          ? _value.dav
          : dav // ignore: cast_nullable_to_non_nullable
              as DAV?,
      networkProps: null == networkProps
          ? _value.networkProps
          : networkProps // ignore: cast_nullable_to_non_nullable
              as NetworkProps,
      vpnProps: null == vpnProps
          ? _value.vpnProps
          : vpnProps // ignore: cast_nullable_to_non_nullable
              as VpnProps,
      themeProps: null == themeProps
          ? _value.themeProps
          : themeProps // ignore: cast_nullable_to_non_nullable
              as ThemeProps,
      proxiesStyle: null == proxiesStyle
          ? _value.proxiesStyle
          : proxiesStyle // ignore: cast_nullable_to_non_nullable
              as ProxiesStyle,
      windowProps: null == windowProps
          ? _value.windowProps
          : windowProps // ignore: cast_nullable_to_non_nullable
              as WindowProps,
      patchClashConfig: null == patchClashConfig
          ? _value.patchClashConfig
          : patchClashConfig // ignore: cast_nullable_to_non_nullable
              as ClashConfig,
      scriptProps: null == scriptProps
          ? _value.scriptProps
          : scriptProps // ignore: cast_nullable_to_non_nullable
              as ScriptProps,
    ) as $Val);
  }

  /// Create a copy of Config
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AppSettingPropsCopyWith<$Res> get appSetting {
    return $AppSettingPropsCopyWith<$Res>(_value.appSetting, (value) {
      return _then(_value.copyWith(appSetting: value) as $Val);
    });
  }

  /// Create a copy of Config
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DAVCopyWith<$Res>? get dav {
    if (_value.dav == null) {
      return null;
    }

    return $DAVCopyWith<$Res>(_value.dav!, (value) {
      return _then(_value.copyWith(dav: value) as $Val);
    });
  }

  /// Create a copy of Config
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $NetworkPropsCopyWith<$Res> get networkProps {
    return $NetworkPropsCopyWith<$Res>(_value.networkProps, (value) {
      return _then(_value.copyWith(networkProps: value) as $Val);
    });
  }

  /// Create a copy of Config
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $VpnPropsCopyWith<$Res> get vpnProps {
    return $VpnPropsCopyWith<$Res>(_value.vpnProps, (value) {
      return _then(_value.copyWith(vpnProps: value) as $Val);
    });
  }

  /// Create a copy of Config
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ThemePropsCopyWith<$Res> get themeProps {
    return $ThemePropsCopyWith<$Res>(_value.themeProps, (value) {
      return _then(_value.copyWith(themeProps: value) as $Val);
    });
  }

  /// Create a copy of Config
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ProxiesStyleCopyWith<$Res> get proxiesStyle {
    return $ProxiesStyleCopyWith<$Res>(_value.proxiesStyle, (value) {
      return _then(_value.copyWith(proxiesStyle: value) as $Val);
    });
  }

  /// Create a copy of Config
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $WindowPropsCopyWith<$Res> get windowProps {
    return $WindowPropsCopyWith<$Res>(_value.windowProps, (value) {
      return _then(_value.copyWith(windowProps: value) as $Val);
    });
  }

  /// Create a copy of Config
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ClashConfigCopyWith<$Res> get patchClashConfig {
    return $ClashConfigCopyWith<$Res>(_value.patchClashConfig, (value) {
      return _then(_value.copyWith(patchClashConfig: value) as $Val);
    });
  }

  /// Create a copy of Config
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ScriptPropsCopyWith<$Res> get scriptProps {
    return $ScriptPropsCopyWith<$Res>(_value.scriptProps, (value) {
      return _then(_value.copyWith(scriptProps: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ConfigImplCopyWith<$Res> implements $ConfigCopyWith<$Res> {
  factory _$$ConfigImplCopyWith(
          _$ConfigImpl value, $Res Function(_$ConfigImpl) then) =
      __$$ConfigImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(fromJson: AppSettingProps.safeFromJson)
      AppSettingProps appSetting,
      List<Profile> profiles,
      List<HotKeyAction> hotKeyActions,
      String? currentProfileId,
      bool overrideDns,
      DAV? dav,
      NetworkProps networkProps,
      VpnProps vpnProps,
      @JsonKey(fromJson: ThemeProps.safeFromJson) ThemeProps themeProps,
      ProxiesStyle proxiesStyle,
      WindowProps windowProps,
      ClashConfig patchClashConfig,
      ScriptProps scriptProps});

  @override
  $AppSettingPropsCopyWith<$Res> get appSetting;
  @override
  $DAVCopyWith<$Res>? get dav;
  @override
  $NetworkPropsCopyWith<$Res> get networkProps;
  @override
  $VpnPropsCopyWith<$Res> get vpnProps;
  @override
  $ThemePropsCopyWith<$Res> get themeProps;
  @override
  $ProxiesStyleCopyWith<$Res> get proxiesStyle;
  @override
  $WindowPropsCopyWith<$Res> get windowProps;
  @override
  $ClashConfigCopyWith<$Res> get patchClashConfig;
  @override
  $ScriptPropsCopyWith<$Res> get scriptProps;
}

/// @nodoc
class __$$ConfigImplCopyWithImpl<$Res>
    extends _$ConfigCopyWithImpl<$Res, _$ConfigImpl>
    implements _$$ConfigImplCopyWith<$Res> {
  __$$ConfigImplCopyWithImpl(
      _$ConfigImpl _value, $Res Function(_$ConfigImpl) _then)
      : super(_value, _then);

  /// Create a copy of Config
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? appSetting = null,
    Object? profiles = null,
    Object? hotKeyActions = null,
    Object? currentProfileId = freezed,
    Object? overrideDns = null,
    Object? dav = freezed,
    Object? networkProps = null,
    Object? vpnProps = null,
    Object? themeProps = null,
    Object? proxiesStyle = null,
    Object? windowProps = null,
    Object? patchClashConfig = null,
    Object? scriptProps = null,
  }) {
    return _then(_$ConfigImpl(
      appSetting: null == appSetting
          ? _value.appSetting
          : appSetting // ignore: cast_nullable_to_non_nullable
              as AppSettingProps,
      profiles: null == profiles
          ? _value._profiles
          : profiles // ignore: cast_nullable_to_non_nullable
              as List<Profile>,
      hotKeyActions: null == hotKeyActions
          ? _value._hotKeyActions
          : hotKeyActions // ignore: cast_nullable_to_non_nullable
              as List<HotKeyAction>,
      currentProfileId: freezed == currentProfileId
          ? _value.currentProfileId
          : currentProfileId // ignore: cast_nullable_to_non_nullable
              as String?,
      overrideDns: null == overrideDns
          ? _value.overrideDns
          : overrideDns // ignore: cast_nullable_to_non_nullable
              as bool,
      dav: freezed == dav
          ? _value.dav
          : dav // ignore: cast_nullable_to_non_nullable
              as DAV?,
      networkProps: null == networkProps
          ? _value.networkProps
          : networkProps // ignore: cast_nullable_to_non_nullable
              as NetworkProps,
      vpnProps: null == vpnProps
          ? _value.vpnProps
          : vpnProps // ignore: cast_nullable_to_non_nullable
              as VpnProps,
      themeProps: null == themeProps
          ? _value.themeProps
          : themeProps // ignore: cast_nullable_to_non_nullable
              as ThemeProps,
      proxiesStyle: null == proxiesStyle
          ? _value.proxiesStyle
          : proxiesStyle // ignore: cast_nullable_to_non_nullable
              as ProxiesStyle,
      windowProps: null == windowProps
          ? _value.windowProps
          : windowProps // ignore: cast_nullable_to_non_nullable
              as WindowProps,
      patchClashConfig: null == patchClashConfig
          ? _value.patchClashConfig
          : patchClashConfig // ignore: cast_nullable_to_non_nullable
              as ClashConfig,
      scriptProps: null == scriptProps
          ? _value.scriptProps
          : scriptProps // ignore: cast_nullable_to_non_nullable
              as ScriptProps,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ConfigImpl implements _Config {
  const _$ConfigImpl(
      {@JsonKey(fromJson: AppSettingProps.safeFromJson)
      this.appSetting = defaultAppSettingProps,
      final List<Profile> profiles = const [],
      final List<HotKeyAction> hotKeyActions = const [],
      this.currentProfileId,
      this.overrideDns = false,
      this.dav,
      this.networkProps = defaultNetworkProps,
      this.vpnProps = defaultVpnProps,
      @JsonKey(fromJson: ThemeProps.safeFromJson) required this.themeProps,
      this.proxiesStyle = defaultProxiesStyle,
      this.windowProps = defaultWindowProps,
      this.patchClashConfig = defaultClashConfig,
      this.scriptProps = const ScriptProps()})
      : _profiles = profiles,
        _hotKeyActions = hotKeyActions;

  factory _$ConfigImpl.fromJson(Map<String, dynamic> json) =>
      _$$ConfigImplFromJson(json);

  @override
  @JsonKey(fromJson: AppSettingProps.safeFromJson)
  final AppSettingProps appSetting;
  final List<Profile> _profiles;
  @override
  @JsonKey()
  List<Profile> get profiles {
    if (_profiles is EqualUnmodifiableListView) return _profiles;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_profiles);
  }

  final List<HotKeyAction> _hotKeyActions;
  @override
  @JsonKey()
  List<HotKeyAction> get hotKeyActions {
    if (_hotKeyActions is EqualUnmodifiableListView) return _hotKeyActions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_hotKeyActions);
  }

  @override
  final String? currentProfileId;
  @override
  @JsonKey()
  final bool overrideDns;
  @override
  final DAV? dav;
  @override
  @JsonKey()
  final NetworkProps networkProps;
  @override
  @JsonKey()
  final VpnProps vpnProps;
  @override
  @JsonKey(fromJson: ThemeProps.safeFromJson)
  final ThemeProps themeProps;
  @override
  @JsonKey()
  final ProxiesStyle proxiesStyle;
  @override
  @JsonKey()
  final WindowProps windowProps;
  @override
  @JsonKey()
  final ClashConfig patchClashConfig;
  @override
  @JsonKey()
  final ScriptProps scriptProps;

  @override
  String toString() {
    return 'Config(appSetting: $appSetting, profiles: $profiles, hotKeyActions: $hotKeyActions, currentProfileId: $currentProfileId, overrideDns: $overrideDns, dav: $dav, networkProps: $networkProps, vpnProps: $vpnProps, themeProps: $themeProps, proxiesStyle: $proxiesStyle, windowProps: $windowProps, patchClashConfig: $patchClashConfig, scriptProps: $scriptProps)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ConfigImpl &&
            (identical(other.appSetting, appSetting) ||
                other.appSetting == appSetting) &&
            const DeepCollectionEquality().equals(other._profiles, _profiles) &&
            const DeepCollectionEquality()
                .equals(other._hotKeyActions, _hotKeyActions) &&
            (identical(other.currentProfileId, currentProfileId) ||
                other.currentProfileId == currentProfileId) &&
            (identical(other.overrideDns, overrideDns) ||
                other.overrideDns == overrideDns) &&
            (identical(other.dav, dav) || other.dav == dav) &&
            (identical(other.networkProps, networkProps) ||
                other.networkProps == networkProps) &&
            (identical(other.vpnProps, vpnProps) ||
                other.vpnProps == vpnProps) &&
            (identical(other.themeProps, themeProps) ||
                other.themeProps == themeProps) &&
            (identical(other.proxiesStyle, proxiesStyle) ||
                other.proxiesStyle == proxiesStyle) &&
            (identical(other.windowProps, windowProps) ||
                other.windowProps == windowProps) &&
            (identical(other.patchClashConfig, patchClashConfig) ||
                other.patchClashConfig == patchClashConfig) &&
            (identical(other.scriptProps, scriptProps) ||
                other.scriptProps == scriptProps));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      appSetting,
      const DeepCollectionEquality().hash(_profiles),
      const DeepCollectionEquality().hash(_hotKeyActions),
      currentProfileId,
      overrideDns,
      dav,
      networkProps,
      vpnProps,
      themeProps,
      proxiesStyle,
      windowProps,
      patchClashConfig,
      scriptProps);

  /// Create a copy of Config
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ConfigImplCopyWith<_$ConfigImpl> get copyWith =>
      __$$ConfigImplCopyWithImpl<_$ConfigImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ConfigImplToJson(
      this,
    );
  }
}

abstract class _Config implements Config {
  const factory _Config(
      {@JsonKey(fromJson: AppSettingProps.safeFromJson)
      final AppSettingProps appSetting,
      final List<Profile> profiles,
      final List<HotKeyAction> hotKeyActions,
      final String? currentProfileId,
      final bool overrideDns,
      final DAV? dav,
      final NetworkProps networkProps,
      final VpnProps vpnProps,
      @JsonKey(fromJson: ThemeProps.safeFromJson)
      required final ThemeProps themeProps,
      final ProxiesStyle proxiesStyle,
      final WindowProps windowProps,
      final ClashConfig patchClashConfig,
      final ScriptProps scriptProps}) = _$ConfigImpl;

  factory _Config.fromJson(Map<String, dynamic> json) = _$ConfigImpl.fromJson;

  @override
  @JsonKey(fromJson: AppSettingProps.safeFromJson)
  AppSettingProps get appSetting;
  @override
  List<Profile> get profiles;
  @override
  List<HotKeyAction> get hotKeyActions;
  @override
  String? get currentProfileId;
  @override
  bool get overrideDns;
  @override
  DAV? get dav;
  @override
  NetworkProps get networkProps;
  @override
  VpnProps get vpnProps;
  @override
  @JsonKey(fromJson: ThemeProps.safeFromJson)
  ThemeProps get themeProps;
  @override
  ProxiesStyle get proxiesStyle;
  @override
  WindowProps get windowProps;
  @override
  ClashConfig get patchClashConfig;
  @override
  ScriptProps get scriptProps;

  /// Create a copy of Config
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ConfigImplCopyWith<_$ConfigImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
