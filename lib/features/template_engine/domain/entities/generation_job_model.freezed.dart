// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'generation_job_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

GenerationJobModel _$GenerationJobModelFromJson(Map<String, dynamic> json) {
  return _GenerationJobModel.fromJson(json);
}

/// @nodoc
mixin _$GenerationJobModel {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get templateId => throw _privateConstructorUsedError;
  String get prompt => throw _privateConstructorUsedError;
  JobStatus get status => throw _privateConstructorUsedError;
  String? get aspectRatio => throw _privateConstructorUsedError;
  int? get imageCount => throw _privateConstructorUsedError;
  String? get providerUsed =>
      throw _privateConstructorUsedError; // 'kie' or 'gemini'
  String? get providerTaskId =>
      throw _privateConstructorUsedError; // taskId from provider
  List<String>? get resultUrls => throw _privateConstructorUsedError;
  String? get errorMessage => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get completedAt => throw _privateConstructorUsedError;

  /// Serializes this GenerationJobModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GenerationJobModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GenerationJobModelCopyWith<GenerationJobModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GenerationJobModelCopyWith<$Res> {
  factory $GenerationJobModelCopyWith(
    GenerationJobModel value,
    $Res Function(GenerationJobModel) then,
  ) = _$GenerationJobModelCopyWithImpl<$Res, GenerationJobModel>;
  @useResult
  $Res call({
    String id,
    String userId,
    String templateId,
    String prompt,
    JobStatus status,
    String? aspectRatio,
    int? imageCount,
    String? providerUsed,
    String? providerTaskId,
    List<String>? resultUrls,
    String? errorMessage,
    DateTime? createdAt,
    DateTime? completedAt,
  });
}

/// @nodoc
class _$GenerationJobModelCopyWithImpl<$Res, $Val extends GenerationJobModel>
    implements $GenerationJobModelCopyWith<$Res> {
  _$GenerationJobModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GenerationJobModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? templateId = null,
    Object? prompt = null,
    Object? status = null,
    Object? aspectRatio = freezed,
    Object? imageCount = freezed,
    Object? providerUsed = freezed,
    Object? providerTaskId = freezed,
    Object? resultUrls = freezed,
    Object? errorMessage = freezed,
    Object? createdAt = freezed,
    Object? completedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            templateId: null == templateId
                ? _value.templateId
                : templateId // ignore: cast_nullable_to_non_nullable
                      as String,
            prompt: null == prompt
                ? _value.prompt
                : prompt // ignore: cast_nullable_to_non_nullable
                      as String,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as JobStatus,
            aspectRatio: freezed == aspectRatio
                ? _value.aspectRatio
                : aspectRatio // ignore: cast_nullable_to_non_nullable
                      as String?,
            imageCount: freezed == imageCount
                ? _value.imageCount
                : imageCount // ignore: cast_nullable_to_non_nullable
                      as int?,
            providerUsed: freezed == providerUsed
                ? _value.providerUsed
                : providerUsed // ignore: cast_nullable_to_non_nullable
                      as String?,
            providerTaskId: freezed == providerTaskId
                ? _value.providerTaskId
                : providerTaskId // ignore: cast_nullable_to_non_nullable
                      as String?,
            resultUrls: freezed == resultUrls
                ? _value.resultUrls
                : resultUrls // ignore: cast_nullable_to_non_nullable
                      as List<String>?,
            errorMessage: freezed == errorMessage
                ? _value.errorMessage
                : errorMessage // ignore: cast_nullable_to_non_nullable
                      as String?,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            completedAt: freezed == completedAt
                ? _value.completedAt
                : completedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$GenerationJobModelImplCopyWith<$Res>
    implements $GenerationJobModelCopyWith<$Res> {
  factory _$$GenerationJobModelImplCopyWith(
    _$GenerationJobModelImpl value,
    $Res Function(_$GenerationJobModelImpl) then,
  ) = __$$GenerationJobModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String userId,
    String templateId,
    String prompt,
    JobStatus status,
    String? aspectRatio,
    int? imageCount,
    String? providerUsed,
    String? providerTaskId,
    List<String>? resultUrls,
    String? errorMessage,
    DateTime? createdAt,
    DateTime? completedAt,
  });
}

