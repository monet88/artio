// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'gallery_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

GalleryItem _$GalleryItemFromJson(Map<String, dynamic> json) {
  return _GalleryItem.fromJson(json);
}

/// @nodoc
mixin _$GalleryItem {
  String get id => throw _privateConstructorUsedError;
  String get jobId => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get templateId => throw _privateConstructorUsedError;
  String get templateName => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  GenerationStatus get status => throw _privateConstructorUsedError;
  String? get imageUrl => throw _privateConstructorUsedError;
  String? get prompt => throw _privateConstructorUsedError;
  List<String>? get resultPaths => throw _privateConstructorUsedError;
  DateTime? get deletedAt => throw _privateConstructorUsedError;
  bool get isFavorite => throw _privateConstructorUsedError;

  /// Serializes this GalleryItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GalleryItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GalleryItemCopyWith<GalleryItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GalleryItemCopyWith<$Res> {
  factory $GalleryItemCopyWith(
    GalleryItem value,
    $Res Function(GalleryItem) then,
  ) = _$GalleryItemCopyWithImpl<$Res, GalleryItem>;
  @useResult
  $Res call({
    String id,
    String jobId,
    String userId,
    String templateId,
    String templateName,
    DateTime createdAt,
    GenerationStatus status,
    String? imageUrl,
    String? prompt,
    List<String>? resultPaths,
    DateTime? deletedAt,
    bool isFavorite,
  });
}

/// @nodoc
class _$GalleryItemCopyWithImpl<$Res, $Val extends GalleryItem>
    implements $GalleryItemCopyWith<$Res> {
  _$GalleryItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GalleryItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? jobId = null,
    Object? userId = null,
    Object? templateId = null,
    Object? templateName = null,
    Object? createdAt = null,
    Object? status = null,
    Object? imageUrl = freezed,
    Object? prompt = freezed,
    Object? resultPaths = freezed,
    Object? deletedAt = freezed,
    Object? isFavorite = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            jobId: null == jobId
                ? _value.jobId
                : jobId // ignore: cast_nullable_to_non_nullable
                      as String,
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            templateId: null == templateId
                ? _value.templateId
                : templateId // ignore: cast_nullable_to_non_nullable
                      as String,
            templateName: null == templateName
                ? _value.templateName
                : templateName // ignore: cast_nullable_to_non_nullable
                      as String,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as GenerationStatus,
            imageUrl: freezed == imageUrl
                ? _value.imageUrl
                : imageUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            prompt: freezed == prompt
                ? _value.prompt
                : prompt // ignore: cast_nullable_to_non_nullable
                      as String?,
            resultPaths: freezed == resultPaths
                ? _value.resultPaths
                : resultPaths // ignore: cast_nullable_to_non_nullable
                      as List<String>?,
            deletedAt: freezed == deletedAt
                ? _value.deletedAt
                : deletedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            isFavorite: null == isFavorite
                ? _value.isFavorite
                : isFavorite // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$GalleryItemImplCopyWith<$Res>
    implements $GalleryItemCopyWith<$Res> {
  factory _$$GalleryItemImplCopyWith(
    _$GalleryItemImpl value,
    $Res Function(_$GalleryItemImpl) then,
  ) = __$$GalleryItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String jobId,
    String userId,
    String templateId,
    String templateName,
    DateTime createdAt,
    GenerationStatus status,
    String? imageUrl,
    String? prompt,
    List<String>? resultPaths,
    DateTime? deletedAt,
    bool isFavorite,
  });
}

