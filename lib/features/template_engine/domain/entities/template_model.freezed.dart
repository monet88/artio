// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'template_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

TemplateModel _$TemplateModelFromJson(Map<String, dynamic> json) {
  return _TemplateModel.fromJson(json);
}

/// @nodoc
mixin _$TemplateModel {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String get thumbnailUrl => throw _privateConstructorUsedError;
  String get category => throw _privateConstructorUsedError;
  String get promptTemplate => throw _privateConstructorUsedError;
  List<InputFieldModel> get inputFields => throw _privateConstructorUsedError;
  String get defaultAspectRatio => throw _privateConstructorUsedError;
  bool get isPremium => throw _privateConstructorUsedError;
  int get order => throw _privateConstructorUsedError;

  /// Serializes this TemplateModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TemplateModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TemplateModelCopyWith<TemplateModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TemplateModelCopyWith<$Res> {
  factory $TemplateModelCopyWith(
    TemplateModel value,
    $Res Function(TemplateModel) then,
  ) = _$TemplateModelCopyWithImpl<$Res, TemplateModel>;
  @useResult
  $Res call({
    String id,
    String name,
    String description,
    String thumbnailUrl,
    String category,
    String promptTemplate,
    List<InputFieldModel> inputFields,
    String defaultAspectRatio,
    bool isPremium,
    int order,
  });
}

/// @nodoc
class _$TemplateModelCopyWithImpl<$Res, $Val extends TemplateModel>
    implements $TemplateModelCopyWith<$Res> {
  _$TemplateModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TemplateModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = null,
    Object? thumbnailUrl = null,
    Object? category = null,
    Object? promptTemplate = null,
    Object? inputFields = null,
    Object? defaultAspectRatio = null,
    Object? isPremium = null,
    Object? order = null,
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
            thumbnailUrl: null == thumbnailUrl
                ? _value.thumbnailUrl
                : thumbnailUrl // ignore: cast_nullable_to_non_nullable
                      as String,
            category: null == category
                ? _value.category
                : category // ignore: cast_nullable_to_non_nullable
                      as String,
            promptTemplate: null == promptTemplate
                ? _value.promptTemplate
                : promptTemplate // ignore: cast_nullable_to_non_nullable
                      as String,
            inputFields: null == inputFields
                ? _value.inputFields
                : inputFields // ignore: cast_nullable_to_non_nullable
                      as List<InputFieldModel>,
            defaultAspectRatio: null == defaultAspectRatio
                ? _value.defaultAspectRatio
                : defaultAspectRatio // ignore: cast_nullable_to_non_nullable
                      as String,
            isPremium: null == isPremium
                ? _value.isPremium
                : isPremium // ignore: cast_nullable_to_non_nullable
                      as bool,
            order: null == order
                ? _value.order
                : order // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TemplateModelImplCopyWith<$Res>
    implements $TemplateModelCopyWith<$Res> {
  factory _$$TemplateModelImplCopyWith(
    _$TemplateModelImpl value,
    $Res Function(_$TemplateModelImpl) then,
  ) = __$$TemplateModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    String description,
    String thumbnailUrl,
    String category,
    String promptTemplate,
    List<InputFieldModel> inputFields,
    String defaultAspectRatio,
    bool isPremium,
    int order,
  });
}

