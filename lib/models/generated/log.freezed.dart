// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../log.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

LogsAndKeywords _$LogsAndKeywordsFromJson(Map<String, dynamic> json) {
  return _LogsAndKeywords.fromJson(json);
}

/// @nodoc
mixin _$LogsAndKeywords {
  List<Log> get logs => throw _privateConstructorUsedError;
  List<String> get keywords => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $LogsAndKeywordsCopyWith<LogsAndKeywords> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LogsAndKeywordsCopyWith<$Res> {
  factory $LogsAndKeywordsCopyWith(
          LogsAndKeywords value, $Res Function(LogsAndKeywords) then) =
      _$LogsAndKeywordsCopyWithImpl<$Res, LogsAndKeywords>;
  @useResult
  $Res call({List<Log> logs, List<String> keywords});
}

/// @nodoc
class _$LogsAndKeywordsCopyWithImpl<$Res, $Val extends LogsAndKeywords>
    implements $LogsAndKeywordsCopyWith<$Res> {
  _$LogsAndKeywordsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? logs = null,
    Object? keywords = null,
  }) {
    return _then(_value.copyWith(
      logs: null == logs
          ? _value.logs
          : logs // ignore: cast_nullable_to_non_nullable
              as List<Log>,
      keywords: null == keywords
          ? _value.keywords
          : keywords // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LogsAndKeywordsImplCopyWith<$Res>
    implements $LogsAndKeywordsCopyWith<$Res> {
  factory _$$LogsAndKeywordsImplCopyWith(_$LogsAndKeywordsImpl value,
          $Res Function(_$LogsAndKeywordsImpl) then) =
      __$$LogsAndKeywordsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<Log> logs, List<String> keywords});
}

/// @nodoc
class __$$LogsAndKeywordsImplCopyWithImpl<$Res>
    extends _$LogsAndKeywordsCopyWithImpl<$Res, _$LogsAndKeywordsImpl>
    implements _$$LogsAndKeywordsImplCopyWith<$Res> {
  __$$LogsAndKeywordsImplCopyWithImpl(
      _$LogsAndKeywordsImpl _value, $Res Function(_$LogsAndKeywordsImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? logs = null,
    Object? keywords = null,
  }) {
    return _then(_$LogsAndKeywordsImpl(
      logs: null == logs
          ? _value._logs
          : logs // ignore: cast_nullable_to_non_nullable
              as List<Log>,
      keywords: null == keywords
          ? _value._keywords
          : keywords // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LogsAndKeywordsImpl implements _LogsAndKeywords {
  const _$LogsAndKeywordsImpl(
      {final List<Log> logs = const [], final List<String> keywords = const []})
      : _logs = logs,
        _keywords = keywords;

  factory _$LogsAndKeywordsImpl.fromJson(Map<String, dynamic> json) =>
      _$$LogsAndKeywordsImplFromJson(json);

  final List<Log> _logs;
  @override
  @JsonKey()
  List<Log> get logs {
    if (_logs is EqualUnmodifiableListView) return _logs;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_logs);
  }

  final List<String> _keywords;
  @override
  @JsonKey()
  List<String> get keywords {
    if (_keywords is EqualUnmodifiableListView) return _keywords;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_keywords);
  }

  @override
  String toString() {
    return 'LogsAndKeywords(logs: $logs, keywords: $keywords)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LogsAndKeywordsImpl &&
            const DeepCollectionEquality().equals(other._logs, _logs) &&
            const DeepCollectionEquality().equals(other._keywords, _keywords));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_logs),
      const DeepCollectionEquality().hash(_keywords));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$LogsAndKeywordsImplCopyWith<_$LogsAndKeywordsImpl> get copyWith =>
      __$$LogsAndKeywordsImplCopyWithImpl<_$LogsAndKeywordsImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LogsAndKeywordsImplToJson(
      this,
    );
  }
}

abstract class _LogsAndKeywords implements LogsAndKeywords {
  const factory _LogsAndKeywords(
      {final List<Log> logs,
      final List<String> keywords}) = _$LogsAndKeywordsImpl;

  factory _LogsAndKeywords.fromJson(Map<String, dynamic> json) =
      _$LogsAndKeywordsImpl.fromJson;

  @override
  List<Log> get logs;
  @override
  List<String> get keywords;
  @override
  @JsonKey(ignore: true)
  _$$LogsAndKeywordsImplCopyWith<_$LogsAndKeywordsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
