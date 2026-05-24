// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ocr_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$OcrState {
  OcrStatus get status => throw _privateConstructorUsedError;
  ScanResult? get result => throw _privateConstructorUsedError;
  String? get errorMessage => throw _privateConstructorUsedError;
  double get progress => throw _privateConstructorUsedError;

  /// Create a copy of OcrState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OcrStateCopyWith<OcrState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OcrStateCopyWith<$Res> {
  factory $OcrStateCopyWith(OcrState value, $Res Function(OcrState) then) =
      _$OcrStateCopyWithImpl<$Res, OcrState>;
  @useResult
  $Res call(
      {OcrStatus status,
      ScanResult? result,
      String? errorMessage,
      double progress});

  $ScanResultCopyWith<$Res>? get result;
}

/// @nodoc
class _$OcrStateCopyWithImpl<$Res, $Val extends OcrState>
    implements $OcrStateCopyWith<$Res> {
  _$OcrStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OcrState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
    Object? result = freezed,
    Object? errorMessage = freezed,
    Object? progress = null,
  }) {
    return _then(_value.copyWith(
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as OcrStatus,
      result: freezed == result
          ? _value.result
          : result // ignore: cast_nullable_to_non_nullable
              as ScanResult?,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      progress: null == progress
          ? _value.progress
          : progress // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }

  /// Create a copy of OcrState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ScanResultCopyWith<$Res>? get result {
    if (_value.result == null) {
      return null;
    }

    return $ScanResultCopyWith<$Res>(_value.result!, (value) {
      return _then(_value.copyWith(result: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$OcrStateImplCopyWith<$Res>
    implements $OcrStateCopyWith<$Res> {
  factory _$$OcrStateImplCopyWith(
          _$OcrStateImpl value, $Res Function(_$OcrStateImpl) then) =
      __$$OcrStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {OcrStatus status,
      ScanResult? result,
      String? errorMessage,
      double progress});

  @override
  $ScanResultCopyWith<$Res>? get result;
}

/// @nodoc
class __$$OcrStateImplCopyWithImpl<$Res>
    extends _$OcrStateCopyWithImpl<$Res, _$OcrStateImpl>
    implements _$$OcrStateImplCopyWith<$Res> {
  __$$OcrStateImplCopyWithImpl(
      _$OcrStateImpl _value, $Res Function(_$OcrStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of OcrState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
    Object? result = freezed,
    Object? errorMessage = freezed,
    Object? progress = null,
  }) {
    return _then(_$OcrStateImpl(
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as OcrStatus,
      result: freezed == result
          ? _value.result
          : result // ignore: cast_nullable_to_non_nullable
              as ScanResult?,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      progress: null == progress
          ? _value.progress
          : progress // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc

class _$OcrStateImpl implements _OcrState {
  const _$OcrStateImpl(
      {this.status = OcrStatus.idle,
      this.result,
      this.errorMessage,
      this.progress = 0.0});

  @override
  @JsonKey()
  final OcrStatus status;
  @override
  final ScanResult? result;
  @override
  final String? errorMessage;
  @override
  @JsonKey()
  final double progress;

  @override
  String toString() {
    return 'OcrState(status: $status, result: $result, errorMessage: $errorMessage, progress: $progress)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OcrStateImpl &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.result, result) || other.result == result) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage) &&
            (identical(other.progress, progress) ||
                other.progress == progress));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, status, result, errorMessage, progress);

  /// Create a copy of OcrState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OcrStateImplCopyWith<_$OcrStateImpl> get copyWith =>
      __$$OcrStateImplCopyWithImpl<_$OcrStateImpl>(this, _$identity);
}

abstract class _OcrState implements OcrState {
  const factory _OcrState(
      {final OcrStatus status,
      final ScanResult? result,
      final String? errorMessage,
      final double progress}) = _$OcrStateImpl;

  @override
  OcrStatus get status;
  @override
  ScanResult? get result;
  @override
  String? get errorMessage;
  @override
  double get progress;

  /// Create a copy of OcrState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OcrStateImplCopyWith<_$OcrStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
