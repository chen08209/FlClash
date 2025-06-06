// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../core.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

SetupParams _$SetupParamsFromJson(Map<String, dynamic> json) {
  return _SetupParams.fromJson(json);
}

/// @nodoc
mixin _$SetupParams {
  @JsonKey(name: 'config')
  Map<String, dynamic> get config => throw _privateConstructorUsedError;
  @JsonKey(name: 'selected-map')
  Map<String, String> get selectedMap => throw _privateConstructorUsedError;
  @JsonKey(name: 'test-url')
  String get testUrl => throw _privateConstructorUsedError;

  /// Serializes this SetupParams to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SetupParams
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SetupParamsCopyWith<SetupParams> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SetupParamsCopyWith<$Res> {
  factory $SetupParamsCopyWith(
          SetupParams value, $Res Function(SetupParams) then) =
      _$SetupParamsCopyWithImpl<$Res, SetupParams>;
  @useResult
  $Res call(
      {@JsonKey(name: 'config') Map<String, dynamic> config,
      @JsonKey(name: 'selected-map') Map<String, String> selectedMap,
      @JsonKey(name: 'test-url') String testUrl});
}

/// @nodoc
class _$SetupParamsCopyWithImpl<$Res, $Val extends SetupParams>
    implements $SetupParamsCopyWith<$Res> {
  _$SetupParamsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SetupParams
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? config = null,
    Object? selectedMap = null,
    Object? testUrl = null,
  }) {
    return _then(_value.copyWith(
      config: null == config
          ? _value.config
          : config // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      selectedMap: null == selectedMap
          ? _value.selectedMap
          : selectedMap // ignore: cast_nullable_to_non_nullable
              as Map<String, String>,
      testUrl: null == testUrl
          ? _value.testUrl
          : testUrl // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SetupParamsImplCopyWith<$Res>
    implements $SetupParamsCopyWith<$Res> {
  factory _$$SetupParamsImplCopyWith(
          _$SetupParamsImpl value, $Res Function(_$SetupParamsImpl) then) =
      __$$SetupParamsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'config') Map<String, dynamic> config,
      @JsonKey(name: 'selected-map') Map<String, String> selectedMap,
      @JsonKey(name: 'test-url') String testUrl});
}

/// @nodoc
class __$$SetupParamsImplCopyWithImpl<$Res>
    extends _$SetupParamsCopyWithImpl<$Res, _$SetupParamsImpl>
    implements _$$SetupParamsImplCopyWith<$Res> {
  __$$SetupParamsImplCopyWithImpl(
      _$SetupParamsImpl _value, $Res Function(_$SetupParamsImpl) _then)
      : super(_value, _then);

  /// Create a copy of SetupParams
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? config = null,
    Object? selectedMap = null,
    Object? testUrl = null,
  }) {
    return _then(_$SetupParamsImpl(
      config: null == config
          ? _value._config
          : config // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      selectedMap: null == selectedMap
          ? _value._selectedMap
          : selectedMap // ignore: cast_nullable_to_non_nullable
              as Map<String, String>,
      testUrl: null == testUrl
          ? _value.testUrl
          : testUrl // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SetupParamsImpl implements _SetupParams {
  const _$SetupParamsImpl(
      {@JsonKey(name: 'config') required final Map<String, dynamic> config,
      @JsonKey(name: 'selected-map')
      required final Map<String, String> selectedMap,
      @JsonKey(name: 'test-url') required this.testUrl})
      : _config = config,
        _selectedMap = selectedMap;

  factory _$SetupParamsImpl.fromJson(Map<String, dynamic> json) =>
      _$$SetupParamsImplFromJson(json);

  final Map<String, dynamic> _config;
  @override
  @JsonKey(name: 'config')
  Map<String, dynamic> get config {
    if (_config is EqualUnmodifiableMapView) return _config;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_config);
  }

  final Map<String, String> _selectedMap;
  @override
  @JsonKey(name: 'selected-map')
  Map<String, String> get selectedMap {
    if (_selectedMap is EqualUnmodifiableMapView) return _selectedMap;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_selectedMap);
  }

  @override
  @JsonKey(name: 'test-url')
  final String testUrl;

  @override
  String toString() {
    return 'SetupParams(config: $config, selectedMap: $selectedMap, testUrl: $testUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SetupParamsImpl &&
            const DeepCollectionEquality().equals(other._config, _config) &&
            const DeepCollectionEquality()
                .equals(other._selectedMap, _selectedMap) &&
            (identical(other.testUrl, testUrl) || other.testUrl == testUrl));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_config),
      const DeepCollectionEquality().hash(_selectedMap),
      testUrl);

  /// Create a copy of SetupParams
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SetupParamsImplCopyWith<_$SetupParamsImpl> get copyWith =>
      __$$SetupParamsImplCopyWithImpl<_$SetupParamsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SetupParamsImplToJson(
      this,
    );
  }
}

abstract class _SetupParams implements SetupParams {
  const factory _SetupParams(
          {@JsonKey(name: 'config') required final Map<String, dynamic> config,
          @JsonKey(name: 'selected-map')
          required final Map<String, String> selectedMap,
          @JsonKey(name: 'test-url') required final String testUrl}) =
      _$SetupParamsImpl;

  factory _SetupParams.fromJson(Map<String, dynamic> json) =
      _$SetupParamsImpl.fromJson;

  @override
  @JsonKey(name: 'config')
  Map<String, dynamic> get config;
  @override
  @JsonKey(name: 'selected-map')
  Map<String, String> get selectedMap;
  @override
  @JsonKey(name: 'test-url')
  String get testUrl;