/// @nodoc
class __$$GenerationJobModelImplCopyWithImpl<$Res>
    extends _$GenerationJobModelCopyWithImpl<$Res, _$GenerationJobModelImpl>
    implements _$$GenerationJobModelImplCopyWith<$Res> {
  __$$GenerationJobModelImplCopyWithImpl(
    _$GenerationJobModelImpl _value,
    $Res Function(_$GenerationJobModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GenerationJobModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? templateId = null,
    Object? prompt = null,
    Object? status = null,
    Object? aspectRatio = freezed,
    Object? imageCount = freezed,
    Object? providerUsed = freezed,
    Object? providerTaskId = freezed,
    Object? resultUrls = freezed,
    Object? errorMessage = freezed,
    Object? createdAt = freezed,
    Object? completedAt = freezed,
  }) {
    return _then(
      _$GenerationJobModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        templateId: null == templateId
            ? _value.templateId
            : templateId // ignore: cast_nullable_to_non_nullable
                  as String,
        prompt: null == prompt
            ? _value.prompt
            : prompt // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as JobStatus,
        aspectRatio: freezed == aspectRatio
            ? _value.aspectRatio
            : aspectRatio // ignore: cast_nullable_to_non_nullable
                  as String?,
        imageCount: freezed == imageCount
            ? _value.imageCount
            : imageCount // ignore: cast_nullable_to_non_nullable
                  as int?,
        providerUsed: freezed == providerUsed
            ? _value.providerUsed
            : providerUsed // ignore: cast_nullable_to_non_nullable
                  as String?,
        providerTaskId: freezed == providerTaskId
            ? _value.providerTaskId
            : providerTaskId // ignore: cast_nullable_to_non_nullable
                  as String?,
        resultUrls: freezed == resultUrls
            ? _value._resultUrls
            : resultUrls // ignore: cast_nullable_to_non_nullable
                  as List<String>?,
        errorMessage: freezed == errorMessage
            ? _value.errorMessage
            : errorMessage // ignore: cast_nullable_to_non_nullable
                  as String?,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        completedAt: freezed == completedAt
            ? _value.completedAt
            : completedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$GenerationJobModelImpl implements _GenerationJobModel {
  const _$GenerationJobModelImpl({
    required this.id,
    required this.userId,
    required this.templateId,
    required this.prompt,
    required this.status,
    this.aspectRatio,
    this.imageCount,
    this.providerUsed,
    this.providerTaskId,
    final List<String>? resultUrls,
    this.errorMessage,
    this.createdAt,
    this.completedAt,
  }) : _resultUrls = resultUrls;

  factory _$GenerationJobModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$GenerationJobModelImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final String templateId;
  @override
  final String prompt;
  @override
  final JobStatus status;
  @override
  final String? aspectRatio;
  @override
  final int? imageCount;
  @override
  final String? providerUsed;
  // 'kie' or 'gemini'
  @override
  final String? providerTaskId;
  // taskId from provider
  final List<String>? _resultUrls;
  // taskId from provider
  @override
  List<String>? get resultUrls {
    final value = _resultUrls;
    if (value == null) return null;
    if (_resultUrls is EqualUnmodifiableListView) return _resultUrls;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final String? errorMessage;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? completedAt;

  @override
  String toString() {
    return 'GenerationJobModel(id: $id, userId: $userId, templateId: $templateId, prompt: $prompt, status: $status, aspectRatio: $aspectRatio, imageCount: $imageCount, providerUsed: $providerUsed, providerTaskId: $providerTaskId, resultUrls: $resultUrls, errorMessage: $errorMessage, createdAt: $createdAt, completedAt: $completedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GenerationJobModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.templateId, templateId) ||
                other.templateId == templateId) &&
            (identical(other.prompt, prompt) || other.prompt == prompt) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.aspectRatio, aspectRatio) ||
                other.aspectRatio == aspectRatio) &&
            (identical(other.imageCount, imageCount) ||
                other.imageCount == imageCount) &&
            (identical(other.providerUsed, providerUsed) ||
                other.providerUsed == providerUsed) &&
            (identical(other.providerTaskId, providerTaskId) ||
                other.providerTaskId == providerTaskId) &&
            const DeepCollectionEquality().equals(
              other._resultUrls,
              _resultUrls,
            ) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.completedAt, completedAt) ||
                other.completedAt == completedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    userId,
    templateId,
    prompt,
    status,
    aspectRatio,
    imageCount,
    providerUsed,
    providerTaskId,
    const DeepCollectionEquality().hash(_resultUrls),
    errorMessage,
    createdAt,
    completedAt,
  );

  /// Create a copy of GenerationJobModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GenerationJobModelImplCopyWith<_$GenerationJobModelImpl> get copyWith =>
      __$$GenerationJobModelImplCopyWithImpl<_$GenerationJobModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$GenerationJobModelImplToJson(this);
  }
}

abstract class _GenerationJobModel implements GenerationJobModel {
  const factory _GenerationJobModel({
    required final String id,
    required final String userId,
    required final String templateId,
    required final String prompt,
    required final JobStatus status,
    final String? aspectRatio,
    final int? imageCount,
    final String? providerUsed,
    final String? providerTaskId,
    final List<String>? resultUrls,
    final String? errorMessage,
    final DateTime? createdAt,
    final DateTime? completedAt,
  }) = _$GenerationJobModelImpl;

  factory _GenerationJobModel.fromJson(Map<String, dynamic> json) =
      _$GenerationJobModelImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  String get templateId;
  @override
  String get prompt;
  @override
  JobStatus get status;
  @override
  String? get aspectRatio;
  @override
  int? get imageCount;
  @override
  String? get providerUsed; // 'kie' or 'gemini'
  @override
  String? get providerTaskId; // taskId from provider
  @override
  List<String>? get resultUrls;
  @override
  String? get errorMessage;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get completedAt;

  /// Create a copy of GenerationJobModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GenerationJobModelImplCopyWith<_$GenerationJobModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
