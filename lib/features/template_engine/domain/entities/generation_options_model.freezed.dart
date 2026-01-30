// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'generation_options_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

GenerationOptionsModel _$GenerationOptionsModelFromJson(
  Map<String, dynamic> json,
) {
  return _GenerationOptionsModel.fromJson(json);
}

/// @nodoc
mixin _$GenerationOptionsModel {
  String get aspectRatio => throw _privateConstructorUsedError;
  int get imageCount => throw _privateConstructorUsedError;
  String get outputFormat => throw _privateConstructorUsedError;
  String get modelId => throw _privateConstructorUsedError;
  String get otherIdeas => throw _privateConstructorUsedError;

  /// Serializes this GenerationOptionsModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GenerationOptionsModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GenerationOptionsModelCopyWith<GenerationOptionsModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GenerationOptionsModelCopyWith<$Res> {
  factory $GenerationOptionsModelCopyWith(
    GenerationOptionsModel value,
    $Res Function(GenerationOptionsModel) then,
  ) = _$GenerationOptionsModelCopyWithImpl<$Res, GenerationOptionsModel>;
  @useResult
  $Res call({
    String aspectRatio,
    int imageCount,
    String outputFormat,
    String modelId,
    String otherIdeas,
  });
}

/// @nodoc
class _$GenerationOptionsModelCopyWithImpl<
  $Res,
  $Val extends GenerationOptionsModel
>
    implements $GenerationOptionsModelCopyWith<$Res> {
  _$GenerationOptionsModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GenerationOptionsModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? aspectRatio = null,
    Object? imageCount = null,
    Object? outputFormat = null,
    Object? modelId = null,
    Object? otherIdeas = null,
  }) {
    return _then(
      _value.copyWith(
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
            otherIdeas: null == otherIdeas
                ? _value.otherIdeas
                : otherIdeas // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$GenerationOptionsModelImplCopyWith<$Res>
    implements $GenerationOptionsModelCopyWith<$Res> {
  factory _$$GenerationOptionsModelImplCopyWith(
    _$GenerationOptionsModelImpl value,
    $Res Function(_$GenerationOptionsModelImpl) then,
  ) = __$$GenerationOptionsModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String aspectRatio,
    int imageCount,
    String outputFormat,
    String modelId,
    String otherIdeas,
  });
}

/// @nodoc
class __$$GenerationOptionsModelImplCopyWithImpl<$Res>
    extends
        _$GenerationOptionsModelCopyWithImpl<$Res, _$GenerationOptionsModelImpl>
    implements _$$GenerationOptionsModelImplCopyWith<$Res> {
  __$$GenerationOptionsModelImplCopyWithImpl(
    _$GenerationOptionsModelImpl _value,
    $Res Function(_$GenerationOptionsModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GenerationOptionsModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? aspectRatio = null,
    Object? imageCount = null,
    Object? outputFormat = null,
    Object? modelId = null,
    Object? otherIdeas = null,
  }) {
    return _then(
      _$GenerationOptionsModelImpl(
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
        otherIdeas: null == otherIdeas
            ? _value.otherIdeas
            : otherIdeas // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$GenerationOptionsModelImpl implements _GenerationOptionsModel {
  const _$GenerationOptionsModelImpl({
    this.aspectRatio = '1:1',
    this.imageCount = 1,
    this.outputFormat = 'jpg',
    this.modelId = 'google/imagen4',
    this.otherIdeas = '',
  });

  factory _$GenerationOptionsModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$GenerationOptionsModelImplFromJson(json);

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
  @JsonKey()
  final String otherIdeas;

  @override
  String toString() {
    return 'GenerationOptionsModel(aspectRatio: $aspectRatio, imageCount: $imageCount, outputFormat: $outputFormat, modelId: $modelId, otherIdeas: $otherIdeas)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GenerationOptionsModelImpl &&
            (identical(other.aspectRatio, aspectRatio) ||
                other.aspectRatio == aspectRatio) &&
            (identical(other.imageCount, imageCount) ||
                other.imageCount == imageCount) &&
            (identical(other.outputFormat, outputFormat) ||
                other.outputFormat == outputFormat) &&
            (identical(other.modelId, modelId) || other.modelId == modelId) &&
            (identical(other.otherIdeas, otherIdeas) ||
                other.otherIdeas == otherIdeas));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    aspectRatio,
    imageCount,
    outputFormat,
    modelId,
    otherIdeas,
  );

  /// Create a copy of GenerationOptionsModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GenerationOptionsModelImplCopyWith<_$GenerationOptionsModelImpl>
  get copyWith =>
      __$$GenerationOptionsModelImplCopyWithImpl<_$GenerationOptionsModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$GenerationOptionsModelImplToJson(this);
  }
}

abstract class _GenerationOptionsModel implements GenerationOptionsModel {
  const factory _GenerationOptionsModel({
    final String aspectRatio,
    final int imageCount,
    final String outputFormat,
    final String modelId,
    final String otherIdeas,
  }) = _$GenerationOptionsModelImpl;

  factory _GenerationOptionsModel.fromJson(Map<String, dynamic> json) =
      _$GenerationOptionsModelImpl.fromJson;

  @override
  String get aspectRatio;
  @override
  int get imageCount;
  @override
  String get outputFormat;
  @override
  String get modelId;
  @override
  String get otherIdeas;

  /// Create a copy of GenerationOptionsModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GenerationOptionsModelImplCopyWith<_$GenerationOptionsModelImpl>
  get copyWith => throw _privateConstructorUsedError;
}