  /// Create a copy of SetupParams
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SetupParamsImplCopyWith<_$SetupParamsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

UpdateParams _$UpdateParamsFromJson(Map<String, dynamic> json) {
  return _UpdateParams.fromJson(json);
}

/// @nodoc
mixin _$UpdateParams {
  Tun get tun => throw _privateConstructorUsedError;
  @JsonKey(name: 'mixed-port')
  int get mixedPort => throw _privateConstructorUsedError;
  @JsonKey(name: 'allow-lan')
  bool get allowLan => throw _privateConstructorUsedError;
  @JsonKey(name: 'find-process-mode')
  FindProcessMode get findProcessMode => throw _privateConstructorUsedError;
  Mode get mode => throw _privateConstructorUsedError;
  @JsonKey(name: 'log-level')
  LogLevel get logLevel => throw _privateConstructorUsedError;
  bool get ipv6 => throw _privateConstructorUsedError;
  @JsonKey(name: 'tcp-concurrent')
  bool get tcpConcurrent => throw _privateConstructorUsedError;
  @JsonKey(name: 'external-controller')
  ExternalControllerStatus get externalController =>
      throw _privateConstructorUsedError;
  @JsonKey(name: 'unified-delay')
  bool get unifiedDelay => throw _privateConstructorUsedError;

  /// Serializes this UpdateParams to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UpdateParams
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UpdateParamsCopyWith<UpdateParams> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UpdateParamsCopyWith<$Res> {
  factory $UpdateParamsCopyWith(
          UpdateParams value, $Res Function(UpdateParams) then) =
      _$UpdateParamsCopyWithImpl<$Res, UpdateParams>;
  @useResult
  $Res call(
      {Tun tun,
      @JsonKey(name: 'mixed-port') int mixedPort,
      @JsonKey(name: 'allow-lan') bool allowLan,
      @JsonKey(name: 'find-process-mode') FindProcessMode findProcessMode,
      Mode mode,
      @JsonKey(name: 'log-level') LogLevel logLevel,
      bool ipv6,
      @JsonKey(name: 'tcp-concurrent') bool tcpConcurrent,
      @JsonKey(name: 'external-controller')
      ExternalControllerStatus externalController,
      @JsonKey(name: 'unified-delay') bool unifiedDelay});

  $TunCopyWith<$Res> get tun;
}

/// @nodoc
class _$UpdateParamsCopyWithImpl<$Res, $Val extends UpdateParams>
    implements $UpdateParamsCopyWith<$Res> {
  _$UpdateParamsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UpdateParams
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? tun = null,
    Object? mixedPort = null,
    Object? allowLan = null,
    Object? findProcessMode = null,
    Object? mode = null,
    Object? logLevel = null,
    Object? ipv6 = null,
    Object? tcpConcurrent = null,
    Object? externalController = null,
    Object? unifiedDelay = null,
  }) {
    return _then(_value.copyWith(
      tun: null == tun
          ? _value.tun
          : tun // ignore: cast_nullable_to_non_nullable
              as Tun,
      mixedPort: null == mixedPort
          ? _value.mixedPort
          : mixedPort // ignore: cast_nullable_to_non_nullable
              as int,
      allowLan: null == allowLan
          ? _value.allowLan
          : allowLan // ignore: cast_nullable_to_non_nullable
              as bool,
      findProcessMode: null == findProcessMode
          ? _value.findProcessMode
          : findProcessMode // ignore: cast_nullable_to_non_nullable
              as FindProcessMode,
      mode: null == mode
          ? _value.mode
          : mode // ignore: cast_nullable_to_non_nullable
              as Mode,
      logLevel: null == logLevel
          ? _value.logLevel
          : logLevel // ignore: cast_nullable_to_non_nullable
              as LogLevel,
      ipv6: null == ipv6
          ? _value.ipv6
          : ipv6 // ignore: cast_nullable_to_non_nullable
              as bool,
      tcpConcurrent: null == tcpConcurrent
          ? _value.tcpConcurrent
          : tcpConcurrent // ignore: cast_nullable_to_non_nullable
              as bool,
      externalController: null == externalController
          ? _value.externalController
          : externalController // ignore: cast_nullable_to_non_nullable
              as ExternalControllerStatus,
      unifiedDelay: null == unifiedDelay
          ? _value.unifiedDelay
          : unifiedDelay // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }

  /// Create a copy of UpdateParams
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TunCopyWith<$Res> get tun {
    return $TunCopyWith<$Res>(_value.tun, (value) {
      return _then(_value.copyWith(tun: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$UpdateParamsImplCopyWith<$Res>
    implements $UpdateParamsCopyWith<$Res> {
  factory _$$UpdateParamsImplCopyWith(
          _$UpdateParamsImpl value, $Res Function(_$UpdateParamsImpl) then) =
      __$$UpdateParamsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {Tun tun,
      @JsonKey(name: 'mixed-port') int mixedPort,
      @JsonKey(name: 'allow-lan') bool allowLan,
      @JsonKey(name: 'find-process-mode') FindProcessMode findProcessMode,
      Mode mode,
      @JsonKey(name: 'log-level') LogLevel logLevel,
      bool ipv6,
      @JsonKey(name: 'tcp-concurrent') bool tcpConcurrent,
      @JsonKey(name: 'external-controller')
      ExternalControllerStatus externalController,
      @JsonKey(name: 'unified-delay') bool unifiedDelay});

  @override
  $TunCopyWith<$Res> get tun;
}

/// @nodoc
class __$$UpdateParamsImplCopyWithImpl<$Res>
    extends _$UpdateParamsCopyWithImpl<$Res, _$UpdateParamsImpl>
    implements _$$UpdateParamsImplCopyWith<$Res> {
  __$$UpdateParamsImplCopyWithImpl(
      _$UpdateParamsImpl _value, $Res Function(_$UpdateParamsImpl) _then)
      : super(_value, _then);

  /// Create a copy of UpdateParams
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? tun = null,
    Object? mixedPort = null,
    Object? allowLan = null,
    Object? findProcessMode = null,
    Object? mode = null,
    Object? logLevel = null,
    Object? ipv6 = null,
    Object? tcpConcurrent = null,
    Object? externalController = null,
    Object? unifiedDelay = null,
  }) {
    return _then(_$UpdateParamsImpl(
      tun: null == tun
          ? _value.tun
          : tun // ignore: cast_nullable_to_non_nullable
              as Tun,
      mixedPort: null == mixedPort
          ? _value.mixedPort
          : mixedPort // ignore: cast_nullable_to_non_nullable
              as int,
      allowLan: null == allowLan
          ? _value.allowLan
          : allowLan // ignore: cast_nullable_to_non_nullable
              as bool,
      findProcessMode: null == findProcessMode
          ? _value.findProcessMode
          : findProcessMode // ignore: cast_nullable_to_non_nullable
              as FindProcessMode,
      mode: null == mode
          ? _value.mode
          : mode // ignore: cast_nullable_to_non_nullable
              as Mode,
      logLevel: null == logLevel
          ? _value.logLevel
          : logLevel // ignore: cast_nullable_to_non_nullable
              as LogLevel,
      ipv6: null == ipv6
          ? _value.ipv6
          : ipv6 // ignore: cast_nullable_to_non_nullable
              as bool,
      tcpConcurrent: null == tcpConcurrent
          ? _value.tcpConcurrent
          : tcpConcurrent // ignore: cast_nullable_to_non_nullable
              as bool,
      externalController: null == externalController
          ? _value.externalController
          : externalController // ignore: cast_nullable_to_non_nullable
              as ExternalControllerStatus,
      unifiedDelay: null == unifiedDelay
          ? _value.unifiedDelay
          : unifiedDelay // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UpdateParamsImpl implements _UpdateParams {
  const _$UpdateParamsImpl(
      {required this.tun,
      @JsonKey(name: 'mixed-port') required this.mixedPort,
      @JsonKey(name: 'allow-lan') required this.allowLan,
      @JsonKey(name: 'find-process-mode') required this.findProcessMode,
      required this.mode,
      @JsonKey(name: 'log-level') required this.logLevel,
      required this.ipv6,
      @JsonKey(name: 'tcp-concurrent') required this.tcpConcurrent,
      @JsonKey(name: 'external-controller') required this.externalController,
      @JsonKey(name: 'unified-delay') required this.unifiedDelay});

  factory _$UpdateParamsImpl.fromJson(Map<String, dynamic> json) =>
      _$$UpdateParamsImplFromJson(json);

  @override
  final Tun tun;
  @override
  @JsonKey(name: 'mixed-port')
  final int mixedPort;
  @override
  @JsonKey(name: 'allow-lan')
  final bool allowLan;
  @override
  @JsonKey(name: 'find-process-mode')
  final FindProcessMode findProcessMode;
  @override
  final Mode mode;
  @override
  @JsonKey(name: 'log-level')
  final LogLevel logLevel;
  @override
  final bool ipv6;
  @override
  @JsonKey(name: 'tcp-concurrent')
  final bool tcpConcurrent;
  @override
  @JsonKey(name: 'external-controller')
  final ExternalControllerStatus externalController;
  @override
  @JsonKey(name: 'unified-delay')
  final bool unifiedDelay;

  @override
  String toString() {
    return 'UpdateParams(tun: $tun, mixedPort: $mixedPort, allowLan: $allowLan, findProcessMode: $findProcessMode, mode: $mode, logLevel: $logLevel, ipv6: $ipv6, tcpConcurrent: $tcpConcurrent, externalController: $externalController, unifiedDelay: $unifiedDelay)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UpdateParamsImpl &&
            (identical(other.tun, tun) || other.tun == tun) &&
            (identical(other.mixedPort, mixedPort) ||
                other.mixedPort == mixedPort) &&
            (identical(other.allowLan, allowLan) ||
                other.allowLan == allowLan) &&
            (identical(other.findProcessMode, findProcessMode) ||
                other.findProcessMode == findProcessMode) &&
            (identical(other.mode, mode) || other.mode == mode) &&
            (identical(other.logLevel, logLevel) ||
                other.logLevel == logLevel) &&
            (identical(other.ipv6, ipv6) || other.ipv6 == ipv6) &&
            (identical(other.tcpConcurrent, tcpConcurrent) ||
                other.tcpConcurrent == tcpConcurrent) &&
            (identical(other.externalController, externalController) ||
                other.externalController == externalController) &&
            (identical(other.unifiedDelay, unifiedDelay) ||
                other.unifiedDelay == unifiedDelay));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      tun,
      mixedPort,
      allowLan,
      findProcessMode,
      mode,
      logLevel,
      ipv6,
      tcpConcurrent,
      externalController,
      unifiedDelay);

  /// Create a copy of UpdateParams
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UpdateParamsImplCopyWith<_$UpdateParamsImpl> get copyWith =>
      __$$UpdateParamsImplCopyWithImpl<_$UpdateParamsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UpdateParamsImplToJson(
      this,
    );
  }
}

abstract class _UpdateParams implements UpdateParams {
  const factory _UpdateParams(
          {required final Tun tun,
          @JsonKey(name: 'mixed-port') required final int mixedPort,
          @JsonKey(name: 'allow-lan') required final bool allowLan,
          @JsonKey(name: 'find-process-mode')
          required final FindProcessMode findProcessMode,
          required final Mode mode,
          @JsonKey(name: 'log-level') required final LogLevel logLevel,
          required final bool ipv6,
          @JsonKey(name: 'tcp-concurrent') required final bool tcpConcurrent,
          @JsonKey(name: 'external-controller')
          required final ExternalControllerStatus externalController,
          @JsonKey(name: 'unified-delay') required final bool unifiedDelay}) =
      _$UpdateParamsImpl;

  factory _UpdateParams.fromJson(Map<String, dynamic> json) =
      _$UpdateParamsImpl.fromJson;

  @override
  Tun get tun;
  @override
  @JsonKey(name: 'mixed-port')
  int get mixedPort;
  @override
  @JsonKey(name: 'allow-lan')
  bool get allowLan;
  @override
  @JsonKey(name: 'find-process-mode')
  FindProcessMode get findProcessMode;
  @override
  Mode get mode;
  @override
  @JsonKey(name: 'log-level')
  LogLevel get logLevel;
  @override
  bool get ipv6;
  @override
  @JsonKey(name: 'tcp-concurrent')
  bool get tcpConcurrent;
  @override
  @JsonKey(name: 'external-controller')
  ExternalControllerStatus get externalController;
  @override
  @JsonKey(name: 'unified-delay')
  bool get unifiedDelay;

  /// Create a copy of UpdateParams
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UpdateParamsImplCopyWith<_$UpdateParamsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CoreState _$CoreStateFromJson(Map<String, dynamic> json) {
  return _CoreState.fromJson(json);
}

/// @nodoc
mixin _$CoreState {
  @JsonKey(name: 'vpn-props')
  VpnProps get vpnProps => throw _privateConstructorUsedError;
  @JsonKey(name: 'only-statistics-proxy')
  bool get onlyStatisticsProxy => throw _privateConstructorUsedError;
  @JsonKey(name: 'current-profile-name')
  String get currentProfileName => throw _privateConstructorUsedError;
  @JsonKey(name: 'bypass-domain')
  List<String> get bypassDomain => throw _privateConstructorUsedError;

  /// Serializes this CoreState to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CoreState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CoreStateCopyWith<CoreState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CoreStateCopyWith<$Res> {
  factory $CoreStateCopyWith(CoreState value, $Res Function(CoreState) then) =
      _$CoreStateCopyWithImpl<$Res, CoreState>;
  @useResult
  $Res call(
      {@JsonKey(name: 'vpn-props') VpnProps vpnProps,
      @JsonKey(name: 'only-statistics-proxy') bool onlyStatisticsProxy,
      @JsonKey(name: 'current-profile-name') String currentProfileName,
      @JsonKey(name: 'bypass-domain') List<String> bypassDomain});

  $VpnPropsCopyWith<$Res> get vpnProps;
}

/// @nodoc
class _$CoreStateCopyWithImpl<$Res, $Val extends CoreState>
    implements $CoreStateCopyWith<$Res> {
  _$CoreStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CoreState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? vpnProps = null,
    Object? onlyStatisticsProxy = null,
    Object? currentProfileName = null,
    Object? bypassDomain = null,
  }) {
    return _then(_value.copyWith(
      vpnProps: null == vpnProps
          ? _value.vpnProps
          : vpnProps // ignore: cast_nullable_to_non_nullable
              as VpnProps,
      onlyStatisticsProxy: null == onlyStatisticsProxy
          ? _value.onlyStatisticsProxy
          : onlyStatisticsProxy // ignore: cast_nullable_to_non_nullable
              as bool,
      currentProfileName: null == currentProfileName
          ? _value.currentProfileName
          : currentProfileName // ignore: cast_nullable_to_non_nullable
              as String,
      bypassDomain: null == bypassDomain
          ? _value.bypassDomain
          : bypassDomain // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }

  /// Create a copy of CoreState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $VpnPropsCopyWith<$Res> get vpnProps {
    return $VpnPropsCopyWith<$Res>(_value.vpnProps, (value) {
      return _then(_value.copyWith(vpnProps: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$CoreStateImplCopyWith<$Res>
    implements $CoreStateCopyWith<$Res> {
  factory _$$CoreStateImplCopyWith(
          _$CoreStateImpl value, $Res Function(_$CoreStateImpl) then) =
      __$$CoreStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'vpn-props') VpnProps vpnProps,
      @JsonKey(name: 'only-statistics-proxy') bool onlyStatisticsProxy,
      @JsonKey(name: 'current-profile-name') String currentProfileName,
      @JsonKey(name: 'bypass-domain') List<String> bypassDomain});

  @override
  $VpnPropsCopyWith<$Res> get vpnProps;
}

/// @nodoc
class __$$CoreStateImplCopyWithImpl<$Res>
    extends _$CoreStateCopyWithImpl<$Res, _$CoreStateImpl>
    implements _$$CoreStateImplCopyWith<$Res> {
  __$$CoreStateImplCopyWithImpl(
      _$CoreStateImpl _value, $Res Function(_$CoreStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of CoreState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? vpnProps = null,
    Object? onlyStatisticsProxy = null,
    Object? currentProfileName = null,
    Object? bypassDomain = null,
  }) {
    return _then(_$CoreStateImpl(
      vpnProps: null == vpnProps
          ? _value.vpnProps
          : vpnProps // ignore: cast_nullable_to_non_nullable
              as VpnProps,
      onlyStatisticsProxy: null == onlyStatisticsProxy
          ? _value.onlyStatisticsProxy
          : onlyStatisticsProxy // ignore: cast_nullable_to_non_nullable
              as bool,
      currentProfileName: null == currentProfileName
          ? _value.currentProfileName
          : currentProfileName // ignore: cast_nullable_to_non_nullable
              as String,
      bypassDomain: null == bypassDomain
          ? _value._bypassDomain
          : bypassDomain // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CoreStateImpl implements _CoreState {
  const _$CoreStateImpl(
      {@JsonKey(name: 'vpn-props') required this.vpnProps,
      @JsonKey(name: 'only-statistics-proxy') required this.onlyStatisticsProxy,
      @JsonKey(name: 'current-profile-name') required this.currentProfileName,
      @JsonKey(name: 'bypass-domain')
      final List<String> bypassDomain = const []})
      : _bypassDomain = bypassDomain;

  factory _$CoreStateImpl.fromJson(Map<String, dynamic> json) =>
      _$$CoreStateImplFromJson(json);

  @override
  @JsonKey(name: 'vpn-props')
  final VpnProps vpnProps;
  @override
  @JsonKey(name: 'only-statistics-proxy')
  final bool onlyStatisticsProxy;
  @override
  @JsonKey(name: 'current-profile-name')
  final String currentProfileName;
  final List<String> _bypassDomain;
  @override
  @JsonKey(name: 'bypass-domain')
  List<String> get bypassDomain {
    if (_bypassDomain is EqualUnmodifiableListView) return _bypassDomain;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_bypassDomain);
  }

  @override
  String toString() {
    return 'CoreState(vpnProps: $vpnProps, onlyStatisticsProxy: $onlyStatisticsProxy, currentProfileName: $currentProfileName, bypassDomain: $bypassDomain)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CoreStateImpl &&
            (identical(other.vpnProps, vpnProps) ||
                other.vpnProps == vpnProps) &&
            (identical(other.onlyStatisticsProxy, onlyStatisticsProxy) ||
                other.onlyStatisticsProxy == onlyStatisticsProxy) &&
            (identical(other.currentProfileName, currentProfileName) ||
                other.currentProfileName == currentProfileName) &&
            const DeepCollectionEquality()
                .equals(other._bypassDomain, _bypassDomain));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, vpnProps, onlyStatisticsProxy,
      currentProfileName, const DeepCollectionEquality().hash(_bypassDomain));

  /// Create a copy of CoreState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CoreStateImplCopyWith<_$CoreStateImpl> get copyWith =>
      __$$CoreStateImplCopyWithImpl<_$CoreStateImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CoreStateImplToJson(
      this,
    );
  }
}

abstract class _CoreState implements CoreState {
  const factory _CoreState(
          {@JsonKey(name: 'vpn-props') required final VpnProps vpnProps,
          @JsonKey(name: 'only-statistics-proxy')
          required final bool onlyStatisticsProxy,
          @JsonKey(name: 'current-profile-name')
          required final String currentProfileName,
          @JsonKey(name: 'bypass-domain') final List<String> bypassDomain}) =
      _$CoreStateImpl;

  factory _CoreState.fromJson(Map<String, dynamic> json) =
      _$CoreStateImpl.fromJson;

  @override
  @JsonKey(name: 'vpn-props')
  VpnProps get vpnProps;
  @override
  @JsonKey(name: 'only-statistics-proxy')
  bool get onlyStatisticsProxy;
  @override
  @JsonKey(name: 'current-profile-name')
  String get currentProfileName;
  @override
  @JsonKey(name: 'bypass-domain')
  List<String> get bypassDomain;

  /// Create a copy of CoreState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CoreStateImplCopyWith<_$CoreStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AndroidVpnOptions _$AndroidVpnOptionsFromJson(Map<String, dynamic> json) {
  return _AndroidVpnOptions.fromJson(json);
}

/// @nodoc
mixin _$AndroidVpnOptions {
  bool get enable => throw _privateConstructorUsedError;
  int get port => throw _privateConstructorUsedError;
  AccessControl? get accessControl => throw _privateConstructorUsedError;
  bool get allowBypass => throw _privateConstructorUsedError;
  bool get systemProxy => throw _privateConstructorUsedError;
  List<String> get bypassDomain => throw _privateConstructorUsedError;
  String get ipv4Address => throw _privateConstructorUsedError;
  String get ipv6Address => throw _privateConstructorUsedError;
  List<String> get routeAddress => throw _privateConstructorUsedError;
  String get dnsServerAddress => throw _privateConstructorUsedError;

  /// Serializes this AndroidVpnOptions to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AndroidVpnOptions
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AndroidVpnOptionsCopyWith<AndroidVpnOptions> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AndroidVpnOptionsCopyWith<$Res> {
  factory $AndroidVpnOptionsCopyWith(
          AndroidVpnOptions value, $Res Function(AndroidVpnOptions) then) =
      _$AndroidVpnOptionsCopyWithImpl<$Res, AndroidVpnOptions>;
  @useResult
  $Res call(
      {bool enable,
      int port,
      AccessControl? accessControl,
      bool allowBypass,
      bool systemProxy,
      List<String> bypassDomain,
      String ipv4Address,
      String ipv6Address,
      List<String> routeAddress,
      String dnsServerAddress});

  $AccessControlCopyWith<$Res>? get accessControl;
}

/// @nodoc
class _$AndroidVpnOptionsCopyWithImpl<$Res, $Val extends AndroidVpnOptions>
    implements $AndroidVpnOptionsCopyWith<$Res> {
  _$AndroidVpnOptionsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AndroidVpnOptions
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? enable = null,
    Object? port = null,
    Object? accessControl = freezed,
    Object? allowBypass = null,
    Object? systemProxy = null,
    Object? bypassDomain = null,
    Object? ipv4Address = null,
    Object? ipv6Address = null,
    Object? routeAddress = null,
    Object? dnsServerAddress = null,
  }) {
    return _then(_value.copyWith(
      enable: null == enable
          ? _value.enable
          : enable // ignore: cast_nullable_to_non_nullable
              as bool,
      port: null == port
          ? _value.port
          : port // ignore: cast_nullable_to_non_nullable
              as int,
      accessControl: freezed == accessControl
          ? _value.accessControl
          : accessControl // ignore: cast_nullable_to_non_nullable
              as AccessControl?,
      allowBypass: null == allowBypass
          ? _value.allowBypass
          : allowBypass // ignore: cast_nullable_to_non_nullable
              as bool,
      systemProxy: null == systemProxy
          ? _value.systemProxy
          : systemProxy // ignore: cast_nullable_to_non_nullable
              as bool,
      bypassDomain: null == bypassDomain
          ? _value.bypassDomain
          : bypassDomain // ignore: cast_nullable_to_non_nullable
              as List<String>,
      ipv4Address: null == ipv4Address
          ? _value.ipv4Address
          : ipv4Address // ignore: cast_nullable_to_non_nullable
              as String,
      ipv6Address: null == ipv6Address
          ? _value.ipv6Address
          : ipv6Address // ignore: cast_nullable_to_non_nullable
              as String,
      routeAddress: null == routeAddress
          ? _value.routeAddress
          : routeAddress // ignore: cast_nullable_to_non_nullable
              as List<String>,
      dnsServerAddress: null == dnsServerAddress
          ? _value.dnsServerAddress
          : dnsServerAddress // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }

  /// Create a copy of AndroidVpnOptions
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AccessControlCopyWith<$Res>? get accessControl {
    if (_value.accessControl == null) {
      return null;
    }

    return $AccessControlCopyWith<$Res>(_value.accessControl!, (value) {
      return _then(_value.copyWith(accessControl: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$AndroidVpnOptionsImplCopyWith<$Res>
    implements $AndroidVpnOptionsCopyWith<$Res> {
  factory _$$AndroidVpnOptionsImplCopyWith(_$AndroidVpnOptionsImpl value,
          $Res Function(_$AndroidVpnOptionsImpl) then) =
      __$$AndroidVpnOptionsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool enable,
      int port,
      AccessControl? accessControl,
      bool allowBypass,
      bool systemProxy,
      List<String> bypassDomain,
      String ipv4Address,
      String ipv6Address,
      List<String> routeAddress,
      String dnsServerAddress});

  @override
  $AccessControlCopyWith<$Res>? get accessControl;
}

/// @nodoc
class __$$AndroidVpnOptionsImplCopyWithImpl<$Res>
    extends _$AndroidVpnOptionsCopyWithImpl<$Res, _$AndroidVpnOptionsImpl>
    implements _$$AndroidVpnOptionsImplCopyWith<$Res> {
  __$$AndroidVpnOptionsImplCopyWithImpl(_$AndroidVpnOptionsImpl _value,
      $Res Function(_$AndroidVpnOptionsImpl) _then)
      : super(_value, _then);

  /// Create a copy of AndroidVpnOptions
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? enable = null,
    Object? port = null,
    Object? accessControl = freezed,
    Object? allowBypass = null,
    Object? systemProxy = null,
    Object? bypassDomain = null,
    Object? ipv4Address = null,
    Object? ipv6Address = null,
    Object? routeAddress = null,
    Object? dnsServerAddress = null,
  }) {
    return _then(_$AndroidVpnOptionsImpl(
      enable: null == enable
          ? _value.enable
          : enable // ignore: cast_nullable_to_non_nullable
              as bool,
      port: null == port
          ? _value.port
          : port // ignore: cast_nullable_to_non_nullable
              as int,
      accessControl: freezed == accessControl
          ? _value.accessControl
          : accessControl // ignore: cast_nullable_to_non_nullable
              as AccessControl?,
      allowBypass: null == allowBypass
          ? _value.allowBypass
          : allowBypass // ignore: cast_nullable_to_non_nullable
              as bool,
      systemProxy: null == systemProxy
          ? _value.systemProxy
          : systemProxy // ignore: cast_nullable_to_non_nullable
              as bool,
      bypassDomain: null == bypassDomain
          ? _value._bypassDomain
          : bypassDomain // ignore: cast_nullable_to_non_nullable
              as List<String>,
      ipv4Address: null == ipv4Address
          ? _value.ipv4Address
          : ipv4Address // ignore: cast_nullable_to_non_nullable
              as String,
      ipv6Address: null == ipv6Address
          ? _value.ipv6Address
          : ipv6Address // ignore: cast_nullable_to_non_nullable
              as String,
      routeAddress: null == routeAddress
          ? _value._routeAddress
          : routeAddress // ignore: cast_nullable_to_non_nullable
              as List<String>,
      dnsServerAddress: null == dnsServerAddress
          ? _value.dnsServerAddress
          : dnsServerAddress // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AndroidVpnOptionsImpl implements _AndroidVpnOptions {
  const _$AndroidVpnOptionsImpl(
      {required this.enable,
      required this.port,
      required this.accessControl,
      required this.allowBypass,
      required this.systemProxy,
      required final List<String> bypassDomain,
      required this.ipv4Address,
      required this.ipv6Address,
      final List<String> routeAddress = const [],
      required this.dnsServerAddress})
      : _bypassDomain = bypassDomain,
        _routeAddress = routeAddress;

  factory _$AndroidVpnOptionsImpl.fromJson(Map<String, dynamic> json) =>
      _$$AndroidVpnOptionsImplFromJson(json);

  @override
  final bool enable;
  @override
  final int port;
  @override
  final AccessControl? accessControl;
  @override
  final bool allowBypass;
  @override
  final bool systemProxy;
  final List<String> _bypassDomain;
  @override
  List<String> get bypassDomain {
    if (_bypassDomain is EqualUnmodifiableListView) return _bypassDomain;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_bypassDomain);
  }

  @override
  final String ipv4Address;
  @override
  final String ipv6Address;
  final List<String> _routeAddress;
  @override
  @JsonKey()
  List<String> get routeAddress {
    if (_routeAddress is EqualUnmodifiableListView) return _routeAddress;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_routeAddress);
  }

  @override
  final String dnsServerAddress;

  @override
  String toString() {
    return 'AndroidVpnOptions(enable: $enable, port: $port, accessControl: $accessControl, allowBypass: $allowBypass, systemProxy: $systemProxy, bypassDomain: $bypassDomain, ipv4Address: $ipv4Address, ipv6Address: $ipv6Address, routeAddress: $routeAddress, dnsServerAddress: $dnsServerAddress)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AndroidVpnOptionsImpl &&
            (identical(other.enable, enable) || other.enable == enable) &&
            (identical(other.port, port) || other.port == port) &&
            (identical(other.accessControl, accessControl) ||
                other.accessControl == accessControl) &&
            (identical(other.allowBypass, allowBypass) ||
                other.allowBypass == allowBypass) &&
            (identical(other.systemProxy, systemProxy) ||
                other.systemProxy == systemProxy) &&
            const DeepCollectionEquality()
                .equals(other._bypassDomain, _bypassDomain) &&
            (identical(other.ipv4Address, ipv4Address) ||
                other.ipv4Address == ipv4Address) &&
            (identical(other.ipv6Address, ipv6Address) ||
                other.ipv6Address == ipv6Address) &&
            const DeepCollectionEquality()
                .equals(other._routeAddress, _routeAddress) &&
            (identical(other.dnsServerAddress, dnsServerAddress) ||
                other.dnsServerAddress == dnsServerAddress));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      enable,
      port,
      accessControl,
      allowBypass,
      systemProxy,
      const DeepCollectionEquality().hash(_bypassDomain),
      ipv4Address,
      ipv6Address,
      const DeepCollectionEquality().hash(_routeAddress),
      dnsServerAddress);

  /// Create a copy of AndroidVpnOptions
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AndroidVpnOptionsImplCopyWith<_$AndroidVpnOptionsImpl> get copyWith =>
      __$$AndroidVpnOptionsImplCopyWithImpl<_$AndroidVpnOptionsImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AndroidVpnOptionsImplToJson(
      this,
    );
  }
}

abstract class _AndroidVpnOptions implements AndroidVpnOptions {
  const factory _AndroidVpnOptions(
      {required final bool enable,
      required final int port,
      required final AccessControl? accessControl,
      required final bool allowBypass,
      required final bool systemProxy,
      required final List<String> bypassDomain,
      required final String ipv4Address,
      required final String ipv6Address,
      final List<String> routeAddress,
      required final String dnsServerAddress}) = _$AndroidVpnOptionsImpl;

  factory _AndroidVpnOptions.fromJson(Map<String, dynamic> json) =
      _$AndroidVpnOptionsImpl.fromJson;

  @override
  bool get enable;
  @override
  int get port;
  @override
  AccessControl? get accessControl;
  @override
  bool get allowBypass;
  @override
  bool get systemProxy;
  @override
  List<String> get bypassDomain;
  @override
  String get ipv4Address;
  @override
  String get ipv6Address;
  @override
  List<String> get routeAddress;
  @override
  String get dnsServerAddress;

  /// Create a copy of AndroidVpnOptions
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AndroidVpnOptionsImplCopyWith<_$AndroidVpnOptionsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

InitParams _$InitParamsFromJson(Map<String, dynamic> json) {
  return _InitParams.fromJson(json);
}

/// @nodoc
mixin _$InitParams {
  @JsonKey(name: 'home-dir')
  String get homeDir => throw _privateConstructorUsedError;
  int get version => throw _privateConstructorUsedError;

  /// Serializes this InitParams to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of InitParams
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $InitParamsCopyWith<InitParams> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $InitParamsCopyWith<$Res> {
  factory $InitParamsCopyWith(
          InitParams value, $Res Function(InitParams) then) =
      _$InitParamsCopyWithImpl<$Res, InitParams>;
  @useResult
  $Res call({@JsonKey(name: 'home-dir') String homeDir, int version});
}

/// @nodoc
class _$InitParamsCopyWithImpl<$Res, $Val extends InitParams>
    implements $InitParamsCopyWith<$Res> {
  _$InitParamsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of InitParams
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? homeDir = null,
    Object? version = null,
  }) {
    return _then(_value.copyWith(
      homeDir: null == homeDir
          ? _value.homeDir
          : homeDir // ignore: cast_nullable_to_non_nullable
              as String,
      version: null == version
          ? _value.version
          : version // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$InitParamsImplCopyWith<$Res>
    implements $InitParamsCopyWith<$Res> {
  factory _$$InitParamsImplCopyWith(
          _$InitParamsImpl value, $Res Function(_$InitParamsImpl) then) =
      __$$InitParamsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({@JsonKey(name: 'home-dir') String homeDir, int version});
}

/// @nodoc
class __$$InitParamsImplCopyWithImpl<$Res>
    extends _$InitParamsCopyWithImpl<$Res, _$InitParamsImpl>
    implements _$$InitParamsImplCopyWith<$Res> {
  __$$InitParamsImplCopyWithImpl(
      _$InitParamsImpl _value, $Res Function(_$InitParamsImpl) _then)
      : super(_value, _then);

  /// Create a copy of InitParams
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? homeDir = null,
    Object? version = null,
  }) {
    return _then(_$InitParamsImpl(
      homeDir: null == homeDir
          ? _value.homeDir
          : homeDir // ignore: cast_nullable_to_non_nullable
              as String,
      version: null == version
          ? _value.version
          : version // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$InitParamsImpl implements _InitParams {
  const _$InitParamsImpl(
      {@JsonKey(name: 'home-dir') required this.homeDir,
      required this.version});

  factory _$InitParamsImpl.fromJson(Map<String, dynamic> json) =>
      _$$InitParamsImplFromJson(json);

  @override
  @JsonKey(name: 'home-dir')
  final String homeDir;
  @override
  final int version;

  @override
  String toString() {
    return 'InitParams(homeDir: $homeDir, version: $version)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$InitParamsImpl &&
            (identical(other.homeDir, homeDir) || other.homeDir == homeDir) &&
            (identical(other.version, version) || other.version == version));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, homeDir, version);

  /// Create a copy of InitParams
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$InitParamsImplCopyWith<_$InitParamsImpl> get copyWith =>
      __$$InitParamsImplCopyWithImpl<_$InitParamsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$InitParamsImplToJson(
      this,
    );
  }
}

abstract class _InitParams implements InitParams {
  const factory _InitParams(
      {@JsonKey(name: 'home-dir') required final String homeDir,
      required final int version}) = _$InitParamsImpl;

  factory _InitParams.fromJson(Map<String, dynamic> json) =
      _$InitParamsImpl.fromJson;

  @override
  @JsonKey(name: 'home-dir')
  String get homeDir;
  @override
  int get version;

  /// Create a copy of InitParams
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$InitParamsImplCopyWith<_$InitParamsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ChangeProxyParams _$ChangeProxyParamsFromJson(Map<String, dynamic> json) {
  return _ChangeProxyParams.fromJson(json);
}

/// @nodoc
mixin _$ChangeProxyParams {
  @JsonKey(name: 'group-name')
  String get groupName => throw _privateConstructorUsedError;
  @JsonKey(name: 'proxy-name')
  String get proxyName => throw _privateConstructorUsedError;

  /// Serializes this ChangeProxyParams to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ChangeProxyParams
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ChangeProxyParamsCopyWith<ChangeProxyParams> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChangeProxyParamsCopyWith<$Res> {
  factory $ChangeProxyParamsCopyWith(
          ChangeProxyParams value, $Res Function(ChangeProxyParams) then) =
      _$ChangeProxyParamsCopyWithImpl<$Res, ChangeProxyParams>;
  @useResult
  $Res call(
      {@JsonKey(name: 'group-name') String groupName,
      @JsonKey(name: 'proxy-name') String proxyName});
}

/// @nodoc
class _$ChangeProxyParamsCopyWithImpl<$Res, $Val extends ChangeProxyParams>
    implements $ChangeProxyParamsCopyWith<$Res> {
  _$ChangeProxyParamsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ChangeProxyParams
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? groupName = null,
    Object? proxyName = null,
  }) {
    return _then(_value.copyWith(
      groupName: null == groupName
          ? _value.groupName
          : groupName // ignore: cast_nullable_to_non_nullable
              as String,
      proxyName: null == proxyName
          ? _value.proxyName
          : proxyName // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ChangeProxyParamsImplCopyWith<$Res>
    implements $ChangeProxyParamsCopyWith<$Res> {
  factory _$$ChangeProxyParamsImplCopyWith(_$ChangeProxyParamsImpl value,
          $Res Function(_$ChangeProxyParamsImpl) then) =
      __$$ChangeProxyParamsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'group-name') String groupName,
      @JsonKey(name: 'proxy-name') String proxyName});
}

/// @nodoc
class __$$ChangeProxyParamsImplCopyWithImpl<$Res>
    extends _$ChangeProxyParamsCopyWithImpl<$Res, _$ChangeProxyParamsImpl>
    implements _$$ChangeProxyParamsImplCopyWith<$Res> {
  __$$ChangeProxyParamsImplCopyWithImpl(_$ChangeProxyParamsImpl _value,
      $Res Function(_$ChangeProxyParamsImpl) _then)
      : super(_value, _then);

  /// Create a copy of ChangeProxyParams
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? groupName = null,
    Object? proxyName = null,
  }) {
    return _then(_$ChangeProxyParamsImpl(
      groupName: null == groupName
          ? _value.groupName
          : groupName // ignore: cast_nullable_to_non_nullable
              as String,
      proxyName: null == proxyName
          ? _value.proxyName
          : proxyName // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ChangeProxyParamsImpl implements _ChangeProxyParams {
  const _$ChangeProxyParamsImpl(
      {@JsonKey(name: 'group-name') required this.groupName,
      @JsonKey(name: 'proxy-name') required this.proxyName});

  factory _$ChangeProxyParamsImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChangeProxyParamsImplFromJson(json);

  @override
  @JsonKey(name: 'group-name')
  final String groupName;
  @override
  @JsonKey(name: 'proxy-name')
  final String proxyName;

  @override
  String toString() {
    return 'ChangeProxyParams(groupName: $groupName, proxyName: $proxyName)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChangeProxyParamsImpl &&
            (identical(other.groupName, groupName) ||
                other.groupName == groupName) &&
            (identical(other.proxyName, proxyName) ||
                other.proxyName == proxyName));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, groupName, proxyName);

  /// Create a copy of ChangeProxyParams
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChangeProxyParamsImplCopyWith<_$ChangeProxyParamsImpl> get copyWith =>
      __$$ChangeProxyParamsImplCopyWithImpl<_$ChangeProxyParamsImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ChangeProxyParamsImplToJson(
      this,
    );
  }
}

abstract class _ChangeProxyParams implements ChangeProxyParams {
  const factory _ChangeProxyParams(
          {@JsonKey(name: 'group-name') required final String groupName,
          @JsonKey(name: 'proxy-name') required final String proxyName}) =
      _$ChangeProxyParamsImpl;

  factory _ChangeProxyParams.fromJson(Map<String, dynamic> json) =
      _$ChangeProxyParamsImpl.fromJson;

  @override
  @JsonKey(name: 'group-name')
  String get groupName;
  @override
  @JsonKey(name: 'proxy-name')
  String get proxyName;

  /// Create a copy of ChangeProxyParams
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChangeProxyParamsImplCopyWith<_$ChangeProxyParamsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

UpdateGeoDataParams _$UpdateGeoDataParamsFromJson(Map<String, dynamic> json) {
  return _UpdateGeoDataParams.fromJson(json);
}

/// @nodoc
mixin _$UpdateGeoDataParams {
  @JsonKey(name: 'geo-type')
  String get geoType => throw _privateConstructorUsedError;
  @JsonKey(name: 'geo-name')
  String get geoName => throw _privateConstructorUsedError;

  /// Serializes this UpdateGeoDataParams to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UpdateGeoDataParams
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UpdateGeoDataParamsCopyWith<UpdateGeoDataParams> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UpdateGeoDataParamsCopyWith<$Res> {
  factory $UpdateGeoDataParamsCopyWith(
          UpdateGeoDataParams value, $Res Function(UpdateGeoDataParams) then) =
      _$UpdateGeoDataParamsCopyWithImpl<$Res, UpdateGeoDataParams>;
  @useResult
  $Res call(
      {@JsonKey(name: 'geo-type') String geoType,
      @JsonKey(name: 'geo-name') String geoName});
}

/// @nodoc
class _$UpdateGeoDataParamsCopyWithImpl<$Res, $Val extends UpdateGeoDataParams>
    implements $UpdateGeoDataParamsCopyWith<$Res> {
  _$UpdateGeoDataParamsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UpdateGeoDataParams
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? geoType = null,
    Object? geoName = null,
  }) {
    return _then(_value.copyWith(
      geoType: null == geoType
          ? _value.geoType
          : geoType // ignore: cast_nullable_to_non_nullable
              as String,
      geoName: null == geoName
          ? _value.geoName
          : geoName // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UpdateGeoDataParamsImplCopyWith<$Res>
    implements $UpdateGeoDataParamsCopyWith<$Res> {
  factory _$$UpdateGeoDataParamsImplCopyWith(_$UpdateGeoDataParamsImpl value,
          $Res Function(_$UpdateGeoDataParamsImpl) then) =
      __$$UpdateGeoDataParamsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'geo-type') String geoType,
      @JsonKey(name: 'geo-name') String geoName});
}

/// @nodoc
class __$$UpdateGeoDataParamsImplCopyWithImpl<$Res>
    extends _$UpdateGeoDataParamsCopyWithImpl<$Res, _$UpdateGeoDataParamsImpl>
    implements _$$UpdateGeoDataParamsImplCopyWith<$Res> {
  __$$UpdateGeoDataParamsImplCopyWithImpl(_$UpdateGeoDataParamsImpl _value,
      $Res Function(_$UpdateGeoDataParamsImpl) _then)
      : super(_value, _then);

  /// Create a copy of UpdateGeoDataParams
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? geoType = null,
    Object? geoName = null,
  }) {
    return _then(_$UpdateGeoDataParamsImpl(
      geoType: null == geoType
          ? _value.geoType
          : geoType // ignore: cast_nullable_to_non_nullable
              as String,
      geoName: null == geoName
          ? _value.geoName
          : geoName // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UpdateGeoDataParamsImpl implements _UpdateGeoDataParams {
  const _$UpdateGeoDataParamsImpl(
      {@JsonKey(name: 'geo-type') required this.geoType,
      @JsonKey(name: 'geo-name') required this.geoName});

  factory _$UpdateGeoDataParamsImpl.fromJson(Map<String, dynamic> json) =>
      _$$UpdateGeoDataParamsImplFromJson(json);

  @override
  @JsonKey(name: 'geo-type')
  final String geoType;
  @override
  @JsonKey(name: 'geo-name')
  final String geoName;

  @override
  String toString() {
    return 'UpdateGeoDataParams(geoType: $geoType, geoName: $geoName)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UpdateGeoDataParamsImpl &&
            (identical(other.geoType, geoType) || other.geoType == geoType) &&
            (identical(other.geoName, geoName) || other.geoName == geoName));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, geoType, geoName);

  /// Create a copy of UpdateGeoDataParams
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UpdateGeoDataParamsImplCopyWith<_$UpdateGeoDataParamsImpl> get copyWith =>
      __$$UpdateGeoDataParamsImplCopyWithImpl<_$UpdateGeoDataParamsImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UpdateGeoDataParamsImplToJson(
      this,
    );
  }
}

abstract class _UpdateGeoDataParams implements UpdateGeoDataParams {
  const factory _UpdateGeoDataParams(
          {@JsonKey(name: 'geo-type') required final String geoType,
          @JsonKey(name: 'geo-name') required final String geoName}) =
      _$UpdateGeoDataParamsImpl;

  factory _UpdateGeoDataParams.fromJson(Map<String, dynamic> json) =
      _$UpdateGeoDataParamsImpl.fromJson;

  @override
  @JsonKey(name: 'geo-type')
  String get geoType;
  @override
  @JsonKey(name: 'geo-name')
  String get geoName;

  /// Create a copy of UpdateGeoDataParams
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UpdateGeoDataParamsImplCopyWith<_$UpdateGeoDataParamsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AppMessage _$AppMessageFromJson(Map<String, dynamic> json) {
  return _AppMessage.fromJson(json);
}

/// @nodoc
mixin _$AppMessage {
  AppMessageType get type => throw _privateConstructorUsedError;
  dynamic get data => throw _privateConstructorUsedError;

  /// Serializes this AppMessage to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AppMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AppMessageCopyWith<AppMessage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AppMessageCopyWith<$Res> {
  factory $AppMessageCopyWith(
          AppMessage value, $Res Function(AppMessage) then) =
      _$AppMessageCopyWithImpl<$Res, AppMessage>;
  @useResult
  $Res call({AppMessageType type, dynamic data});
}

/// @nodoc
class _$AppMessageCopyWithImpl<$Res, $Val extends AppMessage>
    implements $AppMessageCopyWith<$Res> {
  _$AppMessageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AppMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? data = freezed,
  }) {
    return _then(_value.copyWith(
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as AppMessageType,
      data: freezed == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as dynamic,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AppMessageImplCopyWith<$Res>
    implements $AppMessageCopyWith<$Res> {
  factory _$$AppMessageImplCopyWith(
          _$AppMessageImpl value, $Res Function(_$AppMessageImpl) then) =
      __$$AppMessageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({AppMessageType type, dynamic data});
}

/// @nodoc
class __$$AppMessageImplCopyWithImpl<$Res>
    extends _$AppMessageCopyWithImpl<$Res, _$AppMessageImpl>
    implements _$$AppMessageImplCopyWith<$Res> {
  __$$AppMessageImplCopyWithImpl(
      _$AppMessageImpl _value, $Res Function(_$AppMessageImpl) _then)
      : super(_value, _then);

  /// Create a copy of AppMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? data = freezed,
  }) {
    return _then(_$AppMessageImpl(
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as AppMessageType,
      data: freezed == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as dynamic,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AppMessageImpl implements _AppMessage {
  const _$AppMessageImpl({required this.type, this.data});

  factory _$AppMessageImpl.fromJson(Map<String, dynamic> json) =>
      _$$AppMessageImplFromJson(json);

  @override
  final AppMessageType type;
  @override
  final dynamic data;

  @override
  String toString() {
    return 'AppMessage(type: $type, data: $data)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AppMessageImpl &&
            (identical(other.type, type) || other.type == type) &&
            const DeepCollectionEquality().equals(other.data, data));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, type, const DeepCollectionEquality().hash(data));

  /// Create a copy of AppMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AppMessageImplCopyWith<_$AppMessageImpl> get copyWith =>
      __$$AppMessageImplCopyWithImpl<_$AppMessageImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AppMessageImplToJson(
      this,
    );
  }
}

abstract class _AppMessage implements AppMessage {
  const factory _AppMessage(
      {required final AppMessageType type,
      final dynamic data}) = _$AppMessageImpl;

  factory _AppMessage.fromJson(Map<String, dynamic> json) =
      _$AppMessageImpl.fromJson;

  @override
  AppMessageType get type;
  @override
  dynamic get data;

  /// Create a copy of AppMessage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AppMessageImplCopyWith<_$AppMessageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

InvokeMessage _$InvokeMessageFromJson(Map<String, dynamic> json) {
  return _InvokeMessage.fromJson(json);
}

/// @nodoc
mixin _$InvokeMessage {
  InvokeMessageType get type => throw _privateConstructorUsedError;
  dynamic get data => throw _privateConstructorUsedError;

  /// Serializes this InvokeMessage to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of InvokeMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $InvokeMessageCopyWith<InvokeMessage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $InvokeMessageCopyWith<$Res> {
  factory $InvokeMessageCopyWith(
          InvokeMessage value, $Res Function(InvokeMessage) then) =
      _$InvokeMessageCopyWithImpl<$Res, InvokeMessage>;
  @useResult
  $Res call({InvokeMessageType type, dynamic data});
}

/// @nodoc
class _$InvokeMessageCopyWithImpl<$Res, $Val extends InvokeMessage>
    implements $InvokeMessageCopyWith<$Res> {
  _$InvokeMessageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of InvokeMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? data = freezed,
  }) {
    return _then(_value.copyWith(
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as InvokeMessageType,
      data: freezed == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as dynamic,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$InvokeMessageImplCopyWith<$Res>
    implements $InvokeMessageCopyWith<$Res> {
  factory _$$InvokeMessageImplCopyWith(
          _$InvokeMessageImpl value, $Res Function(_$InvokeMessageImpl) then) =
      __$$InvokeMessageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({InvokeMessageType type, dynamic data});
}

/// @nodoc
class __$$InvokeMessageImplCopyWithImpl<$Res>
    extends _$InvokeMessageCopyWithImpl<$Res, _$InvokeMessageImpl>
    implements _$$InvokeMessageImplCopyWith<$Res> {
  __$$InvokeMessageImplCopyWithImpl(
      _$InvokeMessageImpl _value, $Res Function(_$InvokeMessageImpl) _then)
      : super(_value, _then);

  /// Create a copy of InvokeMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? data = freezed,
  }) {
    return _then(_$InvokeMessageImpl(
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as InvokeMessageType,
      data: freezed == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as dynamic,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$InvokeMessageImpl implements _InvokeMessage {
  const _$InvokeMessageImpl({required this.type, this.data});

  factory _$InvokeMessageImpl.fromJson(Map<String, dynamic> json) =>
      _$$InvokeMessageImplFromJson(json);

  @override
  final InvokeMessageType type;
  @override
  final dynamic data;

  @override
  String toString() {
    return 'InvokeMessage(type: $type, data: $data)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$InvokeMessageImpl &&
            (identical(other.type, type) || other.type == type) &&
            const DeepCollectionEquality().equals(other.data, data));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, type, const DeepCollectionEquality().hash(data));

  /// Create a copy of InvokeMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$InvokeMessageImplCopyWith<_$InvokeMessageImpl> get copyWith =>
      __$$InvokeMessageImplCopyWithImpl<_$InvokeMessageImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$InvokeMessageImplToJson(
      this,
    );
  }
}

abstract class _InvokeMessage implements InvokeMessage {
  const factory _InvokeMessage(
      {required final InvokeMessageType type,
      final dynamic data}) = _$InvokeMessageImpl;

  factory _InvokeMessage.fromJson(Map<String, dynamic> json) =
      _$InvokeMessageImpl.fromJson;

  @override
  InvokeMessageType get type;
  @override
  dynamic get data;

  /// Create a copy of InvokeMessage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$InvokeMessageImplCopyWith<_$InvokeMessageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Delay _$DelayFromJson(Map<String, dynamic> json) {
  return _Delay.fromJson(json);
}

/// @nodoc
mixin _$Delay {
  String get name => throw _privateConstructorUsedError;
  String get url => throw _privateConstructorUsedError;
  int? get value => throw _privateConstructorUsedError;

  /// Serializes this Delay to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Delay
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DelayCopyWith<Delay> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DelayCopyWith<$Res> {
  factory $DelayCopyWith(Delay value, $Res Function(Delay) then) =
      _$DelayCopyWithImpl<$Res, Delay>;
  @useResult
  $Res call({String name, String url, int? value});
}

/// @nodoc
class _$DelayCopyWithImpl<$Res, $Val extends Delay>
    implements $DelayCopyWith<$Res> {
  _$DelayCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Delay
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? url = null,
    Object? value = freezed,
  }) {
    return _then(_value.copyWith(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      url: null == url
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as String,
      value: freezed == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DelayImplCopyWith<$Res> implements $DelayCopyWith<$Res> {
  factory _$$DelayImplCopyWith(
          _$DelayImpl value, $Res Function(_$DelayImpl) then) =
      __$$DelayImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String name, String url, int? value});
}

/// @nodoc
class __$$DelayImplCopyWithImpl<$Res>
    extends _$DelayCopyWithImpl<$Res, _$DelayImpl>
    implements _$$DelayImplCopyWith<$Res> {
  __$$DelayImplCopyWithImpl(
      _$DelayImpl _value, $Res Function(_$DelayImpl) _then)
      : super(_value, _then);

  /// Create a copy of Delay
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? url = null,
    Object? value = freezed,
  }) {
    return _then(_$DelayImpl(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      url: null == url
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as String,
      value: freezed == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DelayImpl implements _Delay {
  const _$DelayImpl({required this.name, required this.url, this.value});

  factory _$DelayImpl.fromJson(Map<String, dynamic> json) =>
      _$$DelayImplFromJson(json);

  @override
  final String name;
  @override
  final String url;
  @override
  final int? value;

  @override
  String toString() {
    return 'Delay(name: $name, url: $url, value: $value)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DelayImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.url, url) || other.url == url) &&
            (identical(other.value, value) || other.value == value));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, name, url, value);

  /// Create a copy of Delay
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DelayImplCopyWith<_$DelayImpl> get copyWith =>
      __$$DelayImplCopyWithImpl<_$DelayImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DelayImplToJson(
      this,
    );
  }
}

abstract class _Delay implements Delay {
  const factory _Delay(
      {required final String name,
      required final String url,
      final int? value}) = _$DelayImpl;

  factory _Delay.fromJson(Map<String, dynamic> json) = _$DelayImpl.fromJson;

  @override
  String get name;
  @override
  String get url;
  @override
  int? get value;

  /// Create a copy of Delay
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DelayImplCopyWith<_$DelayImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Now _$NowFromJson(Map<String, dynamic> json) {
  return _Now.fromJson(json);
}

/// @nodoc
mixin _$Now {
  String get name => throw _privateConstructorUsedError;
  String get value => throw _privateConstructorUsedError;

  /// Serializes this Now to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Now
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $NowCopyWith<Now> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NowCopyWith<$Res> {
  factory $NowCopyWith(Now value, $Res Function(Now) then) =
      _$NowCopyWithImpl<$Res, Now>;
  @useResult
  $Res call({String name, String value});
}

/// @nodoc
class _$NowCopyWithImpl<$Res, $Val extends Now> implements $NowCopyWith<$Res> {
  _$NowCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Now
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? value = null,
  }) {
    return _then(_value.copyWith(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      value: null == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$NowImplCopyWith<$Res> implements $NowCopyWith<$Res> {
  factory _$$NowImplCopyWith(_$NowImpl value, $Res Function(_$NowImpl) then) =
      __$$NowImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String name, String value});
}

/// @nodoc
class __$$NowImplCopyWithImpl<$Res> extends _$NowCopyWithImpl<$Res, _$NowImpl>
    implements _$$NowImplCopyWith<$Res> {
  __$$NowImplCopyWithImpl(_$NowImpl _value, $Res Function(_$NowImpl) _then)
      : super(_value, _then);

  /// Create a copy of Now
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? value = null,
  }) {
    return _then(_$NowImpl(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      value: null == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$NowImpl implements _Now {
  const _$NowImpl({required this.name, required this.value});

  factory _$NowImpl.fromJson(Map<String, dynamic> json) =>
      _$$NowImplFromJson(json);

  @override
  final String name;
  @override
  final String value;

  @override
  String toString() {
    return 'Now(name: $name, value: $value)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NowImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.value, value) || other.value == value));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, name, value);

  /// Create a copy of Now
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NowImplCopyWith<_$NowImpl> get copyWith =>
      __$$NowImplCopyWithImpl<_$NowImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$NowImplToJson(
      this,
    );
  }
}

abstract class _Now implements Now {
  const factory _Now(
      {required final String name, required final String value}) = _$NowImpl;

  factory _Now.fromJson(Map<String, dynamic> json) = _$NowImpl.fromJson;

  @override
  String get name;
  @override
  String get value;

  /// Create a copy of Now
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NowImplCopyWith<_$NowImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ProviderSubscriptionInfo _$ProviderSubscriptionInfoFromJson(
    Map<String, dynamic> json) {
  return _ProviderSubscriptionInfo.fromJson(json);
}

/// @nodoc
mixin _$ProviderSubscriptionInfo {
  @JsonKey(name: 'UPLOAD')
  int get upload => throw _privateConstructorUsedError;
  @JsonKey(name: 'DOWNLOAD')
  int get download => throw _privateConstructorUsedError;
  @JsonKey(name: 'TOTAL')
  int get total => throw _privateConstructorUsedError;
  @JsonKey(name: 'EXPIRE')
  int get expire => throw _privateConstructorUsedError;

  /// Serializes this ProviderSubscriptionInfo to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ProviderSubscriptionInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProviderSubscriptionInfoCopyWith<ProviderSubscriptionInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProviderSubscriptionInfoCopyWith<$Res> {
  factory $ProviderSubscriptionInfoCopyWith(ProviderSubscriptionInfo value,
          $Res Function(ProviderSubscriptionInfo) then) =
      _$ProviderSubscriptionInfoCopyWithImpl<$Res, ProviderSubscriptionInfo>;
  @useResult
  $Res call(
      {@JsonKey(name: 'UPLOAD') int upload,
      @JsonKey(name: 'DOWNLOAD') int download,
      @JsonKey(name: 'TOTAL') int total,
      @JsonKey(name: 'EXPIRE') int expire});
}

/// @nodoc
class _$ProviderSubscriptionInfoCopyWithImpl<$Res,
        $Val extends ProviderSubscriptionInfo>
    implements $ProviderSubscriptionInfoCopyWith<$Res> {
  _$ProviderSubscriptionInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProviderSubscriptionInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? upload = null,
    Object? download = null,
    Object? total = null,
    Object? expire = null,
  }) {
    return _then(_value.copyWith(
      upload: null == upload
          ? _value.upload
          : upload // ignore: cast_nullable_to_non_nullable
              as int,
      download: null == download
          ? _value.download
          : download // ignore: cast_nullable_to_non_nullable
              as int,
      total: null == total
          ? _value.total
          : total // ignore: cast_nullable_to_non_nullable
              as int,
      expire: null == expire
          ? _value.expire
          : expire // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ProviderSubscriptionInfoImplCopyWith<$Res>
    implements $ProviderSubscriptionInfoCopyWith<$Res> {
  factory _$$ProviderSubscriptionInfoImplCopyWith(
          _$ProviderSubscriptionInfoImpl value,
          $Res Function(_$ProviderSubscriptionInfoImpl) then) =
      __$$ProviderSubscriptionInfoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'UPLOAD') int upload,
      @JsonKey(name: 'DOWNLOAD') int download,
      @JsonKey(name: 'TOTAL') int total,
      @JsonKey(name: 'EXPIRE') int expire});
}

/// @nodoc
class __$$ProviderSubscriptionInfoImplCopyWithImpl<$Res>
    extends _$ProviderSubscriptionInfoCopyWithImpl<$Res,
        _$ProviderSubscriptionInfoImpl>
    implements _$$ProviderSubscriptionInfoImplCopyWith<$Res> {
  __$$ProviderSubscriptionInfoImplCopyWithImpl(
      _$ProviderSubscriptionInfoImpl _value,
      $Res Function(_$ProviderSubscriptionInfoImpl) _then)
      : super(_value, _then);

  /// Create a copy of ProviderSubscriptionInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? upload = null,
    Object? download = null,
    Object? total = null,
    Object? expire = null,
  }) {
    return _then(_$ProviderSubscriptionInfoImpl(
      upload: null == upload
          ? _value.upload
          : upload // ignore: cast_nullable_to_non_nullable
              as int,
      download: null == download
          ? _value.download
          : download // ignore: cast_nullable_to_non_nullable
              as int,
      total: null == total
          ? _value.total
          : total // ignore: cast_nullable_to_non_nullable
              as int,
      expire: null == expire
          ? _value.expire
          : expire // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ProviderSubscriptionInfoImpl implements _ProviderSubscriptionInfo {
  const _$ProviderSubscriptionInfoImpl(
      {@JsonKey(name: 'UPLOAD') this.upload = 0,
      @JsonKey(name: 'DOWNLOAD') this.download = 0,
      @JsonKey(name: 'TOTAL') this.total = 0,
      @JsonKey(name: 'EXPIRE') this.expire = 0});

  factory _$ProviderSubscriptionInfoImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProviderSubscriptionInfoImplFromJson(json);

  @override
  @JsonKey(name: 'UPLOAD')
  final int upload;
  @override
  @JsonKey(name: 'DOWNLOAD')
  final int download;
  @override
  @JsonKey(name: 'TOTAL')
  final int total;
  @override
  @JsonKey(name: 'EXPIRE')
  final int expire;

  @override
  String toString() {
    return 'ProviderSubscriptionInfo(upload: $upload, download: $download, total: $total, expire: $expire)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProviderSubscriptionInfoImpl &&
            (identical(other.upload, upload) || other.upload == upload) &&
            (identical(other.download, download) ||
                other.download == download) &&
            (identical(other.total, total) || other.total == total) &&
            (identical(other.expire, expire) || other.expire == expire));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, upload, download, total, expire);

  /// Create a copy of ProviderSubscriptionInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProviderSubscriptionInfoImplCopyWith<_$ProviderSubscriptionInfoImpl>
      get copyWith => __$$ProviderSubscriptionInfoImplCopyWithImpl<
          _$ProviderSubscriptionInfoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ProviderSubscriptionInfoImplToJson(
      this,
    );
  }
}

abstract class _ProviderSubscriptionInfo implements ProviderSubscriptionInfo {
  const factory _ProviderSubscriptionInfo(
          {@JsonKey(name: 'UPLOAD') final int upload,
          @JsonKey(name: 'DOWNLOAD') final int download,
          @JsonKey(name: 'TOTAL') final int total,
          @JsonKey(name: 'EXPIRE') final int expire}) =
      _$ProviderSubscriptionInfoImpl;

  factory _ProviderSubscriptionInfo.fromJson(Map<String, dynamic> json) =
      _$ProviderSubscriptionInfoImpl.fromJson;

  @override
  @JsonKey(name: 'UPLOAD')
  int get upload;
  @override
  @JsonKey(name: 'DOWNLOAD')
  int get download;
  @override
  @JsonKey(name: 'TOTAL')
  int get total;
  @override
  @JsonKey(name: 'EXPIRE')
  int get expire;

  /// Create a copy of ProviderSubscriptionInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProviderSubscriptionInfoImplCopyWith<_$ProviderSubscriptionInfoImpl>
      get copyWith => throw _privateConstructorUsedError;
}

ExternalProvider _$ExternalProviderFromJson(Map<String, dynamic> json) {
  return _ExternalProvider.fromJson(json);
}

/// @nodoc
mixin _$ExternalProvider {
  String get name => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;
  String? get path => throw _privateConstructorUsedError;
  int get count => throw _privateConstructorUsedError;
  @JsonKey(name: 'subscription-info', fromJson: subscriptionInfoFormCore)
  SubscriptionInfo? get subscriptionInfo => throw _privateConstructorUsedError;
  bool get isUpdating => throw _privateConstructorUsedError;
  @JsonKey(name: 'vehicle-type')
  String get vehicleType => throw _privateConstructorUsedError;
  @JsonKey(name: 'update-at')
  DateTime get updateAt => throw _privateConstructorUsedError;

  /// Serializes this ExternalProvider to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ExternalProvider
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ExternalProviderCopyWith<ExternalProvider> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExternalProviderCopyWith<$Res> {
  factory $ExternalProviderCopyWith(
          ExternalProvider value, $Res Function(ExternalProvider) then) =
      _$ExternalProviderCopyWithImpl<$Res, ExternalProvider>;
  @useResult
  $Res call(
      {String name,
      String type,
      String? path,
      int count,
      @JsonKey(name: 'subscription-info', fromJson: subscriptionInfoFormCore)
      SubscriptionInfo? subscriptionInfo,
      bool isUpdating,
      @JsonKey(name: 'vehicle-type') String vehicleType,
      @JsonKey(name: 'update-at') DateTime updateAt});

  $SubscriptionInfoCopyWith<$Res>? get subscriptionInfo;
}

/// @nodoc
class _$ExternalProviderCopyWithImpl<$Res, $Val extends ExternalProvider>
    implements $ExternalProviderCopyWith<$Res> {
  _$ExternalProviderCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ExternalProvider
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? type = null,
    Object? path = freezed,
    Object? count = null,
    Object? subscriptionInfo = freezed,
    Object? isUpdating = null,
    Object? vehicleType = null,
    Object? updateAt = null,
  }) {
    return _then(_value.copyWith(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      path: freezed == path
          ? _value.path
          : path // ignore: cast_nullable_to_non_nullable
              as String?,
      count: null == count
          ? _value.count
          : count // ignore: cast_nullable_to_non_nullable
              as int,
      subscriptionInfo: freezed == subscriptionInfo
          ? _value.subscriptionInfo
          : subscriptionInfo // ignore: cast_nullable_to_non_nullable
              as SubscriptionInfo?,
      isUpdating: null == isUpdating
          ? _value.isUpdating
          : isUpdating // ignore: cast_nullable_to_non_nullable
              as bool,
      vehicleType: null == vehicleType
          ? _value.vehicleType
          : vehicleType // ignore: cast_nullable_to_non_nullable
              as String,
      updateAt: null == updateAt
          ? _value.updateAt
          : updateAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }

  /// Create a copy of ExternalProvider
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SubscriptionInfoCopyWith<$Res>? get subscriptionInfo {
    if (_value.subscriptionInfo == null) {
      return null;
    }

    return $SubscriptionInfoCopyWith<$Res>(_value.subscriptionInfo!, (value) {
      return _then(_value.copyWith(subscriptionInfo: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ExternalProviderImplCopyWith<$Res>
    implements $ExternalProviderCopyWith<$Res> {
  factory _$$ExternalProviderImplCopyWith(_$ExternalProviderImpl value,
          $Res Function(_$ExternalProviderImpl) then) =
      __$$ExternalProviderImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String name,
      String type,
      String? path,
      int count,
      @JsonKey(name: 'subscription-info', fromJson: subscriptionInfoFormCore)
      SubscriptionInfo? subscriptionInfo,
      bool isUpdating,
      @JsonKey(name: 'vehicle-type') String vehicleType,
      @JsonKey(name: 'update-at') DateTime updateAt});

  @override
  $SubscriptionInfoCopyWith<$Res>? get subscriptionInfo;
}

/// @nodoc
class __$$ExternalProviderImplCopyWithImpl<$Res>
    extends _$ExternalProviderCopyWithImpl<$Res, _$ExternalProviderImpl>
    implements _$$ExternalProviderImplCopyWith<$Res> {
  __$$ExternalProviderImplCopyWithImpl(_$ExternalProviderImpl _value,
      $Res Function(_$ExternalProviderImpl) _then)
      : super(_value, _then);

  /// Create a copy of ExternalProvider
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? type = null,
    Object? path = freezed,
    Object? count = null,
    Object? subscriptionInfo = freezed,
    Object? isUpdating = null,
    Object? vehicleType = null,
    Object? updateAt = null,
  }) {
    return _then(_$ExternalProviderImpl(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      path: freezed == path
          ? _value.path
          : path // ignore: cast_nullable_to_non_nullable
              as String?,
      count: null == count
          ? _value.count
          : count // ignore: cast_nullable_to_non_nullable
              as int,
      subscriptionInfo: freezed == subscriptionInfo
          ? _value.subscriptionInfo
          : subscriptionInfo // ignore: cast_nullable_to_non_nullable
              as SubscriptionInfo?,
      isUpdating: null == isUpdating
          ? _value.isUpdating
          : isUpdating // ignore: cast_nullable_to_non_nullable
              as bool,
      vehicleType: null == vehicleType
          ? _value.vehicleType
          : vehicleType // ignore: cast_nullable_to_non_nullable
              as String,
      updateAt: null == updateAt
          ? _value.updateAt
          : updateAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ExternalProviderImpl implements _ExternalProvider {
  const _$ExternalProviderImpl(
      {required this.name,
      required this.type,
      this.path,
      required this.count,
      @JsonKey(name: 'subscription-info', fromJson: subscriptionInfoFormCore)
      this.subscriptionInfo,
      this.isUpdating = false,
      @JsonKey(name: 'vehicle-type') required this.vehicleType,
      @JsonKey(name: 'update-at') required this.updateAt});

  factory _$ExternalProviderImpl.fromJson(Map<String, dynamic> json) =>
      _$$ExternalProviderImplFromJson(json);

  @override
  final String name;
  @override
  final String type;
  @override
  final String? path;
  @override
  final int count;
  @override
  @JsonKey(name: 'subscription-info', fromJson: subscriptionInfoFormCore)
  final SubscriptionInfo? subscriptionInfo;
  @override
  @JsonKey()
  final bool isUpdating;
  @override
  @JsonKey(name: 'vehicle-type')
  final String vehicleType;
  @override
  @JsonKey(name: 'update-at')
  final DateTime updateAt;

  @override
  String toString() {
    return 'ExternalProvider(name: $name, type: $type, path: $path, count: $count, subscriptionInfo: $subscriptionInfo, isUpdating: $isUpdating, vehicleType: $vehicleType, updateAt: $updateAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExternalProviderImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.path, path) || other.path == path) &&
            (identical(other.count, count) || other.count == count) &&
            (identical(other.subscriptionInfo, subscriptionInfo) ||
                other.subscriptionInfo == subscriptionInfo) &&
            (identical(other.isUpdating, isUpdating) ||
                other.isUpdating == isUpdating) &&
            (identical(other.vehicleType, vehicleType) ||
                other.vehicleType == vehicleType) &&
            (identical(other.updateAt, updateAt) ||
                other.updateAt == updateAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, name, type, path, count,
      subscriptionInfo, isUpdating, vehicleType, updateAt);

  /// Create a copy of ExternalProvider
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ExternalProviderImplCopyWith<_$ExternalProviderImpl> get copyWith =>
      __$$ExternalProviderImplCopyWithImpl<_$ExternalProviderImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ExternalProviderImplToJson(
      this,
    );
  }
}

abstract class _ExternalProvider implements ExternalProvider {
  const factory _ExternalProvider(
      {required final String name,
      required final String type,
      final String? path,
      required final int count,
      @JsonKey(name: 'subscription-info', fromJson: subscriptionInfoFormCore)
      final SubscriptionInfo? subscriptionInfo,
      final bool isUpdating,
      @JsonKey(name: 'vehicle-type') required final String vehicleType,
      @JsonKey(name: 'update-at')
      required final DateTime updateAt}) = _$ExternalProviderImpl;

  factory _ExternalProvider.fromJson(Map<String, dynamic> json) =
      _$ExternalProviderImpl.fromJson;

  @override
  String get name;
  @override
  String get type;
  @override
  String? get path;
  @override
  int get count;
  @override
  @JsonKey(name: 'subscription-info', fromJson: subscriptionInfoFormCore)
  SubscriptionInfo? get subscriptionInfo;
  @override
  bool get isUpdating;
  @override
  @JsonKey(name: 'vehicle-type')
  String get vehicleType;
  @override
  @JsonKey(name: 'update-at')
  DateTime get updateAt;

  /// Create a copy of ExternalProvider
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ExternalProviderImplCopyWith<_$ExternalProviderImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Action _$ActionFromJson(Map<String, dynamic> json) {
  return _Action.fromJson(json);
}

/// @nodoc
mixin _$Action {
  ActionMethod get method => throw _privateConstructorUsedError;
  dynamic get data => throw _privateConstructorUsedError;
  String get id => throw _privateConstructorUsedError;

  /// Serializes this Action to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Action
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ActionCopyWith<Action> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ActionCopyWith<$Res> {
  factory $ActionCopyWith(Action value, $Res Function(Action) then) =
      _$ActionCopyWithImpl<$Res, Action>;
  @useResult
  $Res call({ActionMethod method, dynamic data, String id});
}

/// @nodoc
class _$ActionCopyWithImpl<$Res, $Val extends Action>
    implements $ActionCopyWith<$Res> {
  _$ActionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Action
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? method = null,
    Object? data = freezed,
    Object? id = null,
  }) {
    return _then(_value.copyWith(
      method: null == method
          ? _value.method
          : method // ignore: cast_nullable_to_non_nullable
              as ActionMethod,
      data: freezed == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as dynamic,
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ActionImplCopyWith<$Res> implements $ActionCopyWith<$Res> {
  factory _$$ActionImplCopyWith(
          _$ActionImpl value, $Res Function(_$ActionImpl) then) =
      __$$ActionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({ActionMethod method, dynamic data, String id});
}

/// @nodoc
class __$$ActionImplCopyWithImpl<$Res>
    extends _$ActionCopyWithImpl<$Res, _$ActionImpl>
    implements _$$ActionImplCopyWith<$Res> {
  __$$ActionImplCopyWithImpl(
      _$ActionImpl _value, $Res Function(_$ActionImpl) _then)
      : super(_value, _then);

  /// Create a copy of Action
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? method = null,
    Object? data = freezed,
    Object? id = null,
  }) {
    return _then(_$ActionImpl(
      method: null == method
          ? _value.method
          : method // ignore: cast_nullable_to_non_nullable
              as ActionMethod,
      data: freezed == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as dynamic,
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ActionImpl implements _Action {
  const _$ActionImpl(
      {required this.method, required this.data, required this.id});

  factory _$ActionImpl.fromJson(Map<String, dynamic> json) =>
      _$$ActionImplFromJson(json);

  @override
  final ActionMethod method;
  @override
  final dynamic data;
  @override
  final String id;

  @override
  String toString() {
    return 'Action(method: $method, data: $data, id: $id)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ActionImpl &&
            (identical(other.method, method) || other.method == method) &&
            const DeepCollectionEquality().equals(other.data, data) &&
            (identical(other.id, id) || other.id == id));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, method, const DeepCollectionEquality().hash(data), id);

  /// Create a copy of Action
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ActionImplCopyWith<_$ActionImpl> get copyWith =>
      __$$ActionImplCopyWithImpl<_$ActionImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ActionImplToJson(
      this,
    );
  }
}

abstract class _Action implements Action {
  const factory _Action(
      {required final ActionMethod method,
      required final dynamic data,
      required final String id}) = _$ActionImpl;

  factory _Action.fromJson(Map<String, dynamic> json) = _$ActionImpl.fromJson;

  @override
  ActionMethod get method;
  @override
  dynamic get data;
  @override
  String get id;

  /// Create a copy of Action
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ActionImplCopyWith<_$ActionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ActionResult _$ActionResultFromJson(Map<String, dynamic> json) {
  return _ActionResult.fromJson(json);
}

/// @nodoc
mixin _$ActionResult {
  ActionMethod get method => throw _privateConstructorUsedError;
  dynamic get data => throw _privateConstructorUsedError;
  String? get id => throw _privateConstructorUsedError;
  ResultType get code => throw _privateConstructorUsedError;

  /// Serializes this ActionResult to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ActionResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ActionResultCopyWith<ActionResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ActionResultCopyWith<$Res> {
  factory $ActionResultCopyWith(
          ActionResult value, $Res Function(ActionResult) then) =
      _$ActionResultCopyWithImpl<$Res, ActionResult>;
  @useResult
  $Res call({ActionMethod method, dynamic data, String? id, ResultType code});
}

/// @nodoc
class _$ActionResultCopyWithImpl<$Res, $Val extends ActionResult>
    implements $ActionResultCopyWith<$Res> {
  _$ActionResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ActionResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? method = null,
    Object? data = freezed,
    Object? id = freezed,
    Object? code = null,
  }) {
    return _then(_value.copyWith(
      method: null == method
          ? _value.method
          : method // ignore: cast_nullable_to_non_nullable
              as ActionMethod,
      data: freezed == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as dynamic,
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      code: null == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as ResultType,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ActionResultImplCopyWith<$Res>
    implements $ActionResultCopyWith<$Res> {
  factory _$$ActionResultImplCopyWith(
          _$ActionResultImpl value, $Res Function(_$ActionResultImpl) then) =
      __$$ActionResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({ActionMethod method, dynamic data, String? id, ResultType code});
}

/// @nodoc
class __$$ActionResultImplCopyWithImpl<$Res>
    extends _$ActionResultCopyWithImpl<$Res, _$ActionResultImpl>
    implements _$$ActionResultImplCopyWith<$Res> {
  __$$ActionResultImplCopyWithImpl(
      _$ActionResultImpl _value, $Res Function(_$ActionResultImpl) _then)
      : super(_value, _then);

  /// Create a copy of ActionResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? method = null,
    Object? data = freezed,
    Object? id = freezed,
    Object? code = null,
  }) {
    return _then(_$ActionResultImpl(
      method: null == method
          ? _value.method
          : method // ignore: cast_nullable_to_non_nullable
              as ActionMethod,
      data: freezed == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as dynamic,
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      code: null == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as ResultType,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ActionResultImpl implements _ActionResult {
  const _$ActionResultImpl(
      {required this.method,
      required this.data,
      this.id,
      this.code = ResultType.success});

  factory _$ActionResultImpl.fromJson(Map<String, dynamic> json) =>
      _$$ActionResultImplFromJson(json);

  @override
  final ActionMethod method;
  @override
  final dynamic data;
  @override
  final String? id;
  @override
  @JsonKey()
  final ResultType code;

  @override
  String toString() {
    return 'ActionResult(method: $method, data: $data, id: $id, code: $code)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ActionResultImpl &&
            (identical(other.method, method) || other.method == method) &&
            const DeepCollectionEquality().equals(other.data, data) &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.code, code) || other.code == code));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, method, const DeepCollectionEquality().hash(data), id, code);

  /// Create a copy of ActionResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ActionResultImplCopyWith<_$ActionResultImpl> get copyWith =>
      __$$ActionResultImplCopyWithImpl<_$ActionResultImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ActionResultImplToJson(
      this,
    );
  }
}

abstract class _ActionResult implements ActionResult {
  const factory _ActionResult(
      {required final ActionMethod method,
      required final dynamic data,
      final String? id,
      final ResultType code}) = _$ActionResultImpl;

  factory _ActionResult.fromJson(Map<String, dynamic> json) =
      _$ActionResultImpl.fromJson;

  @override
  ActionMethod get method;
  @override
  dynamic get data;
  @override
  String? get id;
  @override
  ResultType get code;

  /// Create a copy of ActionResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ActionResultImplCopyWith<_$ActionResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
