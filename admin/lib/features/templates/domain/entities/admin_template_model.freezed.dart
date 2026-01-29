// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'admin_template_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

AdminTemplateModel _$AdminTemplateModelFromJson(Map<String, dynamic> json) {
  return _AdminTemplateModel.fromJson(json);
}

/// @nodoc
mixin _$AdminTemplateModel {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String get category => throw _privateConstructorUsedError;
  @JsonKey(name: 'prompt_template')
  String get promptTemplate => throw _privateConstructorUsedError;
  @JsonKey(name: 'order')
  int get order => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_premium')
  bool get isPremium => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_active')
  bool get isActive => throw _privateConstructorUsedError;
  @JsonKey(name: 'thumbnail_url')
  String? get thumbnailUrl => throw _privateConstructorUsedError;
  @JsonKey(name: 'default_aspect_ratio')
  String get defaultAspectRatio => throw _privateConstructorUsedError;
  @JsonKey(name: 'input_fields')
  List<Map<String, dynamic>> get inputFields =>
      throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime? get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this AdminTemplateModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AdminTemplateModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AdminTemplateModelCopyWith<AdminTemplateModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AdminTemplateModelCopyWith<$Res> {
  factory $AdminTemplateModelCopyWith(
    AdminTemplateModel value,
    $Res Function(AdminTemplateModel) then,
  ) = _$AdminTemplateModelCopyWithImpl<$Res, AdminTemplateModel>;
  @useResult
  $Res call({
    String id,
    String name,
    String description,
    String category,
    @JsonKey(name: 'prompt_template') String promptTemplate,
    @JsonKey(name: 'order') int order,
    @JsonKey(name: 'is_premium') bool isPremium,
    @JsonKey(name: 'is_active') bool isActive,
    @JsonKey(name: 'thumbnail_url') String? thumbnailUrl,
    @JsonKey(name: 'default_aspect_ratio') String defaultAspectRatio,
    @JsonKey(name: 'input_fields') List<Map<String, dynamic>> inputFields,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  });
}

/// @nodoc
class _$AdminTemplateModelCopyWithImpl<$Res, $Val extends AdminTemplateModel>
    implements $AdminTemplateModelCopyWith<$Res> {
  _$AdminTemplateModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AdminTemplateModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = null,
    Object? category = null,
    Object? promptTemplate = null,
    Object? order = null,
    Object? isPremium = null,
    Object? isActive = null,
    Object? thumbnailUrl = freezed,
    Object? defaultAspectRatio = null,
    Object? inputFields = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            description: null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String,
            category: null == category
                ? _value.category
                : category // ignore: cast_nullable_to_non_nullable
                      as String,
            promptTemplate: null == promptTemplate
                ? _value.promptTemplate
                : promptTemplate // ignore: cast_nullable_to_non_nullable
                      as String,
            order: null == order
                ? _value.order
                : order // ignore: cast_nullable_to_non_nullable
                      as int,
            isPremium: null == isPremium
                ? _value.isPremium
                : isPremium // ignore: cast_nullable_to_non_nullable
                      as bool,
            isActive: null == isActive
                ? _value.isActive
                : isActive // ignore: cast_nullable_to_non_nullable
                      as bool,
            thumbnailUrl: freezed == thumbnailUrl
                ? _value.thumbnailUrl
                : thumbnailUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            defaultAspectRatio: null == defaultAspectRatio
                ? _value.defaultAspectRatio
                : defaultAspectRatio // ignore: cast_nullable_to_non_nullable
                      as String,
            inputFields: null == inputFields
                ? _value.inputFields
                : inputFields // ignore: cast_nullable_to_non_nullable
                      as List<Map<String, dynamic>>,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            updatedAt: freezed == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AdminTemplateModelImplCopyWith<$Res>
    implements $AdminTemplateModelCopyWith<$Res> {
  factory _$$AdminTemplateModelImplCopyWith(
    _$AdminTemplateModelImpl value,
    $Res Function(_$AdminTemplateModelImpl) then,
  ) = __$$AdminTemplateModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    String description,
    String category,
    @JsonKey(name: 'prompt_template') String promptTemplate,
    @JsonKey(name: 'order') int order,
    @JsonKey(name: 'is_premium') bool isPremium,
    @JsonKey(name: 'is_active') bool isActive,
    @JsonKey(name: 'thumbnail_url') String? thumbnailUrl,
    @JsonKey(name: 'default_aspect_ratio') String defaultAspectRatio,
    @JsonKey(name: 'input_fields') List<Map<String, dynamic>> inputFields,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  });
}