/// @nodoc
class __$$TemplateModelImplCopyWithImpl<$Res>
    extends _$TemplateModelCopyWithImpl<$Res, _$TemplateModelImpl>
    implements _$$TemplateModelImplCopyWith<$Res> {
  __$$TemplateModelImplCopyWithImpl(
    _$TemplateModelImpl _value,
    $Res Function(_$TemplateModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TemplateModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = null,
    Object? thumbnailUrl = null,
    Object? category = null,
    Object? promptTemplate = null,
    Object? inputFields = null,
    Object? defaultAspectRatio = null,
    Object? isPremium = null,
    Object? order = null,
  }) {
    return _then(
      _$TemplateModelImpl(
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
        thumbnailUrl: null == thumbnailUrl
            ? _value.thumbnailUrl
            : thumbnailUrl // ignore: cast_nullable_to_non_nullable
                  as String,
        category: null == category
            ? _value.category
            : category // ignore: cast_nullable_to_non_nullable
                  as String,
        promptTemplate: null == promptTemplate
            ? _value.promptTemplate
            : promptTemplate // ignore: cast_nullable_to_non_nullable
                  as String,
        inputFields: null == inputFields
            ? _value._inputFields
            : inputFields // ignore: cast_nullable_to_non_nullable
                  as List<InputFieldModel>,
        defaultAspectRatio: null == defaultAspectRatio
            ? _value.defaultAspectRatio
            : defaultAspectRatio // ignore: cast_nullable_to_non_nullable
                  as String,
        isPremium: null == isPremium
            ? _value.isPremium
            : isPremium // ignore: cast_nullable_to_non_nullable
                  as bool,
        order: null == order
            ? _value.order
            : order // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TemplateModelImpl implements _TemplateModel {
  const _$TemplateModelImpl({
    required this.id,
    required this.name,
    required this.description,
    required this.thumbnailUrl,
    required this.category,
    required this.promptTemplate,
    required final List<InputFieldModel> inputFields,
    this.defaultAspectRatio = '1:1',
    this.isPremium = false,
    this.order = 0,
  }) : _inputFields = inputFields;

  factory _$TemplateModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$TemplateModelImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String description;
  @override
  final String thumbnailUrl;
  @override
  final String category;
  @override
  final String promptTemplate;
  final List<InputFieldModel> _inputFields;
  @override
  List<InputFieldModel> get inputFields {
    if (_inputFields is EqualUnmodifiableListView) return _inputFields;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_inputFields);
  }

  @override
  @JsonKey()
  final String defaultAspectRatio;
  @override
  @JsonKey()
  final bool isPremium;
  @override
  @JsonKey()
  final int order;

  @override
  String toString() {
    return 'TemplateModel(id: $id, name: $name, description: $description, thumbnailUrl: $thumbnailUrl, category: $category, promptTemplate: $promptTemplate, inputFields: $inputFields, defaultAspectRatio: $defaultAspectRatio, isPremium: $isPremium, order: $order)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TemplateModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.thumbnailUrl, thumbnailUrl) ||
                other.thumbnailUrl == thumbnailUrl) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.promptTemplate, promptTemplate) ||
                other.promptTemplate == promptTemplate) &&
            const DeepCollectionEquality().equals(
              other._inputFields,
              _inputFields,
            ) &&
            (identical(other.defaultAspectRatio, defaultAspectRatio) ||
                other.defaultAspectRatio == defaultAspectRatio) &&
            (identical(other.isPremium, isPremium) ||
                other.isPremium == isPremium) &&
            (identical(other.order, order) || other.order == order));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    description,
    thumbnailUrl,
    category,
    promptTemplate,
    const DeepCollectionEquality().hash(_inputFields),
    defaultAspectRatio,
    isPremium,
    order,
  );

  /// Create a copy of TemplateModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TemplateModelImplCopyWith<_$TemplateModelImpl> get copyWith =>
      __$$TemplateModelImplCopyWithImpl<_$TemplateModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TemplateModelImplToJson(this);
  }
}

abstract class _TemplateModel implements TemplateModel {
  const factory _TemplateModel({
    required final String id,
    required final String name,
    required final String description,
    required final String thumbnailUrl,
    required final String category,
    required final String promptTemplate,
    required final List<InputFieldModel> inputFields,
    final String defaultAspectRatio,
    final bool isPremium,
    final int order,
  }) = _$TemplateModelImpl;

  factory _TemplateModel.fromJson(Map<String, dynamic> json) =
      _$TemplateModelImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get description;
  @override
  String get thumbnailUrl;
  @override
  String get category;
  @override
  String get promptTemplate;
  @override
  List<InputFieldModel> get inputFields;
  @override
  String get defaultAspectRatio;
  @override
  bool get isPremium;
  @override
  int get order;

  /// Create a copy of TemplateModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TemplateModelImplCopyWith<_$TemplateModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
