// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../widget.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$ActivateState {
  bool get active => throw _privateConstructorUsedError;

  /// Create a copy of ActivateState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ActivateStateCopyWith<ActivateState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ActivateStateCopyWith<$Res> {
  factory $ActivateStateCopyWith(
          ActivateState value, $Res Function(ActivateState) then) =
      _$ActivateStateCopyWithImpl<$Res, ActivateState>;
  @useResult
  $Res call({bool active});
}

/// @nodoc
class _$ActivateStateCopyWithImpl<$Res, $Val extends ActivateState>
    implements $ActivateStateCopyWith<$Res> {
  _$ActivateStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ActivateState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? active = null,
  }) {
    return _then(_value.copyWith(
      active: null == active
          ? _value.active
          : active // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ActivateStateImplCopyWith<$Res>
    implements $ActivateStateCopyWith<$Res> {
  factory _$$ActivateStateImplCopyWith(
          _$ActivateStateImpl value, $Res Function(_$ActivateStateImpl) then) =
      __$$ActivateStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool active});
}

/// @nodoc
class __$$ActivateStateImplCopyWithImpl<$Res>
    extends _$ActivateStateCopyWithImpl<$Res, _$ActivateStateImpl>
    implements _$$ActivateStateImplCopyWith<$Res> {
  __$$ActivateStateImplCopyWithImpl(
      _$ActivateStateImpl _value, $Res Function(_$ActivateStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of ActivateState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? active = null,
  }) {
    return _then(_$ActivateStateImpl(
      active: null == active
          ? _value.active
          : active // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$ActivateStateImpl implements _ActivateState {
  const _$ActivateStateImpl({required this.active});

  @override
  final bool active;

  @override
  String toString() {
    return 'ActivateState(active: $active)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ActivateStateImpl &&
            (identical(other.active, active) || other.active == active));
  }

  @override
  int get hashCode => Object.hash(runtimeType, active);

  /// Create a copy of ActivateState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ActivateStateImplCopyWith<_$ActivateStateImpl> get copyWith =>
      __$$ActivateStateImplCopyWithImpl<_$ActivateStateImpl>(this, _$identity);
}

abstract class _ActivateState implements ActivateState {
  const factory _ActivateState({required final bool active}) =
      _$ActivateStateImpl;

  @override
  bool get active;

  /// Create a copy of ActivateState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ActivateStateImplCopyWith<_$ActivateStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$CommonMessage {
  String get id => throw _privateConstructorUsedError;
  String get text => throw _privateConstructorUsedError;
  Duration get duration => throw _privateConstructorUsedError;

  /// Create a copy of CommonMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CommonMessageCopyWith<CommonMessage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CommonMessageCopyWith<$Res> {
  factory $CommonMessageCopyWith(
          CommonMessage value, $Res Function(CommonMessage) then) =
      _$CommonMessageCopyWithImpl<$Res, CommonMessage>;
  @useResult
  $Res call({String id, String text, Duration duration});
}

/// @nodoc
class _$CommonMessageCopyWithImpl<$Res, $Val extends CommonMessage>
    implements $CommonMessageCopyWith<$Res> {
  _$CommonMessageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CommonMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? text = null,
    Object? duration = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      text: null == text
          ? _value.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
      duration: null == duration
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as Duration,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CommonMessageImplCopyWith<$Res>
    implements $CommonMessageCopyWith<$Res> {
  factory _$$CommonMessageImplCopyWith(
          _$CommonMessageImpl value, $Res Function(_$CommonMessageImpl) then) =
      __$$CommonMessageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String text, Duration duration});
}

/// @nodoc
class __$$CommonMessageImplCopyWithImpl<$Res>
    extends _$CommonMessageCopyWithImpl<$Res, _$CommonMessageImpl>
    implements _$$CommonMessageImplCopyWith<$Res> {
  __$$CommonMessageImplCopyWithImpl(
      _$CommonMessageImpl _value, $Res Function(_$CommonMessageImpl) _then)
      : super(_value, _then);

  /// Create a copy of CommonMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? text = null,
    Object? duration = null,
  }) {
    return _then(_$CommonMessageImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      text: null == text
          ? _value.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
      duration: null == duration
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as Duration,
    ));
  }
}

/// @nodoc

class _$CommonMessageImpl implements _CommonMessage {
  const _$CommonMessageImpl(
      {required this.id,
      required this.text,
      this.duration = const Duration(seconds: 3)});

  @override
  final String id;
  @override
  final String text;
  @override
  @JsonKey()
  final Duration duration;