/// @nodoc
class __$$AdminTemplateModelImplCopyWithImpl<$Res>
    extends _$AdminTemplateModelCopyWithImpl<$Res, _$AdminTemplateModelImpl>
    implements _$$AdminTemplateModelImplCopyWith<$Res> {
  __$$AdminTemplateModelImplCopyWithImpl(
    _$AdminTemplateModelImpl _value,
    $Res Function(_$AdminTemplateModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AdminTemplateModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = null,
    Object? category = null,
    Object? promptTemplate = null,
    Object? order = null,
    Object? isPremium = null,
    Object? isActive = null,
    Object? thumbnailUrl = freezed,
    Object? defaultAspectRatio = null,
    Object? inputFields = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _$AdminTemplateModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        description: null == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String,
        category: null == category
            ? _value.category
            : category // ignore: cast_nullable_to_non_nullable
                  as String,
        promptTemplate: null == promptTemplate
            ? _value.promptTemplate
            : promptTemplate // ignore: cast_nullable_to_non_nullable
                  as String,
        order: null == order
            ? _value.order
            : order // ignore: cast_nullable_to_non_nullable
                  as int,
        isPremium: null == isPremium
            ? _value.isPremium
            : isPremium // ignore: cast_nullable_to_non_nullable
                  as bool,
        isActive: null == isActive
            ? _value.isActive
            : isActive // ignore: cast_nullable_to_non_nullable
                  as bool,
        thumbnailUrl: freezed == thumbnailUrl
            ? _value.thumbnailUrl
            : thumbnailUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        defaultAspectRatio: null == defaultAspectRatio
            ? _value.defaultAspectRatio
            : defaultAspectRatio // ignore: cast_nullable_to_non_nullable
                  as String,
        inputFields: null == inputFields
            ? _value._inputFields
            : inputFields // ignore: cast_nullable_to_non_nullable
                  as List<Map<String, dynamic>>,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        updatedAt: freezed == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AdminTemplateModelImpl implements _AdminTemplateModel {
  const _$AdminTemplateModelImpl({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    @JsonKey(name: 'prompt_template') required this.promptTemplate,
    @JsonKey(name: 'order') required this.order,
    @JsonKey(name: 'is_premium') this.isPremium = false,
    @JsonKey(name: 'is_active') this.isActive = true,
    @JsonKey(name: 'thumbnail_url') this.thumbnailUrl,
    @JsonKey(name: 'default_aspect_ratio') this.defaultAspectRatio = '1:1',
    @JsonKey(name: 'input_fields')
    final List<Map<String, dynamic>> inputFields = const [],
    @JsonKey(name: 'created_at') this.createdAt,
    @JsonKey(name: 'updated_at') this.updatedAt,
  }) : _inputFields = inputFields;

  factory _$AdminTemplateModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$AdminTemplateModelImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String description;
  @override
  final String category;
  @override
  @JsonKey(name: 'prompt_template')
  final String promptTemplate;
  @override
  @JsonKey(name: 'order')
  final int order;
  @override
  @JsonKey(name: 'is_premium')
  final bool isPremium;
  @override
  @JsonKey(name: 'is_active')
  final bool isActive;
  @override
  @JsonKey(name: 'thumbnail_url')
  final String? thumbnailUrl;
  @override
  @JsonKey(name: 'default_aspect_ratio')
  final String defaultAspectRatio;
  final List<Map<String, dynamic>> _inputFields;
  @override
  @JsonKey(name: 'input_fields')
  List<Map<String, dynamic>> get inputFields {
    if (_inputFields is EqualUnmodifiableListView) return _inputFields;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_inputFields);
  }

  @override
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'AdminTemplateModel(id: $id, name: $name, description: $description, category: $category, promptTemplate: $promptTemplate, order: $order, isPremium: $isPremium, isActive: $isActive, thumbnailUrl: $thumbnailUrl, defaultAspectRatio: $defaultAspectRatio, inputFields: $inputFields, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AdminTemplateModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.promptTemplate, promptTemplate) ||
                other.promptTemplate == promptTemplate) &&
            (identical(other.order, order) || other.order == order) &&
            (identical(other.isPremium, isPremium) ||
                other.isPremium == isPremium) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.thumbnailUrl, thumbnailUrl) ||
                other.thumbnailUrl == thumbnailUrl) &&
            (identical(other.defaultAspectRatio, defaultAspectRatio) ||
                other.defaultAspectRatio == defaultAspectRatio) &&
            const DeepCollectionEquality().equals(
              other._inputFields,
              _inputFields,
            ) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    description,
    category,
    promptTemplate,
    order,
    isPremium,
    isActive,
    thumbnailUrl,
    defaultAspectRatio,
    const DeepCollectionEquality().hash(_inputFields),
    createdAt,
    updatedAt,
  );

  /// Create a copy of AdminTemplateModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AdminTemplateModelImplCopyWith<_$AdminTemplateModelImpl> get copyWith =>
      __$$AdminTemplateModelImplCopyWithImpl<_$AdminTemplateModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$AdminTemplateModelImplToJson(this);
  }
}

abstract class _AdminTemplateModel implements AdminTemplateModel {
  const factory _AdminTemplateModel({
    required final String id,
    required final String name,
    required final String description,
    required final String category,
    @JsonKey(name: 'prompt_template') required final String promptTemplate,
    @JsonKey(name: 'order') required final int order,
    @JsonKey(name: 'is_premium') final bool isPremium,
    @JsonKey(name: 'is_active') final bool isActive,
    @JsonKey(name: 'thumbnail_url') final String? thumbnailUrl,
    @JsonKey(name: 'default_aspect_ratio') final String defaultAspectRatio,
    @JsonKey(name: 'input_fields') final List<Map<String, dynamic>> inputFields,
    @JsonKey(name: 'created_at') final DateTime? createdAt,
    @JsonKey(name: 'updated_at') final DateTime? updatedAt,
  }) = _$AdminTemplateModelImpl;

  factory _AdminTemplateModel.fromJson(Map<String, dynamic> json) =
      _$AdminTemplateModelImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get description;
  @override
  String get category;
  @override
  @JsonKey(name: 'prompt_template')
  String get promptTemplate;
  @override
  @JsonKey(name: 'order')
  int get order;
  @override
  @JsonKey(name: 'is_premium')
  bool get isPremium;
  @override
  @JsonKey(name: 'is_active')
  bool get isActive;
  @override
  @JsonKey(name: 'thumbnail_url')
  String? get thumbnailUrl;
  @override
  @JsonKey(name: 'default_aspect_ratio')
  String get defaultAspectRatio;
  @override
  @JsonKey(name: 'input_fields')
  List<Map<String, dynamic>> get inputFields;
  @override
  @JsonKey(name: 'created_at')
  DateTime? get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt;

  /// Create a copy of AdminTemplateModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AdminTemplateModelImplCopyWith<_$AdminTemplateModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