/// @nodoc
class __$$GalleryItemImplCopyWithImpl<$Res>
    extends _$GalleryItemCopyWithImpl<$Res, _$GalleryItemImpl>
    implements _$$GalleryItemImplCopyWith<$Res> {
  __$$GalleryItemImplCopyWithImpl(
    _$GalleryItemImpl _value,
    $Res Function(_$GalleryItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GalleryItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? jobId = null,
    Object? userId = null,
    Object? templateId = null,
    Object? templateName = null,
    Object? createdAt = null,
    Object? status = null,
    Object? imageUrl = freezed,
    Object? prompt = freezed,
    Object? resultPaths = freezed,
    Object? deletedAt = freezed,
    Object? isFavorite = null,
  }) {
    return _then(
      _$GalleryItemImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        jobId: null == jobId
            ? _value.jobId
            : jobId // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        templateId: null == templateId
            ? _value.templateId
            : templateId // ignore: cast_nullable_to_non_nullable
                  as String,
        templateName: null == templateName
            ? _value.templateName
            : templateName // ignore: cast_nullable_to_non_nullable
                  as String,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as GenerationStatus,
        imageUrl: freezed == imageUrl
            ? _value.imageUrl
            : imageUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        prompt: freezed == prompt
            ? _value.prompt
            : prompt // ignore: cast_nullable_to_non_nullable
                  as String?,
        resultPaths: freezed == resultPaths
            ? _value._resultPaths
            : resultPaths // ignore: cast_nullable_to_non_nullable
                  as List<String>?,
        deletedAt: freezed == deletedAt
            ? _value.deletedAt
            : deletedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        isFavorite: null == isFavorite
            ? _value.isFavorite
            : isFavorite // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$GalleryItemImpl implements _GalleryItem {
  const _$GalleryItemImpl({
    required this.id,
    required this.jobId,
    required this.userId,
    required this.templateId,
    required this.templateName,
    required this.createdAt,
    required this.status,
    this.imageUrl,
    this.prompt,
    final List<String>? resultPaths,
    this.deletedAt,
    this.isFavorite = false,
  }) : _resultPaths = resultPaths;

  factory _$GalleryItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$GalleryItemImplFromJson(json);

  @override
  final String id;
  @override
  final String jobId;
  @override
  final String userId;
  @override
  final String templateId;
  @override
  final String templateName;
  @override
  final DateTime createdAt;
  @override
  final GenerationStatus status;
  @override
  final String? imageUrl;
  @override
  final String? prompt;
  final List<String>? _resultPaths;
  @override
  List<String>? get resultPaths {
    final value = _resultPaths;
    if (value == null) return null;
    if (_resultPaths is EqualUnmodifiableListView) return _resultPaths;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final DateTime? deletedAt;
  @override
  @JsonKey()
  final bool isFavorite;

  @override
  String toString() {
    return 'GalleryItem(id: $id, jobId: $jobId, userId: $userId, templateId: $templateId, templateName: $templateName, createdAt: $createdAt, status: $status, imageUrl: $imageUrl, prompt: $prompt, resultPaths: $resultPaths, deletedAt: $deletedAt, isFavorite: $isFavorite)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GalleryItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.jobId, jobId) || other.jobId == jobId) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.templateId, templateId) ||
                other.templateId == templateId) &&
            (identical(other.templateName, templateName) ||
                other.templateName == templateName) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.prompt, prompt) || other.prompt == prompt) &&
            const DeepCollectionEquality().equals(
              other._resultPaths,
              _resultPaths,
            ) &&
            (identical(other.deletedAt, deletedAt) ||
                other.deletedAt == deletedAt) &&
            (identical(other.isFavorite, isFavorite) ||
                other.isFavorite == isFavorite));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    jobId,
    userId,
    templateId,
    templateName,
    createdAt,
    status,
    imageUrl,
    prompt,
    const DeepCollectionEquality().hash(_resultPaths),
    deletedAt,
    isFavorite,
  );

  /// Create a copy of GalleryItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GalleryItemImplCopyWith<_$GalleryItemImpl> get copyWith =>
      __$$GalleryItemImplCopyWithImpl<_$GalleryItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GalleryItemImplToJson(this);
  }
}

abstract class _GalleryItem implements GalleryItem {
  const factory _GalleryItem({
    required final String id,
    required final String jobId,
    required final String userId,
    required final String templateId,
    required final String templateName,
    required final DateTime createdAt,
    required final GenerationStatus status,
    final String? imageUrl,
    final String? prompt,
    final List<String>? resultPaths,
    final DateTime? deletedAt,
    final bool isFavorite,
  }) = _$GalleryItemImpl;

  factory _GalleryItem.fromJson(Map<String, dynamic> json) =
      _$GalleryItemImpl.fromJson;

  @override
  String get id;
  @override
  String get jobId;
  @override
  String get userId;
  @override
  String get templateId;
  @override
  String get templateName;
  @override
  DateTime get createdAt;
  @override
  GenerationStatus get status;
  @override
  String? get imageUrl;
  @override
  String? get prompt;
  @override
  List<String>? get resultPaths;
  @override
  DateTime? get deletedAt;
  @override
  bool get isFavorite;

  /// Create a copy of GalleryItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GalleryItemImplCopyWith<_$GalleryItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