  @override
  String toString() {
    return 'CommonMessage(id: $id, text: $text, duration: $duration)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CommonMessageImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.text, text) || other.text == text) &&
            (identical(other.duration, duration) ||
                other.duration == duration));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, text, duration);

  /// Create a copy of CommonMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CommonMessageImplCopyWith<_$CommonMessageImpl> get copyWith =>
      __$$CommonMessageImplCopyWithImpl<_$CommonMessageImpl>(this, _$identity);
}

abstract class _CommonMessage implements CommonMessage {
  const factory _CommonMessage(
      {required final String id,
      required final String text,
      final Duration duration}) = _$CommonMessageImpl;

  @override
  String get id;
  @override
  String get text;
  @override
  Duration get duration;

  /// Create a copy of CommonMessage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CommonMessageImplCopyWith<_$CommonMessageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$AppBarState {
  List<Widget> get actions => throw _privateConstructorUsedError;
  AppBarSearchState? get searchState => throw _privateConstructorUsedError;
  AppBarEditState? get editState => throw _privateConstructorUsedError;

  /// Create a copy of AppBarState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AppBarStateCopyWith<AppBarState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AppBarStateCopyWith<$Res> {
  factory $AppBarStateCopyWith(
          AppBarState value, $Res Function(AppBarState) then) =
      _$AppBarStateCopyWithImpl<$Res, AppBarState>;
  @useResult
  $Res call(
      {List<Widget> actions,
      AppBarSearchState? searchState,
      AppBarEditState? editState});

  $AppBarSearchStateCopyWith<$Res>? get searchState;
  $AppBarEditStateCopyWith<$Res>? get editState;
}

/// @nodoc
class _$AppBarStateCopyWithImpl<$Res, $Val extends AppBarState>
    implements $AppBarStateCopyWith<$Res> {
  _$AppBarStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AppBarState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? actions = null,
    Object? searchState = freezed,
    Object? editState = freezed,
  }) {
    return _then(_value.copyWith(
      actions: null == actions
          ? _value.actions
          : actions // ignore: cast_nullable_to_non_nullable
              as List<Widget>,
      searchState: freezed == searchState
          ? _value.searchState
          : searchState // ignore: cast_nullable_to_non_nullable
              as AppBarSearchState?,
      editState: freezed == editState
          ? _value.editState
          : editState // ignore: cast_nullable_to_non_nullable
              as AppBarEditState?,
    ) as $Val);
  }

  /// Create a copy of AppBarState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AppBarSearchStateCopyWith<$Res>? get searchState {
    if (_value.searchState == null) {
      return null;
    }

    return $AppBarSearchStateCopyWith<$Res>(_value.searchState!, (value) {
      return _then(_value.copyWith(searchState: value) as $Val);
    });
  }

  /// Create a copy of AppBarState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AppBarEditStateCopyWith<$Res>? get editState {
    if (_value.editState == null) {
      return null;
    }

    return $AppBarEditStateCopyWith<$Res>(_value.editState!, (value) {
      return _then(_value.copyWith(editState: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$AppBarStateImplCopyWith<$Res>
    implements $AppBarStateCopyWith<$Res> {
  factory _$$AppBarStateImplCopyWith(
          _$AppBarStateImpl value, $Res Function(_$AppBarStateImpl) then) =
      __$$AppBarStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<Widget> actions,
      AppBarSearchState? searchState,
      AppBarEditState? editState});

  @override
  $AppBarSearchStateCopyWith<$Res>? get searchState;
  @override
  $AppBarEditStateCopyWith<$Res>? get editState;
}

/// @nodoc
class __$$AppBarStateImplCopyWithImpl<$Res>
    extends _$AppBarStateCopyWithImpl<$Res, _$AppBarStateImpl>
    implements _$$AppBarStateImplCopyWith<$Res> {
  __$$AppBarStateImplCopyWithImpl(
      _$AppBarStateImpl _value, $Res Function(_$AppBarStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of AppBarState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? actions = null,
    Object? searchState = freezed,
    Object? editState = freezed,
  }) {
    return _then(_$AppBarStateImpl(
      actions: null == actions
          ? _value._actions
          : actions // ignore: cast_nullable_to_non_nullable
              as List<Widget>,
      searchState: freezed == searchState
          ? _value.searchState
          : searchState // ignore: cast_nullable_to_non_nullable
              as AppBarSearchState?,
      editState: freezed == editState
          ? _value.editState
          : editState // ignore: cast_nullable_to_non_nullable
              as AppBarEditState?,
    ));
  }
}

/// @nodoc

class _$AppBarStateImpl implements _AppBarState {
  const _$AppBarStateImpl(
      {final List<Widget> actions = const [], this.searchState, this.editState})
      : _actions = actions;

  final List<Widget> _actions;
  @override
  @JsonKey()
  List<Widget> get actions {
    if (_actions is EqualUnmodifiableListView) return _actions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_actions);
  }

  @override
  final AppBarSearchState? searchState;
  @override
  final AppBarEditState? editState;

  @override
  String toString() {
    return 'AppBarState(actions: $actions, searchState: $searchState, editState: $editState)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AppBarStateImpl &&
            const DeepCollectionEquality().equals(other._actions, _actions) &&
            (identical(other.searchState, searchState) ||
                other.searchState == searchState) &&
            (identical(other.editState, editState) ||
                other.editState == editState));
  }

  @override
  int get hashCode => Object.hash(runtimeType,
      const DeepCollectionEquality().hash(_actions), searchState, editState);

  /// Create a copy of AppBarState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AppBarStateImplCopyWith<_$AppBarStateImpl> get copyWith =>
      __$$AppBarStateImplCopyWithImpl<_$AppBarStateImpl>(this, _$identity);
}

