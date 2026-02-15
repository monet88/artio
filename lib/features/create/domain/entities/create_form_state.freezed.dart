// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'create_form_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

CreateFormState _$CreateFormStateFromJson(Map<String, dynamic> json) {
  return _CreateFormState.fromJson(json);
}

/// @nodoc
mixin _$CreateFormState {
  String get prompt => throw _privateConstructorUsedError;
  String get negativePrompt => throw _privateConstructorUsedError;
  String get aspectRatio => throw _privateConstructorUsedError;
  int get imageCount => throw _privateConstructorUsedError;
  String get outputFormat => throw _privateConstructorUsedError;
  String get modelId => throw _privateConstructorUsedError;

  /// Serializes this CreateFormState to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CreateFormState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CreateFormStateCopyWith<CreateFormState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CreateFormStateCopyWith<$Res> {
  factory $CreateFormStateCopyWith(
    CreateFormState value,
    $Res Function(CreateFormState) then,
  ) = _$CreateFormStateCopyWithImpl<$Res, CreateFormState>;
  @useResult
  $Res call({
    String prompt,
    String negativePrompt,
    String aspectRatio,
    int imageCount,
    String outputFormat,
    String modelId,
  });
}

/// @nodoc
class _$CreateFormStateCopyWithImpl<$Res, $Val extends CreateFormState>
    implements $CreateFormStateCopyWith<$Res> {
  _$CreateFormStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CreateFormState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? prompt = null,
    Object? negativePrompt = null,
    Object? aspectRatio = null,
    Object? imageCount = null,
    Object? outputFormat = null,
    Object? modelId = null,
  }) {
    return _then(
      _value.copyWith(
            prompt: null == prompt
                ? _value.prompt
                : prompt // ignore: cast_nullable_to_non_nullable
                      as String,
            negativePrompt: null == negativePrompt
                ? _value.negativePrompt
                : negativePrompt // ignore: cast_nullable_to_non_nullable
                      as String,
            aspectRatio: null == aspectRatio
                ? _value.aspectRatio
                : aspectRatio // ignore: cast_nullable_to_non_nullable
                      as String,
            imageCount: null == imageCount
                ? _value.imageCount
                : imageCount // ignore: cast_nullable_to_non_nullable
                      as int,
            outputFormat: null == outputFormat
                ? _value.outputFormat
                : outputFormat // ignore: cast_nullable_to_non_nullable
                      as String,
            modelId: null == modelId
                ? _value.modelId
                : modelId // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CreateFormStateImplCopyWith<$Res>
    implements $CreateFormStateCopyWith<$Res> {
  factory _$$CreateFormStateImplCopyWith(
    _$CreateFormStateImpl value,
    $Res Function(_$CreateFormStateImpl) then,
  ) = __$$CreateFormStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String prompt,
    String negativePrompt,
    String aspectRatio,
    int imageCount,
    String outputFormat,
    String modelId,
  });
}

/// @nodoc
class __$$CreateFormStateImplCopyWithImpl<$Res>
    extends _$CreateFormStateCopyWithImpl<$Res, _$CreateFormStateImpl>
    implements _$$CreateFormStateImplCopyWith<$Res> {
  __$$CreateFormStateImplCopyWithImpl(
    _$CreateFormStateImpl _value,
    $Res Function(_$CreateFormStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CreateFormState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? prompt = null,
    Object? negativePrompt = null,
    Object? aspectRatio = null,
    Object? imageCount = null,
    Object? outputFormat = null,
    Object? modelId = null,
  }) {
    return _then(
      _$CreateFormStateImpl(
        prompt: null == prompt
            ? _value.prompt
            : prompt // ignore: cast_nullable_to_non_nullable
                  as String,
        negativePrompt: null == negativePrompt
            ? _value.negativePrompt
            : negativePrompt // ignore: cast_nullable_to_non_nullable
                  as String,
        aspectRatio: null == aspectRatio
            ? _value.aspectRatio
            : aspectRatio // ignore: cast_nullable_to_non_nullable
                  as String,
        imageCount: null == imageCount
            ? _value.imageCount
            : imageCount // ignore: cast_nullable_to_non_nullable
                  as int,
        outputFormat: null == outputFormat
            ? _value.outputFormat
            : outputFormat // ignore: cast_nullable_to_non_nullable
                  as String,
        modelId: null == modelId
            ? _value.modelId
            : modelId // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CreateFormStateImpl extends _CreateFormState {
  const _$CreateFormStateImpl({
    this.prompt = '',
    this.negativePrompt = '',
    this.aspectRatio = '1:1',
    this.imageCount = 1,
    this.outputFormat = 'jpg',
    this.modelId = 'google/imagen4',
  }) : super._();

  factory _$CreateFormStateImpl.fromJson(Map<String, dynamic> json) =>
      _$$CreateFormStateImplFromJson(json);

  @override
  @JsonKey()
  final String prompt;
  @override
  @JsonKey()
  final String negativePrompt;
  @override
  @JsonKey()
  final String aspectRatio;
  @override
  @JsonKey()
  final int imageCount;
  @override
  @JsonKey()
  final String outputFormat;
  @override
  @JsonKey()
  final String modelId;

  @override
  String toString() {
    return 'CreateFormState(prompt: $prompt, negativePrompt: $negativePrompt, aspectRatio: $aspectRatio, imageCount: $imageCount, outputFormat: $outputFormat, modelId: $modelId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CreateFormStateImpl &&
            (identical(other.prompt, prompt) || other.prompt == prompt) &&
            (identical(other.negativePrompt, negativePrompt) ||
                other.negativePrompt == negativePrompt) &&
            (identical(other.aspectRatio, aspectRatio) ||
                other.aspectRatio == aspectRatio) &&
            (identical(other.imageCount, imageCount) ||
                other.imageCount == imageCount) &&
            (identical(other.outputFormat, outputFormat) ||
                other.outputFormat == outputFormat) &&
            (identical(other.modelId, modelId) || other.modelId == modelId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    prompt,
    negativePrompt,
    aspectRatio,
    imageCount,
    outputFormat,
    modelId,
  );

  /// Create a copy of CreateFormState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CreateFormStateImplCopyWith<_$CreateFormStateImpl> get copyWith =>
      __$$CreateFormStateImplCopyWithImpl<_$CreateFormStateImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$CreateFormStateImplToJson(this);
  }
}

abstract class _CreateFormState extends CreateFormState {
  const factory _CreateFormState({
    final String prompt,
    final String negativePrompt,
    final String aspectRatio,
    final int imageCount,
    final String outputFormat,
    final String modelId,
  }) = _$CreateFormStateImpl;
  const _CreateFormState._() : super._();

  factory _CreateFormState.fromJson(Map<String, dynamic> json) =
      _$CreateFormStateImpl.fromJson;

  @override
  String get prompt;
  @override
  String get negativePrompt;
  @override
  String get aspectRatio;
  @override
  int get imageCount;
  @override
  String get outputFormat;
  @override
  String get modelId;

  /// Create a copy of CreateFormState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CreateFormStateImplCopyWith<_$CreateFormStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