abstract class _AppBarState implements AppBarState {
  const factory _AppBarState(
      {final List<Widget> actions,
      final AppBarSearchState? searchState,
      final AppBarEditState? editState}) = _$AppBarStateImpl;

  @override
  List<Widget> get actions;
  @override
  AppBarSearchState? get searchState;
  @override
  AppBarEditState? get editState;

  /// Create a copy of AppBarState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AppBarStateImplCopyWith<_$AppBarStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$AppBarSearchState {
  dynamic Function(String) get onSearch => throw _privateConstructorUsedError;
  String? get query => throw _privateConstructorUsedError;

  /// Create a copy of AppBarSearchState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AppBarSearchStateCopyWith<AppBarSearchState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AppBarSearchStateCopyWith<$Res> {
  factory $AppBarSearchStateCopyWith(
          AppBarSearchState value, $Res Function(AppBarSearchState) then) =
      _$AppBarSearchStateCopyWithImpl<$Res, AppBarSearchState>;
  @useResult
  $Res call({dynamic Function(String) onSearch, String? query});
}

/// @nodoc
class _$AppBarSearchStateCopyWithImpl<$Res, $Val extends AppBarSearchState>
    implements $AppBarSearchStateCopyWith<$Res> {
  _$AppBarSearchStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AppBarSearchState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? onSearch = null,
    Object? query = freezed,
  }) {
    return _then(_value.copyWith(
      onSearch: null == onSearch
          ? _value.onSearch
          : onSearch // ignore: cast_nullable_to_non_nullable
              as dynamic Function(String),
      query: freezed == query
          ? _value.query
          : query // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AppBarSearchStateImplCopyWith<$Res>
    implements $AppBarSearchStateCopyWith<$Res> {
  factory _$$AppBarSearchStateImplCopyWith(_$AppBarSearchStateImpl value,
          $Res Function(_$AppBarSearchStateImpl) then) =
      __$$AppBarSearchStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({dynamic Function(String) onSearch, String? query});
}

/// @nodoc
class __$$AppBarSearchStateImplCopyWithImpl<$Res>
    extends _$AppBarSearchStateCopyWithImpl<$Res, _$AppBarSearchStateImpl>
    implements _$$AppBarSearchStateImplCopyWith<$Res> {
  __$$AppBarSearchStateImplCopyWithImpl(_$AppBarSearchStateImpl _value,
      $Res Function(_$AppBarSearchStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of AppBarSearchState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? onSearch = null,
    Object? query = freezed,
  }) {
    return _then(_$AppBarSearchStateImpl(
      onSearch: null == onSearch
          ? _value.onSearch
          : onSearch // ignore: cast_nullable_to_non_nullable
              as dynamic Function(String),
      query: freezed == query
          ? _value.query
          : query // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$AppBarSearchStateImpl implements _AppBarSearchState {
  const _$AppBarSearchStateImpl({required this.onSearch, this.query = null});

  @override
  final dynamic Function(String) onSearch;
  @override
  @JsonKey()
  final String? query;

  @override
  String toString() {
    return 'AppBarSearchState(onSearch: $onSearch, query: $query)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AppBarSearchStateImpl &&
            (identical(other.onSearch, onSearch) ||
                other.onSearch == onSearch) &&
            (identical(other.query, query) || other.query == query));
  }

  @override
  int get hashCode => Object.hash(runtimeType, onSearch, query);

  /// Create a copy of AppBarSearchState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AppBarSearchStateImplCopyWith<_$AppBarSearchStateImpl> get copyWith =>
      __$$AppBarSearchStateImplCopyWithImpl<_$AppBarSearchStateImpl>(
          this, _$identity);
}

abstract class _AppBarSearchState implements AppBarSearchState {
  const factory _AppBarSearchState(
      {required final dynamic Function(String) onSearch,
      final String? query}) = _$AppBarSearchStateImpl;

  @override
  dynamic Function(String) get onSearch;
  @override
  String? get query;

  /// Create a copy of AppBarSearchState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AppBarSearchStateImplCopyWith<_$AppBarSearchStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$AppBarEditState {
  int get editCount => throw _privateConstructorUsedError;
  dynamic Function() get onExit => throw _privateConstructorUsedError;

  /// Create a copy of AppBarEditState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AppBarEditStateCopyWith<AppBarEditState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AppBarEditStateCopyWith<$Res> {
  factory $AppBarEditStateCopyWith(
          AppBarEditState value, $Res Function(AppBarEditState) then) =
      _$AppBarEditStateCopyWithImpl<$Res, AppBarEditState>;
  @useResult
  $Res call({int editCount, dynamic Function() onExit});
}

/// @nodoc
class _$AppBarEditStateCopyWithImpl<$Res, $Val extends AppBarEditState>
    implements $AppBarEditStateCopyWith<$Res> {
  _$AppBarEditStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AppBarEditState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? editCount = null,
    Object? onExit = null,
  }) {
    return _then(_value.copyWith(
      editCount: null == editCount
          ? _value.editCount
          : editCount // ignore: cast_nullable_to_non_nullable
              as int,
      onExit: null == onExit
          ? _value.onExit
          : onExit // ignore: cast_nullable_to_non_nullable
              as dynamic Function(),
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AppBarEditStateImplCopyWith<$Res>
    implements $AppBarEditStateCopyWith<$Res> {
  factory _$$AppBarEditStateImplCopyWith(_$AppBarEditStateImpl value,
          $Res Function(_$AppBarEditStateImpl) then) =
      __$$AppBarEditStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int editCount, dynamic Function() onExit});
}

/// @nodoc
class __$$AppBarEditStateImplCopyWithImpl<$Res>
    extends _$AppBarEditStateCopyWithImpl<$Res, _$AppBarEditStateImpl>
    implements _$$AppBarEditStateImplCopyWith<$Res> {
  __$$AppBarEditStateImplCopyWithImpl(
      _$AppBarEditStateImpl _value, $Res Function(_$AppBarEditStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of AppBarEditState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? editCount = null,
    Object? onExit = null,
  }) {
    return _then(_$AppBarEditStateImpl(
      editCount: null == editCount
          ? _value.editCount
          : editCount // ignore: cast_nullable_to_non_nullable
              as int,
      onExit: null == onExit
          ? _value.onExit
          : onExit // ignore: cast_nullable_to_non_nullable
              as dynamic Function(),
    ));
  }
}

/// @nodoc

class _$AppBarEditStateImpl implements _AppBarEditState {
  const _$AppBarEditStateImpl({this.editCount = 0, required this.onExit});

  @override
  @JsonKey()
  final int editCount;
  @override
  final dynamic Function() onExit;

  @override
  String toString() {
    return 'AppBarEditState(editCount: $editCount, onExit: $onExit)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AppBarEditStateImpl &&
            (identical(other.editCount, editCount) ||
                other.editCount == editCount) &&
            (identical(other.onExit, onExit) || other.onExit == onExit));
  }

  @override
  int get hashCode => Object.hash(runtimeType, editCount, onExit);

  /// Create a copy of AppBarEditState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AppBarEditStateImplCopyWith<_$AppBarEditStateImpl> get copyWith =>
      __$$AppBarEditStateImplCopyWithImpl<_$AppBarEditStateImpl>(
          this, _$identity);
}

abstract class _AppBarEditState implements AppBarEditState {
  const factory _AppBarEditState(
      {final int editCount,
      required final dynamic Function() onExit}) = _$AppBarEditStateImpl;

  @override
  int get editCount;
  @override
  dynamic Function() get onExit;

  /// Create a copy of AppBarEditState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AppBarEditStateImplCopyWith<_$AppBarEditStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
